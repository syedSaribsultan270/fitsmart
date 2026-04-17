import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassSegment } from '../components/Glass'

const spacingScale = [
  { token: '--sp-1', value: 4 },
  { token: '--sp-2', value: 8 },
  { token: '--sp-3', value: 12 },
  { token: '--sp-4', value: 16 },
  { token: '--sp-5', value: 20 },
  { token: '--sp-6', value: 24 },
  { token: '--sp-8', value: 32 },
  { token: '--sp-10', value: 40 },
  { token: '--sp-12', value: 48 },
  { token: '--sp-16', value: 64 },
]

const radii = [
  { name: 'xs', token: '--r-xs', value: 8 },
  { name: 'sm', token: '--r-sm', value: 12 },
  { name: 'md', token: '--r-md', value: 16 },
  { name: 'lg', token: '--r-lg', value: 22 },
  { name: 'xl', token: '--r-xl', value: 28 },
  { name: '2xl', token: '--r-2xl', value: 36 },
  { name: 'pill', token: '--r-pill', value: 9999 },
]

const shadowLevels = [
  { name: 'Default', token: '--glass-shadow', desc: 'Cards, panels, list containers' },
  { name: 'Large', token: '--glass-shadow-lg', desc: 'Modals, alerts, elevated surfaces' },
  { name: 'XL', token: '--glass-shadow-xl', desc: 'Full-screen sheets, presentation modals, popovers', custom: true },
  { name: 'Inner', token: '--glass-shadow-inner', desc: 'Subtle inset glow on glass surfaces' },
]

const tapTargetHeaders = ['Platform', 'Min Size', 'Notes']
const tapTargetRows = [
  ['iOS / iPadOS', '44 x 44 pt', 'Standard touch target for all interactive elements'],
  ['macOS', '28 x 28 pt', 'Pointer-based; smaller targets acceptable'],
  ['visionOS', '60 x 60 pt', 'Gaze and gesture input requires larger targets'],
  ['visionOS (spacing)', '60 pt centers', 'Minimum distance between button centers'],
  ['watchOS', 'Full-width', 'Primary actions should span the full width'],
]

const barHeightHeaders = ['Component', 'Height (pt)', 'Notes']
const barHeightRows = [
  ['Navigation bar (standard)', '44', 'Back button, title, action items'],
  ['Navigation bar (large title)', '96', 'Collapses to 44 on scroll'],
  ['Tab bar', '49', 'Floats above content; Liquid Glass background'],
  ['Toolbar', '44', 'Top or bottom edge'],
  ['Status bar', '~44 / ~20', 'Dynamic Island vs legacy'],
  ['tvOS tab bar', '68', 'Top edge, 46pt from top of screen'],
]

const columnConfigs = {
  '4-col': { count: 4, gutter: 16 },
  '8-col': { count: 8, gutter: 12 },
  '12-col': { count: 12, gutter: 8 },
}

function getShadowValue(token) {
  if (token === '--glass-shadow') {
    return 'var(--glass-shadow), var(--glass-specular)'
  }
  if (token === '--glass-shadow-lg') {
    return 'var(--glass-shadow-lg), var(--glass-specular)'
  }
  if (token === '--glass-shadow-xl') {
    return '0 0 0 0.5px rgba(0,0,0,0.03), 0 8px 24px rgba(0,0,0,0.08), 0 24px 72px rgba(0,0,0,0.12), inset 0 1px 0 rgba(255,255,255,0.55), inset 0 0 0 0.5px rgba(255,255,255,0.25)'
  }
  if (token === '--glass-shadow-inner') {
    return 'var(--glass-shadow-inner)'
  }
  return 'none'
}

function getShadowValueDark(token) {
  if (token === '--glass-shadow') {
    return '0 0 0 0.5px rgba(0,0,0,0.2), 0 2px 8px rgba(0,0,0,0.15), 0 8px 24px rgba(0,0,0,0.2), inset 0 1px 0 rgba(255,255,255,0.08), inset 0 0 0 0.5px rgba(255,255,255,0.05)'
  }
  if (token === '--glass-shadow-lg') {
    return '0 0 0 0.5px rgba(0,0,0,0.2), 0 4px 16px rgba(0,0,0,0.2), 0 16px 48px rgba(0,0,0,0.3), inset 0 1px 0 rgba(255,255,255,0.08), inset 0 0 0 0.5px rgba(255,255,255,0.05)'
  }
  if (token === '--glass-shadow-xl') {
    return '0 0 0 0.5px rgba(0,0,0,0.25), 0 8px 24px rgba(0,0,0,0.25), 0 24px 72px rgba(0,0,0,0.35), inset 0 1px 0 rgba(255,255,255,0.08), inset 0 0 0 0.5px rgba(255,255,255,0.05)'
  }
  if (token === '--glass-shadow-inner') {
    return 'inset 0 0.5px 0 rgba(255,255,255,0.08)'
  }
  return 'none'
}

export default function Spacing() {
  const [gridMode, setGridMode] = useState('4-col')
  const activeGrid = columnConfigs[gridMode]

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Spacing &amp; Layout</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Spacing scale, layout margins, alignment grids, corner radii, shadows, and layout metrics.
      </p>

      {/* ---- Existing: Spacing Scale ---- */}
      <Section title="Spacing Scale" description="Consistent spacing tokens from 4px to 64px">
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {spacingScale.map((s) => (
              <div key={s.token} style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
                <div style={{
                  minWidth: 80, font: 'var(--text-caption1)',
                  fontFamily: 'var(--font-mono)', color: 'var(--label-tertiary)',
                }}>
                  {s.token}
                </div>
                <div style={{
                  minWidth: 40, font: 'var(--text-caption1)', color: 'var(--label-secondary)',
                  textAlign: 'right',
                }}>
                  {s.value}px
                </div>
                <div style={{
                  width: s.value * 4,
                  height: 20,
                  borderRadius: 'var(--r-xs)',
                  background: 'var(--blue)',
                  opacity: 0.7,
                  transition: 'width var(--dur) var(--ease)',
                }} />
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          NEW SECTION: Layout Margins
          ============================================================ */}
      <Section
        title="Layout Margins"
        description="Adaptive content margins that respond to device size class"
      >
        <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 20, maxWidth: 580 }}>
          Layout margins define the horizontal inset between screen edges and content. They adapt based on the
          size class: compact devices use tighter margins, while large screens center content in a max-width container.
        </div>

        <Preview>
          <div style={{ display: 'flex', gap: 20, flexWrap: 'wrap', justifyContent: 'center' }}>
            {/* Compact */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label)' }}>Compact</div>
              <div style={{
                width: 140, height: 200, borderRadius: 'var(--r-md)',
                background: 'var(--fill-secondary)', position: 'relative', overflow: 'hidden',
                border: '0.5px solid var(--separator)',
              }}>
                {/* Left margin */}
                <div style={{
                  position: 'absolute', left: 0, top: 0, bottom: 0, width: 16,
                  background: 'var(--blue)', opacity: 0.15,
                }} />
                {/* Right margin */}
                <div style={{
                  position: 'absolute', right: 0, top: 0, bottom: 0, width: 16,
                  background: 'var(--blue)', opacity: 0.15,
                }} />
                {/* Content area */}
                <div style={{
                  position: 'absolute', left: 16, right: 16, top: 12, bottom: 12,
                  borderRadius: 'var(--r-xs)', border: '1px dashed var(--blue)', opacity: 0.4,
                  display: 'flex', flexDirection: 'column', gap: 6, padding: 8,
                }}>
                  {[1, 0.7, 0.5, 0.8, 0.4].map((w, i) => (
                    <div key={i} style={{ height: 6, borderRadius: 3, background: 'var(--label-quaternary)', width: `${w * 100}%` }} />
                  ))}
                </div>
              </div>
              <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>16px margins</div>
            </div>

            {/* Regular */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label)' }}>Regular</div>
              <div style={{
                width: 200, height: 200, borderRadius: 'var(--r-md)',
                background: 'var(--fill-secondary)', position: 'relative', overflow: 'hidden',
                border: '0.5px solid var(--separator)',
              }}>
                {/* Left margin */}
                <div style={{
                  position: 'absolute', left: 0, top: 0, bottom: 0, width: 20,
                  background: 'var(--blue)', opacity: 0.15,
                }} />
                {/* Right margin */}
                <div style={{
                  position: 'absolute', right: 0, top: 0, bottom: 0, width: 20,
                  background: 'var(--blue)', opacity: 0.15,
                }} />
                {/* Content area */}
                <div style={{
                  position: 'absolute', left: 20, right: 20, top: 12, bottom: 12,
                  borderRadius: 'var(--r-xs)', border: '1px dashed var(--blue)', opacity: 0.4,
                  display: 'flex', flexDirection: 'column', gap: 6, padding: 8,
                }}>
                  {[1, 0.7, 0.5, 0.8, 0.4, 0.6].map((w, i) => (
                    <div key={i} style={{ height: 6, borderRadius: 3, background: 'var(--label-quaternary)', width: `${w * 100}%` }} />
                  ))}
                </div>
              </div>
              <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>20px margins</div>
            </div>

            {/* Large */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label)' }}>Large</div>
              <div style={{
                width: 280, height: 200, borderRadius: 'var(--r-md)',
                background: 'var(--fill-secondary)', position: 'relative', overflow: 'hidden',
                border: '0.5px solid var(--separator)',
              }}>
                {/* Left margin (auto) */}
                <div style={{
                  position: 'absolute', left: 0, top: 0, bottom: 0, width: 50,
                  background: 'var(--blue)', opacity: 0.1,
                }} />
                {/* Right margin (auto) */}
                <div style={{
                  position: 'absolute', right: 0, top: 0, bottom: 0, width: 50,
                  background: 'var(--blue)', opacity: 0.1,
                }} />
                {/* Content area (centered max-width) */}
                <div style={{
                  position: 'absolute', left: 50, right: 50, top: 12, bottom: 12,
                  borderRadius: 'var(--r-xs)', border: '1px dashed var(--blue)', opacity: 0.4,
                  display: 'flex', flexDirection: 'column', gap: 6, padding: 8,
                }}>
                  {[1, 0.7, 0.5, 0.8, 0.4, 0.6, 0.3].map((w, i) => (
                    <div key={i} style={{ height: 6, borderRadius: 3, background: 'var(--label-quaternary)', width: `${w * 100}%` }} />
                  ))}
                </div>
                {/* Center arrows */}
                <div style={{
                  position: 'absolute', bottom: 6, left: 0, right: 0,
                  display: 'flex', justifyContent: 'center',
                }}>
                  <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', fontSize: 9 }}>
                    auto &middot; max-width &middot; auto
                  </div>
                </div>
              </div>
              <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>auto margins, max-width</div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          NEW SECTION: Alignment Grid
          ============================================================ */}
      <Section
        title="Alignment Grid"
        description="A responsive column grid for aligning content. Toggle between 4, 8, and 12 columns."
      >
        <div style={{ marginBottom: 16 }}>
          <GlassSegment
            items={[
              { value: '4-col', label: '4 Columns' },
              { value: '8-col', label: '8 Columns' },
              { value: '12-col', label: '12 Columns' },
            ]}
            value={gridMode}
            onChange={setGridMode}
          />
        </div>

        <Preview>
          <div style={{
            position: 'relative',
            height: 240,
            borderRadius: 'var(--r-md)',
            overflow: 'hidden',
            background: 'var(--fill-secondary)',
            border: '0.5px solid var(--separator)',
          }}>
            {/* Column overlay */}
            <div style={{
              position: 'absolute', inset: 0,
              display: 'grid',
              gridTemplateColumns: `repeat(${activeGrid.count}, 1fr)`,
              gap: activeGrid.gutter,
              padding: `0 ${activeGrid.gutter}px`,
            }}>
              {Array.from({ length: activeGrid.count }, (_, i) => (
                <div key={i} style={{
                  background: 'var(--blue)',
                  opacity: 0.08,
                  borderRadius: 2,
                }} />
              ))}
            </div>

            {/* Sample content blocks */}
            <div style={{
              position: 'relative', zIndex: 1, padding: activeGrid.gutter,
              display: 'grid',
              gridTemplateColumns: `repeat(${activeGrid.count}, 1fr)`,
              gap: activeGrid.gutter,
            }}>
              {/* Header spanning full width */}
              <div style={{
                gridColumn: `1 / -1`, height: 28, borderRadius: 'var(--r-xs)',
                background: 'var(--blue)', opacity: 0.2,
              }} />
              {/* Two-column content */}
              <div style={{
                gridColumn: `1 / ${Math.ceil(activeGrid.count * 0.6) + 1}`,
                height: 120, borderRadius: 'var(--r-sm)',
                background: 'var(--blue)', opacity: 0.12,
                display: 'flex', flexDirection: 'column', gap: 6, padding: 12,
              }}>
                {[1, 0.8, 0.6, 0.9, 0.5].map((w, i) => (
                  <div key={i} style={{ height: 5, borderRadius: 3, background: 'var(--label-quaternary)', width: `${w * 100}%` }} />
                ))}
              </div>
              <div style={{
                gridColumn: `${Math.ceil(activeGrid.count * 0.6) + 1} / -1`,
                height: 120, borderRadius: 'var(--r-sm)',
                background: 'var(--blue)', opacity: 0.12,
              }} />
              {/* Footer */}
              <div style={{
                gridColumn: `1 / -1`, height: 24, borderRadius: 'var(--r-xs)',
                background: 'var(--blue)', opacity: 0.1,
              }} />
            </div>
          </div>
        </Preview>

        <div style={{
          display: 'flex', gap: 24, flexWrap: 'wrap', marginTop: 8,
        }}>
          <GlassPanel style={{ padding: 16, flex: '1 1 160px' }}>
            <div style={{ font: 'var(--text-headline)', marginBottom: 4 }}>{activeGrid.count} Columns</div>
            <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>
              {activeGrid.gutter}px gutters between columns
            </div>
          </GlassPanel>
          <GlassPanel style={{ padding: 16, flex: '1 1 160px' }}>
            <div style={{ font: 'var(--text-headline)', marginBottom: 4 }}>Fluid</div>
            <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>
              Columns stretch to fill the available width
            </div>
          </GlassPanel>
          <GlassPanel style={{ padding: 16, flex: '1 1 160px' }}>
            <div style={{ font: 'var(--text-headline)', marginBottom: 4 }}>Responsive</div>
            <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>
              Use fewer columns on compact size classes
            </div>
          </GlassPanel>
        </div>
      </Section>

      {/* ---- Existing (ENRICHED): Corner Radii ---- */}
      <Section title="Corner Radii" description="Squircle-inspired continuous corners from 8px to pill">
        <Preview>
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(110px, 1fr))',
            gap: 20,
            justifyItems: 'center',
          }}>
            {radii.map((r) => (
              <div key={r.token} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                <div style={{
                  width: r.name === 'pill' ? 80 : 64,
                  height: 64,
                  borderRadius: `var(${r.token})`,
                  background: 'var(--fill)',
                  border: '1.5px solid var(--blue)',
                }} />
                <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label)' }}>
                  {r.name}
                </div>
                <div style={{
                  font: 'var(--text-caption2)', color: 'var(--label-tertiary)',
                  fontFamily: 'var(--font-mono)',
                }}>
                  {r.value === 9999 ? '9999px' : `${r.value}px`}
                </div>
              </div>
            ))}
          </div>
        </Preview>

        {/* NEW: Continuous corners note */}
        <GlassPanel style={{ padding: 20, marginTop: 8 }}>
          <div style={{ display: 'flex', gap: 16, alignItems: 'flex-start' }}>
            <div style={{ display: 'flex', gap: 20, flexShrink: 0, alignItems: 'center' }}>
              {/* Standard border-radius vs continuous corner comparison */}
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
                <div style={{
                  width: 48, height: 48, borderRadius: 12,
                  border: '1.5px solid var(--orange)', background: 'var(--fill-tertiary)',
                }} />
                <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>Standard</div>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
                <svg width="48" height="48" viewBox="0 0 48 48">
                  <rect x="1" y="1" width="46" height="46" rx="12" ry="12"
                    fill="var(--fill-tertiary)" stroke="var(--blue)" strokeWidth="1.5"
                    style={{ paintOrder: 'stroke' }}
                  />
                  {/* Simulate continuous corner with a superellipse path */}
                  <path
                    d="M12 1 C4 1, 1 4, 1 12 L1 36 C1 44, 4 47, 12 47 L36 47 C44 47, 47 44, 47 36 L47 12 C47 4, 44 1, 36 1 Z"
                    fill="none" stroke="var(--blue)" strokeWidth="1.5" opacity="0.5"
                  />
                </svg>
                <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>Continuous</div>
              </div>
            </div>
            <div>
              <div style={{ font: 'var(--text-headline)', marginBottom: 4 }}>Continuous Corners (Squircle)</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', lineHeight: '20px' }}>
                iOS uses <strong>continuous corners</strong> (superellipse / squircle) rather than standard circular
                {' '}<code style={{ fontFamily: 'var(--font-mono)', fontSize: 13, background: 'var(--fill)', padding: '2px 6px', borderRadius: 4 }}>border-radius</code>.
                The curvature begins earlier and blends more smoothly into the straight edges, producing a softer, more organic shape.
                On the web, CSS <code style={{ fontFamily: 'var(--font-mono)', fontSize: 13, background: 'var(--fill)', padding: '2px 6px', borderRadius: 4 }}>border-radius</code> produces
                circular arcs. For a closer match, use SVG superellipses or the upcoming CSS{' '}
                <code style={{ fontFamily: 'var(--font-mono)', fontSize: 13, background: 'var(--fill)', padding: '2px 6px', borderRadius: 4 }}>corner-shape: squircle</code> property.
                Native iOS applies continuous corners automatically via{' '}
                <code style={{ fontFamily: 'var(--font-mono)', fontSize: 13, background: 'var(--fill)', padding: '2px 6px', borderRadius: 4 }}>.cornerCurve = .continuous</code>.
              </div>
            </div>
          </div>
        </GlassPanel>
      </Section>

      {/* ---- Existing (ENRICHED): Shadows ---- */}
      <Section title="Shadows" description="Soft, diffuse shadow levels for glass surfaces">
        <div style={{
          display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))', gap: 24,
        }}>
          {shadowLevels.map((s) => (
            <GlassPanel key={s.token} style={{
              boxShadow: getShadowValue(s.token),
              padding: 20,
            }}>
              <div style={{ font: 'var(--text-headline)', marginBottom: 4 }}>{s.name}</div>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', fontFamily: 'var(--font-mono)', marginBottom: 8 }}>
                {s.token}
              </div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
                {s.desc}
              </div>
            </GlassPanel>
          ))}
        </div>

        {/* NEW: Light vs Dark mode shadow comparison */}
        <div style={{ marginTop: 24 }}>
          <div style={{ font: 'var(--text-headline)', marginBottom: 4 }}>Light vs Dark Mode Shadows</div>
          <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 16 }}>
            Dark mode shadows use higher opacity and deeper spread to remain visible against dark surfaces.
            Specular highlights are reduced to match the lower ambient light.
          </div>

          <div style={{ display: 'flex', gap: 20, flexWrap: 'wrap' }}>
            {/* Light mode column */}
            <div style={{ flex: '1 1 280px' }}>
              <div style={{
                font: 'var(--text-caption1)', color: 'var(--label-tertiary)',
                textTransform: 'uppercase', letterSpacing: 1, marginBottom: 12,
              }}>
                Light Mode
              </div>
              <div style={{
                background: '#f0f0f5', borderRadius: 'var(--r-xl)', padding: 20,
                display: 'flex', flexDirection: 'column', gap: 16,
              }}>
                {shadowLevels.filter((s) => s.token !== '--glass-shadow-inner').map((s) => (
                  <div key={s.token} style={{
                    background: 'rgba(255,255,255,0.55)',
                    borderRadius: 'var(--r-md)',
                    padding: '12px 16px',
                    boxShadow: s.token === '--glass-shadow'
                      ? '0 0 0 0.5px rgba(0,0,0,0.04), 0 2px 8px rgba(0,0,0,0.04), 0 8px 24px rgba(0,0,0,0.06), inset 0 1px 0 rgba(255,255,255,0.55)'
                      : s.token === '--glass-shadow-lg'
                        ? '0 0 0 0.5px rgba(0,0,0,0.03), 0 4px 16px rgba(0,0,0,0.06), 0 16px 48px rgba(0,0,0,0.08), inset 0 1px 0 rgba(255,255,255,0.55)'
                        : '0 0 0 0.5px rgba(0,0,0,0.03), 0 8px 24px rgba(0,0,0,0.08), 0 24px 72px rgba(0,0,0,0.12), inset 0 1px 0 rgba(255,255,255,0.55)',
                  }}>
                    <div style={{ font: 'var(--text-caption1)', color: 'rgba(0,0,0,0.88)' }}>{s.name}</div>
                  </div>
                ))}
              </div>
            </div>

            {/* Dark mode column */}
            <div style={{ flex: '1 1 280px' }}>
              <div style={{
                font: 'var(--text-caption1)', color: 'var(--label-tertiary)',
                textTransform: 'uppercase', letterSpacing: 1, marginBottom: 12,
              }}>
                Dark Mode
              </div>
              <div style={{
                background: '#1c1c1e', borderRadius: 'var(--r-xl)', padding: 20,
                display: 'flex', flexDirection: 'column', gap: 16,
              }}>
                {shadowLevels.filter((s) => s.token !== '--glass-shadow-inner').map((s) => (
                  <div key={s.token} style={{
                    background: 'rgba(38,38,42,0.55)',
                    borderRadius: 'var(--r-md)',
                    padding: '12px 16px',
                    boxShadow: getShadowValueDark(s.token),
                    border: '0.5px solid rgba(255,255,255,0.08)',
                  }}>
                    <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.92)' }}>{s.name}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </Section>

      {/* ---- Existing: Component Sizes ---- */}
      <Section title="Component Sizes" description="Minimum tap/hit targets by platform">
        <SpecTable headers={tapTargetHeaders} rows={tapTargetRows} />
      </Section>

      {/* ---- Existing: Bar Heights ---- */}
      <Section title="Bar Heights" description="Standard iOS/iPadOS bar dimensions">
        <SpecTable headers={barHeightHeaders} rows={barHeightRows} />
      </Section>
    </div>
  )
}
