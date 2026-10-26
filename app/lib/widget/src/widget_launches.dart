import 'dart:io';

import 'package:home_widget/home_widget.dart';

/// emit warm widget launches on Android, otherwise stay silent.
Stream<Uri?> widgetLaunches() =>
    Platform.isAndroid ? HomeWidget.widgetClicked : const Stream<Uri?>.empty();
