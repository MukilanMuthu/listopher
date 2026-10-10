import 'package:drift/drift.dart';

import 'tables.dart';

part 'app_db.g.dart';

/// the phone database. pass a QueryExecutor so tests can use memory db.
@DriftDatabase(tables: [Users, Lists, Items, Ops])
class AppDb extends _$AppDb {
  AppDb(super.e);

  @override
  int get schemaVersion => 1;
}
