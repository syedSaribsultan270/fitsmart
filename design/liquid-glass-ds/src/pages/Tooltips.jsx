import { useState, useRef, useCallback, useEffect } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

/* ------------------------------------------------------------------ */
/*  Reusable Tooltip wrapper                                          */
/* ------------------------------------------------------------------ */
function Tooltip({ text, position = 'top', delay = 600, children, style: wrapperStyle }) {
  const [visible, setVisible] = useState(false)
  const timerRef = useRef(null)

  const show = () => {
    timerRef.current = setTimeout(() => setVisible(true), delay)
  }
  const hide = () => {
    clearTimeout(timerRef.current)
    setVisible(false)
  }

  useEffect(() => () => clearTimeout(timerRef.current), [])

  const arrowSize = 6

  const positionStyles = {
    top: { bottom: '100%', left: '50%', transform: 'translateX(-50%)', marginBottom: arrowSize + 4 },
    bottom: { top: '100%', left: '50%', transform: 'translateX(-50%)', marginTop: arrowSize + 4 },
    left: { right: '100%', top: '50%', transform: 'translateY(-50%)', marginRight: arrowSize + 4 },
    right: { left: '100%', top: '50%', transform: 'translateY(-50%)', marginLeft: arrowSize + 4 },
  }

  const arrowStyles = {
    top: { bottom: -arrowSize, left: '50%', transform: 'translateX(-50%)', borderLeft: `${arrowSize}px solid transparent`, borderRight: `${arrowSize}px solid transparent`, borderTop: `${arrowSize}px solid rgba(255,255,255,0.18)` },
    bottom: { top: -arrowSize, left: '50%', transform: 'translateX(-50%)', borderLeft: `${arrowSize}px solid transparent`, borderRight: `${arrowSize}px solid transparent`, borderBottom: `${arrowSize}px solid rgba(255,255,255,0.18)` },
    left: { right: -arrowSize, top: '50%', transform: 'translateY(-50%)', borderTop: `${arrowSize}px solid transparent`, borderBottom: `${arrowSize}px solid transparent`, borderLeft: `${arrowSize}px solid rgba(255,255,255,0.18)` },
    right: { left: -arrowSize, top: '50%', transform: 'translateY(-50%)', borderTop: `${arrowSize}px solid transparent`, borderBottom: `${arrowSize}px solid transparent`, borderRight: `${arrowSize}px solid rgba(255,255,255,0.18)` },
  }

  return (
    <div
      onMouseEnter={show}
      onMouseLeave={hide}
      style={{ position: 'relative', display: 'inline-flex', ...wrapperStyle }}
    >
      {children}

      {visible && (
        <div style={{
          position: 'absolute',
          ...positionStyles[position],
          zIndex: 100,
          whiteSpace: 'nowrap',
          pointerEvents: 'none',
          animation: 'tooltipIn 200ms var(--ease-spring) forwards',
        }}>
          <div style={{
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(var(--blur-md))',
            WebkitBackdropFilter: 'blur(var(--blur-md))',
            border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-md)',
            padding: '8px 12px',
            font: 'var(--text-caption1)',
            color: 'var(--label)',
            boxShadow: 'var(--glass-shadow)',
          }}>
            {text}
            {/* Arrow */}
            <div style={{
              position: 'absolute', width: 0, height: 0,
              ...arrowStyles[position],
            }} />
          </div>
        </div>
      )}
    </div>
  )
}

/* ------------------------------------------------------------------ */
/*  Rich Tooltip                                                      */
/* ------------------------------------------------------------------ */
function RichTooltip({ title, description, shortcut, position = 'bottom', delay = 600, children }) {
  const [visible, setVisible] = useState(false)
  const timerRef = useRef(null)

  const show = () => { timerRef.current = setTimeout(() => setVisible(true), delay) }
  const hide = () => { clearTimeout(timerRef.current); setVisible(false) }
  useEffect(() => () => clearTimeout(timerRef.current), [])

  const arrowSize = 6
  const positionStyles = {
    top: { bottom: '100%', left: '50%', transform: 'translateX(-50%)', marginBottom: arrowSize + 4 },
    bottom: { top: '100%', left: '50%', transform: 'translateX(-50%)', marginTop: arrowSize + 4 },
  }
  const arrowStyles = {
    top: { bottom: -arrowSize, left: '50%', transform: 'translateX(-50%)', borderLeft: `${arrowSize}px solid transparent`, borderRight: `${arrowSize}px solid transparent`, borderTop: `${arrowSize}px solid rgba(255,255,255,0.18)` },
    bottom: { top: -arrowSize, left: '50%', transform: 'translateX(-50%)', borderLeft: `${arrowSize}px solid transparent`, borderRight: `${arrowSize}px solid transparent`, borderBottom: `${arrowSize}px solid rgba(255,255,255,0.18)` },
  }

  return (
    <div onMouseEnter={show} onMouseLeave={hide} style={{ position: 'relative', display: 'inline-flex' }}>
      {children}
      {visible && (
        <div style={{
          position: 'absolute', ...positionStyles[position], zIndex: 100,
          animation: 'tooltipIn 200ms var(--ease-spring) forwards',
        }}>
          <div style={{
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(var(--blur-md))',
            WebkitBackdropFilter: 'blur(var(--blur-md))',
            border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-md)',
            padding: '12px 16px',
            maxWidth: 280, minWidth: 200,
            boxShadow: 'var(--glass-shadow)',
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 12 }}>
              <div>
                <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 4 }}>{title}</div>
                <div style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', fontSize: 14 }}>{description}</div>
              </div>
              {shortcut && (
                <span style={{ font: 'var(--text-caption1)', fontFamily: 'var(--font-mono)', color: 'var(--label-tertiary)', whiteSpace: 'nowrap', marginTop: 2 }}>
                  {shortcut}
                </span>
              )}
            </div>
            <div style={{ position: 'absolute', width: 0, height: 0, ...arrowStyles[position] }} />
          </div>
        </div>
      )}
    </div>
  )
}

/* ================================================================== */
/*  Page                                                              */
/* ================================================================== */
export default function Tooltips() {
  const [tooltipDelay, setTooltipDelay] = useState(600)

  return (
    <div>
      <style>{`
        @keyframes tooltipIn {
          from { opacity: 0; transform: translateX(-50%) scale(0.95); }
          to   { opacity: 1; transform: translateX(-50%) scale(1); }
        }
      `}</style>

      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Tooltips</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Contextual information overlays that appear on hover with a glass material surface.
      </p>

      {/* ============================================================
          1. Standard Tooltip
          ============================================================ */}
      <Section title="Standard Tooltip" description="Hover each button to reveal a tooltip in a different position. Shows after a 600ms delay.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap', justifyContent: 'center', padding: '40px 0' }}>
            <Tooltip text="Tooltip on top" position="top">
              <GlassButton>Top</GlassButton>
            </Tooltip>
            <Tooltip text="Tooltip on bottom" position="bottom">
              <GlassButton>Bottom</GlassButton>
            </Tooltip>
            <Tooltip text="Tooltip on left" position="left">
              <GlassButton>Left</GlassButton>
            </Tooltip>
            <Tooltip text="Tooltip on right" position="right">
              <GlassButton>Right</GlassButton>
            </Tooltip>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          2. Rich Tooltip
          ============================================================ */}
      <Section title="Rich Tooltip" description="Multi-line tooltip with title, description, and optional keyboard shortcut.">
        <Preview gradient>
          <div style={{ display: 'flex', justifyContent: 'center', padding: '40px 0' }}>
            <RichTooltip
              title="Quick Actions"
              description="Open the command palette to search for actions, files, and settings."
              shortcut="Cmd+K"
              position="bottom"
            >
              <GlassButton>Hover for details</GlassButton>
            </RichTooltip>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          3. Tooltip on Various Elements
          ============================================================ */}
      <Section title="Tooltip on Various Elements" description="Tooltips can attach to icons, links, disabled buttons, and truncated text.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 32, flexWrap: 'wrap', alignItems: 'center', padding: '32px 0' }}>
            {/* Icon button */}
            <Tooltip text="More information" position="top">
              <button style={{
                width: 36, height: 36, borderRadius: '50%', border: 'none',
                background: 'rgba(255,255,255,0.12)', color: '#fff', cursor: 'pointer',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <circle cx="12" cy="12" r="10" />
                  <line x1="12" y1="16" x2="12" y2="12" />
                  <line x1="12" y1="8" x2="12.01" y2="8" />
                </svg>
              </button>
            </Tooltip>

            {/* Text link */}
            <Tooltip text="Learn about accessibility guidelines" position="top">
              <a href="#" onClick={(e) => e.preventDefault()} style={{
                font: 'var(--text-body)', color: 'var(--blue)', textDecoration: 'none',
              }}>
                What's this?
              </a>
            </Tooltip>

            {/* Disabled button */}
            <Tooltip text="Complete all required fields to submit" position="top">
              <span>
                <GlassButton disabled style={{ opacity: 0.5, pointerEvents: 'none' }}>Submit</GlassButton>
              </span>
            </Tooltip>

            {/* Truncated text */}
            <Tooltip text="This is a very long text that has been truncated to fit within the container" position="top">
              <span style={{
                font: 'var(--text-body)', color: 'rgba(255,255,255,0.8)',
                maxWidth: 120, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
                display: 'inline-block',
              }}>
                This is a very long text that has been truncated
              </span>
            </Tooltip>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          4. Tooltip Delay
          ============================================================ */}
      <Section title="Tooltip Delay" description="Adjust the hover delay before the tooltip appears. Range: 0ms to 1000ms.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24, padding: '24px 0' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 16, width: '100%', maxWidth: 360 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', minWidth: 32 }}>0ms</span>
              <input
                type="range" min={0} max={1000} step={50} value={tooltipDelay}
                onChange={(e) => setTooltipDelay(Number(e.target.value))}
                style={{ flex: 1, accentColor: 'var(--blue)' }}
              />
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', minWidth: 42 }}>1000ms</span>
            </div>
            <div style={{
              font: 'var(--text-headline)', color: '#fff',
              background: 'rgba(255,255,255,0.1)', borderRadius: 'var(--r-md)',
              padding: '6px 16px',
            }}>
              Delay: {tooltipDelay}ms
            </div>
            <Tooltip text="This tooltip respects the delay above" position="top" delay={tooltipDelay}>
              <GlassButton>Hover me</GlassButton>
            </Tooltip>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          5. Tooltip Specs
          ============================================================ */}
      <Section title="Tooltip Specs">
        <SpecTable
          headers={['Property', 'Value']}
          rows={[
            ['Max width', '240px (standard), 280px (rich)'],
            ['Padding', '8px 12px (standard), 12px 16px (rich)'],
            ['Border radius', 'var(--r-md) / 16px'],
            ['Arrow size', '6px'],
            ['Show delay', '600ms (default)'],
            ['Hide delay', '0ms (instant)'],
            ['Animation', 'scale 0.95 \u2192 1, 200ms spring'],
            ['Font', 'caption1 (standard), headline+body (rich)'],
          ]}
        />
      </Section>
    </div>
  )
}
