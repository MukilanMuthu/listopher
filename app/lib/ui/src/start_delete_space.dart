import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/share/share.dart';
import 'package:listopher/store/store.dart';

import 'show_delete_space_dialog.dart';

/// the delete action: confirm, then delete on server and phone.
/// cancel stops quietly. server refusing or down shows a message, space stays.
Future<void> startDeleteSpace(
  BuildContext context,
  AppDb db,
  http.Client client,
  SpaceRow space,
) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  if (!await showDeleteSpaceDialog(context, space.name)) return;
  try {
    await deleteSharedSpace(db, client, space.id);
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(t.couldNotDeleteSpace)));
  }
}
