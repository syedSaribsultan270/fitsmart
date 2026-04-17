import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

/* Mini waveform SVG helper */
function Waveform({ points, color = 'var(--blue)', width = 120, height = 32 }) {
  return (
    <svg width={width} height={height} viewBox={`0 0 ${width} ${height}`} fill="none" style={{ display: 'block' }}>
      <line x1="0" y1={height - 2} x2={width} y2={height - 2} stroke="rgba(255,255,255,0.1)" strokeWidth="1" />
      <path d={points} stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" fill="none" />
    </svg>
  )
}

export default function HapticPatterns() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Haptic Patterns</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Haptic feedback types, intensity patterns, and guidelines for when and how to use tactile responses in Apple platforms.
      </p>

      {/* ── Notification Haptics ── */}
      <Section title="Notification Haptics" description="Three notification haptic types used to confirm outcomes: success, warning, and error. Each has a distinct intensity pattern.">
        <Preview gradient>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: 16 }}>
            {[
              {
                type: 'Success',
                icon: '\u2713',
                color: 'var(--green)',
                bg: 'rgba(52,199,89,0.15)',
                border: 'rgba(52,199,89,0.3)',
                waveform: 'M4 28 L16 28 L18 8 L22 28 L34 28 L36 12 L40 28 L116 28',
              },
              {
                type: 'Warning',
                icon: '\u26a0',
                color: 'var(--orange)',
                bg: 'rgba(255,149,0,0.15)',
                border: 'rgba(255,149,0,0.3)',
                waveform: 'M4 28 L20 28 L22 4 L26 28 L40 28 L42 6 L46 28 L116 28',
              },
              {
                type: 'Error',
                icon: '\u2715',
                color: 'var(--red)',
                bg: 'rgba(255,59,48,0.15)',
                border: 'rgba(255,59,48,0.3)',
                waveform: 'M4 28 L14 28 L16 16 L20 28 L28 28 L30 10 L34 28 L42 28 L44 4 L48 28 L116 28',
              },
            ].map(({ type, icon, color, bg, border, waveform }) => (
              <div key={type} style={{
                background: bg,
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: `0.5px solid ${border}`,
                borderRadius: 'var(--r-xl)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                padding: 20,
                textAlign: 'center',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: 12,
              }}>
                <div style={{
                  width: 44,
                  height: 44,
                  borderRadius: '50%',
                  background: bg,
                  border: `1.5px solid ${border}`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: 20,
                  color: color,
                }}>{icon}</div>
                <div style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>{type}</div>
                <Waveform points={waveform} color={color} />
                <div style={{
                  font: 'var(--text-caption1)',
                  color: 'var(--label-tertiary)',
                  padding: '4px 12px',
                  background: 'rgba(255,255,255,0.06)',
                  borderRadius: 'var(--r-pill)',
                }}>Play</div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ── Impact Haptics ── */}
      <Section title="Impact Haptics" description="Five intensity levels for physical collision feedback. Each level suits different interaction weights.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 20, justifyContent: 'center', alignItems: 'flex-end', flexWrap: 'wrap' }}>
            {[
              { label: 'Light', size: 48, opacity: 0.5, waveform: 'M4 28 L20 28 L22 20 L24 28 L52 28' },
              { label: 'Medium', size: 56, opacity: 0.65, waveform: 'M4 28 L18 28 L20 14 L24 28 L52 28' },
              { label: 'Heavy', size: 64, opacity: 0.8, waveform: 'M4 28 L16 28 L18 6 L24 28 L52 28' },
              { label: 'Rigid', size: 56, opacity: 0.75, waveform: 'M4 28 L16 28 L16 6 L24 6 L24 28 L52 28' },
              { label: 'Soft', size: 56, opacity: 0.6, waveform: 'M4 28 Q12 28 16 10 Q20 28 28 28 L52 28' },
            ].map(({ label, size, opacity, waveform }) => (
              <div key={label} style={{ textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10 }}>
                {/* Circle button */}
                <div style={{
                  width: size,
                  height: size,
                  borderRadius: '50%',
                  background: `rgba(0,122,255,${opacity})`,
                  backdropFilter: 'blur(var(--blur-sm))',
                  WebkitBackdropFilter: 'blur(var(--blur-sm))',
                  border: '0.5px solid rgba(255,255,255,0.2)',
                  boxShadow: 'var(--glass-shadow)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  transition: 'transform var(--dur-fast) var(--ease-spring)',
                }}>
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="white" opacity="0.9">
                    <path d="M4 2.5L13 8L4 13.5V2.5Z" />
                  </svg>
                </div>
                <span style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>{label}</span>
                <Waveform points={waveform} color="var(--blue)" width={56} height={28} />
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ── Selection Haptic ── */}
      <Section title="Selection Haptic" description="A single light tick that fires when a UI selection changes, such as switching segments or scrolling a picker.">
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24 }}>
            {/* Segment control mock */}
            <div style={{
              display: 'flex',
              background: 'var(--glass-inner)',
              borderRadius: 'var(--r-pill)',
              padding: 3,
              border: '0.5px solid var(--glass-border)',
              gap: 2,
            }}>
              {['Daily', 'Weekly', 'Monthly'].map((seg, i) => (
                <div key={seg} style={{
                  padding: '8px 20px',
                  borderRadius: 'var(--r-pill)',
                  font: 'var(--text-subhead)',
                  fontWeight: i === 1 ? 600 : 400,
                  color: i === 1 ? 'var(--label)' : 'var(--label-secondary)',
                  background: i === 1 ? 'var(--glass-bg)' : 'transparent',
                  boxShadow: i === 1 ? 'var(--glass-shadow)' : 'none',
                  cursor: 'pointer',
                  transition: 'all var(--dur) var(--ease)',
                }}>{seg}</div>
              ))}
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>Selection tick waveform:</span>
              <Waveform points="M4 28 L30 28 L32 16 L34 28 L80 28" color="var(--blue)" width={84} height={28} />
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Custom Haptic Patterns ── */}
      <Section title="Custom Haptic Patterns" description="Build complex haptic patterns from transient events (sharp spikes) and continuous events (sustained vibration), controlling sharpness and intensity.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 24, maxWidth: 500, margin: '0 auto' }}>
            {/* Axes explanation */}
            <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap' }}>
              <div style={{
                flex: 1,
                minWidth: 180,
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-md)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-md)) saturate(180%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-lg)',
                padding: 16,
              }}>
                <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 8 }}>Sharpness</div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>0 = Round</span>
                  <div style={{ flex: 1, height: 2, background: 'linear-gradient(to right, var(--blue), var(--orange))', margin: '0 12px', borderRadius: 1 }} />
                  <span style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>1 = Sharp</span>
                </div>
              </div>
              <div style={{
                flex: 1,
                minWidth: 180,
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-md)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-md)) saturate(180%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-lg)',
                padding: 16,
              }}>
                <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 8 }}>Intensity</div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>0 = Light</span>
                  <div style={{ flex: 1, height: 2, background: 'linear-gradient(to right, rgba(255,255,255,0.2), white)', margin: '0 12px', borderRadius: 1 }} />
                  <span style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>1 = Strong</span>
                </div>
              </div>
            </div>

            {/* Building blocks */}
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-md)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-md)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-lg)',
              padding: 16,
            }}>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 12 }}>Event Types</div>
              <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <Waveform points="M4 26 L14 26 L16 4 L18 26 L48 26" color="var(--orange)" width={52} height={28} />
                  <span style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>Transient</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <Waveform points="M4 26 L14 26 L14 12 L38 12 L38 26 L48 26" color="var(--teal)" width={52} height={28} />
                  <span style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>Continuous</span>
                </div>
              </div>
            </div>

            {/* Custom pattern timeline */}
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-md)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-md)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-lg)',
              padding: 16,
            }}>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 12 }}>Custom Pattern</div>
              <div style={{ display: 'flex', alignItems: 'flex-end', gap: 4, height: 56, padding: '0 8px' }}>
                {/* Transient 0.8 */}
                <div style={{
                  width: 8,
                  height: '80%',
                  background: 'var(--orange)',
                  borderRadius: '2px 2px 0 0',
                  opacity: 0.9,
                }} />
                {/* Pause */}
                <div style={{
                  width: 20,
                  height: 2,
                  background: 'rgba(255,255,255,0.1)',
                  alignSelf: 'flex-end',
                  marginBottom: 0,
                }} />
                {/* Continuous 0.3, 200ms */}
                <div style={{
                  width: 60,
                  height: '30%',
                  background: 'var(--teal)',
                  borderRadius: '2px 2px 0 0',
                  opacity: 0.8,
                }} />
                {/* Transient 1.0 */}
                <div style={{
                  width: 8,
                  height: '100%',
                  background: 'var(--orange)',
                  borderRadius: '2px 2px 0 0',
                }} />
              </div>
              {/* Labels */}
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 4, padding: '6px 8px 0', fontSize: 10 }}>
                <span style={{ width: 8, textAlign: 'center', color: 'var(--orange)', fontFamily: 'var(--font-mono)' }}>T</span>
                <span style={{ width: 20, textAlign: 'center', color: 'var(--label-quaternary)', fontFamily: 'var(--font-mono)' }}>50ms</span>
                <span style={{ width: 60, textAlign: 'center', color: 'var(--teal)', fontFamily: 'var(--font-mono)' }}>C 200ms</span>
                <span style={{ width: 8, textAlign: 'center', color: 'var(--orange)', fontFamily: 'var(--font-mono)' }}>T</span>
              </div>
              <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', marginTop: 8, fontFamily: 'var(--font-mono)' }}>
                transient(0.8) &rarr; pause(50ms) &rarr; continuous(0.3, 200ms) &rarr; transient(1.0)
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Platform Haptic Reference ── */}
      <Section title="Platform Haptic Reference" description="Available haptic APIs across Apple platforms.">
        <SpecTable
          headers={['Platform', 'API', 'Types']}
          rows={[
            ['iOS', 'UIFeedbackGenerator', 'Notification, Impact, Selection'],
            ['watchOS', 'WKHapticType', 'notification, directionUp, directionDown, success, failure, retry, start, stop, click'],
            ['macOS', 'NSHapticFeedbackManager', 'alignment, levelChange, generic'],
          ]}
        />
      </Section>

      {/* ── When to Use Haptics ── */}
      <Section title="When to Use Haptics" description="Match the right haptic type to each user action for meaningful tactile feedback.">
        <SpecTable
          headers={['Action', 'Haptic Type', 'Why']}
          rows={[
            ['Toggle switch', 'Impact (light)', 'Confirms state change'],
            ['Pull to refresh release', 'Impact (medium)', 'Threshold crossed'],
            ['Delete', 'Notification (warning)', 'Destructive action'],
            ['Success', 'Notification (success)', 'Task completed'],
            ['Scroll to end', 'Impact (rigid)', 'Boundary reached'],
            ['Picker scroll', 'Selection', 'Value changed'],
            ['Long press activate', 'Impact (heavy)', 'Context menu'],
          ]}
        />
      </Section>

      {/* ── Guidelines ── */}
      <Section title="Guidelines" description="Principles for effective haptic design.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: 16 }}>
          {[
            'Haptics should confirm, not distract',
            'Match intensity to the importance of the action',
            'Never use haptics for ongoing animations',
            'Respect the system haptic settings',
          ].map((guideline) => (
            <GlassCard key={guideline} style={{ padding: 20 }}>
              <p style={{ font: 'var(--text-subhead)', color: 'var(--label)', margin: 0 }}>{guideline}</p>
            </GlassCard>
          ))}
        </div>
      </Section>
    </div>
  )
}
