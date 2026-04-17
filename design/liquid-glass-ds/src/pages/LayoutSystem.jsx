import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'
import { useState } from 'react'

/* ── data ─────────────────────────────────────────────────── */

const safeAreaHeaders = ['Device', 'Top (pt)', 'Bottom (pt)', 'Leading (pt)', 'Trailing (pt)']
const safeAreaRows = [
  ['iPhone (notch)', '59', '34', '0', '0'],
  ['iPhone (Dynamic Island)', '59', '34', '0', '0'],
  ['iPad', '24', '20', '0', '0'],
  ['Mac', '0', '0', '0', '0'],
  ['Apple Watch 40mm', '28', '28', '0', '0'],
  ['Apple TV', '60', '60', '80', '80'],
]

const marginHeaders = ['Size Class', 'Breakpoint', 'Margins', 'Columns']
const marginRows = [
  ['Compact', '< 768px', '16px', '4-column grid'],
  ['Regular', '768 – 1024px', '20px', '8-column grid'],
  ['Large', '> 1024px', 'auto (centered)', '12-column grid'],
]

const contentWidthHeaders = ['Type', 'Max Width', 'Use Case']
const contentWidthRows = [
  ['Readable content', '672px', 'Article text, long-form reading'],
  ['Form content', '540px', 'Input forms, settings panels'],
  ['Compact content', '360px', 'Narrow dialogs, onboarding cards'],
  ['Full-bleed', '100%', 'Hero images, backgrounds, media'],
]

const keyboardHeaders = ['Device', 'Keyboard Height (pt)', 'Notes']
const keyboardRows = [
  ['iPhone (portrait)', '291', 'Standard keyboard; 336 with suggestions'],
  ['iPhone (landscape)', '190', 'Compact keyboard layout'],
  ['iPad (floating)', '254', 'Undocked floating keyboard'],
  ['iPad (docked)', '313', 'Full-width docked keyboard'],
  ['iPad (split)', '254', 'Split keyboard, half on each side'],
  ['Mac', '0', 'Hardware keyboard; no on-screen inset'],
]

/* ── helpers ──────────────────────────────────────────────── */

const mono = { fontFamily: 'var(--font-mono)', fontSize: 12 }
const labelFaint = { font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }
const labelSm = { font: 'var(--text-caption1)', color: 'var(--label-secondary)' }

function PhoneFrame({ children, style, width = 180, height = 360 }) {
  return (
    <div style={{
      width,
      height,
      borderRadius: 'var(--r-2xl)',
      border: '2px solid var(--label-tertiary)',
      position: 'relative',
      overflow: 'hidden',
      background: 'linear-gradient(180deg, rgba(255,255,255,0.04) 0%, rgba(255,255,255,0.01) 100%)',
      flexShrink: 0,
      ...style,
    }}>
      {/* Notch / Dynamic Island */}
      <div style={{
        position: 'absolute',
        top: 8,
        left: '50%',
        transform: 'translateX(-50%)',
        width: 72,
        height: 22,
        borderRadius: 'var(--r-pill)',
        background: 'rgba(0,0,0,0.7)',
        zIndex: 5,
      }} />
      {children}
    </div>
  )
}

/* ── column grid helper ──────────────────────────────────── */

function ColumnGrid({ cols, gutterWidth, label }) {
  return (
    <div style={{ textAlign: 'center' }}>
      <div style={{
        display: 'flex',
        gap: gutterWidth,
        height: 160,
        padding: '0 8px',
      }}>
        {Array.from({ length: cols }).map((_, i) => (
          <div key={i} style={{
            flex: 1,
            background: 'rgba(0,122,255,0.08)',
            borderRadius: 4,
            border: '0.5px solid rgba(0,122,255,0.15)',
          }} />
        ))}
      </div>
      <div style={{ ...labelSm, marginTop: 8 }}>
        {label} &mdash; {cols} cols, {gutterWidth}px gutters
      </div>
    </div>
  )
}

/* ── page ─────────────────────────────────────────────────── */

export default function LayoutSystem() {
  const [keyboardVisible, setKeyboardVisible] = useState(false)

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Layout System</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Safe areas, adaptive margins, column grids, content widths, keyboard adaptation, and reading direction.
      </p>

      {/* ═══════════════════════════════════════════════════════
          1 — Safe Areas
          ═══════════════════════════════════════════════════════ */}
      <Section
        title="Safe Areas"
        description="The safe area defines the region not covered by system UI (status bar, home indicator, Dynamic Island). Always inset content within these boundaries."
      >
        <Preview gradient style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 32, flexWrap: 'wrap' }}>
          <PhoneFrame>
            {/* Full background fill */}
            <div style={{
              position: 'absolute', inset: 0,
              background: 'linear-gradient(180deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
            }} />

            {/* Top safe-area overlay */}
            <div style={{
              position: 'absolute', top: 0, left: 0, right: 0,
              height: 59 * (360 / 812),
              background: 'rgba(255,59,48,0.25)',
              borderBottom: '1px dashed rgba(255,59,48,0.6)',
              zIndex: 2,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <span style={{ fontSize: 9, color: 'rgba(255,255,255,0.8)', ...mono }}>59pt</span>
            </div>

            {/* Bottom safe-area overlay */}
            <div style={{
              position: 'absolute', bottom: 0, left: 0, right: 0,
              height: 34 * (360 / 812),
              background: 'rgba(255,149,0,0.25)',
              borderTop: '1px dashed rgba(255,149,0,0.6)',
              zIndex: 2,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <span style={{ fontSize: 9, color: 'rgba(255,255,255,0.8)', ...mono }}>34pt</span>
            </div>

            {/* Safe area dashed border */}
            <div style={{
              position: 'absolute',
              top: 59 * (360 / 812),
              bottom: 34 * (360 / 812),
              left: 0,
              right: 0,
              border: '1.5px dashed rgba(52,199,89,0.6)',
              zIndex: 3,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <span style={{ fontSize: 10, color: 'rgba(52,199,89,0.9)', fontWeight: 600 }}>Safe Area</span>
            </div>
          </PhoneFrame>

          {/* Legend */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <div style={{ width: 14, height: 14, borderRadius: 3, background: 'rgba(255,59,48,0.4)' }} />
              <span style={{ ...labelSm, color: 'rgba(255,255,255,0.8)' }}>Top inset (status bar / Dynamic Island)</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <div style={{ width: 14, height: 14, borderRadius: 3, background: 'rgba(255,149,0,0.4)' }} />
              <span style={{ ...labelSm, color: 'rgba(255,255,255,0.8)' }}>Bottom inset (home indicator)</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <div style={{ width: 14, height: 14, borderRadius: 3, border: '1.5px dashed rgba(52,199,89,0.6)' }} />
              <span style={{ ...labelSm, color: 'rgba(255,255,255,0.8)' }}>Usable safe area</span>
            </div>
          </div>
        </Preview>

        <SpecTable headers={safeAreaHeaders} rows={safeAreaRows} />
      </Section>

      {/* ═══════════════════════════════════════════════════════
          2 — Adaptive Margins
          ═══════════════════════════════════════════════════════ */}
      <Section
        title="Adaptive Margins"
        description="Margins and column counts adapt to the available width. The system defines three primary size classes."
      >
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 16, marginBottom: 16 }}>
          {/* Compact */}
          <Preview style={{ padding: 0, overflow: 'hidden' }}>
            <div style={{ padding: 16 }}>
              <div style={{ ...labelSm, fontWeight: 600, marginBottom: 8, color: 'var(--label)' }}>Compact</div>
              <div style={{ ...labelFaint, marginBottom: 12 }}>&lt; 768px &middot; 16px margins</div>
              <div style={{
                border: '1px dashed var(--blue)',
                borderRadius: 'var(--r-sm)',
                padding: 16,
                position: 'relative',
              }}>
                {/* Margin markers */}
                <div style={{ position: 'absolute', left: -14, top: '50%', transform: 'translateY(-50%)', ...mono, color: 'var(--blue)', fontSize: 10 }}>16</div>
                <div style={{ position: 'absolute', right: -14, top: '50%', transform: 'translateY(-50%)', ...mono, color: 'var(--blue)', fontSize: 10 }}>16</div>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 4 }}>
                  {Array.from({ length: 4 }).map((_, i) => (
                    <div key={i} style={{ height: 48, borderRadius: 4, background: 'rgba(0,122,255,0.1)', border: '0.5px solid rgba(0,122,255,0.2)' }} />
                  ))}
                </div>
                <div style={{ ...labelFaint, textAlign: 'center', marginTop: 6 }}>4-col</div>
              </div>
            </div>
          </Preview>

          {/* Regular */}
          <Preview style={{ padding: 0, overflow: 'hidden' }}>
            <div style={{ padding: 20 }}>
              <div style={{ ...labelSm, fontWeight: 600, marginBottom: 8, color: 'var(--label)' }}>Regular</div>
              <div style={{ ...labelFaint, marginBottom: 12 }}>768 &ndash; 1024px &middot; 20px margins</div>
              <div style={{
                border: '1px dashed var(--teal)',
                borderRadius: 'var(--r-sm)',
                padding: 12,
                position: 'relative',
              }}>
                <div style={{ position: 'absolute', left: -14, top: '50%', transform: 'translateY(-50%)', ...mono, color: 'var(--teal)', fontSize: 10 }}>20</div>
                <div style={{ position: 'absolute', right: -14, top: '50%', transform: 'translateY(-50%)', ...mono, color: 'var(--teal)', fontSize: 10 }}>20</div>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(8, 1fr)', gap: 3 }}>
                  {Array.from({ length: 8 }).map((_, i) => (
                    <div key={i} style={{ height: 48, borderRadius: 4, background: 'rgba(48,176,199,0.1)', border: '0.5px solid rgba(48,176,199,0.2)' }} />
                  ))}
                </div>
                <div style={{ ...labelFaint, textAlign: 'center', marginTop: 6 }}>8-col</div>
              </div>
            </div>
          </Preview>

          {/* Large */}
          <Preview style={{ padding: 0, overflow: 'hidden' }}>
            <div style={{ padding: 20 }}>
              <div style={{ ...labelSm, fontWeight: 600, marginBottom: 8, color: 'var(--label)' }}>Large</div>
              <div style={{ ...labelFaint, marginBottom: 12 }}>&gt; 1024px &middot; auto margins (centered)</div>
              <div style={{
                border: '1px dashed var(--purple)',
                borderRadius: 'var(--r-sm)',
                padding: 12,
                margin: '0 16px',
                position: 'relative',
              }}>
                <div style={{ position: 'absolute', left: -14, top: '50%', transform: 'translateY(-50%)', ...mono, color: 'var(--purple)', fontSize: 10 }}>auto</div>
                <div style={{ position: 'absolute', right: -18, top: '50%', transform: 'translateY(-50%)', ...mono, color: 'var(--purple)', fontSize: 10 }}>auto</div>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: 2 }}>
                  {Array.from({ length: 12 }).map((_, i) => (
                    <div key={i} style={{ height: 24, borderRadius: 3, background: 'rgba(175,82,222,0.1)', border: '0.5px solid rgba(175,82,222,0.2)' }} />
                  ))}
                </div>
                <div style={{ ...labelFaint, textAlign: 'center', marginTop: 6 }}>12-col</div>
              </div>
            </div>
          </Preview>
        </div>

        <SpecTable headers={marginHeaders} rows={marginRows} />
      </Section>

      {/* ═══════════════════════════════════════════════════════
          3 — Column Grids
          ═══════════════════════════════════════════════════════ */}
      <Section
        title="Column Grids"
        description="Column-based grids provide consistent horizontal rhythm. Column count and gutter width scale with available space."
      >
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: 16 }}>
          <Preview>
            <ColumnGrid cols={4} gutterWidth={8} label="Compact" />
          </Preview>
          <Preview>
            <ColumnGrid cols={8} gutterWidth={12} label="Regular" />
          </Preview>
          <Preview>
            <ColumnGrid cols={12} gutterWidth={16} label="Large" />
          </Preview>
        </div>

        <SpecTable
          headers={['Size Class', 'Columns', 'Gutter Width', 'Outer Margin']}
          rows={[
            ['Compact', '4', '8px', '16px'],
            ['Regular', '8', '12px', '20px'],
            ['Large', '12', '16px', 'auto (centered)'],
          ]}
        />
      </Section>

      {/* ═══════════════════════════════════════════════════════
          4 — Content Width
          ═══════════════════════════════════════════════════════ */}
      <Section
        title="Content Width"
        description="Maximum width constraints keep text readable and forms focused, regardless of screen size."
      >
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {[
              { name: 'Readable', width: 672, color: 'var(--blue)' },
              { name: 'Form', width: 540, color: 'var(--teal)' },
              { name: 'Compact', width: 360, color: 'var(--purple)' },
              { name: 'Full-bleed', width: '100%', color: 'var(--orange)' },
            ].map((item) => (
              <div key={item.name}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
                  <span style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label)' }}>{item.name}</span>
                  <span style={{ ...mono, color: 'var(--label-tertiary)', fontSize: 11 }}>
                    {typeof item.width === 'number' ? `${item.width}px` : item.width}
                  </span>
                </div>
                <div style={{
                  width: typeof item.width === 'number' ? `min(${item.width}px, 100%)` : item.width,
                  height: 28,
                  borderRadius: 'var(--r-xs)',
                  background: item.color,
                  opacity: 0.18,
                  border: `1px solid ${item.color}`,
                  position: 'relative',
                }} />
              </div>
            ))}
          </div>
        </Preview>

        <SpecTable headers={contentWidthHeaders} rows={contentWidthRows} />
      </Section>

      {/* ═══════════════════════════════════════════════════════
          5 — Keyboard Layout
          ═══════════════════════════════════════════════════════ */}
      <Section
        title="Keyboard Layout"
        description="When a software keyboard appears, content must reflow to keep the focused input visible. The system animates the layout adjustment with a spring curve."
      >
        <Preview gradient style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 24, flexWrap: 'wrap' }}>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
            <PhoneFrame height={380}>
              {/* Content */}
              <div style={{
                position: 'absolute', inset: 0,
                background: 'linear-gradient(180deg, #1c1c1e 0%, #2c2c2e 100%)',
                display: 'flex', flexDirection: 'column',
                padding: '44px 12px 12px',
                transition: 'padding-bottom 0.4s cubic-bezier(0.34, 1.56, 0.64, 1)',
                paddingBottom: keyboardVisible ? 150 : 12,
              }}>
                {/* Mock content lines */}
                <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8, overflow: 'hidden' }}>
                  {Array.from({ length: 5 }).map((_, i) => (
                    <div key={i} style={{
                      height: 12,
                      width: `${75 - i * 10}%`,
                      background: 'rgba(255,255,255,0.08)',
                      borderRadius: 4,
                    }} />
                  ))}
                </div>

                {/* Mock text input */}
                <div style={{
                  background: 'rgba(255,255,255,0.1)',
                  borderRadius: 'var(--r-sm)',
                  padding: '10px 12px',
                  marginTop: 8,
                  display: 'flex', alignItems: 'center', gap: 8,
                  border: keyboardVisible ? '1px solid rgba(0,122,255,0.5)' : '1px solid rgba(255,255,255,0.1)',
                  transition: 'border-color 0.3s ease',
                }}>
                  <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.4)' }}>Type a message...</span>
                  <div style={{ marginLeft: 'auto', width: 20, height: 20, borderRadius: '50%', background: 'rgba(0,122,255,0.5)' }} />
                </div>
              </div>

              {/* Keyboard overlay */}
              <div style={{
                position: 'absolute', bottom: 0, left: 0, right: 0,
                height: keyboardVisible ? 140 : 0,
                background: 'rgba(30,30,30,0.97)',
                borderTop: '0.5px solid rgba(255,255,255,0.1)',
                transition: 'height 0.4s cubic-bezier(0.34, 1.56, 0.64, 1)',
                overflow: 'hidden',
                zIndex: 10,
              }}>
                {/* Fake keyboard rows */}
                <div style={{ padding: '6px 4px', display: 'flex', flexDirection: 'column', gap: 4 }}>
                  {Array.from({ length: 3 }).map((_, row) => (
                    <div key={row} style={{ display: 'flex', gap: 3, justifyContent: 'center' }}>
                      {Array.from({ length: row === 2 ? 7 : 10 }).map((_, col) => (
                        <div key={col} style={{
                          width: row === 2 ? 18 : 14,
                          height: 28,
                          borderRadius: 4,
                          background: 'rgba(255,255,255,0.08)',
                        }} />
                      ))}
                    </div>
                  ))}
                </div>
              </div>
            </PhoneFrame>

            <GlassButton
              variant="glass"
              size="sm"
              onClick={() => setKeyboardVisible(!keyboardVisible)}
            >
              {keyboardVisible ? 'Dismiss Keyboard' : 'Show Keyboard'}
            </GlassButton>
          </div>

          {/* Annotation */}
          <div style={{ maxWidth: 200, display: 'flex', flexDirection: 'column', gap: 8 }}>
            <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'rgba(255,255,255,0.9)' }}>
              Keyboard Avoidance
            </div>
            <div style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.6)', lineHeight: '18px' }}>
              When the keyboard appears, the focused input scrolls into view. Content above compresses or scrolls.
              The animation uses a spring curve matching the system keyboard transition.
            </div>
          </div>
        </Preview>

        <SpecTable headers={keyboardHeaders} rows={keyboardRows} />
      </Section>

      {/* ═══════════════════════════════════════════════════════
          6 — Reading Direction
          ═══════════════════════════════════════════════════════ */}
      <Section
        title="Reading Direction"
        description="All layout must support both LTR and RTL scripts. Icons, chevrons, and spatial relationships mirror automatically."
      >
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: 16 }}>
          {/* LTR */}
          <Preview>
            <div style={{ ...labelSm, fontWeight: 600, marginBottom: 12, color: 'var(--label)' }}>LTR (Left-to-Right)</div>
            {/* Nav bar */}
            <div style={{
              display: 'flex', alignItems: 'center', gap: 8,
              padding: '8px 12px',
              background: 'var(--glass-bg)',
              borderRadius: 'var(--r-sm)',
              marginBottom: 12,
            }}>
              <span style={{ fontSize: 14 }}>&#x276E;</span>
              <span style={{ font: 'var(--text-headline)', flex: 1, textAlign: 'center' }}>Settings</span>
              <span style={{ width: 14 }} />
            </div>
            {/* List items */}
            {['Wi-Fi', 'Bluetooth', 'Notifications'].map((item) => (
              <div key={item} style={{
                display: 'flex', alignItems: 'center', gap: 10,
                padding: '10px 12px',
                borderBottom: '0.5px solid var(--separator)',
              }}>
                <div style={{
                  width: 24, height: 24, borderRadius: 6,
                  background: 'var(--blue)', opacity: 0.3,
                }} />
                <span style={{ flex: 1, font: 'var(--text-body)' }}>{item}</span>
                <span style={{ color: 'var(--label-tertiary)', fontSize: 14 }}>&#x276F;</span>
              </div>
            ))}
          </Preview>

          {/* RTL */}
          <Preview>
            <div style={{ ...labelSm, fontWeight: 600, marginBottom: 12, color: 'var(--label)' }}>RTL (Right-to-Left)</div>
            {/* Nav bar mirrored */}
            <div dir="rtl" style={{
              display: 'flex', alignItems: 'center', gap: 8,
              padding: '8px 12px',
              background: 'var(--glass-bg)',
              borderRadius: 'var(--r-sm)',
              marginBottom: 12,
            }}>
              <span style={{ fontSize: 14 }}>&#x276F;</span>
              <span style={{ font: 'var(--text-headline)', flex: 1, textAlign: 'center' }}>&#x0625;&#x0639;&#x062F;&#x0627;&#x062F;&#x0627;&#x062A;</span>
              <span style={{ width: 14 }} />
            </div>
            {/* List items mirrored */}
            {[
              { ar: '\u0648\u0627\u064A \u0641\u0627\u064A', en: 'Wi-Fi' },
              { ar: '\u0628\u0644\u0648\u062A\u0648\u062B', en: 'Bluetooth' },
              { ar: '\u0627\u0644\u0625\u0634\u0639\u0627\u0631\u0627\u062A', en: 'Notifications' },
            ].map((item) => (
              <div key={item.en} dir="rtl" style={{
                display: 'flex', alignItems: 'center', gap: 10,
                padding: '10px 12px',
                borderBottom: '0.5px solid var(--separator)',
              }}>
                <div style={{
                  width: 24, height: 24, borderRadius: 6,
                  background: 'var(--blue)', opacity: 0.3,
                }} />
                <span style={{ flex: 1, font: 'var(--text-body)' }}>{item.ar}</span>
                <span style={{ color: 'var(--label-tertiary)', fontSize: 14 }}>&#x276E;</span>
              </div>
            ))}
          </Preview>
        </div>

        <SpecTable
          headers={['Aspect', 'LTR Behavior', 'RTL Behavior']}
          rows={[
            ['Text alignment', 'Left-aligned', 'Right-aligned'],
            ['Navigation chevron', 'Points right (forward)', 'Points left (forward)'],
            ['Back button', 'Left side, points left', 'Right side, points right'],
            ['Icon + text', 'Icon on leading (left) side', 'Icon on leading (right) side'],
            ['Progress indicators', 'Fill left to right', 'Fill right to left'],
            ['Swipe gestures', 'Swipe left to go forward', 'Swipe right to go forward'],
          ]}
        />
      </Section>
    </div>
  )
}
