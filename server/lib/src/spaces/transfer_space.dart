import 'package:sqlite3/sqlite3.dart';

import '../db/db.dart';

// hand space to new owner. old owner's membership is dropped by caller.
void transferSpace(Database db, String spaceId, String newOwnerId) =>
    inTransaction(db, () {
      db.execute('UPDATE spaces SET owner_id = ? WHERE id = ?', [newOwnerId, spaceId]);
      db.execute(
        "UPDATE members SET role = 'owner' WHERE space_id = ? AND account_id = ?",
        [spaceId, newOwnerId],
      );
    });
