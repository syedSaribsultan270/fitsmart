import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassButton } from '../components/Glass'

/* ── Reusable inline glass style ── */
const glassPanel = {
  background: 'var(--glass-bg-thick)',
  backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
  WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
  border: '0.5px solid var(--glass-border)',
  borderRadius: 'var(--r-xl)',
  boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
}

/* ── Arrow factory (CSS border triangle) ── */
function Arrow({ direction = 'top', tint }) {
  const size = 10
  const color = tint || 'var(--glass-bg-thick)'
  const base = {
    position: 'absolute',
    width: 0,
    height: 0,
    borderStyle: 'solid',
  }
  const styles = {
    top: {
      ...base,
      top: -size,
      left: '50%',
      transform: 'translateX(-50%)',
      borderWidth: `0 ${size}px ${size}px ${size}px`,
      borderColor: `transparent transparent ${color} transparent`,
    },
    bottom: {
      ...base,
      bottom: -size,
      left: '50%',
      transform: 'translateX(-50%)',
      borderWidth: `${size}px ${size}px 0 ${size}px`,
      borderColor: `${color} transparent transparent transparent`,
    },
    left: {
      ...base,
      left: -size,
      top: '50%',
      transform: 'translateY(-50%)',
      borderWidth: `${size}px ${size}px ${size}px 0`,
      borderColor: `transparent ${color} transparent transparent`,
    },
    right: {
      ...base,
      right: -size,
      top: '50%',
      transform: 'translateY(-50%)',
      borderWidth: `${size}px 0 ${size}px ${size}px`,
      borderColor: `transparent transparent transparent ${color}`,
    },
  }
  return <div style={styles[direction]} />
}

export default function Popovers() {
  const [actionsOpen] = useState(true)

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Popovers</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Floating glass panels anchored to a trigger, with directional arrows and adaptive behavior across screen sizes.
      </p>

      {/* ── 1. Standard Popover ── */}
      <Section title="Standard Popover" description="Glass panels with directional arrows pointing top, bottom, left, and right.">
        <Preview gradient style={{ minHeight: 320 }}>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 40, justifyItems: 'center', padding: '24px 0' }}>
            {['top', 'bottom', 'left', 'right'].map((dir) => (
              <div key={dir} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 1 }}>
                  Arrow {dir}
                </span>
                <div style={{ position: 'relative', ...glassPanel, padding: '16px 20px', maxWidth: 220, marginTop: dir === 'top' ? 16 : 0, marginBottom: dir === 'bottom' ? 16 : 0, marginLeft: dir === 'left' ? 16 : 0, marginRight: dir === 'right' ? 16 : 0 }}>
                  <Arrow direction={dir} />
                  <div style={{ font: 'var(--text-headline)', marginBottom: 4 }}>Popover Title</div>
                  <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 12 }}>
                    Brief description of the popover content.
                  </div>
                  <GlassButton variant="tinted" size="sm">Action</GlassButton>
                </div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ── 2. Tip Popover ── */}
      <Section title="Tip Popover" description="Feature discovery callout with blue-tinted glass and dismiss control.">
        <Preview gradient>
          <div style={{ display: 'flex', justifyContent: 'center', padding: '32px 0' }}>
            <div style={{
              position: 'relative',
              background: 'var(--glass-bg-tinted)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid rgba(0,122,255,0.2)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
              padding: '16px 20px',
              maxWidth: 260,
            }}>
              <Arrow direction="bottom" tint="rgba(0,122,255,0.1)" />
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div>
                  <div style={{ font: 'var(--text-headline)', color: 'var(--blue)', marginBottom: 4 }}>New Feature</div>
                  <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
                    Tap here to access your library
                  </div>
                </div>
                <button style={{
                  background: 'rgba(255,255,255,0.15)',
                  border: 'none',
                  borderRadius: '50%',
                  width: 24,
                  height: 24,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  color: 'var(--label-secondary)',
                  fontSize: 14,
                  fontWeight: 600,
                  flexShrink: 0,
                  marginLeft: 12,
                }}>
                  &#10005;
                </button>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── 3. Adaptive Popover ── */}
      <Section title="Adaptive Popover" description="Popovers adapt to screen width: floating panel on regular screens, bottom sheet on compact.">
        <Preview gradient style={{ minHeight: 340 }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 24 }}>
            {/* Regular width */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 12, textAlign: 'center' }}>
                Regular Width
              </div>
              <div style={{ position: 'relative', height: 240, background: 'rgba(255,255,255,0.04)', borderRadius: 'var(--r-lg)', border: '0.5px solid rgba(255,255,255,0.08)', overflow: 'hidden' }}>
                <div style={{ padding: 16, display: 'flex', justifyContent: 'center' }}>
                  <GlassButton variant="glass" size="sm">Trigger</GlassButton>
                </div>
                <div style={{ position: 'absolute', top: 52, left: '50%', transform: 'translateX(-50%)', ...glassPanel, padding: '14px 18px', width: 200, animation: 'dropdown-in 300ms cubic-bezier(0.34,1.56,0.64,1) both' }}>
                  <Arrow direction="top" />
                  <div style={{ font: 'var(--text-headline)', marginBottom: 4 }}>Options</div>
                  <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
                    Choose an action to perform on this item.
                  </div>
                </div>
              </div>
            </div>

            {/* Compact width */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 12, textAlign: 'center' }}>
                Compact Width
              </div>
              <div style={{ position: 'relative', height: 240, background: 'rgba(255,255,255,0.04)', borderRadius: 'var(--r-lg)', border: '0.5px solid rgba(255,255,255,0.08)', overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
                <div style={{ flex: 1, padding: 16, display: 'flex', justifyContent: 'center' }}>
                  <GlassButton variant="glass" size="sm">Trigger</GlassButton>
                </div>
                <div style={{
                  ...glassPanel,
                  borderRadius: '20px 20px 0 0',
                  padding: '0 18px 18px',
                }}>
                  <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 12px' }}>
                    <div style={{ width: 36, height: 5, borderRadius: 3, background: 'var(--label-quaternary)' }} />
                  </div>
                  <div style={{ font: 'var(--text-headline)', marginBottom: 4 }}>Options</div>
                  <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
                    Choose an action to perform on this item.
                  </div>
                </div>
              </div>
            </div>
          </div>
          <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.45)', textAlign: 'center', marginTop: 16, marginBottom: 0 }}>
            On narrow screens, popovers automatically present as bottom sheets for better reachability.
          </p>
        </Preview>
      </Section>

      {/* ── 4. Popover with Actions ── */}
      <Section title="Popover with Actions" description="Context-menu style popover containing a list of actions, dividers, and a footer link.">
        <Preview gradient>
          <div style={{ display: 'flex', justifyContent: 'center', padding: '24px 0' }}>
            <div style={{ position: 'relative', ...glassPanel, padding: 0, width: 260, overflow: 'hidden' }}>
              <Arrow direction="top" />
              {['Edit', 'Duplicate', 'Move to Folder'].map((action, i) => (
                <button key={action} style={{
                  display: 'block',
                  width: '100%',
                  padding: '12px 20px',
                  textAlign: 'left',
                  font: 'var(--text-body)',
                  color: 'var(--label)',
                  background: 'transparent',
                  border: 'none',
                  borderBottom: '0.5px solid var(--separator)',
                  cursor: 'pointer',
                  transition: 'background 200ms cubic-bezier(0.42,0,0.58,1)',
                }}>
                  {action}
                </button>
              ))}
              <button style={{
                display: 'block',
                width: '100%',
                padding: '12px 20px',
                textAlign: 'left',
                font: 'var(--text-body)',
                color: 'var(--red)',
                background: 'transparent',
                border: 'none',
                borderBottom: '0.5px solid var(--separator)',
                cursor: 'pointer',
              }}>
                Delete
              </button>
              <div style={{ padding: '10px 20px', borderTop: 'none' }}>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--blue)', cursor: 'pointer' }}>
                  Learn More
                </span>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── 5. Popover Specs ── */}
      <Section title="Popover Specs">
        <SpecTable
          headers={['Property', 'Value']}
          rows={[
            ['Max width', '320px'],
            ['Min width', '200px'],
            ['Border radius', 'var(--r-xl) / 28px'],
            ['Arrow size', '10px'],
            ['Backdrop blur', 'var(--blur-lg) / 48px'],
            ['Shadow', 'var(--glass-shadow-lg)'],
            ['Background', 'var(--glass-bg-thick)'],
            ['Dismiss', 'Tap outside / explicit button'],
          ]}
        />
      </Section>
    </div>
  )
}
