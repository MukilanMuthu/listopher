# 6. Multi-language support

Date: 2026-10-10
Status: Accepted

## Context

The app must support languages other than English, including right-to-left (RTL) scripts.

## Decision

- **UI strings:** use the native localization systems only: Android `strings.xml` (with plurals) and iOS String Catalogs. Don't hardcode user-facing text in code.
- **User data is stored as typed.** Item names, notes, units and list names are UTF-8 free text and are never translated. `unit` stays free text with no English enum ([ADR 5](0005-data-model.md)).
- **Numbers:** `quantity` is stored as a locale-neutral decimal. Parse and display it with the device locale, so `1,5` and `1.5` both work.
- **Dates:** store them as UTC ISO 8601 and format them with the device locale. `list.date` is a plain date with no timezone.
- **Layout:** support RTL from the start. Use start/end, not left/right.
- **Sorting:** compare with locale-aware collation (`Collator` on Android, `localizedStandardCompare` on iOS), not byte order.
- **Server:** stores and returns user text unchanged and holds no user-facing strings. Push payloads are silent "sync now" messages ([ADR 4](0004-push-hosted-only.md)), so they need no translation.
- **Dictation:**
  - Speech-to-text uses the device locale, or a language the user picks.
  - The LLM parser gets the language as input.
  - The local fallback parser splits on commas plus a per-locale list of words meaning "and". Languages without an entry get comma splitting only.

## Consequences

- Adding a language means adding string files plus an optional fallback-parser word list. No schema or server changes are needed.
- A group whose members use different languages sees item text exactly as it was typed. That's intended.
