# GPS Control

Flutter app for configuring GPS trackers over **BLE** (when you are standing next
to the device) and over **SMS** (when you are not).

Bundle id `com.ikayapps.gps_control` · Flutter 3.41 / Dart 3.11 · English
(default) and Turkish.

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
    features/      bluetooth (bloc), sms (threads + chat), sim, settings
    shell/         StatefulShellRoute host + bottom tab bar
    l10n/          en (template) and tr
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
switches. One consequence bites: the shell stacks its tab bar *over* the branch
navigator, so a modal sheet pushed onto that navigator opens underneath the bar.
Settings pickers go through `showPickerSheet`, which pushes onto the root
navigator instead.

**Two families, one rule.** Manrope carries all prose; Roboto carries anything
that is really data — all-caps section labels, serials, phone numbers,
timestamps, wire text — with `kTabular` on the figures that change in place so
a ticking countdown or a clock column does not reflow. Both are bundled under
`assets/fonts` with their licences; nothing is fetched at runtime.

**One palette, three radii, no warm neutrals.** `lib/app/tokens.dart` is the
whole design system: deep forest ink (`kInk`), a fresh green pair (`kGreen` for
fills that carry ink text, `kGreenDeep` for text and white-on-green), a lime pop
that is only ever used on ink surfaces (`kLime`), and a cool mist canvas
(`kCanvas`). The old champagne paper and orange accent are gone — including from
the chat, where the canvas is mist and the composer is an ink pill. Radii come
from `kR14` / `kR22` / `kR30` and nothing else; every card shares the one
`kShadow` value.

**One mark, three places.** The launcher icon, the launch screen and the app
mark in the page headers are all the same green arrow, cut from
`AppIcons/gpslogo-transparent.png` at the repo root. `AppLogo` draws that
transparent cut directly — no plate, no ground — so the arrow sits on whatever
surface the header already has, ink on the radar screen and mist everywhere
else. The splash is dark in both light and dark mode, because the first screen
behind it is the dark radar view — see
`android/.../values-v31/styles.xml` for API 31+, `drawable*/launch_background.xml`
below that, and `ios/Runner/Base.lproj/LaunchScreen.storyboard`.

**The SMS tab is a thread list; a chat is a pushed screen.** `/sms` lists the
fleet with each thread's newest message; `/sms/:trackerId` is that tracker's
chat, routed *outside* the shell so it gets the whole screen instead of sharing
it with the floating tab bar. One chat talks to exactly one tracker — the "To:"
line is fixed, and there is no recipient picker (see the TODO on `SmsChatPage`).

**One conversation, two views.** `ConversationCubit` holds the whole
conversation above the routes, so a reply arriving while a chat is open also
moves that row's preview in the list, and a command sent from a chat shows up
in the list without reloading anything. Threading is a read-time concern —
`sms_thread.dart` splits the flat history per tracker, matching replies on the
last nine digits of the sender so a country code or a space does not lose a
message.

**Every setting is a bottom sheet.** Language, tracker brand and active SIM are
all one-of-N choices, so they share one row widget and one sheet widget
(`features/settings/widgets/`) rather than each growing its own control.

**Two brands, split by transport.** SMS speaks Teltonika FMB — the command
catalogue in `mock/mock_data.dart`, the wire strings in
`features/sms/sms_command_text.dart`, both in the documented
`<login> <password> <command>` form, which is why every message starts with two
spaces when no credentials are set. BLE speaks Bariox and only Bariox, because
that is what `packages/bariox_tracker` implements — see
`TrackerBrand.hasBleSupport`. Teltonika is the default brand; the picker changes
the label, not the protocol, until a second catalogue exists.

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
