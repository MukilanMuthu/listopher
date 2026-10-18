import 'package:http/http.dart' as http;

import 'package:listopher/net/net.dart' as net;
import 'package:listopher/store/store.dart';
import 'package:listopher/sync/sync.dart';

import 'invite_link.dart';

/// joiner: join the space on the server, then restore pulls it and its items.
/// needs a saved account on the link's server (caller logs in first).
/// throws BadInvite on a wrong or rotated invite, else if the server cannot be reached.
/// ponytail: restore also syncs my other spaces on that server. fine, cheap.
Future<void> joinByLink(AppDb db, http.Client client, InviteLink link) async {
  final account = (await watchServerAccounts(db).first).firstWhere((a) => a.url == link.server);
  await net.joinSpace(client, link.server, account.token, link.space, link.invite);
  await restoreSpaces(db, client, link.server);
}
