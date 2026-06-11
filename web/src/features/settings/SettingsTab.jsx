import React from 'react';
import { BX, MONO } from '../../tokens.js';

const Chevron = () => (
  <svg width="8" height="14" viewBox="0 0 8 14" fill="none" stroke={BX.mute2} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M1 1l5 6-5 6" />
  </svg>
);

function SettingsCard({ title, children }) {
  return (
    <div style={{ marginBottom: 18 }}>
      <div style={{ padding: '4px 4px 8px', fontSize: 11, fontWeight: 700, color: BX.mute, letterSpacing: 1.2, textTransform: 'uppercase' }}>{title}</div>
      <div style={{ background: '#fff', borderRadius: 12, border: `1px solid ${BX.rule}`, overflow: 'hidden' }}>
        {children}
      </div>
    </div>
  );
}

function Row({ label, value, last }) {
  return (
    <div style={{
      padding: '14px 18px', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      borderBottom: last ? 'none' : `1px solid ${BX.rule}`, cursor: 'pointer',
    }}>
      <span style={{ fontSize: 14, fontWeight: 600, color: BX.navy }}>{label}</span>
      <span style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        <span style={{ fontSize: 13, color: BX.mute }}>{value}</span>
        <Chevron />
      </span>
    </div>
  );
}

export default function SettingsTab() {
  return (
    <div style={{ width: '100%', height: '100%', display: 'flex', justifyContent: 'center', overflow: 'auto', padding: '32px 24px' }}>
      <div style={{ width: '100%', maxWidth: 820 }}>
        <div style={{ marginBottom: 24 }}>
          <div style={{ fontSize: 10.5, color: BX.mute, fontFamily: MONO, letterSpacing: 1.4, fontWeight: 700 }}>WORKSPACE & ACCOUNT</div>
          <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.5, marginTop: 4 }}>Settings</div>
        </div>

        <SettingsCard title="Profile">
          <Row label="Name"  value="Anita Park" />
          <Row label="Email" value="anita.park@pacific-log.com" />
          <Row label="Role"  value="Dispatcher" />
          <Row label="Phone" value="+1 619 555 0143" last />
        </SettingsCard>

        <SettingsCard title="Workspace">
          <Row label="Name"    value="Pacific Logistics" />
          <Row label="Plan"    value="Operations · 247 devices" />
          <Row label="Members" value="14 dispatchers" last />
        </SettingsCard>

        <SettingsCard title="App">
          <Row label="Notifications"    value="On" />
          <Row label="Default channel"  value="Bluetooth, then SMS" />
          <Row label="Units"            value="Metric" />
          <Row label="Language"         value="English" last />
        </SettingsCard>

        <SettingsCard title="About">
          <Row label="Version"       value="1.0 (build 24)" />
          <Row label="Help & support" value="" />
          <Row label="Privacy policy" value="" />
          <Row label="Terms"         value="" last />
        </SettingsCard>

        <button style={{ marginTop: 8, padding: '10px 16px', border: `1px solid ${BX.rule}`, background: '#fff', color: BX.bad, fontWeight: 700, fontSize: 13.5, borderRadius: 8, cursor: 'pointer' }}>
          Sign out
        </button>

        <div style={{ textAlign: 'center', padding: '24px 0 12px', fontSize: 11.5, color: BX.mute, fontFamily: MONO }}>
          Bariox Control · v1.0
        </div>
      </div>
    </div>
  );
}
