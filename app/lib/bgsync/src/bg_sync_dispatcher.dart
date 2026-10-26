import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

import 'package:listopher/store/store.dart';
import 'package:listopher/sync/sync.dart';
import 'package:listopher/widget/widget.dart';

import 'background_sync.dart';
import 'queue_sync_on_network.dart';

/// entry for the background isolate. WorkManager calls it by name, so keep the pragma.
/// periodic task = back-off sync. on-network one-off = plain best-effort sync.
/// never queues anything itself: no retry loop on a dead server.
@pragma('vm:entry-point')
void bgSyncDispatcher() {
  Workmanager().executeTask((task, input) async {
    // fresh db: own sqlite connection to the same file (busy timeout covers clashes)
    final db = openAppDb();
    final client = http.Client();
    try {
      if (task == onNetworkTask) {
        // one-off: foreground already showed the error. no back-off check, no
        // saved failure, so it never touches the periodic job's back-off.
        try {
          await sync(db, client);
          await refreshWidget(db, syncFailed: false).catchError((_) {});
        } catch (_) {
          await refreshWidget(db, syncFailed: true).catchError((_) {});
        } // best effort
      } else {
        await backgroundSync(db, client, DateTime.now());
      }
    } finally {
      client.close();
      await db.close();
    }
    // always success: back-off is kept in the DB, not by WorkManager retry
    return true;
  });
}
