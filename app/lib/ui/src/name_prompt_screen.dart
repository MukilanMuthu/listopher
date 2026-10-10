import 'package:flutter/material.dart';

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

/// first run: ask the owner's name.
class NamePromptScreen extends StatefulWidget {
  final AppDb db;
  const NamePromptScreen({super.key, required this.db});

  @override
  State<NamePromptScreen> createState() => _NamePromptScreenState();
}

class _NamePromptScreenState extends State<NamePromptScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.appName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: t.yourName),
              // rebuild so Save enables/disables as user types
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            FilledButton(
              // blank name = button off
              onPressed: _name.text.trim().isEmpty
                  ? null
                  : () => createMe(widget.db, _name.text),
              child: Text(t.save),
            ),
          ],
        ),
      ),
    );
  }
}
