# 05: Restore after reinstall

**What to build:** After logging in on a fresh install, the phone asks the server which spaces the account belongs to and pulls them all, so shared spaces come back. The private space is not restored (ADR 8, accepted).

**Blocked by:** 04 (Sync)

**Status:** ready-for-agent

- [ ] After login, member spaces are fetched and pulled
- [ ] Restored spaces show their items and names
- [ ] Test: wipe the phone store, log in again, shared spaces and items are back
