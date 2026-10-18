# 02: Log in to a server

**What to build:** From the Spaces tab, the user can log in to a self-hosted server with server url, username and password. A successful login saves the server account on the phone. Wrong credentials and a locked account show clear, localized errors. The Spaces tab shows which servers you are signed in to. Plain http is allowed (ADR 8 Transport).

**Blocked by:** 01 (Me per server (prefactor))

**Status:** ready-for-agent

- [ ] Login screen: server url, username, password
- [ ] Success saves the server account and shows 'signed in to <server>'
- [ ] 401 shows a 'wrong username or password' message; 429 shows a 'locked, try later' message; unreachable server shows a network error
- [ ] All strings come from the localization file
- [ ] Tested against the real server handler in-process (no mocks)
