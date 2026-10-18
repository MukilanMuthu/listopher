# 08: Names and buyer picker

**What to build:** Items show who asked and who bought, using member names from the server for shared spaces and the local name for the private space (ADR 8, Names). When checking an item in a shared space, the user can pick which member bought it (default: me).

**Blocked by:** 06 (Join by invite link)

**Status:** ready-for-agent

- [ ] Item rows show requester and fulfiller names
- [ ] Member names come from the server's member list and are refreshed on sync
- [ ] Ops by deleted accounts show a localized 'deleted user'
- [ ] Checking an item in a shared space lets the user pick the buyer; default is me
