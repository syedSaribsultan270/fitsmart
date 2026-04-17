import { useState, useEffect, useRef } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton, GlassProgress } from '../components/Glass'

export default function ErrorHandling() {
  // Retry pattern state machine
  const [retryState, setRetryState] = useState('idle') // idle | loading | error | success
  const timerRef = useRef(null)

  const handleLoadData = () => {
    setRetryState('loading')
    timerRef.current = setTimeout(() => setRetryState('error'), 1500)
  }

  const handleRetry = () => {
    setRetryState('loading')
    timerRef.current = setTimeout(() => setRetryState('success'), 1000)
  }

  useEffect(() => () => { if (timerRef.current) clearTimeout(timerRef.current) }, [])

  // Offline banner
  const [showOfflineBanner, setShowOfflineBanner] = useState(true)
  const [showOnlineBanner, setShowOnlineBanner] = useState(false)

  // Toast errors
  const [toasts, setToasts] = useState({ error: true, warning: true, info: true })

  return (
    <div>
      <style>{`
        @keyframes glass-spin {
          to { transform: rotate(360deg); }
        }
        @keyframes banner-slide-down {
          0% { opacity: 0; transform: translateY(-100%) scale(0.98); }
          100% { opacity: 1; transform: translateY(0) scale(1); }
        }
        @keyframes banner-slide-up {
          0% { opacity: 1; transform: translateY(0) scale(1); }
          100% { opacity: 0; transform: translateY(-100%) scale(0.98); }
        }
        @keyframes toast-stack-enter {
          0% { opacity: 0; transform: translateY(16px) scale(0.95); }
          100% { opacity: 1; transform: translateY(0) scale(1); }
        }
        @keyframes fade-in {
          0% { opacity: 0; transform: scale(0.95); }
          100% { opacity: 1; transform: scale(1); }
        }
      `}</style>

      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Error Handling</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Patterns for communicating errors, guiding recovery, and maintaining trust. Inline validations, full-page errors, banners, and toast notifications rendered with Liquid Glass materials.
      </p>

      {/* ── Inline Field Errors ── */}
      <Section title="Inline Field Errors" description="Form fields with validation states. Errors appear directly below the field with color and icon cues.">
        <Preview gradient>
          <div style={{
            background: 'var(--glass-bg)',
            backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
            WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
            border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-xl)',
            boxShadow: 'var(--glass-shadow), var(--glass-specular)',
            padding: 24,
            maxWidth: 380,
            display: 'flex',
            flexDirection: 'column',
            gap: 20,
          }}>
            {/* Email — Error */}
            <div>
              <label style={{ font: 'var(--text-subhead)', color: 'var(--label)', display: 'block', marginBottom: 6 }}>Email</label>
              <div style={{
                padding: '10px 14px',
                background: 'var(--glass-inner)',
                backdropFilter: 'blur(var(--blur-sm))',
                WebkitBackdropFilter: 'blur(var(--blur-sm))',
                border: '1.5px solid var(--red)',
                borderRadius: 'var(--r-md)',
                font: 'var(--text-body)',
                color: 'var(--label)',
              }}>
                user@invalid
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginTop: 6 }}>
                <svg width="14" height="14" viewBox="0 0 14 14" fill="none" style={{ color: 'var(--red)', flexShrink: 0 }}>
                  <circle cx="7" cy="7" r="6" stroke="currentColor" strokeWidth="1.2" fill="none" />
                  <line x1="7" y1="4" x2="7" y2="8" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round" />
                  <circle cx="7" cy="10" r="0.8" fill="currentColor" />
                </svg>
                <span style={{ font: 'var(--text-footnote)', color: 'var(--red)' }}>Please enter a valid email</span>
              </div>
            </div>

            {/* Password — Error */}
            <div>
              <label style={{ font: 'var(--text-subhead)', color: 'var(--label)', display: 'block', marginBottom: 6 }}>Password</label>
              <div style={{
                padding: '10px 14px',
                background: 'var(--glass-inner)',
                backdropFilter: 'blur(var(--blur-sm))',
                WebkitBackdropFilter: 'blur(var(--blur-sm))',
                border: '1.5px solid var(--red)',
                borderRadius: 'var(--r-md)',
                font: 'var(--text-body)',
                color: 'var(--label)',
              }}>
                &#8226;&#8226;&#8226;
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginTop: 6 }}>
                <svg width="14" height="14" viewBox="0 0 14 14" fill="none" style={{ color: 'var(--red)', flexShrink: 0 }}>
                  <circle cx="7" cy="7" r="6" stroke="currentColor" strokeWidth="1.2" fill="none" />
                  <line x1="7" y1="4" x2="7" y2="8" stroke="currentColor" strokeWidth="1.2" strokeLinecap="round" />
                  <circle cx="7" cy="10" r="0.8" fill="currentColor" />
                </svg>
                <span style={{ font: 'var(--text-footnote)', color: 'var(--red)' }}>Password must be at least 8 characters</span>
              </div>
            </div>

            {/* Name — Valid */}
            <div>
              <label style={{ font: 'var(--text-subhead)', color: 'var(--label)', display: 'block', marginBottom: 6 }}>Name</label>
              <div style={{
                display: 'flex',
                alignItems: 'center',
                padding: '10px 14px',
                background: 'var(--glass-inner)',
                backdropFilter: 'blur(var(--blur-sm))',
                WebkitBackdropFilter: 'blur(var(--blur-sm))',
                border: '1.5px solid var(--green)',
                borderRadius: 'var(--r-md)',
                font: 'var(--text-body)',
                color: 'var(--label)',
              }}>
                <span style={{ flex: 1 }}>Abdullah</span>
                <svg width="18" height="18" viewBox="0 0 18 18" fill="none" style={{ color: 'var(--green)', flexShrink: 0 }}>
                  <circle cx="9" cy="9" r="8" stroke="currentColor" strokeWidth="1.5" fill="none" />
                  <path d="M5.5 9L8 11.5L12.5 6.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Error Pages ── */}
      <Section title="Error Pages" description="Full-page error states for when navigation leads nowhere or the server fails.">
        <Preview gradient>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 24, justifyContent: 'center' }}>
            {/* 404 */}
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              padding: 32,
              maxWidth: 280,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              textAlign: 'center',
              gap: 8,
            }}>
              <span style={{
                font: 'var(--text-large-title)',
                fontSize: 64,
                lineHeight: 1,
                color: 'var(--label-tertiary)',
                fontWeight: 700,
                letterSpacing: -2,
              }}>404</span>
              <h3 style={{ font: 'var(--text-headline)', color: 'var(--label)', margin: 0 }}>Page Not Found</h3>
              <p style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', margin: '4px 0 12px' }}>
                The page you're looking for doesn't exist or has been moved.
              </p>
              <GlassButton variant="filled">Go Home</GlassButton>
            </div>

            {/* 500 */}
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              padding: 32,
              maxWidth: 280,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              textAlign: 'center',
              gap: 8,
            }}>
              <span style={{
                font: 'var(--text-large-title)',
                fontSize: 64,
                lineHeight: 1,
                color: 'var(--red)',
                fontWeight: 700,
                letterSpacing: -2,
                opacity: 0.6,
              }}>500</span>
              <h3 style={{ font: 'var(--text-headline)', color: 'var(--label)', margin: 0 }}>Server Error</h3>
              <p style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', margin: '4px 0 12px' }}>
                Something went wrong on our end. Please try again later.
              </p>
              <GlassButton variant="filled">Retry</GlassButton>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Retry Pattern ── */}
      <Section title="Retry Pattern" description="An interactive demo of the loading-error-retry-success flow. Click 'Load Data' to start the sequence.">
        <Preview gradient>
          <div style={{
            background: 'var(--glass-bg)',
            backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
            WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
            border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-xl)',
            boxShadow: 'var(--glass-shadow), var(--glass-specular)',
            padding: 32,
            maxWidth: 340,
            minHeight: 160,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            textAlign: 'center',
            gap: 12,
            margin: '0 auto',
          }}>
            {retryState === 'idle' && (
              <div style={{ animation: 'fade-in 200ms ease both' }}>
                <p style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', margin: '0 0 16px' }}>
                  Press the button to simulate a data fetch.
                </p>
                <GlassButton variant="filled" onClick={handleLoadData}>Load Data</GlassButton>
              </div>
            )}

            {retryState === 'loading' && (
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12, animation: 'fade-in 200ms ease both' }}>
                <div style={{
                  width: 28, height: 28,
                  border: '2.5px solid rgba(255,255,255,0.2)',
                  borderTopColor: '#fff',
                  borderRadius: '50%',
                  animation: 'glass-spin 0.8s linear infinite',
                }} />
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>Loading...</span>
              </div>
            )}

            {retryState === 'error' && (
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12, animation: 'fade-in 200ms ease both' }}>
                <svg width="36" height="36" viewBox="0 0 36 36" fill="none" style={{ color: 'var(--red)' }}>
                  <circle cx="18" cy="18" r="16" stroke="currentColor" strokeWidth="2" fill="none" />
                  <line x1="12" y1="12" x2="24" y2="24" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
                  <line x1="24" y1="12" x2="12" y2="24" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
                </svg>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>Failed to load</span>
                <GlassButton variant="filled" onClick={handleRetry}>Retry</GlassButton>
              </div>
            )}

            {retryState === 'success' && (
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12, animation: 'fade-in 200ms ease both' }}>
                <svg width="36" height="36" viewBox="0 0 36 36" fill="none" style={{ color: 'var(--green)' }}>
                  <circle cx="18" cy="18" r="16" stroke="currentColor" strokeWidth="2" fill="none" />
                  <path d="M11 18L16 23L25 13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>Data loaded!</span>
                <GlassButton variant="plain" size="sm" onClick={() => setRetryState('idle')}>Reset Demo</GlassButton>
              </div>
            )}
          </div>
        </Preview>
      </Section>

      {/* ── Offline Banner ── */}
      <Section title="Offline Banner" description="A persistent bar at the top of the content area that communicates connectivity status.">
        <Preview gradient style={{ position: 'relative', overflow: 'hidden', minHeight: 200 }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {/* Offline banner */}
            {showOfflineBanner && (
              <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: 10,
                height: 48,
                padding: '0 16px',
                background: 'rgba(255,204,0,0.14)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid rgba(255,204,0,0.25)',
                borderRadius: 'var(--r-lg)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                animation: 'banner-slide-down 300ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
              }}>
                {/* Wifi-off icon */}
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none" style={{ color: 'var(--orange)', flexShrink: 0 }}>
                  <path d="M3 7.5C5 5.2 7.3 4 10 4C12.7 4 15 5.2 17 7.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" fill="none" />
                  <path d="M5.5 11C6.8 9.5 8.3 9 10 9C11.7 9 13.2 9.5 14.5 11" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" fill="none" />
                  <circle cx="10" cy="14.5" r="1.2" fill="currentColor" />
                  <line x1="3" y1="17" x2="17" y2="3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                </svg>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label)', flex: 1 }}>No internet connection</span>
                <GlassButton variant="tinted" size="sm" onClick={() => {
                  setShowOfflineBanner(false)
                  setShowOnlineBanner(true)
                  setTimeout(() => setShowOnlineBanner(false), 3000)
                }}>
                  Retry
                </GlassButton>
                <button
                  onClick={() => setShowOfflineBanner(false)}
                  style={{
                    background: 'transparent', border: 'none', color: 'var(--label-secondary)',
                    cursor: 'pointer', fontSize: 14, fontWeight: 600, padding: 4, flexShrink: 0, lineHeight: 1,
                  }}
                >
                  &#10005;
                </button>
              </div>
            )}

            {/* Back online banner */}
            {showOnlineBanner && (
              <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: 10,
                height: 48,
                padding: '0 16px',
                background: 'rgba(52,199,89,0.14)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid rgba(52,199,89,0.25)',
                borderRadius: 'var(--r-lg)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                animation: 'banner-slide-down 300ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
              }}>
                <svg width="18" height="18" viewBox="0 0 18 18" fill="none" style={{ color: 'var(--green)', flexShrink: 0 }}>
                  <circle cx="9" cy="9" r="8" stroke="currentColor" strokeWidth="1.5" fill="none" />
                  <path d="M5.5 9L8 11.5L12.5 6.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label)', flex: 1 }}>Back online</span>
              </div>
            )}

            {/* Reset */}
            {!showOfflineBanner && !showOnlineBanner && (
              <div style={{ textAlign: 'center', marginTop: 8 }}>
                <GlassButton variant="plain" size="sm" onClick={() => setShowOfflineBanner(true)}>Reset Banner Demo</GlassButton>
              </div>
            )}

            {/* Faux content behind the banner */}
            <div style={{ padding: '8px 0' }}>
              {[1, 2, 3].map((i) => (
                <div key={i} style={{
                  padding: '12px 0',
                  borderBottom: i < 3 ? '0.5px solid rgba(255,255,255,0.08)' : 'none',
                  font: 'var(--text-subhead)',
                  color: 'rgba(255,255,255,0.3)',
                }}>
                  Content row {i}
                </div>
              ))}
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Toast Errors ── */}
      <Section title="Toast Errors" description="Small glass pill notifications stacked at the bottom-right. Each variant uses color and icon to communicate severity.">
        <Preview gradient style={{ minHeight: 240, position: 'relative' }}>
          {/* Stacked toasts at bottom-right */}
          <div style={{
            position: 'absolute',
            bottom: 24,
            right: 24,
            display: 'flex',
            flexDirection: 'column',
            gap: 8,
            maxWidth: 360,
          }}>
            {/* Error toast */}
            {toasts.error && (
              <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: 10,
                padding: '10px 14px',
                background: 'rgba(255,59,48,0.12)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid rgba(255,59,48,0.25)',
                borderRadius: 'var(--r-lg)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                animation: 'toast-stack-enter 300ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
              }}>
                <svg width="18" height="18" viewBox="0 0 18 18" fill="none" style={{ color: 'var(--red)', flexShrink: 0 }}>
                  <circle cx="9" cy="9" r="8" stroke="currentColor" strokeWidth="1.5" fill="none" />
                  <line x1="6" y1="6" x2="12" y2="12" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                  <line x1="12" y1="6" x2="6" y2="12" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                </svg>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label)', flex: 1 }}>Upload failed</span>
                <GlassButton variant="plain" size="sm">Retry</GlassButton>
                <button onClick={() => setToasts(t => ({ ...t, error: false }))} style={{
                  background: 'transparent', border: 'none', color: 'var(--label-tertiary)',
                  cursor: 'pointer', fontSize: 13, fontWeight: 600, padding: 2, lineHeight: 1,
                }}>&#10005;</button>
              </div>
            )}

            {/* Warning toast */}
            {toasts.warning && (
              <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: 10,
                padding: '10px 14px',
                background: 'rgba(255,149,0,0.12)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid rgba(255,149,0,0.25)',
                borderRadius: 'var(--r-lg)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                animation: 'toast-stack-enter 300ms cubic-bezier(0.34, 1.56, 0.64, 1) 50ms both',
              }}>
                <svg width="18" height="18" viewBox="0 0 18 18" fill="none" style={{ color: 'var(--orange)', flexShrink: 0 }}>
                  <path d="M9 2L17 16H1L9 2Z" stroke="currentColor" strokeWidth="1.5" strokeLinejoin="round" fill="none" />
                  <line x1="9" y1="7" x2="9" y2="11" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                  <circle cx="9" cy="13.5" r="0.8" fill="currentColor" />
                </svg>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label)', flex: 1 }}>Slow connection</span>
                <GlassButton variant="plain" size="sm">Dismiss</GlassButton>
                <button onClick={() => setToasts(t => ({ ...t, warning: false }))} style={{
                  background: 'transparent', border: 'none', color: 'var(--label-tertiary)',
                  cursor: 'pointer', fontSize: 13, fontWeight: 600, padding: 2, lineHeight: 1,
                }}>&#10005;</button>
              </div>
            )}

            {/* Info toast */}
            {toasts.info && (
              <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: 10,
                padding: '10px 14px',
                background: 'rgba(0,122,255,0.12)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid rgba(0,122,255,0.25)',
                borderRadius: 'var(--r-lg)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                animation: 'toast-stack-enter 300ms cubic-bezier(0.34, 1.56, 0.64, 1) 100ms both',
              }}>
                <svg width="18" height="18" viewBox="0 0 18 18" fill="none" style={{ color: 'var(--blue)', flexShrink: 0 }}>
                  <circle cx="9" cy="9" r="8" stroke="currentColor" strokeWidth="1.5" fill="none" />
                  <line x1="9" y1="8" x2="9" y2="13" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                  <circle cx="9" cy="5.5" r="0.8" fill="currentColor" />
                </svg>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label)', flex: 1 }}>New version available</span>
                <GlassButton variant="plain" size="sm">Update</GlassButton>
                <button onClick={() => setToasts(t => ({ ...t, info: false }))} style={{
                  background: 'transparent', border: 'none', color: 'var(--label-tertiary)',
                  cursor: 'pointer', fontSize: 13, fontWeight: 600, padding: 2, lineHeight: 1,
                }}>&#10005;</button>
              </div>
            )}
          </div>

          {/* Reset if all dismissed */}
          {(!toasts.error || !toasts.warning || !toasts.info) && (
            <div style={{ textAlign: 'center' }}>
              <GlassButton variant="plain" size="sm" onClick={() => setToasts({ error: true, warning: true, info: true })}>
                Reset Toasts
              </GlassButton>
            </div>
          )}
        </Preview>
      </Section>

      {/* ── Error Handling Guidelines ── */}
      <Section title="Error Handling Guidelines" description="Best practices for designing error experiences.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: 16 }}>
          {[
            'Show errors near the source — inline, not in a distant alert',
            'Always provide a recovery action (retry, go back, contact support)',
            'Use color + icon, never color alone',
            'Preserve user input when showing errors',
            'Log errors for debugging; show user-friendly messages',
          ].map((guideline) => (
            <GlassCard key={guideline} style={{ padding: 20 }}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none" style={{ color: 'var(--green)', flexShrink: 0, marginTop: 1 }}>
                  <circle cx="10" cy="10" r="9" stroke="currentColor" strokeWidth="1.5" fill="none" />
                  <path d="M6 10L9 13L14 7" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>{guideline}</span>
              </div>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs" description="Reference values for implementing error handling patterns.">
        <SpecTable
          headers={['Property', 'Value']}
          rows={[
            ['Inline error font', 'var(--text-footnote)'],
            ['Error color', '--red'],
            ['Banner height', '48px'],
            ['Toast max-width', '360px'],
            ['Animation', '300ms cubic-bezier(0.34, 1.56, 0.64, 1)'],
          ]}
        />
      </Section>
    </div>
  )
}
