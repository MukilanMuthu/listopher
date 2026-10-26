import 'dart:async';
import 'dart:io';

import 'package:home_widget/home_widget.dart';

import 'package:listopher/store/store.dart';

import 'refresh_widget.dart';
import 'widget_background_action.dart';

/// register widget actions and refresh after local database edits.
Future<void> startWidget(AppDb db) async {
  if (!Platform.isAndroid) return;
  await HomeWidget.registerInteractivityCallback(widgetBackgroundAction);
  await refreshWidget(db).catchError((_) {});
  watchSpaces(db).listen((_) => refreshWidget(db).catchError((_) {}));
  watchItems(db).listen((_) => refreshWidget(db).catchError((_) {}));
}
