import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton, GlassInput, GlassSlider } from '../components/Glass'

function luminance(hex) {
  const r = parseInt(hex.slice(1, 3), 16) / 255
  const g = parseInt(hex.slice(3, 5), 16) / 255
  const b = parseInt(hex.slice(5, 7), 16) / 255
  const toLinear = (c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4)
  return 0.2126 * toLinear(r) + 0.7152 * toLinear(g) + 0.0722 * toLinear(b)
}

function contrastRatio(hex1, hex2) {
  const l1 = luminance(hex1)
  const l2 = luminance(hex2)
  const lighter = Math.max(l1, l2)
  const darker = Math.min(l1, l2)
  return (lighter + 0.05) / (darker + 0.05)
}

const wcagHeaders = ['Level', 'Normal Text', 'Large Text', 'UI Components']
const wcagRows = [
  ['A', 'No requirement', 'No requirement', 'No requirement'],
  ['AA', '4.5 : 1', '3 : 1', '3 : 1'],
  ['AAA', '7 : 1', '4.5 : 1', 'Not defined'],
]

const typeHeaders = ['Style', 'Size (pts)', 'Weight', 'Leading', 'Tracking']
const typeRows = [
  ['Large Title', '34', 'Bold (700)', '41pt', '0.37'],
  ['Title 1', '28', 'Bold (700)', '34pt', '0.36'],
  ['Title 2', '22', 'Bold (700)', '28pt', '0.35'],
  ['Title 3', '20', 'Semibold (600)', '25pt', '0.38'],
  ['Headline', '17', 'Semibold (600)', '22pt', '-0.41'],
  ['Body', '17', 'Regular (400)', '22pt', '-0.41'],
  ['Callout', '16', 'Regular (400)', '21pt', '-0.32'],
  ['Subheadline', '15', 'Regular (400)', '20pt', '-0.24'],
  ['Footnote', '13', 'Regular (400)', '18pt', '-0.08'],
  ['Caption 1', '12', 'Regular (400)', '16pt', '0'],
  ['Caption 2', '11', 'Regular (400)', '13pt', '0.07'],
]

const controlHeaders = ['Control', 'Min Size (pt)', 'Platform', 'Notes']
const controlRows = [
  ['Touch target', '44 x 44', 'iOS / iPadOS', 'Minimum tappable area, even if visual is smaller'],
  ['Pointer target', '28 x 28', 'macOS', 'Mouse provides more precision than touch'],
  ['Tab bar item', '66 x 48', 'iOS', 'Bottom tab bar icons and labels'],
  ['Navigation bar', '44 x 60', 'iOS', 'Standard navigation bar height with title'],
]

const voiceOverPractices = [
  { title: 'Label Everything', desc: 'Every interactive element needs an accessibility label. If a button has only an icon, add an accessibilityLabel describing the action.' },
  { title: 'Group Related Content', desc: 'Use accessibility containers to group related elements. A card with title, subtitle, and action should be one focusable unit.' },
  { title: 'Announce Changes', desc: 'Post UIAccessibility.Notification.announcement for dynamic content changes that VoiceOver users cannot see.' },
  { title: 'Meaningful Order', desc: 'Ensure the reading order matches the visual layout. Use accessibilityElements to override default top-to-bottom ordering.' },
]

export default function Accessibility() {
  const [fg, setFg] = useState('#000000')
  const [bg, setBg] = useState('#ffffff')
  const [previewSize, setPreviewSize] = useState(17)
  const [focusDemo, setFocusDemo] = useState(0)

  const ratio = contrastRatio(fg, bg)
  const passAA = ratio >= 4.5
  const passAALarge = ratio >= 3
  const passAAA = ratio >= 7

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Accessibility</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Inclusive design guidelines covering contrast, type scaling, control sizing, and assistive technology.
      </p>

      {/* Contrast Ratios */}
      <Section title="Contrast Ratios" description="Interactive contrast checker and WCAG 2.1 requirements.">
        <Preview>
          <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap', alignItems: 'flex-start' }}>
            <div style={{ flex: '1 1 240px' }}>
              <div style={{ display: 'flex', gap: 16, marginBottom: 16 }}>
                <label style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>
                  <div style={{ marginBottom: 4 }}>Foreground</div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <input type="color" value={fg} onChange={(e) => setFg(e.target.value)} style={{ width: 40, height: 32, border: 'none', borderRadius: 'var(--r-xs)', cursor: 'pointer' }} />
                    <span style={{ fontFamily: 'var(--font-mono)', fontSize: 13 }}>{fg}</span>
                  </div>
                </label>
                <label style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>
                  <div style={{ marginBottom: 4 }}>Background</div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <input type="color" value={bg} onChange={(e) => setBg(e.target.value)} style={{ width: 40, height: 32, border: 'none', borderRadius: 'var(--r-xs)', cursor: 'pointer' }} />
                    <span style={{ fontFamily: 'var(--font-mono)', fontSize: 13 }}>{bg}</span>
                  </div>
                </label>
              </div>
              <div style={{
                background: bg,
                borderRadius: 'var(--r-lg)',
                padding: 20,
                marginBottom: 16,
                border: '0.5px solid var(--separator)',
              }}>
                <div style={{ color: fg, fontSize: 24, fontWeight: 700, marginBottom: 4 }}>Sample Text</div>
                <div style={{ color: fg, fontSize: 17 }}>Body text for readability testing</div>
              </div>
            </div>
            <div style={{ flex: '0 0 auto', textAlign: 'center' }}>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)', marginBottom: 4 }}>Contrast Ratio</div>
              <div style={{
                font: 'var(--text-large-title)',
                color: 'var(--label)',
                marginBottom: 12,
              }}>
                {ratio.toFixed(2)} : 1
              </div>
              <div style={{ display: 'flex', gap: 8, justifyContent: 'center', flexWrap: 'wrap' }}>
                <span style={{
                  padding: '4px 12px',
                  borderRadius: 'var(--r-pill)',
                  fontSize: 13,
                  fontWeight: 600,
                  background: passAA ? 'var(--green)' : 'var(--red)',
                  color: '#fff',
                }}>AA {passAA ? 'Pass' : 'Fail'}</span>
                <span style={{
                  padding: '4px 12px',
                  borderRadius: 'var(--r-pill)',
                  fontSize: 13,
                  fontWeight: 600,
                  background: passAALarge ? 'var(--green)' : 'var(--red)',
                  color: '#fff',
                }}>AA Large {passAALarge ? 'Pass' : 'Fail'}</span>
                <span style={{
                  padding: '4px 12px',
                  borderRadius: 'var(--r-pill)',
                  fontSize: 13,
                  fontWeight: 600,
                  background: passAAA ? 'var(--green)' : 'var(--red)',
                  color: '#fff',
                }}>AAA {passAAA ? 'Pass' : 'Fail'}</span>
              </div>
            </div>
          </div>
        </Preview>
        <SpecTable headers={wcagHeaders} rows={wcagRows} />
      </Section>

      {/* Dynamic Type */}
      <Section title="Dynamic Type" description="All 11 text styles with their specifications. Use the slider to preview scaling.">
        <Preview>
          <div style={{ marginBottom: 16, display: 'flex', alignItems: 'center', gap: 12 }}>
            <span style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)', whiteSpace: 'nowrap' }}>Preview size</span>
            <GlassSlider min={11} max={40} value={previewSize} onChange={(e) => setPreviewSize(Number(e.target.value))} style={{ flex: 1 }} />
            <span style={{ fontFamily: 'var(--font-mono)', fontSize: 13, color: 'var(--label)', minWidth: 36 }}>{previewSize}pt</span>
          </div>
          <div style={{
            background: 'var(--fill-tertiary)',
            borderRadius: 'var(--r-lg)',
            padding: 20,
            marginBottom: 8,
          }}>
            <span style={{ fontSize: previewSize, fontWeight: 600, color: 'var(--label)' }}>
              The quick brown fox jumps over the lazy dog
            </span>
          </div>
        </Preview>
        <SpecTable headers={typeHeaders} rows={typeRows} />
      </Section>

      {/* Min Control Sizes */}
      <Section title="Minimum Control Sizes" description="Platform-specific minimum touch and pointer target sizes.">
        <Preview>
          <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap', justifyContent: 'center', alignItems: 'end' }}>
            {[
              { label: 'Touch Target', size: 44, color: 'var(--blue)' },
              { label: 'Pointer Target', size: 28, color: 'var(--indigo)' },
              { label: 'Tab Bar Item', w: 66, h: 48, color: 'var(--teal)' },
              { label: 'Nav Bar', w: 44, h: 60, color: 'var(--purple)' },
            ].map((c) => (
              <div key={c.label} style={{ textAlign: 'center' }}>
                <div style={{
                  width: c.w || c.size,
                  height: c.h || c.size,
                  borderRadius: 'var(--r-sm)',
                  background: c.color,
                  opacity: 0.25,
                  border: `2px dashed ${c.color}`,
                  margin: '0 auto 8px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}>
                  <span style={{ fontSize: 11, fontWeight: 600, color: c.color }}>{c.w ? `${c.w}x${c.h}` : `${c.size}x${c.size}`}</span>
                </div>
                <div style={{ font: 'var(--text-caption1)', fontWeight: 500, color: 'var(--label)' }}>{c.label}</div>
              </div>
            ))}
          </div>
        </Preview>
        <SpecTable headers={controlHeaders} rows={controlRows} />
      </Section>

      {/* VoiceOver */}
      <Section title="VoiceOver Best Practices" description="Guidelines for building great VoiceOver experiences.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          {voiceOverPractices.map((p) => (
            <GlassCard key={p.title}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>{p.title}</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>{p.desc}</div>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* Focus Indicators */}
      <Section title="Focus Indicators" description="Visible focus rings for keyboard and switch control navigation.">
        <Preview>
          <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap', alignItems: 'center' }}>
            {['Default', 'Focused', 'Active'].map((state, i) => (
              <GlassButton
                key={state}
                variant="glass"
                onClick={() => setFocusDemo(i)}
                style={{
                  outline: i === 1 ? '3px solid var(--blue)' : i === focusDemo && focusDemo === 1 ? '3px solid var(--blue)' : 'none',
                  outlineOffset: i === 1 ? '2px' : undefined,
                  opacity: i === 2 ? 0.7 : 1,
                  transform: i === 2 ? 'scale(0.97)' : 'none',
                }}
              >
                {state}
              </GlassButton>
            ))}
          </div>
          <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)', marginTop: 12 }}>
            Focus indicators must be at least 2px wide and have a 3:1 contrast ratio against adjacent colors.
            The system default is a blue ring with 2px offset.
          </div>
        </Preview>
      </Section>

      {/* Reduced Motion */}
      <Section title="Reduced Motion" description="Always honor the user's motion preferences.">
        <GlassCard>
          <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 8 }}>Key Considerations</div>
          <ul style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', paddingLeft: 20, margin: 0, lineHeight: 1.6 }}>
            <li>Check UIAccessibility.isReduceMotionEnabled before animating</li>
            <li>Replace slide transitions with cross-dissolve</li>
            <li>Disable parallax, bouncing, and auto-playing animations</li>
            <li>Opacity transitions are acceptable (non-vestibular)</li>
          </ul>
        </GlassCard>
        <div style={{ marginTop: 16 }}>
          <GlassPanel>
            <div style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', marginBottom: 8 }}>SwiftUI Implementation</div>
            <pre style={{
              fontFamily: 'var(--font-mono)',
              fontSize: 13,
              lineHeight: 1.6,
              color: 'var(--label)',
              margin: 0,
              whiteSpace: 'pre-wrap',
              wordBreak: 'break-word',
            }}>
              <code>{`@Environment(\\.accessibilityReduceMotion)
var reduceMotion: Bool

withAnimation(reduceMotion ? .none : .spring()) {
    isExpanded.toggle()
}`}</code>
            </pre>
          </GlassPanel>
        </div>
      </Section>

      {/* Captions & Subtitles */}
      <Section title="Captions & Subtitles" description="Ensure all media content is accessible to deaf and hard-of-hearing users.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16, marginBottom: 16 }}>
          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Closed Captions</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>Provide closed captions for all video content. Captions must be accurate, synchronized, and include speaker identification.</div>
          </GlassCard>
          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>SDH Subtitles</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>Use SDH (Subtitles for the Deaf and Hard of Hearing) when possible. SDH includes sound effects and music descriptions beyond dialogue.</div>
          </GlassCard>
          <GlassCard>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Audio Descriptions</div>
            <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>Support audio descriptions for visual content. Narrate key visual elements during natural pauses in dialogue.</div>
          </GlassCard>
        </div>

        {/* Mock video player */}
        <Preview>
          <div style={{ maxWidth: 400, margin: '0 auto' }}>
            <div style={{
              background: '#000',
              borderRadius: 'var(--r-lg)',
              overflow: 'hidden',
              position: 'relative',
            }}>
              {/* Video area */}
              <div style={{
                height: 200,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                background: 'linear-gradient(135deg, #1a1a2e, #16213e)',
              }}>
                <span style={{ color: 'rgba(255,255,255,0.3)', font: 'var(--text-title3)' }}>Video Content</span>
              </div>
              {/* Caption bar */}
              <div style={{
                position: 'absolute',
                bottom: 44,
                left: 0,
                right: 0,
                textAlign: 'center',
                padding: '4px 16px',
              }}>
                <span style={{
                  background: 'rgba(0,0,0,0.75)',
                  color: '#fff',
                  padding: '2px 8px',
                  borderRadius: 4,
                  font: 'var(--text-footnote)',
                }}>[Speaker] This is an example of closed captions.</span>
              </div>
              {/* Controls bar */}
              <div style={{
                height: 40,
                background: 'rgba(0,0,0,0.6)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '0 12px',
              }}>
                <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
                  <span style={{ color: '#fff', fontSize: 14 }}>&#9654;</span>
                  <span style={{ color: 'rgba(255,255,255,0.6)', font: 'var(--text-caption2)' }}>0:42 / 3:15</span>
                </div>
                <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
                  <span style={{
                    color: '#fff',
                    font: 'var(--text-caption1)',
                    fontWeight: 700,
                    padding: '2px 6px',
                    borderRadius: 4,
                    background: 'var(--blue)',
                  }}>CC</span>
                  <span style={{ color: '#fff', fontSize: 14 }}>&#9974;</span>
                </div>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* Motor Accessibility */}
      <Section title="Motor Accessibility" description="Support users who navigate with alternative input methods.">
        <SpecTable
          headers={['Feature', 'Purpose', 'Implementation']}
          rows={[
            ['Switch Control', 'Navigate with switches', 'All elements focusable'],
            ['AssistiveTouch', 'On-screen controls', 'Support all gestures'],
            ['Full Keyboard Access', 'Navigate without touch', 'Tab order, arrow keys'],
            ['Dwell Control', 'Select by hovering', 'Adequate dwell time'],
            ['Voice Control', 'Control by voice', 'Label all elements'],
          ]}
        />
      </Section>
    </div>
  )
}
