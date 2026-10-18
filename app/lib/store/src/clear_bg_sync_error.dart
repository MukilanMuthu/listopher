import 'package:drift/drift.dart' show Value, BooleanExpressionOperators;

import 'app_db.dart';

/// forget the saved background error, but only the one the user [shown].
/// a newer error saved meanwhile stays. no row yet = nothing to do.
Future<void> clearBgSyncError(AppDb db, String shown) async {
  await (db.update(db.bgSyncState)
        ..where((s) => s.id.equals(1) & s.lastError.equals(shown)))
      .write(const BgSyncStateCompanion(lastError: Value(null)));
}
