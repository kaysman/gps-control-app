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
  String get smsCmdBatteryName => 'Battery voltage';

  @override
  String get smsCmdBatterySub => 'Internal battery, AVL ID 67';

  @override
  String get smsCmdStatusName => 'Modem status';

  @override
  String get smsCmdStatusSub => 'GPRS · signal · SIM · cell';

  @override
  String get smsCmdPositionName => 'GPS position';

  @override
  String get smsCmdPositionSub => 'Coordinates · satellites · speed';

  @override
  String get smsCmdFwName => 'Firmware version';

  @override
  String get smsCmdFwSub => 'Firmware · GPS · hardware · IMEI';

  @override
  String get smsCmdSleepName => 'Sleep mode';

  @override
  String get smsCmdSleepInputLabel => 'GPS sleep (parameter 102)';

  @override
  String get smsCmdIntervalName => 'Tracking period';

  @override
  String get smsCmdIntervalInputLabel => 'Record while moving every';

  @override
  String get smsCmdUnlockName => 'Unlock';

  @override
  String get smsCmdUnlockSub => 'Pull DOUT1 low';

  @override
  String get smsCmdLockName => 'Lock';

  @override
  String get smsCmdLockSub => 'Hold DOUT1 high';

  @override
  String get smsCmdRebootName => 'Restart device';

  @override
  String get smsCmdRebootSub => 'CPU reset';

  @override
  String get smsCmdClearName => 'Delete records';

  @override
  String get smsCmdClearSub => 'Erases every record still on the device';

  @override
  String get smsCmdInfoName => 'Device info';

  @override
  String get smsCmdInfoSub => 'Uptime · errors · GPS fix · records';

  @override
  String get smsCmdIoName => 'I/O readings';

  @override
  String get smsCmdIoSub => 'Digital inputs and outputs';

  @override
  String get smsCmdGetparamName => 'Read parameter';

  @override
  String get smsCmdGetparamInputLabel => 'Parameter ID';

  @override
  String get smsCmdSetparamName => 'Set parameter';

  @override
  String get smsCmdSetparamInputLabel => 'ID:value';

  @override
  String get smsCmdPulseName => 'Pulse output';

  @override
  String get smsCmdPulseSub => 'DOUT1 high for 5 seconds';

  @override
  String get smsUnitSeconds => 'seconds';

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
  String get brandBarioxSub => 'BLE · master locks and sub-locks';

  @override
  String get brandTeltonika => 'Teltonika';

  @override
  String get brandTeltonikaSub => 'SMS · FMB series';

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
  String get smsPasswordNone => 'Not set';

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
