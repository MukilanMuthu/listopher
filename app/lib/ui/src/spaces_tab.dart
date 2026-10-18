import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'delete_space_button.dart';
import 'invite_button.dart';
import 'login_screen.dart';
import 'server_tile.dart';
import 'start_join.dart';
import 'start_scan.dart';
import 'start_share_space.dart';
import 'space_label.dart';

/// servers I am signed in to, then all spaces: lock = private, group = shared.
/// FAB makes a shared space.
class SpacesTab extends StatelessWidget {
  final AppDb db;
  final http.Client client;
  const SpacesTab({super.key, required this.db, required this.client});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: StreamBuilder<List<SpaceRow>>(
        stream: watchSpaces(db),
        builder: (context, snap) => ListView(
          children: [
            // ponytail: re-login to the same url replaces the account.
            StreamBuilder<List<ServerAccountRow>>(
              stream: watchServerAccounts(db),
              builder: (context, snap) => Column(
                children: [
                  for (final s in snap.data ?? <ServerAccountRow>[])
                    ServerTile(db: db, client: client, server: s),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(t.logInToServer),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => LoginScreen(db: db, client: client),
              )),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(t.joinWithLink),
              onTap: () => startJoin(context, db, client),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: Text(t.scanQr),
              onTap: () => startScan(context, db, client),
            ),
            for (final space in snap.data ?? <SpaceRow>[])
              // ponytail: tap does nothing yet. space details / members come later.
              ListTile(
                leading: Icon(space.private ? Icons.lock : Icons.group),
                title: Text(spaceLabel(space, t)),
                // owner buttons: role from the cached members, so a server transfer shows
                trailing: StreamBuilder<Set<String>>(
                  stream: watchOwnedSpaceIds(db),
                  builder: (context, owned) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (owned.data?.contains(space.id) ?? false) ...[
                        InviteButton(db: db, client: client, space: space),
                        DeleteSpaceButton(db: db, client: client, space: space),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => startShareSpace(context, db, client),
        child: const Icon(Icons.add),
      ),
    );
  }
}
