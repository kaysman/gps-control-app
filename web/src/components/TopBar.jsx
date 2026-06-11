import React from 'react';
import { BX, MONO } from '../tokens.js';

function TabIcon({ id, active }) {
  const c = active ? '#fff' : BX.mute;
  const p = { width: 16, height: 16, viewBox: '0 0 24 24', fill: 'none', stroke: c, strokeWidth: 1.8, strokeLinecap: 'round', strokeLinejoin: 'round' };
  if (id === 'ble')      return <svg {...p}><path d="M7 7l10 10-5 5V2l5 5L7 17"/></svg>;
  if (id === 'sms')      return <svg {...p}><path d="M21 11c0 4-4 7-9 7-1.5 0-3-.3-4.2-.8L3 19l1.8-3.4C3.6 14.2 3 12.7 3 11c0-4 4-7 9-7s9 3 9 7Z"/></svg>;
  if (id === 'settings') return <svg {...p}><circle cx="12" cy="12" r="2.6"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.9l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.9-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 0 1-4 0 1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.9.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.9 1.7 1.7 0 0 0-1.5-1H3a2 2 0 0 1 0-4 1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.9l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.9.3 1.7 1.7 0 0 0 1-1.5V3a2 2 0 0 1 4 0 1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.9-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.9 1.7 1.7 0 0 0 1.5 1H21a2 2 0 0 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1Z"/></svg>;
  return null;
}

// Bariox logo glyph
function BarioxGlyph() {
  return (
    <svg width="28" height="28" viewBox="0 0 32 32">
      <rect x="3.5" y="9.5" width="13" height="13" rx="3.5" fill="none" stroke={BX.navy} strokeWidth="2" />
      <rect x="11.5" y="3.5" width="13" height="13" rx="3.5" fill="none" stroke={BX.navy} strokeWidth="2" />
      <circle cx="7.5" cy="7" r="1.6" fill={BX.orange} />
      <circle cx="15.5" cy="1" r="1.6" fill={BX.orange} />
    </svg>
  );
}

export default function TopBar({ tab, onTab }) {
  const tabs = [
    { id: 'ble',      label: 'Bluetooth' },
    { id: 'sms',      label: 'SMS' },
    { id: 'settings', label: 'Settings' },
  ];
  return (
    <div style={{
      height: 64, padding: '0 28px', background: '#fff',
      borderBottom: `1px solid ${BX.rule}`,
      display: 'flex', alignItems: 'center', gap: 32, flexShrink: 0,
    }}>
      {/* Logo */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
        <BarioxGlyph />
        <span style={{ fontWeight: 800, fontSize: 17, letterSpacing: -0.3 }}>
          Bariox <span style={{ color: BX.orange }}>Control</span>
        </span>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', gap: 4 }}>
        {tabs.map(t => (
          <button key={t.id} onClick={() => onTab(t.id)} style={{
            padding: '8px 18px', borderRadius: 8, border: 'none',
            background: tab === t.id ? BX.navy : 'transparent',
            color:      tab === t.id ? '#fff' : BX.mute,
            fontSize: 14, fontWeight: 700, cursor: 'pointer',
            display: 'flex', alignItems: 'center', gap: 8,
            transition: 'all 0.15s',
          }}>
            <TabIcon id={t.id} active={tab === t.id} />
            {t.label}
          </button>
        ))}
      </div>

      {/* User */}
      <div style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 14 }}>
        <span style={{ fontSize: 12, color: BX.mute }}>Pacific Logistics</span>
        <div style={{
          width: 34, height: 34, borderRadius: '50%',
          background: BX.orange, color: BX.navy,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontWeight: 800, fontSize: 13,
        }}>AP</div>
      </div>
    </div>
  );
}
