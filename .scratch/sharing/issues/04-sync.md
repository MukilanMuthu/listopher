# 04: Sync

**What to build:** Shared spaces sync with their server: the outbox is sent, new ops are pulled, and items are rebuilt from the op log in server-seq order with still-pending ops on top (ADR 3). Sync runs when the app opens and when the user taps a Sync button. The same account on two devices sees the same items after syncing.

**Blocked by:** 03 (Share a new space)

**Status:** done

- [x] Outbox ops are sent per space; confirmed ops get their server seq locally
- [x] New ops after the last known seq are pulled (looping past the 500-op page)
- [x] Space and item state rebuilt: confirmed ops by seq, then pending ops
- [x] Sync on app open and on a Sync button; failures are shown, not swallowed
- [x] Resending after a lost response creates no duplicates
- [x] Test: two phone stores, same account, one server handler — an item added on one appears on the other after sync
