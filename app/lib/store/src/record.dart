import 'dart:convert';

import 'package:drift/drift.dart' show InsertMode;

import 'package:listopher_core/core.dart';

import 'app_db.dart';
import 'apply_item_op.dart';
import 'apply_space_op.dart';

/// log a change made on this phone: save op in outbox + update space/item rows.
Future<void> record(
  AppDb db, {
  required String spaceId,
  String? itemId,
  required OpBody body,
}) {
  return db.transaction(() async {
    // who am i. no profile = cannot blame anyone
    final me = await (db.select(
      db.users,
    )..where((u) => u.isMe.equals(true))).getSingleOrNull();
    if (me == null) throw StateError('no me user; createMe first');

    final space = await (db.select(
      db.spaces,
    )..where((s) => s.id.equals(spaceId))).getSingleOrNull();
    final op = Op(
      id: newId(),
      spaceId: spaceId,
      itemId: itemId,
      userId: me.id,
      clientTime: DateTime.now().toUtc(),
      serverSeq: null, // not synced yet
      body: body,
    );

    // op into log (serverSeq null = outbox)
    await db
        .into(db.ops)
        .insert(
          OpsCompanion.insert(
            id: op.id,
            spaceId: spaceId,
            json: jsonEncode(opToJson(op)),
          ),
        );

    // replace whole row: upsert skips null cols, so cleared fields would stay
    // space row. item ops skip it: rewriting same row wakes every watchSpaces listener
    final newSpace = itemId == null ? applySpaceOp(space, op) : null;
    if (newSpace != null) {
      await db.into(db.spaces).insert(newSpace, mode: InsertMode.insertOrReplace);
    }

    // item row
    if (itemId != null) {
      final item = await (db.select(
        db.items,
      )..where((i) => i.id.equals(itemId))).getSingleOrNull();
      final newItem = applyItemOp(item, op);
      if (newItem != null) {
        await db.into(db.items).insert(newItem, mode: InsertMode.insertOrReplace);
      }
    }
  });
}
