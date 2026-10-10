import 'package:flutter/material.dart';

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'items_tab.dart';
import 'spaces_tab.dart';

/// main screen: two tabs, Items and Spaces.
class HomeScreen extends StatelessWidget {
  final AppDb db;
  final UserRow me;
  const HomeScreen({super.key, required this.db, required this.me});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.appName),
          bottom: TabBar(tabs: [Tab(text: t.itemsTab), Tab(text: t.spacesTab)]),
        ),
        body: TabBarView(children: [ItemsTab(db: db, me: me), SpacesTab(db: db)]),
      ),
    );
  }
}
