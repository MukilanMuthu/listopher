import 'package:sqlite3/sqlite3.dart';

import 'dummy_hash.dart';
import 'hash_token.dart';
import 'login_locked.dart';
import 'new_token.dart';
import 'record_failed_login.dart';
import 'verify_password.dart';

// check password, make session. returns {token, user_id, display_name}.
// null = bad credentials (unknown user and wrong password look the same).
// throws LoginLocked while account is locked.
Map<String, Object?>? login(Database db, String username, String password, DateTime now) {
  final rows = db.select(
    'SELECT id, password_hash, display_name, failed_logins, locked_until '
    'FROM accounts WHERE username = ?',
    [username],
  );
  if (rows.isEmpty) {
    // unknown user: still run slow hash, so timing matches wrong password
    verifyPassword(password, dummyHash);
    return null;
  }
  final a = rows.first;
  final lockedUntil = a['locked_until'] as String?;
  if (lockedUntil != null && DateTime.parse(lockedUntil).isAfter(now)) {
    throw const LoginLocked();
  }
  final id = a['id'] as String;
  if (!verifyPassword(password, a['password_hash'] as String)) {
    recordFailedLogin(db, id, a['failed_logins'] as int, now);
    return null;
  }
  // good: clear failures, open session. only the token hash is stored.
  db.execute(
    'UPDATE accounts SET failed_logins = 0, locked_until = NULL WHERE id = ?',
    [id],
  );
  final token = newToken();
  db.execute(
    'INSERT INTO sessions (token_hash, account_id, created_at) VALUES (?, ?, ?)',
    [hashToken(token), id, now.toUtc().toIso8601String()],
  );
  return {'token': token, 'user_id': id, 'display_name': a['display_name']};
}
