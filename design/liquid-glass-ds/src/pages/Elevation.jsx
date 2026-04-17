import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

/* ── data ─────────────────────────────────────────────────── */

const zIndexHeaders = ['Layer', 'z-index', 'Token', 'Use Case']
const zIndexRows = [
  ['Content', '0', '--z-content', 'Base page content, scroll views'],
  ['Sticky', '100', '--z-sticky', 'Sticky headers, floating action buttons'],
  ['Dropdown', '200', '--z-dropdown', 'Menus, popovers, tooltips'],
  ['Overlay', '300', '--z-overlay', 'Sheets, sidebars, drawers'],
  ['Modal', '400', '--z-modal', 'Alert dialogs, confirmations'],
  ['Toast', '500', '--z-toast', 'Notifications, snackbars, banners'],
]

const zLayers = [
  { name: 'Content', z: 0, color: 'rgba(142,142,147,0.25)', label: 'z: 0' },
  { name: 'Sticky', z: 100, color: 'rgba(0,122,255,0.2)', label: 'z: 100' },
  { name: 'Dropdown', z: 200, color: 'rgba(48,176,199,0.2)', label: 'z: 200' },
  { name: 'Overlay', z: 300, color: 'rgba(88,86,214,0.2)', label: 'z: 300' },
  { name: 'Modal', z: 400, color: 'rgba(175,82,222,0.2)', label: 'z: 400' },
  { name: 'Toast', z: 500, color: 'rgba(255,45,85,0.2)', label: 'z: 500' },
]

const scrollEdgeHeaders = ['Edge Type', 'When to Use', 'Transition']
const scrollEdgeRows = [
  ['Soft edge', 'Default for most views; content fades beneath glass controls', 'Gradual blur + opacity fade over 20px'],
  ['Hard edge', 'Dense data tables; content behind glass would be distracting', 'Sharp clip boundary, no gradient fade'],
]

const depthBlurHeaders = ['Material', 'Blur', 'Opacity', 'Use Case']
const depthBlurRows = [
  ['Thin', '16px (--blur-sm)', '0.28', 'Lightweight overlays, transient popovers'],
  ['Regular', '48px (--blur-lg)', '0.45', 'Standard toolbars, tab bars, nav bars'],
  ['Thick', '72px (--blur-xl)', '0.62', 'Sidebars, persistent panels, alerts'],
]

const hierarchyLayers = [
  {
    name: 'Background Glass',
    sub: 'Sidebar',
    blur: '--blur-xl',
    bg: '--glass-bg-thick',
    opacity: 0.78,
    desc: 'Thickest, most opaque. Persistent surfaces like sidebars.',
  },
  {
    name: 'Mid-level Glass',
    sub: 'Toolbar',
    blur: '--blur-lg',
    bg: '--glass-bg',
    opacity: 0.45,
    desc: 'Standard glass. Tab bars, toolbars, navigation bars.',
  },
  {
    name: 'Foreground Glass',
    sub: 'Popover',
    blur: '--blur-md',
    bg: '--glass-bg-thin',
    opacity: 0.35,
    desc: 'Lighter glass, more blur. Transient popovers and menus.',
  },
  {
    name: 'Alert Glass',
    sub: 'Modal',
    blur: '--blur-xl',
    bg: '--glass-bg-thick',
    opacity: 0.72,
    desc: 'Highest blur + specular. Alerts, confirmation dialogs.',
  },
]

/* ── helpers ──────────────────────────────────────────────── */

const mono = { fontFamily: 'var(--font-mono)', fontSize: 12 }
const labelSm = { font: 'var(--text-caption1)', color: 'var(--label-secondary)' }

/* ── page ─────────────────────────────────────────────────── */

export default function Elevation() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Elevation</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Depth, layering, and the Liquid Glass material hierarchy.
        How surfaces stack, how glass separates content from controls, and how depth cues communicate hierarchy.
      </p>

      {/* ═══════════════════════════════════════════════════════
          1 — Z-Index Scale
          ═══════════════════════════════════════════════════════ */}
      <Section
        title="Z-Index Scale"
        description="A structured z-index scale prevents stacking conflicts. Each elevation tier is separated by 100 to allow intermediate layers."
      >
        <Preview gradient style={{ minHeight: 360, display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
          <div style={{
            position: 'relative',
            width: 340,
            height: 300,
            perspective: '800px',
            transformStyle: 'preserve-3d',
          }}>
            {zLayers.map((layer, i) => (
              <div key={layer.name} style={{
                position: 'absolute',
                left: i * 12,
                top: 220 - i * 40,
                width: 280,
                padding: '12px 16px',
                background: layer.color,
                backdropFilter: 'blur(24px) saturate(180%)',
                WebkitBackdropFilter: 'blur(24px) saturate(180%)',
                border: '0.5px solid rgba(255,255,255,0.15)',
                borderRadius: 'var(--r-md)',
                boxShadow: '0 2px 12px rgba(0,0,0,0.15), inset 0 1px 0 rgba(255,255,255,0.1)',
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                transform: `translateZ(${i * 8}px) rotateX(2deg) rotateY(-3deg)`,
                zIndex: layer.z,
              }}>
                <span style={{
                  font: 'var(--text-subhead)',
                  fontWeight: 600,
                  color: 'rgba(255,255,255,0.9)',
                }}>
                  {layer.name}
                </span>
                <span style={{
                  ...mono,
                  color: 'rgba(255,255,255,0.5)',
                  fontSize: 11,
                }}>
                  {layer.label}
                </span>
              </div>
            ))}
          </div>
        </Preview>

        <SpecTable headers={zIndexHeaders} rows={zIndexRows} />
      </Section>

      {/* ═══════════════════════════════════════════════════════
          2 — Material Layers
          ═══════════════════════════════════════════════════════ */}
      <Section
        title="Material Layers"
        description="The fundamental Liquid Glass rule: content lives on opaque surfaces, controls use translucent glass. Glass is never applied to content areas."
      >
        <Preview gradient style={{ display: 'flex', justifyContent: 'center', padding: 32 }}>
          {/* Phone mock showing content vs control */}
          <div style={{
            width: 200,
            height: 400,
            borderRadius: 'var(--r-2xl)',
            border: '2px solid rgba(255,255,255,0.15)',
            position: 'relative',
            overflow: 'hidden',
            background: '#1c1c1e',
            flexShrink: 0,
          }}>
            {/* Status bar area / Dynamic Island */}
            <div style={{
              position: 'absolute', top: 8, left: '50%', transform: 'translateX(-50%)',
              width: 72, height: 22, borderRadius: 'var(--r-pill)',
              background: 'rgba(0,0,0,0.8)', zIndex: 5,
            }} />

            {/* Nav bar — glass control layer */}
            <div style={{
              position: 'absolute', top: 0, left: 0, right: 0,
              height: 56,
              background: 'rgba(255,255,255,0.12)',
              backdropFilter: 'blur(48px)',
              WebkitBackdropFilter: 'blur(48px)',
              borderBottom: '0.5px solid rgba(255,255,255,0.08)',
              display: 'flex', alignItems: 'flex-end', justifyContent: 'center',
              paddingBottom: 8, zIndex: 3,
            }}>
              <span style={{ fontSize: 11, fontWeight: 600, color: 'rgba(255,255,255,0.85)' }}>Nav Bar</span>
            </div>

            {/* Annotation arrow — control layer */}
            <div style={{
              position: 'absolute', top: 30, right: -2, zIndex: 4,
              display: 'flex', alignItems: 'center', gap: 4,
            }}>
              <div style={{
                background: 'rgba(0,122,255,0.7)',
                borderRadius: 'var(--r-xs)',
                padding: '2px 6px',
                fontSize: 8, fontWeight: 700, color: '#fff',
                whiteSpace: 'nowrap',
              }}>Control Layer</div>
            </div>

            {/* Content area */}
            <div style={{
              position: 'absolute', top: 56, left: 0, right: 0, bottom: 56,
              background: '#1c1c1e',
              padding: '16px 12px',
              display: 'flex', flexDirection: 'column', gap: 10,
              overflow: 'hidden',
            }}>
              {/* Fake content blocks */}
              <div style={{ height: 80, borderRadius: 'var(--r-sm)', background: 'rgba(255,255,255,0.04)' }} />
              <div style={{ height: 12, width: '90%', borderRadius: 4, background: 'rgba(255,255,255,0.06)' }} />
              <div style={{ height: 12, width: '70%', borderRadius: 4, background: 'rgba(255,255,255,0.06)' }} />
              <div style={{ height: 12, width: '80%', borderRadius: 4, background: 'rgba(255,255,255,0.06)' }} />
              <div style={{ height: 60, borderRadius: 'var(--r-sm)', background: 'rgba(255,255,255,0.04)', marginTop: 4 }} />
              <div style={{ height: 12, width: '60%', borderRadius: 4, background: 'rgba(255,255,255,0.06)' }} />
            </div>

            {/* Content area label */}
            <div style={{
              position: 'absolute', top: '45%', left: '50%', transform: 'translate(-50%, -50%)',
              zIndex: 2, fontSize: 10, fontWeight: 600, color: 'rgba(255,255,255,0.35)',
              textAlign: 'center', pointerEvents: 'none',
            }}>
              Content Layer<br />
              <span style={{ fontSize: 8, fontWeight: 400, opacity: 0.7 }}>(opaque, no glass)</span>
            </div>

            {/* Tab bar — glass control layer */}
            <div style={{
              position: 'absolute', bottom: 0, left: 0, right: 0,
              height: 56,
              background: 'rgba(255,255,255,0.12)',
              backdropFilter: 'blur(48px)',
              WebkitBackdropFilter: 'blur(48px)',
              borderTop: '0.5px solid rgba(255,255,255,0.08)',
              display: 'flex', alignItems: 'center', justifyContent: 'space-around',
              padding: '0 12px',
              zIndex: 3,
            }}>
              {Array.from({ length: 4 }).map((_, i) => (
                <div key={i} style={{
                  width: 20, height: 20, borderRadius: 4,
                  background: i === 0 ? 'rgba(0,122,255,0.5)' : 'rgba(255,255,255,0.12)',
                }} />
              ))}
            </div>

            {/* Annotation arrow — control layer bottom */}
            <div style={{
              position: 'absolute', bottom: 30, right: -2, zIndex: 4,
              display: 'flex', alignItems: 'center', gap: 4,
            }}>
              <div style={{
                background: 'rgba(0,122,255,0.7)',
                borderRadius: 'var(--r-xs)',
                padding: '2px 6px',
                fontSize: 8, fontWeight: 700, color: '#fff',
                whiteSpace: 'nowrap',
              }}>Control Layer</div>
            </div>
          </div>
        </Preview>

        {/* Guidelines cards */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: 16, marginBottom: 24 }}>
          <GlassCard style={{ padding: 20 }}>
            <div style={{ font: 'var(--text-headline)', marginBottom: 6, color: 'var(--label)' }}>
              Glass is for controls, not content
            </div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', lineHeight: '20px' }}>
              Liquid Glass is reserved for the control layer: tab bars, toolbars, sidebars, and navigation bars.
              Content areas always use opaque backgrounds.
            </div>
          </GlassCard>

          <GlassCard style={{ padding: 20 }}>
            <div style={{ font: 'var(--text-headline)', marginBottom: 6, color: 'var(--label)' }}>
              Content scrolls beneath glass
            </div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', lineHeight: '20px' }}>
              Glass controls float above scrolling content. The translucent blur lets content peek through,
              maintaining spatial context while keeping controls prominent.
            </div>
          </GlassCard>

          <GlassCard style={{ padding: 20 }}>
            <div style={{ font: 'var(--text-headline)', marginBottom: 6, color: 'var(--label)' }}>
              Interactive controls gain glass
            </div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', lineHeight: '20px' }}>
              Sliders, toggles, and segmented controls gain a Liquid Glass appearance
              on interaction (press/drag). This is the exception to the content-layer rule.
            </div>
          </GlassCard>
        </div>
      </Section>

      {/* ═══════════════════════════════════════════════════════
          3 — Scroll Edge Effects
          ═══════════════════════════════════════════════════════ */}
      <Section
        title="Scroll Edge Effects"
        description="The transition between scrolling content and a glass control bar. The edge treatment defines how content disappears beneath glass."
      >
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: 16, marginBottom: 16 }}>
          {/* Soft edge */}
          <Preview gradient>
            <div style={{ textAlign: 'center', marginBottom: 12 }}>
              <span style={{ font: 'var(--text-headline)', color: 'rgba(255,255,255,0.9)' }}>Soft Edge</span>
            </div>
            <div style={{
              width: '100%', height: 200, borderRadius: 'var(--r-lg)',
              overflow: 'hidden', position: 'relative',
              background: '#1c1c1e',
            }}>
              {/* Content lines */}
              <div style={{ padding: '12px 16px', display: 'flex', flexDirection: 'column', gap: 8 }}>
                {Array.from({ length: 8 }).map((_, i) => (
                  <div key={i} style={{
                    height: 10, borderRadius: 4,
                    width: `${65 + (i % 3) * 12}%`,
                    background: 'rgba(255,255,255,0.08)',
                  }} />
                ))}
              </div>

              {/* Gradient fade into glass */}
              <div style={{
                position: 'absolute', bottom: 44, left: 0, right: 0, height: 24,
                background: 'linear-gradient(to bottom, transparent, rgba(255,255,255,0.06))',
                backdropFilter: 'blur(8px)',
                WebkitBackdropFilter: 'blur(8px)',
                pointerEvents: 'none',
              }} />

              {/* Glass bar */}
              <div style={{
                position: 'absolute', bottom: 0, left: 0, right: 0, height: 44,
                background: 'rgba(255,255,255,0.12)',
                backdropFilter: 'blur(48px)',
                WebkitBackdropFilter: 'blur(48px)',
                borderTop: '0.5px solid rgba(255,255,255,0.06)',
                display: 'flex', alignItems: 'center', justifyContent: 'space-around',
                padding: '0 24px',
              }}>
                {Array.from({ length: 3 }).map((_, i) => (
                  <div key={i} style={{ width: 16, height: 16, borderRadius: 3, background: 'rgba(255,255,255,0.15)' }} />
                ))}
              </div>

              {/* Annotation */}
              <div style={{
                position: 'absolute', bottom: 50, right: 8,
                fontSize: 9, color: 'rgba(52,199,89,0.8)', fontWeight: 600,
              }}>
                gradual fade
              </div>
            </div>
          </Preview>

          {/* Hard edge */}
          <Preview gradient>
            <div style={{ textAlign: 'center', marginBottom: 12 }}>
              <span style={{ font: 'var(--text-headline)', color: 'rgba(255,255,255,0.9)' }}>Hard Edge</span>
            </div>
            <div style={{
              width: '100%', height: 200, borderRadius: 'var(--r-lg)',
              overflow: 'hidden', position: 'relative',
              background: '#1c1c1e',
            }}>
              {/* Content lines */}
              <div style={{ padding: '12px 16px', display: 'flex', flexDirection: 'column', gap: 8 }}>
                {Array.from({ length: 8 }).map((_, i) => (
                  <div key={i} style={{
                    height: 10, borderRadius: 4,
                    width: `${65 + (i % 3) * 12}%`,
                    background: 'rgba(255,255,255,0.08)',
                  }} />
                ))}
              </div>

              {/* Hard clip — no gradient */}
              <div style={{
                position: 'absolute', bottom: 0, left: 0, right: 0, height: 44,
                background: 'rgba(255,255,255,0.12)',
                backdropFilter: 'blur(48px)',
                WebkitBackdropFilter: 'blur(48px)',
                borderTop: '1px solid rgba(255,255,255,0.1)',
                display: 'flex', alignItems: 'center', justifyContent: 'space-around',
                padding: '0 24px',
              }}>
                {Array.from({ length: 3 }).map((_, i) => (
                  <div key={i} style={{ width: 16, height: 16, borderRadius: 3, background: 'rgba(255,255,255,0.15)' }} />
                ))}
              </div>

              {/* Annotation */}
              <div style={{
                position: 'absolute', bottom: 50, right: 8,
                fontSize: 9, color: 'rgba(255,149,0,0.8)', fontWeight: 600,
              }}>
                sharp boundary
              </div>
            </div>
          </Preview>
        </div>

        <SpecTable headers={scrollEdgeHeaders} rows={scrollEdgeRows} />
      </Section>

      {/* ═══════════════════════════════════════════════════════
          4 — Depth Cues
          ═══════════════════════════════════════════════════════ */}
      <Section
        title="Depth Cues"
        description="Four visual signals communicate elevation: shadow, blur, specular highlights, and background dimming."
      >
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: 16, marginBottom: 16 }}>
          {/* Shadow */}
          <Preview gradient style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
            <span style={{ font: 'var(--text-headline)', color: 'rgba(255,255,255,0.9)' }}>Shadow</span>
            <div style={{ display: 'flex', gap: 20, alignItems: 'flex-end' }}>
              <div style={{ textAlign: 'center' }}>
                <div style={{
                  width: 80, height: 60, borderRadius: 'var(--r-md)',
                  background: 'rgba(255,255,255,0.15)',
                  boxShadow: '0 0 0 0.5px rgba(0,0,0,0.04), 0 2px 8px rgba(0,0,0,0.04), 0 8px 24px rgba(0,0,0,0.06)',
                }} />
                <div style={{ ...mono, color: 'rgba(255,255,255,0.45)', marginTop: 6, fontSize: 10 }}>--glass-shadow</div>
              </div>
              <div style={{ textAlign: 'center' }}>
                <div style={{
                  width: 80, height: 60, borderRadius: 'var(--r-md)',
                  background: 'rgba(255,255,255,0.15)',
                  boxShadow: '0 0 0 0.5px rgba(0,0,0,0.03), 0 4px 16px rgba(0,0,0,0.06), 0 16px 48px rgba(0,0,0,0.08)',
                }} />
                <div style={{ ...mono, color: 'rgba(255,255,255,0.45)', marginTop: 6, fontSize: 10 }}>--glass-shadow-lg</div>
              </div>
            </div>
          </Preview>

          {/* Blur */}
          <Preview gradient style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
            <span style={{ font: 'var(--text-headline)', color: 'rgba(255,255,255,0.9)' }}>Blur Amount</span>
            <div style={{ display: 'flex', gap: 12, alignItems: 'flex-end' }}>
              {[
                { label: 'Thin', blur: 16, size: '--blur-sm' },
                { label: 'Regular', blur: 48, size: '--blur-lg' },
                { label: 'Thick', blur: 72, size: '--blur-xl' },
              ].map((b) => (
                <div key={b.label} style={{ textAlign: 'center' }}>
                  <div style={{
                    width: 60, height: 50, borderRadius: 'var(--r-sm)',
                    background: 'rgba(255,255,255,0.12)',
                    backdropFilter: `blur(${b.blur}px)`,
                    WebkitBackdropFilter: `blur(${b.blur}px)`,
                    border: '0.5px solid rgba(255,255,255,0.1)',
                  }} />
                  <div style={{ fontSize: 10, color: 'rgba(255,255,255,0.7)', marginTop: 6, fontWeight: 600 }}>{b.label}</div>
                  <div style={{ ...mono, color: 'rgba(255,255,255,0.4)', fontSize: 9 }}>{b.blur}px</div>
                </div>
              ))}
            </div>
          </Preview>

          {/* Specular */}
          <Preview gradient style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
            <span style={{ font: 'var(--text-headline)', color: 'rgba(255,255,255,0.9)' }}>Specular Highlight</span>
            <div style={{ display: 'flex', gap: 20 }}>
              <div style={{ textAlign: 'center' }}>
                <div style={{
                  width: 80, height: 60, borderRadius: 'var(--r-md)',
                  background: 'rgba(255,255,255,0.12)',
                  border: '0.5px solid rgba(255,255,255,0.08)',
                }} />
                <div style={{ fontSize: 10, color: 'rgba(255,255,255,0.5)', marginTop: 6 }}>Without</div>
              </div>
              <div style={{ textAlign: 'center' }}>
                <div style={{
                  width: 80, height: 60, borderRadius: 'var(--r-md)',
                  background: 'rgba(255,255,255,0.12)',
                  border: '0.5px solid rgba(255,255,255,0.08)',
                  boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.55), inset 0 0 0 0.5px rgba(255,255,255,0.25)',
                }} />
                <div style={{ fontSize: 10, color: 'rgba(255,255,255,0.5)', marginTop: 6 }}>With specular</div>
              </div>
            </div>
            <div style={{ ...mono, color: 'rgba(255,255,255,0.35)', fontSize: 10, textAlign: 'center' }}>
              Bright top edge simulates<br />light reflecting off glass
            </div>
          </Preview>

          {/* Background dimming */}
          <Preview gradient style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
            <span style={{ font: 'var(--text-headline)', color: 'rgba(255,255,255,0.9)' }}>Background Dimming</span>
            <div style={{ display: 'flex', gap: 16 }}>
              <div style={{ textAlign: 'center' }}>
                <div style={{
                  width: 70, height: 90, borderRadius: 'var(--r-sm)',
                  background: 'rgba(0,0,0,0.3)',
                  position: 'relative', overflow: 'hidden',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <div style={{
                    width: 50, height: 36, borderRadius: 'var(--r-xs)',
                    background: 'rgba(255,255,255,0.2)',
                    border: '0.5px solid rgba(255,255,255,0.15)',
                  }} />
                </div>
                <div style={{ fontSize: 10, color: 'rgba(255,255,255,0.5)', marginTop: 6 }}>Sheet (30%)</div>
              </div>
              <div style={{ textAlign: 'center' }}>
                <div style={{
                  width: 70, height: 90, borderRadius: 'var(--r-sm)',
                  background: 'rgba(0,0,0,0.4)',
                  position: 'relative', overflow: 'hidden',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <div style={{
                    width: 50, height: 36, borderRadius: 'var(--r-xs)',
                    background: 'rgba(255,255,255,0.2)',
                    border: '0.5px solid rgba(255,255,255,0.15)',
                    boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.3)',
                  }} />
                </div>
                <div style={{ fontSize: 10, color: 'rgba(255,255,255,0.5)', marginTop: 6 }}>Modal (40%)</div>
              </div>
            </div>
          </Preview>
        </div>

        <SpecTable headers={depthBlurHeaders} rows={depthBlurRows} />
      </Section>

      {/* ═══════════════════════════════════════════════════════
          5 — Glass Hierarchy
          ═══════════════════════════════════════════════════════ */}
      <Section
        title="Glass Hierarchy"
        description="When multiple glass surfaces stack, each layer uses a different thickness, blur, and specular intensity to maintain visual separation."
      >
        <Preview gradient style={{ display: 'flex', justifyContent: 'center', padding: 40 }}>
          <div style={{ position: 'relative', width: 360, height: 320 }}>
            {/* Background glass — sidebar */}
            <GlassPanel
              variant="thick"
              style={{
                position: 'absolute',
                left: 0, top: 0,
                width: 130, height: 300,
                background: 'rgba(255,255,255,0.14)',
                backdropFilter: 'blur(72px) saturate(180%)',
                WebkitBackdropFilter: 'blur(72px) saturate(180%)',
                border: '0.5px solid rgba(255,255,255,0.12)',
                boxShadow: 'var(--glass-shadow), inset 0 1px 0 rgba(255,255,255,0.08)',
                borderRadius: 'var(--r-lg)',
                padding: 12,
                zIndex: 1,
              }}
            >
              <div style={{ font: 'var(--text-caption1)', fontWeight: 700, color: 'rgba(255,255,255,0.85)', marginBottom: 8 }}>
                Sidebar
              </div>
              <div style={{ ...mono, fontSize: 9, color: 'rgba(255,255,255,0.4)', lineHeight: '16px' }}>
                --glass-bg-thick<br />
                --blur-xl (72px)<br />
                opacity: 0.62
              </div>
              {/* Fake sidebar items */}
              <div style={{ marginTop: 16, display: 'flex', flexDirection: 'column', gap: 6 }}>
                {Array.from({ length: 5 }).map((_, i) => (
                  <div key={i} style={{
                    height: 8, borderRadius: 3,
                    width: `${60 + (i % 3) * 15}%`,
                    background: i === 0 ? 'rgba(0,122,255,0.3)' : 'rgba(255,255,255,0.06)',
                  }} />
                ))}
              </div>
            </GlassPanel>

            {/* Mid-level glass — toolbar */}
            <GlassPanel
              style={{
                position: 'absolute',
                left: 120, top: 0, right: 0,
                height: 48,
                background: 'rgba(255,255,255,0.1)',
                backdropFilter: 'blur(48px) saturate(180%)',
                WebkitBackdropFilter: 'blur(48px) saturate(180%)',
                border: '0.5px solid rgba(255,255,255,0.1)',
                boxShadow: 'var(--glass-shadow), inset 0 1px 0 rgba(255,255,255,0.12)',
                borderRadius: 'var(--r-md)',
                padding: '8px 14px',
                display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                zIndex: 2,
              }}
            >
              <div style={{ font: 'var(--text-caption1)', fontWeight: 700, color: 'rgba(255,255,255,0.85)' }}>
                Toolbar
              </div>
              <div style={{ ...mono, fontSize: 9, color: 'rgba(255,255,255,0.4)' }}>
                --glass-bg &middot; --blur-lg (48px)
              </div>
            </GlassPanel>

            {/* Foreground glass — popover */}
            <GlassPanel
              variant="thin"
              style={{
                position: 'absolute',
                right: 10, top: 56,
                width: 160, height: 120,
                background: 'rgba(255,255,255,0.08)',
                backdropFilter: 'blur(32px) saturate(180%)',
                WebkitBackdropFilter: 'blur(32px) saturate(180%)',
                border: '0.5px solid rgba(255,255,255,0.1)',
                boxShadow: 'var(--glass-shadow-lg), inset 0 1px 0 rgba(255,255,255,0.15)',
                borderRadius: 'var(--r-md)',
                padding: 12,
                zIndex: 3,
              }}
            >
              <div style={{ font: 'var(--text-caption1)', fontWeight: 700, color: 'rgba(255,255,255,0.85)', marginBottom: 4 }}>
                Popover
              </div>
              <div style={{ ...mono, fontSize: 9, color: 'rgba(255,255,255,0.4)', lineHeight: '14px' }}>
                --glass-bg-thin<br />
                --blur-md (32px)
              </div>
              {/* Fake menu items */}
              <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 4 }}>
                {Array.from({ length: 3 }).map((_, i) => (
                  <div key={i} style={{
                    height: 6, borderRadius: 2,
                    width: `${70 + i * 10}%`,
                    background: 'rgba(255,255,255,0.08)',
                  }} />
                ))}
              </div>
            </GlassPanel>

            {/* Alert glass — modal */}
            <GlassPanel
              variant="thick"
              style={{
                position: 'absolute',
                left: '50%', top: '50%',
                transform: 'translate(-50%, -50%)',
                width: 200, height: 130,
                background: 'rgba(255,255,255,0.16)',
                backdropFilter: 'blur(72px) saturate(200%)',
                WebkitBackdropFilter: 'blur(72px) saturate(200%)',
                border: '0.5px solid rgba(255,255,255,0.15)',
                boxShadow: '0 0 0 0.5px rgba(0,0,0,0.03), 0 4px 16px rgba(0,0,0,0.06), 0 16px 48px rgba(0,0,0,0.08), inset 0 1px 0 rgba(255,255,255,0.55), inset 0 0 0 0.5px rgba(255,255,255,0.25)',
                borderRadius: 'var(--r-lg)',
                padding: 16,
                zIndex: 4,
                display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
              }}
            >
              <div>
                <div style={{ font: 'var(--text-caption1)', fontWeight: 700, color: 'rgba(255,255,255,0.9)', marginBottom: 4 }}>
                  Alert / Modal
                </div>
                <div style={{ ...mono, fontSize: 9, color: 'rgba(255,255,255,0.45)', lineHeight: '14px' }}>
                  --glass-bg-thick<br />
                  --blur-xl (72px)<br />
                  highest specular
                </div>
              </div>
              <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end' }}>
                <div style={{
                  padding: '4px 14px', borderRadius: 'var(--r-xs)',
                  background: 'rgba(255,255,255,0.1)', fontSize: 10, color: 'rgba(255,255,255,0.6)',
                }}>Cancel</div>
                <div style={{
                  padding: '4px 14px', borderRadius: 'var(--r-xs)',
                  background: 'rgba(0,122,255,0.6)', fontSize: 10, color: '#fff', fontWeight: 600,
                }}>OK</div>
              </div>
            </GlassPanel>
          </div>
        </Preview>

        <SpecTable
          headers={['Layer', 'Material', 'Blur', 'Specular', 'Example']}
          rows={[
            ['Background', '--glass-bg-thick', '72px (--blur-xl)', 'Subtle', 'Sidebars, persistent panels'],
            ['Mid-level', '--glass-bg', '48px (--blur-lg)', 'Standard', 'Toolbars, tab bars, nav bars'],
            ['Foreground', '--glass-bg-thin', '32px (--blur-md)', 'Moderate', 'Popovers, menus, tooltips'],
            ['Alert', '--glass-bg-thick', '72px (--blur-xl)', 'Highest', 'Modal dialogs, confirmation alerts'],
          ]}
        />
      </Section>
    </div>
  )
}
