import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'start_invite.dart';

/// invite button for a shared space I created (= the owner). nothing for others.
/// ponytail: creator = owner, same limit as DeleteSpaceButton.
class InviteButton extends StatelessWidget {
  final AppDb db;
  final http.Client client;
  final SpaceRow space;
  const InviteButton({super.key, required this.db, required this.client, required this.space});

  @override
  Widget build(BuildContext context) {
    if (space.private) return const SizedBox.shrink(); // never on a server
    return FutureBuilder<bool>(
      future: isMe(db, space.createdBy),
      builder: (context, snap) => snap.data == true
          ? IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: AppLocalizations.of(context).invite,
              onPressed: () => startInvite(context, db, client, space),
            )
          : const SizedBox.shrink(),
    );
  }
}
