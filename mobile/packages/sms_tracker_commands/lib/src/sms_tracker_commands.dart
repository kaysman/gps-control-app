import 'package:sms_tracker_commands/src/sms_command.dart';

/// Builds outgoing SMS commands for the Bariox GPS tracker.
///
/// All commands follow the format `#password,CMD:params` where the password
/// is the 6-digit device password (see [defaultPassword]).
///
/// Confirmed commands come from the vendor "device send SMS data user manual".
/// Extended parameter keys (alarm thresholds, intervals) follow the observed
/// `ST` prefix pattern and are grouped for future validation against firmware.
///
/// Usage:
/// ```dart
/// final cmds = SmsTrackerCommands(password: '000000');
/// final cmd = cmds.setReceivePhone(slot: 1, phoneNumber: '71061248');
/// // Send cmd.text via Android SMS to the tracker's SIM phone number.
/// ```
class SmsTrackerCommands {
  /// Creates a builder that authenticates every command with [password].
  const SmsTrackerCommands({String password = defaultPassword})
    : _password = password;

  /// Factory default device password (`000000`).
  static const String defaultPassword = '000000';

  final String _password;

  // ── Confirmed commands (documented in vendor manual) ──────────────────────

  /// Sets the phone number that receives SMS reports from the tracker.
  ///
  /// [slot] is 1-based (typically 1). [phoneNumber] must NOT include the
  /// country code — set that separately with [setNationalCode].
  ///
  /// Example: `#000000,STPH:1,71061248`
  SmsCommand setReceivePhone({
    required int slot,
    required String phoneNumber,
  }) => _build('STPH:$slot,$phoneNumber');

  /// Sets the country/national dialing code for outbound SMS.
  ///
  /// Example for Turkmenistan: `#000000,STNC:993`
  SmsCommand setNationalCode(int code) => _build('STNC:$code');

  // ── Extended parameters (Ext Parameters tab in vendor PC-tool) ───────────
  // Command keys follow the observed ST-prefix pattern. Values and units
  // match the vendor PC-tool labels. Validate against live firmware.

  /// Sets the SMS reporting interval in minutes.
  SmsCommand setSmsInterval(int minutes) => _build('STSI:$minutes');

  /// Enables (true) or disables (false) periodic SMS position reports.
  SmsCommand setSmsSwitch({required bool enabled}) =>
      _build('STSS:${enabled ? 1 : 0}');

  /// Enables (true) or disables (false) TCP/GPRS data upload.
  SmsCommand setTcpSwitch({required bool enabled}) =>
      _build('STTS:${enabled ? 1 : 0}');

  /// Sets the minimum rest (sleep) time in seconds.
  SmsCommand setMinRestTime(int seconds) => _build('STMR:$seconds');

  /// Sets the maximum parking time before a standstill alarm in minutes.
  SmsCommand setMaxParkingTime(int minutes) => _build('STMP:$minutes');

  /// Sets the wakeup working duration in seconds.
  SmsCommand setWakeupWorkingTime(int seconds) => _build('STWW:$seconds');

  /// Sets the stop/sleep mode timeout in minutes.
  SmsCommand setStopModeTime(int minutes) => _build('STSM:$minutes');

  /// Enables (true) or disables (false) the cover-open alarm.
  SmsCommand setCoverOpenAlarm({required bool enabled}) =>
      _build('STCA:${enabled ? 1 : 0}');

  /// Enables (true) or disables (false) the lock wire-cut alarm.
  SmsCommand setLockCutoffAlarm({required bool enabled}) =>
      _build('STLA:${enabled ? 1 : 0}');

  /// Enables (true) or disables (false) the seal-tampered alarm.
  SmsCommand setSealTamperedAlarm({required bool enabled}) =>
      _build('STSA:${enabled ? 1 : 0}');

  /// Enables (true) or disables (false) the illegal card (SIM swap) alarm.
  SmsCommand setIllegalCardAlarm({required bool enabled}) =>
      _build('STIC:${enabled ? 1 : 0}');

  /// Enables (true) or disables (false) the session-timeout alarm.
  SmsCommand setTimeoutAlarm({required bool enabled}) =>
      _build('STTO:${enabled ? 1 : 0}');

  /// Enables (true) or disables (false) the lock-rope insertion alarm.
  SmsCommand setLockRopeAlarm({required bool enabled}) =>
      _build('STLR:${enabled ? 1 : 0}');

  /// Enables (true) or disables (false) the low-power alarm.
  SmsCommand setLowPowerAlarm({required bool enabled}) =>
      _build('STLP:${enabled ? 1 : 0}');

  /// Enables (true) or disables (false) the standstill alarm.
  SmsCommand setStandstillAlarm({required bool enabled}) =>
      _build('STSB:${enabled ? 1 : 0}');

  /// Sets the send mode for lock wire-cut alarms (0 = SMS, 1 = TCP, 2 = both).
  SmsCommand setLockCutoffAlarmSendMode(int mode) => _build('STLM:$mode');

  /// Sets the send mode for standstill alarms (0 = SMS, 1 = TCP, 2 = both).
  SmsCommand setStandstillAlarmSendMode(int mode) => _build('STSN:$mode');

  // ── Internal ──────────────────────────────────────────────────────────────

  SmsCommand _build(String body) => SmsCommand(password: _password, body: body);
}
