import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

const easings = [
  { name: 'Linear', css: 'linear', desc: 'Constant speed' },
  { name: 'Ease Out', css: 'cubic-bezier(0.25, 0.1, 0.25, 1)', desc: 'Decelerating' },
  { name: 'Ease In', css: 'cubic-bezier(0.42, 0, 1, 1)', desc: 'Accelerating' },
  { name: 'Ease In-Out', css: 'cubic-bezier(0.42, 0, 0.58, 1)', desc: 'Symmetric' },
]

const durations = [
  { name: 'Micro', ms: 100, token: '--dur-micro' },
  { name: 'Fast', ms: 200, token: '--dur-fast' },
  { name: 'Normal', ms: 300, token: '--dur' },
  { name: 'Slow', ms: 500, token: '--dur-slow' },
]

const hapticHeaders = ['Category', 'Type', 'Use Case']
const hapticRows = [
  ['Notification', 'Success', 'Completed action, payment confirmed'],
  ['Notification', 'Warning', 'Caution state, destructive action pending'],
  ['Notification', 'Error', 'Failed action, invalid input'],
  ['Impact', 'Light', 'Subtle UI interactions, toggle switches'],
  ['Impact', 'Medium', 'Button presses, picker selections'],
  ['Impact', 'Heavy', 'Significant state changes, drag drop'],
  ['Selection', 'Changed', 'Scrolling through picker items'],
]

export default function Motion() {
  const [playing, setPlaying] = useState(false)
  const [clicked, setClicked] = useState({})
  const [staggerPlaying, setStaggerPlaying] = useState(false)
  const [heroExpanded, setHeroExpanded] = useState(false)

  const handlePlay = () => {
    setPlaying(false)
    requestAnimationFrame(() => {
      requestAnimationFrame(() => setPlaying(true))
    })
  }

  const handleDurationClick = (name) => {
    setClicked((prev) => ({ ...prev, [name]: true }))
    setTimeout(() => {
      setClicked((prev) => ({ ...prev, [name]: false }))
    }, 600)
  }

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Motion</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Animation principles, easing curves, duration scales, and haptic feedback patterns.
      </p>

      {/* Animation Principles */}
      <Section title="Animation Principles" description="Four pillars that guide all motion in the system.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))', gap: 16 }}>
          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Purposeful</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Every animation must serve a clear functional purpose -- guiding attention, showing relationships, or confirming actions.
            </div>
          </GlassCard>
          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Brief</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Animations should feel instantaneous. Users should never wait for an animation to complete before they can act.
            </div>
          </GlassCard>
          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Precise</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Motion should be physically plausible. Use spring curves and momentum-based timing for natural feel.
            </div>
          </GlassCard>
          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Optional</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
              Always respect Reduce Motion preferences. Provide equivalent non-animated alternatives for all transitions.
            </div>
          </GlassCard>
        </div>
      </Section>

      {/* Easing Curves */}
      <Section title="Easing Curves" description="Standard timing functions for different animation contexts.">
        <Preview>
          <div style={{ marginBottom: 16 }}>
            <GlassButton onClick={handlePlay} variant="filled" size="sm">
              Play Animation
            </GlassButton>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {easings.map((e) => (
              <div key={e.name} style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
                <div style={{ width: 100, font: 'var(--text-caption1)', color: 'var(--label-secondary)', flexShrink: 0 }}>
                  <div style={{ fontWeight: 600, color: 'var(--label)' }}>{e.name}</div>
                  <div>{e.desc}</div>
                </div>
                <div style={{ flex: 1, height: 40, background: 'var(--fill-tertiary)', borderRadius: 'var(--r-sm)', position: 'relative', overflow: 'hidden' }}>
                  <div
                    style={{
                      width: 36,
                      height: 36,
                      borderRadius: 'var(--r-sm)',
                      background: 'var(--blue)',
                      position: 'absolute',
                      top: 2,
                      left: playing ? 'calc(100% - 38px)' : '2px',
                      transition: playing ? `left 1s ${e.css}` : 'none',
                    }}
                  />
                </div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* Duration Scale */}
      <Section title="Duration Scale" description="Click each box to see its duration. Scale from micro interactions to slow transitions.">
        <Preview>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 20 }}>
            {durations.map((d) => (
              <div key={d.name} style={{ textAlign: 'center' }}>
                <div
                  onClick={() => handleDurationClick(d.name)}
                  style={{
                    width: 80,
                    height: 80,
                    borderRadius: 'var(--r-lg)',
                    background: 'var(--glass-bg)',
                    backdropFilter: 'blur(var(--blur-md))',
                    WebkitBackdropFilter: 'blur(var(--blur-md))',
                    border: '0.5px solid var(--glass-border)',
                    boxShadow: 'var(--glass-shadow)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    cursor: 'pointer',
                    margin: '0 auto 8px',
                    transform: clicked[d.name] ? 'scale(1.25)' : 'scale(1)',
                    transition: `transform ${d.ms}ms var(--ease)`,
                  }}
                >
                  <span style={{ font: 'var(--text-title3)', color: 'var(--label)' }}>{d.ms}</span>
                </div>
                <div style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label)' }}>{d.name}</div>
                <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', fontFamily: 'var(--font-mono)' }}>{d.ms}ms</div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* Reduced Motion */}
      <Section title="Reduced Motion" description="Always provide an alternative experience when Reduce Motion is enabled.">
        <GlassCard>
          <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 8 }}>Guidelines</div>
          <ul style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', paddingLeft: 20, margin: 0, lineHeight: 1.6 }}>
            <li>Replace slide/zoom transitions with cross-dissolve</li>
            <li>Remove parallax and bouncing effects entirely</li>
            <li>Keep opacity animations -- they are non-vestibular</li>
            <li>Use instant layout changes instead of animated repositioning</li>
            <li>Test your app with Reduce Motion enabled on every release</li>
          </ul>
        </GlassCard>
        <div style={{ marginTop: 16 }}>
          <GlassPanel>
            <div style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', marginBottom: 8 }}>CSS Implementation</div>
            <pre style={{
              fontFamily: 'var(--font-mono)',
              fontSize: 13,
              lineHeight: 1.6,
              color: 'var(--label)',
              margin: 0,
              whiteSpace: 'pre-wrap',
              wordBreak: 'break-word',
            }}>
              <code>{`@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}`}</code>
            </pre>
          </GlassPanel>
        </div>
      </Section>

      {/* Haptic Types */}
      <Section title="Haptic Types" description="UIFeedbackGenerator categories and their appropriate usage.">
        <SpecTable headers={hapticHeaders} rows={hapticRows} />
      </Section>

      {/* Choreography */}
      <Section title="Choreography" description="Staggered animations create a sense of spatial hierarchy and draw attention sequentially.">
        <Preview>
          <div style={{ marginBottom: 16 }}>
            <GlassButton onClick={() => { setStaggerPlaying(false); requestAnimationFrame(() => requestAnimationFrame(() => setStaggerPlaying(true))) }} variant="filled" size="sm">
              Play Stagger
            </GlassButton>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(140px, 1fr))', gap: 12 }}>
            {[0, 1, 2, 3].map((i) => (
              <div
                key={i}
                style={{
                  opacity: staggerPlaying ? 1 : 0,
                  transform: staggerPlaying ? 'translateY(0)' : 'translateY(20px)',
                  transition: `opacity 400ms ease ${i * 100}ms, transform 400ms var(--ease-spring) ${i * 100}ms`,
                }}
              >
                <GlassCard>
                  <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 4 }}>Card {i + 1}</div>
                  <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>Delay: {i * 100}ms</div>
                </GlassCard>
              </div>
            ))}
          </div>
        </Preview>
        <GlassPanel style={{ marginTop: 8 }}>
          <div style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', marginBottom: 8 }}>CSS Implementation</div>
          <pre style={{
            fontFamily: 'var(--font-mono)',
            fontSize: 13,
            lineHeight: 1.6,
            color: 'var(--label)',
            margin: 0,
            whiteSpace: 'pre-wrap',
            wordBreak: 'break-word',
          }}>
            <code>{`.card { opacity: 0; transform: translateY(20px); }
.card.visible {
  opacity: 1; transform: translateY(0);
  transition: opacity 400ms ease, transform 400ms var(--ease-spring);
}
.card:nth-child(1) { transition-delay: 0ms; }
.card:nth-child(2) { transition-delay: 100ms; }
.card:nth-child(3) { transition-delay: 200ms; }
.card:nth-child(4) { transition-delay: 300ms; }`}</code>
          </pre>
        </GlassPanel>
      </Section>

      {/* Hero Transitions */}
      <Section title="Hero Transitions" description="Matched geometry transitions create visual continuity between states.">
        <Preview>
          <div style={{ marginBottom: 16 }}>
            <GlassButton onClick={() => setHeroExpanded(prev => !prev)} variant="filled" size="sm">
              {heroExpanded ? 'Show List View' : 'Show Detail View'}
            </GlassButton>
          </div>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <div
              style={{
                width: heroExpanded ? 360 : 140,
                height: heroExpanded ? 280 : 80,
                borderRadius: heroExpanded ? 'var(--r-xl)' : 'var(--r-sm)',
                background: 'linear-gradient(135deg, var(--blue), var(--purple))',
                boxShadow: 'var(--glass-shadow)',
                transition: 'width 500ms var(--ease-spring), height 500ms var(--ease-spring), border-radius 500ms var(--ease-spring)',
                display: 'flex',
                flexDirection: 'column',
                alignItems: heroExpanded ? 'flex-start' : 'center',
                justifyContent: heroExpanded ? 'flex-end' : 'center',
                padding: heroExpanded ? 24 : 8,
                overflow: 'hidden',
                cursor: 'pointer',
              }}
              onClick={() => setHeroExpanded(prev => !prev)}
            >
              {heroExpanded ? (
                <>
                  <div style={{ font: 'var(--text-title2)', color: '#fff', marginBottom: 4 }}>Mountain Vista</div>
                  <div style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.8)' }}>Detail view with full content and description area</div>
                </>
              ) : (
                <div style={{ font: 'var(--text-caption1)', color: '#fff', fontWeight: 600, textAlign: 'center' }}>Mountain Vista</div>
              )}
            </div>
          </div>
          <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)', marginTop: 12, textAlign: 'center' }}>
            {heroExpanded ? 'Detail view — click or toggle to collapse' : 'List view — click or toggle to expand'}
          </div>
        </Preview>
        <GlassCard style={{ marginTop: 8 }}>
          <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Matched Geometry Effect</div>
          <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
            In SwiftUI, use .matchedGeometryEffect(id:in:) to create shared element transitions. The system interpolates frame, corner radius, and opacity between the source and destination views. On the web, animate width, height, and border-radius with spring easing for a similar result.
          </div>
        </GlassCard>
      </Section>
    </div>
  )
}
