import 'dart:io' show Platform;

import 'package:workmanager/workmanager.dart';

/// queue one background sync that runs once the phone is online.
/// foreground only: background code must never call this (no retry loop on a dead server).
/// Android only: iOS/Windows/tests do nothing (ADR 9).
Future<void> queueSyncOnNetwork() async {
  if (!Platform.isAndroid) return;
  await Workmanager().registerOneOffTask(
    'bgsync-on-network', // unique name
    'bgsync-on-network', // task name (dispatcher ignores it)
    constraints: Constraints(networkType: NetworkType.connected),
    // keep = one queued at most. WorkManager's keep ignores finished work,
    // so a later failure can queue it again.
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}
