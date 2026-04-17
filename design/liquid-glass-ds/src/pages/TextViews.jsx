import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'

/* ────────────────────────────────────────────
   Helpers & Styles
   ──────────────────────────────────────────── */

const SPRING = 'all 300ms cubic-bezier(0.34, 1.56, 0.64, 1)'
const EASE_IO = 'all 200ms cubic-bezier(0.42, 0, 0.58, 1)'

const glassContainer = {
  background: 'var(--glass-bg)',
  backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
  WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
  border: '0.5px solid var(--glass-border)',
  borderRadius: 'var(--r-xl)',
  boxShadow: 'var(--glass-shadow), var(--glass-specular)',
  padding: 20,
}

const glassTextarea = {
  width: '100%',
  boxSizing: 'border-box',
  minHeight: 120,
  padding: 16,
  background: 'var(--glass-inner)',
  backdropFilter: 'blur(var(--blur-sm))',
  WebkitBackdropFilter: 'blur(var(--blur-sm))',
  border: '0.5px solid var(--glass-border)',
  borderRadius: 'var(--r-lg)',
  font: 'var(--text-body)',
  color: 'var(--label)',
  resize: 'vertical',
  outline: 'none',
  transition: EASE_IO,
}

const SAMPLE_TEXT = 'The Liquid Glass design system brings translucent, light-refracting surfaces to every UI element. Built for iOS 26 and macOS Tahoe, it creates depth through blur, refraction, and specular highlights rather than opaque fills.'

const SAMPLE_MARKDOWN = `# Liquid Glass

The design system uses **translucent materials** with *real-time blur* to create depth.

## Key Features

- Backdrop blur with saturation boost
- Specular highlights on top edges
- Spring-based transitions
- [Learn more](https://developer.apple.com)

> Glass is not flat. It refracts, reflects, and reveals what lies beneath.

Inline code uses \`var(--glass-bg)\` for the background token.

\`\`\`css
.glass {
  backdrop-filter: blur(48px);
  background: rgba(255,255,255,0.45);
}
\`\`\``


/* ════════════════════════════════════════════
   Main Page Component
   ════════════════════════════════════════════ */

export default function TextViews() {
  const [editorText, setEditorText] = useState('')
  const [filledText, setFilledText] = useState(SAMPLE_TEXT)
  const [limitText, setLimitText] = useState('')
  const [markdownSource, setMarkdownSource] = useState(SAMPLE_MARKDOWN)
  const CHARACTER_LIMIT = 280

  /* Simple markdown to JSX renderer */
  function renderMarkdown(src) {
    const lines = src.split('\n')
    const elements = []
    let inCodeBlock = false
    let codeLines = []
    let inList = false
    let listItems = []

    function flushList() {
      if (listItems.length > 0) {
        elements.push(
          <ul key={`ul-${elements.length}`} style={{ margin: '12px 0', paddingLeft: 24, color: 'var(--label)' }}>
            {listItems.map((item, i) => (
              <li key={i} style={{ font: 'var(--text-body)', marginBottom: 4, color: 'var(--label)' }}>{item}</li>
            ))}
          </ul>
        )
        listItems = []
        inList = false
      }
    }

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]

      // Code block toggle
      if (line.startsWith('```')) {
        if (inCodeBlock) {
          elements.push(
            <pre key={`code-${i}`} style={{
              background: 'var(--fill-tertiary)',
              borderRadius: 'var(--r-sm)',
              padding: 16,
              overflowX: 'auto',
              margin: '12px 0',
              font: '400 14px/20px var(--font-mono)',
              color: 'var(--label)',
              border: '0.5px solid var(--separator)',
            }}>
              <code>{codeLines.join('\n')}</code>
            </pre>
          )
          codeLines = []
          inCodeBlock = false
        } else {
          flushList()
          inCodeBlock = true
        }
        continue
      }
      if (inCodeBlock) {
        codeLines.push(line)
        continue
      }

      // List items
      if (line.startsWith('- ')) {
        inList = true
        listItems.push(processInline(line.slice(2)))
        continue
      } else {
        flushList()
      }

      // Headings
      if (line.startsWith('## ')) {
        elements.push(
          <h3 key={`h3-${i}`} style={{ font: 'var(--text-title3)', color: 'var(--label)', margin: '20px 0 8px' }}>
            {line.slice(3)}
          </h3>
        )
        continue
      }
      if (line.startsWith('# ')) {
        elements.push(
          <h2 key={`h2-${i}`} style={{ font: 'var(--text-title2)', color: 'var(--label)', margin: '0 0 12px' }}>
            {line.slice(2)}
          </h2>
        )
        continue
      }

      // Blockquote
      if (line.startsWith('> ')) {
        elements.push(
          <blockquote key={`bq-${i}`} style={{
            borderLeft: '3px solid var(--blue)',
            paddingLeft: 16,
            margin: '12px 0',
            fontStyle: 'italic',
            color: 'var(--label-secondary)',
            font: 'var(--text-body)',
          }}>
            {processInline(line.slice(2))}
          </blockquote>
        )
        continue
      }

      // Empty line
      if (line.trim() === '') {
        continue
      }

      // Normal paragraph
      elements.push(
        <p key={`p-${i}`} style={{ font: 'var(--text-body)', color: 'var(--label)', margin: '8px 0', lineHeight: 1.5 }}>
          {processInline(line)}
        </p>
      )
    }
    flushList()
    return elements
  }

  /* Process inline markdown (bold, italic, code, links) */
  function processInline(text) {
    // Process in order: code, links, bold, italic
    const parts = []
    let remaining = text
    let keyIdx = 0

    // Combined regex for inline patterns
    const regex = /(`[^`]+`)|(\[([^\]]+)\]\(([^)]+)\))|(\*\*([^*]+)\*\*)|(\*([^*]+)\*)/g
    let lastIndex = 0
    let match

    while ((match = regex.exec(remaining)) !== null) {
      // Text before this match
      if (match.index > lastIndex) {
        parts.push(remaining.slice(lastIndex, match.index))
      }

      if (match[1]) {
        // Inline code
        parts.push(
          <code key={`ic-${keyIdx++}`} style={{
            background: 'var(--fill)',
            padding: '2px 6px',
            borderRadius: 5,
            fontFamily: 'var(--font-mono)',
            fontSize: 15,
            color: 'var(--label)',
          }}>
            {match[1].slice(1, -1)}
          </code>
        )
      } else if (match[2]) {
        // Link
        parts.push(
          <a key={`a-${keyIdx++}`} href={match[4]} style={{
            color: 'var(--blue)',
            textDecoration: 'none',
            borderBottom: '1px solid transparent',
            transition: EASE_IO,
          }}
          onMouseEnter={e => e.currentTarget.style.borderBottomColor = 'var(--blue)'}
          onMouseLeave={e => e.currentTarget.style.borderBottomColor = 'transparent'}
          >
            {match[3]}
          </a>
        )
      } else if (match[5]) {
        // Bold
        parts.push(<strong key={`b-${keyIdx++}`} style={{ fontWeight: 600 }}>{match[6]}</strong>)
      } else if (match[7]) {
        // Italic
        parts.push(<em key={`i-${keyIdx++}`}>{match[8]}</em>)
      }

      lastIndex = match.index + match[0].length
    }

    if (lastIndex < remaining.length) {
      parts.push(remaining.slice(lastIndex))
    }

    return parts.length > 0 ? parts : text
  }

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Text Views</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Text editing and display components with Liquid Glass materials. From multi-line editors to rich text display, all using translucent surfaces with proper focus states and typography.
      </p>

      {/* ──────────────────────────────────────
          1. Multi-line Text Editor
          ────────────────────────────────────── */}
      <Section title="Multi-line Text Editor" description="Glass-styled textarea with character count, focus glow, and resize support. The blue ring appears on focus.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 20, flexWrap: 'wrap' }}>
            {/* Empty editor */}
            <div style={{ flex: '1 1 280px', minWidth: 280 }}>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8, fontWeight: 500 }}>EMPTY</div>
              <div style={{ position: 'relative' }}>
                <textarea
                  value={editorText}
                  onChange={e => setEditorText(e.target.value)}
                  placeholder="Enter your notes..."
                  style={glassTextarea}
                  onFocus={e => {
                    e.currentTarget.style.border = '1.5px solid var(--blue)'
                    e.currentTarget.style.boxShadow = '0 0 0 3px rgba(0, 122, 255, 0.18)'
                  }}
                  onBlur={e => {
                    e.currentTarget.style.border = '0.5px solid var(--glass-border)'
                    e.currentTarget.style.boxShadow = 'none'
                  }}
                />
                <span style={{
                  position: 'absolute',
                  bottom: 10,
                  right: 14,
                  font: 'var(--text-caption1)',
                  color: 'var(--label-tertiary)',
                }}>
                  {editorText.length}
                </span>
              </div>
            </div>

            {/* Filled editor */}
            <div style={{ flex: '1 1 280px', minWidth: 280 }}>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8, fontWeight: 500 }}>FILLED</div>
              <div style={{ position: 'relative' }}>
                <textarea
                  value={filledText}
                  onChange={e => setFilledText(e.target.value)}
                  style={glassTextarea}
                  onFocus={e => {
                    e.currentTarget.style.border = '1.5px solid var(--blue)'
                    e.currentTarget.style.boxShadow = '0 0 0 3px rgba(0, 122, 255, 0.18)'
                  }}
                  onBlur={e => {
                    e.currentTarget.style.border = '0.5px solid var(--glass-border)'
                    e.currentTarget.style.boxShadow = 'none'
                  }}
                />
                <span style={{
                  position: 'absolute',
                  bottom: 10,
                  right: 14,
                  font: 'var(--text-caption1)',
                  color: 'var(--label-tertiary)',
                }}>
                  {filledText.length}
                </span>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ──────────────────────────────────────
          2. Text Area Variants
          ────────────────────────────────────── */}
      <Section title="Text Area Variants" description="All visual states of the glass text editor: default, filled, focused, disabled, error, and character-limited.">
        <Preview gradient>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))', gap: 16 }}>
            {/* Default */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 6, fontWeight: 500 }}>DEFAULT</div>
              <textarea
                readOnly
                placeholder="Enter your notes..."
                style={{ ...glassTextarea, minHeight: 80 }}
              />
            </div>

            {/* Filled */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 6, fontWeight: 500 }}>FILLED</div>
              <textarea
                readOnly
                value="The quick brown fox jumps over the lazy dog."
                style={{ ...glassTextarea, minHeight: 80 }}
              />
            </div>

            {/* Focused */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 6, fontWeight: 500 }}>FOCUSED</div>
              <textarea
                readOnly
                value="Typing here..."
                style={{
                  ...glassTextarea,
                  minHeight: 80,
                  border: '1.5px solid var(--blue)',
                  boxShadow: '0 0 0 3px rgba(0, 122, 255, 0.18)',
                }}
              />
            </div>

            {/* Disabled */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 6, fontWeight: 500 }}>DISABLED</div>
              <textarea
                disabled
                value="This field is disabled"
                style={{ ...glassTextarea, minHeight: 80, opacity: 0.35, cursor: 'not-allowed' }}
              />
            </div>

            {/* Error */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 6, fontWeight: 500 }}>ERROR</div>
              <textarea
                readOnly
                value="Invalid input"
                style={{
                  ...glassTextarea,
                  minHeight: 80,
                  border: '1.5px solid var(--red)',
                  boxShadow: '0 0 0 3px rgba(255, 59, 48, 0.15)',
                }}
              />
              <div style={{ font: 'var(--text-caption1)', color: 'var(--red)', marginTop: 4 }}>
                This field contains an error. Please check your input.
              </div>
            </div>

            {/* With character limit */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 6, fontWeight: 500 }}>CHARACTER LIMIT</div>
              <div style={{ position: 'relative' }}>
                <textarea
                  value={limitText}
                  onChange={e => {
                    if (e.target.value.length <= CHARACTER_LIMIT) {
                      setLimitText(e.target.value)
                    }
                  }}
                  placeholder="Limited to 280 characters..."
                  style={{
                    ...glassTextarea,
                    minHeight: 80,
                    border: limitText.length >= CHARACTER_LIMIT ? '1.5px solid var(--orange)' : '0.5px solid var(--glass-border)',
                  }}
                  onFocus={e => {
                    if (limitText.length < CHARACTER_LIMIT) {
                      e.currentTarget.style.border = '1.5px solid var(--blue)'
                      e.currentTarget.style.boxShadow = '0 0 0 3px rgba(0, 122, 255, 0.18)'
                    }
                  }}
                  onBlur={e => {
                    e.currentTarget.style.border = limitText.length >= CHARACTER_LIMIT ? '1.5px solid var(--orange)' : '0.5px solid var(--glass-border)'
                    e.currentTarget.style.boxShadow = 'none'
                  }}
                />
                <span style={{
                  position: 'absolute',
                  bottom: 10,
                  right: 14,
                  font: 'var(--text-caption1)',
                  color: limitText.length >= CHARACTER_LIMIT ? 'var(--orange)' : 'var(--label-tertiary)',
                  fontWeight: limitText.length >= CHARACTER_LIMIT * 0.9 ? 600 : 400,
                }}>
                  {limitText.length}/{CHARACTER_LIMIT}
                </span>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ──────────────────────────────────────
          3. Rich Text Display
          ────────────────────────────────────── */}
      <Section title="Rich Text Display" description="A glass panel demonstrating rendered rich text with headings, emphasis, links, lists, code spans, and blockquotes.">
        <Preview gradient>
          <div style={{ ...glassContainer, maxWidth: 600 }}>
            <h2 style={{ font: 'var(--text-title2)', color: 'var(--label)', margin: '0 0 12px' }}>
              Introducing Liquid Glass
            </h2>

            <p style={{ font: 'var(--text-body)', color: 'var(--label)', lineHeight: 1.6, margin: '0 0 12px' }}>
              The Liquid Glass design language transforms every surface into a <strong style={{ fontWeight: 600 }}>translucent, light-refracting material</strong> that reveals the content beneath it. Introduced with <em>iOS 26</em> and <em>macOS Tahoe</em>, it replaces opaque backgrounds with living, breathing glass.
            </p>

            <p style={{ font: 'var(--text-body)', color: 'var(--label)', lineHeight: 1.6, margin: '0 0 16px' }}>
              Read the full specification on the{' '}
              <a href="#" style={{ color: 'var(--blue)', textDecoration: 'none', borderBottom: '1px solid transparent', transition: EASE_IO }}
                onMouseEnter={e => e.currentTarget.style.borderBottomColor = 'var(--blue)'}
                onMouseLeave={e => e.currentTarget.style.borderBottomColor = 'transparent'}
              >
                Apple Human Interface Guidelines
              </a>.
            </p>

            <h3 style={{ font: 'var(--text-title3)', color: 'var(--label)', margin: '0 0 8px' }}>
              Core Principles
            </h3>

            <ul style={{ margin: '0 0 16px', paddingLeft: 24, color: 'var(--label)' }}>
              <li style={{ font: 'var(--text-body)', marginBottom: 6 }}>Heavy backdrop blur (48px+) with saturation boost</li>
              <li style={{ font: 'var(--text-body)', marginBottom: 6 }}>Specular highlights along the top edge</li>
              <li style={{ font: 'var(--text-body)', marginBottom: 6 }}>Spring-based animations for organic movement</li>
              <li style={{ font: 'var(--text-body)', marginBottom: 6 }}>Layered depth through nested glass surfaces</li>
            </ul>

            <p style={{ font: 'var(--text-body)', color: 'var(--label)', lineHeight: 1.6, margin: '0 0 16px' }}>
              Use the{' '}
              <code style={{
                background: 'var(--fill)',
                padding: '2px 6px',
                borderRadius: 5,
                fontFamily: 'var(--font-mono)',
                fontSize: 15,
                color: 'var(--label)',
              }}>backdrop-filter</code>{' '}
              CSS property along with{' '}
              <code style={{
                background: 'var(--fill)',
                padding: '2px 6px',
                borderRadius: 5,
                fontFamily: 'var(--font-mono)',
                fontSize: 15,
                color: 'var(--label)',
              }}>saturate(180%)</code>{' '}
              to achieve the characteristic glass effect.
            </p>

            <blockquote style={{
              borderLeft: '3px solid var(--blue)',
              paddingLeft: 16,
              margin: '0 0 0',
              fontStyle: 'italic',
              color: 'var(--label-secondary)',
              font: 'var(--text-body)',
              lineHeight: 1.6,
            }}>
              Glass is not flat. It refracts, reflects, and reveals what lies beneath  creating interfaces that feel alive and connected to their environment.
            </blockquote>
          </div>
        </Preview>
      </Section>

      {/* ──────────────────────────────────────
          4. Attributed Text Styles
          ────────────────────────────────────── */}
      <Section title="Attributed Text Styles" description="Reference table for text style tokens used throughout the design system.">
        <SpecTable
          headers={['Style', 'Font', 'Weight', 'Color', 'Usage']}
          rows={[
            ['Heading',  'System 22px', 'Bold (700)',     '--label',           'Section titles'],
            ['Body',     'System 17px', 'Regular (400)',  '--label',           'Main content'],
            ['Bold',     'System 17px', 'Semibold (600)', '--label',           'Emphasis'],
            ['Italic',   'System 17px (italic)', 'Regular (400)', '--label',  'Names, titles'],
            ['Link',     'System 17px', 'Regular (400)',  '--blue',            'Interactive text'],
            ['Code',     'Mono 15px',   'Regular (400)',  '--label',           'Inline code'],
            ['Caption',  'System 12px', 'Regular (400)',  '--label-secondary', 'Annotations'],
          ]}
        />

        {/* Visual examples of each style */}
        <Preview style={{ marginTop: 8 }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 16 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', width: 70, flexShrink: 0 }}>Heading</span>
              <span style={{ font: 'var(--text-title2)', color: 'var(--label)' }}>Section Title</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 16 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', width: 70, flexShrink: 0 }}>Body</span>
              <span style={{ font: 'var(--text-body)', color: 'var(--label)' }}>The quick brown fox jumps over the lazy dog.</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 16 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', width: 70, flexShrink: 0 }}>Bold</span>
              <span style={{ font: 'var(--text-body)', fontWeight: 600, color: 'var(--label)' }}>Emphasized content stands out.</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 16 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', width: 70, flexShrink: 0 }}>Italic</span>
              <span style={{ font: 'var(--text-body)', fontStyle: 'italic', color: 'var(--label)' }}>Names, titles, and references.</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 16 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', width: 70, flexShrink: 0 }}>Link</span>
              <a href="#" style={{ font: 'var(--text-body)', color: 'var(--blue)', textDecoration: 'none', borderBottom: '1px solid transparent', transition: EASE_IO }}
                onMouseEnter={e => e.currentTarget.style.borderBottomColor = 'var(--blue)'}
                onMouseLeave={e => e.currentTarget.style.borderBottomColor = 'transparent'}
              >Tap to navigate</a>
            </div>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 16 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', width: 70, flexShrink: 0 }}>Code</span>
              <code style={{ fontFamily: 'var(--font-mono)', fontSize: 15, background: 'var(--fill)', padding: '2px 6px', borderRadius: 5, color: 'var(--label)' }}>backdrop-filter: blur(48px)</code>
            </div>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 16 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', width: 70, flexShrink: 0 }}>Caption</span>
              <span style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>Figure 1 - Glass material layers</span>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ──────────────────────────────────────
          5. Markdown Preview
          ────────────────────────────────────── */}
      <Section title="Markdown Preview" description="Side-by-side: raw markdown source on the left, rendered HTML output on the right. Both panels use glass materials.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
            {/* Source panel */}
            <div style={{ flex: '1 1 300px', minWidth: 280 }}>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8, fontWeight: 500, display: 'flex', alignItems: 'center', gap: 6 }}>
                <svg width="14" height="14" viewBox="0 0 14 14" fill="rgba(255,255,255,0.5)">
                  <rect x="1" y="2" width="12" height="10" rx="1.5" fill="none" stroke="currentColor" strokeWidth="1.2"/>
                  <line x1="4" y1="5" x2="10" y2="5" stroke="currentColor" strokeWidth="1" strokeLinecap="round"/>
                  <line x1="4" y1="7.5" x2="8" y2="7.5" stroke="currentColor" strokeWidth="1" strokeLinecap="round"/>
                  <line x1="4" y1="10" x2="9" y2="10" stroke="currentColor" strokeWidth="1" strokeLinecap="round"/>
                </svg>
                SOURCE
              </div>
              <textarea
                value={markdownSource}
                onChange={e => setMarkdownSource(e.target.value)}
                style={{
                  ...glassTextarea,
                  minHeight: 360,
                  fontFamily: 'var(--font-mono)',
                  fontSize: 13,
                  lineHeight: '20px',
                  tabSize: 2,
                }}
                onFocus={e => {
                  e.currentTarget.style.border = '1.5px solid var(--blue)'
                  e.currentTarget.style.boxShadow = '0 0 0 3px rgba(0, 122, 255, 0.18)'
                }}
                onBlur={e => {
                  e.currentTarget.style.border = '0.5px solid var(--glass-border)'
                  e.currentTarget.style.boxShadow = 'none'
                }}
              />
            </div>

            {/* Rendered panel */}
            <div style={{ flex: '1 1 300px', minWidth: 280 }}>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8, fontWeight: 500, display: 'flex', alignItems: 'center', gap: 6 }}>
                <svg width="14" height="14" viewBox="0 0 14 14" fill="rgba(255,255,255,0.5)">
                  <rect x="1" y="2" width="12" height="10" rx="1.5" fill="none" stroke="currentColor" strokeWidth="1.2"/>
                  <path d="M4 9l2-4 2 4" stroke="currentColor" strokeWidth="1" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
                  <circle cx="10" cy="6" r="1.5" fill="currentColor" opacity="0.5"/>
                </svg>
                PREVIEW
              </div>
              <div style={{
                ...glassContainer,
                minHeight: 360,
                padding: 20,
                overflowY: 'auto',
              }}>
                {renderMarkdown(markdownSource)}
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ──────────────────────────────────────
          6. Text Editor Specs
          ────────────────────────────────────── */}
      <Section title="Text Editor Specs" description="Sizing and styling reference for text editor components.">
        <SpecTable
          headers={['Property', 'Value']}
          rows={[
            ['Min height', '120px'],
            ['Max height', '400px (or scrollable)'],
            ['Padding', '16px'],
            ['Border radius', 'var(--r-lg) / 22px'],
            ['Font', 'System 17px / var(--text-body)'],
            ['Focus ring', '3px rgba(0, 122, 255, 0.18)'],
            ['Placeholder color', 'var(--label-tertiary)'],
          ]}
        />
      </Section>
    </div>
  )
}
