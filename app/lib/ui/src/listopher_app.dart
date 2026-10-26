import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/l10n/app_localizations.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/widget/widget.dart';

import 'home_screen.dart';
import 'name_prompt_screen.dart';

/// root widget. shows name prompt until a "me" user exists, then the home screen.
class ListopherApp extends StatefulWidget {
  final AppDb db;
  final http.Client
  client; // for server calls. tests pass one wired to the real handler
  final String? initialSpaceId;
  const ListopherApp({
    super.key,
    required this.db,
    required this.client,
    this.initialSpaceId,
  });

  @override
  State<ListopherApp> createState() => _ListopherAppState();
}

class _ListopherAppState extends State<ListopherApp> {
  StreamSubscription<Uri?>? _widgetClicks;
  StreamSubscription<List<SpaceRow>>? _spaces;
  String? _spaceId;
  int _widgetLinkRevision = 0;

  @override
  void initState() {
    super.initState();
    _spaceId = widget.initialSpaceId;
    if (Platform.isAndroid) {
      _widgetClicks = widgetLaunches().listen((uri) {
        final id = widgetSpaceFromUri(uri);
        if (id != null) {
          setState(() {
            _spaceId = id;
            _widgetLinkRevision++;
          });
        }
      }, onError: (_) {});
      _spaces = watchSpaces(widget.db).listen((spaces) {
        if (_spaceId != null && !spaces.any((space) => space.id == _spaceId)) {
          setState(() => _spaceId = null);
        }
      }, onError: (_) {});
    }
  }

  @override
  void dispose() {
    _widgetClicks?.cancel();
    _spaces?.cancel();
    super.dispose();
  }

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
        stream: watchMe(widget.db),
        builder: (context, snap) {
          // first event not here yet: spinner
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final me = snap.data;
          if (me == null) return NamePromptScreen(db: widget.db);
          return HomeScreen(
            db: widget.db,
            me: me,
            client: widget.client,
            selectedSpaceId: _spaceId,
            widgetLinkRevision: _widgetLinkRevision,
            onClearSelectedSpace: () => setState(() => _spaceId = null),
          );
        },
      ),
    );
  }
}
