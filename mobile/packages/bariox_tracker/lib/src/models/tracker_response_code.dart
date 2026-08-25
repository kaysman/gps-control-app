/// Response status codes returned by the Bariox device.
enum TrackerResponseCode {
  /// Request processed successfully.
  success(0x00),

  /// XOR checksum of the received frame did not match.
  invalidChecksum(0x01),

  /// Frame header (0xAA 0xBB) or trailer (0x0D 0x0A) was incorrect.
  frameError(0x02),

  /// Length field does not match the actual data length.
  invalidLength(0x03),

  /// Command word is not defined or supported by this device.
  unsupportedCommand(0x04),

  /// The requested operation could not be completed.
  operationFailed(0x05),

  /// The supplied password is incorrect.
  wrongPassword(0x06),

  /// Device is busy and cannot process the request right now.
  deviceBusy(0x07)
  ;

  const TrackerResponseCode(this.value);

  /// Raw byte value from the response frame.
  final int value;

  /// Returns [TrackerResponseCode] for [value], falling back to
  /// [operationFailed] for unknown codes.
  static TrackerResponseCode fromValue(int value) {
    for (final code in values) {
      if (code.value == value) return code;
    }
    return TrackerResponseCode.operationFailed;
  }

  /// Whether this code indicates a successful operation.
  bool get isSuccess => this == TrackerResponseCode.success;
}
