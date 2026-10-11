import 'package:sqlite3/sqlite3.dart';

// ids of spaces this account is in. app uses it to restore after reinstall.
List<String> listMySpaces(Database db, String accountId) => [
      for (final r in db.select(
        'SELECT space_id FROM members WHERE account_id = ? ORDER BY joined_at',
        [accountId],
      ))
        r['space_id'] as String,
    ];
