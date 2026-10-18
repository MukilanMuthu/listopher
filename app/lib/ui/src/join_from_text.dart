import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/join/join.dart';
import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/store/store.dart';

import 'login_screen.dart';

/// the join flow for a link as text (pasted or scanned): log in to its server if needed, join.
/// backing out of login stops quietly. every failure shows a message.
Future<void> joinFromText(BuildContext context, AppDb db, http.Client client, String text) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
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
