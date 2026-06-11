// Mock fleet and command data matching the design spec.

class MockTracker {
  const MockTracker({
    required this.id,
    required this.short,
    required this.name,
    required this.tone,
    required this.phone,
  });
  final String id;
  final String short;
  final String name;
  final int tone; // ARGB int
  final String phone; // E.164 SIM number
}

const smsTrackers = [
  MockTracker(
    id: '2500000001',
    short: 'BX-001',
    name: 'S/N 2500000001',
    tone: 0xFF3D7DCE,
    phone: '+99371061287',
  ),
  MockTracker(
    id: '2500000002',
    short: 'BX-002',
    name: 'S/N 2500000002',
    tone: 0xFFE8952E,
    phone: '+99371061295',
  ),
  MockTracker(
    id: '2500000003',
    short: 'BX-003',
    name: 'S/N 2500000003',
    tone: 0xFF2D8F5A,
    phone: '+99371061279',
  ),
  MockTracker(
    id: '2500000004',
    short: 'BX-004',
    name: 'S/N 2500000004',
    tone: 0xFFC8473F,
    phone: '+99371061241',
  ),
  MockTracker(
    id: '2500000005',
    short: 'BX-005',
    name: 'S/N 2500000005',
    tone: 0xFF8A6FE0,
    phone: '+99371061291',
  ),
  MockTracker(
    id: '2500000006',
    short: 'BX-006',
    name: 'S/N 2500000006',
    tone: 0xFF4BAAD4,
    phone: '+99371061273',
  ),
  MockTracker(
    id: '2500000007',
    short: 'BX-007',
    name: 'S/N 2500000007',
    tone: 0xFFD4944B,
    phone: '+99371061275',
  ),
  MockTracker(
    id: '2500000008',
    short: 'BX-008',
    name: 'S/N 2500000008',
    tone: 0xFF5BAF7A,
    phone: '+99371061245',
  ),
  MockTracker(
    id: '2500000009',
    short: 'BX-009',
    name: 'S/N 2500000009',
    tone: 0xFF3D7DCE,
    phone: '+99371061254',
  ),
  MockTracker(
    id: '2500000010',
    short: 'BX-010',
    name: 'S/N 2500000010',
    tone: 0xFFE8952E,
    phone: '+99371061258',
  ),
  MockTracker(
    id: '2500000011',
    short: 'BX-011',
    name: 'S/N 2500000011',
    tone: 0xFF2D8F5A,
    phone: '+99371061293',
  ),
  MockTracker(
    id: '2500000012',
    short: 'BX-012',
    name: 'S/N 2500000012',
    tone: 0xFFC8473F,
    phone: '+99371061268',
  ),
  MockTracker(
    id: '2500000013',
    short: 'BX-013',
    name: 'S/N 2500000013',
    tone: 0xFF8A6FE0,
    phone: '+99371061237',
  ),
  MockTracker(
    id: '2500000014',
    short: 'BX-014',
    name: 'S/N 2500000014',
    tone: 0xFF4BAAD4,
    phone: '+99371061253',
  ),
  MockTracker(
    id: '2500000016',
    short: 'BX-016',
    name: 'S/N 2500000016',
    tone: 0xFFD4944B,
    phone: '+99371061259',
  ),
  MockTracker(
    id: '2500000017',
    short: 'BX-017',
    name: 'S/N 2500000017',
    tone: 0xFF5BAF7A,
    phone: '+99371061267',
  ),
  MockTracker(
    id: '2500000018',
    short: 'BX-018',
    name: 'S/N 2500000018',
    tone: 0xFF3D7DCE,
    phone: '+99371061247',
  ),
  MockTracker(
    id: '2500000019',
    short: 'BX-019',
    name: 'S/N 2500000019',
    tone: 0xFFE8952E,
    phone: '+99371061231',
  ),
  MockTracker(
    id: '2500000020',
    short: 'BX-020',
    name: 'S/N 2500000020',
    tone: 0xFF2D8F5A,
    phone: '+99361917698',
  ),
];

// ── Paired BLE device ──────────────────────────────────────────────────────
const pairedName = 'CMAU-783412 · Reefer';
const pairedSn = '2025000025';
const pairedBatt = 42;
const pairedTemp = 4;
const pairedLocked = false; // starts unlocked per mock

// ── SMS commands ───────────────────────────────────────────────────────────
enum CmdGroup { read, set, action }

class SmsCommand {
  const SmsCommand({
    required this.id,
    required this.group,
    this.input,
    this.danger = false,
  });
  final String id;
  final CmdGroup group;
  final CmdInput? input;
  final bool danger;
}

class CmdInput {
  const CmdInput({
    required this.kind,
    this.placeholder,
    this.optionIds,
    this.defaultStr,
    this.defaultBool,
  });
  final String kind; // toggle | duration | segmented | pin | text | phone
  final String? placeholder;
  final List<String>? optionIds;
  final String? defaultStr;
  final bool? defaultBool;
}

const allCommands = [
  SmsCommand(id: 'battery', group: CmdGroup.read),
  SmsCommand(id: 'status', group: CmdGroup.read),
  SmsCommand(id: 'position', group: CmdGroup.read),
  SmsCommand(id: 'rfid', group: CmdGroup.read),
  SmsCommand(id: 'subs', group: CmdGroup.read),
  SmsCommand(id: 'fw', group: CmdGroup.read),
  SmsCommand(
    id: 'sleep',
    group: CmdGroup.set,
    input: CmdInput(kind: 'toggle', defaultBool: true),
  ),
  SmsCommand(
    id: 'interval',
    group: CmdGroup.set,
    input: CmdInput(kind: 'duration', defaultStr: '30'),
  ),
  SmsCommand(
    id: 'autolock',
    group: CmdGroup.set,
    input: CmdInput(kind: 'duration', defaultStr: '120'),
  ),
  SmsCommand(
    id: 'addrfid',
    group: CmdGroup.set,
    input: CmdInput(kind: 'text', placeholder: '2226557347'),
  ),
  SmsCommand(
    id: 'addphone',
    group: CmdGroup.set,
    input: CmdInput(kind: 'phone', placeholder: '+1 555 0143'),
  ),
  SmsCommand(
    id: 'pwd',
    group: CmdGroup.set,
    input: CmdInput(kind: 'pin'),
  ),
  SmsCommand(
    id: 'sensor',
    group: CmdGroup.set,
    input: CmdInput(
      kind: 'segmented',
      optionIds: ['low', 'medium', 'high'],
      defaultStr: 'medium',
    ),
  ),
  SmsCommand(id: 'unlock', group: CmdGroup.action),
  SmsCommand(id: 'lock', group: CmdGroup.action),
  SmsCommand(id: 'reboot', group: CmdGroup.action),
  SmsCommand(id: 'clear', group: CmdGroup.action),
  SmsCommand(id: 'reset', group: CmdGroup.action, danger: true),
];

// ── SMS conversation history ───────────────────────────────────────────────
class SmsThread {
  const SmsThread({
    required this.id,
    required this.sent,
    required this.replies,
  });
  final int id;
  final SentMsg sent;
  final List<ReplyMsg> replies;
}

class SentMsg {
  const SentMsg({
    required this.time,
    required this.recipientIds,
    required this.command,
    this.value,
  });
  final String time;
  final List<String> recipientIds;
  final String command;
  final String? value;
}

class ReplyMsg {
  const ReplyMsg({
    required this.from,
    required this.time,
    required this.body,
    required this.tone,
  });
  final String from;
  final String time;
  final String body;
  final String tone; // 'ok' | 'warn' | 'bad'
}

const smsHistory = [
  SmsThread(
    id: 1,
    sent: SentMsg(
      time: 'Today 10:42',
      recipientIds: ['2025000012', '2025000025', '2025000034'],
      command: 'Get battery',
    ),
    replies: [
      ReplyMsg(
        from: '2025000012',
        time: '10:42',
        body: 'Battery 86% · charging',
        tone: 'ok',
      ),
      ReplyMsg(
        from: '2025000025',
        time: '10:43',
        body: 'Battery 42% · on battery',
        tone: 'warn',
      ),
      ReplyMsg(
        from: '2025000034',
        time: '10:43',
        body: 'Battery 100% · charging',
        tone: 'ok',
      ),
    ],
  ),
  SmsThread(
    id: 2,
    sent: SentMsg(
      time: 'Today 10:50',
      recipientIds: ['2025000034'],
      command: 'Set sleep mode',
      value: 'ON',
    ),
    replies: [
      ReplyMsg(
        from: '2025000034',
        time: '10:51',
        body: 'Sleep mode: ON',
        tone: 'ok',
      ),
    ],
  ),
];
