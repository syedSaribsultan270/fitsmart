import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

export default function Notifications() {
  const [expanded, setExpanded] = useState(false)

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Notifications</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Banner, alert, grouping, rich media, and priority-level notification patterns with Liquid Glass materials.
      </p>

      {/* ── Banner ── */}
      <Section title="Banner" description="Standard notification banner that slides down from the top and auto-dismisses. Swipe right to dismiss, tap to open.">
        <Preview gradient style={{ padding: '40px 16px 24px' }}>
          <div style={{ maxWidth: 400, margin: '0 auto' }}>
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
              WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
              padding: '12px 16px',
              display: 'flex', alignItems: 'center', gap: 12,
              cursor: 'pointer',
            }}>
              <div style={{
                width: 32, height: 32, borderRadius: 'var(--r-xs)', flexShrink: 0,
                background: 'var(--green)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <span style={{ color: '#fff', fontSize: 16, fontWeight: 700 }}>M</span>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 2 }}>
                  <span style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>Messages</span>
                  <span style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', flexShrink: 0 }}>now</span>
                </div>
                <span style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)', display: 'block', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                  Hey, are you free?
                </span>
              </div>
            </div>
            <p style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.35)', textAlign: 'center', marginTop: 12 }}>
              Swipe right to dismiss &bull; Tap to open
            </p>
          </div>
        </Preview>
      </Section>

      {/* ── Alert ── */}
      <Section title="Alert" description="Persistent notification alert that stays on screen until the user takes action. More prominent than banners.">
        <Preview gradient style={{ padding: 32 }}>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <div style={{
              width: 300,
              background: 'var(--glass-bg-thick)',
              backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
              WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
              overflow: 'hidden',
            }}>
              <div style={{ padding: '20px 20px 16px', textAlign: 'center' }}>
                <div style={{
                  width: 40, height: 40, borderRadius: 'var(--r-sm)', margin: '0 auto 12px',
                  background: 'var(--blue)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <span style={{ color: '#fff', fontSize: 20, fontWeight: 700 }}>R</span>
                </div>
                <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 4 }}>Reminder</div>
                <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
                  Team meeting starts in 5 minutes. Join the call now.
                </div>
              </div>
              <div style={{ display: 'flex', borderTop: '0.5px solid var(--separator)' }}>
                <button style={{
                  flex: 1, padding: '14px 0', textAlign: 'center',
                  font: 'var(--text-body)', color: 'var(--label-secondary)',
                  background: 'transparent', border: 'none', cursor: 'pointer',
                  borderRight: '0.5px solid var(--separator)',
                }}>Dismiss</button>
                <button style={{
                  flex: 1, padding: '14px 0', textAlign: 'center',
                  font: 'var(--text-body)', fontWeight: 600, color: 'var(--blue)',
                  background: 'transparent', border: 'none', cursor: 'pointer',
                }}>View</button>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Notification Grouping ── */}
      <Section title="Notification Grouping" description="Stacked notifications from the same app. Tap to expand and view individually.">
        <Preview gradient style={{ padding: '24px 16px' }}>
          <div style={{ maxWidth: 400, margin: '0 auto' }}>
            {!expanded ? (
              <div style={{ cursor: 'pointer' }} onClick={() => setExpanded(true)}>
                {/* Stacked cards */}
                <div style={{ position: 'relative', height: 120 }}>
                  {[2, 1, 0].map((i) => (
                    <div key={i} style={{
                      position: 'absolute',
                      top: i * 6,
                      left: i * 4, right: i * 4,
                      background: 'var(--glass-bg)',
                      backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
                      WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
                      border: '0.5px solid var(--glass-border)',
                      borderRadius: 'var(--r-xl)',
                      boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                      padding: '12px 16px',
                      display: 'flex', alignItems: 'center', gap: 12,
                      opacity: i === 0 ? 1 : 0.7 - i * 0.2,
                      zIndex: 3 - i,
                    }}>
                      {i === 0 && <>
                        <div style={{
                          width: 32, height: 32, borderRadius: 'var(--r-xs)', flexShrink: 0,
                          background: 'var(--green)',
                          display: 'flex', alignItems: 'center', justifyContent: 'center',
                        }}>
                          <span style={{ color: '#fff', fontSize: 16, fontWeight: 700 }}>M</span>
                        </div>
                        <div style={{ flex: 1 }}>
                          <span style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>Messages</span>
                          <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>See you at 7!</div>
                        </div>
                        <span style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>2m ago</span>
                      </>}
                    </div>
                  ))}
                </div>
                <p style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.4)', textAlign: 'center', marginTop: 16 }}>
                  3 more notifications from Messages &bull; Tap to expand
                </p>
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                {['See you at 7!', 'Can you bring the charger?', 'On my way now'].map((msg, i) => (
                  <div key={i} style={{
                    background: 'var(--glass-bg)',
                    backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
                    WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
                    border: '0.5px solid var(--glass-border)',
                    borderRadius: 'var(--r-xl)',
                    boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                    padding: '12px 16px',
                    display: 'flex', alignItems: 'center', gap: 12,
                  }}>
                    <div style={{
                      width: 32, height: 32, borderRadius: 'var(--r-xs)', flexShrink: 0,
                      background: 'var(--green)',
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                    }}>
                      <span style={{ color: '#fff', fontSize: 16, fontWeight: 700 }}>M</span>
                    </div>
                    <div style={{ flex: 1 }}>
                      <span style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>Messages</span>
                      <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>{msg}</div>
                    </div>
                    <span style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>{i + 1}m ago</span>
                  </div>
                ))}
                <div style={{ textAlign: 'center', marginTop: 8 }}>
                  <GlassButton variant="plain" size="sm" onClick={() => setExpanded(false)}>Collapse</GlassButton>
                </div>
              </div>
            )}
          </div>
        </Preview>
      </Section>

      {/* ── Rich Notifications ── */}
      <Section title="Rich Notifications" description="Notifications with image attachments, action buttons, and expandable content via long-press.">
        <Preview gradient style={{ padding: '24px 16px' }}>
          <div style={{ maxWidth: 400, margin: '0 auto' }}>
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
              WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
              overflow: 'hidden',
            }}>
              <div style={{ padding: '12px 16px', display: 'flex', gap: 12 }}>
                <div style={{ flex: 1 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
                    <div style={{
                      width: 20, height: 20, borderRadius: 5, background: 'var(--purple)',
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                    }}>
                      <span style={{ color: '#fff', fontSize: 10, fontWeight: 700 }}>P</span>
                    </div>
                    <span style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label)' }}>Photos</span>
                    <span style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>5m ago</span>
                  </div>
                  <span style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)', display: 'block', marginBottom: 2 }}>New Memory Available</span>
                  <span style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>A trip to the coast last summer</span>
                </div>
                {/* Thumbnail */}
                <div style={{
                  width: 48, height: 48, borderRadius: 'var(--r-sm)', flexShrink: 0,
                  background: 'linear-gradient(135deg, var(--cyan), var(--blue))',
                }} />
              </div>
              {/* Action buttons */}
              <div style={{ display: 'flex', borderTop: '0.5px solid var(--separator)' }}>
                {['Reply', 'Like', 'Mute'].map((action, i, arr) => (
                  <button key={action} style={{
                    flex: 1, padding: '12px 0', textAlign: 'center',
                    font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--blue)',
                    background: 'transparent', border: 'none', cursor: 'pointer',
                    borderRight: i < arr.length - 1 ? '0.5px solid var(--separator)' : 'none',
                  }}>{action}</button>
                ))}
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Time-Sensitive ── */}
      <Section title="Time-Sensitive" description="Notification priority levels determine interruption behavior and visual prominence.">
        <Preview gradient style={{ padding: '24px 16px' }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12, maxWidth: 400, margin: '0 auto' }}>
            {[
              { level: 'Passive', badge: 'var(--gray)', desc: 'Summary only', label: 'App update available' },
              { level: 'Active', badge: 'var(--blue)', desc: 'Default banner', label: 'New message from Alex' },
              { level: 'Time-Sensitive', badge: 'var(--yellow)', desc: 'Breaks through Focus', label: 'Flight boards in 30 minutes' },
              { level: 'Critical', badge: 'var(--red)', desc: 'Plays sound even in silent', label: 'Severe weather warning' },
            ].map((n) => (
              <div key={n.level} style={{
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
                WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-lg)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                padding: '12px 16px',
                display: 'flex', alignItems: 'center', gap: 12,
              }}>
                <div style={{
                  width: 10, height: 10, borderRadius: '50%', flexShrink: 0,
                  background: n.badge,
                  boxShadow: `0 0 6px ${n.badge}50`,
                }} />
                <div style={{ flex: 1 }}>
                  <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
                    <span style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>{n.level}</span>
                    <span style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>{n.desc}</span>
                  </div>
                  <span style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>{n.label}</span>
                </div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs" description="Notification dimensions and limits.">
        <SpecTable
          headers={['Property', 'Value']}
          rows={[
            ['Banner height', '~90 pt'],
            ['App icon size', '32 x 32 pt'],
            ['Max action buttons', '4'],
            ['Grouping', 'Automatic by app'],
            ['Rich media max', '1024 x 1024 px'],
          ]}
        />
      </Section>
    </div>
  )
}
