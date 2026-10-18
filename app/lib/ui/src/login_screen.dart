import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/net/net.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/sync/sync.dart';

import 'error_text.dart';

/// log in to a self-hosted server. ok = save account and close.
/// [initialUrl] fills the address (join links know their server).
class LoginScreen extends StatefulWidget {
  final AppDb db;
  final http.Client client;
  final String? initialUrl;
  const LoginScreen({super.key, required this.db, required this.client, this.initialUrl});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final _url = TextEditingController(text: widget.initialUrl);
  final _user = TextEditingController();
  final _password = TextEditingController();
  LoginFailure? _error; // last failure, shown under the fields
  bool _busy = false; // request in flight: button off

  @override
  void dispose() {
    _url.dispose();
    _user.dispose();
    _password.dispose();
    super.dispose();
  }

  /// ask server. ok = save + close. fail = show why.
  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context); // outlives this screen
    setState(() {
      _busy = true;
      _error = null;
    });
    final url = normalizeServerUrl(_url.text); // stored spelling, matches parsed invite links
    final result = await login(widget.client, url, _user.text.trim(), _password.text);
    switch (result) {
      case LoginOk():
        await saveServerAccount(
          widget.db,
          url: url,
          accountId: result.accountId,
          displayName: result.displayName,
          token: result.token,
        );
        // bring back shared spaces from an earlier install
        try {
          await restoreSpaces(widget.db, widget.client, url);
        } catch (e) {
          // logged in but restore failed: say so, log in again to retry
          messenger.showSnackBar(
              SnackBar(content: Text(errorText(t, e, t.couldNotRestore))));
        }
        if (mounted) Navigator.of(context).pop();
      case LoginFailed():
        if (mounted) {
          setState(() {
            _busy = false;
            _error = result.reason;
          });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // all three filled = button on
    final ready = _url.text.trim().isNotEmpty &&
        _user.text.trim().isNotEmpty &&
        _password.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(t.logInToServer)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _url,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: t.serverUrl),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _user,
              decoration: InputDecoration(labelText: t.username),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(labelText: t.password),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                switch (_error!) {
                  LoginFailure.wrongCredentials => t.wrongCredentials,
                  LoginFailure.locked => t.accountLocked,
                  LoginFailure.unreachable => t.serverUnreachable,
                },
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: ready && !_busy ? _submit : null,
              child: Text(t.logIn),
            ),
          ],
        ),
      ),
    );
  }
}
