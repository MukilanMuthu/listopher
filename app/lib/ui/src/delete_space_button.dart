import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'start_delete_space.dart';

/// trash button for a shared space I created (= the owner). nothing for others.
/// ponytail: creator = owner. after the owner's account is deleted and the server
/// passes the space on, the new owner gets no button; the old one's tap gets a 403 message.
class DeleteSpaceButton extends StatelessWidget {
  final AppDb db;
  final http.Client client;
  final SpaceRow space;
  const DeleteSpaceButton({super.key, required this.db, required this.client, required this.space});

  @override
  Widget build(BuildContext context) {
    if (space.private) return const SizedBox.shrink(); // never on a server
    return FutureBuilder<bool>(
      future: isMe(db, space.createdBy),
      builder: (context, snap) => snap.data == true
          ? IconButton(
              icon: const Icon(Icons.delete),
              tooltip: AppLocalizations.of(context).deleteSpace,
              onPressed: () => startDeleteSpace(context, db, client, space),
            )
          : const SizedBox.shrink(),
    );
  }
}
