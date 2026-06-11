// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Bariox Kontrol';

  @override
  String get tabBluetooth => 'Bluetooth';

  @override
  String get tabSms => 'SMS';

  @override
  String get tabSettings => 'Ayarlar';

  @override
  String get bluetoothTitle => 'Bluetooth';

  @override
  String get bluetoothConnected => 'Bağlı';

  @override
  String bluetoothOffTitle(String state) {
    return 'Bluetooth $state';
  }

  @override
  String get bluetoothOffMessage =>
      'Bir takip cihazına bağlanmak için Bluetooth\'u açın.';

  @override
  String bluetoothScanCountdown(int seconds) {
    return '${seconds}s';
  }

  @override
  String get bluetoothTapToScan => 'Taramak için dokunun';

  @override
  String bluetoothRssiDbm(int rssi) {
    return '$rssi dBm';
  }

  @override
  String get bleStatusSealed => 'Mühürlü';

  @override
  String get bleStatusOpen => 'Açık';

  @override
  String get bleStatusFetching => 'Alınıyor…';

  @override
  String get bleStatBattery => 'PİL';

  @override
  String get bleStatCover => 'KAPAK';

  @override
  String get bleStatUpdated => 'GÜNCELLEME';

  @override
  String get bleStatCoverOpen => 'Açık';

  @override
  String get bleStatCoverClosed => 'Kapalı';

  @override
  String get bleStatUpdatedJustNow => 'az önce';

  @override
  String get bleStatPending => '—';

  @override
  String get bleStatBusy => '…';

  @override
  String get bleSending => 'Gönderiliyor…';

  @override
  String get bleTapToRefresh => 'Yenilemek için dokunun';

  @override
  String get bleTapToUnlock => 'Açmak için dokunun';

  @override
  String get bleTapToLock => 'Kilitlemek için dokunun';

  @override
  String get bleCommandsHeader => 'BLUETOOTH KOMUTLARI';

  @override
  String get bleCmdUnlock => 'Kilidi aç';

  @override
  String get bleCmdUnlockSub => 'Ana kilidi aç';

  @override
  String get bleCmdLock => 'Kilitle';

  @override
  String get bleCmdLockSub => 'Ana kilidi mühürle';

  @override
  String get bleCmdRefresh => 'Durumu yenile';

  @override
  String get bleCmdRefreshSub => 'Pil, kapak ve kilit durumunu al';

  @override
  String get bleCmdDisconnect => 'Bağlantıyı kes';

  @override
  String get bleCmdDisconnectSub => 'BLE bağlantısını kapat';

  @override
  String get bleToastUnlocked => 'Kilit açıldı';

  @override
  String get bleToastLocked => 'Kilitlendi';

  @override
  String get bleToastStatusRefreshed => 'Durum yenilendi';

  @override
  String get smsHeader => 'SMS';

  @override
  String smsRecipientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count takip cihazı',
      one: '$count takip cihazı',
    );
    return '$_temp0';
  }

  @override
  String get smsToLabel => 'Kime:';

  @override
  String get smsAddRecipient => '+ Ekle';

  @override
  String smsOverflowCount(int count) {
    return '+$count';
  }

  @override
  String get smsEmptyTitle => 'Henüz mesaj yok';

  @override
  String get smsEmptySub => 'Başlamak için aşağıdan bir komut seçin';

  @override
  String get smsPickCommand => 'Göndermek için bir komut seçin';

  @override
  String smsSendFailed(String tracker) {
    return '$tracker cihazına gönderilemedi';
  }

  @override
  String smsBubbleYouTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cihaza',
      one: '$count cihaza',
    );
    return 'Sen · $_temp0';
  }

  @override
  String smsDateToday(String hour, String minute) {
    return 'BUGÜN $hour:$minute';
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
  String get trackerPickerTitle => 'Takip cihazı ekle';

  @override
  String trackerPickerDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cihaz',
      one: '$count cihaz',
    );
    return 'Tamam · $_temp0';
  }

  @override
  String get allRecipientsHeading => 'KİME';

  @override
  String allRecipientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cihaz',
      one: '$count cihaz',
    );
    return '$_temp0';
  }

  @override
  String get commandPickerHeading => 'KOMUT';

  @override
  String get commandPickerTitle => 'Birini seçin';

  @override
  String get commandGroupRead => 'OKU';

  @override
  String get commandGroupSet => 'AYARLA';

  @override
  String get commandGroupAction => 'EYLEM';

  @override
  String get commandGroupSetNeedsInput => '· giriş gerekli';

  @override
  String get commandPickerInputBadge => 'giriş';

  @override
  String get composeTagSet => 'AYARLA';

  @override
  String get composeTagAction => 'EYLEM';

  @override
  String get composeTagCommand => 'KOMUT';

  @override
  String composeDangerWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cihazdaki',
      one: '$count cihazdaki',
    );
    return 'Emin misiniz? Bu, $_temp0 her şeyi siler.';
  }

  @override
  String get composeNoParams => 'Parametre gerekmez.';

  @override
  String composeSendTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cihaza gönder',
      one: '$count cihaza gönder',
    );
    return '$_temp0';
  }

  @override
  String get composeToggleOn => 'Açık';

  @override
  String get composeToggleOff => 'Kapalı';

  @override
  String get smsCmdBatteryName => 'Pili al';

  @override
  String get smsCmdBatterySub => 'Pil seviyesi ve şarj';

  @override
  String get smsCmdStatusName => 'Kilit durumunu al';

  @override
  String get smsCmdStatusSub => 'Mühürlü · kapak · motor';

  @override
  String get smsCmdPositionName => 'Konumu al';

  @override
  String get smsCmdPositionSub => 'GPS koordinatları · hız';

  @override
  String get smsCmdRfidName => 'RFID kartları listele';

  @override
  String get smsCmdRfidSub => 'Tüm yetkili kartlar';

  @override
  String get smsCmdSubsName => 'Alt kilitleri listele';

  @override
  String get smsCmdSubsSub => 'Eşli alt kilitler ve durum';

  @override
  String get smsCmdFwName => 'Firmware sürümünü al';

  @override
  String get smsCmdFwSub => '';

  @override
  String get smsCmdSleepName => 'Uyku modunu ayarla';

  @override
  String get smsCmdSleepInputLabel => 'Uyku modu';

  @override
  String get smsCmdIntervalName => 'Konum aralığını ayarla';

  @override
  String get smsCmdIntervalInputLabel => 'Konumu her';

  @override
  String get smsCmdAutolockName => 'Otomatik kilit süresini ayarla';

  @override
  String get smsCmdAutolockInputLabel => 'Şu süreden sonra kilitle';

  @override
  String get smsCmdAddrfidName => 'RFID kart ekle';

  @override
  String get smsCmdAddrfidInputLabel => 'Kart numarası';

  @override
  String get smsCmdAddphoneName => 'Yetkili telefon ekle';

  @override
  String get smsCmdAddphoneInputLabel => 'Telefon numarası';

  @override
  String get smsCmdPwdName => 'Açma şifresini değiştir';

  @override
  String get smsCmdPwdInputLabel => 'Yeni 6 haneli şifre';

  @override
  String get smsCmdSensorName => 'Sensör hassasiyetini ayarla';

  @override
  String get smsCmdSensorInputLabel => 'Hassasiyet';

  @override
  String get smsCmdUnlockName => 'Kilidi aç';

  @override
  String get smsCmdUnlockSub => 'Ana kilidi aç';

  @override
  String get smsCmdLockName => 'Kilitle';

  @override
  String get smsCmdLockSub => 'Ana kilidi mühürle';

  @override
  String get smsCmdRebootName => 'Cihazı yeniden başlat';

  @override
  String get smsCmdRebootSub => '';

  @override
  String get smsCmdClearName => 'Konum önbelleğini temizle';

  @override
  String get smsCmdClearSub => '';

  @override
  String get smsCmdResetName => 'Fabrika ayarlarına dön';

  @override
  String get smsCmdResetSub => 'Her şeyi siler';

  @override
  String get smsUnitSeconds => 'saniye';

  @override
  String get sensorLow => 'Düşük';

  @override
  String get sensorMedium => 'Orta';

  @override
  String get sensorHigh => 'Yüksek';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsSectionApp => 'UYGULAMA';

  @override
  String get settingsSectionSims => 'SIM KARTLAR';

  @override
  String get settingsRowLanguage => 'Dil';

  @override
  String get settingsFooter => 'Bariox Kontrol · v1.0';

  @override
  String get simsNone => 'SIM kart bulunamadı';

  @override
  String get simsRefresh => 'Yenile';

  @override
  String simSlotLabel(int slot) {
    return 'Yuva $slot';
  }

  @override
  String simSubtitle(int slot, String country) {
    return 'Yuva $slot · $country';
  }

  @override
  String smsActiveSimChip(String carrier, int slot) {
    return '$carrier (Yuva $slot)';
  }

  @override
  String get smsNoSimChip => 'SIM yok';

  @override
  String get languagePickerTitle => 'Dil';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'İngilizce';
}
