# 3. Sync as an append-only operation log, last-writer-wins

Date: 2026-10-10
Status: Accepted

## Context

We need offline edits, merging, and "git blame" history (who requested, checked and bought each item). With a server to put changes in order, a CRDT (Automerge and similar) is more than this needs.

## Decision

- Every change is an **op** (operation) appended to a log. The schema is in [ADR 5](0005-data-model.md).
- **On the client:** new ops are applied to local state immediately and queued in an outbox.
- **On sync:**
  1. The client sends its outbox ops.
  2. The server authenticates the user and assigns each op a `server_seq` (a per-space sequence number).
  3. The client fetches all ops after the last `server_seq` it has seen.
  4. The client rebuilds local state: confirmed ops in `server_seq` order, then any ops still pending.
- **Conflicts:** last-writer-wins per op, by `server_seq`. Update ops carry the full editable state, so a null means "cleared", not "unchanged". Example: an offline "uncheck" that reaches the server after a "check" wins.
- Ops are never deleted. The op log *is* the blame history.

## Consequences

- The server is simple: authenticate, order, store, fan out.
- Attribution is trustworthy for shared lists, because the server ties ops to an authenticated user.
- Two people editing the same item name at once lose one edit. That's acceptable for a shopping list. Add a CRDT only if live collaborative text editing is ever needed.
- The op log grows forever. Compact it per space (snapshot plus ops after the snapshot) if size ever becomes a problem.
