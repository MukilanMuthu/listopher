import 'dart:io' show Platform;

import 'package:workmanager/workmanager.dart';

/// task + unique name of the network-return one-off. the dispatcher branches on it.
const onNetworkTask = 'bgsync-on-network';

/// queue one background sync that runs once the phone is online.
/// foreground only: background code must never call this (no retry loop on a dead server).
/// Android only: iOS/Windows/tests do nothing (ADR 9).
Future<void> queueSyncOnNetwork() async {
  if (!Platform.isAndroid) return;
  await Workmanager().registerOneOffTask(
    onNetworkTask, // unique name
    onNetworkTask, // task name (dispatcher branches on it)
    constraints: Constraints(networkType: NetworkType.connected),
    // keep = one queued at most. WorkManager's keep ignores finished work,
    // so a later failure can queue it again.
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}
