import React, { useState, useRef, useEffect } from 'react';
import { BX, MONO } from '../../tokens.js';
import { WEB_PAIRED } from '../../mock.js';

function LockIcon({ locked, size = 36 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <rect x="4" y="11" width="16" height="10" rx="2" />
      {locked ? <path d="M8 11V8a4 4 0 0 1 8 0v3" /> : <path d="M8 11V8a4 4 0 0 1 7-2.6" />}
      <circle cx="12" cy="16" r="1.2" fill="currentColor" />
    </svg>
  );
}

// SVG dial ring + ticks
function DialRing({ progress, size = 280 }) {
  const cx = size / 2, cy = size / 2, r = (size / 2) * (108 / 120);
  const circ = 2 * Math.PI * r;
  const offset = circ * (1 - progress);
  const tickR1 = r * (92 / 108), tickR2 = r * (100 / 108);
  const ticks = Array.from({ length: 36 }, (_, i) => {
    const a = (i / 36) * Math.PI * 2;
    return {
      x1: cx + Math.cos(a) * tickR1, y1: cy + Math.sin(a) * tickR1,
      x2: cx + Math.cos(a) * tickR2, y2: cy + Math.sin(a) * tickR2,
    };
  });
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{ position: 'absolute' }}>
      <circle cx={cx} cy={cy} r={r} fill="none" stroke="rgba(255,255,255,0.07)" strokeWidth="2" />
      <circle cx={cx} cy={cy} r={r} fill="none" stroke={BX.orange}
        strokeWidth="3" strokeDasharray={circ} strokeDashoffset={offset}
        strokeLinecap="round" transform={`rotate(-90 ${cx} ${cy})`}
        style={{ transition: 'stroke-dashoffset 0.5s ease' }} />
      {ticks.map((t, i) => (
        <line key={i} x1={t.x1} y1={t.y1} x2={t.x2} y2={t.y2}
          stroke="rgba(255,255,255,0.16)" strokeWidth="1" />
      ))}
    </svg>
  );
}

function BleAction({ label, icon, onClick, disabled, busy }) {
  const icons = {
    open:    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 7-2.6"/></svg>,
    lock:    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></svg>,
    refresh: <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 12a9 9 0 0 1 15-6.7L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-15 6.7L3 16"/><path d="M3 21v-5h5"/></svg>,
  };
  return (
    <button onClick={onClick} disabled={disabled || busy} style={{
      padding: '12px 14px', borderRadius: 10, cursor: disabled ? 'not-allowed' : 'pointer',
      background: 'rgba(255,255,255,0.08)', color: '#fff',
      border: '1px solid rgba(255,255,255,0.12)', opacity: disabled ? 0.45 : 1,
      fontWeight: 700, fontSize: 13.5, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      transition: 'opacity 0.15s', flex: 1,
    }}>
      {busy
        ? <span style={{ width: 14, height: 14, border: '2px solid #fff', borderTopColor: 'transparent', borderRadius: '50%', animation: 'bxSpin 0.8s linear infinite' }} />
        : icons[icon]}
      {label}
    </button>
  );
}

export default function BluetoothTab() {
  const d = WEB_PAIRED;
  const [locked, setLocked] = useState(d.locked);
  const [pressing, setPressing] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [toast, setToast] = useState(null);

  const showToast = (msg) => {
    setToast(msg);
    setTimeout(() => setToast(null), 1800);
  };

  const toggle = () => {
    if (pressing) return;
    setPressing(true);
    setTimeout(() => {
      const wasLocked = locked;
      setLocked(!wasLocked);
      setPressing(false);
      showToast(wasLocked ? 'Unlocked' : 'Locked');
    }, 1000);
  };

  const refresh = () => {
    if (refreshing) return;
    setRefreshing(true);
    setTimeout(() => { setRefreshing(false); showToast('Status refreshed'); }, 1100);
  };

  const progress = locked ? 1 : 0.5;

  return (
    <div style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 32 }}>
      <div style={{
        width: 640, background: locked ? BX.navyInk : BX.navy, color: '#fff',
        borderRadius: 22, padding: 32, position: 'relative', overflow: 'hidden',
        boxShadow: '0 20px 60px rgba(14,36,56,0.25)',
      }}>
        {/* Glow */}
        <div style={{
          position: 'absolute', right: -100, top: -100, width: 320, height: 320,
          borderRadius: '50%', background: `radial-gradient(circle, rgba(232,149,46,0.30), transparent 65%)`,
          pointerEvents: 'none',
        }} />

        {/* Header */}
        <div style={{ position: 'relative', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
          <div>
            <div style={{ fontSize: 11, color: BX.mute2, fontFamily: MONO, letterSpacing: 1.4 }}>CONNECTED OVER BLUETOOTH</div>
            <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.4, marginTop: 4 }}>{d.name}</div>
            <div style={{ fontSize: 12.5, color: BX.mute2, fontFamily: MONO, marginTop: 2 }}>SN {d.sn} · iS-Lock {d.model}</div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 8 }}>
            <span style={{
              padding: '3px 9px', borderRadius: 999, fontSize: 11, fontWeight: 600,
              background: locked ? 'rgba(28,61,94,0.6)' : 'rgba(232,149,46,0.12)',
              color: locked ? BX.mute2 : BX.orangeD,
              border: `1px solid ${locked ? 'rgba(255,255,255,0.15)' : 'rgba(232,149,46,0.30)'}`,
            }}>{locked ? 'Sealed' : 'Open'}</span>
            <span style={{ display: 'flex', alignItems: 'center', gap: 6, color: BX.ok, fontSize: 12, fontWeight: 600 }}>
              <span style={{ width: 8, height: 8, borderRadius: '50%', background: BX.ok }} />
              Strong signal
            </span>
          </div>
        </div>

        {/* Dial */}
        <div style={{ position: 'relative', height: 280, display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '8px 0' }}>
          <DialRing progress={progress} size={280} />
          <button onClick={toggle} disabled={pressing} style={{
            width: 200, height: 200, borderRadius: '50%', cursor: pressing ? 'wait' : 'pointer',
            border: 'none', transition: 'all 0.2s',
            background: pressing ? BX.orange : (locked ? '#fff' : BX.orange), color: BX.navy,
            display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8,
            boxShadow: locked ? '0 14px 40px rgba(0,0,0,0.30)' : '0 14px 40px rgba(232,149,46,0.5)',
          }}>
            {pressing ? (
              <>
                <span style={{ width: 28, height: 28, border: `3px solid ${BX.navy}`, borderTopColor: 'transparent', borderRadius: '50%', animation: 'bxSpin 0.8s linear infinite' }} />
                <span style={{ fontWeight: 700, fontSize: 14 }}>Sending…</span>
              </>
            ) : (
              <>
                <LockIcon locked={locked} size={36} />
                <span style={{ fontWeight: 700, fontSize: 17, letterSpacing: 0.3 }}>
                  {locked ? 'Click to unlock' : 'Click to lock'}
                </span>
              </>
            )}
          </button>
        </div>

        {/* Status strip */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', borderTop: '1px solid rgba(255,255,255,0.08)', paddingTop: 18, marginTop: 8 }}>
          {[
            { k: 'BATTERY', v: `${d.batt}%`, warn: d.batt <= 25 },
            { k: 'INSIDE',  v: `${d.temp}°C` },
            { k: 'UPDATED', v: refreshing ? '…' : 'just now' },
          ].map((t, i) => (
            <div key={t.k} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, borderLeft: i > 0 ? '1px solid rgba(255,255,255,0.08)' : 'none' }}>
              <span style={{ fontSize: 10.5, color: BX.mute2, fontFamily: MONO, letterSpacing: 1.4 }}>{t.k}</span>
              <span style={{ fontWeight: 700, fontSize: 22, color: t.warn ? BX.orange : '#fff', letterSpacing: -0.4 }}>{t.v}</span>
            </div>
          ))}
        </div>

        {/* Commands */}
        <div style={{ marginTop: 20, display: 'flex', gap: 10 }}>
          <BleAction label="Unlock"         icon="open"    onClick={() => locked && toggle()}  disabled={!locked || pressing} />
          <BleAction label="Lock"           icon="lock"    onClick={() => !locked && toggle()} disabled={locked || pressing} />
          <BleAction label="Refresh status" icon="refresh" onClick={refresh}                   busy={refreshing} />
        </div>

        {/* Toast */}
        {toast && (
          <div style={{
            position: 'absolute', left: 32, right: 32, bottom: 28,
            padding: '12px 16px', borderRadius: 12, background: BX.orange, color: BX.navy,
            fontWeight: 700, fontSize: 14, animation: 'bxRise 0.2s',
            display: 'flex', alignItems: 'center', gap: 8,
            boxShadow: '0 8px 24px rgba(232,149,46,0.30)',
          }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={BX.navy} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
              <path d="M4 12l5 5L20 6" />
            </svg>
            {toast}
          </div>
        )}
      </div>
    </div>
  );
}
