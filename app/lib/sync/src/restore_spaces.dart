import 'package:http/http.dart' as http;

import 'package:listopher/net/net.dart';
import 'package:listopher/store/store.dart';

import 'sync_failed.dart';
import 'sync_space.dart';

/// after login: ask [serverUrl] which spaces I belong to, add the unknown
/// ones and pull each. private space is never on the server, so not restored.
/// a failing space does not stop the others (it stays bare, a retry heals it);
/// throws SyncFailed once at the end. throws if the space list cannot be fetched.
Future<void> restoreSpaces(AppDb db, http.Client client, String serverUrl) async {
  final account = (await watchServerAccounts(db).first).firstWhere((a) => a.url == serverUrl);
  final errors = <Object>[];
  for (final id in await listMySpaces(client, serverUrl, account.token)) {
    await addBareSpace(
        db, spaceId: id, serverUrl: serverUrl, accountId: account.accountId);
    final space = (await watchSpaces(db).first).firstWhere((s) => s.id == id);
    try {
      await syncSpace(db, client, space); // fills name and items
    } catch (e) {
      errors.add(e);
    }
  }
  if (errors.isNotEmpty) throw SyncFailed(errors);
}
