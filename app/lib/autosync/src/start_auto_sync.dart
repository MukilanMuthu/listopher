import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:listopher/store/store.dart';
import 'package:listopher/sync/sync.dart';

import 'one_at_a_time.dart';

/// handle for a running auto sync.
/// [now] = the manual Sync button: shares the no-overlap guard, throws on failure.
/// [stop] = cancel every trigger. call once, from dispose.
typedef AutoSync = ({Future<void> Function() now, void Function() stop});

/// keep shared spaces in sync without the screens asking. triggers:
/// app open, app resume, every [poll] in the foreground, and [debounce] after a
/// local change waits in a shared outbox. one sync at a time (see [oneAtATime]).
/// a failed automatic sync calls [onError] only when the error differs from the
/// last one, so a dead server is reported once, not every poll.
/// ponytail: error identity = its text; a changed message counts as new.
AutoSync startAutoSync(
  AppDb db,
  http.Client client, {
  required void Function(Object error) onError,
  Duration poll = const Duration(seconds: 30),
  Duration debounce = const Duration(seconds: 1),
}) {
  var stopped = false;
  String? lastError; // text of the error already shown, null = last run was fine
  // any good sync (manual too) forgets the shown error, so it can show again later
  final now = oneAtATime(() async {
    await sync(db, client);
    lastError = null;
  });

  // automatic trigger: sync, report a new error once
  void auto() {
    if (stopped) return;
    now().catchError((Object e) {
      if (stopped || e.toString() == lastError) return;
      lastError = e.toString();
      onError(e);
    });
  }

  Timer? pollTimer;
  // foreground only: start polling, drop any old timer first
  void startPolling() {
    pollTimer?.cancel();
    pollTimer = Timer.periodic(poll, (_) => auto());
  }

  // local change: wait for quiet, then sync. restarts on every new change
  Timer? debounceTimer;
  final unsent = watchUnsentCount(db).listen((count) {
    debounceTimer?.cancel();
    if (count > 0) debounceTimer = Timer(debounce, auto); // 0 = outbox empty, nothing to send
  });

  // resume = sync now and poll; anything else = quiet
  final lifecycle = AppLifecycleListener(onStateChange: (state) {
    if (state == AppLifecycleState.resumed) {
      auto();
      startPolling();
    } else {
      pollTimer?.cancel();
    }
  });

  auto(); // app open
  startPolling();

  return (
    now: now,
    stop: () {
      stopped = true;
      pollTimer?.cancel();
      debounceTimer?.cancel();
      unsent.cancel();
      lifecycle.dispose();
    },
  );
}
