# 4. Push notifications on the hosted server only

Date: 2026-10-10
Status: Accepted

## Context

APNs and FCM only accept pushes to our published app when they are signed with our private keys. Those keys can't ship in the open-source server. A push relay for self-hosters would work, but it is extra infrastructure we would have to run.

## Decision

- Only the hosted server sends pushes. The payload is "sync now" only and never contains list contents.
- Push is an optional module in the server. It is off by default.
- There is no push relay for self-hosters. Their clients sync:
  - when the app opens or comes to the foreground,
  - right after any local change to a shared space (add, check, edit, delete, create, join), debounced,
  - by polling every 30 s while the app is in the foreground,
  - in the background on Android via WorkManager (periodic, 15 min minimum),
  - when the user taps the **Sync** button on the ongoing notification or the widget.
- The Sync button calls one sync action:
  - Android: the widget and notification buttons run Dart sync in the background.
  - iOS: the widget button opens the app, and the app syncs when it opens ([ADR 7](0007-stack-and-module-design.md)).

## Consequences

- Self-hosted lists can be stale until someone opens the app or taps Sync. This is accepted.
- People who build their own copy of the app can enable the push module with their own keys.
