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
  /// In tr, this message translates to:
  /// **'Bariox Kontrol'**
  String get appTitle;

  /// No description provided for @tabBluetooth.
  ///
  /// In tr, this message translates to:
  /// **'Bluetooth'**
  String get tabBluetooth;

  /// No description provided for @tabSms.
  ///
  /// In tr, this message translates to:
  /// **'SMS'**
  String get tabSms;

  /// No description provided for @tabSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get tabSettings;

  /// No description provided for @bluetoothTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bluetooth'**
  String get bluetoothTitle;

  /// No description provided for @bluetoothConnected.
  ///
  /// In tr, this message translates to:
  /// **'Bağlı'**
  String get bluetoothConnected;

  /// No description provided for @bluetoothOffTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bluetooth {state}'**
  String bluetoothOffTitle(String state);

  /// No description provided for @bluetoothOffMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bir takip cihazına bağlanmak için Bluetooth\'u açın.'**
  String get bluetoothOffMessage;

  /// No description provided for @bluetoothScanCountdown.
  ///
  /// In tr, this message translates to:
  /// **'{seconds}s'**
  String bluetoothScanCountdown(int seconds);

  /// No description provided for @bluetoothTapToScan.
  ///
  /// In tr, this message translates to:
  /// **'Taramak için dokunun'**
  String get bluetoothTapToScan;

  /// No description provided for @bluetoothRssiDbm.
  ///
  /// In tr, this message translates to:
  /// **'{rssi} dBm'**
  String bluetoothRssiDbm(int rssi);

  /// No description provided for @bleStatusSealed.
  ///
  /// In tr, this message translates to:
  /// **'Mühürlü'**
  String get bleStatusSealed;

  /// No description provided for @bleStatusOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get bleStatusOpen;

  /// No description provided for @bleStatusFetching.
  ///
  /// In tr, this message translates to:
  /// **'Alınıyor…'**
  String get bleStatusFetching;

  /// No description provided for @bleStatBattery.
  ///
  /// In tr, this message translates to:
  /// **'PİL'**
  String get bleStatBattery;

  /// No description provided for @bleStatCover.
  ///
  /// In tr, this message translates to:
  /// **'KAPAK'**
  String get bleStatCover;

  /// No description provided for @bleStatUpdated.
  ///
  /// In tr, this message translates to:
  /// **'GÜNCELLEME'**
  String get bleStatUpdated;

  /// No description provided for @bleStatCoverOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get bleStatCoverOpen;

  /// No description provided for @bleStatCoverClosed.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get bleStatCoverClosed;

  /// No description provided for @bleStatUpdatedJustNow.
  ///
  /// In tr, this message translates to:
  /// **'az önce'**
  String get bleStatUpdatedJustNow;

  /// No description provided for @bleStatPending.
  ///
  /// In tr, this message translates to:
  /// **'—'**
  String get bleStatPending;

  /// No description provided for @bleStatBusy.
  ///
  /// In tr, this message translates to:
  /// **'…'**
  String get bleStatBusy;

  /// No description provided for @bleSending.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiliyor…'**
  String get bleSending;

  /// No description provided for @bleTapToRefresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenilemek için dokunun'**
  String get bleTapToRefresh;

  /// No description provided for @bleTapToUnlock.
  ///
  /// In tr, this message translates to:
  /// **'Açmak için dokunun'**
  String get bleTapToUnlock;

  /// No description provided for @bleTapToLock.
  ///
  /// In tr, this message translates to:
  /// **'Kilitlemek için dokunun'**
  String get bleTapToLock;

  /// No description provided for @bleCommandsHeader.
  ///
  /// In tr, this message translates to:
  /// **'BLUETOOTH KOMUTLARI'**
  String get bleCommandsHeader;

  /// No description provided for @bleCmdUnlock.
  ///
  /// In tr, this message translates to:
  /// **'Kilidi aç'**
  String get bleCmdUnlock;

  /// No description provided for @bleCmdUnlockSub.
  ///
  /// In tr, this message translates to:
  /// **'Ana kilidi aç'**
  String get bleCmdUnlockSub;

  /// No description provided for @bleCmdLock.
  ///
  /// In tr, this message translates to:
  /// **'Kilitle'**
  String get bleCmdLock;

  /// No description provided for @bleCmdLockSub.
  ///
  /// In tr, this message translates to:
  /// **'Ana kilidi mühürle'**
  String get bleCmdLockSub;

  /// No description provided for @bleCmdRefresh.
  ///
  /// In tr, this message translates to:
  /// **'Durumu yenile'**
  String get bleCmdRefresh;

  /// No description provided for @bleCmdRefreshSub.
  ///
  /// In tr, this message translates to:
  /// **'Pil, kapak ve kilit durumunu al'**
  String get bleCmdRefreshSub;

  /// No description provided for @bleCmdDisconnect.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı kes'**
  String get bleCmdDisconnect;

  /// No description provided for @bleCmdDisconnectSub.
  ///
  /// In tr, this message translates to:
  /// **'BLE bağlantısını kapat'**
  String get bleCmdDisconnectSub;

  /// No description provided for @bleToastUnlocked.
  ///
  /// In tr, this message translates to:
  /// **'Kilit açıldı'**
  String get bleToastUnlocked;

  /// No description provided for @bleToastLocked.
  ///
  /// In tr, this message translates to:
  /// **'Kilitlendi'**
  String get bleToastLocked;

  /// No description provided for @bleToastStatusRefreshed.
  ///
  /// In tr, this message translates to:
  /// **'Durum yenilendi'**
  String get bleToastStatusRefreshed;

  /// No description provided for @smsHeader.
  ///
  /// In tr, this message translates to:
  /// **'SMS'**
  String get smsHeader;

  /// No description provided for @smsRecipientCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{{count} takip cihazı} other{{count} takip cihazı}}'**
  String smsRecipientCount(int count);

  /// No description provided for @smsToLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kime:'**
  String get smsToLabel;

  /// No description provided for @smsAddRecipient.
  ///
  /// In tr, this message translates to:
  /// **'+ Ekle'**
  String get smsAddRecipient;

  /// No description provided for @smsOverflowCount.
  ///
  /// In tr, this message translates to:
  /// **'+{count}'**
  String smsOverflowCount(int count);

  /// No description provided for @smsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz mesaj yok'**
  String get smsEmptyTitle;

  /// No description provided for @smsEmptySub.
  ///
  /// In tr, this message translates to:
  /// **'Başlamak için aşağıdan bir komut seçin'**
  String get smsEmptySub;

  /// No description provided for @smsPickCommand.
  ///
  /// In tr, this message translates to:
  /// **'Göndermek için bir komut seçin'**
  String get smsPickCommand;

  /// No description provided for @smsSendFailed.
  ///
  /// In tr, this message translates to:
  /// **'{tracker} cihazına gönderilemedi'**
  String smsSendFailed(String tracker);

  /// No description provided for @smsBubbleYouTo.
  ///
  /// In tr, this message translates to:
  /// **'Sen · {count, plural, =1{{count} cihaza} other{{count} cihaza}}'**
  String smsBubbleYouTo(int count);

  /// No description provided for @smsDateToday.
  ///
  /// In tr, this message translates to:
  /// **'BUGÜN {hour}:{minute}'**
  String smsDateToday(String hour, String minute);

  /// No description provided for @smsDateFull.
  ///
  /// In tr, this message translates to:
  /// **'{day}/{month}/{year} {hour}:{minute}'**
  String smsDateFull(
    String day,
    String month,
    String year,
    String hour,
    String minute,
  );

  /// No description provided for @trackerPickerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Takip cihazı ekle'**
  String get trackerPickerTitle;

  /// No description provided for @trackerPickerDone.
  ///
  /// In tr, this message translates to:
  /// **'Tamam · {count, plural, =1{{count} cihaz} other{{count} cihaz}}'**
  String trackerPickerDone(int count);

  /// No description provided for @allRecipientsHeading.
  ///
  /// In tr, this message translates to:
  /// **'KİME'**
  String get allRecipientsHeading;

  /// No description provided for @allRecipientsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{{count} cihaz} other{{count} cihaz}}'**
  String allRecipientsCount(int count);

  /// No description provided for @commandPickerHeading.
  ///
  /// In tr, this message translates to:
  /// **'KOMUT'**
  String get commandPickerHeading;

  /// No description provided for @commandPickerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Birini seçin'**
  String get commandPickerTitle;

  /// No description provided for @commandGroupRead.
  ///
  /// In tr, this message translates to:
  /// **'OKU'**
  String get commandGroupRead;

  /// No description provided for @commandGroupSet.
  ///
  /// In tr, this message translates to:
  /// **'AYARLA'**
  String get commandGroupSet;

  /// No description provided for @commandGroupAction.
  ///
  /// In tr, this message translates to:
  /// **'EYLEM'**
  String get commandGroupAction;

  /// No description provided for @commandGroupSetNeedsInput.
  ///
  /// In tr, this message translates to:
  /// **'· giriş gerekli'**
  String get commandGroupSetNeedsInput;

  /// No description provided for @commandPickerInputBadge.
  ///
  /// In tr, this message translates to:
  /// **'giriş'**
  String get commandPickerInputBadge;

  /// No description provided for @composeTagSet.
  ///
  /// In tr, this message translates to:
  /// **'AYARLA'**
  String get composeTagSet;

  /// No description provided for @composeTagAction.
  ///
  /// In tr, this message translates to:
  /// **'EYLEM'**
  String get composeTagAction;

  /// No description provided for @composeTagCommand.
  ///
  /// In tr, this message translates to:
  /// **'KOMUT'**
  String get composeTagCommand;

  /// No description provided for @composeDangerWarning.
  ///
  /// In tr, this message translates to:
  /// **'Emin misiniz? Bu, {count, plural, =1{{count} cihazdaki} other{{count} cihazdaki}} her şeyi siler.'**
  String composeDangerWarning(int count);

  /// No description provided for @composeNoParams.
  ///
  /// In tr, this message translates to:
  /// **'Parametre gerekmez.'**
  String get composeNoParams;

  /// No description provided for @composeSendTo.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{{count} cihaza gönder} other{{count} cihaza gönder}}'**
  String composeSendTo(int count);

  /// No description provided for @composeToggleOn.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get composeToggleOn;

  /// No description provided for @composeToggleOff.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get composeToggleOff;

  /// No description provided for @smsCmdBatteryName.
  ///
  /// In tr, this message translates to:
  /// **'Pili al'**
  String get smsCmdBatteryName;

  /// No description provided for @smsCmdBatterySub.
  ///
  /// In tr, this message translates to:
  /// **'Pil seviyesi ve şarj'**
  String get smsCmdBatterySub;

  /// No description provided for @smsCmdStatusName.
  ///
  /// In tr, this message translates to:
  /// **'Kilit durumunu al'**
  String get smsCmdStatusName;

  /// No description provided for @smsCmdStatusSub.
  ///
  /// In tr, this message translates to:
  /// **'Mühürlü · kapak · motor'**
  String get smsCmdStatusSub;

  /// No description provided for @smsCmdPositionName.
  ///
  /// In tr, this message translates to:
  /// **'Konumu al'**
  String get smsCmdPositionName;

  /// No description provided for @smsCmdPositionSub.
  ///
  /// In tr, this message translates to:
  /// **'GPS koordinatları · hız'**
  String get smsCmdPositionSub;

  /// No description provided for @smsCmdRfidName.
  ///
  /// In tr, this message translates to:
  /// **'RFID kartları listele'**
  String get smsCmdRfidName;

  /// No description provided for @smsCmdRfidSub.
  ///
  /// In tr, this message translates to:
  /// **'Tüm yetkili kartlar'**
  String get smsCmdRfidSub;

  /// No description provided for @smsCmdSubsName.
  ///
  /// In tr, this message translates to:
  /// **'Alt kilitleri listele'**
  String get smsCmdSubsName;

  /// No description provided for @smsCmdSubsSub.
  ///
  /// In tr, this message translates to:
  /// **'Eşli alt kilitler ve durum'**
  String get smsCmdSubsSub;

  /// No description provided for @smsCmdFwName.
  ///
  /// In tr, this message translates to:
  /// **'Firmware sürümünü al'**
  String get smsCmdFwName;

  /// No description provided for @smsCmdFwSub.
  ///
  /// In tr, this message translates to:
  /// **''**
  String get smsCmdFwSub;

  /// No description provided for @smsCmdSleepName.
  ///
  /// In tr, this message translates to:
  /// **'Uyku modunu ayarla'**
  String get smsCmdSleepName;

  /// No description provided for @smsCmdSleepInputLabel.
  ///
  /// In tr, this message translates to:
  /// **'Uyku modu'**
  String get smsCmdSleepInputLabel;

  /// No description provided for @smsCmdIntervalName.
  ///
  /// In tr, this message translates to:
  /// **'Konum aralığını ayarla'**
  String get smsCmdIntervalName;

  /// No description provided for @smsCmdIntervalInputLabel.
  ///
  /// In tr, this message translates to:
  /// **'Konumu her'**
  String get smsCmdIntervalInputLabel;

  /// No description provided for @smsCmdAutolockName.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik kilit süresini ayarla'**
  String get smsCmdAutolockName;

  /// No description provided for @smsCmdAutolockInputLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şu süreden sonra kilitle'**
  String get smsCmdAutolockInputLabel;

  /// No description provided for @smsCmdAddrfidName.
  ///
  /// In tr, this message translates to:
  /// **'RFID kart ekle'**
  String get smsCmdAddrfidName;

  /// No description provided for @smsCmdAddrfidInputLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kart numarası'**
  String get smsCmdAddrfidInputLabel;

  /// No description provided for @smsCmdAddphoneName.
  ///
  /// In tr, this message translates to:
  /// **'Yetkili telefon ekle'**
  String get smsCmdAddphoneName;

  /// No description provided for @smsCmdAddphoneInputLabel.
  ///
  /// In tr, this message translates to:
  /// **'Telefon numarası'**
  String get smsCmdAddphoneInputLabel;

  /// No description provided for @smsCmdPwdName.
  ///
  /// In tr, this message translates to:
  /// **'Açma şifresini değiştir'**
  String get smsCmdPwdName;

  /// No description provided for @smsCmdPwdInputLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yeni 6 haneli şifre'**
  String get smsCmdPwdInputLabel;

  /// No description provided for @smsCmdSensorName.
  ///
  /// In tr, this message translates to:
  /// **'Sensör hassasiyetini ayarla'**
  String get smsCmdSensorName;

  /// No description provided for @smsCmdSensorInputLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hassasiyet'**
  String get smsCmdSensorInputLabel;

  /// No description provided for @smsCmdUnlockName.
  ///
  /// In tr, this message translates to:
  /// **'Kilidi aç'**
  String get smsCmdUnlockName;

  /// No description provided for @smsCmdUnlockSub.
  ///
  /// In tr, this message translates to:
  /// **'Ana kilidi aç'**
  String get smsCmdUnlockSub;

  /// No description provided for @smsCmdLockName.
  ///
  /// In tr, this message translates to:
  /// **'Kilitle'**
  String get smsCmdLockName;

  /// No description provided for @smsCmdLockSub.
  ///
  /// In tr, this message translates to:
  /// **'Ana kilidi mühürle'**
  String get smsCmdLockSub;

  /// No description provided for @smsCmdRebootName.
  ///
  /// In tr, this message translates to:
  /// **'Cihazı yeniden başlat'**
  String get smsCmdRebootName;

  /// No description provided for @smsCmdRebootSub.
  ///
  /// In tr, this message translates to:
  /// **''**
  String get smsCmdRebootSub;

  /// No description provided for @smsCmdClearName.
  ///
  /// In tr, this message translates to:
  /// **'Konum önbelleğini temizle'**
  String get smsCmdClearName;

  /// No description provided for @smsCmdClearSub.
  ///
  /// In tr, this message translates to:
  /// **''**
  String get smsCmdClearSub;

  /// No description provided for @smsCmdResetName.
  ///
  /// In tr, this message translates to:
  /// **'Fabrika ayarlarına dön'**
  String get smsCmdResetName;

  /// No description provided for @smsCmdResetSub.
  ///
  /// In tr, this message translates to:
  /// **'Her şeyi siler'**
  String get smsCmdResetSub;

  /// No description provided for @smsUnitSeconds.
  ///
  /// In tr, this message translates to:
  /// **'saniye'**
  String get smsUnitSeconds;

  /// No description provided for @sensorLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get sensorLow;

  /// No description provided for @sensorMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get sensorMedium;

  /// No description provided for @sensorHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get sensorHigh;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsSectionApp.
  ///
  /// In tr, this message translates to:
  /// **'UYGULAMA'**
  String get settingsSectionApp;

  /// No description provided for @settingsSectionSims.
  ///
  /// In tr, this message translates to:
  /// **'SIM KARTLAR'**
  String get settingsSectionSims;

  /// No description provided for @settingsRowLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsRowLanguage;

  /// No description provided for @settingsFooter.
  ///
  /// In tr, this message translates to:
  /// **'Bariox Kontrol · v1.0'**
  String get settingsFooter;

  /// No description provided for @simsNone.
  ///
  /// In tr, this message translates to:
  /// **'SIM kart bulunamadı'**
  String get simsNone;

  /// No description provided for @simsRefresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get simsRefresh;

  /// No description provided for @simSlotLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yuva {slot}'**
  String simSlotLabel(int slot);

  /// No description provided for @simSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yuva {slot} · {country}'**
  String simSubtitle(int slot, String country);

  /// No description provided for @smsActiveSimChip.
  ///
  /// In tr, this message translates to:
  /// **'{carrier} (Yuva {slot})'**
  String smsActiveSimChip(String carrier, int slot);

  /// No description provided for @smsNoSimChip.
  ///
  /// In tr, this message translates to:
  /// **'SIM yok'**
  String get smsNoSimChip;

  /// No description provided for @languagePickerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get languagePickerTitle;

  /// No description provided for @languageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
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
