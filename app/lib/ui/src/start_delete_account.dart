import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';

import 'show_delete_account_dialog.dart';

/// the delete-account action: ask the server what happens to my spaces, warn, confirm, delete.
/// cancel stops quietly. server down or refusing shows a message, phone keeps everything.
Future<void> startDeleteAccount(
  BuildContext context,
  AppDb db,
  http.Client client,
  ServerAccountRow server,
) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    final preview = await deletePreview(client, server.url, server.token);
    final names = {for (final s in await watchSpaces(db).first) s.id: s.name};
    if (!context.mounted) return;
    final ok = await showDeleteAccountDialog(
      context,
      server.url,
      [for (final id in preview.transfer) names[id] ?? id], // unknown id: show the id
      [for (final id in preview.delete) names[id] ?? id],
    );
    if (!ok) return;
    await deleteMyAccount(db, client, server.url);
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(t.couldNotDeleteAccount)));
  }
}
