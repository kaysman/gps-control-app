import 'package:gps_control/l10n/l10n.dart';
import 'package:gps_control/mock/mock_data.dart' show SmsCommand;

/// Resolves the localized display name for an [SmsCommand.id].
String smsCommandName(AppLocalizations l10n, String id) => switch (id) {
  'info' => l10n.smsCmdInfoName,
  'gps' => l10n.smsCmdPositionName,
  'io' => l10n.smsCmdIoName,
  'status' => l10n.smsCmdStatusName,
  'battery' => l10n.smsCmdBatteryName,
  'ver' => l10n.smsCmdFwName,
  'sleep' => l10n.smsCmdSleepName,
  'interval' => l10n.smsCmdIntervalName,
  'getparam' => l10n.smsCmdGetparamName,
  'setparam' => l10n.smsCmdSetparamName,
  'lock' => l10n.smsCmdLockName,
  'unlock' => l10n.smsCmdUnlockName,
  'pulse' => l10n.smsCmdPulseName,
  'cpureset' => l10n.smsCmdRebootName,
  'deleterecords' => l10n.smsCmdClearName,
  _ => id,
};

/// Resolves the localized subtitle for an [SmsCommand.id] (may be empty).
String smsCommandSub(AppLocalizations l10n, String id) => switch (id) {
  'info' => l10n.smsCmdInfoSub,
  'gps' => l10n.smsCmdPositionSub,
  'io' => l10n.smsCmdIoSub,
  'status' => l10n.smsCmdStatusSub,
  'battery' => l10n.smsCmdBatterySub,
  'ver' => l10n.smsCmdFwSub,
  'lock' => l10n.smsCmdLockSub,
  'unlock' => l10n.smsCmdUnlockSub,
  'pulse' => l10n.smsCmdPulseSub,
  'cpureset' => l10n.smsCmdRebootSub,
  'deleterecords' => l10n.smsCmdClearSub,
  _ => '',
};

/// Resolves the localized input field label for an [SmsCommand.id] (or '' if
/// the command doesn't take input).
String smsInputLabel(AppLocalizations l10n, String id) => switch (id) {
  'sleep' => l10n.smsCmdSleepInputLabel,
  'interval' => l10n.smsCmdIntervalInputLabel,
  'getparam' => l10n.smsCmdGetparamInputLabel,
  'setparam' => l10n.smsCmdSetparamInputLabel,
  _ => '',
};

/// Returns the localized unit string for duration-typed inputs (or null).
String? smsInputUnit(AppLocalizations l10n, String id) => switch (id) {
  'interval' => l10n.smsUnitSeconds,
  _ => null,
};

/// Resolves the localized label for a stored command-value identifier: toggle
/// states ('true'/'false'), or any other free-form value (returned as-is).
String smsOptionLabel(AppLocalizations l10n, String optionId) =>
    switch (optionId) {
      'true' => l10n.composeToggleOn,
      'false' => l10n.composeToggleOff,
      _ => optionId,
    };
