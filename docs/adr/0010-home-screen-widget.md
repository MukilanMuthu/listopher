# 10. Android home-screen widget

Date: 2026-10-26
Status: Accepted

## Context

People need to view and update shopping lists without opening the app. The widget must work with local-first data and the existing background sync. The ongoing notification is dropped entirely; this supersedes its plans in [ADR 4](0004-push-hosted-only.md) and [ADR 7](0007-stack-and-module-design.md).

## Decision

- Build the Android home-screen widget next, using `home_widget` and Glance as chosen in [ADR 7](0007-stack-and-module-design.md).
- Make it a resizable, scrollable, calendar/agenda-style list that can fill the available home-screen page.
- Each widget instance has an independent filter: All lists, or one or more selected lists. A small picker opens over the home screen with All and a list checklist, then Apply. All includes lists created or joined later. An explicit subset does not include new lists until selected.
- Show list names as group headings. Each compact row has a checkbox, item name, and quantity plus unit. Omit asked-by and bought-by fields. Keep list/item positions for now; layout and exact ordering remain provisional. No Add button.
- Checking an item updates it locally without opening the app. Checked items stay visible with crossed-out text. Tapping the row text opens that item's list in the app.
- Sync runs for all lists, regardless of widget filter, in the background without opening the app. Reuse the existing sync action. Refresh the widget after local edits and successful foreground or background sync. Queue offline edits for sync.
- On sync failure, retain existing widget content and show `Sync failed · tap to retry` inline. Tapping retries sync.
- Defer UI polish.

## Consequences

- Users can check items and view lists from the home screen, including while offline; queued changes sync later.
- Widget filters affect display only. Sync continues to cover every list.
- The notification UI and its Sync action are removed; the widget is the home-screen sync control.
- Widget refresh must follow both local changes and sync writes from other isolates.
- Details such as default filter selection and behavior when a selected list is deleted remain implementation decisions.
