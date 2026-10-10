import 'package:drift/drift.dart';

import 'app_db.dart';

/// all spaces: private first, then by name.
Stream<List<SpaceRow>> watchSpaces(AppDb db) {
  return (db.select(db.spaces)
        ..orderBy([
          (s) => OrderingTerm(expression: s.private, mode: OrderingMode.desc), // true first
          (s) => OrderingTerm(expression: s.name),
        ]))
      .watch();
}
