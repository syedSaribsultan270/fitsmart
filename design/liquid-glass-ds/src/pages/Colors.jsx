import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel } from '../components/Glass'

const systemColors = [
  { name: 'Red', light: '#FF3B30', dark: '#FF453A', token: '--red' },
  { name: 'Orange', light: '#FF9500', dark: '#FF9F0A', token: '--orange' },
  { name: 'Yellow', light: '#FFCC00', dark: '#FFD60A', token: '--yellow' },
  { name: 'Green', light: '#34C759', dark: '#30D158', token: '--green' },
  { name: 'Mint', light: '#00C7BE', dark: '#63E6E2', token: '--mint' },
  { name: 'Teal', light: '#30B0C7', dark: '#40CBE0', token: '--teal' },
  { name: 'Cyan', light: '#32ADE6', dark: '#64D2FF', token: '--cyan' },
  { name: 'Blue', light: '#007AFF', dark: '#0A84FF', token: '--blue' },
  { name: 'Indigo', light: '#5856D6', dark: '#5E5CE6', token: '--indigo' },
  { name: 'Purple', light: '#AF52DE', dark: '#BF5AF2', token: '--purple' },
  { name: 'Pink', light: '#FF2D55', dark: '#FF375F', token: '--pink' },
  { name: 'Brown', light: '#A2845E', dark: '#AC8E68', token: '--brown' },
]

const grays = [
  { name: 'Gray', light: '#8E8E93', dark: '#8E8E93', token: '--gray' },
  { name: 'Gray 2', light: '#AEAEB2', dark: '#636366', token: '--gray2' },
  { name: 'Gray 3', light: '#C7C7CC', dark: '#48484A', token: '--gray3' },
  { name: 'Gray 4', light: '#D1D1D6', dark: '#3A3A3C', token: '--gray4' },
  { name: 'Gray 5', light: '#E5E5EA', dark: '#2C2C2E', token: '--gray5' },
  { name: 'Gray 6', light: '#F2F2F7', dark: '#1C1C1E', token: '--gray6' },
]

const contrastHeaders = ['Combination', 'Min Ratio', 'WCAG Level', 'Requirement']
const contrastRows = [
  ['Normal text', '4.5:1', 'AA', 'Standard body copy'],
  ['Large text (18px+ bold, 24px+)', '3:1', 'AA', 'Headings and large labels'],
  ['Normal text (enhanced)', '7:1', 'AAA', 'Enhanced readability'],
  ['Non-text (icons, borders)', '3:1', 'AA', 'UI components and graphical objects'],
  ['Incidental / decorative', 'None', 'N/A', 'Disabled or purely decorative elements'],
]

function ColorSwatch({ name, light, dark }) {
  const [copied, setCopied] = useState(false)

  const handleCopy = (hex) => {
    navigator.clipboard.writeText(hex).then(() => {
      setCopied(true)
      setTimeout(() => setCopied(false), 1200)
    })
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6, position: 'relative' }}>
      <div
        onClick={() => handleCopy(light)}
        title={`Click to copy ${light}`}
        style={{
          width: 52, height: 52,
          borderRadius: 'var(--r-md)',
          background: light,
          cursor: 'pointer',
          boxShadow: '0 1px 4px rgba(0,0,0,0.12), inset 0 1px 0 rgba(255,255,255,0.2)',
          transition: 'transform var(--dur-fast) var(--ease)',
        }}
      />
      <div style={{ font: 'var(--text-caption1)', fontWeight: 500, color: 'var(--label)' }}>{name}</div>
      <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', fontFamily: 'var(--font-mono)' }}>
        {light} / {dark}
      </div>
      {copied && (
        <div style={{
          position: 'absolute', top: -24, fontSize: 11, fontWeight: 600,
          color: 'var(--green)', background: 'var(--bg-primary)',
          padding: '2px 8px', borderRadius: 'var(--r-xs)',
          boxShadow: 'var(--glass-shadow)',
        }}>Copied</div>
      )}
    </div>
  )
}

export default function Colors() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Colors</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        System colors, semantic tokens, and adaptive dark mode palettes.
      </p>

      <Section title="System Colors" description="12 system colors with light and dark variants. Click to copy hex.">
        <Preview>
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(90px, 1fr))',
            gap: 20,
            justifyItems: 'center',
          }}>
            {systemColors.map((c) => (
              <ColorSwatch key={c.name} {...c} />
            ))}
          </div>
        </Preview>
      </Section>

      <Section title="Gray Scale" description="6 system grays from mid-tone to near-white (light) / near-black (dark)">
        <Preview>
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(90px, 1fr))',
            gap: 20,
            justifyItems: 'center',
          }}>
            {grays.map((c) => (
              <ColorSwatch key={c.name} {...c} />
            ))}
          </div>
        </Preview>
      </Section>

      <Section title="Semantic Colors" description="Purpose-defined colors for text hierarchy, separators, and links">
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <div style={{ color: 'var(--label)', font: 'var(--text-body)', fontWeight: 500 }}>
              Primary Label — High emphasis content
            </div>
            <div style={{ color: 'var(--label-secondary)', font: 'var(--text-body)' }}>
              Secondary Label — Subheadings and supplementary text
            </div>
            <div style={{ color: 'var(--label-tertiary)', font: 'var(--text-body)' }}>
              Tertiary Label — Placeholder and disabled content
            </div>
            <div style={{ color: 'var(--label-quaternary)', font: 'var(--text-body)' }}>
              Quaternary Label — Watermarks and decorative text
            </div>
            <div style={{
              height: 1,
              background: 'var(--separator)',
              margin: '8px 0',
            }} />
            <div style={{ color: 'var(--blue)', font: 'var(--text-body)' }}>
              Link Color — Interactive text links
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Backgrounds" description="Nested background hierarchy: primary > secondary > tertiary">
        <Preview>
          <div style={{
            background: 'var(--bg-primary)',
            borderRadius: 'var(--r-lg)',
            padding: 20,
            border: '0.5px solid var(--separator)',
          }}>
            <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', marginBottom: 8 }}>Primary Background</div>
            <div style={{
              background: 'var(--bg-secondary)',
              borderRadius: 'var(--r-md)',
              padding: 20,
              border: '0.5px solid var(--separator)',
            }}>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', marginBottom: 8 }}>Secondary Background</div>
              <div style={{
                background: 'var(--bg-grouped-secondary)',
                borderRadius: 'var(--r-sm)',
                padding: 20,
                border: '0.5px solid var(--separator)',
              }}>
                <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>Tertiary Background</div>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Dark Mode" description="Side-by-side comparison of light and dark appearances">
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
          <div style={{
            background: '#f2f2f7', borderRadius: 'var(--r-xl)', padding: 24,
            border: '0.5px solid rgba(0,0,0,0.06)',
          }}>
            <div style={{ font: 'var(--text-caption1)', color: 'rgba(60,60,67,0.6)', marginBottom: 12 }}>Light</div>
            <GlassPanel style={{
              background: 'rgba(255,255,255,0.45)',
              border: '0.5px solid rgba(255,255,255,0.45)',
              padding: 16,
            }}>
              <div style={{ fontSize: 15, fontWeight: 600, color: 'rgba(0,0,0,0.88)', marginBottom: 4 }}>Glass Panel</div>
              <div style={{ fontSize: 13, color: 'rgba(60,60,67,0.6)' }}>Content on light glass</div>
            </GlassPanel>
            <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
              {['#FF3B30', '#FF9500', '#007AFF', '#34C759', '#AF52DE'].map((c) => (
                <div key={c} style={{ width: 28, height: 28, borderRadius: 'var(--r-xs)', background: c }} />
              ))}
            </div>
          </div>
          <div style={{
            background: '#000000', borderRadius: 'var(--r-xl)', padding: 24,
            border: '0.5px solid rgba(255,255,255,0.04)',
          }}>
            <div style={{ font: 'var(--text-caption1)', color: 'rgba(235,235,245,0.6)', marginBottom: 12 }}>Dark</div>
            <GlassPanel style={{
              background: 'rgba(38,38,42,0.55)',
              border: '0.5px solid rgba(255,255,255,0.1)',
              padding: 16,
            }}>
              <div style={{ fontSize: 15, fontWeight: 600, color: 'rgba(255,255,255,0.92)', marginBottom: 4 }}>Glass Panel</div>
              <div style={{ fontSize: 13, color: 'rgba(235,235,245,0.6)' }}>Content on dark glass</div>
            </GlassPanel>
            <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
              {['#FF453A', '#FF9F0A', '#0A84FF', '#30D158', '#BF5AF2'].map((c) => (
                <div key={c} style={{ width: 28, height: 28, borderRadius: 'var(--r-xs)', background: c }} />
              ))}
            </div>
          </div>
        </div>
      </Section>

      <Section title="Contrast Ratios" description="WCAG 2.1 minimum contrast requirements">
        <SpecTable headers={contrastHeaders} rows={contrastRows} />
      </Section>
    </div>
  )
}
