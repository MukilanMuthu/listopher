import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/join/join.dart';
import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'show_invite_dialog.dart';

/// the invite action: make a fresh link (old ones die) and show it.
/// server refusing or down shows a message.
Future<void> startInvite(
  BuildContext context,
  AppDb db,
  http.Client client,
  SpaceRow space,
) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final String link;
  try {
    link = await makeInviteLink(db, client, space.id);
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(t.couldNotInvite)));
    return;
  }
  if (!context.mounted) return;
  await showInviteDialog(context, link);
}
