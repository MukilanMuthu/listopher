import 'package:drift/drift.dart';

import 'app_db.dart';

/// all lists: newest date first, no-date last, then newest created.
Stream<List<ListRow>> watchLists(AppDb db) {
  return (db.select(db.lists)
        ..orderBy([
          (l) => OrderingTerm(
              expression: l.date, mode: OrderingMode.desc, nulls: NullsOrder.last),
          (l) => OrderingTerm(expression: l.createdAt, mode: OrderingMode.desc),
        ]))
      .watch();
}
