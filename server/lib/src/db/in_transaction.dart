import 'package:sqlite3/sqlite3.dart';

// run body all-or-nothing. error → undo everything, rethrow.
// savepoint (not BEGIN) so nesting works.
T inTransaction<T>(Database db, T Function() body) {
  db.execute('SAVEPOINT tx'); // start (or nest)
  try {
    final result = body();
    db.execute('RELEASE tx'); // keep
    return result;
  } catch (_) {
    db.execute('ROLLBACK TO tx'); // undo
    db.execute('RELEASE tx');
    rethrow;
  }
}
