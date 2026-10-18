import 'app_db.dart';

/// pure: name to show for [userId] in [space].
/// private space → my local name. shared → cached member name.
/// no match (account deleted) → [deleted], the localized "deleted user".
String memberName(
  String userId,
  SpaceRow space,
  UserRow me,
  Map<String, String> members, // user id → display name, one space
  String deleted,
) {
  if (space.private) return userId == me.id ? me.displayName : deleted;
  return members[userId] ?? deleted;
}
