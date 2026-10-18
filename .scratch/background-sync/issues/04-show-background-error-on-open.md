# 04: Show the background error on open

**What to build:** On app open, if a background sync saved an error (01), show it once with the same error UI the foreground uses (`errorText`, so an expired session reads the same), then clear it.

**Blocked by:** 01

**Status:** done

- [x] On open, the saved error is shown once and then cleared
- [x] No saved error means nothing is shown
- [x] Test: save an error, open the app, see it; open again and it's gone

## Comments

- Deviation: the saved error is only `e.toString()`, so its type is lost and `errorText` cannot tell an expired session. The open shows one fixed message ("Background sync failed") instead. An expired session is still shown as "log in again" by the foreground sync that runs on open.
