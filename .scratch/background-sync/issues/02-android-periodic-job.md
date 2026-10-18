# 02: Android periodic job

**What to build:** Add `workmanager`. On Android, the app registers a unique periodic task (every 15 min, network required, keep it if it's already registered) on start. The task's top-level `@pragma('vm:entry-point')` dispatcher opens the DB and an `http.Client` and calls `backgroundSync` (01). The DB is opened with `DriftNativeOptions(shareAcrossIsolates: true)` so a background write shows up in the open app. iOS registers nothing (ADR 9).

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] `workmanager` added; Android manifest/setup per its docs
- [ ] `openAppDb` uses `shareAcrossIsolates: true`
- [ ] Periodic unique task registered on Android start only, with a network constraint
- [ ] Dispatcher opens the DB and client, runs `backgroundSync`, closes them, and returns success (the back-off is ours, not WorkManager's)
- [ ] Manual check on the phone: add an item on phone B, keep app A closed, and A's list has it after the job runs (force a run with `adb shell cmd jobscheduler run -f <pkg> <id>`, or wait)
