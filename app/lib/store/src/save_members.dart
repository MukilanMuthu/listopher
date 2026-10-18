import 'app_db.dart';

/// replace the cached members of a space with the server's list:
/// user id → (display name, role 'owner' | 'member').
Future<void> saveMembers(
  AppDb db,
  String spaceId,
  Map<String, ({String name, String role})> members,
) {
  return db.transaction(() async {
    // old rows out: members who left must not linger
    await (db.delete(db.members)..where((m) => m.spaceId.equals(spaceId))).go();
    for (final e in members.entries) {
      await db.into(db.members).insert(MembersCompanion.insert(
          spaceId: spaceId, userId: e.key, displayName: e.value.name, role: e.value.role));
    }
  });
}
