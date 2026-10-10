# 7. Stack and module design (Flutter + Dart, Android first)

Date: 2026-10-10
Status: Accepted

## Context

- Android ships first and iOS follows. Native Kotlin would mean rewriting the whole UI for iOS later.
- P2P is gone ([ADR 1](0001-local-first-with-sync-server.md)). Flutter was only ruled out because it lacked Automerge/Iroh packages, so it's viable again ([research](../research/flutter-feasibility.md)).
- The app and the server exchange ops ([ADR 3](0003-operation-log-sync.md)). If they disagree on the op format, sync breaks without any error.
- The code must stay small and readable ([CLAUDE.md](../../CLAUDE.md)).

## Decision

### Stack

| Part | Choice | Why |
|------|--------|-----|
| Language | Dart everywhere | One language for the app, the server and the shared op format |
| Repo | `core/` (pure Dart), `server/`, `app/` (Flutter) | `core` is the only code used by both sides |
| Server | `shelf` + SQLite (`sqlite3` package, plain SQL) | Small binary, official `dart` Docker image (~10 MB final image), one database file. Easy to self-host. |
| Server build | `dart build cli` | `dart compile exe` fails with `sqlite3`'s build hooks |
| Server API | Plain HTTP + JSON | Push ops, then pull ops after a seq. No WebSockets ([ADR 4](0004-push-hosted-only.md)). |
| Auth | The server issues a random bearer token when an account is created. No passwords, no email. | Simplest option that works. Account recovery and multiple devices are deferred. |
| App DB | `drift` + `drift_flutter` | Stream queries for the UI, migrations, and `shareAcrossIsolates` so the widget and background code use the same DB |
| HTTP client | `http` | First-party |
| Background sync | `workmanager` | Android is reliable (15 min minimum). iOS is best-effort, so we don't rely on it. |
| Widget | `home_widget` + native layout (Glance on Android, SwiftUI on iOS) | The widget layout has to be native on both platforms |
| Notification | `flutter_local_notifications` | Ongoing notification + Sync action |
| QR (Android) | ~40 lines of Kotlin over a MethodChannel to the Google code scanner | No camera permission, and there's no maintained Flutter wrapper |
| QR (iOS, later) | `mobile_scanner` | iOS has no scanner that works without camera permission |
| Speech (later) | `speech_to_text` | Lets the user pick the language |
| i18n | gen-l10n (ARB files) + `intl` | [ADR 6](0006-multi-language.md) |
| DI | None; manual wiring in `main.dart` | A DI framework isn't worth it at this size |

### Sync button per platform

- **Android:** the widget button runs Dart sync in the background (`home_widget` interactivity callback). The notification action does the same (`flutter_local_notifications` background handler).
- **iOS:** the widget button **just opens the app**, and the app syncs when it opens. This needs no Swift AppIntent shim and no background Flutter engine. Add the shim only if users ask for it.

### Modules

Each module exposes a small interface. Everything else is internal (not exported).

```
core/
  ops        Op types + JSON shape. No IO.

server/
  accounts   createAccount() -> token, authenticate(token) -> user
  spaces     createSpace(), createInvite(), joinSpace(invite)
  oplog      appendOps(space, ops) -> seqs, opsAfter(space, seq)

app/
  store      record(op)            apply locally + queue in outbox
             watchSpaces(), watchItems()   streams for UI/widget/notification
  sync       sync(space)           push outbox, pull new ops, rebuild state
  join       join(qrPayload)       account if needed, join space, first sync
  additems   addItems(space, items, requestedBy)   only way items get created
  ui / widget / notification       read store, call record/sync. No logic.
```

- **`store` is the deepest module.** Drift tables, materialization ("op → item state") and the outbox are all hidden behind `record` and the watch streams.
- **Rebuilding state:** `sync` rebuilds a space by replaying all of its ops. That's cheap for shopping lists. Upgrade path: rebuild only from the first changed seq.
- **`ItemParser` is deferred.** There's no seam until a second adapter exists (the LLM parser). Until then, `addItems` is the seam.
- **No repository interfaces, no use-case classes, no state-management framework** until plain streams + `StreamBuilder` hurt. No fakes of our own code.

### Testing

Tests go through module interfaces only.

- **`core/ops`:** JSON round-trip tests.
- **`server`:** call the shelf handler directly with a temporary SQLite file. No real port needed.
- **`app/sync`:** run against the real shelf handler in-process. No mock server.
- **Pure functions** (apply one op, parse a quantity): plain `test`.

## Consequences

- iOS reuses all of the Dart code. Only the widget layout and the iOS setup are native.
- Native code exists in exactly three places: the widget layouts, the Android QR channel, and the platform setup files.
- iOS background sync is best-effort. Users get fresh data when they open the app, which is accepted.
- Token-only auth means a lost phone loses the account. Recovery is deferred.
- The new Dart build-hooks toolchain is a risk. If `dart build cli` breaks, pin the versions.
