import 'package:sqlite3/sqlite3.dart';

// kill every session of user (stolen phone). unknown user → StateError.
void revokeSessions(Database db, String username) {
  final rows = db.select('SELECT id FROM accounts WHERE username = ?', [username]);
  if (rows.isEmpty) throw StateError('no such user: $username');
  db.execute('DELETE FROM sessions WHERE account_id = ?', [rows.first['id']]);
}
