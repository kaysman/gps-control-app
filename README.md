# Bariox Control

Configure GPS trackers without the manufacturer's Windows tool — over
**Bluetooth** when you are standing next to the device, over **SMS** when you
are not.

Configuring a tracker by hand means cabling it into a laptop, opening the
vendor's config tool, checking the battery, whitelisting SIM numbers, setting
GPRS and verifying coordinates. That is tedious for twenty units. For a few
thousand it stops being a job.

## The protocol is not what the documents say

The manufacturer's documented framing (`AA-BB-0A`) is implemented in
`packages/bariox_tracker` as `BarioxTracker`, and no unit has ever answered it.
Throwaway Python against a single tracker is what found the truth: HB-series
firmware speaks an older `AA-55-A9` protocol with a different header and a
different default password, and that is what ships, as
`BarioxTrackerLegacy`. Both implementations are kept so the difference stays
visible.

A protocol document is a claim, not a fact. Probe the device before building on
it.

## Layout

```text
mobile/    Flutter app — the real client (BLE + SMS), en/tr
  packages/bariox_tracker         BLE transport and frame codecs
  packages/sms_tracker_commands   SMS command builder and status parser
web/       React + Vite UI prototype, mock data only
```

## Run it

```sh
cd mobile
flutter pub get
flutter run
```

No hardware nearby? Canned data, no BLE, no SMS, no permission prompts:

```sh
flutter run --dart-define=DEMO=true
```

The web prototype is `cd web && npm install && npm run dev`.

## Status

Working: BLE scan, connect, lock/unlock and status — verified by reading the
device back rather than trusting the acknowledgement frame. SMS composes and
sends real messages and parses replies into a chat.

Not done: some SMS command strings are still guesses, the tracker list is
mock data (`mobile/lib/mock/mock_data.dart`), and nothing is persisted — there
is no database yet.

## Notes

`mobile/README.md` covers the architecture and the reasoning behind it. CI runs
formatting, `flutter analyze --fatal-infos` and the three test suites on every
push.

MIT.
