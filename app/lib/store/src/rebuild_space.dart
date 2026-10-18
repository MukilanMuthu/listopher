import 'dart:convert';

import 'package:drift/drift.dart' show InsertMode, OrderingTerm, Value;
import 'package:listopher_core/core.dart';

import 'app_db.dart';
import 'apply_item_op.dart';
import 'apply_space_op.dart';

/// rebuild the space row and its items from the op log (ADR 3):
/// confirmed ops by server seq, then pending ops in the order I made them.
/// ponytail: deletes and rewrites all item rows of the space.
Future<void> rebuildSpace(AppDb db, String spaceId) {
  return db.transaction(() async {
    final rows = await (db.select(db.ops)
          ..where((o) => o.spaceId.equals(spaceId))
          ..orderBy([(o) => OrderingTerm.asc(o.seq)]))
        .get();
    final confirmed = rows.where((r) => r.serverSeq != null).toList()
      ..sort((x, y) => x.serverSeq!.compareTo(y.serverSeq!));
    final pending = rows.where((r) => r.serverSeq == null);

    // replay: pure, no db
    SpaceRow? space;
    final items = <String, ItemRow>{};
    for (final r in [...confirmed, ...pending]) {
      final op = opFromJson(jsonDecode(r.json) as Map<String, Object?>);
      space = applySpaceOp(space, op);
      final id = op.itemId;
      if (id == null) continue;
      final item = applyItemOp(items[id], op);
      if (item != null) items[id] = item;
    }
    if (space == null) return; // no space.create yet: nothing to show

    // keep the server url: ops do not carry it
    final old = await (db.select(db.spaces)..where((s) => s.id.equals(spaceId))).getSingleOrNull();
    await db.into(db.spaces).insert(space.copyWith(serverUrl: Value(old?.serverUrl)),
        mode: InsertMode.insertOrReplace);
    await (db.delete(db.items)..where((i) => i.spaceId.equals(spaceId))).go();
    for (final item in items.values) {
      await db.into(db.items).insert(item);
    }
  });
}
