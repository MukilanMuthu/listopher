import 'package:http/http.dart' as http;

import 'package:listopher/store/store.dart';
import 'package:listopher/sync/sync.dart';

import 'backoff_wait.dart';

/// one run of the background job: sync, unless the back-off wait is not over.
/// never throws: background must stay silent. error text goes to the DB.
/// ponytail: a failure in the DB itself is also swallowed and lost.
Future<void> backgroundSync(AppDb db, http.Client client, DateTime now) async {
  try {
    final state = await readBgSyncState(db);
    final failAt = state.lastFailAt;
    // still inside the wait: no network
    if (failAt != null && now.isBefore(failAt.add(backoffWait(state.failures)))) return;
    await sync(db, client); // good sync resets the failures itself
  } catch (e) {
    try {
      await saveBgSyncFailure(db, now, e.toString());
    } catch (_) {} // nothing more to do
  }
}
