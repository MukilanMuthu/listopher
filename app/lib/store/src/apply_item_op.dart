import 'package:drift/drift.dart';
import 'package:listopher_core/core.dart';

import 'app_db.dart';

/// pure: item row after op. null current = item not there yet.
ItemRow? applyItemOp(ItemRow? current, Op op) {
  final body = op.body;
  // add makes the row
  if (body is ItemAdd) {
    return ItemRow(
      id: op.itemId!,
      listId: op.listId,
      name: body.name,
      quantity: body.quantity,
      unit: body.unit,
      note: body.note,
      requestedBy: body.requestedBy,
      requestedAt: op.clientTime,
      checked: false,
      deleted: false,
    );
  }
  // every other op needs an existing row, else ignore
  if (current == null) return null;
  return switch (body) {
    // full state: null clears field
    ItemUpdate() => current.copyWith(
        name: body.name,
        quantity: Value(body.quantity),
        unit: Value(body.unit),
        note: Value(body.note),
      ),
    ItemCheck() => current.copyWith(
        checked: true,
        checkedBy: Value(op.userId),
        checkedAt: Value(op.clientTime),
        fulfilledBy: Value(body.fulfilledBy),
      ),
    // uncheck clears all check fields
    ItemUncheck() => current.copyWith(
        checked: false,
        checkedBy: const Value(null),
        checkedAt: const Value(null),
        fulfilledBy: const Value(null),
      ),
    // soft delete: row stays
    ItemDelete() => current.copyWith(deleted: true),
    // list ops do not touch items
    _ => current,
  };
}
