import 'package:drift/drift.dart';

import 'app_db.dart';

/// live items of one list: not deleted, unchecked first, then oldest request.
Stream<List<ItemRow>> watchItems(AppDb db, String listId) {
  return (db.select(db.items)
        ..where((i) => i.listId.equals(listId) & i.deleted.equals(false))
        ..orderBy([
          (i) => OrderingTerm(expression: i.checked), // false sorts before true
          (i) => OrderingTerm(expression: i.requestedAt),
        ]))
      .watch();
}
