import 'package:drift_flutter/drift_flutter.dart';

import 'app_db.dart';

/// open the real on-disk db.
AppDb openAppDb() => AppDb(driftDatabase(name: 'listopher'));
