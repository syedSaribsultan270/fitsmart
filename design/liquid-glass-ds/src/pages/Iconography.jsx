import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

const appIconHeaders = ['Platform', 'Shape', 'Masked Shape', 'Layout Size', 'Style']
const appIconRows = [
  ['iOS, iPadOS, macOS', 'Square', 'Rounded rectangle', '1024x1024 px', 'Layered'],
  ['tvOS', 'Rectangle (landscape)', 'Rounded rectangle', '800x480 px', 'Layered (parallax)'],
  ['visionOS', 'Square', 'Circular', '1024x1024 px', 'Layered (3D)'],
  ['watchOS', 'Square', 'Circular', '1088x1088 px', 'Layered'],
]

const sfSymbols = [
  { name: 'house', path: 'M3 12.5L12 3.5l9 9V21a1 1 0 01-1 1h-5v-6h-6v6H4a1 1 0 01-1-1v-8.5z' },
  { name: 'search', path: 'M10 4a6 6 0 104.45 10.04l4.25 4.26a.75.75 0 01-1.06 1.06l-4.26-4.25A6 6 0 0110 4zm-4.5 6a4.5 4.5 0 119 0 4.5 4.5 0 01-9 0z' },
  { name: 'plus', path: 'M12 4.5a.75.75 0 01.75.75v6h6a.75.75 0 010 1.5h-6v6a.75.75 0 01-1.5 0v-6h-6a.75.75 0 010-1.5h6v-6A.75.75 0 0112 4.5z' },
  { name: 'heart', path: 'M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z' },
  { name: 'person', path: 'M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z' },
  { name: 'gear', path: 'M19.14 12.94c.04-.3.06-.61.06-.94 0-.32-.02-.64-.07-.94l2.03-1.58a.49.49 0 00.12-.61l-1.92-3.32a.49.49 0 00-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94L14.4 2.81a.48.48 0 00-.48-.41h-3.84a.48.48 0 00-.48.41l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96a.49.49 0 00-.59.22L2.72 8.87a.48.48 0 00.12.61l2.03 1.58c-.05.3-.07.63-.07.94s.02.64.07.94l-2.03 1.58a.49.49 0 00-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.24.41.48.41h3.84c.24 0 .44-.17.48-.41l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6A3.6 3.6 0 1115.6 12 3.6 3.6 0 0112 15.6z' },
  { name: 'bell', path: 'M12 22c1.1 0 2-.9 2-2h-4a2 2 0 002 2zm6-6v-5c0-3.07-1.63-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.64 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z' },
  { name: 'star', path: 'M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z' },
  { name: 'trash', path: 'M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM8 9h8v10H8V9zm7.5-5l-1-1h-5l-1 1H5v2h14V4h-3.5z' },
  { name: 'pencil', path: 'M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a1 1 0 000-1.41l-2.34-2.34a1 1 0 00-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z' },
  { name: 'checkmark', path: 'M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z' },
  { name: 'xmark', path: 'M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12 19 6.41z' },
  { name: 'chevron.right', path: 'M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z' },
  { name: 'share', path: 'M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11A2.99 2.99 0 0018 8.04c1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.85A2.99 2.99 0 006 8.84c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92s2.92-1.31 2.92-2.92-1.31-2.76-2.92-2.76z' },
  { name: 'bookmark', path: 'M17 3H7c-1.1 0-2 .9-2 2v16l7-3 7 3V5c0-1.1-.9-2-2-2z' },
  { name: 'cloud', path: 'M19.35 10.04A7.49 7.49 0 0012 4C9.11 4 6.6 5.64 5.35 8.04A5.994 5.994 0 000 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96z' },
]

const renderingModes = [
  { name: 'Monochrome', desc: 'One color applied to all layers', color: 'var(--blue)', opacity: [1, 1, 1] },
  { name: 'Hierarchical', desc: 'One color with varying opacity per layer', color: 'var(--blue)', opacity: [1, 0.55, 0.25] },
  { name: 'Palette', desc: 'Two or more colors, one per layer', color: null, colors: ['var(--blue)', 'var(--cyan)', 'var(--teal)'] },
  { name: 'Multicolor', desc: 'Intrinsic colors to enhance meaning', color: null, colors: ['var(--green)', 'var(--blue)', 'var(--yellow)'] },
]

const symbolWeights = [
  { name: 'Ultralight', width: 0.8 },
  { name: 'Thin', width: 1 },
  { name: 'Light', width: 1.2 },
  { name: 'Regular', width: 1.5 },
  { name: 'Medium', width: 1.8 },
  { name: 'Semibold', width: 2.1 },
  { name: 'Bold', width: 2.5 },
  { name: 'Heavy', width: 3 },
  { name: 'Black', width: 3.5 },
]

const symbolScales = [
  { name: 'Small', size: 20, desc: 'Below cap height' },
  { name: 'Medium', size: 24, desc: 'Cap height (default)' },
  { name: 'Large', size: 28, desc: 'Above cap height' },
]

const appIconSizeHeaders = ['Platform', 'Sizes (pt)', '@2x', '@3x', 'App Store']
const appIconSizeRows = [
  ['iPhone', '60x60', '120x120', '180x180', '1024x1024'],
  ['iPad', '76x76, 83.5x83.5', '152x152, 167x167', '\u2014', '1024x1024'],
  ['Mac', '16\u2013512', 'up to 1024', '\u2014', '1024x1024'],
  ['Watch', '40\u201350', '80\u2013100', '\u2014', '1024x1024'],
]

const symbolEffects = [
  {
    name: 'Bounce',
    anim: 'iconBounce',
    desc: 'Draws attention with a spring upward',
    symbol: 0, // house
  },
  {
    name: 'Pulse',
    anim: 'iconPulse',
    desc: 'Rhythmic scale for ongoing status',
    symbol: 3, // heart
  },
  {
    name: 'Scale',
    anim: 'iconScale',
    desc: 'Grows from nothing with spring',
    symbol: 2, // plus
  },
  {
    name: 'Appear',
    anim: 'iconAppear',
    desc: 'Fades and scales in smoothly',
    symbol: 7, // star
  },
  {
    name: 'Disappear',
    anim: 'iconDisappear',
    desc: 'Fades and scales out smoothly',
    symbol: 6, // bell
  },
  {
    name: 'Wiggle',
    anim: 'iconWiggle',
    desc: 'Oscillating rotation for alerts',
    symbol: 6, // bell
  },
  {
    name: 'Replace',
    anim: 'iconReplace',
    desc: 'Cross-fade transition between symbols',
    symbol: 3, // heart
    symbolAlt: 7, // star
  },
]

const customSymbolGuidelines = [
  {
    title: 'Design on a 22x22 Template',
    desc: 'Use the SF Symbols template at Regular weight. The 22x22pt canvas aligns with the default Medium scale and ensures optical consistency with system symbols.',
  },
  {
    title: 'Align to Baseline and Cap Height',
    desc: 'Anchor your symbol to the typographic baseline and cap height guides. This ensures vertical alignment when the symbol sits alongside text in labels, buttons, and lists.',
  },
  {
    title: 'Match Stroke Widths',
    desc: 'Match the stroke width of your custom symbol to the corresponding SF Symbols weight. At Regular weight, strokes are approximately 1.5pt.',
  },
  {
    title: 'Support All 9 Weights and 3 Scales',
    desc: 'For full compatibility, provide artwork for Ultralight through Black (9 weights) at Small, Medium, and Large scales \u2014 27 variants total.',
  },
  {
    title: 'Export as SVG Template',
    desc: 'Export using the SF Symbols app. The SVG template includes annotation layers for alignment, weight, and scale metadata that Xcode reads at build time.',
  },
]

// WiFi-like SVG for variable color demo
function WifiSymbol({ fillPercent, size = 48 }) {
  // 4 arcs from bottom to top; fill based on percentage
  const arcs = [
    { d: 'M10 17.5a2.5 2.5 0 015 0', threshold: 0 },
    { d: 'M6.5 14a7 7 0 0112 0', threshold: 33 },
    { d: 'M3 10.5a11.5 11.5 0 0119 0', threshold: 66 },
  ]
  return (
    <svg width={size} height={size} viewBox="0 0 25 22" fill="none" strokeLinecap="round" strokeLinejoin="round">
      {/* Dot at bottom */}
      <circle
        cx="12.5"
        cy="19"
        r="1.5"
        fill={fillPercent > 0 ? 'var(--blue)' : 'var(--gray3)'}
      />
      {arcs.map((arc, i) => (
        <path
          key={i}
          d={arc.d}
          stroke={fillPercent > arc.threshold ? 'var(--blue)' : 'var(--gray3)'}
          strokeWidth="2.2"
          fill="none"
        />
      ))}
    </svg>
  )
}

// Speaker wave SVG for variable color
function SpeakerSymbol({ fillPercent, size = 48 }) {
  const waveThresholds = [0, 33, 66]
  return (
    <svg width={size} height={size} viewBox="0 0 28 24" fill="none">
      {/* Speaker body - always filled */}
      <path
        d="M3 9h4l5-5v16l-5-5H3a1 1 0 01-1-1v-4a1 1 0 011-1z"
        fill={fillPercent > 0 ? 'var(--blue)' : 'var(--gray3)'}
      />
      {/* Wave 1 - small */}
      <path
        d="M16 9.5a3.5 3.5 0 010 5"
        stroke={fillPercent > waveThresholds[0] ? 'var(--blue)' : 'var(--gray3)'}
        strokeWidth="2"
        strokeLinecap="round"
      />
      {/* Wave 2 - medium */}
      <path
        d="M19 7a7 7 0 010 10"
        stroke={fillPercent > waveThresholds[1] ? 'var(--blue)' : 'var(--gray3)'}
        strokeWidth="2"
        strokeLinecap="round"
      />
      {/* Wave 3 - large */}
      <path
        d="M22 4.5a10.5 10.5 0 010 15"
        stroke={fillPercent > waveThresholds[2] ? 'var(--blue)' : 'var(--gray3)'}
        strokeWidth="2"
        strokeLinecap="round"
      />
    </svg>
  )
}

const keyframesCSS = `
@keyframes iconBounce {
  0%   { transform: translateY(0); }
  30%  { transform: translateY(-8px); }
  50%  { transform: translateY(-2px); }
  70%  { transform: translateY(-5px); }
  100% { transform: translateY(0); }
}
@keyframes iconPulse {
  0%   { transform: scale(1); }
  25%  { transform: scale(1.2); }
  50%  { transform: scale(1); }
  75%  { transform: scale(1.2); }
  100% { transform: scale(1); }
}
@keyframes iconScale {
  0%   { transform: scale(0); }
  60%  { transform: scale(1.1); }
  80%  { transform: scale(0.95); }
  100% { transform: scale(1); }
}
@keyframes iconAppear {
  0%   { opacity: 0; transform: scale(0.5); }
  60%  { opacity: 1; transform: scale(1.05); }
  100% { opacity: 1; transform: scale(1); }
}
@keyframes iconDisappear {
  0%   { opacity: 1; transform: scale(1); }
  100% { opacity: 0; transform: scale(0.5); }
}
@keyframes iconWiggle {
  0%   { transform: rotate(0deg); }
  15%  { transform: rotate(12deg); }
  30%  { transform: rotate(-10deg); }
  45%  { transform: rotate(8deg); }
  60%  { transform: rotate(-6deg); }
  75%  { transform: rotate(3deg); }
  100% { transform: rotate(0deg); }
}
@keyframes iconReplaceOut {
  0%   { opacity: 1; transform: scale(1); }
  100% { opacity: 0; transform: scale(0.3); }
}
@keyframes iconReplaceIn {
  0%   { opacity: 0; transform: scale(0.3); }
  100% { opacity: 1; transform: scale(1); }
}
`

function EffectDemo({ effect, symbols }) {
  const [playing, setPlaying] = useState(false)
  const [key, setKey] = useState(0)

  const play = () => {
    setKey((k) => k + 1)
    setPlaying(true)
    setTimeout(() => setPlaying(false), 800)
  }

  const isReplace = effect.name === 'Replace'

  return (
    <GlassCard style={{ padding: 20, textAlign: 'center', cursor: 'default' }}>
      <div style={{
        height: 56, display: 'flex', alignItems: 'center', justifyContent: 'center',
        marginBottom: 12, position: 'relative',
      }}>
        {isReplace ? (
          <>
            <svg
              key={`a-${key}`}
              width="32" height="32" viewBox="0 0 24 24" fill="var(--blue)"
              style={{
                position: 'absolute',
                animation: playing ? 'iconReplaceOut 0.4s var(--ease) forwards' : 'none',
              }}
            >
              <path d={symbols[effect.symbol].path} />
            </svg>
            <svg
              key={`b-${key}`}
              width="32" height="32" viewBox="0 0 24 24" fill="var(--purple)"
              style={{
                position: 'absolute',
                opacity: playing ? 1 : 0,
                animation: playing ? 'iconReplaceIn 0.4s var(--ease) 0.15s both' : 'none',
              }}
            >
              <path d={symbols[effect.symbolAlt].path} />
            </svg>
          </>
        ) : (
          <svg
            key={key}
            width="32" height="32" viewBox="0 0 24 24" fill="var(--blue)"
            style={{
              animation: playing
                ? `${effect.anim} 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) forwards`
                : 'none',
            }}
          >
            <path d={symbols[effect.symbol].path} />
          </svg>
        )}
      </div>
      <div style={{ font: 'var(--text-headline)', marginBottom: 4 }}>{effect.name}</div>
      <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)', marginBottom: 12 }}>
        {effect.desc}
      </div>
      <GlassButton
        variant="glass"
        size="sm"
        onClick={play}
        style={{ font: 'var(--text-caption1)' }}
      >
        <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" style={{ marginRight: 4 }}>
          <path d="M8 5v14l11-7z" />
        </svg>
        Play
      </GlassButton>
    </GlassCard>
  )
}

export default function Iconography() {
  return (
    <div>
      <style>{keyframesCSS}</style>

      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Iconography</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        SF Symbols, app icon specifications, and rendering modes.
      </p>

      {/* ---- Existing: App Icon Sizes ---- */}
      <Section title="App Icon Sizes" description="Required icon dimensions per platform">
        <SpecTable headers={appIconHeaders} rows={appIconRows} />
      </Section>

      {/* ---- Existing: SF Symbols ---- */}
      <Section title="SF Symbols" description="16 common symbols rendered as inline SVG">
        <Preview>
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(80px, 1fr))',
            gap: 16,
            justifyItems: 'center',
          }}>
            {sfSymbols.map((s) => (
              <div key={s.name} style={{
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8,
                padding: 12, borderRadius: 'var(--r-md)',
              }}>
                <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" style={{ color: 'var(--label)' }}>
                  <path d={s.path} />
                </svg>
                <div style={{
                  font: 'var(--text-caption2)', color: 'var(--label-tertiary)',
                  textAlign: 'center', wordBreak: 'break-all',
                }}>
                  {s.name}
                </div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ---- Existing: Rendering Modes ---- */}
      <Section title="Rendering Modes" description="Four rendering modes for SF Symbols">
        <div style={{
          display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: 16,
        }}>
          {renderingModes.map((mode) => (
            <GlassPanel key={mode.name} style={{ padding: 20, textAlign: 'center' }}>
              <div style={{ display: 'flex', justifyContent: 'center', gap: 8, marginBottom: 12 }}>
                {mode.opacity ? (
                  mode.opacity.map((op, i) => (
                    <svg key={i} width="28" height="28" viewBox="0 0 24 24" fill={mode.color} opacity={op}>
                      <path d={sfSymbols[0].path} />
                    </svg>
                  ))
                ) : (
                  mode.colors.map((c, i) => (
                    <svg key={i} width="28" height="28" viewBox="0 0 24 24" fill={c}>
                      <path d={sfSymbols[i].path} />
                    </svg>
                  ))
                )}
              </div>
              <div style={{ font: 'var(--text-headline)', marginBottom: 4 }}>{mode.name}</div>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>{mode.desc}</div>
            </GlassPanel>
          ))}
        </div>
      </Section>

      {/* ---- Existing: Symbol Weights ---- */}
      <Section title="Symbol Weights" description="9 weights matching SF Pro font weights">
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {symbolWeights.map((w) => (
              <div key={w.name} style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
                <div style={{ minWidth: 90, font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>
                  {w.name}
                </div>
                <svg width="32" height="32" viewBox="0 0 32 32" fill="none" stroke="currentColor" strokeWidth={w.width} style={{ color: 'var(--label)' }}>
                  <circle cx="16" cy="16" r="12" />
                </svg>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ---- Existing: Symbol Scales ---- */}
      <Section title="Symbol Scales" description="Three relative scales for SF Symbols alongside text">
        <Preview>
          <div style={{ display: 'flex', alignItems: 'center', gap: 32 }}>
            {symbolScales.map((s) => (
              <div key={s.name} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                <svg width={s.size} height={s.size} viewBox="0 0 24 24" fill="currentColor" style={{ color: 'var(--blue)' }}>
                  <path d={sfSymbols[7].path} />
                </svg>
                <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label)' }}>
                  {s.name}
                </div>
                <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>
                  {s.size}px — {s.desc}
                </div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          NEW SECTION: App Icon Design
          ============================================================ */}
      <Section
        title="App Icon Design"
        description="The icon grid, keyline shapes, and platform-specific sizes for app icons"
      >
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24 }}>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', textAlign: 'center', maxWidth: 520 }}>
              All app icons are designed on a 1024x1024 grid with keyline shapes overlaid.
              The system masks the icon to its platform shape — you provide a full-bleed square.
            </div>
            <div style={{ display: 'flex', gap: 32, flexWrap: 'wrap', justifyContent: 'center' }}>
              {/* Icon grid with keylines */}
              <svg width="200" height="200" viewBox="0 0 200 200" style={{ borderRadius: 'var(--r-lg)', overflow: 'hidden' }}>
                {/* Background fill */}
                <rect width="200" height="200" fill="var(--gray5)" />
                {/* Grid lines - every 1/4 */}
                {[50, 100, 150].map((pos) => (
                  <g key={pos}>
                    <line x1={pos} y1="0" x2={pos} y2="200" stroke="var(--label-quaternary)" strokeWidth="0.5" />
                    <line x1="0" y1={pos} x2="200" y2={pos} stroke="var(--label-quaternary)" strokeWidth="0.5" />
                  </g>
                ))}
                {/* Circle keyline - ~80% diameter */}
                <circle cx="100" cy="100" r="80" fill="none" stroke="var(--blue)" strokeWidth="1" strokeDasharray="4 3" opacity="0.7" />
                {/* Rounded rect keyline - ~85% width, inner radius ~22% */}
                <rect x="15" y="15" width="170" height="170" rx="38" ry="38" fill="none" stroke="var(--green)" strokeWidth="1" strokeDasharray="4 3" opacity="0.7" />
                {/* Horizontal rect keyline - full width, ~70% height */}
                <rect x="0" y="30" width="200" height="140" rx="0" ry="0" fill="none" stroke="var(--orange)" strokeWidth="1" strokeDasharray="4 3" opacity="0.6" />
                {/* Center crosshair */}
                <line x1="95" y1="100" x2="105" y2="100" stroke="var(--label-tertiary)" strokeWidth="0.75" />
                <line x1="100" y1="95" x2="100" y2="105" stroke="var(--label-tertiary)" strokeWidth="0.75" />
              </svg>

              {/* Legend */}
              <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', gap: 16 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <div style={{ width: 24, height: 2, background: 'var(--blue)', borderRadius: 1, opacity: 0.7 }} />
                  <span style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>Circle keyline (80% diameter)</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <div style={{ width: 24, height: 2, background: 'var(--green)', borderRadius: 1, opacity: 0.7 }} />
                  <span style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>Rounded rect keyline (85%, r22%)</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <div style={{ width: 24, height: 2, background: 'var(--orange)', borderRadius: 1, opacity: 0.7 }} />
                  <span style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>Horizontal rect keyline (70% height)</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <div style={{ width: 24, height: 1, background: 'var(--label-quaternary)', borderRadius: 1 }} />
                  <span style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>Quarter grid (250px intervals)</span>
                </div>
              </div>
            </div>
          </div>
        </Preview>

        <SpecTable headers={appIconSizeHeaders} rows={appIconSizeRows} />

        <GlassPanel style={{ padding: 20, marginTop: 16 }}>
          <div style={{ display: 'flex', gap: 12, alignItems: 'flex-start' }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="var(--blue)" style={{ flexShrink: 0, marginTop: 2 }}>
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z" />
            </svg>
            <div>
              <div style={{ font: 'var(--text-headline)', marginBottom: 4 }}>Layered Icons (iOS 26+)</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
                Starting with iOS 26, app icons support a layered format with a <strong>front layer</strong> and a <strong>back layer</strong>.
                The system automatically applies Liquid Glass material attributes — including translucency, refraction, and specular highlights —
                to the front layer, creating a dynamic, depth-aware appearance on the Home Screen. Provide both layers as separate assets in your asset catalog.
              </div>
            </div>
          </div>
        </GlassPanel>
      </Section>

      {/* ============================================================
          NEW SECTION: Variable Color
          ============================================================ */}
      <Section
        title="Variable Color"
        description="Symbols can show percentage-based variable color fills to indicate levels like signal strength or volume"
      >
        <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 20, maxWidth: 640 }}>
          Variable color progressively fills symbol layers from bottom to top. iOS uses this for Wi-Fi signal strength,
          cellular bars, speaker volume, and other level-based indicators. The fill percentage maps directly to the value being represented.
        </div>

        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 32 }}>
            {/* WiFi fill levels */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', marginBottom: 12, textTransform: 'uppercase', letterSpacing: 1 }}>
                Wi-Fi Signal Strength
              </div>
              <div style={{ display: 'flex', gap: 24, alignItems: 'flex-end' }}>
                {[0, 33, 66, 100].map((pct) => (
                  <div key={pct} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                    <WifiSymbol fillPercent={pct} size={48} />
                    <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>{pct}%</div>
                  </div>
                ))}
              </div>
            </div>

            {/* Speaker fill levels */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', marginBottom: 12, textTransform: 'uppercase', letterSpacing: 1 }}>
                Speaker Volume Level
              </div>
              <div style={{ display: 'flex', gap: 24, alignItems: 'flex-end' }}>
                {[0, 33, 66, 100].map((pct) => (
                  <div key={pct} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                    <SpeakerSymbol fillPercent={pct} size={48} />
                    <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>{pct}%</div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </Preview>

        <GlassPanel style={{ padding: 20, marginTop: 8 }}>
          <div style={{ display: 'flex', gap: 12, alignItems: 'flex-start' }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="var(--purple)" style={{ flexShrink: 0, marginTop: 2 }}>
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z" />
            </svg>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              In SwiftUI, apply <code style={{ fontFamily: 'var(--font-mono)', fontSize: 13, background: 'var(--fill)', padding: '2px 6px', borderRadius: 4 }}>
              .symbolEffect(.variableColor.iterative)</code> to animate through fill levels automatically,
              or bind to a numeric value with <code style={{ fontFamily: 'var(--font-mono)', fontSize: 13, background: 'var(--fill)', padding: '2px 6px', borderRadius: 4 }}>
              .symbolVariableValue(_:)</code> for manual control.
            </div>
          </div>
        </GlassPanel>
      </Section>

      {/* ============================================================
          NEW SECTION: Symbol Effects
          ============================================================ */}
      <Section
        title="Symbol Effects"
        description="Seven animated effects for SF Symbols — tap Play to preview each animation"
      >
        <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 20, maxWidth: 640 }}>
          Symbol effects bring icons to life with carefully tuned motion. Each effect uses spring-based
          timing curves to match iOS system animations. In SwiftUI, apply these with the
          {' '}<code style={{ fontFamily: 'var(--font-mono)', fontSize: 13, background: 'var(--fill)', padding: '2px 6px', borderRadius: 4 }}>.symbolEffect()</code> modifier.
        </div>

        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fill, minmax(180px, 1fr))',
          gap: 16,
        }}>
          {symbolEffects.map((effect) => (
            <EffectDemo key={effect.name} effect={effect} symbols={sfSymbols} />
          ))}
        </div>
      </Section>

      {/* ============================================================
          NEW SECTION: Custom Symbols
          ============================================================ */}
      <Section
        title="Custom Symbols"
        description="Guidelines for designing custom SF Symbols that harmonize with the system set"
      >
        <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 20, maxWidth: 640 }}>
          Custom symbols extend SF Symbols with your own glyphs. Follow these guidelines to ensure your
          symbols feel native and support all rendering modes, weights, and scales.
        </div>

        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
          gap: 16,
        }}>
          {customSymbolGuidelines.map((g, i) => (
            <GlassCard key={i} style={{ padding: 20, cursor: 'default' }}>
              <div style={{
                width: 32, height: 32, borderRadius: 'var(--r-sm)',
                background: 'var(--fill)', display: 'flex', alignItems: 'center', justifyContent: 'center',
                marginBottom: 12, font: 'var(--text-headline)', color: 'var(--blue)',
              }}>
                {i + 1}
              </div>
              <div style={{ font: 'var(--text-headline)', marginBottom: 6 }}>{g.title}</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', lineHeight: '20px' }}>
                {g.desc}
              </div>
            </GlassCard>
          ))}
        </div>

        <Preview style={{ marginTop: 20 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 24, flexWrap: 'wrap', justifyContent: 'center' }}>
            <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', textTransform: 'uppercase', letterSpacing: 1 }}>
              Template grid example (22x22)
            </div>
            <svg width="132" height="132" viewBox="0 0 22 22" style={{ border: '0.5px solid var(--separator)', borderRadius: 'var(--r-sm)' }}>
              {/* Grid */}
              {Array.from({ length: 23 }, (_, i) => (
                <g key={i}>
                  <line x1={i} y1="0" x2={i} y2="22" stroke="var(--separator)" strokeWidth="0.05" />
                  <line x1="0" y1={i} x2="22" y2={i} stroke="var(--separator)" strokeWidth="0.05" />
                </g>
              ))}
              {/* Cap height guide */}
              <line x1="0" y1="4" x2="22" y2="4" stroke="var(--red)" strokeWidth="0.08" opacity="0.5" />
              {/* Baseline guide */}
              <line x1="0" y1="18" x2="22" y2="18" stroke="var(--red)" strokeWidth="0.08" opacity="0.5" />
              {/* Example custom symbol: a lightning bolt */}
              <path
                d="M12 2L6 12h4l-2 8 8-10h-4l2-8z"
                fill="none"
                stroke="var(--label)"
                strokeWidth="0.4"
                strokeLinejoin="round"
                strokeLinecap="round"
              />
              {/* Labels */}
              <text x="0.5" y="3.7" fill="var(--red)" fontSize="1" opacity="0.7">cap height</text>
              <text x="0.5" y="18.9" fill="var(--red)" fontSize="1" opacity="0.7">baseline</text>
            </svg>
          </div>
        </Preview>
      </Section>
    </div>
  )
}
