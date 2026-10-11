import 'package:sqlite3/sqlite3.dart';

import 'hash_token.dart';

// logout: drop this one session.
void deleteSession(Database db, String token) =>
    db.execute('DELETE FROM sessions WHERE token_hash = ?', [hashToken(token)]);
