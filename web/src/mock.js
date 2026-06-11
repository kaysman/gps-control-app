export const WEB_PAIRED = {
  id: '2025000025', name: 'CMAU-783412 · Reefer', sn: '2025000025',
  model: 'A1M', batt: 42, temp: 4, locked: false,
};

export const WEB_TRACKERS = [
  { id: '2025000012', short: 'Trailer 312',  name: 'Trailer 312',           tone: '#3D7DCE' },
  { id: '2025000025', short: 'Reefer-25',    name: 'CMAU-783412 · Reefer',  tone: '#E8952E' },
  { id: '2025000034', short: 'Phoenix-7',    name: 'Warehouse 7 · Bay 04',  tone: '#2D8F5A' },
  { id: '2025000088', short: 'TCNU-04',      name: 'TCNU-991204 · Dry',     tone: '#C8473F' },
  { id: '2025000051', short: 'Rotterdam',    name: 'MSCU-441207 · Reefer',  tone: '#8A6FE0' },
  { id: '2025000019', short: 'HJMU-19',      name: 'HJMU-217756 · Dry',     tone: '#1F8A7A' },
  { id: '2025000067', short: 'Trailer 488',  name: 'Trailer 488',           tone: '#B5572E' },
];

export const COMMANDS = {
  Read: [
    { id: 'battery',  name: 'Get battery',          sub: 'Battery level & charging' },
    { id: 'status',   name: 'Get lock status',      sub: 'Sealed · cover · motor' },
    { id: 'position', name: 'Get position',         sub: 'GPS coordinates · speed' },
    { id: 'rfid',     name: 'List RFID cards',      sub: 'All authorized cards' },
    { id: 'subs',     name: 'List sub-locks',       sub: 'Paired sub-locks & state' },
    { id: 'fw',       name: 'Get firmware version', sub: '' },
  ],
  Set: [
    { id: 'sleep',    name: 'Set sleep mode',        input: { kind: 'toggle',   label: 'Sleep mode',          defaultValue: true } },
    { id: 'interval', name: 'Set position interval', input: { kind: 'duration', label: 'Send position every', defaultValue: 30,  unit: 'seconds' } },
    { id: 'autolock', name: 'Set auto-lock time',    input: { kind: 'duration', label: 'Auto-lock after',     defaultValue: 120, unit: 'seconds' } },
    { id: 'addrfid',  name: 'Add RFID card',         input: { kind: 'text',     label: 'Card number',         placeholder: '2226557347' } },
    { id: 'addphone', name: 'Add authorized phone',  input: { kind: 'phone',    label: 'Phone number',        placeholder: '+1 555 0143' } },
    { id: 'pwd',      name: 'Change unlock password',input: { kind: 'pin',      label: 'New 6-digit password' } },
    { id: 'sensor',   name: 'Set sensor sensitivity',input: { kind: 'segmented',label: 'Sensitivity', options: ['Low','Medium','High'], defaultValue: 'Medium' } },
  ],
  Action: [
    { id: 'unlock', name: 'Unlock',              sub: 'Open the master lock' },
    { id: 'lock',   name: 'Lock',                sub: 'Seal the master lock' },
    { id: 'reboot', name: 'Restart device',      sub: '' },
    { id: 'clear',  name: 'Clear position cache',sub: '' },
    { id: 'reset',  name: 'Factory reset',       sub: 'Erases everything', danger: true },
  ],
};

export const WEB_HISTORY = [
  {
    id: 1,
    sent: { time: 'Today 10:42', recipients: ['2025000012','2025000025','2025000034'], command: 'Get battery' },
    replies: [
      { from: '2025000012', time: '10:42', body: 'Battery 86% · charging',  tone: 'ok' },
      { from: '2025000025', time: '10:43', body: 'Battery 42% · on battery',tone: 'warn' },
      { from: '2025000034', time: '10:43', body: 'Battery 100% · charging', tone: 'ok' },
    ],
  },
  {
    id: 2,
    sent: { time: 'Today 10:50', recipients: ['2025000034'], command: 'Set sleep mode', value: 'ON' },
    replies: [{ from: '2025000034', time: '10:51', body: 'Sleep mode: ON', tone: 'ok' }],
  },
  {
    id: 3,
    sent: { time: 'Today 11:14', recipients: ['2025000025'], command: 'Get position' },
    replies: [{ from: '2025000025', time: '11:14', body: '22.5928° N, 113.9974° E · 18.4 kn', tone: 'ok' }],
  },
];
