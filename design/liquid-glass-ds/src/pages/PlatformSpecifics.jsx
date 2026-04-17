import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

export default function PlatformSpecifics() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Platform Specifics</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Design considerations for watchOS, tvOS, visionOS, and CarPlay, including input models, sizing, and glass usage.
      </p>

      {/* ── watchOS ── */}
      <Section title="watchOS" description="Designing for the wrist: Digital Crown interaction, complications, and glanceable sessions.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          <GlassCard>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
              {/* Crown icon */}
              <div style={{
                width: 36, height: 36, borderRadius: '50%',
                background: 'var(--fill)',
                border: '2px solid var(--label-tertiary)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                position: 'relative',
              }}>
                <div style={{ width: 4, height: 14, borderRadius: 2, background: 'var(--label-secondary)' }} />
                {/* Notches */}
                <div style={{ position: 'absolute', right: -4, top: 8, width: 6, height: 2, borderRadius: 1, background: 'var(--label-tertiary)' }} />
                <div style={{ position: 'absolute', right: -4, top: 14, width: 6, height: 2, borderRadius: 1, background: 'var(--label-tertiary)' }} />
                <div style={{ position: 'absolute', right: -4, top: 20, width: 6, height: 2, borderRadius: 1, background: 'var(--label-tertiary)' }} />
              </div>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>Digital Crown</div>
            </div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Scroll through content, zoom into maps and photos, and select items. Provides haptic detents at each position for tactile feedback.
            </div>
          </GlassCard>

          <GlassCard>
            <div style={{ display: 'flex', gap: 8, marginBottom: 10 }}>
              {/* Mock complications */}
              <div style={{
                width: 48, height: 48, borderRadius: '50%',
                background: 'var(--fill)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <span style={{ fontSize: 20, fontWeight: 700, color: 'var(--blue)' }}>72</span>
              </div>
              <div style={{
                width: 80, height: 48, borderRadius: 'var(--r-sm)',
                background: 'var(--fill)',
                display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
              }}>
                <div style={{ width: 8, height: 8, borderRadius: '50%', background: 'var(--red)' }} />
                <span style={{ font: 'var(--text-caption1)', color: 'var(--label)' }}>420</span>
              </div>
            </div>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Complications</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Circular (48x48) and modular small/large formats. Show a single metric or compact data visualization on the watch face.
            </div>
          </GlassCard>

          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Glanceable Design</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Sessions under 5 seconds. Use large text, bold colors, and minimal content hierarchy. Every pixel matters on the small display.
            </div>
          </GlassCard>
        </div>
      </Section>

      {/* ── tvOS ── */}
      <Section title="tvOS" description="10-foot UI design with focus-based navigation and remote control interaction.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16, marginBottom: 24 }}>
          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Focus Engine</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 12 }}>
              Items scale up with shadow when focused. The focused element lifts to indicate selection.
            </div>
            {/* Mock card row */}
            <div style={{ display: 'flex', gap: 8 }}>
              {[0, 1, 2].map((i) => (
                <div key={i} style={{
                  width: 72, height: 48, borderRadius: 'var(--r-sm)',
                  background: i === 1 ? 'var(--glass-bg)' : 'var(--fill-tertiary)',
                  border: i === 1 ? '1.5px solid var(--blue)' : '0.5px solid var(--separator)',
                  transform: i === 1 ? 'scale(1.05)' : 'scale(1)',
                  boxShadow: i === 1 ? '0 4px 16px rgba(0,0,0,0.15)' : 'none',
                  transition: 'all var(--dur) var(--ease)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <span style={{ font: 'var(--text-caption2)', color: i === 1 ? 'var(--blue)' : 'var(--label-tertiary)' }}>
                    {i === 1 ? 'Focused' : ''}
                  </span>
                </div>
              ))}
            </div>
          </GlassCard>

          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Remote Interaction</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Swipe the trackpad to navigate focus, click to select, and use the Siri button for voice commands. No direct touch on screen.
            </div>
          </GlassCard>

          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>10-Foot UI</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Minimum text size 29pt, high contrast for readability at distance. Respect overscan safe areas to avoid clipping on TV edges.
            </div>
          </GlassCard>
        </div>
      </Section>

      {/* ── visionOS ── */}
      <Section title="visionOS" description="Spatial computing with eye tracking, hand gestures, windows floating in 3D space, and volumetric content.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Spatial Glass</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 12 }}>
              Windows float in 3D space with depth and glass materials that react to the surrounding environment.
            </div>
            {/* Mock floating window */}
            <div style={{ perspective: 600, display: 'flex', justifyContent: 'center' }}>
              <div style={{
                width: 180, height: 100,
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-md))',
                WebkitBackdropFilter: 'blur(var(--blur-md))',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-lg)',
                boxShadow: 'var(--glass-shadow-lg)',
                transform: 'rotateY(-8deg) rotateX(4deg)',
                padding: 12,
                display: 'flex', flexDirection: 'column', gap: 4,
              }}>
                <div style={{ height: 6, width: '60%', borderRadius: 3, background: 'var(--fill)' }} />
                <div style={{ height: 6, width: '80%', borderRadius: 3, background: 'var(--fill-secondary)' }} />
                <div style={{ height: 6, width: '45%', borderRadius: 3, background: 'var(--fill-tertiary)' }} />
              </div>
            </div>
          </GlassCard>

          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Eye + Hand Tracking</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Gaze at an element to highlight it, then pinch to select. Indirect interaction feels natural and keeps hands relaxed at your sides.
            </div>
          </GlassCard>

          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Ornaments</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Floating toolbars and controls that anchor to the bottom edge of windows. They sit slightly in front of the window surface for depth.
            </div>
          </GlassCard>

          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Volumes</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              3D content containers for showing models and immersive objects. Volumes have a fixed size and position relative to the user.
            </div>
          </GlassCard>
        </div>
      </Section>

      {/* ── CarPlay ── */}
      <Section title="CarPlay" description="Automotive interface with large touch targets, minimal text, and template-based layouts.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Dashboard</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Glanceable information with large touch targets for safe interaction while driving. Minimal cognitive load, maximum clarity.
            </div>
          </GlassCard>

          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Templates</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 10 }}>
              CarPlay provides standardized layouts:
            </div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
              {['List', 'Grid', 'Now Playing', 'Map'].map((t) => (
                <span key={t} style={{
                  padding: '4px 10px', borderRadius: 'var(--r-pill)',
                  background: 'var(--fill)',
                  font: 'var(--text-caption1)', color: 'var(--label-secondary)',
                }}>{t}</span>
              ))}
            </div>
          </GlassCard>

          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Constraints</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Maximum 5 list items visible at once. Minimize text, avoid scrolling content, and ensure all interactions are single-tap.
            </div>
          </GlassCard>
        </div>
      </Section>

      {/* ── Platform Comparison ── */}
      <Section title="Platform Comparison" description="Key design differences across Apple platforms.">
        <SpecTable
          headers={['Property', 'iOS', 'macOS', 'watchOS', 'tvOS', 'visionOS']}
          rows={[
            ['Input', 'Touch', 'Mouse + KB', 'Crown + Touch', 'Remote', 'Eyes + Hands'],
            ['Min tap target', '44 pt', '28 pt', '38 pt', '66 pt', '60 pt'],
            ['Default font', '17 pt', '13 pt', '16 pt (Body)', '29 pt', '17 pt'],
            ['Glass usage', 'Heavy', 'Medium', 'Light', 'Medium', 'Heavy'],
          ]}
        />
      </Section>
    </div>
  )
}
