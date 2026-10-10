import 'package:drift/drift.dart';

import 'tables.dart';

part 'app_db.g.dart';

/// the phone database. pass a QueryExecutor so tests can use memory db.
@DriftDatabase(tables: [Users, Spaces, Items, Ops])
class AppDb extends _$AppDb {
  AppDb(super.e);

  // ponytail: nothing shipped, so schema stays 1 and no migrations.
  // dev builds must clear app data when tables change.
  @override
  int get schemaVersion => 1;
}
