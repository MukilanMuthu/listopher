import 'package:http/http.dart' as http;

import 'package:listopher/net/net.dart';
import 'package:listopher/store/store.dart';

import 'sync_space.dart';

/// after login: ask [serverUrl] which spaces I belong to, add the unknown
/// ones and pull each. private space is never on the server, so not restored.
/// throws if the server cannot be reached or says no.
Future<void> restoreSpaces(AppDb db, http.Client client, String serverUrl) async {
  final account = (await watchServerAccounts(db).first).firstWhere((a) => a.url == serverUrl);
  for (final id in await listMySpaces(client, serverUrl, account.token)) {
    await addBareSpace(
        db, spaceId: id, serverUrl: serverUrl, accountId: account.accountId);
    final space = (await watchSpaces(db).first).firstWhere((s) => s.id == id);
    await syncSpace(db, client, space); // fills name and items
  }
}
