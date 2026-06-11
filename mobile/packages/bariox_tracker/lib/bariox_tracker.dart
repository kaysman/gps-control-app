/// Bariox GPS tracker BLE protocol — frame serialization, parsing, and models.
library;

export 'src/bariox_tracker.dart';
export 'src/bariox_tracker_legacy.dart';
export 'src/ble/discovered_tracker.dart';
export 'src/ble/nus_constants.dart';
export 'src/ble/tracker_connection.dart';
export 'src/ble/tracker_scanner.dart';
export 'src/models/broadcast_packet.dart';
export 'src/models/legacy_response.dart';
export 'src/models/legacy_status.dart';
export 'src/models/tracker_command.dart';
export 'src/models/tracker_device_type.dart';
export 'src/models/tracker_response.dart';
export 'src/models/tracker_response_code.dart';
export 'src/models/tracker_time.dart';
export 'src/protocol/frame_builder.dart';
export 'src/protocol/frame_parser.dart';
export 'src/protocol/legacy_frame_builder.dart';
export 'src/protocol/legacy_frame_parser.dart';
