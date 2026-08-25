/// Device type identifier from the broadcast packet.
enum TrackerDeviceType {
  /// Sub-lock model A1i.
  subLockA1i(0x01),

  /// Sub-lock model A1m.
  subLockA1m(0x04)
  ;

  const TrackerDeviceType(this.value);

  /// Raw byte value from the broadcast packet.
  final int value;

  /// Returns the [TrackerDeviceType] matching [value], or null if unknown.
  static TrackerDeviceType? fromValue(int value) {
    for (final type in values) {
      if (type.value == value) return type;
    }
    return null;
  }
}
