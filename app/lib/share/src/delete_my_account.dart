import 'package:http/http.dart' as http;

import 'package:listopher/net/net.dart';
import 'package:listopher/store/store.dart';

/// delete my account on a server, then clean the phone like a logout.
/// throws if the server cannot be reached or says no: phone keeps everything.
Future<void> deleteMyAccount(AppDb db, http.Client client, String serverUrl) async {
  final account = (await watchServerAccounts(db).first).firstWhere((a) => a.url == serverUrl);
  await deleteAccount(client, serverUrl, account.token);
  await forgetServer(db, serverUrl);
}
