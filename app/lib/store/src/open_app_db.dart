import 'package:drift_flutter/drift_flutter.dart';

import 'app_db.dart';

/// open the real on-disk db.
/// each isolate (app, background job) opens its own sqlite connection to the same file.
/// busy_timeout: a second writer waits up to 5 s instead of failing at once.
AppDb openAppDb() => AppDb(driftDatabase(
      name: 'listopher',
      native: DriftNativeOptions(
        setup: (db) => db.execute('PRAGMA busy_timeout = 5000'),
      ),
    ));
