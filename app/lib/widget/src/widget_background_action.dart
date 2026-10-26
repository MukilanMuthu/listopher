import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:listopher/store/store.dart';

import 'refresh_widget.dart';
import 'perform_widget_action.dart';

/// apply a widget action in a background Flutter isolate.
@pragma('vm:entry-point')
Future<void> widgetBackgroundAction(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  final action = uri;
  if (!Platform.isAndroid || action == null || action.scheme != 'listopher') {
    return;
  }
  final db = openAppDb();
  final client = http.Client();
  try {
    final failed = await performWidgetAction(db, client, action);
    if (failed != null) await refreshWidget(db, syncFailed: failed);
  } finally {
    client.close();
    try {
      if (action.host != 'sync') await refreshWidget(db);
    } finally {
      await db.close();
    }
  }
}
