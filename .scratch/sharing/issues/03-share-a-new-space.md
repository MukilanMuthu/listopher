# 03: Share a new space

**What to build:** Creating a shared space from the Spaces tab registers it on a chosen server. If the user isn't logged in to any server, they log in first. The space is created on the phone and on the server, and its first ops (space.create) are uploaded so the server holds them.

**Blocked by:** 02 (Log in to a server)

**Status:** ready-for-agent

- [ ] Spaces tab + asks which server (login if none) and a name
- [ ] Space exists locally with its server url set and on the server with the user as owner
- [ ] The space.create op is uploaded and gets a server seq
- [ ] Private space can never be shared
- [ ] Tested end-to-end against the in-process server
