import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

export default function LiveActivities() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Live Activities</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Dynamic Island presentations, Lock Screen banners, and StandBy layouts for real-time activity tracking.
      </p>

      {/* ── Dynamic Island ── */}
      <Section title="Dynamic Island" description="Three presentation states for the Dynamic Island: compact, expanded, and minimal.">
        <Preview gradient style={{ padding: 32 }}>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 32 }}>
            {/* Compact */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.4)', textTransform: 'uppercase', letterSpacing: 1 }}>Compact</span>
              <div style={{
                width: 220, height: 37,
                background: '#000',
                borderRadius: 'var(--r-pill)',
                display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                padding: '0 12px 0 14px',
                boxShadow: '0 2px 12px rgba(0,0,0,0.4)',
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <div style={{ width: 16, height: 16, borderRadius: 4, background: 'var(--red)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <span style={{ color: '#fff', fontSize: 8, fontWeight: 700 }}>&#9654;</span>
                  </div>
                  <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.9)', fontWeight: 500 }}>Now Playing</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                  <span style={{ font: 'var(--text-caption2)', color: 'var(--blue)', fontWeight: 600, fontVariantNumeric: 'tabular-nums' }}>2:34</span>
                  {/* Waveform indicator */}
                  <div style={{ display: 'flex', gap: 1, alignItems: 'flex-end', height: 12 }}>
                    {[6, 10, 4, 8, 5].map((h, i) => (
                      <div key={i} style={{ width: 2, height: h, background: 'var(--blue)', borderRadius: 1 }} />
                    ))}
                  </div>
                </div>
              </div>
            </div>

            {/* Expanded */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.4)', textTransform: 'uppercase', letterSpacing: 1 }}>Expanded</span>
              <div style={{
                width: 340, maxWidth: '100%',
                background: '#000',
                borderRadius: 'var(--r-2xl)',
                padding: 16,
                boxShadow: '0 4px 24px rgba(0,0,0,0.5)',
              }}>
                <div style={{ display: 'flex', gap: 14, marginBottom: 14 }}>
                  {/* Album art */}
                  <div style={{
                    width: 56, height: 56, borderRadius: 'var(--r-sm)', flexShrink: 0,
                    background: 'linear-gradient(135deg, var(--indigo), var(--purple))',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                  }}>
                    <span style={{ fontSize: 24 }}>&#9835;</span>
                  </div>
                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
                    <span style={{ font: 'var(--text-subhead)', fontWeight: 600, color: '#fff' }}>Glass Houses</span>
                    <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)' }}>Billy Joel</span>
                  </div>
                </div>
                {/* Progress bar */}
                <div style={{ height: 4, background: 'rgba(255,255,255,0.15)', borderRadius: 2, marginBottom: 8 }}>
                  <div style={{ width: '45%', height: '100%', background: '#fff', borderRadius: 2 }} />
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 12 }}>
                  <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.4)', fontVariantNumeric: 'tabular-nums' }}>2:34</span>
                  <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.4)', fontVariantNumeric: 'tabular-nums' }}>-3:12</span>
                </div>
                {/* Transport controls */}
                <div style={{ display: 'flex', justifyContent: 'center', gap: 24, alignItems: 'center' }}>
                  {['&#9198;', '&#9654;', '&#9197;'].map((icon, i) => (
                    <div key={i} style={{
                      width: i === 1 ? 40 : 32, height: i === 1 ? 40 : 32,
                      borderRadius: '50%',
                      background: i === 1 ? 'rgba(255,255,255,0.9)' : 'transparent',
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      cursor: 'pointer',
                    }}>
                      <span style={{ color: i === 1 ? '#000' : 'rgba(255,255,255,0.8)', fontSize: i === 1 ? 18 : 16 }}
                        dangerouslySetInnerHTML={{ __html: icon }} />
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Minimal */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.4)', textTransform: 'uppercase', letterSpacing: 1 }}>Minimal</span>
              <div style={{
                width: 37, height: 37,
                background: '#000',
                borderRadius: '50%',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                boxShadow: '0 2px 12px rgba(0,0,0,0.4)',
              }}>
                <div style={{
                  width: 12, height: 12, borderRadius: '50%',
                  background: 'conic-gradient(var(--blue) 0% 45%, rgba(255,255,255,0.15) 45% 100%)',
                }} />
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Lock Screen ── */}
      <Section title="Lock Screen" description="Live Activity banner displayed below the clock on the Lock Screen, with compact and expanded views.">
        <Preview gradient style={{ padding: 24 }}>
          <div style={{ maxWidth: 380, margin: '0 auto' }}>
            {/* Mock clock */}
            <div style={{ textAlign: 'center', marginBottom: 20 }}>
              <span style={{ fontSize: 48, fontWeight: 700, color: 'rgba(255,255,255,0.9)', letterSpacing: -1, fontVariantNumeric: 'tabular-nums' }}>9:41</span>
            </div>

            {/* Live Activity banner */}
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
              WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
              padding: 16,
              marginBottom: 16,
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
                <div style={{
                  width: 32, height: 32, borderRadius: 'var(--r-xs)',
                  background: 'var(--orange)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <span style={{ color: '#fff', fontSize: 16, fontWeight: 700 }}>D</span>
                </div>
                <div style={{ flex: 1 }}>
                  <span style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>Delivery on the way</span>
                </div>
                <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>12 min</span>
              </div>
              {/* Progress bar */}
              <div style={{ height: 4, background: 'var(--fill)', borderRadius: 2, marginBottom: 8 }}>
                <div style={{ width: '65%', height: '100%', background: 'var(--orange)', borderRadius: 2 }} />
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ font: 'var(--text-caption2)', color: 'var(--label-secondary)' }}>Out for delivery</span>
                <span style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>ETA 10:05 AM</span>
              </div>
            </div>

            {/* Expanded view */}
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
              WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
              padding: 16,
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 14 }}>
                <div style={{
                  width: 32, height: 32, borderRadius: 'var(--r-xs)',
                  background: 'var(--orange)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <span style={{ color: '#fff', fontSize: 16, fontWeight: 700 }}>D</span>
                </div>
                <div style={{ flex: 1 }}>
                  <span style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>Your order is almost here</span>
                  <div style={{ font: 'var(--text-caption2)', color: 'var(--label-secondary)' }}>Driver: Alex M. &mdash; 0.3 mi away</div>
                </div>
              </div>
              <div style={{ height: 4, background: 'var(--fill)', borderRadius: 2, marginBottom: 12 }}>
                <div style={{ width: '85%', height: '100%', background: 'var(--orange)', borderRadius: 2 }} />
              </div>
              <div style={{ display: 'flex', gap: 8 }}>
                <GlassButton size="sm" style={{ flex: 1 }}>Contact Driver</GlassButton>
                <GlassButton variant="tinted" size="sm" style={{ flex: 1 }}>View Details</GlassButton>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── StandBy ── */}
      <Section title="StandBy" description="Full-screen Live Activity display in landscape orientation for at-a-glance monitoring.">
        <Preview gradient>
          <div style={{
            width: '100%', maxWidth: 500, height: 200, margin: '0 auto',
            background: 'rgba(0,0,0,0.6)',
            borderRadius: 'var(--r-xl)',
            border: '1px solid rgba(255,255,255,0.08)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            padding: 32, gap: 40,
          }}>
            {/* Score display */}
            <div style={{ textAlign: 'center' }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.4)', textTransform: 'uppercase', letterSpacing: 1 }}>Home</span>
              <div style={{ fontSize: 56, fontWeight: 700, color: 'rgba(255,255,255,0.9)', lineHeight: 1 }}>24</div>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
              <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.3)', textTransform: 'uppercase', letterSpacing: 1 }}>Q3 &bull; 4:32</span>
              <div style={{ width: 2, height: 40, background: 'rgba(255,255,255,0.1)' }} />
            </div>
            <div style={{ textAlign: 'center' }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.4)', textTransform: 'uppercase', letterSpacing: 1 }}>Away</span>
              <div style={{ fontSize: 56, fontWeight: 700, color: 'rgba(255,255,255,0.9)', lineHeight: 1 }}>21</div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Live Activity Timeline ── */}
      <Section title="Live Activity Timeline" description="Lifecycle of a Live Activity from start to end. Maximum duration is 8 hours.">
        <Preview gradient>
          <div style={{ maxWidth: 480, margin: '0 auto', padding: '16px 0' }}>
            {/* Timeline */}
            <div style={{ position: 'relative', paddingLeft: 40 }}>
              {/* Vertical line */}
              <div style={{
                position: 'absolute', left: 15, top: 8, bottom: 8, width: 2,
                background: 'linear-gradient(to bottom, var(--green), var(--blue), var(--blue), var(--red))',
                borderRadius: 1,
              }} />

              {[
                { label: 'Start', desc: 'Activity begins, appears on Dynamic Island & Lock Screen', color: 'var(--green)', time: '0:00' },
                { label: 'Update', desc: 'Remote push notification updates content', color: 'var(--blue)', time: '1:24' },
                { label: 'Update', desc: 'State changes trigger UI refresh', color: 'var(--blue)', time: '3:47' },
                { label: 'End', desc: 'Activity dismissed or expires after 8 hours max', color: 'var(--red)', time: '5:12' },
              ].map((step, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'flex-start', gap: 16, marginBottom: i < 3 ? 28 : 0, position: 'relative' }}>
                  {/* Dot */}
                  <div style={{
                    width: 12, height: 12, borderRadius: '50%',
                    background: step.color,
                    border: '2px solid rgba(0,0,0,0.3)',
                    position: 'absolute', left: -31,
                    boxShadow: `0 0 8px ${step.color}40`,
                  }} />
                  <div style={{ flex: 1 }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
                      <span style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>{step.label}</span>
                      <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.4)', fontVariantNumeric: 'tabular-nums' }}>{step.time}</span>
                    </div>
                    <span style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>{step.desc}</span>
                  </div>
                </div>
              ))}
            </div>

            <div style={{
              marginTop: 24, padding: '10px 14px',
              background: 'rgba(255,149,0,0.12)',
              border: '0.5px solid rgba(255,149,0,0.25)',
              borderRadius: 'var(--r-md)',
            }}>
              <span style={{ font: 'var(--text-caption1)', color: 'var(--orange)' }}>
                Duration limit: Live Activities expire after 8 hours maximum.
              </span>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Guidelines ── */}
      <Section title="Guidelines" description="Best practices for designing effective Live Activities.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          {[
            { title: 'Keep it glanceable', desc: 'Live Activities should communicate status at a glance. Use large text, bold numbers, and clear iconography.' },
            { title: 'Update wisely', desc: 'Limit updates to every few seconds at most. Each push notification update counts toward APNs rate limits.' },
            { title: 'Support all sizes', desc: 'Design for compact, expanded, and minimal Dynamic Island states plus Lock Screen and StandBy presentations.' },
            { title: 'Provide a deep link', desc: 'Tapping a Live Activity should open the app to the relevant content with full context and controls.' },
          ].map((g) => (
            <GlassCard key={g.title}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>{g.title}</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>{g.desc}</div>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs" description="Key dimensions for Live Activity presentations.">
        <SpecTable
          headers={['Element', 'Value']}
          rows={[
            ['Dynamic Island compact height', '37.33 pt'],
            ['Dynamic Island expanded max', '160 pt'],
            ['Lock Screen max height', '160 pt'],
            ['Max duration', '8 hours'],
            ['Update frequency', 'Max every few seconds'],
          ]}
        />
      </Section>
    </div>
  )
}
