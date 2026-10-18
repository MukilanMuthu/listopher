import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/bgsync/bgsync.dart';
import 'package:listopher/store/store.dart';
import 'package:listopher/ui/ui.dart';

// app entry: schedule background sync (Android), open db, show app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // workmanager is Android only here; skip on Windows and iOS
  if (Platform.isAndroid) await startBackgroundSync();
  final db = openAppDb();
  runApp(ListopherApp(db: db, client: http.Client()));
}
