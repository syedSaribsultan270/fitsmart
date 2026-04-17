import { useState, useRef } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'

/* ── Inline helper styles ─────────────────────────────────────────── */

const glassContainerStyle = {
  background: 'var(--glass-inner)',
  backdropFilter: 'blur(var(--blur-sm))',
  WebkitBackdropFilter: 'blur(var(--blur-sm))',
  border: '0.5px solid var(--glass-border)',
  borderRadius: 'var(--r-lg)',
  minHeight: 44,
  padding: '6px 10px',
  display: 'flex',
  flexWrap: 'wrap',
  gap: 6,
  alignItems: 'center',
}

const pillStyle = {
  background: 'var(--glass-bg)',
  borderRadius: 9999,
  padding: '4px 12px',
  font: 'var(--text-footnote)',
  display: 'inline-flex',
  alignItems: 'center',
  gap: 6,
  color: '#fff',
  whiteSpace: 'nowrap',
}

const xBtnStyle = {
  width: 16,
  height: 16,
  borderRadius: '50%',
  border: 'none',
  background: 'transparent',
  color: 'var(--label-tertiary)',
  cursor: 'pointer',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  padding: 0,
  transition: 'color var(--dur-fast) var(--ease), background var(--dur-fast) var(--ease)',
}

const inlineInputStyle = {
  flex: 1,
  minWidth: 80,
  border: 'none',
  background: 'transparent',
  font: 'var(--text-body)',
  outline: 'none',
  color: '#fff',
}

/* ── Pill component ───────────────────────────────────────────────── */

function Pill({ label, onRemove, color }) {
  const [hoverX, setHoverX] = useState(false)
  const bg = color || 'var(--glass-bg)'
  return (
    <span style={{ ...pillStyle, background: bg }}>
      {label}
      {onRemove && (
        <button
          style={{
            ...xBtnStyle,
            color: hoverX ? 'var(--red)' : 'var(--label-tertiary)',
            background: hoverX ? 'rgba(255,59,48,0.1)' : 'transparent',
          }}
          onMouseEnter={() => setHoverX(true)}
          onMouseLeave={() => setHoverX(false)}
          onClick={onRemove}
          aria-label={`Remove ${label}`}
        >
          <svg width="10" height="10" viewBox="0 0 10 10" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round">
            <line x1="2" y1="2" x2="8" y2="8" />
            <line x1="8" y1="2" x2="2" y2="8" />
          </svg>
        </button>
      )}
    </span>
  )
}

/* ── Main page ────────────────────────────────────────────────────── */

export default function TokenFields() {
  /* Section 1 — Basic interactive token field */
  const [tokens, setTokens] = useState(['Design', 'System', 'Glass'])
  const [inputVal, setInputVal] = useState('')

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && inputVal.trim()) {
      e.preventDefault()
      setTokens([...tokens, inputVal.trim()])
      setInputVal('')
    }
    if (e.key === 'Backspace' && !inputVal && tokens.length) {
      setTokens(tokens.slice(0, -1))
    }
  }

  const removeToken = (idx) => setTokens(tokens.filter((_, i) => i !== idx))

  /* Section 4 — Token field with suggestions */
  const allSuggestions = ['Swift', 'SwiftUI', 'SwiftData', 'UIKit', 'AppKit', 'CoreData', 'Combine', 'Concurrency', 'Metal', 'RealityKit']
  const [sugTokens, setSugTokens] = useState(['SwiftUI'])
  const [sugInput, setSugInput] = useState('')
  const [sugOpen, setSugOpen] = useState(false)
  const sugRef = useRef(null)

  const filteredSuggestions = sugInput.length > 0
    ? allSuggestions.filter(
        (s) => s.toLowerCase().startsWith(sugInput.toLowerCase()) && !sugTokens.includes(s)
      )
    : []

  const addSuggestion = (s) => {
    setSugTokens([...sugTokens, s])
    setSugInput('')
    setSugOpen(false)
    sugRef.current?.focus()
  }

  const handleSugKeyDown = (e) => {
    if (e.key === 'Enter' && sugInput.trim()) {
      e.preventDefault()
      if (filteredSuggestions.length > 0) {
        addSuggestion(filteredSuggestions[0])
      } else {
        setSugTokens([...sugTokens, sugInput.trim()])
        setSugInput('')
      }
    }
    if (e.key === 'Backspace' && !sugInput && sugTokens.length) {
      setSugTokens(sugTokens.slice(0, -1))
    }
  }

  /* Section 3 — Overflow: collapse state */
  const collapseTokens = ['React', 'TypeScript', 'GraphQL', 'Docker', 'Kubernetes', 'Terraform', 'AWS']
  const visibleCount = 3
  const visibleTokens = collapseTokens.slice(0, visibleCount)
  const remaining = collapseTokens.length - visibleCount

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Token Fields</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Glass-styled token fields for tagging, filtering, and multi-value input. Tokens appear as removable pills inside a translucent container.
      </p>

      {/* ── 1. Basic Token Field ──────────────────────────────────── */}
      <Section title="Basic Token Field" description="An interactive glass container with tag pills. Type and press Enter to add tokens. Click the X to remove.">
        <Preview gradient>
          <div style={{ maxWidth: 480 }}>
            <div style={glassContainerStyle}>
              {tokens.map((t, i) => (
                <Pill key={`${t}-${i}`} label={t} onRemove={() => removeToken(i)} />
              ))}
              <input
                style={inlineInputStyle}
                placeholder={tokens.length === 0 ? 'Add a tag...' : ''}
                value={inputVal}
                onChange={(e) => setInputVal(e.target.value)}
                onKeyDown={handleKeyDown}
              />
            </div>
            <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.6)', marginTop: 10, marginBottom: 0 }}>
              Type a word and press Enter to add. Backspace removes the last token.
            </p>
          </div>
        </Preview>
      </Section>

      {/* ── 2. Token Styles ──────────────────────────────────────── */}
      <Section title="Token Styles" description="Neutral, colored, and removable pill variants.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            {/* Default */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8, textTransform: 'uppercase', letterSpacing: 1 }}>Default</div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
                <Pill label="Figma" />
                <Pill label="Sketch" />
                <Pill label="Framer" />
              </div>
            </div>

            {/* Colored */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8, textTransform: 'uppercase', letterSpacing: 1 }}>Colored</div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
                <Pill label="Design" color="rgba(0,122,255,0.25)" />
                <Pill label="Develop" color="rgba(52,199,89,0.25)" />
                <Pill label="Test" color="rgba(175,82,222,0.25)" />
                <Pill label="Ship" color="rgba(255,149,0,0.25)" />
              </div>
            </div>

            {/* Removable */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8, textTransform: 'uppercase', letterSpacing: 1 }}>Removable</div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
                <Pill label="iOS" onRemove={() => {}} />
                <Pill label="macOS" onRemove={() => {}} />
                <Pill label="visionOS" onRemove={() => {}} />
                <Pill label="watchOS" onRemove={() => {}} />
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── 3. Overflow Behavior ─────────────────────────────────── */}
      <Section title="Overflow Behavior" description="How the token field handles many tokens: wrap, scroll, or collapse.">
        {/* Wrap */}
        <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', marginBottom: 6, textTransform: 'uppercase', letterSpacing: 1 }}>Wrap</div>
        <Preview gradient>
          <div style={{ maxWidth: 320 }}>
            <div style={glassContainerStyle}>
              {['React', 'TypeScript', 'GraphQL', 'Docker', 'Kubernetes', 'Terraform', 'AWS'].map((t) => (
                <Pill key={t} label={t} />
              ))}
            </div>
          </div>
        </Preview>

        {/* Scroll */}
        <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', marginBottom: 6, textTransform: 'uppercase', letterSpacing: 1 }}>Scroll</div>
        <Preview gradient>
          <div style={{ maxWidth: 320 }}>
            <div style={{ ...glassContainerStyle, flexWrap: 'nowrap', overflowX: 'auto' }}>
              {['React', 'TypeScript', 'GraphQL', 'Docker', 'Kubernetes', 'Terraform', 'AWS'].map((t) => (
                <Pill key={t} label={t} />
              ))}
            </div>
          </div>
        </Preview>

        {/* Collapse */}
        <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', marginBottom: 6, textTransform: 'uppercase', letterSpacing: 1 }}>Collapse</div>
        <Preview gradient>
          <div style={{ maxWidth: 320 }}>
            <div style={{ ...glassContainerStyle, flexWrap: 'nowrap' }}>
              {visibleTokens.map((t) => (
                <Pill key={t} label={t} />
              ))}
              {remaining > 0 && (
                <span style={{
                  ...pillStyle,
                  background: 'var(--fill-secondary)',
                  color: 'var(--label-secondary)',
                  cursor: 'pointer',
                }}>
                  +{remaining} more
                </span>
              )}
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── 4. Token Field with Suggestions ──────────────────────── */}
      <Section title="Token Field with Suggestions" description="An enhanced token field that shows a glass dropdown of filtered suggestions as you type.">
        <Preview gradient>
          <div style={{ maxWidth: 480, position: 'relative' }}>
            <div style={glassContainerStyle}>
              {sugTokens.map((t, i) => (
                <Pill key={`${t}-${i}`} label={t} onRemove={() => setSugTokens(sugTokens.filter((_, j) => j !== i))} />
              ))}
              <input
                ref={sugRef}
                style={inlineInputStyle}
                placeholder={sugTokens.length === 0 ? 'Search frameworks...' : ''}
                value={sugInput}
                onChange={(e) => { setSugInput(e.target.value); setSugOpen(true) }}
                onKeyDown={handleSugKeyDown}
                onFocus={() => sugInput && setSugOpen(true)}
                onBlur={() => setTimeout(() => setSugOpen(false), 150)}
              />
            </div>

            {/* Dropdown */}
            {sugOpen && filteredSuggestions.length > 0 && (
              <div style={{
                position: 'absolute',
                top: '100%',
                left: 0,
                right: 0,
                marginTop: 6,
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-xl)',
                boxShadow: 'var(--glass-shadow-lg)',
                overflow: 'hidden',
                zIndex: 10,
                animation: 'tokenDropIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1) forwards',
              }}>
                {filteredSuggestions.map((s) => (
                  <div
                    key={s}
                    onMouseDown={(e) => { e.preventDefault(); addSuggestion(s) }}
                    style={{
                      padding: '10px 16px',
                      font: 'var(--text-body)',
                      color: '#fff',
                      cursor: 'pointer',
                      borderBottom: '0.5px solid var(--separator)',
                      transition: 'background var(--dur-fast) var(--ease)',
                    }}
                    onMouseEnter={(e) => e.currentTarget.style.background = 'var(--glass-bg-hover)'}
                    onMouseLeave={(e) => e.currentTarget.style.background = 'transparent'}
                  >
                    {s}
                  </div>
                ))}
              </div>
            )}

            <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.6)', marginTop: 10, marginBottom: 0 }}>
              Try typing "Sw", "Co", or "Me" to see suggestions.
            </p>
          </div>
        </Preview>
      </Section>

      {/* ── 5. Specs ─────────────────────────────────────────────── */}
      <Section title="Token Field Specs" description="Sizing and spacing reference for token field components.">
        <SpecTable
          headers={['Property', 'Value']}
          rows={[
            ['Container min-height', '44px'],
            ['Pill height', '28px'],
            ['Pill padding', '4px 12px'],
            ['Pill radius', '9999px (pill)'],
            ['Pill font', '13px / caption1'],
            ['X button size', '16x16'],
            ['Gap', '6px'],
            ['Input min-width', '80px'],
          ]}
        />
      </Section>

      {/* Keyframe for dropdown entrance */}
      <style>{`
        @keyframes tokenDropIn {
          from { opacity: 0; transform: translateY(-8px) scale(0.97); }
          to { opacity: 1; transform: translateY(0) scale(1); }
        }
      `}</style>
    </div>
  )
}
