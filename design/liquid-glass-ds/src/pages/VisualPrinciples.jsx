import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

const glassSpecHeaders = ['Property', 'Regular', 'Clear']
const glassSpecRows = [
  ['Background', 'rgba(255,255,255, 0.45)', 'rgba(255,255,255, 0.12)'],
  ['Blur radius', '48px (--blur-lg)', '72px (--blur-xl)'],
  ['Saturation', '180%', '200%'],
  ['Border', '0.5px white @ 45%', '0.5px white @ 25%'],
  ['Specular highlight', 'Strong top edge', 'Subtle top edge'],
  ['Use case', 'Panels, sheets, toolbars', 'Overlays, camera backgrounds'],
]

const platformTenets = [
  { name: 'iOS', tenets: 'Clarity, deference, depth. Glass elevates content with layered translucency. Touch-first, fluid gestures.' },
  { name: 'iPadOS', tenets: 'Expansive canvas, multitasking focus. Glass sidebars and floating panels define workspace boundaries.' },
  { name: 'macOS', tenets: 'Desktop precision, window management. Glass menus, sidebars, and title bars blend into the desktop.' },
  { name: 'tvOS', tenets: 'Focus-driven, cinematic scale. Glass cards float with parallax depth, responding to Siri Remote movement.' },
  { name: 'visionOS', tenets: 'Spatial computing, volumetric glass. Panels exist in 3D space with real specular lighting and depth.' },
  { name: 'watchOS', tenets: 'Glanceable, compact. Minimal glass used for backgrounds; content density is paramount on small displays.' },
]

const radii = [
  { name: 'XS', token: '--r-xs', value: '8px' },
  { name: 'SM', token: '--r-sm', value: '12px' },
  { name: 'MD', token: '--r-md', value: '16px' },
  { name: 'LG', token: '--r-lg', value: '22px' },
  { name: 'XL', token: '--r-xl', value: '28px' },
  { name: '2XL', token: '--r-2xl', value: '36px' },
  { name: 'Pill', token: '--r-pill', value: '9999px' },
]

const brandingRules = [
  { title: 'Respect the Glass', desc: 'Never place opaque branding elements over glass surfaces. Let the material speak.' },
  { title: 'Tint, Don\'t Paint', desc: 'Use subtle tints to convey brand color. A 10% opacity overlay is more effective than a solid fill.' },
  { title: 'Iconography First', desc: 'SF Symbols and monochrome icons integrate best with glass. Avoid complex illustrated logos on glass.' },
  { title: 'Typography Harmony', desc: 'Use system fonts at standard weights. Custom typefaces can clash with the glass aesthetic.' },
  { title: 'Let Content Shine', desc: 'The best branding on glass is invisible -- users remember the content experience, not the chrome.' },
]

export default function VisualPrinciples() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Visual Principles</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Liquid Glass design language, platform tenets, materials, and spatial hierarchy.
      </p>

      {/* STAR SECTION: Liquid Glass */}
      <Section title="Liquid Glass" description="The defining visual language of iOS 26 and macOS Tahoe. Glass surfaces are dynamic, translucent layers that respond to the content behind them.">
        <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 24 }}>
          Liquid Glass creates a sense of physical depth and materiality in digital interfaces.
          It uses real-time Gaussian blur, specular highlights, and subtle refraction to simulate
          frosted glass floating above content. The material adapts dynamically to the colors
          beneath it, creating an ever-changing, living surface that feels tangible and grounded
          in the physical world.
        </p>

        {/* Regular vs Clear */}
        <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 12 }}>Regular vs Clear Glass</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 24 }}>
          <Preview gradient style={{ minHeight: 200, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center' }}>
            <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.7)', marginBottom: 12 }}>Regular Glass</div>
            <GlassPanel style={{
              width: '80%',
              padding: 20,
              background: 'rgba(255,255,255,0.45)',
              backdropFilter: 'blur(48px) saturate(180%)',
              WebkitBackdropFilter: 'blur(48px) saturate(180%)',
            }}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 4 }}>Panel Title</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
                Standard blur at 48px with 45% white background. Used for most UI surfaces.
              </div>
            </GlassPanel>
          </Preview>
          <Preview gradient style={{ minHeight: 200, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center' }}>
            <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.7)', marginBottom: 12 }}>Clear Glass</div>
            <GlassPanel variant="clear" style={{
              width: '80%',
              padding: 20,
            }}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 4 }}>Panel Title</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
                Enhanced blur at 72px with 12% white. Maximum transparency for overlays.
              </div>
            </GlassPanel>
          </Preview>
        </div>

        {/* Tinted Glass */}
        <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 12 }}>Tinted Glass</div>
        <Preview gradient style={{ minHeight: 180, display: 'flex', gap: 16, alignItems: 'center', justifyContent: 'center', flexWrap: 'wrap' }}>
          {[
            { label: 'Blue Tint', bg: 'rgba(0, 122, 255, 0.12)' },
            { label: 'Green Tint', bg: 'rgba(52, 199, 89, 0.12)' },
            { label: 'Red Tint', bg: 'rgba(255, 59, 48, 0.12)' },
          ].map((t) => (
            <GlassPanel key={t.label} style={{
              padding: 20,
              minWidth: 160,
              background: t.bg,
              backdropFilter: 'blur(48px) saturate(180%)',
              WebkitBackdropFilter: 'blur(48px) saturate(180%)',
              textAlign: 'center',
            }}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 4 }}>{t.label}</div>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>Low-opacity color overlay</div>
            </GlassPanel>
          ))}
        </Preview>

        {/* Glass Over Content */}
        <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 12 }}>Glass Over Content</div>
        <Preview style={{ position: 'relative', minHeight: 280, overflow: 'hidden', padding: 0 }}>
          <div style={{ padding: 24 }}>
            <div style={{ font: 'var(--text-title2)', color: 'var(--label)', marginBottom: 12 }}>Today</div>
            <div style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', lineHeight: 1.6, marginBottom: 12 }}>
              Liquid Glass transforms your device into a window of depth and light. Every surface
              breathes with the content beneath it, creating interfaces that feel alive and responsive.
            </div>
            <div style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', lineHeight: 1.6, marginBottom: 12 }}>
              The translucent material system adapts to context -- bright and clear in the morning
              light, deep and rich in dark mode. It is a design language rooted in physical reality.
            </div>
            <div style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', lineHeight: 1.6, marginBottom: 60 }}>
              Content flows beneath glass like water under ice, always visible, always connected,
              always just a gesture away from full clarity.
            </div>
          </div>
          {/* Floating tab bar */}
          <div style={{
            position: 'absolute',
            bottom: 12,
            left: 16,
            right: 16,
            background: 'var(--glass-bg)',
            backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
            WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
            borderRadius: 'var(--r-2xl)',
            border: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
            padding: '10px 8px',
            display: 'flex',
            justifyContent: 'space-around',
            alignItems: 'center',
          }}>
            {['Home', 'Search', 'Library', 'Profile'].map((tab, i) => (
              <div key={tab} style={{
                font: 'var(--text-caption2)',
                fontWeight: i === 0 ? 600 : 400,
                color: i === 0 ? 'var(--blue)' : 'var(--label-secondary)',
                textAlign: 'center',
                padding: '4px 16px',
                borderRadius: 'var(--r-pill)',
                background: i === 0 ? 'var(--glass-bg-tinted)' : 'transparent',
              }}>
                {tab}
              </div>
            ))}
          </div>
        </Preview>

        <SpecTable headers={glassSpecHeaders} rows={glassSpecRows} />
      </Section>

      {/* Platform Tenets */}
      <Section title="Platform Tenets" description="How Liquid Glass adapts to each Apple platform.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: 16 }}>
          {platformTenets.map((p) => (
            <GlassCard key={p.name}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>{p.name}</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>{p.tenets}</div>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* Materials */}
      <Section title="Materials" description="Four material thicknesses from ultra-thin to thick, each with increasing opacity and blur.">
        <Preview gradient style={{ display: 'flex', gap: 16, flexWrap: 'wrap', justifyContent: 'center', minHeight: 180, alignItems: 'center' }}>
          {[
            { name: 'Ultra Thin', bg: 'rgba(255,255,255,0.15)', blur: '16px' },
            { name: 'Thin', bg: 'rgba(255,255,255,0.28)', blur: '32px' },
            { name: 'Regular', bg: 'rgba(255,255,255,0.45)', blur: '48px' },
            { name: 'Thick', bg: 'rgba(255,255,255,0.62)', blur: '72px' },
          ].map((m) => (
            <div key={m.name} style={{
              background: m.bg,
              backdropFilter: `blur(${m.blur}) saturate(180%)`,
              WebkitBackdropFilter: `blur(${m.blur}) saturate(180%)`,
              border: '0.5px solid rgba(255,255,255,0.3)',
              borderRadius: 'var(--r-xl)',
              padding: '20px 24px',
              minWidth: 130,
              textAlign: 'center',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
            }}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 4 }}>{m.name}</div>
              <div style={{ font: 'var(--text-caption2)', color: 'var(--label-secondary)', fontFamily: 'var(--font-mono)' }}>blur({m.blur})</div>
            </div>
          ))}
        </Preview>
      </Section>

      {/* Corner Radii */}
      <Section title="Corner Radii" description="Continuous corner (squircle) radius scale from XS to Pill.">
        <Preview>
          <div style={{ display: 'flex', gap: 20, flexWrap: 'wrap', alignItems: 'end' }}>
            {radii.map((r) => (
              <div key={r.name} style={{ textAlign: 'center' }}>
                <div style={{
                  width: r.name === 'Pill' ? 100 : 60,
                  height: 60,
                  borderRadius: `var(${r.token})`,
                  background: 'var(--blue)',
                  opacity: 0.8,
                  marginBottom: 8,
                }} />
                <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label)' }}>{r.name}</div>
                <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', fontFamily: 'var(--font-mono)' }}>{r.value}</div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* Branding */}
      <Section title="Branding" description="Rules for integrating brand identity with the Liquid Glass aesthetic.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          {brandingRules.map((b) => (
            <GlassCard key={b.title}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>{b.title}</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>{b.desc}</div>
            </GlassCard>
          ))}
        </div>
      </Section>
    </div>
  )
}
