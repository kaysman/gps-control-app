import 'package:gps_control/mock/mock_data.dart';

/// Renders [cmd] as the SMS text a Teltonika FMB unit expects, with [password]
/// and [value] applied.
///
/// Teltonika reads an SMS as `<login> <password> <command>`. Both credentials
/// are usually left unset on the device, which is why the documented form
/// starts with two spaces — the empty login and empty password still need
/// their separators. Anything else and the unit ignores the message.
String buildSmsText(SmsCommand cmd, String password, Object? value) =>
    ' $password ${_command(cmd, value)}';

String _command(SmsCommand cmd, Object? value) => switch (cmd.id) {
  'info' => 'getinfo',
  'gps' => 'getgps',
  'io' => 'getio',
  'status' => 'getstatus',
  'ver' => 'getver',
  // AVL ID 67 is the internal battery voltage.
  'battery' => 'readio 67',
  // Sleep Mode, parameter 102: 0 disabled, 1 GPS sleep.
  'sleep' => 'setparam 102:${(value as bool? ?? true) ? 1 : 0}',
  // Min Period between records while moving, parameter 10050, in seconds.
  'interval' => 'setparam 10050:$value',
  'getparam' => 'getparam $value',
  'setparam' => 'setparam $value',
  // DOUT1 drives the lock relay: held high to lock, low to release.
  'lock' => 'setdigout 1',
  'unlock' => 'setdigout 0',
  'pulse' => 'setdigout 1 5',
  'cpureset' => 'cpureset',
  'deleterecords' => 'deleterecords',
  _ => cmd.id,
};
