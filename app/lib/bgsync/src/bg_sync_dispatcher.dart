import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

import 'package:listopher/store/store.dart';

import 'background_sync.dart';

/// entry for the background isolate. WorkManager calls it by name, so keep the pragma.
/// any task name does the same sync (periodic and on-network one-off share this).
/// never queues anything itself: no retry loop on a dead server.
@pragma('vm:entry-point')
void bgSyncDispatcher() {
  Workmanager().executeTask((task, input) async {
    // fresh db + client: this isolate shares nothing with the app
    final db = openAppDb();
    final client = http.Client();
    try {
      await backgroundSync(db, client, DateTime.now());
    } finally {
      client.close();
      await db.close();
    }
    // always success: back-off is kept in the DB, not by WorkManager retry
    return true;
  });
}
