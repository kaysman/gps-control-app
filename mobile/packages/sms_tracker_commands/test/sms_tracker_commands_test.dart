import 'package:sms_tracker_commands/sms_tracker_commands.dart';
import 'package:test/test.dart';

void main() {
  group('SmsTrackerCommands', () {
    const cmds = SmsTrackerCommands();

    test('setReceivePhone builds correct command', () {
      final cmd = cmds.setReceivePhone(slot: 1, phoneNumber: '71061248');
      expect(cmd.text, '#000000,STPH:1,71061248');
    });

    test('setNationalCode builds correct command', () {
      final cmd = cmds.setNationalCode(993);
      expect(cmd.text, '#000000,STNC:993');
    });

    test('setSmsInterval builds correct command', () {
      final cmd = cmds.setSmsInterval(30);
      expect(cmd.text, '#000000,STSI:30');
    });

    test('setSmsSwitch enabled', () {
      expect(cmds.setSmsSwitch(enabled: true).text, '#000000,STSS:1');
      expect(cmds.setSmsSwitch(enabled: false).text, '#000000,STSS:0');
    });

    test('custom password', () {
      const custom = SmsTrackerCommands(password: '123456');
      expect(custom.setNationalCode(993).text, '#123456,STNC:993');
    });
  });
}
