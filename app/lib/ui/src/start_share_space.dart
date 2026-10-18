import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';

import 'error_text.dart';
import 'login_screen.dart';
import 'show_server_picker.dart';
import 'show_space_dialog.dart';

/// the + button: pick server (log in first if none), ask name, share the space.
/// any cancel stops quietly. server refusing shows a message; dead token says log in again.
Future<void> startShareSpace(BuildContext context, AppDb db, http.Client client) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  var servers = await watchServerAccounts(db).first;
  // nobody to share through: log in, then look again
  if (servers.isEmpty) {
    await navigator.push(MaterialPageRoute<void>(
      builder: (_) => LoginScreen(db: db, client: client),
    ));
    servers = await watchServerAccounts(db).first;
    if (servers.isEmpty) return; // backed out of login
  }
  if (!context.mounted) return;
  // one server = no question
  final server =
      servers.length == 1 ? servers.single : await showServerPicker(context, servers);
  if (server == null || !context.mounted) return;
  final name = await showSpaceDialog(context);
  if (name == null) return;
  try {
    if (!await shareNewSpace(db, client, server.url, name)) {
      messenger.showSnackBar(SnackBar(content: Text(t.couldNotShare)));
    }
  } catch (e) {
    // dead token: tell the user to log in again
    messenger.showSnackBar(SnackBar(content: Text(errorText(t, e, t.couldNotShare))));
  }
}
