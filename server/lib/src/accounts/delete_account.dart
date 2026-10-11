import 'package:sqlite3/sqlite3.dart';

import '../db/db.dart';
import '../spaces/spaces.dart';

// delete account in one transaction.
// owned space → oldest eligible member, none → space deleted.
// ops the account wrote stay (blame shows "deleted user").
void deleteAccount(Database db, String accountId) => inTransaction(db, () {
      for (final id in ownedSpaceIds(db, accountId)) {
        final next = pickNewOwner(db, id, accountId);
        next == null ? deleteSpace(db, id) : transferSpace(db, id, next);
      }
      db.execute('DELETE FROM members WHERE account_id = ?', [accountId]);
      db.execute('DELETE FROM sessions WHERE account_id = ?', [accountId]);
      db.execute('DELETE FROM accounts WHERE id = ?', [accountId]);
    });
