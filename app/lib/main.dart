import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/bgsync/bgsync.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/ui/ui.dart';

// app entry: open db, show app, then schedule background sync (Android).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = openAppDb();
  runApp(ListopherApp(db: db, client: http.Client()));
  // optional, not awaited: a failure only means no background sync this launch.
  // workmanager is Android only here; skip on Windows and iOS
  if (Platform.isAndroid) startBackgroundSync().catchError((_) {});
}
