import { useState, useRef, useEffect } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'

/* ── Shared glass dropdown style ──────────────────────────────────── */

const glassDropdownStyle = {
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
  maxHeight: 240,
  overflowY: 'auto',
  animation: 'comboDropIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1) forwards',
}

const glassInputWrapStyle = {
  position: 'relative',
  display: 'flex',
  alignItems: 'center',
  background: 'var(--glass-inner)',
  backdropFilter: 'blur(var(--blur-sm))',
  WebkitBackdropFilter: 'blur(var(--blur-sm))',
  border: '0.5px solid var(--glass-border)',
  borderRadius: 'var(--r-md)',
  height: 44,
  padding: '0 12px 0 16px',
}

const glassInputStyle = {
  flex: 1,
  border: 'none',
  background: 'transparent',
  font: 'var(--text-body)',
  color: '#fff',
  outline: 'none',
  width: '100%',
}

const itemStyle = {
  padding: '8px 16px',
  height: 40,
  display: 'flex',
  alignItems: 'center',
  font: 'var(--text-body)',
  color: '#fff',
  cursor: 'pointer',
  borderBottom: '0.5px solid var(--separator)',
  transition: 'background var(--dur-fast) var(--ease)',
}

const chevronDown = (
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0, opacity: 0.5 }}>
    <polyline points="4,6 8,10 12,6" />
  </svg>
)

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

/* ── Pill with X ──────────────────────────────────────────────────── */

function Pill({ label, onRemove }) {
  const [hoverX, setHoverX] = useState(false)
  return (
    <span style={pillStyle}>
      {label}
      {onRemove && (
        <button
          style={{
            width: 16, height: 16, borderRadius: '50%', border: 'none',
            background: hoverX ? 'rgba(255,59,48,0.1)' : 'transparent',
            color: hoverX ? 'var(--red)' : 'var(--label-tertiary)',
            cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 0,
            transition: 'color var(--dur-fast) var(--ease), background var(--dur-fast) var(--ease)',
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

/* ── Page component ───────────────────────────────────────────────── */

export default function ComboBox() {
  /* ── Section 1: Text + Dropdown ── */
  const fruitOptions = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry', 'Fig', 'Grape']
  const [comboVal, setComboVal] = useState('')
  const [comboOpen, setComboOpen] = useState(false)
  const comboRef = useRef(null)

  const filteredFruits = comboVal
    ? fruitOptions.filter((o) => o.toLowerCase().includes(comboVal.toLowerCase()))
    : fruitOptions

  const selectCombo = (val) => {
    setComboVal(val)
    setComboOpen(false)
  }

  /* ── Section 2: Autocomplete ── */
  const [autoVal, setAutoVal] = useState('')
  const [autoOpen, setAutoOpen] = useState(false)
  const autoRef = useRef(null)

  const autoFiltered = autoVal
    ? fruitOptions.filter((o) => o.toLowerCase().startsWith(autoVal.toLowerCase()))
    : fruitOptions

  const autoCompletion = autoVal && autoFiltered.length > 0 ? autoFiltered[0] : ''
  const showInline = autoVal && autoCompletion && autoCompletion.toLowerCase().startsWith(autoVal.toLowerCase())

  /* ── Section 3: Multi-select Combo ── */
  const frameworks = ['React', 'Vue', 'Angular', 'Svelte', 'Solid', 'Preact']
  const [multiSelected, setMultiSelected] = useState(['React'])
  const [multiInput, setMultiInput] = useState('')
  const [multiOpen, setMultiOpen] = useState(false)
  const multiRef = useRef(null)

  const multiFiltered = multiInput
    ? frameworks.filter((f) => f.toLowerCase().includes(multiInput.toLowerCase()))
    : frameworks

  const toggleMulti = (val) => {
    if (multiSelected.includes(val)) {
      setMultiSelected(multiSelected.filter((s) => s !== val))
    } else {
      setMultiSelected([...multiSelected, val])
    }
    setMultiInput('')
    multiRef.current?.focus()
  }

  const removeMulti = (val) => {
    setMultiSelected(multiSelected.filter((s) => s !== val))
  }

  const handleMultiKeyDown = (e) => {
    if (e.key === 'Backspace' && !multiInput && multiSelected.length) {
      setMultiSelected(multiSelected.slice(0, -1))
    }
  }

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Combo Box</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Searchable dropdowns that combine text input with selectable options. Built with glass materials and spring-animated entrances.
      </p>

      {/* ── 1. Text + Dropdown ────────────────────────────────────── */}
      <Section title="Text + Dropdown" description="A glass input that reveals a filterable dropdown on focus. Type to filter, click to select.">
        <Preview gradient>
          <div style={{ maxWidth: 360, position: 'relative' }}>
            <div
              style={glassInputWrapStyle}
              onClick={() => { setComboOpen(true); comboRef.current?.focus() }}
            >
              <input
                ref={comboRef}
                style={glassInputStyle}
                placeholder="Choose a fruit..."
                value={comboVal}
                onChange={(e) => { setComboVal(e.target.value); setComboOpen(true) }}
                onFocus={() => setComboOpen(true)}
                onBlur={() => setTimeout(() => setComboOpen(false), 150)}
              />
              {chevronDown}
            </div>

            {comboOpen && filteredFruits.length > 0 && (
              <div style={glassDropdownStyle}>
                {filteredFruits.map((item) => (
                  <div
                    key={item}
                    onMouseDown={(e) => { e.preventDefault(); selectCombo(item) }}
                    style={itemStyle}
                    onMouseEnter={(e) => e.currentTarget.style.background = 'var(--glass-bg-hover)'}
                    onMouseLeave={(e) => e.currentTarget.style.background = 'transparent'}
                  >
                    {item}
                  </div>
                ))}
              </div>
            )}
          </div>
        </Preview>
      </Section>

      {/* ── 2. Autocomplete ───────────────────────────────────────── */}
      <Section title="Autocomplete" description="Inline text completion: the first match appears as gray ghost text after the cursor. Press Tab or click to accept.">
        <Preview gradient>
          <div style={{ maxWidth: 360, position: 'relative' }}>
            <div style={glassInputWrapStyle}>
              <div style={{ position: 'relative', flex: 1 }}>
                {/* Ghost completion text */}
                {showInline && (
                  <div style={{
                    ...glassInputStyle,
                    position: 'absolute',
                    top: 0,
                    left: 0,
                    pointerEvents: 'none',
                    color: 'rgba(255,255,255,0.3)',
                    whiteSpace: 'pre',
                  }}>
                    {autoVal}{autoCompletion.slice(autoVal.length)}
                  </div>
                )}
                <input
                  ref={autoRef}
                  style={{ ...glassInputStyle, position: 'relative', background: 'transparent' }}
                  placeholder="Start typing a fruit..."
                  value={autoVal}
                  onChange={(e) => { setAutoVal(e.target.value); setAutoOpen(true) }}
                  onFocus={() => setAutoOpen(true)}
                  onBlur={() => setTimeout(() => setAutoOpen(false), 150)}
                  onKeyDown={(e) => {
                    if (e.key === 'Tab' && showInline) {
                      e.preventDefault()
                      setAutoVal(autoCompletion)
                      setAutoOpen(false)
                    }
                  }}
                />
              </div>
              {chevronDown}
            </div>

            {autoOpen && autoFiltered.length > 0 && autoVal && (
              <div style={glassDropdownStyle}>
                {autoFiltered.map((item) => (
                  <div
                    key={item}
                    onMouseDown={(e) => { e.preventDefault(); setAutoVal(item); setAutoOpen(false) }}
                    style={itemStyle}
                    onMouseEnter={(e) => e.currentTarget.style.background = 'var(--glass-bg-hover)'}
                    onMouseLeave={(e) => e.currentTarget.style.background = 'transparent'}
                  >
                    {/* Bold the matching portion */}
                    <span>
                      <strong>{item.slice(0, autoVal.length)}</strong>
                      {item.slice(autoVal.length)}
                    </span>
                  </div>
                ))}
              </div>
            )}

            <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.6)', marginTop: 10, marginBottom: 0 }}>
              Type "App" to see inline completion. Press Tab to accept.
            </p>
          </div>
        </Preview>
      </Section>

      {/* ── 3. Multi-select Combo ─────────────────────────────────── */}
      <Section title="Multi-select Combo" description="Combines token pills with a filterable dropdown. Selected items appear as pills and show a checkmark in the list.">
        <Preview gradient>
          <div style={{ maxWidth: 420, position: 'relative' }}>
            {/* Token + input area */}
            <div
              style={{
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
                cursor: 'text',
              }}
              onClick={() => multiRef.current?.focus()}
            >
              {multiSelected.map((s) => (
                <Pill key={s} label={s} onRemove={() => removeMulti(s)} />
              ))}
              <input
                ref={multiRef}
                style={{
                  flex: 1, minWidth: 80, border: 'none', background: 'transparent',
                  font: 'var(--text-body)', outline: 'none', color: '#fff',
                }}
                placeholder={multiSelected.length === 0 ? 'Select frameworks...' : ''}
                value={multiInput}
                onChange={(e) => { setMultiInput(e.target.value); setMultiOpen(true) }}
                onFocus={() => setMultiOpen(true)}
                onBlur={() => setTimeout(() => setMultiOpen(false), 150)}
                onKeyDown={handleMultiKeyDown}
              />
            </div>

            {/* Dropdown */}
            {multiOpen && (
              <div style={glassDropdownStyle}>
                {multiFiltered.map((item) => {
                  const isSelected = multiSelected.includes(item)
                  return (
                    <div
                      key={item}
                      onMouseDown={(e) => { e.preventDefault(); toggleMulti(item) }}
                      style={{
                        ...itemStyle,
                        justifyContent: 'space-between',
                        background: isSelected ? 'var(--glass-bg-tinted)' : 'transparent',
                      }}
                      onMouseEnter={(e) => { if (!isSelected) e.currentTarget.style.background = 'var(--glass-bg-hover)' }}
                      onMouseLeave={(e) => { e.currentTarget.style.background = isSelected ? 'var(--glass-bg-tinted)' : 'transparent' }}
                    >
                      <span>{item}</span>
                      {isSelected && (
                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" stroke="var(--blue)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                          <polyline points="3,8 6.5,11.5 13,5" />
                        </svg>
                      )}
                    </div>
                  )
                })}
              </div>
            )}
          </div>
        </Preview>
      </Section>

      {/* ── 4. Specs ──────────────────────────────────────────────── */}
      <Section title="Combo Box Specs" description="Sizing and animation reference for combo box components.">
        <SpecTable
          headers={['Property', 'Value']}
          rows={[
            ['Input height', '44px'],
            ['Dropdown max-height', '240px (scrollable)'],
            ['Dropdown radius', 'var(--r-xl)'],
            ['Item height', '40px'],
            ['Item padding', '8px 16px'],
            ['Dropdown shadow', 'var(--glass-shadow-lg)'],
            ['Animation', 'spring entrance, 300ms'],
          ]}
        />
      </Section>

      {/* Keyframe for dropdown entrance */}
      <style>{`
        @keyframes comboDropIn {
          from { opacity: 0; transform: translateY(-8px) scale(0.97); }
          to { opacity: 1; transform: translateY(0) scale(1); }
        }
      `}</style>
    </div>
  )
}
