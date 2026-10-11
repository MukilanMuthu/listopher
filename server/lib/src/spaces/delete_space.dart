import 'package:sqlite3/sqlite3.dart';

import '../db/db.dart';

// wipe space: ops, members, space. members get 404 on next sync.
void deleteSpace(Database db, String spaceId) => inTransaction(db, () {
      db.execute('DELETE FROM ops WHERE space_id = ?', [spaceId]);
      db.execute('DELETE FROM members WHERE space_id = ?', [spaceId]);
      db.execute('DELETE FROM spaces WHERE id = ?', [spaceId]);
    });
