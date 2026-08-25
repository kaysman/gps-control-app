import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GPS Control'**
  String get appTitle;

  /// No description provided for @tabBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get tabBluetooth;

  /// No description provided for @tabSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get tabSms;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @bluetoothOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is {state}'**
  String bluetoothOffTitle(String state);

  /// No description provided for @bluetoothOffMessage.
  ///
  /// In en, this message translates to:
  /// **'Turn Bluetooth on to connect to a tracker.'**
  String get bluetoothOffMessage;

  /// No description provided for @bluetoothScanCountdown.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String bluetoothScanCountdown(int seconds);

  /// No description provided for @bluetoothTapToScan.
  ///
  /// In en, this message translates to:
  /// **'Tap to scan'**
  String get bluetoothTapToScan;

  /// No description provided for @bluetoothRssiDbm.
  ///
  /// In en, this message translates to:
  /// **'{rssi} dBm'**
  String bluetoothRssiDbm(int rssi);

  /// No description provided for @bleStatusSealed.
  ///
  /// In en, this message translates to:
  /// **'Sealed'**
  String get bleStatusSealed;

  /// No description provided for @bleStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get bleStatusOpen;

  /// No description provided for @bleStatusFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching…'**
  String get bleStatusFetching;

  /// No description provided for @bleStatBattery.
  ///
  /// In en, this message translates to:
  /// **'BATTERY'**
  String get bleStatBattery;

  /// No description provided for @bleStatCover.
  ///
  /// In en, this message translates to:
  /// **'COVER'**
  String get bleStatCover;

  /// No description provided for @bleStatUpdated.
  ///
  /// In en, this message translates to:
  /// **'UPDATED'**
  String get bleStatUpdated;

  /// No description provided for @bleStatCoverOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get bleStatCoverOpen;

  /// No description provided for @bleStatCoverClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get bleStatCoverClosed;

  /// No description provided for @bleStatUpdatedJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get bleStatUpdatedJustNow;

  /// No description provided for @bleStatPending.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get bleStatPending;

  /// No description provided for @bleStatBusy.
  ///
  /// In en, this message translates to:
  /// **'…'**
  String get bleStatBusy;

  /// No description provided for @bleSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get bleSending;

  /// No description provided for @bleTapToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Tap to refresh'**
  String get bleTapToRefresh;

  /// No description provided for @bleTapToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Tap to unlock'**
  String get bleTapToUnlock;

  /// No description provided for @bleTapToLock.
  ///
  /// In en, this message translates to:
  /// **'Tap to lock'**
  String get bleTapToLock;

  /// No description provided for @bleCommandsHeader.
  ///
  /// In en, this message translates to:
  /// **'BLUETOOTH COMMANDS'**
  String get bleCommandsHeader;

  /// No description provided for @bleCmdUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get bleCmdUnlock;

  /// No description provided for @bleCmdUnlockSub.
  ///
  /// In en, this message translates to:
  /// **'Open the master lock'**
  String get bleCmdUnlockSub;

  /// No description provided for @bleCmdLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get bleCmdLock;

  /// No description provided for @bleCmdLockSub.
  ///
  /// In en, this message translates to:
  /// **'Seal the master lock'**
  String get bleCmdLockSub;

  /// No description provided for @bleCmdRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get bleCmdRefresh;

  /// No description provided for @bleCmdRefreshSub.
  ///
  /// In en, this message translates to:
  /// **'Get battery, cover & lock state'**
  String get bleCmdRefreshSub;

  /// No description provided for @bleCmdDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get bleCmdDisconnect;

  /// No description provided for @bleCmdDisconnectSub.
  ///
  /// In en, this message translates to:
  /// **'Close BLE connection'**
  String get bleCmdDisconnectSub;

  /// No description provided for @bleToastUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get bleToastUnlocked;

  /// No description provided for @bleToastLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get bleToastLocked;

  /// No description provided for @bleToastStatusRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Status refreshed'**
  String get bleToastStatusRefreshed;

  /// No description provided for @smsToLabel.
  ///
  /// In en, this message translates to:
  /// **'To:'**
  String get smsToLabel;

  /// No description provided for @smsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get smsEmptyTitle;

  /// No description provided for @smsEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Pick a command below to start'**
  String get smsEmptySub;

  /// No description provided for @smsPickCommand.
  ///
  /// In en, this message translates to:
  /// **'Pick a command to send'**
  String get smsPickCommand;

  /// No description provided for @smsSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send to {tracker}'**
  String smsSendFailed(String tracker);

  /// No description provided for @smsDateToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY {hour}:{minute}'**
  String smsDateToday(String hour, String minute);

  /// No description provided for @smsDateFull.
  ///
  /// In en, this message translates to:
  /// **'{day}/{month}/{year} {hour}:{minute}'**
  String smsDateFull(
    String day,
    String month,
    String year,
    String hour,
    String minute,
  );

  /// No description provided for @commandPickerHeading.
  ///
  /// In en, this message translates to:
  /// **'COMMAND'**
  String get commandPickerHeading;

  /// No description provided for @commandPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick one'**
  String get commandPickerTitle;

  /// No description provided for @commandGroupRead.
  ///
  /// In en, this message translates to:
  /// **'READ'**
  String get commandGroupRead;

  /// No description provided for @commandGroupSet.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get commandGroupSet;

  /// No description provided for @commandGroupAction.
  ///
  /// In en, this message translates to:
  /// **'ACTION'**
  String get commandGroupAction;

  /// No description provided for @commandGroupSetNeedsInput.
  ///
  /// In en, this message translates to:
  /// **'· needs input'**
  String get commandGroupSetNeedsInput;

  /// No description provided for @commandPickerInputBadge.
  ///
  /// In en, this message translates to:
  /// **'input'**
  String get commandPickerInputBadge;

  /// No description provided for @composeTagSet.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get composeTagSet;

  /// No description provided for @composeTagAction.
  ///
  /// In en, this message translates to:
  /// **'ACTION'**
  String get composeTagAction;

  /// No description provided for @composeTagCommand.
  ///
  /// In en, this message translates to:
  /// **'COMMAND'**
  String get composeTagCommand;

  /// No description provided for @composeDangerWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This erases everything on this tracker.'**
  String get composeDangerWarning;

  /// No description provided for @composeNoParams.
  ///
  /// In en, this message translates to:
  /// **'No parameters required.'**
  String get composeNoParams;

  /// No description provided for @composeToggleOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get composeToggleOn;

  /// No description provided for @composeToggleOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get composeToggleOff;

  /// No description provided for @smsCmdBatteryName.
  ///
  /// In en, this message translates to:
  /// **'Get battery'**
  String get smsCmdBatteryName;

  /// No description provided for @smsCmdBatterySub.
  ///
  /// In en, this message translates to:
  /// **'Battery level & charging'**
  String get smsCmdBatterySub;

  /// No description provided for @smsCmdStatusName.
  ///
  /// In en, this message translates to:
  /// **'Get lock status'**
  String get smsCmdStatusName;

  /// No description provided for @smsCmdStatusSub.
  ///
  /// In en, this message translates to:
  /// **'Sealed · cover · motor'**
  String get smsCmdStatusSub;

  /// No description provided for @smsCmdPositionName.
  ///
  /// In en, this message translates to:
  /// **'Get position'**
  String get smsCmdPositionName;

  /// No description provided for @smsCmdPositionSub.
  ///
  /// In en, this message translates to:
  /// **'GPS coordinates · speed'**
  String get smsCmdPositionSub;

  /// No description provided for @smsCmdRfidName.
  ///
  /// In en, this message translates to:
  /// **'List RFID cards'**
  String get smsCmdRfidName;

  /// No description provided for @smsCmdRfidSub.
  ///
  /// In en, this message translates to:
  /// **'All authorized cards'**
  String get smsCmdRfidSub;

  /// No description provided for @smsCmdSubsName.
  ///
  /// In en, this message translates to:
  /// **'List sub-locks'**
  String get smsCmdSubsName;

  /// No description provided for @smsCmdSubsSub.
  ///
  /// In en, this message translates to:
  /// **'Paired sub-locks & state'**
  String get smsCmdSubsSub;

  /// No description provided for @smsCmdFwName.
  ///
  /// In en, this message translates to:
  /// **'Get firmware version'**
  String get smsCmdFwName;

  /// No description provided for @smsCmdFwSub.
  ///
  /// In en, this message translates to:
  /// **''**
  String get smsCmdFwSub;

  /// No description provided for @smsCmdSleepName.
  ///
  /// In en, this message translates to:
  /// **'Set sleep mode'**
  String get smsCmdSleepName;

  /// No description provided for @smsCmdSleepInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep mode'**
  String get smsCmdSleepInputLabel;

  /// No description provided for @smsCmdIntervalName.
  ///
  /// In en, this message translates to:
  /// **'Set position interval'**
  String get smsCmdIntervalName;

  /// No description provided for @smsCmdIntervalInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Send position every'**
  String get smsCmdIntervalInputLabel;

  /// No description provided for @smsCmdAutolockName.
  ///
  /// In en, this message translates to:
  /// **'Set auto-lock time'**
  String get smsCmdAutolockName;

  /// No description provided for @smsCmdAutolockInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock after'**
  String get smsCmdAutolockInputLabel;

  /// No description provided for @smsCmdAddrfidName.
  ///
  /// In en, this message translates to:
  /// **'Add RFID card'**
  String get smsCmdAddrfidName;

  /// No description provided for @smsCmdAddrfidInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get smsCmdAddrfidInputLabel;

  /// No description provided for @smsCmdAddphoneName.
  ///
  /// In en, this message translates to:
  /// **'Add authorized phone'**
  String get smsCmdAddphoneName;

  /// No description provided for @smsCmdAddphoneInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get smsCmdAddphoneInputLabel;

  /// No description provided for @smsCmdPwdName.
  ///
  /// In en, this message translates to:
  /// **'Change unlock password'**
  String get smsCmdPwdName;

  /// No description provided for @smsCmdPwdInputLabel.
  ///
  /// In en, this message translates to:
  /// **'New 6-digit password'**
  String get smsCmdPwdInputLabel;

  /// No description provided for @smsCmdSensorName.
  ///
  /// In en, this message translates to:
  /// **'Set sensor sensitivity'**
  String get smsCmdSensorName;

  /// No description provided for @smsCmdSensorInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity'**
  String get smsCmdSensorInputLabel;

  /// No description provided for @smsCmdUnlockName.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get smsCmdUnlockName;

  /// No description provided for @smsCmdUnlockSub.
  ///
  /// In en, this message translates to:
  /// **'Open the master lock'**
  String get smsCmdUnlockSub;

  /// No description provided for @smsCmdLockName.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get smsCmdLockName;

  /// No description provided for @smsCmdLockSub.
  ///
  /// In en, this message translates to:
  /// **'Seal the master lock'**
  String get smsCmdLockSub;

  /// No description provided for @smsCmdRebootName.
  ///
  /// In en, this message translates to:
  /// **'Restart device'**
  String get smsCmdRebootName;

  /// No description provided for @smsCmdRebootSub.
  ///
  /// In en, this message translates to:
  /// **''**
  String get smsCmdRebootSub;

  /// No description provided for @smsCmdClearName.
  ///
  /// In en, this message translates to:
  /// **'Clear position cache'**
  String get smsCmdClearName;

  /// No description provided for @smsCmdClearSub.
  ///
  /// In en, this message translates to:
  /// **''**
  String get smsCmdClearSub;

  /// No description provided for @smsCmdResetName.
  ///
  /// In en, this message translates to:
  /// **'Factory reset'**
  String get smsCmdResetName;

  /// No description provided for @smsCmdResetSub.
  ///
  /// In en, this message translates to:
  /// **'Erases everything'**
  String get smsCmdResetSub;

  /// No description provided for @smsUnitSeconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get smsUnitSeconds;

  /// No description provided for @sensorLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get sensorLow;

  /// No description provided for @sensorMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get sensorMedium;

  /// No description provided for @sensorHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get sensorHigh;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionApp.
  ///
  /// In en, this message translates to:
  /// **'APP'**
  String get settingsSectionApp;

  /// No description provided for @settingsSectionDevice.
  ///
  /// In en, this message translates to:
  /// **'DEVICE'**
  String get settingsSectionDevice;

  /// No description provided for @settingsSectionSims.
  ///
  /// In en, this message translates to:
  /// **'SIM CARDS'**
  String get settingsSectionSims;

  /// No description provided for @settingsRowLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsRowLanguage;

  /// No description provided for @settingsRowBrand.
  ///
  /// In en, this message translates to:
  /// **'Tracker brand'**
  String get settingsRowBrand;

  /// No description provided for @settingsRowSim.
  ///
  /// In en, this message translates to:
  /// **'Active SIM'**
  String get settingsRowSim;

  /// No description provided for @brandPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracker brand'**
  String get brandPickerTitle;

  /// No description provided for @brandPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Which family of trackers this app talks to.'**
  String get brandPickerSubtitle;

  /// No description provided for @brandBariox.
  ///
  /// In en, this message translates to:
  /// **'Bariox'**
  String get brandBariox;

  /// No description provided for @brandBarioxSub.
  ///
  /// In en, this message translates to:
  /// **'BLE and SMS · full command set'**
  String get brandBarioxSub;

  /// No description provided for @brandTeltonika.
  ///
  /// In en, this message translates to:
  /// **'Teltonika'**
  String get brandTeltonika;

  /// No description provided for @brandTeltonikaSub.
  ///
  /// In en, this message translates to:
  /// **'SMS only · FMB series'**
  String get brandTeltonikaSub;

  /// No description provided for @simsNone.
  ///
  /// In en, this message translates to:
  /// **'No SIM cards detected'**
  String get simsNone;

  /// No description provided for @simsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get simsRefresh;

  /// No description provided for @simRowNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get simRowNone;

  /// No description provided for @simPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Active SIM'**
  String get simPickerTitle;

  /// No description provided for @simPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Outgoing commands are sent from this SIM.'**
  String get simPickerSubtitle;

  /// No description provided for @simSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Slot {slot} · {country}'**
  String simSubtitle(int slot, String country);

  /// No description provided for @smsActiveSimChip.
  ///
  /// In en, this message translates to:
  /// **'{carrier} (Slot {slot})'**
  String smsActiveSimChip(String carrier, int slot);

  /// No description provided for @smsThreadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get smsThreadsTitle;

  /// No description provided for @smsThreadYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get smsThreadYou;

  /// No description provided for @smsThreadEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get smsThreadEmpty;

  /// No description provided for @smsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search trackers'**
  String get smsSearchHint;

  /// No description provided for @smsSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tracker matches that'**
  String get smsSearchEmpty;

  /// No description provided for @smsNoSimChip.
  ///
  /// In en, this message translates to:
  /// **'No SIM'**
  String get smsNoSimChip;

  /// No description provided for @smsPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracker password'**
  String get smsPasswordTitle;

  /// No description provided for @smsPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sent with every command to this tracker.'**
  String get smsPasswordSubtitle;

  /// No description provided for @composeSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get composeSend;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePickerTitle;

  /// No description provided for @languagePickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Applies everywhere in the app.'**
  String get languagePickerSubtitle;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
