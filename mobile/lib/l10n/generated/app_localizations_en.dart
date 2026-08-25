// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GPS Control';

  @override
  String get tabBluetooth => 'Bluetooth';

  @override
  String get tabSms => 'SMS';

  @override
  String get tabSettings => 'Settings';

  @override
  String bluetoothOffTitle(String state) {
    return 'Bluetooth is $state';
  }

  @override
  String get bluetoothOffMessage =>
      'Turn Bluetooth on to connect to a tracker.';

  @override
  String bluetoothScanCountdown(int seconds) {
    return '${seconds}s';
  }

  @override
  String get bluetoothTapToScan => 'Tap to scan';

  @override
  String bluetoothRssiDbm(int rssi) {
    return '$rssi dBm';
  }

  @override
  String get bleStatusSealed => 'Sealed';

  @override
  String get bleStatusOpen => 'Open';

  @override
  String get bleStatusFetching => 'Fetching…';

  @override
  String get bleStatBattery => 'BATTERY';

  @override
  String get bleStatCover => 'COVER';

  @override
  String get bleStatUpdated => 'UPDATED';

  @override
  String get bleStatCoverOpen => 'Open';

  @override
  String get bleStatCoverClosed => 'Closed';

  @override
  String get bleStatUpdatedJustNow => 'just now';

  @override
  String get bleStatPending => '—';

  @override
  String get bleStatBusy => '…';

  @override
  String get bleSending => 'Sending…';

  @override
  String get bleTapToRefresh => 'Tap to refresh';

  @override
  String get bleTapToUnlock => 'Tap to unlock';

  @override
  String get bleTapToLock => 'Tap to lock';

  @override
  String get bleCommandsHeader => 'BLUETOOTH COMMANDS';

  @override
  String get bleCmdUnlock => 'Unlock';

  @override
  String get bleCmdUnlockSub => 'Open the master lock';

  @override
  String get bleCmdLock => 'Lock';

  @override
  String get bleCmdLockSub => 'Seal the master lock';

  @override
  String get bleCmdRefresh => 'Refresh status';

  @override
  String get bleCmdRefreshSub => 'Get battery, cover & lock state';

  @override
  String get bleCmdDisconnect => 'Disconnect';

  @override
  String get bleCmdDisconnectSub => 'Close BLE connection';

  @override
  String get bleToastUnlocked => 'Unlocked';

  @override
  String get bleToastLocked => 'Locked';

  @override
  String get bleToastStatusRefreshed => 'Status refreshed';

  @override
  String get smsToLabel => 'To:';

  @override
  String get smsEmptyTitle => 'No messages yet';

  @override
  String get smsEmptySub => 'Pick a command below to start';

  @override
  String get smsPickCommand => 'Pick a command to send';

  @override
  String smsSendFailed(String tracker) {
    return 'Failed to send to $tracker';
  }

  @override
  String smsDateToday(String hour, String minute) {
    return 'TODAY $hour:$minute';
  }

  @override
  String smsDateFull(
    String day,
    String month,
    String year,
    String hour,
    String minute,
  ) {
    return '$day/$month/$year $hour:$minute';
  }

  @override
  String get commandPickerHeading => 'COMMAND';

  @override
  String get commandPickerTitle => 'Pick one';

  @override
  String get commandGroupRead => 'READ';

  @override
  String get commandGroupSet => 'SET';

  @override
  String get commandGroupAction => 'ACTION';

  @override
  String get commandGroupSetNeedsInput => '· needs input';

  @override
  String get commandPickerInputBadge => 'input';

  @override
  String get composeTagSet => 'SET';

  @override
  String get composeTagAction => 'ACTION';

  @override
  String get composeTagCommand => 'COMMAND';

  @override
  String get composeDangerWarning =>
      'Are you sure? This erases everything on this tracker.';

  @override
  String get composeNoParams => 'No parameters required.';

  @override
  String get composeToggleOn => 'On';

  @override
  String get composeToggleOff => 'Off';

  @override
  String get smsCmdBatteryName => 'Get battery';

  @override
  String get smsCmdBatterySub => 'Battery level & charging';

  @override
  String get smsCmdStatusName => 'Get lock status';

  @override
  String get smsCmdStatusSub => 'Sealed · cover · motor';

  @override
  String get smsCmdPositionName => 'Get position';

  @override
  String get smsCmdPositionSub => 'GPS coordinates · speed';

  @override
  String get smsCmdRfidName => 'List RFID cards';

  @override
  String get smsCmdRfidSub => 'All authorized cards';

  @override
  String get smsCmdSubsName => 'List sub-locks';

  @override
  String get smsCmdSubsSub => 'Paired sub-locks & state';

  @override
  String get smsCmdFwName => 'Get firmware version';

  @override
  String get smsCmdFwSub => '';

  @override
  String get smsCmdSleepName => 'Set sleep mode';

  @override
  String get smsCmdSleepInputLabel => 'Sleep mode';

  @override
  String get smsCmdIntervalName => 'Set position interval';

  @override
  String get smsCmdIntervalInputLabel => 'Send position every';

  @override
  String get smsCmdAutolockName => 'Set auto-lock time';

  @override
  String get smsCmdAutolockInputLabel => 'Auto-lock after';

  @override
  String get smsCmdAddrfidName => 'Add RFID card';

  @override
  String get smsCmdAddrfidInputLabel => 'Card number';

  @override
  String get smsCmdAddphoneName => 'Add authorized phone';

  @override
  String get smsCmdAddphoneInputLabel => 'Phone number';

  @override
  String get smsCmdPwdName => 'Change unlock password';

  @override
  String get smsCmdPwdInputLabel => 'New 6-digit password';

  @override
  String get smsCmdSensorName => 'Set sensor sensitivity';

  @override
  String get smsCmdSensorInputLabel => 'Sensitivity';

  @override
  String get smsCmdUnlockName => 'Unlock';

  @override
  String get smsCmdUnlockSub => 'Open the master lock';

  @override
  String get smsCmdLockName => 'Lock';

  @override
  String get smsCmdLockSub => 'Seal the master lock';

  @override
  String get smsCmdRebootName => 'Restart device';

  @override
  String get smsCmdRebootSub => '';

  @override
  String get smsCmdClearName => 'Clear position cache';

  @override
  String get smsCmdClearSub => '';

  @override
  String get smsCmdResetName => 'Factory reset';

  @override
  String get smsCmdResetSub => 'Erases everything';

  @override
  String get smsUnitSeconds => 'seconds';

  @override
  String get sensorLow => 'Low';

  @override
  String get sensorMedium => 'Medium';

  @override
  String get sensorHigh => 'High';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionApp => 'APP';

  @override
  String get settingsSectionDevice => 'DEVICE';

  @override
  String get settingsSectionSims => 'SIM CARDS';

  @override
  String get settingsRowLanguage => 'Language';

  @override
  String get settingsRowBrand => 'Tracker brand';

  @override
  String get settingsRowSim => 'Active SIM';

  @override
  String get brandPickerTitle => 'Tracker brand';

  @override
  String get brandPickerSubtitle =>
      'Which family of trackers this app talks to.';

  @override
  String get brandBariox => 'Bariox';

  @override
  String get brandBarioxSub => 'BLE and SMS · full command set';

  @override
  String get brandTeltonika => 'Teltonika';

  @override
  String get brandTeltonikaSub => 'SMS only · FMB series';

  @override
  String get simsNone => 'No SIM cards detected';

  @override
  String get simsRefresh => 'Refresh';

  @override
  String get simRowNone => 'None';

  @override
  String get simPickerTitle => 'Active SIM';

  @override
  String get simPickerSubtitle => 'Outgoing commands are sent from this SIM.';

  @override
  String simSubtitle(int slot, String country) {
    return 'Slot $slot · $country';
  }

  @override
  String smsActiveSimChip(String carrier, int slot) {
    return '$carrier (Slot $slot)';
  }

  @override
  String get smsThreadsTitle => 'Messages';

  @override
  String get smsThreadYou => 'You';

  @override
  String get smsThreadEmpty => 'No messages yet';

  @override
  String get smsSearchHint => 'Search trackers';

  @override
  String get smsSearchEmpty => 'No tracker matches that';

  @override
  String get smsNoSimChip => 'No SIM';

  @override
  String get smsPasswordTitle => 'Tracker password';

  @override
  String get smsPasswordSubtitle => 'Sent with every command to this tracker.';

  @override
  String get composeSend => 'Send';

  @override
  String get languagePickerTitle => 'Language';

  @override
  String get languagePickerSubtitle => 'Applies everywhere in the app.';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get languageEnglish => 'English';
}
