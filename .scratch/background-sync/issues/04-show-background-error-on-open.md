# 04: Show the background error on open

**What to build:** On app open, if a background sync saved an error (01), show it once with the same error UI the foreground uses (`errorText`, so an expired session reads the same), then clear it.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] On open, the saved error is shown once and then cleared
- [ ] No saved error means nothing is shown
- [ ] Test: save an error, open the app, see it; open again and it's gone
