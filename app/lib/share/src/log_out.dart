import 'package:http/http.dart' as http;

import 'package:listopher/net/net.dart';
import 'package:listopher/store/store.dart';

/// log out of a server: session first, then the phone forgets the account and its spaces.
/// throws if the server cannot be reached or says no: phone keeps everything.
/// ponytail: a dead token (401) also throws, so the account cannot be dropped then.
Future<void> logOut(AppDb db, http.Client client, String serverUrl) async {
  final account = (await watchServerAccounts(db).first).firstWhere((a) => a.url == serverUrl);
  await logout(client, serverUrl, account.token);
  await forgetServer(db, serverUrl);
}
