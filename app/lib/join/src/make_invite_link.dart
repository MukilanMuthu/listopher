import 'package:http/http.dart' as http;

import 'package:listopher/net/net.dart';
import 'package:listopher/store/store.dart';

import 'build_invite_link.dart';

/// owner: new invite for a shared space, as a link to hand out. old links die.
/// throws if the server cannot be reached or says no (not the owner).
Future<String> makeInviteLink(AppDb db, http.Client client, String spaceId) async {
  final space = (await watchSpaces(db).first).firstWhere((s) => s.id == spaceId);
  final url = space.serverUrl!; // caller passes shared spaces only
  final account = (await watchServerAccounts(db).first).firstWhere((a) => a.url == url);
  return buildInviteLink(url, spaceId, await createInvite(client, url, account.token, spaceId));
}
