import 'package:listopher_core/core.dart';
import 'package:sqlite3/sqlite3.dart';

import 'hash_password.dart';

// admin makes an account. returns its server-made id.
// duplicate username → SqliteException (unique index).
String addUser(Database db, String username, String displayName, String password) {
  final id = newId();
  db.execute(
    'INSERT INTO accounts (id, username, password_hash, display_name, created_at) '
    'VALUES (?, ?, ?, ?, ?)',
    [id, username, hashPassword(password), displayName, DateTime.now().toUtc().toIso8601String()],
  );
  return id;
}
