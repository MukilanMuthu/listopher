import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';

import 'home_screen.dart';
import 'name_prompt_screen.dart';

/// root widget. shows name prompt until a "me" user exists, then the home screen.
class ListopherApp extends StatelessWidget {
  final AppDb db;
  const ListopherApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // texts come from lib/l10n/*.arb
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // db stream flips screen by itself: no navigation code
      home: StreamBuilder<UserRow?>(
        stream: watchMe(db),
        builder: (context, snap) {
          // first event not here yet: spinner
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final me = snap.data;
          if (me == null) return NamePromptScreen(db: db);
          return HomeScreen(db: db, me: me);
        },
      ),
    );
  }
}
