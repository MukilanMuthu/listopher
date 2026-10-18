# 9. Background sync

Date: 2026-10-18
Status: Accepted

## Context

Foreground auto-sync is done ([ADR 4](0004-push-hosted-only.md)): it syncs on open, on resume, every 30 s, and right after a local change. When the app is closed, nothing syncs. Self-hosters have no push, so a background job is their only way to get fresh data without opening the app.

`workmanager` runs Dart on Android after the app is killed, at most every 15 min. On iOS it's best-effort and stops after a force-quit ([research](../research/flutter-feasibility.md)).

## Decision

- **Android only.** iOS gets no background job. It syncs when the app opens, and its widget Sync button just opens the app ([ADR 7](0007-stack-and-module-design.md)).
- **Periodic job:** a WorkManager periodic task, every 15 min, that runs only with a network connection. It calls the same `sync` the foreground uses.
- **Network-return job:** when a foreground sync fails, the app queues one unique one-off task with a network constraint (if one is already queued, it keeps that one). It runs once the phone is online, even if the app is closed. The background jobs never queue it themselves, so a server that is down can't cause a retry loop.
- **Back-off:** the periodic job skips its run until a wait has passed since the last background failure: 15 min after the first failure, then 30 min, then 1 h, and it stays at 1 h after that. Any good sync, foreground or background, resets the wait. WorkManager's own back-off can't be capped at 1 h, so the wait is kept in the DB and checked by the job.
- **No overlap lock.** A background sync can run at the same time as a foreground one. The server already ignores a resent op (ADR 3), so a double send is harmless.
- **Errors:** the background job is silent. It saves its last error in the DB, and the next app open shows it once and then clears it.
- **No notifications** for items that others add.
- **One DB across isolates.** The app opens drift with `shareAcrossIsolates: true`, so a background write shows up in the open app's lists.
- **Later step:** the Sync buttons on the notification and the widget. They will call the same `sync`.

## Consequences

- On Android, a self-hosted list is at most ~15 min stale while the phone is online and the server is up.
- On iOS, a list is stale until someone opens the app.
- The periodic job also wakes phones that have no shared spaces. It finds nothing to sync and exits.
  ponytail: register the job only when a shared space exists, if battery reports show it matters.
- An error that is shown on open may already be fixed by the sync that open runs. This is accepted.
