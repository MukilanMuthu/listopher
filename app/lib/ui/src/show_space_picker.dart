import 'package:flutter/material.dart';

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'space_label.dart';

/// ask which space gets the new items. null = cancelled.
Future<SpaceRow?> showSpacePicker(BuildContext context, List<SpaceRow> spaces) {
  final t = AppLocalizations.of(context);
  return showDialog<SpaceRow>(
    context: context,
    builder: (_) => SimpleDialog(
      title: Text(t.pickSpace),
      children: [
        // tap a space → dialog closes with it
        for (final space in spaces)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, space),
            child: Text(spaceLabel(space, t)),
          ),
      ],
    ),
  );
}
