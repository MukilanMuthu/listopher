import 'package:flutter/material.dart';

import 'package:listopher/l10n/app_localizations.dart';

/// dialog body for a new space. stateful: keeps typed name.
class SpaceDialog extends StatefulWidget {
  const SpaceDialog({super.key});

  @override
  State<SpaceDialog> createState() => _SpaceDialogState();
}

class _SpaceDialogState extends State<SpaceDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(t.newSpace),
      content: TextField(
        controller: _name,
        autofocus: true,
        decoration: InputDecoration(labelText: t.spaceName),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          // blank name = off
          onPressed: _name.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, _name.text.trim()),
          child: Text(t.create),
        ),
      ],
    );
  }
}
