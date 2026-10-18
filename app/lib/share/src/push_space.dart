import 'package:http/http.dart' as http;

import 'package:listopher/net/net.dart';
import 'package:listopher/store/store.dart';

/// upload a shared space's outbox and mark the answered ops confirmed.
/// throws if the server cannot be reached or says no: ops stay in the outbox.
/// private space throws StateError (from outbox).
Future<void> pushSpace(AppDb db, http.Client client, String spaceId) async {
  final ops = await outbox(db, spaceId);
  if (ops.isEmpty) return; // nothing to send
  final space = (await watchSpaces(db).first).firstWhere((s) => s.id == spaceId);
  final url = space.serverUrl!; // outbox already refused unshared spaces
  final account =
      (await watchServerAccounts(db).first).firstWhere((a) => a.url == url);
  await confirmOps(db, await pushOps(client, url, account.token, spaceId, ops));
}
