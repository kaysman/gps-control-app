import React, { useState } from 'react';
import { BX } from './tokens.js';
import TopBar from './components/TopBar.jsx';
import BluetoothTab from './features/bluetooth/BluetoothTab.jsx';
import SmsTab from './features/sms/SmsTab.jsx';
import SettingsTab from './features/settings/SettingsTab.jsx';

export default function App() {
  const [tab, setTab] = useState('ble');
  return (
    <div style={{ width: '100%', height: '100vh', background: BX.paper, color: BX.navy, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      <TopBar tab={tab} onTab={setTab} />
      <div style={{ flex: 1, overflow: 'hidden', minHeight: 0 }}>
        {tab === 'ble'      && <BluetoothTab />}
        {tab === 'sms'      && <SmsTab />}
        {tab === 'settings' && <SettingsTab />}
      </div>
    </div>
  );
}
