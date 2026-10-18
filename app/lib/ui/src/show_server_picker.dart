import 'package:flutter/material.dart';

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

/// ask which server the new space lives on. null = cancelled.
Future<ServerAccountRow?> showServerPicker(
  BuildContext context,
  List<ServerAccountRow> servers,
) {
  final t = AppLocalizations.of(context);
  return showDialog<ServerAccountRow>(
    context: context,
    builder: (_) => SimpleDialog(
      title: Text(t.pickServer),
      children: [
        // tap a server → dialog closes with it
        for (final s in servers)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, s),
            child: Text(s.url),
          ),
      ],
    ),
  );
}
