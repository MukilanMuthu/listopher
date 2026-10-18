import 'package:drift/drift.dart' show innerJoin;

import 'app_db.dart';

/// ids of the shared spaces where I am the owner, by the cached member roles.
/// follows a server ownership transfer at the next sync.
Stream<Set<String>> watchOwnedSpaceIds(AppDb db) {
  // members joined with my accounts: a row is mine when its user id is one of my account ids
  final query = db.select(db.members).join([
    innerJoin(db.serverAccounts, db.serverAccounts.accountId.equalsExp(db.members.userId)),
  ])
    ..where(db.members.role.equals('owner'));
  return query.watch().map((rows) => {for (final r in rows) r.readTable(db.members).spaceId});
}
