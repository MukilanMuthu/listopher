import 'package:flutter/material.dart';

import 'package:listopher/l10n/app_localizations.dart';

/// warn before deleting an account: which owned spaces pass on, which die.
/// true = confirmed, false = cancelled.
Future<bool> showDeleteAccountDialog(
  BuildContext context,
  String serverUrl,
  List<String> transferNames,
  List<String> deleteNames,
) async {
  final t = AppLocalizations.of(context);
  final yes = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t.deleteAccountQuestion(serverUrl)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // a line only when there is something to say
          if (transferNames.isNotEmpty) Text(t.handedOver(transferNames.join(', '))),
          if (deleteNames.isNotEmpty) Text(t.willBeDeleted(deleteNames.join(', '))),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.delete)),
      ],
    ),
  );
  return yes ?? false; // tap outside = cancel
}
