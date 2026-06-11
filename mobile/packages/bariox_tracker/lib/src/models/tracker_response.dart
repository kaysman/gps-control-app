import 'dart:typed_data';

import 'package:bariox_tracker/src/models/tracker_command.dart';
import 'package:bariox_tracker/src/models/tracker_response_code.dart';
import 'package:bariox_tracker/src/models/tracker_time.dart';

/// Parsed response frame returned by the Bariox device after a command.
class TrackerResponse {
  /// Creates a [TrackerResponse].
  const TrackerResponse({
    required this.command,
    required this.responseCode,
    required this.data,
  });

  /// The command this response belongs to; null if the CMD byte is unknown.
  final TrackerCommand? command;

  /// Result status from the device.
  final TrackerResponseCode responseCode;

  /// Payload bytes after the response code. For most successful responses this
  /// starts with the 6-byte device ID followed by command-specific data.
  final Uint8List data;

  /// Whether the operation completed without error.
  bool get isSuccess => responseCode.isSuccess;

  /// Convenience accessor: the 12-digit BCD device ID from the first 6 bytes
  /// of [data], available on most response types.
  String? get deviceId {
    if (data.length < 6) return null;
    final sb = StringBuffer();
    for (var i = 0; i < 6; i++) {
      sb.write(((data[i] >> 4) & 0x0F).toString());
      sb.write((data[i] & 0x0F).toString());
    }
    return sb.toString();
  }

  /// Decodes the [TrackerTime] from a query-time response (CMD 0x0C).
  ///
  /// Returns null when the response is not a successful time-query reply or
  /// does not contain enough bytes.
  TrackerTime? get time {
    if (!isSuccess || data.length < 12) return null;
    return TrackerTime.fromBytes(data.sublist(6, 12));
  }

  /// Decodes the firmware version string from a read-software-version response
  /// (CMD 0x14).
  ///
  /// Returns null when the response is not a successful version reply.
  String? get softwareVersion {
    if (!isSuccess || data.length < 7) return null;
    final versionBytes = data.sublist(6);
    return String.fromCharCodes(versionBytes);
  }

  @override
  String toString() =>
      'TrackerResponse(cmd: ${command?.name}, code: ${responseCode.name})';
}
