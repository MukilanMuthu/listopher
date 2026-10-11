import 'package:sqlite3/sqlite3.dart';

// ids of spaces this account owns.
List<String> ownedSpaceIds(Database db, String accountId) => [
      for (final r in db.select(
        "SELECT space_id FROM members WHERE account_id = ? AND role = 'owner' ORDER BY space_id",
        [accountId],
      ))
        r['space_id'] as String,
    ];
