import 'package:http/http.dart' as http;

import 'package:listopher/net/net.dart';
import 'package:listopher/store/store.dart';

/// delete a shared space: server first, then the phone.
/// throws if the server cannot be reached or says no (not owner): phone keeps the space.
Future<void> deleteSharedSpace(AppDb db, http.Client client, String spaceId) async {
  final space = (await watchSpaces(db).first).firstWhere((s) => s.id == spaceId);
  final account = (await watchServerAccounts(db).first).firstWhere((a) => a.url == space.serverUrl);
  await deleteSpace(client, account.url, account.token, spaceId);
  await forgetSpace(db, spaceId);
}
