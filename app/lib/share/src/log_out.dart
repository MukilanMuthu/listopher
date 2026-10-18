import 'package:http/http.dart' as http;

import 'package:listopher/net/net.dart';
import 'package:listopher/store/store.dart';

/// log out of a server: session first, then the phone forgets the account and its spaces.
/// dead token (401) = already logged out: the phone still forgets.
/// throws if the server cannot be reached or says no: phone keeps everything.
/// unsent ops die here: callers flushServer and unsentCount first.
Future<void> logOut(AppDb db, http.Client client, String serverUrl) async {
  final account = (await watchServerAccounts(db).first).firstWhere((a) => a.url == serverUrl);
  try {
    await logout(client, serverUrl, account.token);
  } on SessionExpired {
    // nothing left to end on the server
  }
  await forgetServer(db, serverUrl);
}
