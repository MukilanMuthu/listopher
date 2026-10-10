# Flutter + Dart server feasibility for listopher

Date: 2026-10-10. Context: the [ADR 7](../adr/0007-stack-and-module-design.md) proposal (Kotlin everywhere) compared with Flutter app + Dart (`shelf`) server + SQLite on both sides. Android ships first, iOS later.

Sources: pub.dev package API (`https://pub.dev/api/packages/<name>`), package GitHub repos (README, docs, source, CHANGELOG), dart.dev, docs.flutter.dev, developer.android.com, developer.apple.com, developers.google.com. Versions and publish dates are taken from the pub.dev API on 2026-10-10. Items marked **UNVERIFIED** were not confirmed in a primary source.

## Package snapshot

| Package | Latest | Published | Publisher | Repo |
|---|---|---|---|---|
| home_widget | 0.10.0 | 2026-09-17 | antonborri.es | https://github.com/ABausG/home_widget |
| flutter_local_notifications | 22.3.1 | 2026-09-13 | dexterx.dev | https://github.com/MaikuB/flutter_local_notifications |
| workmanager | 0.10.10 | 2026-09-07 | fluttercommunity.dev | https://github.com/fluttercommunity/flutter_workmanager |
| mobile_scanner | 7.4.2 | 2026-09-14 | steenbakker.dev | https://github.com/juliansteenbakker/mobile_scanner |
| native_qr | 0.0.3 | 2023-05-15 | (none) | https://github.com/roman-yerin/native_qr |
| drift | 2.35.2 | 2026-10-07 | simonbinder.eu | https://github.com/simolus3/drift |
| drift_flutter | 0.3.1 | 2026-07-11 | simonbinder.eu | same |
| sqflite | 2.4.4+1 | 2026-10-05 | tekartik.com | https://github.com/tekartik/sqflite |
| sqlite3 | 3.7.0 | 2026-09-30 | simonbinder.eu | https://github.com/simolus3/sqlite3.dart |
| sqlite3_flutter_libs | 0.6.0+eol | 2026-02-15 | simonbinder.eu | (end of life, see Q5) |
| shelf | 1.4.2 | 2024-06-21 | tools.dart.dev | https://github.com/dart-lang/shelf |
| shelf_router | 1.1.4 | 2023-05-03 | tools.dart.dev | same |
| speech_to_text | 7.5.0 (7.6.0-beta in repo) | 2026-09-14 | csdcorp.com | https://github.com/csdcorp/speech_to_text |
| intl | 0.20.3 | 2026-06-25 | dart.dev | https://github.com/dart-lang/i18n |

## 1. Home-screen widget with a Sync button that runs Dart

### Android: yes, Dart runs in the background

- `home_widget` lists "Interactive widgets that call Dart Code" as a feature. https://github.com/ABausG/home_widget/blob/main/packages/home_widget/README.md
- Mechanism: you write a top-level `@pragma("vm:entry-point")` function `FutureOr<void> backgroundCallback(Uri? data)` and register it with `HomeWidget.registerInteractivityCallback(backgroundCallback)`. https://github.com/ABausG/home_widget/blob/main/docs/features/interactive-widgets.mdx
- `registerBackgroundCallback` was renamed to `registerInteractivityCallback` in 0.4.0. https://github.com/ABausG/home_widget/blob/main/packages/home_widget/CHANGELOG.md
- Since 0.8.1 the Android side runs interactivity "using WorkManager", which "improves reliability of clicks". The old `HomeWidgetBackgroundService` manifest entry is no longer needed. Sources: the CHANGELOG and the interactive-widgets doc above.
- **UI toolkit:** Jetpack Glance and XML RemoteViews both work.
  - The Android setup guide is written for Glance. You use `HomeWidgetGlanceStateDefinition` and `HomeWidgetGlanceWidgetReceiver`. https://github.com/ABausG/home_widget/blob/main/docs/setup/android.mdx
  - Glance support arrived in 0.5.0 (CHANGELOG).
  - XML widgets have a separate section. A click there uses `HomeWidgetBackgroundIntent.getBroadcast(...)` plus `setOnClickPendingIntent`. https://github.com/ABausG/home_widget/blob/main/docs/android-xml/interactive-widgets.mdx
  - With Glance, a click goes through an `ActionCallback` that calls `HomeWidgetBackgroundIntent.getBroadcast(context, uri).send()`, attached with `GlanceModifier.clickable(onClick = actionRunCallback<...>())`. Source: the interactive-widgets doc.
- The widget layout is native in both cases: Kotlin for Glance, XML for RemoteViews. A newer `home_widget_generator` with `home_widget_cli` can generate the Glance (Android) and SwiftUI (iOS) code from an annotated Dart schema. https://github.com/ABausG/home_widget/blob/main/docs/generator/index.mdx (Maturity: **UNVERIFIED**. The docs exist, but I did not check its pub.dev version.)

### iOS 17+: yes, but there are process caveats

- Interactive widgets on iOS were added in home_widget 0.4.0 (CHANGELOG). Per the docs, "Android and iOS (starting with iOS 17)" support them.
- Setup (from the interactive-widgets doc):
  - You write a **native Swift `AppIntent`** and add it to both the Runner and WidgetExtension targets. Its `perform()` calls `await HomeWidgetBackgroundWorker.run(url:appGroup:)`, which in turn calls the same Dart `backgroundCallback`.
  - AppDelegate must call `HomeWidgetBackgroundWorker.setPluginRegistrantCallback { GeneratedPluginRegistrant.register(with:) }` so plugins work in the background engine.
  - An App Group is required to share data. https://github.com/ABausG/home_widget/blob/main/docs/setup/ios.mdx
- Caveat from the docs: with that setup the widget is interactive only "as long as the App is still in the background".
  - To wake a terminated app you also make the intent conform to `ForegroundContinuableIntent`.
  - That "will start your Flutter App using the normal main entrypoint", so the full app may run in the background. You have to guard `runApp` against this.
- Apple's rules: by default an AppIntent's `perform()` runs in the widget extension's process. If the intent conforms to `ForegroundContinuableIntent` (or `openAppWhenRun` is true, among other cases), it runs in the app's process. When `perform()` returns, the system reloads the timeline. https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities
- **Conclusion for iOS:** Dart code can run, but only through a small native Swift AppIntent shim. Doing the HTTP sync natively in Swift inside `perform()` avoids starting a Flutter engine. However, it means duplicating the op-log sync client in Swift, which brings back the risk ADR 7 tries to remove. Start with the Dart path; fall back to native Swift if it proves unreliable.
- **UNVERIFIED:**
  - Widget extensions have tight memory limits, so a Flutter engine inside the extension is unlikely to work. That is presumably why the docs push `ForegroundContinuableIntent`.
  - Whether `ForegroundContinuableIntent` brings the app UI to the foreground on every tap. Test this on a device.

## 2. Ongoing notification with a Sync action

- **Ongoing flag:** `AndroidNotificationDetails` has `ongoing` (default `false`), `autoCancel` (default `true`) and a new `requestPromotedOngoing` (Android 16 "Live Update" promotion). It also has `dismissIsolate`: `NotificationDismissedIsolate.background` reports a dismissal "even when the app has been terminated". You can use that to re-post the notification. https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/lib/src/platform_specifics/android/notification_details.dart
- **Action buttons + background Dart:**
  - On iOS and Android, if an action does not set `showsUserInterface` (Android) or `DarwinNotificationActionOption.foreground` (iOS), the plugin "will start a separate Flutter Engine" and invoke `onDidReceiveBackgroundNotificationResponse` (a top-level `@pragma('vm:entry-point')` function) in a separate isolate. This works when the app is sleeping or terminated.
  - Android needs no extra configuration.
  - iOS needs `FlutterLocalNotificationsPlugin.setPluginRegistrantCallback` in AppDelegate, or in `didInitializeImplicitFlutterEngine` for UIScene apps.
  - iOS action categories must be configured in `initialize` before the app starts.
  - Source: https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/README.md (sections "Notification Actions" and "Linux limitations")
- **Android 14:** foreground notifications using `FLAG_ONGOING_EVENT` / `setOngoing(true)` are "actually dismissable by the user". They stay non-dismissible in a few cases, for example when the phone is locked. https://developer.android.com/about/versions/14/behavior-changes-all#non-dismissable-notifications
  - Design for "user can swipe it away" and re-post it via `dismissIsolate`, or on app open.
- **iOS:** there is no ongoing or persistent notification. The `ongoing` field exists only on the Android details class (from the source above). The iOS substitute would be a Live Activity, which needs native code. **UNVERIFIED** as a product fit.

## 3. Background sync: `workmanager`

- Status: 0.10.10, published 2026-09-07, maintained under the Flutter Community org. It is now federated (`workmanager_android`, `workmanager_apple`, …) and requires Flutter >=3.38.0 (pub.dev API).
- Android: "Reliable, 15-minute minimum frequency". One-off and periodic tasks survive restarts and run after the app is killed. It also supports expedited one-off work and foreground-service mode for long tasks. On Android 15 the `dataSync` foreground-service limits apply. https://github.com/fluttercommunity/flutter_workmanager/blob/main/docs/index.mdx and https://github.com/fluttercommunity/flutter_workmanager/blob/main/docs/quickstart.mdx
- iOS:
  - `registerPeriodicTask` maps to `BGAppRefreshTaskRequest`. It is "best-effort; no guaranteed interval", with a budget of about 30 s.
  - `registerProcessingTask` maps to `BGProcessingTaskRequest`, which runs when the device is idle.
  - One-off tasks run via `beginBackgroundTask` only while the app is alive.
  - "Task execution after app is killed: No — iOS does not run tasks after the app is terminated."
  - The frequency is set in `AppDelegate.swift`, not from Dart. Identifiers must match `BGTaskSchedulerPermittedIdentifiers` in Info.plist.
  - Sources: the same docs, plus https://github.com/fluttercommunity/flutter_workmanager/blob/main/docs/customization.mdx
- home_widget's own background-update docs recommend workmanager. https://github.com/ABausG/home_widget/blob/main/docs/features/background-updates.mdx

## 4. QR scanning

- **Google code scanner (no camera permission):** this is an ML Kit API delivered by Google Play services. It scans "without requiring camera permission" and returns only the result. https://developers.google.com/ml-kit/vision/barcode-scanning/code-scanner
- **Flutter wrapper: none that is maintained.**
  - `native_qr` 0.0.3 (2023-05-15) wraps `GmsBarcodeScanner` on Android and `DataScannerViewController` on iOS 16+. Its SDK constraint is `>=2.19.6 <3.0.0`, so it **does not resolve on Dart 3**. It is unmaintained. https://pub.dev/packages/native_qr
  - `google_mlkit_barcode_scanning` 0.16.1 (2026-08-17) is the ML Kit *image* API: you pass an `InputImage` and need your own camera. It is not the code scanner. https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_barcode_scanning/README.md
  - pub.dev searches for "google code scanner" and "GmsBarcodeScanning" found nothing better (searched 2026-10-10).
  - **Recommendation:** about 40 lines of Kotlin behind a `MethodChannel` calling `GmsBarcodeScanning.getClient(...).startScan()`.
- **mobile_scanner** 7.4.2 (2026-09-14) is actively maintained.
  - Its Android manifest declares `android.permission.CAMERA`. https://github.com/juliansteenbakker/mobile_scanner/blob/master/android/src/main/AndroidManifest.xml
  - iOS needs `NSCameraUsageDescription`.
  - It uses bundled ML Kit on Android by default (+3 to 10 MB). The unbundled variant adds about 600 KB.
  - Source: https://github.com/juliansteenbakker/mobile_scanner/blob/master/README.md
- **iOS equivalent:** `DataScannerViewController` (VisionKit, iOS 16+) still needs `NSCameraUsageDescription` and user consent. You should check `isSupported` and `isAvailable` first. https://developer.apple.com/documentation/visionkit/datascannerviewcontroller
  - iOS has no permission-free scanner. Either `mobile_scanner` or a small Swift channel works there.

## 5. Local DB: drift vs sqflite vs sqlite3

| | drift 2.35.2 | sqflite 2.4.4+1 | sqlite3 3.7.0 |
|---|---|---|---|
| Reactive streams for UI | Yes. "every query can be turned into an auto-updating stream" ([streams](https://drift.simonbinder.eu/dart_api/streams/)) | No built-in streams (README lists none; **UNVERIFIED** absence) | No (raw bindings) |
| Migrations | `schemaVersion` + step-by-step migrations, `make-migrations` CLI, schema test utilities ([migrations](https://drift.simonbinder.eu/migrations/)) | `onCreate` / `onUpgrade` / `onDowngrade` in a transaction ([README](https://github.com/tekartik/sqflite/blob/master/sqflite/README.md)) | Manual |
| Background isolate (workmanager, widget callback) | `drift_flutter`'s `DriftNativeOptions(shareAcrossIsolates: true)` uses `IsolateNameServer` to share one DB isolate between "your app and a background service" ([drift_flutter README](https://github.com/simolus3/drift/blob/develop/drift_flutter/README.md)). Truly independent isolates can open the same file, but "stream queries won't synchronize" ([isolates](https://drift.simonbinder.eu/isolates/)) | Runs DB ops on a background native thread. Usable from any isolate that has plugins registered | Usable from any isolate (pure FFI) |
| Dart server (no Flutter) | Yes. drift depends on `sqlite3 ^3.4.0` (pure Dart and FFI) | No, Flutter plugin (use `sqflite_common_ffi` on the desktop/VM) | Yes |

- **sqlite3 3.x** now ships SQLite via Dart **build hooks**. It "bundles SQLite with your application and doesn't require any external dependencies or build configuration".
  - Prebuilt binaries cover Linux armv7, aarch64, x64, x86 and riscv64.
  - You can switch to the system SQLite or SQLCipher/SQLite3MultipleCiphers with hook options.
  - Sources: https://github.com/simolus3/sqlite3.dart/blob/main/sqlite3/README.md and https://github.com/simolus3/sqlite3.dart/blob/main/sqlite3/doc/hook.md
  - `sqlite3_flutter_libs` is now `0.6.0+eol` because the hooks replace it.
- **Server compile caveat (important):** "If your package or any of its dependencies has build hooks, you must use the `dart build` command. The `dart compile exe` … commands don't run build hooks, and will fail if hooks are present." https://dart.dev/tools/dart-compile
  - So a server using `sqlite3` 3.x must be built with `dart build cli`. The output is `bundle/bin/<exe>` plus `bundle/lib/<dynamic libs>`. https://dart.dev/tools/dart-build
  - `dart build` was introduced in Dart 3.10. The current stable is Dart 3.13.x per dart.dev.
- **Verdict:** use `drift` (with `drift_flutter`) in the app and plain `drift` or `sqlite3` on the server. That gives one SQL dialect and one library family on both sides.

## 6. Dart server

- **shelf:**
  - Latest release 1.4.2 (2024-06-21). The repo is not archived and is still actively committed to: the last commit to `pkgs/shelf` was 2026-10-01, and 1.4.3-wip is in progress. It has 76 open issues. Sources: https://github.com/dart-lang/shelf and https://github.com/dart-lang/shelf/blob/master/pkgs/shelf/CHANGELOG.md
  - Its publisher is tools.dart.dev, i.e. the Dart team.
  - It is stable but slow-moving. `shelf_router` 1.1.4 dates from 2023-05-03.
- **Executable:**
  - `dart compile exe` produces a "standalone, architecture-specific executable".
  - It can cross-compile to Linux x64, ARM64 (Dart 3.8+), ARM and RISCV64 (Dart 3.9+) with `--target-os=linux --target-arch=...`. Only Linux is supported as a cross-compile target. https://dart.dev/tools/dart-compile
  - With `sqlite3` hooks, use `dart build cli` instead (see Q5). **UNVERIFIED:** whether `dart build cli` supports the same cross-compile flags. The page lists only `-o`, `-t` and `--verbosity`.
- **Official Docker image:** `dart` on Docker Hub ("Official Image"), maintained at https://github.com/dart-lang/dart-docker (last push 2026-10-05). The documented pattern is:
  - `FROM dart:stable AS build`
  - `RUN dart build cli --target bin/server.dart -o output`
  - `FROM scratch`
  - `COPY --from=build /runtime/ /`
  - `COPY --from=build /app/output/bundle/ /app/`
  - The docs claim "very small runtime images (~10 MB)". https://github.com/docker-library/docs/blob/master/dart/content.md and https://hub.docker.com/_/dart
- **Memory footprint:** no official figure found. **UNVERIFIED.** Measure the RSS of a compiled shelf + sqlite3 server yourself. My expectation, also unverified: tens of MB.

## 7. Speech: `speech_to_text`

- 7.5.0 (2026-09-14) is on pub.dev and 7.6.0-beta.4 is in the repo. Releases are active. https://github.com/csdcorp/speech_to_text/blob/main/speech_to_text/CHANGELOG.md
- **Locale:** `speech.locales()` returns the installed locales, and `listen(localeId: ...)` selects one. The default is the device locale. https://github.com/csdcorp/speech_to_text/blob/main/speech_to_text/README.md
- **On-device:**
  - `SpeechListenOptions.onDevice` exists. Per the platform interface docs, an on-device request the device cannot satisfy "fails the listen session" on iOS, while "on Android it silently falls back to the network recognizer".
  - A `has_on_device_support` check was added in 7.6.0-beta.4. iOS support is per locale. https://github.com/csdcorp/speech_to_text/blob/main/speech_to_text_platform_interface/lib/speech_to_text_platform_interface.dart
  - Android needs the `INTERNET` permission "because speech recognition may use remote services".
  - Offline language packs are installed via Google app settings (README troubleshooting).
- **Limits:**
  - Android stops listening after a short pause (≤5 s observed).
  - The README quotes Apple's one-minute audio limit and its network rate limits (README).
- It fits short item dictation ("milk, eggs") well. Offline use is best-effort.

## 8. Localization and RTL

Flutter's official path is `flutter_localizations` (SDK) plus `intl` (0.20.3, dart.dev publisher). You enable `generate: true` and create an `l10n.yaml` with `template-arb-file: app_en.arb`. ARB files then generate a typed `AppLocalizations` via `flutter gen-l10n`, with placeholders, plurals and selects. `GlobalWidgetsLocalizations.delegate` "defines the default text direction, either left-to-right or right-to-left", so RTL locales (Arabic, Hebrew) flip the layout automatically. Source: https://docs.flutter.dev/ui/internationalization

## Verdict

**Flutter + Dart server works for listopher.** Every feature has a maintained path, and the "one language, shared op format" goal from ADR 7 holds equally well with Dart:

- A shared `listopher_core` Dart package used by both the app and the server.
- `drift`/`sqlite3` on both sides.

What must be native, per platform:

| Piece | Android (Kotlin) | iOS (Swift) |
|---|---|---|
| Home-screen widget layout | Glance composable or XML layout (small). Click goes to a `home_widget` broadcast, then the Dart callback | SwiftUI widget extension + an `AppIntent` that calls `HomeWidgetBackgroundWorker.run`, + App Group |
| Widget Sync button logic | None (Dart via `registerInteractivityCallback`) | Dart via the AppIntent shim. Fallback: native Swift HTTP sync if the engine-in-background path proves unreliable |
| Permission-free QR scan | ~40-line `MethodChannel` to `GmsBarcodeScanning` (no maintained wrapper) | Use `mobile_scanner`, or a small `DataScannerViewController` channel (camera permission is needed either way) |
| Background schedule config | None | `AppDelegate` registrations + Info.plist `BGTaskSchedulerPermittedIdentifiers` |
| Ongoing notification | None | Not available on iOS (Live Activity would be native, out of scope) |

**Minimal package set:**
- App: `drift` + `drift_flutter`, `home_widget`, `flutter_local_notifications`, `workmanager`, `http`, `flutter_localizations` + `intl`, `speech_to_text`.
- Add `mobile_scanner` only if the camera-permission scanner is acceptable for iOS.
- Server: `shelf` (+ `shelf_router` optional), `sqlite3` (or `drift`).
- Shared: a pure-Dart `core` package for the op format and JSON.

**Risks:**
1. **iOS widget sync** needs a Flutter engine started in the background via an AppIntent. It is documented but has known fragility (several iOS background fixes in the home_widget CHANGELOG, e.g. 0.5.0 and #244). Prototype it early on a real device before committing.
2. **iOS background sync is best-effort.** There is no guaranteed periodic run and no runs after the user force-quits the app. The Sync button and on-open sync are the real guarantees, which matches ADR 4.
3. **Android 14+** lets users dismiss "ongoing" notifications. Plan to re-post via `dismissIsolate` or treat the notification as optional.
4. **Build hooks:** `sqlite3` 3.x forces `dart build cli` instead of `dart compile exe`. It is documented and the official Docker example already does this, but the toolchain is new (Dart 3.10+).
5. **Several isolates touching the DB** (UI, widget callback, notification action, workmanager). Use `drift_flutter` `shareAcrossIsolates: true`, or accept that streams won't auto-refresh after a background write until the app reloads.
6. **shelf releases are infrequent** (last release June 2024). It is low-risk for a small HTTP+JSON API, but don't expect new features.
7. **No maintained Flutter wrapper for the Google code scanner.** You own a small native channel.
8. **Plugin minimums:** Flutter >=3.38 (home_widget, workmanager, flutter_local_notifications) and >=3.44 (sqflite, not recommended here). Pin the Flutter SDK accordingly.
