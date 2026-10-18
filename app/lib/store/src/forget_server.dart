import 'app_db.dart';
import 'forget_space.dart';

/// drop a server from the phone: my account there and all its spaces. no server call.
Future<void> forgetServer(AppDb db, String serverUrl) {
  return db.transaction(() async {
    final spaces = await (db.select(db.spaces)..where((s) => s.serverUrl.equals(serverUrl))).get();
    for (final s in spaces) {
      await forgetSpace(db, s.id); // reuse: ops, items, row
    }
    await (db.delete(db.serverAccounts)..where((a) => a.url.equals(serverUrl))).go();
  });
}
