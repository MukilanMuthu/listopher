import 'dart:convert';

import 'package:drift/drift.dart' show InsertMode;

import 'package:listopher_core/core.dart';

import 'app_db.dart';
import 'apply_item_op.dart';
import 'apply_list_op.dart';

/// log a change made on this phone: save op in outbox + update list/item rows.
Future<void> record(
  AppDb db, {
  required String listId,
  String? itemId,
  required OpBody body,
}) {
  return db.transaction(() async {
    // who am i. no profile = cannot blame anyone
    final me = await (db.select(
      db.users,
    )..where((u) => u.isMe.equals(true))).getSingleOrNull();
    if (me == null) throw StateError('no me user; createMe first');

    // group comes from existing list. new/local list = null
    final list = await (db.select(
      db.lists,
    )..where((l) => l.id.equals(listId))).getSingleOrNull();
    final op = Op(
      id: newId(),
      groupId: list?.groupId,
      listId: listId,
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
            listId: listId,
            json: jsonEncode(opToJson(op)),
          ),
        );

    // replace whole row: upsert skips null cols, so cleared fields would stay
    // list row. item ops skip it: rewriting same row wakes every watchLists listener
    final newList = itemId == null ? applyListOp(list, op) : null;
    if (newList != null) {
      await db.into(db.lists).insert(newList, mode: InsertMode.insertOrReplace);
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
