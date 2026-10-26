# Widget test run — 2026-10-26

- `flutter test`: 132 passed, including 4 widget-module checks.
- `flutter analyze`: no issues.
- `git diff --check`: clean.
- `flutter build apk --debug`: passed after native API/resource fixes.
- APK installed successfully on AIN065, serial `71c9feac`; app launched with no startup crash in sampled logs.
- Local server running on port 8080 with a consistent backup of the existing test DB; `/me/spaces` responds HTTP 401 before login.
- USB reverse `tcp:8080 → tcp:8080` active.

## Phone feedback

User confirms widget works on AIN065. Individual cases below were not separately reported, so they remain an extended test checklist.

## Extended phone checklist

- Add widget and resize/scroll.
- Select one/multiple lists; verify separate widget instances keep separate filters.
- Check/uncheck offline, confirm crossed-out state and app data match.
- Open correct list from row text on cold/warm app starts; clear app filter.
- Sync shared lists; verify background refresh and failure/retry recovery.

App data was not cleared or uninstalled. UI layout/order remain provisional.
