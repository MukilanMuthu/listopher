# 03: Sync when the network returns

**What to build:** When a foreground automatic sync fails, the app queues a unique one-off WorkManager task with a network constraint (if one is already queued, it keeps that one). It runs `backgroundSync` once the phone is online, even if the app is closed. Only the foreground queues it, never the background jobs, so a server that is down can't loop (ADR 9). Android only.

**Blocked by:** 02

**Status:** ready-for-agent

- [x] Foreground auto-sync failure queues the unique one-off task (keep if it's already queued)
- [x] The background dispatcher handles the one-off task name the same as the periodic one
- [x] Background runs never queue it
- [ ] Manual check: airplane mode on, add an item, close the app, airplane mode off, and the item reaches the server without opening the app

## Comments

Code done (`queueSyncOnNetwork`, wired into home screen `onError`). Phone check pending: airplane mode on, add an item to a shared space, close the app, airplane mode off, check the item reached the other phone/server without opening the app. `adb shell dumpsys jobscheduler | grep listopher` shows the queued job.
