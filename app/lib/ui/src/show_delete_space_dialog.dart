import 'package:flutter/material.dart';

import 'package:listopher/l10n/app_localizations.dart';

/// ask "delete [name] for everyone?". true = confirmed, false = cancelled.
Future<bool> showDeleteSpaceDialog(BuildContext context, String name) async {
  final t = AppLocalizations.of(context);
  final yes = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t.deleteSpaceQuestion(name)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.delete)),
      ],
    ),
  );
  return yes ?? false; // tap outside = cancel
}
