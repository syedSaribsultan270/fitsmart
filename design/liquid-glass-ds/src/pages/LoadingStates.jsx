import { useState, useEffect, useRef } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton, GlassProgress } from '../components/Glass'

export default function LoadingStates() {
  const [progress, setProgress] = useState(0)
  const [animating, setAnimating] = useState(false)
  const animRef = useRef(null)

  const startProgress = () => {
    setProgress(0)
    setAnimating(true)
    const start = Date.now()
    const tick = () => {
      const elapsed = Date.now() - start
      const pct = Math.min(100, (elapsed / 3000) * 100)
      setProgress(Math.round(pct))
      if (pct < 100) {
        animRef.current = requestAnimationFrame(tick)
      } else {
        setAnimating(false)
      }
    }
    animRef.current = requestAnimationFrame(tick)
  }

  useEffect(() => () => { if (animRef.current) cancelAnimationFrame(animRef.current) }, [])

  const [toastState, setToastState] = useState('loading') // loading | success | error

  return (
    <div>
      <style>{`
        @keyframes shimmer {
          0% { background-position: 200% 0; }
          100% { background-position: -200% 0; }
        }
        @keyframes glass-spin {
          to { transform: rotate(360deg); }
        }
        @keyframes toast-enter {
          0% { opacity: 0; transform: translateY(-16px) scale(0.95); }
          100% { opacity: 1; transform: translateY(0) scale(1); }
        }
      `}</style>

      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Loading States</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Loading patterns that keep users informed about progress. Skeleton screens, shimmers, spinners, and progress indicators rendered with Liquid Glass materials.
      </p>

      {/* ── Skeleton Screen ── */}
      <Section title="Skeleton Screen" description="The primary loading pattern. Placeholder shapes mimic the final layout while content loads.">
        <Preview gradient>
          <div style={{
            background: 'var(--glass-bg)',
            backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
            WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
            border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-xl)',
            boxShadow: 'var(--glass-shadow), var(--glass-specular)',
            padding: 20,
            maxWidth: 360,
          }}>
            <div style={{ display: 'flex', gap: 12, marginBottom: 16 }}>
              {/* Avatar */}
              <div style={{
                width: 48, height: 48, borderRadius: '50%', flexShrink: 0,
                background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
                backgroundSize: '200% 100%',
                animation: 'shimmer 1.5s ease-in-out infinite',
              }} />
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8, flex: 1, justifyContent: 'center' }}>
                {/* Name */}
                <div style={{
                  width: 120, height: 16, borderRadius: 4,
                  background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
                  backgroundSize: '200% 100%',
                  animation: 'shimmer 1.5s ease-in-out infinite',
                }} />
                {/* Subtitle */}
                <div style={{
                  width: 180, height: 12, borderRadius: 4,
                  background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
                  backgroundSize: '200% 100%',
                  animation: 'shimmer 1.5s ease-in-out infinite',
                }} />
              </div>
            </div>
            {/* Content block */}
            <div style={{
              width: '100%', height: 80, borderRadius: 'var(--r-md)',
              background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
              backgroundSize: '200% 100%',
              animation: 'shimmer 1.5s ease-in-out infinite',
            }} />
          </div>
        </Preview>
      </Section>

      {/* ── Shimmer Effect ── */}
      <Section title="Shimmer Effect" description="The animated gradient sweep applied to different placeholder shapes.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 24, alignItems: 'center', flexWrap: 'wrap' }}>
            {/* Circle */}
            <div style={{
              width: 48, height: 48, borderRadius: '50%',
              background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
              backgroundSize: '200% 100%',
              animation: 'shimmer 1.5s ease-in-out infinite',
            }} />
            {/* Short bar */}
            <div style={{
              width: 80, height: 14, borderRadius: 4,
              background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
              backgroundSize: '200% 100%',
              animation: 'shimmer 1.5s ease-in-out infinite',
            }} />
            {/* Long bar */}
            <div style={{
              width: 160, height: 14, borderRadius: 4,
              background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
              backgroundSize: '200% 100%',
              animation: 'shimmer 1.5s ease-in-out infinite',
            }} />
            {/* Full rectangle */}
            <div style={{
              width: 200, height: 60, borderRadius: 'var(--r-sm)',
              background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
              backgroundSize: '200% 100%',
              animation: 'shimmer 1.5s ease-in-out infinite',
            }} />
          </div>
        </Preview>
        <Preview>
          <code style={{
            font: 'var(--text-footnote)',
            fontFamily: 'var(--font-mono)',
            color: 'var(--label-secondary)',
            display: 'block',
            whiteSpace: 'pre-wrap',
            lineHeight: 1.6,
          }}>
{`background: linear-gradient(90deg,
  var(--fill-tertiary) 25%,
  var(--fill-secondary) 50%,
  var(--fill-tertiary) 75%);
background-size: 200% 100%;
animation: shimmer 1.5s ease-in-out infinite;`}
          </code>
        </Preview>
      </Section>

      {/* ── Placeholder Content ── */}
      <Section title="Placeholder Content" description="A full page mock with skeleton loading, showing how skeletons compose into a realistic app loading state.">
        <Preview gradient>
          <div style={{
            background: 'var(--glass-bg)',
            backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
            WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
            border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-xl)',
            boxShadow: 'var(--glass-shadow), var(--glass-specular)',
            overflow: 'hidden',
            maxWidth: 400,
          }}>
            {/* Nav bar skeleton */}
            <div style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              padding: '12px 16px',
              borderBottom: '0.5px solid var(--separator)',
            }}>
              <div style={{
                width: 24, height: 24, borderRadius: 4,
                background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
                backgroundSize: '200% 100%',
                animation: 'shimmer 1.5s ease-in-out infinite',
              }} />
              <div style={{
                width: 100, height: 16, borderRadius: 4,
                background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
                backgroundSize: '200% 100%',
                animation: 'shimmer 1.5s ease-in-out infinite',
              }} />
              <div style={{
                width: 24, height: 24, borderRadius: 4,
                background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
                backgroundSize: '200% 100%',
                animation: 'shimmer 1.5s ease-in-out infinite',
              }} />
            </div>

            {/* List of 4 skeleton rows */}
            <div style={{ padding: '8px 16px' }}>
              {[0, 1, 2, 3].map((i) => (
                <div key={i} style={{
                  display: 'flex',
                  gap: 12,
                  padding: '14px 0',
                  borderBottom: i < 3 ? '0.5px solid var(--separator)' : 'none',
                }}>
                  {/* Icon placeholder */}
                  <div style={{
                    width: 36, height: 36, borderRadius: 'var(--r-xs)', flexShrink: 0,
                    background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
                    backgroundSize: '200% 100%',
                    animation: 'shimmer 1.5s ease-in-out infinite',
                  }} />
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 6, flex: 1, justifyContent: 'center' }}>
                    <div style={{
                      width: `${100 + i * 20}px`, height: 14, borderRadius: 4,
                      background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
                      backgroundSize: '200% 100%',
                      animation: 'shimmer 1.5s ease-in-out infinite',
                    }} />
                    <div style={{
                      width: `${140 + i * 15}px`, height: 10, borderRadius: 4,
                      background: 'linear-gradient(90deg, var(--fill-tertiary) 25%, var(--fill-secondary) 50%, var(--fill-tertiary) 75%)',
                      backgroundSize: '200% 100%',
                      animation: 'shimmer 1.5s ease-in-out infinite',
                    }} />
                  </div>
                </div>
              ))}
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Spinner Variants ── */}
      <Section title="Spinner Variants" description="Indeterminate spinners for when progress cannot be measured. Available in multiple sizes and colors.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 32, alignItems: 'center', flexWrap: 'wrap' }}>
            {/* System spinner 20px */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 20, height: 20,
                border: '2px solid rgba(255,255,255,0.2)',
                borderTopColor: '#fff',
                borderRadius: '50%',
                animation: 'glass-spin 0.8s linear infinite',
              }} />
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)' }}>20px</span>
            </div>

            {/* Large spinner 36px */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 36, height: 36,
                border: '3px solid rgba(255,255,255,0.2)',
                borderTopColor: '#fff',
                borderRadius: '50%',
                animation: 'glass-spin 0.8s linear infinite',
              }} />
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)' }}>36px</span>
            </div>

            {/* Colored spinner */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 20, height: 20,
                border: '2px solid rgba(0,122,255,0.2)',
                borderTopColor: 'var(--blue)',
                borderRadius: '50%',
                animation: 'glass-spin 0.8s linear infinite',
              }} />
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)' }}>Blue</span>
            </div>

            {/* Inline spinner + text */}
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 16, height: 16,
                border: '2px solid rgba(255,255,255,0.2)',
                borderTopColor: '#fff',
                borderRadius: '50%',
                animation: 'glass-spin 0.8s linear infinite',
              }} />
              <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.8)' }}>Loading...</span>
            </div>
          </div>
        </Preview>

        {/* Full-screen spinner */}
        <Preview gradient style={{ position: 'relative', minHeight: 200, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{
            position: 'absolute', inset: 0,
            background: 'var(--glass-bg-thin)',
            backdropFilter: 'blur(var(--blur-sm))',
            WebkitBackdropFilter: 'blur(var(--blur-sm))',
            borderRadius: 'var(--r-xl)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}>
            <div style={{
              width: 36, height: 36,
              border: '3px solid rgba(255,255,255,0.2)',
              borderTopColor: '#fff',
              borderRadius: '50%',
              animation: 'glass-spin 0.8s linear infinite',
            }} />
          </div>
          <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.3)', zIndex: 0 }}>Full-screen overlay spinner</span>
        </Preview>
      </Section>

      {/* ── Progress Loading ── */}
      <Section title="Progress Loading" description="Determinate progress bars showing exact completion. Use when the total work is known.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16, maxWidth: 400 }}>
            {[0, 33, 66, 100].map((val) => (
              <div key={val}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                  <span style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.7)' }}>
                    {val === 0 ? 'Not started' : val === 100 ? 'Complete' : `${val}%`}
                  </span>
                  <span style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.5)' }}>{val}%</span>
                </div>
                <GlassProgress value={val} />
              </div>
            ))}
          </div>
        </Preview>

        {/* Interactive demo */}
        <Preview gradient>
          <div style={{ maxWidth: 400, display: 'flex', flexDirection: 'column', gap: 12 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.8)' }}>
                {animating ? `Downloading... ${progress}%` : progress === 100 ? 'Download complete' : 'Interactive demo'}
              </span>
              <GlassButton variant="filled" size="sm" onClick={startProgress} disabled={animating}>
                {animating ? 'Running...' : progress === 100 ? 'Restart' : 'Start'}
              </GlassButton>
            </div>
            <GlassProgress value={progress} />
          </div>
        </Preview>

        {/* Progress with label */}
        <Preview gradient>
          <div style={{ maxWidth: 400 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
              <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.8)' }}>Downloading...</span>
              <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.6)' }}>67%</span>
            </div>
            <GlassProgress value={67} />
          </div>
        </Preview>
      </Section>

      {/* ── Loading Toast ── */}
      <Section title="Loading Toast" description="A small glass pill that appears at the top of the screen to show a transient loading state with spring entrance animation.">
        <Preview gradient style={{ minHeight: 200, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24 }}>
          {/* Three toast states */}
          <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap', justifyContent: 'center' }}>
            {/* Loading */}
            <div style={{
              display: 'flex', alignItems: 'center', gap: 8,
              height: 36,
              padding: '0 16px',
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-pill)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              animation: 'toast-enter 300ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
            }}>
              <div style={{
                width: 14, height: 14,
                border: '2px solid rgba(255,255,255,0.2)',
                borderTopColor: '#fff',
                borderRadius: '50%',
                animation: 'glass-spin 0.8s linear infinite',
              }} />
              <span style={{ font: 'var(--text-footnote)', color: 'var(--label)', fontWeight: 500 }}>Saving...</span>
            </div>

            {/* Success */}
            <div style={{
              display: 'flex', alignItems: 'center', gap: 8,
              height: 36,
              padding: '0 16px',
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-pill)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              animation: 'toast-enter 300ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
            }}>
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" style={{ color: 'var(--green)' }}>
                <circle cx="8" cy="8" r="7" stroke="currentColor" strokeWidth="1.5" fill="none" />
                <path d="M5 8L7 10L11 6" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
              <span style={{ font: 'var(--text-footnote)', color: 'var(--label)', fontWeight: 500 }}>Saved</span>
            </div>

            {/* Error */}
            <div style={{
              display: 'flex', alignItems: 'center', gap: 8,
              height: 36,
              padding: '0 16px',
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-pill)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              animation: 'toast-enter 300ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
            }}>
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none" style={{ color: 'var(--red)' }}>
                <circle cx="8" cy="8" r="7" stroke="currentColor" strokeWidth="1.5" fill="none" />
                <line x1="5.5" y1="5.5" x2="10.5" y2="10.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                <line x1="10.5" y1="5.5" x2="5.5" y2="10.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
              </svg>
              <span style={{ font: 'var(--text-footnote)', color: 'var(--label)', fontWeight: 500 }}>Failed</span>
            </div>
          </div>

          {/* Interactive toast toggle */}
          <div style={{ display: 'flex', gap: 8 }}>
            <GlassButton variant={toastState === 'loading' ? 'filled' : 'glass'} size="sm" onClick={() => setToastState('loading')}>Loading</GlassButton>
            <GlassButton variant={toastState === 'success' ? 'filled' : 'glass'} size="sm" onClick={() => setToastState('success')}>Success</GlassButton>
            <GlassButton variant={toastState === 'error' ? 'filled' : 'glass'} size="sm" onClick={() => setToastState('error')}>Error</GlassButton>
          </div>
        </Preview>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs" description="Reference values for implementing loading states.">
        <SpecTable
          headers={['Property', 'Value']}
          rows={[
            ['Skeleton shimmer duration', '1.5s ease-in-out infinite'],
            ['Spinner sizes', '20px (default), 36px (large)'],
            ['Progress bar height', '4px'],
            ['Toast height', '36px'],
            ['Entrance animation', '300ms cubic-bezier(0.34, 1.56, 0.64, 1)'],
          ]}
        />
      </Section>
    </div>
  )
}
