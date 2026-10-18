import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/sync/sync.dart';

import 'error_text.dart';
import 'items_tab.dart';
import 'spaces_tab.dart';

/// main screen: two tabs, Items and Spaces. syncs on open and on the Sync button.
class HomeScreen extends StatefulWidget {
  final AppDb db;
  final UserRow me;
  final http.Client client;
  const HomeScreen({super.key, required this.db, required this.me, required this.client});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _sync(); // on app open
  }

  /// sync all shared spaces. a failure shows in a snackbar, never silent.
  Future<void> _sync() async {
    try {
      await sync(widget.db, widget.client);
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorText(t, e, t.syncFailed))));
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
