# 09: Delete space

**What to build:** The owner can delete a shared space. Other members' phones notice on their next sync (the server answers 404) and remove the space and its items locally.

**Blocked by:** 04 (Sync)

**Status:** done

- [x] Owner sees a delete action with a confirmation; non-owners don't
- [x] Deleted on the server, removed locally on the owner's phone
- [x] Other members' phones remove it on next sync
- [x] Test with two phone stores against the in-process server
