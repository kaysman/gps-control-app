// Demo fleet and the SMS command catalogue it answers to.

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

/// The demo fleet. Teltonika units are addressed by IMEI, so that is the
/// id; the short name is the label a dispatcher would actually use.
const smsTrackers = [
  MockTracker(
    id: '352094081234501',
    short: 'FMB-001',
    name: 'FMB920 · IMEI 352094081234501',
    tone: 0xFF3D7DCE,
    phone: '+99371061287',
  ),
  MockTracker(
    id: '352094081234502',
    short: 'FMB-002',
    name: 'FMB920 · IMEI 352094081234502',
    tone: 0xFF2D8F5A,
    phone: '+99371061295',
  ),
  MockTracker(
    id: '352094081234503',
    short: 'FMB-003',
    name: 'FMB640 · IMEI 352094081234503',
    tone: 0xFFD4944B,
    phone: '+99371061279',
  ),
  MockTracker(
    id: '352094081234504',
    short: 'FMB-004',
    name: 'FMC920 · IMEI 352094081234504',
    tone: 0xFF8A6FE0,
    phone: '+99371061241',
  ),
  MockTracker(
    id: '352094081234505',
    short: 'FMB-005',
    name: 'FMB920 · IMEI 352094081234505',
    tone: 0xFF4BAAD4,
    phone: '+99371061291',
  ),
  MockTracker(
    id: '352094081234506',
    short: 'FMB-006',
    name: 'FMB003 · IMEI 352094081234506',
    tone: 0xFFC8473F,
    phone: '+99371061273',
  ),
  MockTracker(
    id: '352094081234507',
    short: 'FMB-007',
    name: 'FMB640 · IMEI 352094081234507',
    tone: 0xFF5BAF7A,
    phone: '+99371061275',
  ),
  MockTracker(
    id: '352094081234508',
    short: 'FMB-008',
    name: 'FMB920 · IMEI 352094081234508',
    tone: 0xFF3D7DCE,
    phone: '+99371061245',
  ),
  MockTracker(
    id: '352094081234509',
    short: 'FMB-009',
    name: 'FMC920 · IMEI 352094081234509',
    tone: 0xFFE8952E,
    phone: '+99371061254',
  ),
  MockTracker(
    id: '352094081234510',
    short: 'FMB-010',
    name: 'FMB920 · IMEI 352094081234510',
    tone: 0xFF2D8F5A,
    phone: '+99371061258',
  ),
  MockTracker(
    id: '352094081234511',
    short: 'FMB-011',
    name: 'FMB003 · IMEI 352094081234511',
    tone: 0xFF4BAAD4,
    phone: '+99371061293',
  ),
  MockTracker(
    id: '352094081234512',
    short: 'FMB-012',
    name: 'FMB640 · IMEI 352094081234512',
    tone: 0xFF8A6FE0,
    phone: '+99371061268',
  ),
];

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
  final String kind; // toggle | duration | text
  final String? placeholder;
  final List<String>? optionIds;
  final String? defaultStr;
  final bool? defaultBool;
}

/// The commands offered in the picker, in Teltonika FMB SMS form.
///
/// Reads answer with the device's own text; sets and actions go through
/// `setparam` / `setdigout`, which is how an FMB unit is configured over SMS.
/// The wire strings live in `features/sms/sms_command_text.dart`.
const allCommands = [
  SmsCommand(id: 'info', group: CmdGroup.read),
  SmsCommand(id: 'gps', group: CmdGroup.read),
  SmsCommand(id: 'io', group: CmdGroup.read),
  SmsCommand(id: 'status', group: CmdGroup.read),
  SmsCommand(id: 'battery', group: CmdGroup.read),
  SmsCommand(id: 'ver', group: CmdGroup.read),
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
    id: 'getparam',
    group: CmdGroup.set,
    input: CmdInput(kind: 'text', placeholder: '10050'),
  ),
  SmsCommand(
    id: 'setparam',
    group: CmdGroup.set,
    input: CmdInput(kind: 'text', placeholder: '10050:30'),
  ),
  SmsCommand(id: 'lock', group: CmdGroup.action),
  SmsCommand(id: 'unlock', group: CmdGroup.action),
  SmsCommand(id: 'pulse', group: CmdGroup.action),
  SmsCommand(id: 'cpureset', group: CmdGroup.action),
  SmsCommand(id: 'deleterecords', group: CmdGroup.action, danger: true),
];
