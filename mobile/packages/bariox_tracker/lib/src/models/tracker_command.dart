/// BLE command identifiers for the Bariox e-lock protocol.
enum TrackerCommand {
  /// Lock or unlock the device (CMD 0x01).
  switchLock(0x01),

  /// Query current lock state (CMD 0x02).
  queryLockStatus(0x02),

  /// Query device data/memory usage (CMD 0x03).
  queryDataUsage(0x03),

  /// Retrieve device information (CMD 0x04).
  checkDeviceInfo(0x04),

  /// Change the device password (CMD 0x05).
  changePassword(0x05),

  /// Configure device parameters (CMD 0x06).
  parameterConfig(0x06),

  /// Upgrade MCU firmware (CMD 0x07).
  mcuFirmwareUpgrade(0x07),

  /// Upgrade Bluetooth module firmware (CMD 0x08).
  btModuleFirmwareUpgrade(0x08),

  /// Reset device to factory defaults (CMD 0x09).
  factoryReset(0x09),

  /// Retrieve device operation log (CMD 0x0A).
  queryOperationLog(0x0A),

  /// Set the device clock (CMD 0x0B).
  setTime(0x0B),

  /// Read the device clock (CMD 0x0C).
  queryTime(0x0C),

  /// Control lock-in persistence (CMD 0x0D).
  lockInControl(0x0D),

  /// Query e-seal tamper status (CMD 0x0E).
  checkSealStatus(0x0E),

  /// Query battery and charging status (CMD 0x0F).
  checkChargingStatus(0x0F),

  /// Write a document to device flash (CMD 0x10).
  writeDocument(0x10),

  /// Read a file from device flash (CMD 0x11).
  readFile(0x11),

  /// Delete all files from device flash (CMD 0x12).
  deleteAllFiles(0x12),

  /// List all file names stored in device flash (CMD 0x13).
  readFileNames(0x13),

  /// Read the firmware version string (CMD 0x14).
  readSoftwareVersion(0x14),

  /// Add, read, delete, or clear RFID card numbers (CMD 0x15).
  configureRfid(0x15)
  ;

  const TrackerCommand(this.value);

  /// Raw byte value used in the protocol frame.
  final int value;

  /// Returns the [TrackerCommand] matching [value], or null if unrecognised.
  static TrackerCommand? fromValue(int value) {
    for (final cmd in values) {
      if (cmd.value == value) return cmd;
    }
    return null;
  }
}
