// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'GPS Control';

  @override
  String get tabBluetooth => 'Bluetooth';

  @override
  String get tabSms => 'SMS';

  @override
  String get tabSettings => 'Ayarlar';

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
  String get smsToLabel => 'Kime:';

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
  String get composeDangerWarning =>
      'Emin misiniz? Bu cihazdaki her şeyi siler.';

  @override
  String get composeNoParams => 'Parametre gerekmez.';

  @override
  String get composeToggleOn => 'Açık';

  @override
  String get composeToggleOff => 'Kapalı';

  @override
  String get smsCmdBatteryName => 'Pil voltajı';

  @override
  String get smsCmdBatterySub => 'Dahili pil, AVL ID 67';

  @override
  String get smsCmdStatusName => 'Modem durumu';

  @override
  String get smsCmdStatusSub => 'GPRS · sinyal · SIM · hücre';

  @override
  String get smsCmdPositionName => 'GPS konumu';

  @override
  String get smsCmdPositionSub => 'Koordinatlar · uydular · hız';

  @override
  String get smsCmdFwName => 'Firmware sürümü';

  @override
  String get smsCmdFwSub => 'Firmware · GPS · donanım · IMEI';

  @override
  String get smsCmdSleepName => 'Uyku modu';

  @override
  String get smsCmdSleepInputLabel => 'GPS uykusu (parametre 102)';

  @override
  String get smsCmdIntervalName => 'Takip aralığı';

  @override
  String get smsCmdIntervalInputLabel => 'Hareket hâlinde kayıt aralığı';

  @override
  String get smsCmdUnlockName => 'Kilidi aç';

  @override
  String get smsCmdUnlockSub => 'DOUT1\'i düşür';

  @override
  String get smsCmdLockName => 'Kilitle';

  @override
  String get smsCmdLockSub => 'DOUT1\'i yüksek tut';

  @override
  String get smsCmdRebootName => 'Cihazı yeniden başlat';

  @override
  String get smsCmdRebootSub => 'CPU sıfırlama';

  @override
  String get smsCmdClearName => 'Kayıtları sil';

  @override
  String get smsCmdClearSub => 'Cihazdaki tüm kayıtları siler';

  @override
  String get smsCmdInfoName => 'Cihaz bilgisi';

  @override
  String get smsCmdInfoSub => 'Çalışma süresi · hatalar · GPS · kayıtlar';

  @override
  String get smsCmdIoName => 'Giriş/çıkış değerleri';

  @override
  String get smsCmdIoSub => 'Dijital girişler ve çıkışlar';

  @override
  String get smsCmdGetparamName => 'Parametre oku';

  @override
  String get smsCmdGetparamInputLabel => 'Parametre ID';

  @override
  String get smsCmdSetparamName => 'Parametre ayarla';

  @override
  String get smsCmdSetparamInputLabel => 'ID:değer';

  @override
  String get smsCmdPulseName => 'Çıkışı darbele';

  @override
  String get smsCmdPulseSub => 'DOUT1 5 saniye yüksek';

  @override
  String get smsUnitSeconds => 'saniye';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsSectionApp => 'UYGULAMA';

  @override
  String get settingsSectionDevice => 'CİHAZ';

  @override
  String get settingsSectionSims => 'SIM KARTLAR';

  @override
  String get settingsRowLanguage => 'Dil';

  @override
  String get settingsRowBrand => 'Cihaz markası';

  @override
  String get settingsRowSim => 'Etkin SIM';

  @override
  String get brandPickerTitle => 'Cihaz markası';

  @override
  String get brandPickerSubtitle =>
      'Uygulamanın konuştuğu takip cihazı ailesi.';

  @override
  String get brandBariox => 'Bariox';

  @override
  String get brandBarioxSub => 'BLE · ana kilitler ve alt kilitler';

  @override
  String get brandTeltonika => 'Teltonika';

  @override
  String get brandTeltonikaSub => 'SMS · FMB serisi';

  @override
  String get simsNone => 'SIM kart bulunamadı';

  @override
  String get simsRefresh => 'Yenile';

  @override
  String get simRowNone => 'Yok';

  @override
  String get simPickerTitle => 'Etkin SIM';

  @override
  String get simPickerSubtitle => 'Giden komutlar bu SIM üzerinden gönderilir.';

  @override
  String simSubtitle(int slot, String country) {
    return 'Yuva $slot · $country';
  }

  @override
  String smsActiveSimChip(String carrier, int slot) {
    return '$carrier (Yuva $slot)';
  }

  @override
  String get smsThreadsTitle => 'Mesajlar';

  @override
  String get smsThreadYou => 'Sen';

  @override
  String get smsThreadEmpty => 'Henüz mesaj yok';

  @override
  String get smsSearchHint => 'Cihaz ara';

  @override
  String get smsSearchEmpty => 'Eşleşen cihaz yok';

  @override
  String get smsPasswordNone => 'Ayarlanmadı';

  @override
  String get smsPasswordTitle => 'Cihaz şifresi';

  @override
  String get smsPasswordSubtitle =>
      'Bu cihaza giden her komutla birlikte gönderilir.';

  @override
  String get composeSend => 'Gönder';

  @override
  String get languagePickerTitle => 'Dil';

  @override
  String get languagePickerSubtitle => 'Uygulamanın tamamında geçerlidir.';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'İngilizce';
}
