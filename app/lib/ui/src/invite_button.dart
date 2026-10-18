import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'start_invite.dart';

/// invite button for a shared space. the caller shows it to the owner only.
class InviteButton extends StatelessWidget {
  final AppDb db;
  final http.Client client;
  final SpaceRow space;
  const InviteButton({super.key, required this.db, required this.client, required this.space});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.person_add),
      tooltip: AppLocalizations.of(context).invite,
      onPressed: () => startInvite(context, db, client, space),
    );
  }
}
