import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'start_delete_account.dart';
import 'start_log_out.dart';

/// one server I am signed in to, with log out and delete account buttons.
class ServerTile extends StatelessWidget {
  final AppDb db;
  final http.Client client;
  final ServerAccountRow server;
  const ServerTile({super.key, required this.db, required this.client, required this.server});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.cloud_done),
      title: Text(t.signedInTo(server.url)),
      subtitle: Text(server.displayName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: t.logOut,
            onPressed: () => startLogOut(context, db, client, server),
          ),
          IconButton(
            icon: const Icon(Icons.person_remove),
            tooltip: t.deleteAccount,
            onPressed: () => startDeleteAccount(context, db, client, server),
          ),
        ],
      ),
    );
  }
}
