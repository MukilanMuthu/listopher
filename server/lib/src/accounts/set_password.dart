import 'package:sqlite3/sqlite3.dart';

import 'hash_password.dart';

// new password for user. also clears lockout. unknown user → StateError.
void setPassword(Database db, String username, String password) {
  db.execute(
    'UPDATE accounts SET password_hash = ?, failed_logins = 0, locked_until = NULL '
    'WHERE username = ?',
    [hashPassword(password), username],
  );
  if (db.updatedRows == 0) throw StateError('no such user: $username');
}
