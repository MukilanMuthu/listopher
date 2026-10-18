import 'app_db.dart';

/// drop a space from the phone: its ops, items and the row. no server call.
Future<void> forgetSpace(AppDb db, String spaceId) {
  return db.transaction(() async {
    await (db.delete(db.ops)..where((o) => o.spaceId.equals(spaceId))).go();
    await (db.delete(db.items)..where((i) => i.spaceId.equals(spaceId))).go();
    await (db.delete(db.members)..where((m) => m.spaceId.equals(spaceId))).go();
    await (db.delete(db.spaces)..where((s) => s.id.equals(spaceId))).go();
  });
}
