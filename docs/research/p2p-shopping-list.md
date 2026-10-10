# Listopher: P2P shared shopping list research

Checked on 2026-10-10. Sources are primary only: official docs, specs, and the GitHub READMEs or source of the projects themselves. Repo activity dates come from the GitHub API (`pushed_at`) on the same day. Where I could not confirm something, the text says so.

---

## TL;DR

- **CRDT:** Automerge and Loro both record an actor/peer ID, a wall-clock timestamp and an optional message on every change, and both keep full history. That is enough to build "blame".
- **Transport:** Iroh (QUIC, dial by public key, NAT hole-punching, relay fallback) is the only option checked that has published Swift and Kotlin packages and works both on a LAN and across the internet.
- **"No server at all" works only when phones are near each other** (same LAN or Bluetooth). Across different networks you need address lookup plus a relay. The least infrastructure is n0's free public relays (rate-limited, no guarantees, "suitable for development and testing") or one small self-hosted `iroh-relay`.
- **Background sync on iOS is effectively foreground-only** without push, and push needs a server. Design for "syncs when the app is open on two phones at once, or when you're near each other".
- **Recommended stack:** a native UI per platform (Kotlin/Compose + Glance on Android, Swift/SwiftUI + WidgetKit on iOS) over one shared Rust core (Automerge + Iroh) exposed through UniFFI. Widgets, notifications, speech and on-device LLMs are all native-only APIs anyway.

---

## A. Sync data model (CRDTs)

| Library | Per-change author | Per-change time | History kept | Mobile bindings | Activity (GitHub) |
|---|---|---|---|---|---|
| **Automerge** (Rust core) | `actorId` | `timestamp` | Yes. Every change has a hash and dependencies | Swift (official), Java/Android (official, early), JS/WASM, C | core pushed 2026-10-09 |
| **Loro** (Rust core) | `peer` (PeerID) | `timestamp` (opt-in) | Yes. Changes have Lamport time, deps and a commit message | Swift (marked "experimental"), React Native (UniFFI Turbo Module), Python. No first-party Kotlin package found | core pushed 2026-10-09 |
| **cr-sqlite** | `site_id` per column change | No wall-clock column in `crsql_changes` | Last-writer state plus versions, not an op log | SQLite extension. No first-party mobile packages found in README | pushed 2026-08-10 |
| **Yjs / y-crdt** | clientID | Not first-class | Yes, but JS-first | Rust port `y-crdt` | yjs 2026-10-07 |
| **iroh-docs** | Signed **Author** key per entry | Timestamp per entry | Latest entry per key per author (a KV store, not a full op log) | Not in iroh-ffi (out of scope until it reaches 1.0) | 2026-08-19 |
| **Ditto** | n/a | n/a | n/a | Commercial SDK. P2P mesh plus optional Ditto Server (cloud or on-prem) | closed source |

Evidence:
- **Automerge.** The Swift `Change` struct exposes `actorId`, `message`, `deps`, `timestamp` and `hash` ([Change.swift](https://raw.githubusercontent.com/automerge/automerge-swift/main/Sources/Automerge/Change.swift)). Conflict "last writer wins" is decided by op ID (counter + actorId), **not** by wall-clock time ([Automerge conflicts](https://automerge.org/docs/reference/documents/conflicts/)). This is fine: the timestamp is for display only.
  - Swift package: `from: "0.5.2"` in the README ([automerge-swift README](https://github.com/automerge/automerge-swift)).
  - automerge-repo-swift (networking/storage) describes itself as "far from stable", and its last push was 2024-11-01 ([automerge-repo-swift README](https://github.com/automerge/automerge-repo-swift)). **Don't depend on it.**
  - Java bindings are at 0.0.7, and the README has a "Gradle (including android)" section ([automerge-java README](https://github.com/automerge/automerge-java)). They are early.
- **Loro.**
  - The internal `Change` has `id` (peer + counter), `lamport`, `deps`, `timestamp` (Unix seconds) and `commit_msg` ([change.rs](https://github.com/loro-dev/loro/blob/main/crates/loro-internal/src/change.rs)).
  - The public API has `set_record_timestamp(true)`, `set_next_commit_message`, `get_change` returning `ChangeMeta`, and `travel_change_ancestors` ([loro lib.rs](https://github.com/loro-dev/loro/blob/main/crates/loro/src/lib.rs)).
  - **Caution from the source:** "Do not assign a fixed PeerID to a user or device without strict single-ownership locking. Prefer the default random PeerID per process/session" (same file).
  - Changes inside a merge interval are merged together (default 1000 s, `set_change_merge_interval`). Shorten this if you want per-tap blame.
  - Bindings are listed in the [loro-ffi README](https://github.com/loro-dev/loro-ffi). The [loro-swift README](https://github.com/loro-dev/loro-swift) calls them "experimental" and pins `from: "1.16.2"`.
- **cr-sqlite.** The `crsql_changes` columns are `table, pk, cid, val, col_version, db_version, site_id, cl, seq` ([cr-sqlite README](https://github.com/vlcn-io/cr-sqlite)). That gives "which device" but no wall time and no op history, so you would have to store blame yourself.
- **iroh-docs.** Entries are "signed with two keypairs": the Namespace key (write capability) and the Author key ("proof of authorship"), and each entry carries a timestamp ([iroh-docs README](https://github.com/n0-computer/iroh-docs)). This is the only option checked with *cryptographically authenticated* authorship. It is excluded from iroh-ffi ("higher-level protocols not yet at 1.0 (`iroh-blobs`, `iroh-docs`, `iroh-gossip`) are out of scope", [iroh-ffi README](https://github.com/n0-computer/iroh-ffi)).
- **Ditto.**
  - Ditto calls itself a mobile database that can "synchronize without relying on a central server", over "Bluetooth, peer-to-peer Wi-Fi, or local LAN".
  - "Ditto Server" is an optional cluster, cloud or on-prem ([About Ditto](https://docs.ditto.live/home/about-ditto)).
  - It is commercial and closed source. I could not fetch the pricing or license terms.
  - It is the only turnkey answer to the Android↔iOS offline mesh, at the cost of vendor lock-in.

**Blame design (works with either Automerge or Loro):**
1. Store `checkedBy: <memberId>` and `checkedAt` on the item itself, for cheap display.
2. Use CRDT change history (actor + timestamp + message such as `"check:item123"`) as the audit trail.
3. Keep a `members` map in the doc from actorId/peerId to memberId (see D).

Caveat: in Automerge and Loro, authorship is **not** authenticated. Any group member can write any `checkedBy`. That is acceptable for a family list. If it isn't, you need signed ops (iroh-docs-style).

## B. P2P transport

**Local, same network**
- Android NSD (mDNS/DNS-SD) and Apple Bonjour (`NWBrowser`, iOS 13+, [Apple](https://developer.apple.com/documentation/network/nwbrowser)) interoperate over standard mDNS.
- iOS requires `NSLocalNetworkUsageDescription` and an `NSBonjourServices` list ([Nearby Swift setup](https://developers.google.com/nearby/connections/swift/get-started)).
- **Android 17 (API 37)** makes local-network protection mandatory for apps targeting it. You need the new `ACCESS_LOCAL_NETWORK` permission (NEARBY_DEVICES group) or a system picker (`DiscoveryRequest.FLAG_SHOW_PICKER`), and advertising always needs the permission ([Local network permission](https://developer.android.com/privacy-and-security/local-network-permission), [NsdManager](https://developer.android.com/reference/android/net/nsd/NsdManager)).

**Nearby without Wi-Fi infrastructure**
- **Apple Multipeer Connectivity** uses infrastructure Wi-Fi, peer-to-peer Wi-Fi and Bluetooth on iOS ([Apple](https://developer.apple.com/documentation/multipeerconnectivity)). It is **Apple-only**, with no Android implementation.
- **Google Nearby Connections** uses "Bluetooth, BLE, and Wi-Fi" ([overview](https://developers.google.com/nearby/connections/overview)) and now has a Swift SDK ([Swift get started](https://developers.google.com/nearby/connections/swift/get-started)).
  - Maintainers say iOS↔Android works only when both are on the same Wi-Fi LAN. iOS supports fewer mediums, and fully offline iOS↔Android "most likely won't be possible" ([google/nearby #2447](https://github.com/google/nearby/discussions/2447)).
  - The repo says it is "not an officially supported Google product" ([google/nearby README](https://github.com/google/nearby)).
- **Wi-Fi Aware on iOS 26** is a NAN P2P framework ([Apple WiFiAware](https://developer.apple.com/documentation/wifiaware)). Apple frames it around connecting to "Wi-Fi Aware certified accessories". Phone-to-Android-phone interop is **unverified**. Treat it as future work.
- **Raw BLE GATT** is the only truly cross-platform offline radio, but you build the whole protocol yourself. Not worth it for v1.

**Internet, different networks**
- **Iroh** (pushed 2026-10-09; iroh-ffi says it mirrors the "stabilized iroh 1.0 surface"):
  - You dial by public key. It "tries to hole-punch" and otherwise "fall[s] back to an open ecosystem of public relay servers" ([iroh README](https://github.com/n0-computer/iroh)).
  - Public relays are run by n0. They "Rate-limit traffic", "Carry no uptime or performance guarantees", and are "suitable for development and testing". Production is expected to use n0's paid relays or a self-hosted `iroh-relay` ([Relays](https://docs.iroh.computer/concepts/relays)).
  - Address lookup defaults to DNS/Pkarr (n0's `dns.iroh.link`). Alternatives are **mDNS** on the LAN and the **BitTorrent Mainline DHT** ([Address lookup](https://docs.iroh.computer/concepts/discovery)).
  - Published bindings: Swift (SwiftPM/CocoaPods), Kotlin (`computer.iroh:iroh` on Maven Central), Python, Node ([iroh-ffi](https://github.com/n0-computer/iroh-ffi)). The `@number0/iroh` npm package is Node.js, **not React Native**.
- **Hypercore / Holepunch.**
  - HyperDHT defaults to three hardcoded bootstrap nodes (`node{1,2,3}.hyperdht.org`) ([hyperdht README](https://github.com/holepunchto/hyperdht)).
  - It runs on mobile through Bare/bare-kit "worklets" (a JS runtime embedded in iOS/Android) ([bare-kit](https://github.com/holepunchto/bare-kit)).
  - Workable, but it means a JS runtime in the app plus a different data model.
- **libp2p** (rust-libp2p is active) has the same shape: it needs bootstrap peers and relays. It has no mobile-first packaging. I did not research it in depth.
- **WebRTC** needs out-of-band signalling plus STUN, and TURN ([RFC 8656](https://datatracker.ietf.org/doc/html/rfc8656)) for relaying around NATs. It is **not serverless**: the signalling channel is a server you have to supply.

**Can two phones on different networks sync with zero servers?** Not reliably.
- You need to find the other peer's current address. That takes DNS/Pkarr, a DHT whose bootstrap nodes someone runs, or a ticket that goes stale ([Tickets](https://docs.iroh.computer/concepts/tickets)).
- When hole-punching fails (common on mobile carrier NAT), you need a relay.
- Even with both, the two apps must be **running at the same time**.

**Minimum honest infrastructure:**
- (1) None for the same-LAN / nearby case.
- (2) For remote sync: Iroh with Mainline DHT address lookup (public infrastructure, no server of your own) plus n0 public relays for dev, then one self-hosted `iroh-relay` (a few MB, any VPS) for production.
- Optional (3): any always-on peer, such as a desktop build of the same core, can act as a store-and-forward member. Because it's just another group member, there's still no central server.

**Background limits**
- **iOS:**
  - On backgrounding, the app gets about 5 seconds, then is suspended. `beginBackgroundTask` extends this only briefly ([Apple](https://developer.apple.com/documentation/uikit/extending-your-app-s-background-execution-time)).
  - `BGTaskScheduler` runs at system discretion ([Apple](https://developer.apple.com/documentation/backgroundtasks/bgtaskscheduler)).
  - iOS 26 adds `BGContinuedProcessingTask`, but it only continues work that *started in the foreground* ([Apple](https://developer.apple.com/documentation/backgroundtasks/bgcontinuedprocessingtask)).
  - Net effect: no persistent P2P listener. Waking a phone remotely needs APNs, which needs a server.
- **Android:**
  - Doze blocks network access and defers jobs to maintenance windows. Google recommends FCM, which is server-based, for timely wake-ups ([Doze](https://developer.android.com/training/monitoring-device-state/doze-standby)).
  - WorkManager respects Doze ([WorkManager](https://developer.android.com/topic/libraries/architecture/workmanager)).
  - `dataSync` foreground services are capped at 6 h per 24 h in the background for apps targeting Android 15 ([FGS timeout](https://developer.android.com/develop/background-work/services/fgs/timeout)).
  - Net effect: you can sync opportunistically for longer than on iOS, but you can't count on it.
- **Design consequence:** sync on app open, on pull-to-refresh, and opportunistically from WorkManager/BGAppRefresh. Show "last synced with X at T" per member.

## C. Joining a group via QR

**What to encode.** Keep it compact so the QR stays scannable. For example:

`listopher://join?v=1&g=<groupId>&s=<groupSecret base32>&t=<inviter iroh endpoint ticket>`

- `g`: the doc/group ID.
- `s`: a random 256-bit group secret. Use it for a membership proof when connecting (for example an HMAC challenge over the QUIC connection, which is already encrypted to the peer's key) and, optionally, to derive a key for encrypting docs at rest.
- `t`: the inviter's iroh ticket.

Iroh ticket facts ([Tickets](https://docs.iroh.computer/concepts/tickets)):
- Tickets "contain IP addresses".
- They "are reusable", not single-use.
- "Application-specific tickets may contain secrets … can grant ongoing access."
- They "can go stale".
- Implication: the QR is a long-lived bearer credential. Show it only on demand and rotate `s` when someone leaves. Revocation means re-keying the group and re-inviting.

**Scanning APIs**
- **Android:** the Google code scanner (`play-services-code-scanner:16.1.0`) works "without requiring camera permission", using a Google Play services UI ([code scanner](https://developers.google.com/ml-kit/vision/barcode-scanning/code-scanner)). Android-only, and it needs Play services. Use ML Kit Barcode + CameraX if you need a custom UI or devices without Play services.
- **iOS:** VisionKit `DataScannerViewController` (iOS 16+) reads QR codes from the live camera; check availability before presenting ([Apple](https://developer.apple.com/documentation/visionkit/datascannerviewcontroller)). AVFoundation metadata output is the low-level fallback (not separately verified here).
- Also register `listopher://` as a deep link, so the system camera app can join without the in-app scanner.

## D. Local identity

- **Device keypair:** one Ed25519 keypair per install, which is the iroh endpoint secret key. The public key *is* the `EndpointId` you dial ([iroh README](https://github.com/n0-computer/iroh): "`iroh-base`: Common types like `EndpointId`"). Store the secret in the Keychain or Android Keystore-wrapped storage.
- **User vs device:** v1 should use **one member = one device**. Multi-device users can be added later by having the old device "vouch" for the new key in the members map.
- **Mapping to CRDT actors:** use a random Automerge actorId or Loro PeerID per device or session, following Loro's own warning against fixed per-user IDs. On first write, put `members[actorId] = { endpointId, displayName, color }` into the doc. Blame then resolves through actor → member → display name.
- **Display name** is just data in the doc. It's last-writer-wins and editable by its owner (by convention, not enforced).

## E. Notifications and widgets

**Android**
- **Persistent notification:**
  - Since Android 14, `setOngoing(true)` notifications **can be swiped away by the user**, except on the lock screen, on "Clear all", and for exempt categories (CallStyle, media, DPC). This applies to all apps regardless of target SDK ([Android 14 changes](https://developer.android.com/about/versions/14/behavior-changes-all)).
  - So treat the list notification as best-effort: offer a "re-pin" action and repost it when the list changes.
  - Android 16 "Live Updates" have strict eligibility criteria ([Live updates](https://developer.android.com/develop/ui/compose/notifications/live-update)). I have not verified whether a shopping list qualifies, so don't assume it does.
- **Widget:**
  - Jetpack Glance `glance-appwidget` is stable at **1.2.0** (2026-08-26) ([Glance releases](https://developer.android.com/jetpack/androidx/releases/glance)).
  - Glance widgets run in the app process, so they read the same local store (DataStore/file) directly. Check-off goes through an `ActionCallback` that writes a CRDT change.

**iOS**
- **WidgetKit:** widgets get data from a shared **App Group** container ([App Groups](https://developer.apple.com/documentation/xcode/configuring-app-groups)).
  - Store the CRDT doc file, or a JSON snapshot, in the App Group.
  - The app calls WidgetCenter to reload timelines after sync.
- **Interactive check-off (iOS 17+):** buttons and toggles run App Intents without launching the app. They are inactive on a locked device until it's unlocked ([Adding interactivity](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities)). The intent runs in the extension and must write to the App Group doc. That is easy with a Rust core that both the app and the extension link.
- **Live Activities are a poor fit:**
  - At most 8 h active, then up to 4 more hours on the lock screen (12 h max).
  - "It can't access the network"; updates come only from the app or push ([Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)).
  - At most, use one only for an "I'm at the store now" session.

## F. Voice dictation (future, but put the seam in now)

**Speech to text**
- **Android:** `SpeechRecognizer.createOnDeviceSpeechRecognizer()` (API 31+). Guard it with `isOnDeviceRecognitionAvailable()` ([SpeechRecognizer](https://developer.android.com/reference/android/speech/SpeechRecognizer)).
  - ML Kit GenAI Speech Recognition is **alpha**. Basic mode runs on API 31+; Advanced mode (Gemini Nano) runs on Pixel 10/11 only ([ML Kit speech](https://developers.google.com/ml-kit/genai/speech-recognition/android)).
- **iOS:** `SpeechAnalyzer` + `SpeechTranscriber` (iOS 26+) ([Apple](https://developer.apple.com/documentation/speech/speechanalyzer)). Fallback is `SFSpeechRecognizer` with `requiresOnDeviceRecognition` (iOS 13+) ([Apple](https://developer.apple.com/documentation/speech/sfspeechrecognitionrequest/requiresondevicerecognition)).

**Parsing text into items**
- **iOS:** the Foundation Models framework (iOS 26+) offers guided generation with `@Generable` that "provides strong guarantees that the model generates instances of your type". It requires an Apple Intelligence–capable device ([Foundation Models](https://developer.apple.com/documentation/foundationmodels)).
- **Android:** the ML Kit GenAI **Prompt API (Beta)** runs Gemini Nano. Structured output is **Alpha**. Device support is a changing allowlist across nano-v2, v3 and v4 ([Prompt API](https://developers.google.com/ml-kit/genai/prompt/android), [GenAI overview](https://developers.google.com/ml-kit/genai)).
- Both are device-limited, so you **must** have a dumb fallback: split on commas/"and"/newlines plus a quantity regex.

**The seam to build now.** Make one command-based write path that manual entry already uses:

```
addItems(listId, requester: MemberId, date, items: [ParsedItem{name, qty?, unit?, note?}], source: manual|voice)
```

The voice pipeline is then `transcribe() -> String -> parse(String) -> [ParsedItem] -> review screen -> addItems(...)`. Keep `parse` behind an interface (`ItemParser`) with LLM and regex implementations. Record `source` in the change message, so blame shows "added by voice".

## G. Cross-platform framework choice

| Option | CRDT | Iroh | Widgets / notifications / speech / LLM | Verdict |
|---|---|---|---|---|
| **Native Kotlin + Swift over a Rust core (UniFFI)** | Automerge or Loro are Rust natively | Rust natively, including gossip/mDNS crates that aren't in FFI | All first-party | **Recommended** |
| Native, no Rust (automerge-swift + automerge-java + iroh-ffi) | Official packages (Java 0.0.7 is early) | Published Swift/Kotlin | All first-party | Viable, but sync glue is written twice |
| React Native / Expo | `loro-react-native` (UniFFI Turbo Module) | No RN package; you'd need your own uniffi-bindgen-react-native wrapper | `expo-widgets` is stable for **iOS** widgets and Live Activities in SDK 56 ([Expo blog](https://expo.dev/blog/ios-widgets-and-live-activities-in-expo)). Nothing equivalent found for Android | You end up writing native modules anyway |
| Flutter | No first-party bindings (none listed in the loro-ffi or iroh-ffi READMEs) | Same | Widgets need native code | Worst fit |
| Kotlin Multiplatform | Rust via UniFFI on each side anyway | Same | Native per platform | Adds a layer without removing one |

Per-platform APIs dominate this app: widgets, App Intents, notifications, QR, speech and LLMs. The shared piece is exactly "CRDT + sync", which a Rust core covers.

---

## Recommended stack (lazy/minimal path)

1. **`listopher-core` (Rust):** `automerge` (built-in sync protocol; actor/time/message on every change) + `iroh` (+ `iroh` mDNS / Mainline DHT address lookup).
   - Exported to Swift and Kotlin with UniFFI.
   - API: `open(groupDir)`, `addItems`, `check(itemId, member)`, `history(itemId)`, `snapshotJson()`, `syncNow()`, `inviteQr()`, `join(qr)`.
   - Swap in Loro instead if you want cheaper history queries. Both work.
2. **One Automerge document per group.** Lists hold items. Each item has `name, qty, requester, createdAt, listDate, checkedBy, checkedAt`. The doc also holds a `members` map. Store it as a single file in the app's storage: the App Group container on iOS, `filesDir` on Android.
3. **Sync:** on app open, every 15–30 s while in the foreground, and opportunistically via WorkManager / BGAppRefresh. Use mDNS on the LAN, then n0 public relays + DHT for dev, then **one self-hosted `iroh-relay`** before any real release.
4. **Android:** Compose UI, Glance 1.2 widget, and a re-postable ongoing notification. QR scanning via the Google code scanner.
5. **iOS:** SwiftUI, WidgetKit with App Intent toggles (iOS 17+) reading the App Group doc. QR scanning via `DataScannerViewController`. Skip Live Activities.
6. **Voice:** later, behind `ItemParser`. On-device STT, then Foundation Models / Gemini Nano when available, otherwise the regex fallback.

## Open questions / risks

- **"No server" is only true nearby.** Remote sync needs at least a relay, and address lookup through someone's DNS or DHT bootstrap. Decide whether to self-host one `iroh-relay` or accept n0's public relays, which come with no guarantees.
- **Simultaneous-online requirement.** Without push (which needs a server) or an always-on member device, two remote phones only sync when both apps happen to be open together. Validate that users accept this, or plan an optional "home hub" peer.
- **Offline Android↔iOS without Wi-Fi is unsolved:**
  - Multipeer is Apple-only.
  - Nearby Connections iOS↔Android works only over a shared Wi-Fi LAN.
  - Phone-to-phone interop of iOS Wi-Fi Aware is unverified.
  - Ditto may solve it, but it is commercial and closed source.
- **Authorship isn't authenticated** in Automerge or Loro data. Fine for families; if not, look at signed ops (iroh-docs model).
- **Revocation:** a QR code is a reusable bearer secret. Removing a member requires re-keying the group. Old devices keep the history they already have.
- **Android 17 local-network permission** changes the LAN discovery UX (permission prompt or system picker).
- **The iOS widget extension writing to the same Automerge file as the app** needs file coordination or locking. This needs a prototype.
- **Unverified here:** Ditto pricing and licence; cr-sqlite mobile packaging; whether Android Live Updates allow a shopping-list use case; AVFoundation QR details.
