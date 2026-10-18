# 02: Android periodic job

**What to build:** Add `workmanager`. On Android, the app registers a unique periodic task (every 15 min, network required, keep it if it's already registered) on start. The task's top-level `@pragma('vm:entry-point')` dispatcher opens the DB and an `http.Client` and calls `backgroundSync` (01). The DB is opened with `DriftNativeOptions(shareAcrossIsolates: true)` so a background write shows up in the open app. iOS registers nothing (ADR 9).

**Blocked by:** 01

**Status:** done

- [x] `workmanager` added; Android manifest/setup per its docs
- [x] `openAppDb` uses `shareAcrossIsolates: true`
- [x] Periodic unique task registered on Android start only, with a network constraint
- [x] Dispatcher opens the DB and client, runs `backgroundSync`, closes them, and returns success (the back-off is ours, not WorkManager's)
- [x] Manual check on the phone: add an item on phone B, keep app A closed, and A's list has it after the job runs (force a run with `adb shell cmd jobscheduler run -f <pkg> <id>`, or wait)

## Comments

Code done. Manual phone check still pending (box above left unticked). No manifest changes were needed beyond the plugin.

Forced run on the phone (app installed once so the job is registered):

```
adb shell dumpsys jobscheduler | grep listopher
adb shell cmd jobscheduler run -f com.gnomebyte.listopher <job id from above>
```

Manual check passed on the phone (2026-10-18): Windows app add pulled by the 15-min job while the phone was in airplane mode.
