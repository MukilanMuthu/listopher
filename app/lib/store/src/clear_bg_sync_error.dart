import 'package:drift/drift.dart' show Value;

import 'app_db.dart';

/// forget the saved background error (the user has seen it).
/// no row yet = nothing to do.
Future<void> clearBgSyncError(AppDb db) async {
  await (db.update(db.bgSyncState)..where((s) => s.id.equals(1)))
      .write(const BgSyncStateCompanion(lastError: Value(null)));
}
