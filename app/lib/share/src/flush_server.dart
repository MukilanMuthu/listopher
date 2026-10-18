import 'package:http/http.dart' as http;

import 'package:listopher/store/store.dart';

import 'push_space.dart';

/// try to upload the outbox of every space on [serverUrl].
/// never throws: offline or refused spaces keep their ops, unsentCount tells how many.
Future<void> flushServer(AppDb db, http.Client client, String serverUrl) async {
  for (final space in await watchSpaces(db).first) {
    if (space.serverUrl != serverUrl) continue;
    try {
      await pushSpace(db, client, space.id);
    } catch (_) {
      // best effort, the caller counts what is left
    }
  }
}
