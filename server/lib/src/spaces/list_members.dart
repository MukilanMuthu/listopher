import 'package:sqlite3/sqlite3.dart';

// members of space: names for blame + buyer picker.
List<Map<String, Object?>> listMembers(Database db, String spaceId) => [
      for (final r in db.select(
        'SELECT a.id, a.display_name, m.role FROM members m '
        'JOIN accounts a ON a.id = m.account_id '
        'WHERE m.space_id = ? ORDER BY m.joined_at, a.id',
        [spaceId],
      ))
        {'user_id': r['id'], 'display_name': r['display_name'], 'role': r['role']},
    ];
