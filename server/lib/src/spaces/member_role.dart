import 'package:sqlite3/sqlite3.dart';

// 'owner' / 'member' / null (not in space).
String? memberRole(Database db, String spaceId, String accountId) {
  final rows = db.select(
    'SELECT role FROM members WHERE space_id = ? AND account_id = ?',
    [spaceId, accountId],
  );
  return rows.isEmpty ? null : rows.first['role'] as String;
}
