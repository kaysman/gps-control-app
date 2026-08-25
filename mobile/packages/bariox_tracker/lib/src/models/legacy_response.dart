import 'dart:typed_data';

import 'package:bariox_tracker/src/models/legacy_status.dart';

/// A complete legacy `AA-55-A9` response frame received from the lock.
///
/// Wraps the raw frame bytes plus, when applicable, a decoded payload.
class LegacyResponse {
  /// Creates a [LegacyResponse].
  const LegacyResponse({
    required this.cmd,
    required this.rawFrame,
    this.status,
  });

  /// CMD byte echoed by the lock — `0x00` for system_status, `0x01` for the
  /// switch-control acknowledgement, etc.
  final int cmd;

  /// The full received frame, header through XOR.
  final Uint8List rawFrame;

  /// Decoded system_status fields, populated only when `cmd == 0x00`.
  final LegacyStatus? status;

  /// True when this response decoded a `cmd=0x00` system_status frame.
  bool get isStatus => status != null;

  /// True when this response is the lock/unlock command echo (`cmd=0x01`).
  bool get isSwitchEcho => cmd == 0x01;

  /// Hex string of the raw frame, e.g. `"AA 55 A9 00 ..."`. Useful for logs.
  String get hex => rawFrame
      .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join(' ');

  @override
  String toString() =>
      'LegacyResponse(cmd: 0x'
      '${cmd.toRadixString(16).padLeft(2, '0').toUpperCase()}, '
      '${rawFrame.length}B, status: $status)';
}
