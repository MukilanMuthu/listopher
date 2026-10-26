import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/bgsync/bgsync.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/ui/ui.dart';
import 'package:listopher/widget/widget.dart';

// app entry: open db, show app, then schedule background sync (Android).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = openAppDb();
  final initialUri = await initialWidgetLaunch();
  await startWidget(db);
  runApp(
    ListopherApp(
      db: db,
      client: http.Client(),
      initialSpaceId: widgetSpaceFromUri(initialUri),
    ),
  );
  // optional, not awaited: a failure only means no background sync this launch.
  // workmanager is Android only here; skip on Windows and iOS
  if (Platform.isAndroid) startBackgroundSync().catchError((_) {});
}
