# GPS Control

Flutter app for configuring GPS trackers over **BLE** (when you are standing next
to the device) and over **SMS** (when you are not).

Bundle id `com.ikayapps.gps_control` · Flutter 3.41 / Dart 3.11 · Turkish and
English.

## Running

```sh
cd mobile
flutter pub get
flutter run
```

Against canned data — no BLE, no SMS, no SIM, no permission prompts:

```sh
flutter run --dart-define=DEMO=true
```

`DEMO` is read in exactly one place, `lib/main.dart`. Everything downstream is
handed a repository interface and cannot tell whether hardware is answering.

## Layout

```text
mobile/
  lib/
    app/           MaterialApp.router, go_router config, design tokens
    data/          repository interfaces + real and fake implementations
    features/      bluetooth (bloc), sms, sim (cubit), settings
    shell/         StatefulShellRoute host + bottom tab bar
    l10n/          tr (template) and en
  packages/
    bariox_tracker         BLE transport and frame codecs
    sms_tracker_commands   SMS command builder and status parser
```

`mobile/` is a [pub workspace], so one `flutter pub get` resolves the app and
both path packages.

[pub workspace]: https://dart.dev/tools/pub/workspaces

## Architecture

**Repositories are the seam.** `TrackerRepository`, `SmsRepository` and
`SimRepository` are interfaces in `lib/data/`. Each has a platform
implementation and a fake. `main.dart` is the composition root and the only
place that chooses between them, so blocs, widgets and tests all work against
the interface.

**BLE commands are verified, not assumed.** A lock or unlock does not report
success from the acknowledgement frame. `BleTrackerRepository` sends the switch
command, then reads the device's status back and derives the result from the
device's own reading. See `_switch` in
`lib/data/tracker/ble_tracker_repository.dart`.

**Two BLE protocols exist, one is live.** The manufacturer's documented
`AA-BB-0A` framing is implemented as `BarioxTracker`, and no unit we have ever
answered it. HB-series firmware speaks an older `AA-55-A9` protocol, implemented
as `BarioxTrackerLegacy` — that is what ships. Both are kept so the difference
stays visible.

**Navigation is declarative.** `StatefulShellRoute.indexedStack` keeps all three
branches mounted, so the `BluetoothBloc` and any live BLE connection survive tab
switches.

## Checks

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
(cd packages/bariox_tracker       && flutter test)
(cd packages/sms_tracker_commands && dart test)
```

The analyzer runs `very_good_analysis` with `--fatal-infos` and the tree is
clean, so any new info is a regression. `public_member_api_docs` is disabled for
`lib/` only — app internals are not a published API surface — and stays on in
both packages.
