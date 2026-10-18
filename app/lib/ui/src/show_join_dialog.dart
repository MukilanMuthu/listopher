import 'package:flutter/material.dart';

import 'package:listopher/l10n/app_localizations.dart';

/// ask for a pasted invite link. null = cancelled.
/// stateless: the field's controller lives in the builder closure.
Future<String?> showJoinDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  final link = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t.joinWithLink),
      content: TextField(
        controller: link,
        autofocus: true,
        decoration: InputDecoration(labelText: t.inviteLink),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: () => Navigator.pop(context, link.text),
          child: Text(t.join),
        ),
      ],
    ),
  );
}
