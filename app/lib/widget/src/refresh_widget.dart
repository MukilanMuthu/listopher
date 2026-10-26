import 'dart:convert';
import 'dart:io';

import 'package:home_widget/home_widget.dart';

import 'package:listopher/store/store.dart';

import 'widget_constants.dart';
import 'widget_snapshot.dart';

/// write a credential-free view of the current lists for Glance.
Future<void> refreshWidget(AppDb db, {bool? syncFailed}) async {
  if (!Platform.isAndroid) {
    return;
  }
  if (syncFailed != null) {
    await HomeWidget.saveWidgetData(widgetSyncFailedKey, syncFailed);
  }
  final spaces = await watchSpaces(db).first;
  final items = await watchItems(db).first;
  await HomeWidget.saveWidgetData(
    widgetSnapshotKey,
    jsonEncode(widgetSnapshot(spaces, items)),
  );
  await HomeWidget.updateWidget(qualifiedAndroidName: widgetReceiver);
}
