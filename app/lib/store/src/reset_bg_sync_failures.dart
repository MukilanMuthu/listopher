import 'package:drift/drift.dart' show Value, BooleanExpressionOperators, ComparableExpr;

import 'app_db.dart';

/// good sync: clear count and time so back-off ends.
/// writes only when there is something to reset (most syncs are clean).
/// lastError stays: the user still has to see it once.
Future<void> resetBgSyncFailures(AppDb db) async {
  await (db.update(db.bgSyncState)..where((s) =>
          s.id.equals(1) &
          (s.failures.isBiggerThanValue(0) | s.lastFailAt.isNotNull()))).write(
      const BgSyncStateCompanion(failures: Value(0), lastFailAt: Value(null)));
}
