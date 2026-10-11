import 'package:sqlite3/sqlite3.dart';

import 'hash_token.dart';

// token → account id. null = unknown token.
String? authenticate(Database db, String token) {
  final rows = db.select(
    'SELECT account_id FROM sessions WHERE token_hash = ?',
    [hashToken(token)],
  );
  return rows.isEmpty ? null : rows.first['account_id'] as String;
}
