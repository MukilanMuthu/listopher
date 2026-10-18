# 01: Me per server (prefactor)

**What to build:** The phone can hold one server account per server (server url, account id, display name, session token). When a change is recorded in a shared space, the op carries the account id of that space's server; in the private space it keeps the local user id. Both ids resolve to "me". No UI yet. This prepares every later ticket (see ADR 8, 'Multiple servers per phone').

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Store keeps zero or more server accounts, one per server url
- [ ] Ops recorded in a space with a server url carry that server's account id as user id
- [ ] Ops recorded in the private space carry the local user id
- [ ] A lookup answers "is this user id me?" for both the local id and any account id
- [ ] Store tests cover all of the above; existing tests still pass
