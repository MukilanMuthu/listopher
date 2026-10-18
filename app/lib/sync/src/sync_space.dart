import 'package:http/http.dart' as http;

import 'package:listopher/net/net.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';

/// sync one shared space: send outbox, pull new ops (all pages), rebuild state.
/// throws if the server cannot be reached or says no.
Future<void> syncSpace(AppDb db, http.Client client, SpaceRow space) async {
  final url = space.serverUrl!; // caller passes shared spaces only
  final account = (await watchServerAccounts(db).first).firstWhere((a) => a.url == url);
  await pushSpace(db, client, space.id);
  // page loop: empty page = caught up
  while (true) {
    final after = await lastSeq(db, space.id);
    final page = await pullOps(client, url, account.token, space.id, after);
    if (page.isEmpty) break;
    await storeOps(db, page);
  }
  await rebuildSpace(db, space.id);
}
