import React, { useState } from 'react';
import { BX, MONO } from '../../tokens.js';
import { WEB_TRACKERS, COMMANDS, WEB_HISTORY } from '../../mock.js';

const Chevron = () => (
  <svg width="8" height="14" viewBox="0 0 8 14" fill="none" stroke={BX.mute2} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M1 1l5 6-5 6" />
  </svg>
);

function StatusDot({ tone }) {
  const c = tone === 'ok' ? BX.ok : tone === 'bad' ? BX.bad : BX.orange;
  return <span style={{ display: 'inline-block', width: 8, height: 8, borderRadius: '50%', background: c }} />;
}

// Left rail — tracker checklist
function TrackerRail({ recipients, onToggle }) {
  return (
    <aside style={{ width: 296, flexShrink: 0, background: '#fff', borderRight: `1px solid ${BX.rule}`, display: 'flex', flexDirection: 'column' }}>
      <div style={{ padding: '20px 22px 14px', borderBottom: `1px solid ${BX.rule}` }}>
        <div style={{ fontSize: 10.5, color: BX.mute, fontFamily: MONO, letterSpacing: 1.4, fontWeight: 700 }}>RECIPIENTS</div>
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginTop: 6 }}>
          <span style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.3 }}>Trackers</span>
          <span style={{ fontSize: 12.5, color: BX.mute }}>{recipients.length} selected</span>
        </div>
      </div>
      <div style={{ flex: 1, overflow: 'auto', padding: '8px 12px' }}>
        {WEB_TRACKERS.map(t => {
          const checked = recipients.includes(t.id);
          return (
            <button key={t.id} onClick={() => onToggle(t.id)} style={{
              width: '100%', padding: '10px', display: 'flex', alignItems: 'center', gap: 12,
              background: checked ? BX.paper : 'transparent', border: 'none', borderRadius: 8,
              cursor: 'pointer', marginBottom: 2, textAlign: 'left',
            }}>
              <span style={{
                width: 18, height: 18, borderRadius: 5, flexShrink: 0,
                border: `1.5px solid ${checked ? BX.navy : BX.ruleS}`,
                background: checked ? BX.navy : '#fff',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                {checked && <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><path d="M4 12l5 5L20 6"/></svg>}
              </span>
              <span style={{ width: 8, height: 8, borderRadius: '50%', background: t.tone, flexShrink: 0 }} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13.5, fontWeight: 600, color: BX.navy, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{t.short}</div>
                <div style={{ fontSize: 11, color: BX.mute, fontFamily: MONO }}>SN {t.id}</div>
              </div>
            </button>
          );
        })}
      </div>
      <div style={{ padding: '12px 16px', borderTop: `1px solid ${BX.rule}` }}>
        <button style={{ width: '100%', padding: '9px 12px', border: `1px dashed ${BX.ruleS}`, background: 'transparent', color: BX.navy, fontWeight: 700, fontSize: 13, borderRadius: 8, cursor: 'pointer' }}>
          + Add tracker
        </button>
      </div>
    </aside>
  );
}

// Conversation threads
function Thread({ thread, showDate }) {
  const sentDevs = thread.sent.recipients.map(id => WEB_TRACKERS.find(t => t.id === id)).filter(Boolean);
  return (
    <div style={{ marginBottom: 16 }}>
      {showDate && (
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 18 }}>
          <span style={{ fontSize: 10.5, fontFamily: MONO, color: BX.mute, letterSpacing: 1.4, fontWeight: 700, padding: '4px 14px', background: '#fff', borderRadius: 999, border: `1px solid ${BX.rule}` }}>
            {thread.sent.time.toUpperCase()}
          </span>
        </div>
      )}
      {/* Sent bubble */}
      <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 10 }}>
        <div style={{ maxWidth: 520, display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 6 }}>
          <span style={{ fontSize: 11, color: BX.mute, fontFamily: MONO, letterSpacing: 0.6 }}>
            You · to {sentDevs.length} {sentDevs.length === 1 ? 'tracker' : 'trackers'}
          </span>
          <div style={{ padding: '12px 18px', borderRadius: '16px 16px 4px 16px', background: BX.navy, color: '#fff', fontSize: 15, fontWeight: 600, boxShadow: '0 2px 4px rgba(14,36,56,0.10)' }}>
            {thread.sent.command}
            {thread.sent.value && <span style={{ color: BX.orange, marginLeft: 10 }}>→ {thread.sent.value}</span>}
          </div>
          <div style={{ display: 'flex', gap: 4 }}>
            {sentDevs.map(t => <span key={t.id} style={{ width: 7, height: 7, borderRadius: '50%', background: t.tone }} />)}
          </div>
        </div>
      </div>
      {/* Replies */}
      {thread.replies.map((r, i) => {
        const dev = WEB_TRACKERS.find(t => t.id === r.from);
        return (
          <div key={i} style={{ display: 'flex', justifyContent: 'flex-start', marginBottom: 8 }}>
            <div style={{ maxWidth: 520, display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 6 }}>
              <span style={{ fontSize: 11, color: BX.mute, fontFamily: MONO, letterSpacing: 0.6, display: 'flex', alignItems: 'center', gap: 6 }}>
                <span style={{ width: 7, height: 7, borderRadius: '50%', background: dev?.tone || BX.mute2 }} />
                {dev?.short || r.from} · {r.time}
              </span>
              <div style={{ padding: '12px 18px', borderRadius: '16px 16px 16px 4px', background: '#fff', color: BX.navy, fontSize: 15, fontWeight: 500, border: `1px solid ${BX.rule}`, display: 'flex', alignItems: 'center', gap: 10 }}>
                <StatusDot tone={r.tone} />
                {r.body}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}

// Command picker modal
function CommandPicker({ onPick, onClose }) {
  return (
    <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'rgba(14,36,56,0.40)', backdropFilter: 'blur(4px)', zIndex: 50, display: 'flex', alignItems: 'center', justifyContent: 'center', animation: 'bxRise 0.18s' }}>
      <div onClick={e => e.stopPropagation()} style={{ width: 720, maxHeight: '80%', background: '#fff', borderRadius: 16, boxShadow: '0 30px 80px rgba(14,36,56,0.40)', display: 'flex', flexDirection: 'column' }}>
        <div style={{ padding: '20px 24px', borderBottom: `1px solid ${BX.rule}`, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <div style={{ fontSize: 10.5, color: BX.mute, fontFamily: MONO, letterSpacing: 1.4, fontWeight: 700 }}>COMMAND</div>
            <div style={{ fontSize: 22, fontWeight: 700, marginTop: 2 }}>Pick one</div>
          </div>
          <button onClick={onClose} style={{ background: BX.bone, border: 'none', width: 34, height: 34, borderRadius: '50%', color: BX.navy, fontSize: 18, cursor: 'pointer' }}>×</button>
        </div>
        <div style={{ flex: 1, overflow: 'auto', padding: '14px 16px 18px' }}>
          {Object.entries(COMMANDS).map(([group, list]) => (
            <div key={group} style={{ marginBottom: 12 }}>
              <div style={{ padding: '10px 10px 8px', fontSize: 11, fontWeight: 700, color: BX.mute, letterSpacing: 1.2, textTransform: 'uppercase' }}>
                {group} {group === 'Set' && <span style={{ color: BX.orangeD, marginLeft: 6 }}>· needs input</span>}
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2,1fr)', gap: 6 }}>
                {list.map(cmd => {
                  const iconBg = group === 'Read' ? BX.bone : group === 'Set' ? 'rgba(232,149,46,0.14)' : cmd.danger ? 'rgba(200,71,63,0.10)' : 'rgba(45,143,90,0.10)';
                  return (
                    <button key={cmd.id} onClick={() => onPick(cmd)} style={{
                      width: '100%', textAlign: 'left', background: '#fff', border: `1px solid ${BX.rule}`,
                      padding: '12px 14px', borderRadius: 10, cursor: 'pointer',
                      display: 'flex', alignItems: 'center', gap: 10,
                    }}>
                      <div style={{ width: 30, height: 30, borderRadius: 8, background: iconBg, color: cmd.danger ? BX.bad : BX.navy, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 13, fontWeight: 800 }}>
                        {group === 'Read' ? '↓' : group === 'Set' ? '⇄' : '!'}
                      </div>
                      <div style={{ flex: 1 }}>
                        <div style={{ fontSize: 13.5, fontWeight: 600, color: cmd.danger ? BX.bad : BX.navy }}>{cmd.name}</div>
                        {cmd.sub && <div style={{ fontSize: 11.5, color: BX.mute }}>{cmd.sub}</div>}
                      </div>
                      {cmd.input && <span style={{ padding: '2px 7px', borderRadius: 999, fontSize: 9.5, fontWeight: 700, letterSpacing: 0.5, background: 'rgba(232,149,46,0.10)', color: BX.orangeD }}>input</span>}
                    </button>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// Compose input for web
function ComposeInput({ input, value, onChange }) {
  if (input.kind === 'toggle') {
    return (
      <div style={{ display: 'flex', alignItems: 'center', gap: 18 }}>
        <span style={{ fontSize: 13.5, fontWeight: 600 }}>{input.label}</span>
        <span style={{ display: 'flex', border: `1px solid ${BX.rule}`, borderRadius: 8, overflow: 'hidden' }}>
          {['On','Off'].map((o, i) => (
            <button key={o} onClick={() => onChange(o === 'On')} style={{ padding: '8px 22px', border: 'none', fontWeight: 700, fontSize: 13.5, borderLeft: i ? `1px solid ${BX.rule}` : 'none', background: (value === true) === (o === 'On') ? BX.navy : '#fff', color: (value === true) === (o === 'On') ? '#fff' : BX.navy, cursor: 'pointer' }}>{o}</button>
          ))}
        </span>
      </div>
    );
  }
  if (input.kind === 'segmented') {
    return (
      <div style={{ display: 'flex', alignItems: 'center', gap: 18 }}>
        <span style={{ fontSize: 13.5, fontWeight: 600 }}>{input.label}</span>
        <span style={{ display: 'flex', border: `1px solid ${BX.rule}`, borderRadius: 8, overflow: 'hidden' }}>
          {(input.options || []).map((o, i) => (
            <button key={o} onClick={() => onChange(o)} style={{ padding: '8px 16px', border: 'none', fontWeight: 700, fontSize: 13, borderLeft: i ? `1px solid ${BX.rule}` : 'none', background: value === o ? BX.navy : '#fff', color: value === o ? '#fff' : BX.navy, cursor: 'pointer' }}>{o}</button>
          ))}
        </span>
      </div>
    );
  }
  if (input.kind === 'pin') {
    return (
      <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
        <span style={{ fontSize: 13.5, fontWeight: 600 }}>{input.label}</span>
        <input type="password" defaultValue="••••••" style={{ padding: '10px 14px', border: `1px solid ${BX.rule}`, borderRadius: 6, fontFamily: MONO, fontSize: 18, letterSpacing: 6, color: BX.navy, width: 180, textAlign: 'center' }} />
      </div>
    );
  }
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
      <span style={{ fontSize: 13.5, fontWeight: 600 }}>{input.label}</span>
      <input type="text" placeholder={input.placeholder} defaultValue={typeof value === 'string' ? value : ''} style={{ padding: '10px 14px', border: `1px solid ${BX.rule}`, borderRadius: 6, fontFamily: input.kind === 'phone' ? MONO : 'inherit', fontSize: 14, fontWeight: 600, color: BX.navy, width: input.kind === 'duration' ? 110 : 260 }} />
      {input.unit && <span style={{ fontSize: 13, color: BX.mute }}>{input.unit}</span>}
    </div>
  );
}

// Compose dock
function ComposeDock({ panel, picked, recipientCount, onOpen, onCancel, onChange }) {
  if (panel === 'compose' && picked) {
    return (
      <div style={{ borderTop: `1px solid ${BX.rule}`, background: '#fff', padding: '16px 28px', boxShadow: '0 -8px 24px rgba(14,36,56,0.06)' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <span style={{ padding: '3px 9px', borderRadius: 999, fontSize: 10, fontWeight: 700, letterSpacing: 0.6, background: BX.bone, color: BX.navy }}>
              {picked.input ? 'SET' : picked.danger ? 'ACTION' : 'COMMAND'}
            </span>
            <span style={{ fontSize: 16, fontWeight: 700 }}>{picked.name}</span>
            {picked.sub && <span style={{ fontSize: 12.5, color: BX.mute }}>{picked.sub}</span>}
          </div>
          <button onClick={onCancel} style={{ background: 'transparent', border: 'none', color: BX.mute, fontSize: 18, cursor: 'pointer', width: 30, height: 30, display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: 6 }}>×</button>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr auto', gap: 14, alignItems: 'center' }}>
          {picked.input
            ? <ComposeInput input={picked.input} value={picked.value} onChange={onChange} />
            : <div style={{ padding: '12px 14px', borderRadius: 8, background: picked.danger ? 'rgba(200,71,63,0.06)' : BX.paper, color: picked.danger ? BX.bad : BX.inkSoft, fontSize: 13.5 }}>
                {picked.danger ? `Confirm: erases everything on ${recipientCount} ${recipientCount === 1 ? 'tracker' : 'trackers'}.` : 'No parameters required.'}
              </div>
          }
          <button disabled={recipientCount === 0} style={{
            padding: '12px 22px', borderRadius: 10, border: 'none',
            cursor: recipientCount === 0 ? 'not-allowed' : 'pointer',
            background: recipientCount === 0 ? BX.mute2 : picked.danger ? BX.bad : BX.orange,
            color: picked.danger ? '#fff' : BX.navy,
            fontWeight: 700, fontSize: 14, display: 'flex', alignItems: 'center', gap: 8,
            opacity: recipientCount === 0 ? 0.5 : 1,
          }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M3 21l18-9L3 3l3 9-3 9Z"/></svg>
            Send to {recipientCount} {recipientCount === 1 ? 'tracker' : 'trackers'}
          </button>
        </div>
      </div>
    );
  }
  return (
    <div style={{ borderTop: `1px solid ${BX.rule}`, background: '#fff', padding: '16px 28px' }}>
      <button onClick={onOpen} disabled={recipientCount === 0} style={{
        width: '100%', padding: '14px', borderRadius: 12, border: `1px dashed ${BX.ruleS}`,
        background: BX.paper, color: BX.navy, fontWeight: 700, fontSize: 14.5,
        cursor: recipientCount === 0 ? 'not-allowed' : 'pointer',
        opacity: recipientCount === 0 ? 0.5 : 1,
        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 12,
      }}>
        <span style={{ fontSize: 22, color: BX.orange, fontWeight: 800, lineHeight: 1 }}>+</span>
        {recipientCount === 0 ? 'Select at least one tracker' : `Pick a command to send to ${recipientCount} ${recipientCount === 1 ? 'tracker' : 'trackers'}`}
      </button>
    </div>
  );
}

export default function SmsTab() {
  const [recipients, setRecipients] = useState(['2025000012','2025000025','2025000034']);
  const [panel, setPanel]   = useState('idle');
  const [picked, setPicked] = useState(null);

  const toggle = (id) => setRecipients(rs => rs.includes(id) ? rs.filter(r => r !== id) : [...rs, id]);

  const pick = (cmd) => {
    const val = cmd.input?.kind === 'toggle' ? (cmd.input.defaultValue ?? true) : (cmd.input?.defaultValue ?? '');
    setPicked({ ...cmd, value: val });
    setPanel('compose');
  };

  const cancel = () => { setPicked(null); setPanel('idle'); };

  return (
    <div style={{ width: '100%', height: '100%', display: 'flex' }}>
      <TrackerRail recipients={recipients} onToggle={toggle} />
      <main style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0, position: 'relative' }}>
        {/* Header */}
        <div style={{ padding: '18px 28px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: `1px solid ${BX.rule}`, background: '#fff' }}>
          <div>
            <div style={{ fontSize: 10.5, color: BX.orangeD, fontFamily: MONO, letterSpacing: 1.4, fontWeight: 700 }}>GROUP MESSAGE</div>
            <div style={{ fontSize: 20, fontWeight: 700, letterSpacing: -0.3, marginTop: 2 }}>
              {recipients.length} {recipients.length === 1 ? 'tracker' : 'trackers'} selected
            </div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            {recipients.slice(0, 4).map(id => {
              const t = WEB_TRACKERS.find(x => x.id === id);
              return t ? (
                <span key={id} style={{ padding: '5px 12px 5px 10px', borderRadius: 999, background: '#fff', border: `1px solid ${BX.rule}`, fontSize: 12.5, fontWeight: 600, color: BX.navy, display: 'flex', alignItems: 'center', gap: 6 }}>
                  <span style={{ width: 8, height: 8, borderRadius: '50%', background: t.tone }} />
                  {t.short}
                </span>
              ) : null;
            })}
            {recipients.length > 4 && <span style={{ fontSize: 12, color: BX.mute }}>+{recipients.length - 4} more</span>}
          </div>
        </div>
        {/* Conversation */}
        <div style={{ flex: 1, overflow: 'auto', padding: '22px 28px', background: BX.paper, minHeight: 0 }}>
          {WEB_HISTORY.map((thread, idx) => <Thread key={thread.id} thread={thread} showDate={idx === 0} />)}
        </div>
        <ComposeDock panel={panel} picked={picked} recipientCount={recipients.length} onOpen={() => setPanel('picker')} onCancel={cancel} onChange={v => setPicked({ ...picked, value: v })} />
        {panel === 'picker' && <CommandPicker onPick={pick} onClose={() => setPanel('idle')} />}
      </main>
    </div>
  );
}
