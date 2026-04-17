import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

export default function MapsLocation() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Maps &amp; Location</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Embedded maps, location permissions, accuracy levels, and turn-by-turn direction patterns with Liquid Glass overlays.
      </p>

      {/* ── Embedded Map ── */}
      <Section title="Embedded Map" description="Map view with a glass overlay card and annotation pin. The bottom card shows place details and a Directions action.">
        <Preview gradient style={{ padding: 0, position: 'relative', height: 360, overflow: 'hidden' }}>
          {/* Mock map tiles */}
          <div style={{
            position: 'absolute', inset: 0,
            background: 'linear-gradient(145deg, #d4cfc4 0%, #c8c2b6 20%, #d9d3c7 40%, #ccc6ba 60%, #ddd7cb 80%, #c5bfb3 100%)',
          }}>
            {/* Grid lines to simulate streets */}
            <div style={{ position: 'absolute', inset: 0, opacity: 0.15 }}>
              {[60, 130, 200, 270].map((y) => (
                <div key={`h${y}`} style={{ position: 'absolute', top: y, left: 0, right: 0, height: 1, background: '#888' }} />
              ))}
              {[80, 160, 240, 320].map((x) => (
                <div key={`v${x}`} style={{ position: 'absolute', left: x, top: 0, bottom: 0, width: 1, background: '#888' }} />
              ))}
            </div>
            {/* Map annotation pin */}
            <div style={{
              position: 'absolute', top: '35%', left: '55%', transform: 'translate(-50%, -100%)',
            }}>
              <div style={{
                width: 32, height: 32, borderRadius: '50%',
                background: 'var(--blue)',
                border: '3px solid #fff',
                boxShadow: '0 2px 8px rgba(0,0,0,0.3)',
              }} />
              <div style={{
                width: 0, height: 0, margin: '-2px auto 0',
                borderLeft: '6px solid transparent',
                borderRight: '6px solid transparent',
                borderTop: '8px solid #fff',
              }} />
            </div>
          </div>

          {/* Bottom glass card */}
          <div style={{
            position: 'absolute', bottom: 12, left: 12, right: 12,
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
            WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
            border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-xl)',
            boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
            padding: '14px 18px',
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          }}>
            <div>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>Coffee Shop</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>0.3 mi away</div>
            </div>
            <GlassButton variant="filled" size="sm">Directions</GlassButton>
          </div>
        </Preview>
      </Section>

      {/* ── Location Permission ── */}
      <Section title="Location Permission" description="Three-step permission flow: explain context, present the system prompt, and confirm the result.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: 16 }}>
          {/* Step 1 */}
          <GlassCard>
            <div style={{
              width: 32, height: 32, borderRadius: '50%', marginBottom: 12,
              background: 'var(--blue)', display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <span style={{ color: '#fff', fontWeight: 700, fontSize: 16 }}>1</span>
            </div>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Pre-permission</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Explain why the app needs location access before triggering the system prompt. Provide context and value.
            </div>
          </GlassCard>

          {/* Step 2 */}
          <GlassCard>
            <div style={{
              width: 32, height: 32, borderRadius: '50%', marginBottom: 12,
              background: 'var(--blue)', display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <span style={{ color: '#fff', fontWeight: 700, fontSize: 16 }}>2</span>
            </div>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>System Prompt</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 10 }}>
              iOS presents the standard permission dialog with three options:
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
              {['Allow While Using', 'Allow Once', "Don't Allow"].map((opt) => (
                <div key={opt} style={{
                  padding: '6px 10px', borderRadius: 'var(--r-xs)',
                  background: 'var(--fill-tertiary)',
                  font: 'var(--text-caption1)', color: 'var(--blue)', fontWeight: 500,
                }}>{opt}</div>
              ))}
            </div>
          </GlassCard>

          {/* Step 3 */}
          <GlassCard>
            <div style={{
              width: 32, height: 32, borderRadius: '50%', marginBottom: 12,
              background: 'var(--green)', display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <span style={{ color: '#fff', fontWeight: 700, fontSize: 16 }}>3</span>
            </div>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Confirmation</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 10 }}>
              Show in-app feedback confirming the permission status.
            </div>
            <div style={{
              padding: '8px 12px', borderRadius: 'var(--r-sm)',
              background: 'rgba(52,199,89,0.12)',
              border: '0.5px solid rgba(52,199,89,0.25)',
              font: 'var(--text-caption1)', color: 'var(--green)', fontWeight: 500,
            }}>
              Location enabled &#10003;
            </div>
          </GlassCard>
        </div>
      </Section>

      {/* ── Accuracy Levels ── */}
      <Section title="Accuracy Levels" description="Precise vs approximate location accuracy, showing the difference in radius circles on a map.">
        <Preview gradient>
          <div style={{ display: 'flex', justifyContent: 'center', gap: 40, flexWrap: 'wrap' }}>
            {/* Precise */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 1 }}>Precise</span>
              <div style={{
                width: 160, height: 160, borderRadius: 'var(--r-lg)',
                background: 'linear-gradient(145deg, #d4cfc4, #ccc6ba)',
                position: 'relative', overflow: 'hidden',
              }}>
                {/* Small accuracy circle */}
                <div style={{
                  position: 'absolute', top: '50%', left: '50%',
                  transform: 'translate(-50%, -50%)',
                  width: 30, height: 30, borderRadius: '50%',
                  background: 'rgba(0,122,255,0.15)',
                  border: '1px solid rgba(0,122,255,0.3)',
                }} />
                {/* Blue dot */}
                <div style={{
                  position: 'absolute', top: '50%', left: '50%',
                  transform: 'translate(-50%, -50%)',
                  width: 12, height: 12, borderRadius: '50%',
                  background: 'var(--blue)',
                  border: '2px solid #fff',
                  boxShadow: '0 1px 4px rgba(0,0,0,0.2)',
                }} />
              </div>
              <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.4)' }}>~10m radius</span>
            </div>

            {/* Approximate */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 1 }}>Approximate</span>
              <div style={{
                width: 160, height: 160, borderRadius: 'var(--r-lg)',
                background: 'linear-gradient(145deg, #d4cfc4, #ccc6ba)',
                position: 'relative', overflow: 'hidden',
              }}>
                {/* Large accuracy circle */}
                <div style={{
                  position: 'absolute', top: '50%', left: '50%',
                  transform: 'translate(-50%, -50%)',
                  width: 120, height: 120, borderRadius: '50%',
                  background: 'rgba(0,122,255,0.15)',
                  border: '1px solid rgba(0,122,255,0.3)',
                }} />
                {/* Blue dot */}
                <div style={{
                  position: 'absolute', top: '50%', left: '50%',
                  transform: 'translate(-50%, -50%)',
                  width: 12, height: 12, borderRadius: '50%',
                  background: 'var(--blue)',
                  border: '2px solid #fff',
                  boxShadow: '0 1px 4px rgba(0,0,0,0.2)',
                }} />
              </div>
              <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.4)' }}>~5km radius</span>
            </div>
          </div>
        </Preview>

        <SpecTable
          headers={['Accuracy', 'Radius', 'Use Case']}
          rows={[
            ['Precise', '~10 m', 'Navigation, ride sharing, local search'],
            ['Approximate', '~5 km', 'Weather, regional content, news'],
          ]}
        />
      </Section>

      {/* ── Directions ── */}
      <Section title="Directions" description="Turn-by-turn navigation card with route information overlay.">
        <Preview gradient style={{ padding: 32 }}>
          <div style={{
            maxWidth: 380, margin: '0 auto',
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
            WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
            border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-xl)',
            boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
            overflow: 'hidden',
          }}>
            {/* Current step */}
            <div style={{ padding: '16px 20px', display: 'flex', alignItems: 'center', gap: 14 }}>
              <div style={{
                width: 44, height: 44, borderRadius: 'var(--r-md)', flexShrink: 0,
                background: 'var(--green)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <span style={{ color: '#fff', fontSize: 20, fontWeight: 700 }}>&#8599;</span>
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>Turn right on Main St</div>
                <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>0.2 mi</div>
              </div>
            </div>

            {/* Route overview */}
            <div style={{
              padding: '12px 20px',
              background: 'var(--fill-tertiary)',
              borderTop: '0.5px solid var(--separator)',
            }}>
              {/* Route strip */}
              <div style={{ height: 4, background: 'var(--fill)', borderRadius: 2, marginBottom: 8, position: 'relative' }}>
                <div style={{ width: '20%', height: '100%', background: 'var(--green)', borderRadius: 2 }} />
                <div style={{
                  position: 'absolute', left: '20%', top: -3,
                  width: 10, height: 10, borderRadius: '50%',
                  background: 'var(--blue)', border: '2px solid #fff',
                  boxShadow: '0 1px 4px rgba(0,0,0,0.2)',
                }} />
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>ETA 3 min</span>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>1.2 mi remaining</span>
              </div>
            </div>

            {/* Next steps */}
            <div style={{ padding: '12px 20px' }}>
              {[
                { dir: 'Continue straight', dist: '0.5 mi' },
                { dir: 'Turn left on Oak Ave', dist: '0.3 mi' },
                { dir: 'Arrive at destination', dist: '' },
              ].map((step, i, arr) => (
                <div key={i} style={{
                  padding: '8px 0',
                  borderBottom: i < arr.length - 1 ? '0.5px solid var(--separator)' : 'none',
                  display: 'flex', justifyContent: 'space-between',
                }}>
                  <span style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>{step.dir}</span>
                  {step.dist && <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>{step.dist}</span>}
                </div>
              ))}
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs" description="Key dimensions for map and location components.">
        <SpecTable
          headers={['Element', 'Value']}
          rows={[
            ['Map pin size', '44 x 44 pt'],
            ['Accuracy circle opacity', '0.15'],
            ['Bottom card max height', '200 px'],
          ]}
        />
      </Section>
    </div>
  )
}
