import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';

import 'error_text.dart';
import 'show_unsent_dialog.dart';

/// the log-out action: send the outbox first; if ops are still unsent, confirm they will be lost.
/// cancel stops quietly. server down or refusing shows a message, phone keeps everything.
Future<void> startLogOut(
  BuildContext context,
  AppDb db,
  http.Client client,
  ServerAccountRow server,
) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await flushServer(db, client, server.url);
    final unsent = await unsentCount(db, server.url);
    if (unsent > 0) {
      if (!context.mounted || !await showUnsentDialog(context, unsent)) return;
    }
    await logOut(db, client, server.url);
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(errorText(t, e, t.couldNotLogOut))));
  }
}
