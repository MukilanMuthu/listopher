import 'app_db.dart';

/// cached members of all spaces: space id → (user id → display name).
Stream<Map<String, Map<String, String>>> watchMembers(AppDb db) {
  return db.select(db.members).watch().map((rows) {
    final out = <String, Map<String, String>>{};
    for (final r in rows) {
      (out[r.spaceId] ??= {})[r.userId] = r.displayName;
    }
    return out;
  });
}
