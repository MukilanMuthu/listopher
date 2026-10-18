import 'package:flutter/material.dart';

import 'package:listopher/l10n/app_localizations.dart';

/// ask which member bought the item. [members] is user id → name, me first,
/// so the top option is the default. returns the user id, null = cancelled.
Future<String?> showBuyerPicker(BuildContext context, Map<String, String> members) {
  final t = AppLocalizations.of(context);
  return showDialog<String>(
    context: context,
    builder: (_) => SimpleDialog(
      title: Text(t.whoBought),
      children: [
        // tap a member → dialog closes with their id
        for (final m in members.entries)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, m.key),
            child: Text(m.value),
          ),
      ],
    ),
  );
}
