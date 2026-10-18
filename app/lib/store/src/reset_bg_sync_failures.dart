import 'package:drift/drift.dart' show Value;

import 'app_db.dart';

/// good sync: clear count and time so back-off ends.
/// lastError stays: the user still has to see it once.
Future<void> resetBgSyncFailures(AppDb db) async {
  await (db.update(db.bgSyncState)..where((s) => s.id.equals(1))).write(
      const BgSyncStateCompanion(failures: Value(0), lastFailAt: Value(null)));
}
