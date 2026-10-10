import 'package:drift/drift.dart';
import 'package:listopher_core/core.dart';

import 'app_db.dart';

/// pure: list row after op. null current = list not there yet.
ListRow? applyListOp(ListRow? current, Op op) {
  final body = op.body;
  // new list from create op
  if (body is ListCreate) {
    return ListRow(
      id: op.listId,
      groupId: op.groupId,
      name: body.name,
      date: body.date,
      createdBy: op.userId,
      createdAt: op.clientTime,
    );
  }
  // update = full state, so null date clears it. no list = ignore.
  if (body is ListUpdate && current != null) {
    return current.copyWith(name: body.name, date: Value(body.date));
  }
  return current; // item ops and ignored ops leave list alone
}
