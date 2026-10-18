import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/join/join.dart';
import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/store/store.dart';

import 'login_screen.dart';
import 'show_join_dialog.dart';

/// the join action: ask for a link, log in to its server if needed, join.
/// cancel or backing out of login stops quietly. every failure shows a message.
Future<void> startJoin(BuildContext context, AppDb db, http.Client client) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final text = await showJoinDialog(context);
  if (text == null) return;
  final InviteLink link;
  try {
    link = parseInviteLink(text);
  } on BadInviteLink {
    messenger.showSnackBar(SnackBar(content: Text(t.badLink)));
    return;
  }
  // not signed in to that server: log in first, url already filled in
  if (!(await watchServerAccounts(db).first).any((a) => a.url == link.server)) {
    await navigator.push(MaterialPageRoute<void>(
      builder: (_) => LoginScreen(db: db, client: client, initialUrl: link.server),
    ));
    // ponytail: login to a different url than the link's counts as backing out
    if (!(await watchServerAccounts(db).first).any((a) => a.url == link.server)) return;
  }
  try {
    await joinByLink(db, client, link);
  } on BadInvite {
    messenger.showSnackBar(SnackBar(content: Text(t.badInvite)));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(t.couldNotJoin)));
  }
}
