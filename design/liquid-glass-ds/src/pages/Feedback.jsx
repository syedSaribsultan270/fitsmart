import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { GlassAlert, GlassProgress, GlassButton, GlassInput, GlassToggle } from '../components/Glass'

export default function Feedback() {
  const [allDay, setAllDay] = useState(false)
  const [banners, setBanners] = useState({ warning: true, error: true, info: true })
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Feedback</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Alerts, sheets, progress indicators, and other feedback components rendered with Liquid Glass materials.
      </p>

      <Section title="Alerts" description="Modal dialogs with glass background and blur. Available in simple, two-button, and destructive variants.">
        <Preview gradient>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 24, justifyContent: 'center' }}>
            <GlassAlert
              title="Update Complete"
              message="Your device has been updated to the latest version."
              actions={[{ label: 'OK', primary: true }]}
            />
            <GlassAlert
              title="Save Changes?"
              message="You have unsaved changes that will be lost."
              actions={[
                { label: 'Discard' },
                { label: 'Save', primary: true },
              ]}
            />
            <GlassAlert
              title="Delete Photo?"
              message="This action cannot be undone."
              actions={[
                { label: 'Cancel' },
                { label: 'Delete', destructive: true },
              ]}
            />
          </div>
        </Preview>
      </Section>

      <Section title="Action Sheet" description="Bottom-anchored glass sheet with a list of actions. Common for share menus and contextual options.">
        <Preview gradient style={{ padding: 0, position: 'relative', height: 360, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
          <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)' }}>Background content</span>
          </div>
          <div style={{ padding: '0 8px 8px' }}>
            <div style={{
              background: 'var(--glass-bg-thick)',
              backdropFilter: 'blur(72px) saturate(200%)',
              WebkitBackdropFilter: 'blur(72px) saturate(200%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
              overflow: 'hidden',
              marginBottom: 8,
            }}>
              {['Share', 'Add to Favorites', 'Copy Link', 'Save to Files'].map((action, i, arr) => (
                <button key={action} style={{
                  display: 'block', width: '100%', padding: '14px 20px', textAlign: 'center',
                  font: 'var(--text-body)', color: 'var(--blue)', background: 'transparent',
                  border: 'none', cursor: 'pointer',
                  borderBottom: i < arr.length - 1 ? '0.5px solid var(--separator)' : 'none',
                }}>{action}</button>
              ))}
            </div>
            <div style={{
              background: 'var(--glass-bg-thick)',
              backdropFilter: 'blur(72px) saturate(200%)',
              WebkitBackdropFilter: 'blur(72px) saturate(200%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
              overflow: 'hidden',
            }}>
              <button style={{
                display: 'block', width: '100%', padding: '14px 20px', textAlign: 'center',
                font: 'var(--text-body)', fontWeight: 600, color: 'var(--blue)',
                background: 'transparent', border: 'none', cursor: 'pointer',
              }}>Cancel</button>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Sheet" description="Modal sheet with glass background, rounded top corners, and a drag indicator for dismissal.">
        <Preview gradient style={{ padding: 0, position: 'relative', height: 380, overflow: 'hidden' }}>
          <div style={{ height: 100, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)' }}>Background content</span>
          </div>
          <div style={{
            position: 'absolute', bottom: 0, left: 0, right: 0, height: 280,
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(72px) saturate(200%)',
            WebkitBackdropFilter: 'blur(72px) saturate(200%)',
            borderTop: '0.5px solid var(--glass-border)',
            borderRadius: '20px 20px 0 0',
            boxShadow: '0 -4px 32px rgba(0,0,0,0.1), var(--glass-specular)',
            display: 'flex', flexDirection: 'column', alignItems: 'center',
          }}>
            <div style={{
              width: 36, height: 5, borderRadius: 3,
              background: 'var(--label-quaternary)', marginTop: 8, marginBottom: 16,
            }} />
            <div style={{ padding: '0 24px', width: '100%' }}>
              <h3 style={{ font: 'var(--text-headline)', marginBottom: 4 }}>Sheet Title</h3>
              <p style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 20 }}>
                Sheets slide up from the bottom and can be dismissed by dragging down.
              </p>
              <GlassButton variant="filled" style={{ width: '100%' }}>Confirm</GlassButton>
              <div style={{ height: 12 }} />
              <GlassButton variant="glass" style={{ width: '100%' }}>Cancel</GlassButton>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Progress" description="Linear progress indicators at various completion values.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16, maxWidth: 400 }}>
            {[0, 25, 50, 75, 100].map((val) => (
              <div key={val}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                  <span style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.7)' }}>{val === 0 ? 'Not started' : val === 100 ? 'Complete' : `${val}% done`}</span>
                  <span style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.5)' }}>{val}%</span>
                </div>
                <GlassProgress value={val} />
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      <Section title="Spinner" description="Animated loading indicator using CSS keyframe rotation.">
        <style>{`@keyframes glass-spin { to { transform: rotate(360deg); } }`}</style>
        <Preview gradient>
          <div style={{ display: 'flex', gap: 32, alignItems: 'center' }}>
            {[20, 28, 40].map((size) => (
              <div key={size} style={{
                width: size, height: size,
                border: `${size > 24 ? 3 : 2.5}px solid rgba(255,255,255,0.2)`,
                borderTopColor: '#fff',
                borderRadius: '50%',
                animation: 'glass-spin 0.8s linear infinite',
              }} />
            ))}
            <div style={{
              width: 28, height: 28,
              border: '2.5px solid rgba(0,122,255,0.2)',
              borderTopColor: 'var(--blue)',
              borderRadius: '50%',
              animation: 'glass-spin 0.8s linear infinite',
            }} />
          </div>
        </Preview>
      </Section>

      <Section title="Page Control" description="Dot indicators showing the current page in a paginated view.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 20, alignItems: 'center' }}>
            {[0, 2, 4].map((active) => (
              <div key={active} style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                {[0, 1, 2, 3, 4].map((dot) => (
                  <div key={dot} style={{
                    width: dot === active ? 10 : 7,
                    height: dot === active ? 10 : 7,
                    borderRadius: '50%',
                    background: dot === active ? 'var(--blue)' : 'rgba(255,255,255,0.35)',
                    transition: 'all var(--dur) var(--ease)',
                  }} />
                ))}
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ── Sheet Detents ── */}
      <Section title="Sheet Detents" description="Sheets can stop at different heights (detents): half, full, or custom. Each detent controls how much content is revealed.">
        <Preview gradient>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: 20 }}>
            {[
              { label: 'Half (50%)', pct: 50 },
              { label: 'Full (90%)', pct: 90 },
              { label: 'Custom (30%)', pct: 30 },
            ].map(({ label, pct }) => (
              <div key={label} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 1 }}>
                  {label}
                </span>
                {/* Phone frame */}
                <div style={{
                  width: '100%',
                  maxWidth: 180,
                  height: 300,
                  borderRadius: 'var(--r-xl)',
                  border: '1.5px solid rgba(255,255,255,0.12)',
                  background: 'rgba(255,255,255,0.03)',
                  position: 'relative',
                  overflow: 'hidden',
                }}>
                  {/* Background label */}
                  <div style={{ position: 'absolute', top: '30%', left: 0, right: 0, textAlign: 'center', font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.2)' }}>
                    App Content
                  </div>
                  {/* Sheet */}
                  <div style={{
                    position: 'absolute',
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: `${pct}%`,
                    background: 'var(--glass-bg-thick)',
                    backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                    WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                    borderTop: '0.5px solid var(--glass-border)',
                    borderRadius: '16px 16px 0 0',
                    boxShadow: '0 -4px 32px rgba(0,0,0,0.1), var(--glass-specular)',
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                  }}>
                    {/* Drag indicator */}
                    <div style={{ width: 32, height: 4, borderRadius: 2, background: 'var(--label-quaternary)', marginTop: 6, marginBottom: 10 }} />
                    <span style={{ font: 'var(--text-caption2)', color: 'var(--label-secondary)' }}>Sheet Content</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ── Scrollable Sheet ── */}
      <Section title="Scrollable Sheet" description="A sheet with a scrollable content area. The sheet stays fixed while inner content scrolls.">
        <Preview gradient style={{ padding: 0, position: 'relative', height: 400, overflow: 'hidden' }}>
          <div style={{ height: 100, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)' }}>Background content</span>
          </div>
          <div style={{
            position: 'absolute', bottom: 0, left: 0, right: 0, height: 300,
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(72px) saturate(200%)',
            WebkitBackdropFilter: 'blur(72px) saturate(200%)',
            borderTop: '0.5px solid var(--glass-border)',
            borderRadius: '20px 20px 0 0',
            boxShadow: '0 -4px 32px rgba(0,0,0,0.1), var(--glass-specular)',
            display: 'flex',
            flexDirection: 'column',
          }}>
            {/* Drag indicator */}
            <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 4px' }}>
              <div style={{ width: 36, height: 5, borderRadius: 3, background: 'var(--label-quaternary)' }} />
            </div>
            <div style={{ padding: '0 24px 8px' }}>
              <h3 style={{ font: 'var(--text-headline)', marginBottom: 4 }}>Select an Option</h3>
            </div>
            {/* Scrollable list */}
            <div style={{
              flex: 1,
              overflowY: 'auto',
              padding: '0 24px 16px',
              maskImage: 'linear-gradient(to bottom, black 80%, transparent 100%)',
              WebkitMaskImage: 'linear-gradient(to bottom, black 80%, transparent 100%)',
            }}>
              {['Wi-Fi Network', 'Bluetooth Device', 'AirDrop', 'Personal Hotspot', 'VPN Configuration', 'Cellular Data', 'Ethernet', 'USB Tethering', 'Satellite Link', 'Mesh Network'].map((item, i, arr) => (
                <div key={item} style={{
                  padding: '14px 0',
                  borderBottom: i < arr.length - 1 ? '0.5px solid var(--separator)' : 'none',
                  font: 'var(--text-body)',
                  color: 'var(--label)',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                }}>
                  <span>{item}</span>
                  <span style={{ color: 'var(--label-tertiary)', fontSize: 18 }}>&#8250;</span>
                </div>
              ))}
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Form Sheet ── */}
      <Section title="Form Sheet" description="A sheet containing form fields for data entry, with glass-styled inputs and controls.">
        <Preview gradient style={{ padding: 0, position: 'relative', height: 440, overflow: 'hidden' }}>
          <div style={{ height: 80, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)' }}>Background content</span>
          </div>
          <div style={{
            position: 'absolute', bottom: 0, left: 0, right: 0, height: 380,
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(72px) saturate(200%)',
            WebkitBackdropFilter: 'blur(72px) saturate(200%)',
            borderTop: '0.5px solid var(--glass-border)',
            borderRadius: '20px 20px 0 0',
            boxShadow: '0 -4px 32px rgba(0,0,0,0.1), var(--glass-specular)',
            display: 'flex',
            flexDirection: 'column',
          }}>
            {/* Drag indicator */}
            <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 4px' }}>
              <div style={{ width: 36, height: 5, borderRadius: 3, background: 'var(--label-quaternary)' }} />
            </div>
            <div style={{ padding: '0 24px', flex: 1, display: 'flex', flexDirection: 'column' }}>
              <h3 style={{ font: 'var(--text-headline)', marginBottom: 16 }}>New Event</h3>

              <div style={{ display: 'flex', flexDirection: 'column', gap: 12, flex: 1 }}>
                <GlassInput placeholder="Event Name" />
                <GlassInput placeholder="Location" />
                <GlassInput placeholder="Date" type="date" />

                {/* All-day toggle */}
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '8px 16px',
                  background: 'var(--glass-inner)',
                  backdropFilter: 'blur(var(--blur-sm))',
                  WebkitBackdropFilter: 'blur(var(--blur-sm))',
                  border: '0.5px solid var(--glass-border)',
                  borderRadius: 'var(--r-md)',
                }}>
                  <span style={{ font: 'var(--text-body)', color: 'var(--label)' }}>All-day</span>
                  <GlassToggle checked={allDay} onChange={() => setAllDay(v => !v)} />
                </div>

                {/* Spacer */}
                <div style={{ flex: 1 }} />

                {/* Actions */}
                <div style={{ display: 'flex', gap: 12, paddingBottom: 20 }}>
                  <GlassButton variant="glass" style={{ flex: 1 }}>Cancel</GlassButton>
                  <GlassButton variant="filled" style={{ flex: 1 }}>Save</GlassButton>
                </div>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Inline Banner Alert ── */}
      <Section title="Inline Banner Alert" description="Non-modal alert banners that slide in at the top of a content area. Available in warning, error, and info variants.">
        <style>{`
          @keyframes banner-slide-in {
            0% { opacity: 0; transform: translateY(-12px) scale(0.98); }
            100% { opacity: 1; transform: translateY(0) scale(1); }
          }
        `}</style>
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {/* Warning */}
            {banners.warning && (
              <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: 12,
                padding: '12px 16px',
                background: 'rgba(255,204,0,0.12)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid rgba(255,204,0,0.25)',
                borderRadius: 'var(--r-lg)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                animation: 'banner-slide-in 300ms cubic-bezier(0.34,1.56,0.64,1) both',
              }}>
                <span style={{ fontSize: 20, flexShrink: 0 }}>&#9888;</span>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label)', flex: 1 }}>
                  Low storage space. Free up room to continue.
                </span>
                <button
                  onClick={() => setBanners(b => ({ ...b, warning: false }))}
                  style={{
                    background: 'transparent', border: 'none', color: 'var(--label-secondary)',
                    cursor: 'pointer', fontSize: 16, fontWeight: 600, padding: 4, flexShrink: 0,
                  }}
                >
                  &#10005;
                </button>
              </div>
            )}

            {/* Error */}
            {banners.error && (
              <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: 12,
                padding: '12px 16px',
                background: 'rgba(255,59,48,0.12)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid rgba(255,59,48,0.25)',
                borderRadius: 'var(--r-lg)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                animation: 'banner-slide-in 300ms cubic-bezier(0.34,1.56,0.64,1) 50ms both',
              }}>
                <span style={{ fontSize: 20, flexShrink: 0 }}>&#9888;</span>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label)', flex: 1 }}>
                  Upload failed. Please check your connection.
                </span>
                <GlassButton variant="tinted" size="sm" style={{ flexShrink: 0 }} onClick={() => setBanners(b => ({ ...b, error: false }))}>
                  Retry
                </GlassButton>
              </div>
            )}

            {/* Info */}
            {banners.info && (
              <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: 12,
                padding: '12px 16px',
                background: 'var(--glass-bg-tinted)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid rgba(0,122,255,0.2)',
                borderRadius: 'var(--r-lg)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                animation: 'banner-slide-in 300ms cubic-bezier(0.34,1.56,0.64,1) 100ms both',
              }}>
                <span style={{ fontSize: 20, flexShrink: 0 }}>&#8505;</span>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label)', flex: 1 }}>
                  A new version is available with improved performance.
                </span>
                <GlassButton variant="tinted" size="sm" style={{ flexShrink: 0 }} onClick={() => setBanners(b => ({ ...b, info: false }))}>
                  Update
                </GlassButton>
              </div>
            )}

            {/* Reset button if all dismissed */}
            {(!banners.warning || !banners.error || !banners.info) && (
              <div style={{ textAlign: 'center', marginTop: 8 }}>
                <GlassButton variant="plain" size="sm" onClick={() => setBanners({ warning: true, error: true, info: true })}>
                  Reset Banners
                </GlassButton>
              </div>
            )}
          </div>
        </Preview>
      </Section>
    </div>
  )
}
