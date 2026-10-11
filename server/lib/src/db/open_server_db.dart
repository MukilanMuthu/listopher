import 'package:sqlite3/sqlite3.dart';

import 'apply_schema.dart';

// open db file (or ':memory:'), set pragmas, make tables.
Database openServerDb(String path) {
  final db = sqlite3.open(path);
  db.execute('PRAGMA journal_mode = WAL'); // readers do not block writer
  db.execute('PRAGMA foreign_keys = ON'); // off by default in sqlite
  applySchema(db);
  return db;
}
