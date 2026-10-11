import 'package:sqlite3/sqlite3.dart';

import 'is_eligible_owner.dart';

// oldest other member who is eligible. null = nobody, so the space must go.
String? pickNewOwner(Database db, String spaceId, String leavingId) {
  final rows = db.select(
    'SELECT account_id FROM members WHERE space_id = ? AND account_id != ? '
    'ORDER BY joined_at, account_id',
    [spaceId, leavingId],
  );
  for (final r in rows) {
    final id = r['account_id'] as String;
    if (isEligibleOwner(db, id)) return id;
  }
  return null;
}
