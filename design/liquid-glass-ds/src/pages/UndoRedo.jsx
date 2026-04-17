import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

export default function UndoRedo() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Undo & Redo</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Patterns for reversible actions, including shake to undo, toast confirmations, edit history, and gesture shortcuts.
      </p>

      {/* ── Shake to Undo ── */}
      <Section title="Shake to Undo" description="On iOS, shaking the device presents an undo alert. The alert uses a Liquid Glass style with clear action buttons.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 32, justifyContent: 'center', alignItems: 'center', flexWrap: 'wrap' }}>
            {/* Shake icon */}
            <div style={{ textAlign: 'center' }}>
              <div style={{
                width: 80,
                height: 140,
                borderRadius: 'var(--r-lg)',
                border: '2px solid rgba(255,255,255,0.3)',
                position: 'relative',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}>
                {/* Motion lines left */}
                <div style={{ position: 'absolute', left: -20, top: '50%', transform: 'translateY(-50%)', display: 'flex', flexDirection: 'column', gap: 6 }}>
                  {[12, 16, 12].map((w, i) => (
                    <div key={i} style={{ width: w, height: 2, background: 'rgba(255,255,255,0.3)', borderRadius: 1 }} />
                  ))}
                </div>
                {/* Motion lines right */}
                <div style={{ position: 'absolute', right: -20, top: '50%', transform: 'translateY(-50%)', display: 'flex', flexDirection: 'column', gap: 6 }}>
                  {[12, 16, 12].map((w, i) => (
                    <div key={i} style={{ width: w, height: 2, background: 'rgba(255,255,255,0.3)', borderRadius: 1 }} />
                  ))}
                </div>
                <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.4)' }}>Shake</span>
              </div>
            </div>

            {/* Phone frame with alert */}
            <div style={{
              width: 260,
              height: 480,
              borderRadius: 'var(--r-2xl)',
              border: '1.5px solid rgba(255,255,255,0.12)',
              background: 'rgba(255,255,255,0.03)',
              position: 'relative',
              overflow: 'hidden',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}>
              {/* Status bar */}
              <div style={{ position: 'absolute', top: 12, left: 20, right: 20, display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.3)' }}>9:41</span>
                <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.3)' }}>100%</span>
              </div>

              {/* Dimmed background */}
              <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.3)' }} />

              {/* Glass alert */}
              <div style={{
                position: 'relative',
                zIndex: 2,
                background: 'var(--glass-bg-thick)',
                backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
                WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-lg)',
                boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
                width: 220,
                overflow: 'hidden',
              }}>
                <div style={{ padding: '20px 20px 16px', textAlign: 'center' }}>
                  <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Undo Typing</div>
                  <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>
                    Are you sure you want to undo the last typing action?
                  </div>
                </div>
                <div style={{ borderTop: '0.5px solid var(--separator)', display: 'flex' }}>
                  <button style={{
                    flex: 1, padding: '12px 0', font: 'var(--text-body)',
                    color: 'var(--blue)', background: 'transparent', border: 'none',
                    cursor: 'pointer', borderRight: '0.5px solid var(--separator)',
                  }}>Cancel</button>
                  <button style={{
                    flex: 1, padding: '12px 0', font: 'var(--text-body)',
                    fontWeight: 600, color: 'var(--blue)', background: 'transparent',
                    border: 'none', cursor: 'pointer',
                  }}>Undo</button>
                </div>
              </div>
            </div>
          </div>
          <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.5)', textAlign: 'center', marginTop: 16 }}>
            Shake the device to trigger the undo alert
          </p>
        </Preview>
      </Section>

      {/* ── Toast with Undo ── */}
      <Section title="Toast with Undo" description="A brief glass toast appears at the bottom with an Undo action. Auto-dismisses after 5 seconds with a progress indicator.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16, maxWidth: 400, margin: '0 auto' }}>
            {[
              { message: 'Message deleted', progress: 80 },
              { message: 'Item moved to trash', progress: 50 },
              { message: 'Email archived', progress: 20 },
            ].map(({ message, progress }) => (
              <div key={message} style={{
                background: 'var(--glass-bg-thick)',
                backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
                WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-pill)',
                boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
                padding: '0',
                overflow: 'hidden',
                position: 'relative',
              }}>
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 8px 12px 20px',
                }}>
                  <span style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>{message}</span>
                  <button style={{
                    font: 'var(--text-subhead)', fontWeight: 600,
                    color: 'var(--blue)', background: 'transparent',
                    border: 'none', cursor: 'pointer', padding: '4px 12px',
                  }}>Undo</button>
                </div>
                {/* Progress bar */}
                <div style={{
                  position: 'absolute',
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 2,
                  background: 'rgba(255,255,255,0.08)',
                }}>
                  <div style={{
                    height: '100%',
                    width: `${progress}%`,
                    background: 'var(--blue)',
                    borderRadius: 1,
                    transition: 'width 200ms linear',
                  }} />
                </div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ── Edit History ── */}
      <Section title="Edit History" description="A panel showing a chronological list of actions that can be individually undone. The most recent action is highlighted.">
        <Preview>
          <div style={{ maxWidth: 400, margin: '0 auto' }}>
            <GlassPanel style={{
              padding: 0,
              overflow: 'hidden',
              boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
            }}>
              <div style={{
                padding: '16px 20px 12px',
                borderBottom: '0.5px solid var(--separator)',
              }}>
                <span style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>Edit History</span>
              </div>
              {[
                { action: 'Changed font to Helvetica', current: true },
                { action: 'Resized image to 200x200', current: false },
                { action: 'Added text layer', current: false },
                { action: 'Created new document', current: false },
              ].map(({ action, current }, i, arr) => (
                <div key={action} style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 12,
                  padding: '14px 20px',
                  borderBottom: i < arr.length - 1 ? '0.5px solid var(--separator)' : 'none',
                  background: current ? 'var(--glass-bg-tinted)' : 'transparent',
                }}>
                  {/* Undo arrow icon */}
                  <div style={{
                    width: 28,
                    height: 28,
                    borderRadius: 'var(--r-xs)',
                    background: current ? 'rgba(0,122,255,0.15)' : 'var(--fill-secondary)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    flexShrink: 0,
                  }}>
                    <svg width="14" height="14" viewBox="0 0 14 14" fill="none" style={{ opacity: 0.7 }}>
                      <path d="M3 5.5L1 7.5L3 9.5" stroke={current ? 'var(--blue)' : 'var(--label-secondary)'} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                      <path d="M1.5 7.5H9C10.933 7.5 12.5 5.933 12.5 4V3.5" stroke={current ? 'var(--blue)' : 'var(--label-secondary)'} strokeWidth="1.5" strokeLinecap="round" />
                    </svg>
                  </div>
                  <div style={{ flex: 1 }}>
                    <span style={{
                      font: 'var(--text-subhead)',
                      fontWeight: current ? 600 : 400,
                      color: 'var(--label)',
                    }}>{action}</span>
                  </div>
                  {current && (
                    <span style={{
                      font: 'var(--text-caption2)',
                      color: 'var(--blue)',
                      background: 'rgba(0,122,255,0.1)',
                      padding: '2px 8px',
                      borderRadius: 'var(--r-pill)',
                    }}>Current</span>
                  )}
                </div>
              ))}
            </GlassPanel>
          </div>
        </Preview>
      </Section>

      {/* ── Three-finger Gestures ── */}
      <Section title="Three-finger Gestures" description="iOS provides three-finger gesture shortcuts for undo, redo, and clipboard operations.">
        <Preview gradient>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: 16 }}>
            {[
              {
                label: 'Undo',
                desc: 'Three-finger swipe left',
                icon: (
                  <svg width="48" height="32" viewBox="0 0 48 32" fill="none">
                    <circle cx="16" cy="16" r="4" fill="rgba(255,255,255,0.6)" />
                    <circle cx="24" cy="10" r="4" fill="rgba(255,255,255,0.6)" />
                    <circle cx="32" cy="16" r="4" fill="rgba(255,255,255,0.6)" />
                    <path d="M12 22L4 16L12 10" stroke="var(--blue)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                ),
              },
              {
                label: 'Redo',
                desc: 'Three-finger swipe right',
                icon: (
                  <svg width="48" height="32" viewBox="0 0 48 32" fill="none">
                    <circle cx="16" cy="16" r="4" fill="rgba(255,255,255,0.6)" />
                    <circle cx="24" cy="10" r="4" fill="rgba(255,255,255,0.6)" />
                    <circle cx="32" cy="16" r="4" fill="rgba(255,255,255,0.6)" />
                    <path d="M36 10L44 16L36 22" stroke="var(--green)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                ),
              },
              {
                label: 'Copy / Cut / Paste',
                desc: 'Three-finger pinch',
                icon: (
                  <svg width="48" height="32" viewBox="0 0 48 32" fill="none">
                    <circle cx="14" cy="22" r="4" fill="rgba(255,255,255,0.6)" />
                    <circle cx="24" cy="8" r="4" fill="rgba(255,255,255,0.6)" />
                    <circle cx="34" cy="22" r="4" fill="rgba(255,255,255,0.6)" />
                    <path d="M16 20L22 12" stroke="var(--orange)" strokeWidth="1.5" strokeLinecap="round" strokeDasharray="2 3" />
                    <path d="M32 20L26 12" stroke="var(--orange)" strokeWidth="1.5" strokeLinecap="round" strokeDasharray="2 3" />
                  </svg>
                ),
              },
            ].map(({ label, desc, icon }) => (
              <div key={label} style={{
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-xl)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                padding: 24,
                textAlign: 'center',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: 12,
              }}>
                <div style={{ marginBottom: 4 }}>{icon}</div>
                <div style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>{label}</div>
                <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>{desc}</div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ── Guidelines ── */}
      <Section title="Undo/Redo Guidelines" description="Best practices for implementing undo and redo in your app.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: 16 }}>
          {[
            'Support at least 10 undo steps',
            'Show a brief toast confirming the undoable action',
            'Undo should reverse the LAST action exactly',
            'Destructive actions (delete account) should not be undoable \u2014 use confirmation instead',
          ].map((guideline) => (
            <GlassCard key={guideline} style={{ padding: 20 }}>
              <p style={{ font: 'var(--text-subhead)', color: 'var(--label)', margin: 0 }}>{guideline}</p>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs">
        <SpecTable
          headers={['Property', 'Value', 'Notes']}
          rows={[
            ['Toast duration', '5s', 'Auto-dismiss timeout'],
            ['Toast height', '44px', 'Minimum touch target'],
            ['Max undo history', '20 steps', 'Keep memory usage bounded'],
            ['Shake sensitivity', 'Medium', 'System default threshold'],
            ['Gesture swipe distance', '>100pt', 'Minimum distance to trigger'],
          ]}
        />
      </Section>
    </div>
  )
}
