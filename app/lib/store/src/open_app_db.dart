import 'package:drift_flutter/drift_flutter.dart';

import 'app_db.dart';

/// open the real on-disk db.
/// shareAcrossIsolates: a background isolate write shows up in the open app.
AppDb openAppDb() => AppDb(driftDatabase(
      name: 'listopher',
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    ));
