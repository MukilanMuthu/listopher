import 'package:drift/drift.dart' show InsertMode;

import 'app_db.dart';
import 'read_bg_sync_state.dart';

/// note one failed background sync: count + 1, time and error saved.
Future<void> saveBgSyncFailure(AppDb db, DateTime now, String error) async {
  await db.transaction(() async {
    final old = await readBgSyncState(db);
    // single row 1: insert or replace
    await db.into(db.bgSyncState).insert(
          BgSyncStateRow(
              id: 1, failures: old.failures + 1, lastFailAt: now, lastError: error),
          mode: InsertMode.insertOrReplace,
        );
  });
}
