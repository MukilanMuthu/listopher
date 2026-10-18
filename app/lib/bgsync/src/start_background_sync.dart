import 'package:workmanager/workmanager.dart';

import 'bg_sync_dispatcher.dart';

/// register the 15 min periodic sync job. call once at app start.
/// Android only: iOS gets no background job (ADR 9), so callers guard it.
/// ponytail: keep policy means a changed frequency later needs a new unique name.
Future<void> startBackgroundSync() async {
  await Workmanager().initialize(bgSyncDispatcher);
  await Workmanager().registerPeriodicTask(
    'bgsync-periodic', // unique name
    'bgsync-periodic', // task name (dispatcher ignores it)
    frequency: const Duration(minutes: 15), // WorkManager minimum
    constraints: Constraints(networkType: NetworkType.connected),
    // keep: a restart must not reset the schedule
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}
