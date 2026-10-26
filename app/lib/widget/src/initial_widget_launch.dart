import 'dart:io';

import 'package:home_widget/home_widget.dart';

/// return a widget launch URI, when Android opened the app from a widget.
Future<Uri?> initialWidgetLaunch() => Platform.isAndroid
    ? HomeWidget.initiallyLaunchedFromHomeWidget()
    : Future.value(null);
