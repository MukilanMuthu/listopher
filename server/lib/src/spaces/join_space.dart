import 'package:sqlite3/sqlite3.dart';

// join as member if invite matches. false = wrong invite.
// already member → no-op (still true).
// ponytail: plain string compare, not constant-time. invite is 122 bits, guessing is hopeless.
bool joinSpace(Database db, String spaceId, String accountId, String invite, DateTime now) {
  final rows = db.select('SELECT invite_token FROM spaces WHERE id = ?', [spaceId]);
  final token = rows.isEmpty ? null : rows.first['invite_token'] as String?;
  if (token == null || token != invite) return false; // no invite yet, or wrong
  db.execute(
    "INSERT OR IGNORE INTO members (space_id, account_id, role, joined_at) VALUES (?, ?, 'member', ?)",
    [spaceId, accountId, now.toUtc().toIso8601String()],
  );
  return true;
}
