import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/autosync/autosync.dart';
import 'package:listopher/bgsync/bgsync.dart';
import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'error_text.dart';
import 'items_tab.dart';
import 'spaces_tab.dart';

/// main screen: two tabs, Items and Spaces. syncs by itself (autosync); the Sync button is the manual fallback.
class HomeScreen extends StatefulWidget {
  final AppDb db;
  final UserRow me;
  final http.Client client;
  const HomeScreen({super.key, required this.db, required this.me, required this.client});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AutoSync _auto;

  @override
  void initState() {
    super.initState();
    // open, resume, poll and local changes all sync from here on
    _auto = startAutoSync(widget.db, widget.client, onError: _onSyncError);
  }

  @override
  void dispose() {
    _auto.stop();
    super.dispose();
  }

  /// failed sync: show it and queue one background sync for when the network returns.
  /// ponytail: autosync reports an error only when its text changes, so the job is
  /// queued once per new error; the 15 min periodic job covers the rest.
  void _onSyncError(Object e) {
    _showError(e);
    queueSyncOnNetwork().catchError((_) {}); // fire and forget, never throws out
  }

  /// snackbar for a failed sync. dead token says "log in again".
  void _showError(Object e) {
    if (!mounted) return;
    final t = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorText(t, e, t.syncFailed))));
  }

  /// Sync button: same sync, but every failure shows (the user asked).
  Future<void> _sync() async {
    try {
      await _auto.now();
    } catch (e) {
      _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.appName),
          actions: [
            IconButton(icon: const Icon(Icons.sync), tooltip: t.sync, onPressed: _sync),
          ],
          bottom: TabBar(tabs: [Tab(text: t.itemsTab), Tab(text: t.spacesTab)]),
        ),
        body: TabBarView(
          children: [
            ItemsTab(db: widget.db, me: widget.me),
            SpacesTab(db: widget.db, client: widget.client),
          ],
        ),
      ),
    );
  }
}
