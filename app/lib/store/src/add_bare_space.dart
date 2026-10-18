import 'app_db.dart';

/// insert a shared space we only know the id of. name is a placeholder;
/// the first sync pulls space.create and fills it in.
/// already there = do nothing.
Future<void> addBareSpace(
  AppDb db, {
  required String spaceId,
  required String serverUrl,
  required String accountId,
}) async {
  // ponytail: check then insert, no lock. fine, one caller at a time.
  final known = await (db.select(db.spaces)..where((s) => s.id.equals(spaceId))).get();
  if (known.isNotEmpty) return;
  await db.into(db.spaces).insert(SpaceRow(
      id: spaceId,
      name: '?',
      private: false,
      serverUrl: serverUrl,
      createdBy: '', // unknown until sync: must not look like me
      createdAt: DateTime.now()));
}
