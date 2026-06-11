import 'package:bariox_control/l10n/l10n.dart';

/// Resolves the localized display name for an [SmsCommand.id].
String smsCommandName(AppLocalizations l10n, String id) => switch (id) {
  'battery' => l10n.smsCmdBatteryName,
  'status' => l10n.smsCmdStatusName,
  'position' => l10n.smsCmdPositionName,
  'rfid' => l10n.smsCmdRfidName,
  'subs' => l10n.smsCmdSubsName,
  'fw' => l10n.smsCmdFwName,
  'sleep' => l10n.smsCmdSleepName,
  'interval' => l10n.smsCmdIntervalName,
  'autolock' => l10n.smsCmdAutolockName,
  'addrfid' => l10n.smsCmdAddrfidName,
  'addphone' => l10n.smsCmdAddphoneName,
  'pwd' => l10n.smsCmdPwdName,
  'sensor' => l10n.smsCmdSensorName,
  'unlock' => l10n.smsCmdUnlockName,
  'lock' => l10n.smsCmdLockName,
  'reboot' => l10n.smsCmdRebootName,
  'clear' => l10n.smsCmdClearName,
  'reset' => l10n.smsCmdResetName,
  _ => id,
};

/// Resolves the localized subtitle for an [SmsCommand.id] (may be empty).
String smsCommandSub(AppLocalizations l10n, String id) => switch (id) {
  'battery' => l10n.smsCmdBatterySub,
  'status' => l10n.smsCmdStatusSub,
  'position' => l10n.smsCmdPositionSub,
  'rfid' => l10n.smsCmdRfidSub,
  'subs' => l10n.smsCmdSubsSub,
  'fw' => l10n.smsCmdFwSub,
  'unlock' => l10n.smsCmdUnlockSub,
  'lock' => l10n.smsCmdLockSub,
  'reboot' => l10n.smsCmdRebootSub,
  'clear' => l10n.smsCmdClearSub,
  'reset' => l10n.smsCmdResetSub,
  _ => '',
};

/// Resolves the localized input field label for an [SmsCommand.id] (or '' if
/// the command doesn't take input).
String smsInputLabel(AppLocalizations l10n, String id) => switch (id) {
  'sleep' => l10n.smsCmdSleepInputLabel,
  'interval' => l10n.smsCmdIntervalInputLabel,
  'autolock' => l10n.smsCmdAutolockInputLabel,
  'addrfid' => l10n.smsCmdAddrfidInputLabel,
  'addphone' => l10n.smsCmdAddphoneInputLabel,
  'pwd' => l10n.smsCmdPwdInputLabel,
  'sensor' => l10n.smsCmdSensorInputLabel,
  _ => '',
};

/// Returns the localized unit string for duration-typed inputs (or null).
String? smsInputUnit(AppLocalizations l10n, String id) => switch (id) {
  'interval' || 'autolock' => l10n.smsUnitSeconds,
  _ => null,
};

/// Resolves the localized label for a stored command-value identifier:
/// segmented sensor levels ('low'/'medium'/'high'), toggle states
/// ('true'/'false'), or any other free-form value (returned as-is).
String smsOptionLabel(AppLocalizations l10n, String optionId) =>
    switch (optionId) {
      'low' => l10n.sensorLow,
      'medium' => l10n.sensorMedium,
      'high' => l10n.sensorHigh,
      'true' => l10n.composeToggleOn,
      'false' => l10n.composeToggleOff,
      _ => optionId,
    };
