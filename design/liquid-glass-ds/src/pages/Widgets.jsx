import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

export default function Widgets() {
  const [todoChecked, setTodoChecked] = useState(false)
  const [timerRunning, setTimerRunning] = useState(false)

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Widgets</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Home Screen, Lock Screen, and StandBy widget form factors with sizing, layout grids, and interaction patterns.
      </p>

      {/* ── Widget Sizes ── */}
      <Section title="Widget Sizes" description="Four standard widget form factors for iPhone and iPad Home Screens.">
        <Preview gradient>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 20, justifyContent: 'center', alignItems: 'flex-start' }}>
            {/* Small */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 170, height: 170,
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-xl)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                padding: 16,
              }}>
                <span style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)', marginBottom: 4 }}>San Francisco</span>
                <span style={{ fontSize: 48, fontWeight: 200, color: 'var(--label)', lineHeight: 1 }}>72&deg;</span>
                <span style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', marginTop: 4 }}>Partly Cloudy</span>
              </div>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)' }}>Small &mdash; 170x170</span>
            </div>

            {/* Medium */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 364, height: 170,
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-xl)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                display: 'flex', alignItems: 'center', gap: 16,
                padding: 16,
              }}>
                <div style={{ display: 'flex', flexDirection: 'column', flex: 1 }}>
                  <span style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 8 }}>Monday, Mar 30</span>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                      <div style={{ width: 4, height: 4, borderRadius: 2, background: 'var(--blue)' }} />
                      <span style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>Team Standup 9:00 AM</span>
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                      <div style={{ width: 4, height: 4, borderRadius: 2, background: 'var(--green)' }} />
                      <span style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>Lunch with Alex 12:30 PM</span>
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                      <div style={{ width: 4, height: 4, borderRadius: 2, background: 'var(--orange)' }} />
                      <span style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>Design Review 3:00 PM</span>
                    </div>
                  </div>
                </div>
              </div>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)' }}>Medium &mdash; 364x170</span>
            </div>

            {/* Large */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 364, height: 382,
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-xl)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                padding: 16,
                display: 'flex', flexDirection: 'column',
              }}>
                <span style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 12 }}>Notes</span>
                {['Meeting notes from Thursday', 'Shopping list for weekend', 'Book recommendations', 'Project timeline draft', 'Workout plan Week 12', 'Travel packing list'].map((note, i) => (
                  <div key={i} style={{
                    padding: '10px 0',
                    borderBottom: i < 5 ? '0.5px solid var(--separator)' : 'none',
                  }}>
                    <span style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>{note}</span>
                    <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', marginTop: 2 }}>Updated {i + 1}h ago</div>
                  </div>
                ))}
              </div>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)' }}>Large &mdash; 364x382</span>
            </div>

            {/* Extra Large */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 364, height: 382,
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-xl)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                padding: 16,
                display: 'flex', flexDirection: 'column',
              }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
                  <span style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>Activity</span>
                  <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>iPad Only</span>
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, flex: 1 }}>
                  {[
                    { label: 'Move', value: '420', unit: 'CAL', color: 'var(--red)' },
                    { label: 'Exercise', value: '35', unit: 'MIN', color: 'var(--green)' },
                    { label: 'Stand', value: '10', unit: 'HRS', color: 'var(--cyan)' },
                    { label: 'Steps', value: '8,241', unit: '', color: 'var(--orange)' },
                  ].map((item) => (
                    <div key={item.label} style={{
                      background: 'var(--glass-inner)',
                      borderRadius: 'var(--r-md)',
                      padding: 12,
                      display: 'flex', flexDirection: 'column', justifyContent: 'center',
                    }}>
                      <span style={{ font: 'var(--text-caption1)', color: item.color, fontWeight: 600 }}>{item.label}</span>
                      <span style={{ fontSize: 28, fontWeight: 700, color: 'var(--label)', lineHeight: 1.2 }}>{item.value}</span>
                      {item.unit && <span style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>{item.unit}</span>}
                    </div>
                  ))}
                </div>
              </div>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)' }}>Extra Large &mdash; 364x382 (iPad)</span>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Lock Screen Widgets ── */}
      <Section title="Lock Screen Widgets" description="Compact widget placements on the iOS Lock Screen, designed to be glanceable on a dark background.">
        <Preview gradient style={{ padding: 32 }}>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24 }}>
            {/* Inline widget */}
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 1 }}>Inline</span>
              <div style={{
                display: 'inline-flex', alignItems: 'center', gap: 6,
                padding: '4px 10px',
                background: 'rgba(255,255,255,0.12)',
                borderRadius: 'var(--r-pill)',
              }}>
                <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.85)' }}>Monday, Mar 30 &mdash; 72&deg; Partly Cloudy</span>
              </div>
            </div>

            <div style={{ display: 'flex', gap: 24, alignItems: 'center', flexWrap: 'wrap', justifyContent: 'center' }}>
              {/* Circular widget */}
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                <div style={{
                  width: 50, height: 50,
                  borderRadius: '50%',
                  background: 'rgba(255,255,255,0.12)',
                  backdropFilter: 'blur(var(--blur-sm))',
                  WebkitBackdropFilter: 'blur(var(--blur-sm))',
                  border: '0.5px solid rgba(255,255,255,0.15)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <span style={{ fontSize: 18, fontWeight: 600, color: 'rgba(255,255,255,0.9)' }}>72</span>
                </div>
                <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.4)' }}>Circular 50x50</span>
              </div>

              {/* Rectangular widget */}
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                <div style={{
                  width: 172, height: 50,
                  borderRadius: 'var(--r-md)',
                  background: 'rgba(255,255,255,0.12)',
                  backdropFilter: 'blur(var(--blur-sm))',
                  WebkitBackdropFilter: 'blur(var(--blur-sm))',
                  border: '0.5px solid rgba(255,255,255,0.15)',
                  display: 'flex', alignItems: 'center', gap: 10, padding: '0 12px',
                }}>
                  <div style={{
                    width: 28, height: 28, borderRadius: 'var(--r-xs)',
                    background: 'var(--blue)', display: 'flex', alignItems: 'center', justifyContent: 'center',
                  }}>
                    <span style={{ color: '#fff', fontSize: 14, fontWeight: 600 }}>W</span>
                  </div>
                  <div>
                    <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'rgba(255,255,255,0.9)' }}>72&deg; Cloudy</div>
                    <div style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.5)' }}>H:78&deg; L:62&deg;</div>
                  </div>
                </div>
                <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.4)' }}>Rectangular 172x50</span>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Widget Design Grid ── */}
      <Section title="Widget Design Grid" description="Content layout guidelines within widget boundaries. Widgets inherit the system corner radius from the Home Screen.">
        <Preview gradient>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <div style={{ position: 'relative', width: 170, height: 170 }}>
              {/* Outer widget boundary */}
              <div style={{
                position: 'absolute', inset: 0,
                border: '1.5px dashed rgba(0,122,255,0.4)',
                borderRadius: 'var(--r-xl)',
              }} />
              {/* Padding indicator */}
              <div style={{
                position: 'absolute', inset: 16,
                border: '1px dashed rgba(52,199,89,0.4)',
                borderRadius: 'var(--r-sm)',
              }} />
              {/* Content area */}
              <div style={{
                position: 'absolute', inset: 16,
                background: 'var(--glass-bg-thin)',
                backdropFilter: 'blur(var(--blur-sm))',
                WebkitBackdropFilter: 'blur(var(--blur-sm))',
                borderRadius: 'var(--r-sm)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.5)' }}>Content</span>
              </div>
              {/* Padding labels */}
              <div style={{ position: 'absolute', top: 2, left: '50%', transform: 'translateX(-50)', font: 'var(--text-caption2)', color: 'var(--blue)' }}>16px</div>
              <div style={{ position: 'absolute', left: 2, top: '50%', transform: 'translateY(-50%) rotate(-90deg)', font: 'var(--text-caption2)', color: 'var(--blue)' }}>16px</div>
              {/* Corner radius label */}
              <div style={{ position: 'absolute', bottom: -24, left: '50%', transform: 'translateX(-50%)', font: 'var(--text-caption2)', color: 'var(--green)', whiteSpace: 'nowrap' }}>Corner: var(--r-xl)</div>
            </div>
          </div>
          <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.5)', textAlign: 'center', marginTop: 32 }}>
            Use system corner radius &mdash; widgets inherit the Home Screen radius.
          </p>
        </Preview>
      </Section>

      {/* ── Interactive Widgets ── */}
      <Section title="Interactive Widgets" description="Widgets can contain tappable elements powered by App Intents. Users interact without launching the full app.">
        <Preview gradient>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 20, justifyContent: 'center' }}>
            {/* Toggle widget */}
            <div style={{
              width: 170, height: 170,
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              padding: 16, display: 'flex', flexDirection: 'column',
            }}>
              <span style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label)', marginBottom: 12 }}>To-Do</span>
              {['Buy groceries', 'Call dentist', 'Review PR'].map((item, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '4px 0', cursor: 'pointer' }}
                  onClick={() => i === 0 && setTodoChecked(v => !v)}>
                  <div style={{
                    width: 20, height: 20, borderRadius: 'var(--r-xs)', flexShrink: 0,
                    border: '1.5px solid var(--separator)',
                    background: (i === 0 && todoChecked) ? 'var(--blue)' : 'transparent',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    transition: 'all var(--dur) var(--ease)',
                  }}>
                    {i === 0 && todoChecked && <span style={{ color: '#fff', fontSize: 12 }}>&#10003;</span>}
                  </div>
                  <span style={{
                    font: 'var(--text-caption1)', color: 'var(--label-secondary)',
                    textDecoration: (i === 0 && todoChecked) ? 'line-through' : 'none',
                  }}>{item}</span>
                </div>
              ))}
            </div>

            {/* Button widget */}
            <div style={{
              width: 170, height: 170,
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              padding: 16, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 12,
            }}>
              <span style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label)' }}>Timer</span>
              <span style={{ fontSize: 32, fontWeight: 300, color: 'var(--label)', fontVariantNumeric: 'tabular-nums' }}>
                {timerRunning ? '4:32' : '5:00'}
              </span>
              <button onClick={() => setTimerRunning(v => !v)} style={{
                width: 44, height: 44, borderRadius: '50%', border: 'none', cursor: 'pointer',
                background: timerRunning ? 'var(--red)' : 'var(--green)',
                color: '#fff', fontSize: 14, fontWeight: 600,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                transition: 'background var(--dur) var(--ease)',
              }}>
                {timerRunning ? 'Stop' : 'Start'}
              </button>
            </div>
          </div>
          <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.5)', textAlign: 'center', marginTop: 16 }}>
            Interactive widgets use App Intents to handle taps without launching the full app.
          </p>
        </Preview>
      </Section>

      {/* ── StandBy Mode ── */}
      <Section title="StandBy Mode" description="Full-screen widget display when iPhone is charging in landscape orientation.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            {/* Normal StandBy */}
            <div style={{
              width: '100%', maxWidth: 500, height: 200, margin: '0 auto',
              background: 'rgba(0,0,0,0.6)',
              borderRadius: 'var(--r-xl)',
              border: '1px solid rgba(255,255,255,0.08)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              padding: 24,
            }}>
              <div style={{ textAlign: 'center' }}>
                <span style={{ fontSize: 64, fontWeight: 200, color: 'rgba(255,255,255,0.9)', letterSpacing: -2, fontVariantNumeric: 'tabular-nums' }}>10:30</span>
                <div style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.4)', marginTop: 4 }}>Monday, March 30</div>
              </div>
            </div>

            {/* Night mode (red tint) */}
            <div style={{
              width: '100%', maxWidth: 500, height: 200, margin: '0 auto',
              background: 'rgba(30,0,0,0.8)',
              borderRadius: 'var(--r-xl)',
              border: '1px solid rgba(255,60,48,0.15)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              padding: 24,
            }}>
              <div style={{ textAlign: 'center' }}>
                <span style={{ fontSize: 64, fontWeight: 200, color: 'rgba(255,60,48,0.7)', letterSpacing: -2, fontVariantNumeric: 'tabular-nums' }}>10:30</span>
                <div style={{ font: 'var(--text-subhead)', color: 'rgba(255,60,48,0.3)', marginTop: 4 }}>Monday, March 30</div>
              </div>
            </div>
            <p style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.4)', textAlign: 'center' }}>
              Night mode applies a red tint to reduce eye strain in dark environments. StandBy layouts use landscape-specific designs.
            </p>
          </div>
        </Preview>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs" description="Standard widget dimensions and layout values.">
        <SpecTable
          headers={['Element', 'Value']}
          rows={[
            ['Small widget', '170 x 170 pt'],
            ['Medium widget', '364 x 170 pt'],
            ['Large widget', '364 x 382 pt'],
            ['Extra Large widget (iPad)', '364 x 382 pt'],
            ['Lock Screen circular', '50 x 50 pt'],
            ['Lock Screen rectangular', '172 x 50 pt'],
            ['Content padding', '16 px'],
            ['Corner radius', 'System (var(--r-xl))'],
          ]}
        />
      </Section>
    </div>
  )
}
