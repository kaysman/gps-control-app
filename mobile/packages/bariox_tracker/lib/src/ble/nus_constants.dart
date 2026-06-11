/// Nordic UART Service (NUS) GATT UUIDs.
///
/// The Bariox e-lock uses NUS as its application-layer transport:
/// - Write command frames to the RX characteristic.
/// - Receive response frames via notifications on the TX characteristic.
abstract final class NusConstants {
  /// NUS service UUID.
  static const String serviceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';

  /// RX characteristic — app writes command frames here.
  static const String rxUuid = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';

  /// TX characteristic — device notifies response frames here.
  static const String txUuid = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';
}
