import 'package:flutter/material.dart';

import 'package:listopher/l10n/app_localizations.dart';

/// warn that [count] unsent changes die on log out. true = log out anyway, false = cancelled.
Future<bool> showUnsentDialog(BuildContext context, int count) async {
  final t = AppLocalizations.of(context);
  final yes = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t.unsentWillBeLost(count)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.logOut)),
      ],
    ),
  );
  return yes ?? false; // tap outside = cancel
}
