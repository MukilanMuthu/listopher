import 'app_db.dart';

/// back-off state of the background sync. no row yet = no failures.
Future<({int failures, DateTime? lastFailAt, String? lastError})> readBgSyncState(
    AppDb db) async {
  final row = await db.select(db.bgSyncState).getSingleOrNull();
  return (
    failures: row?.failures ?? 0,
    lastFailAt: row?.lastFailAt,
    lastError: row?.lastError,
  );
}
