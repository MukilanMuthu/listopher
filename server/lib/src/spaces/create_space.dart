import 'package:sqlite3/sqlite3.dart';

import '../db/db.dart';
import 'space_exists.dart';

// register space, caller = owner. false if id taken.
bool createSpace(Database db, String id, String ownerId, DateTime now) {
  if (spaceExists(db, id)) return false;
  final at = now.toUtc().toIso8601String();
  inTransaction(db, () {
    db.execute(
      'INSERT INTO spaces (id, owner_id, created_at) VALUES (?, ?, ?)',
      [id, ownerId, at],
    );
    db.execute(
      "INSERT INTO members (space_id, account_id, role, joined_at) VALUES (?, ?, 'owner', ?)",
      [id, ownerId, at],
    );
  });
  return true;
}
