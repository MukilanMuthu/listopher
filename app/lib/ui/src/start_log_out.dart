import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';

/// the log-out action. server down or refusing shows a message, phone keeps everything.
Future<void> startLogOut(
  BuildContext context,
  AppDb db,
  http.Client client,
  ServerAccountRow server,
) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await logOut(db, client, server.url);
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(t.couldNotLogOut)));
  }
}
