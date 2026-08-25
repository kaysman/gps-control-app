import 'package:gps_control/mock/mock_data.dart';

/// Renders [cmd] as the text the tracker expects, with [password] substituted
/// and [value] applied where the command takes one.
///
/// Kept in one place because it is the only thing standing between a tap and a
/// real SMS to real hardware.
String buildSmsText(SmsCommand cmd, String password, Object? value) {
  final p = password.isEmpty ? '000000' : password;
  if (cmd.id == 'sensor') {
    final level = value == 'low'
        ? 1
        : value == 'high'
        ? 3
        : 2;
    return '#$p,STPF:SENSORVAL,$level';
  }
  return switch (cmd.id) {
    'battery' => '#$p,RDBL',
    'status' => '#$p,RDLS',
    'position' => '#$p,RDLO',
    'rfid' => '#$p,RDRF',
    'subs' => '#$p,SLRA',
    'fw' => '#$p,RDVE',
    'sleep' => '#$p,STPF:SLEEPEN,${(value as bool? ?? true) ? 1 : 0}',
    'interval' => '#$p,STIN:$value',
    'autolock' => '#$p,STPF:CTIME,$value',
    'addrfid' => '#$p,STRF:1,$value',
    'addphone' => '#$p,STPN:1,$value',
    'pwd' => '(P44,$value,$p)',
    'unlock' || 'lock' => '(P43,$p)',
    'reboot' => '#$p,REST',
    'clear' => '#$p,CLRD',
    'reset' => '#$p,INIT:INIT-SYS',
    _ => '#$p,${cmd.id.toUpperCase()}',
  };
}
