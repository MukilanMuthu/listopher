import 'package:drift/drift.dart';

import 'app_db.dart';

/// live items of all spaces: not deleted, unchecked first, then oldest request.
Stream<List<ItemRow>> watchItems(AppDb db) {
  return (db.select(db.items)
        ..where((i) => i.deleted.equals(false))
        ..orderBy([
          (i) => OrderingTerm(expression: i.checked), // false sorts before true
          (i) => OrderingTerm(expression: i.requestedAt),
        ]))
      .watch();
}
