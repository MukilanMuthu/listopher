# Android home-screen widget

Status: ready-for-agent

## What to build

Deliver ADR 10 end to end: view, filter, check, and sync shopping lists from a scrollable Android home-screen widget. Notification work is dropped. UI polish stays deferred.

## Acceptance criteria

- [ ] Resizable widget scrolls compact rows grouped by list; checked items remain crossed out in place.
- [ ] Each widget saves its own All/one/multiple-list selection through an overlaid picker.
- [ ] All includes future lists; explicit selections remain fixed.
- [ ] Checkboxes update local data offline; row text opens the correct list on cold and warm app starts.
- [ ] Sync runs for every list without opening the app, bypasses periodic-job backoff, and exposes retry on failure without losing content.
- [ ] Widget refreshes after local edits and foreground/background sync.
- [ ] Existing app data survives installation; focused checks pass and APK is tested on AIN065.

## Blocked by

None — design accepted in ADR 10.
