# 01: Background sync run with back-off

**What to build:** A new `bgsync` module (`app/lib/bgsync/`) with one function that a background job calls: `backgroundSync(db, client, now)`. It runs `sync` unless the back-off wait has not passed yet (ADR 9). The wait after the last background failure is 15 min after the 1st failure, 30 min after the 2nd, and 1 h after the 3rd and every later one. A failure saves its error text in the DB. A good sync (from here or from the foreground) resets the failure count. The state lives in a new single-row drift table (failure count, last failure time, last error text). Dev DB policy: `schemaVersion` stays 1, uninstall the app.

**Blocked by:** none

**Status:** ready-for-agent

- [ ] New drift table for back-off state; store exports read/write functions for it
- [ ] `backgroundSync` skips (no network calls) while inside the wait
- [ ] Waits are 15 min, 30 min, 1 h, then 1 h forever
- [ ] Failure saves the error text and bumps the count; it never throws out of `backgroundSync`
- [ ] Any good sync resets the count (foreground `startAutoSync` too)
- [ ] Test through the module interface with a fake clock (`now` passed in) and a server handler: fail, fail, fail, fail → the skip windows are 15/30/60/60 min; then a good sync resets them
