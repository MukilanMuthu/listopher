# 06: Join by invite link

**What to build:** The space owner can produce an invite link (listopher://join?server=…&space=…&invite=…). Another user pastes the link, logs in to that server with their own account if needed, joins the space, and pulls its ops. A new invite makes old links stop working.

**Blocked by:** 04 (Sync)

**Status:** ready-for-agent

- [ ] Owner can create or rotate the invite link from the space
- [ ] Joiner pastes the link; login prompt appears if not signed in to that server
- [ ] Join succeeds with a valid invite; wrong or rotated invite shows an error
- [ ] After joining, the space and its items appear
- [ ] Test against in-process server: owner + joiner, two phone stores
