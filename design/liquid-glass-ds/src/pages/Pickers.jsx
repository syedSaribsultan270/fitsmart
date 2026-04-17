import { useState, useRef, useEffect } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'

/* ────────────────────────────────────────────
   Helpers
   ──────────────────────────────────────────── */

const SPRING = 'all 300ms cubic-bezier(0.34, 1.56, 0.64, 1)'
const EASE_IO = 'all 200ms cubic-bezier(0.42, 0, 0.58, 1)'

const DAYS_OF_WEEK = ['S', 'M', 'T', 'W', 'T', 'F', 'S']
const MONTH_NAMES = [
  'January','February','March','April','May','June',
  'July','August','September','October','November','December',
]

function daysInMonth(year, month) {
  return new Date(year, month + 1, 0).getDate()
}
function firstDayOfMonth(year, month) {
  return new Date(year, month, 1).getDay()
}

const glassContainer = {
  background: 'var(--glass-bg)',
  backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
  WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
  border: '0.5px solid var(--glass-border)',
  borderRadius: 'var(--r-xl)',
  boxShadow: 'var(--glass-shadow), var(--glass-specular)',
  padding: 20,
}

const glassInner = {
  background: 'var(--glass-inner)',
  border: '0.5px solid var(--glass-border)',
  borderRadius: 'var(--r-lg)',
}

const SYSTEM_COLORS = [
  { name: 'Red',    value: '#FF3B30' },
  { name: 'Orange', value: '#FF9500' },
  { name: 'Yellow', value: '#FFCC00' },
  { name: 'Green',  value: '#34C759' },
  { name: 'Mint',   value: '#00C7BE' },
  { name: 'Teal',   value: '#30B0C7' },
  { name: 'Cyan',   value: '#32ADE6' },
  { name: 'Blue',   value: '#007AFF' },
  { name: 'Indigo', value: '#5856D6' },
  { name: 'Purple', value: '#AF52DE' },
  { name: 'Pink',   value: '#FF2D55' },
  { name: 'Brown',  value: '#A2845E' },
]

/* ────────────────────────────────────────────
   Inline Calendar Component
   ──────────────────────────────────────────── */

function InlineCalendar({ selectedDate, onSelectDate, displayYear, displayMonth, onPrevMonth, onNextMonth }) {
  const totalDays = daysInMonth(displayYear, displayMonth)
  const startDay = firstDayOfMonth(displayYear, displayMonth)
  const today = new Date()
  const isThisMonth = today.getFullYear() === displayYear && today.getMonth() === displayMonth
  const todayDate = today.getDate()

  const cells = []
  // Leading blanks
  for (let i = 0; i < startDay; i++) {
    cells.push(null)
  }
  for (let d = 1; d <= totalDays; d++) {
    cells.push(d)
  }
  // Trailing blanks to fill 6 rows
  while (cells.length < 42) {
    cells.push(null)
  }

  const rows = []
  for (let r = 0; r < 6; r++) {
    rows.push(cells.slice(r * 7, r * 7 + 7))
  }

  return (
    <div style={{ ...glassContainer, width: 320, userSelect: 'none' }}>
      {/* Month header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 16 }}>
        <button
          onClick={onPrevMonth}
          style={{
            width: 32, height: 32, display: 'flex', alignItems: 'center', justifyContent: 'center',
            background: 'var(--glass-inner)', border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-xs)', cursor: 'pointer', color: 'var(--blue)',
            transition: SPRING,
          }}
          onMouseEnter={e => e.currentTarget.style.background = 'var(--glass-inner-hover)'}
          onMouseLeave={e => e.currentTarget.style.background = 'var(--glass-inner)'}
        >
          <svg width="12" height="12" viewBox="0 0 12 12" fill="currentColor"><path d="M8 1L3 6l5 5" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </button>
        <span style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>
          {MONTH_NAMES[displayMonth]} {displayYear}
        </span>
        <button
          onClick={onNextMonth}
          style={{
            width: 32, height: 32, display: 'flex', alignItems: 'center', justifyContent: 'center',
            background: 'var(--glass-inner)', border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-xs)', cursor: 'pointer', color: 'var(--blue)',
            transition: SPRING,
          }}
          onMouseEnter={e => e.currentTarget.style.background = 'var(--glass-inner-hover)'}
          onMouseLeave={e => e.currentTarget.style.background = 'var(--glass-inner)'}
        >
          <svg width="12" height="12" viewBox="0 0 12 12" fill="currentColor"><path d="M4 1l5 5-5 5" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </button>
      </div>

      {/* Day-of-week header */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', textAlign: 'center', marginBottom: 8 }}>
        {DAYS_OF_WEEK.map((d, i) => (
          <span key={i} style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', fontWeight: 600 }}>{d}</span>
        ))}
      </div>

      {/* Day grid */}
      {rows.map((row, ri) => (
        <div key={ri} style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', textAlign: 'center' }}>
          {row.map((day, ci) => {
            if (day === null) return <div key={ci} style={{ height: 40 }} />
            const isSelected = day === selectedDate && displayYear === 2026 && displayMonth === 2
            const isToday = isThisMonth && day === todayDate && !isSelected
            return (
              <div
                key={ci}
                onClick={() => onSelectDate(day)}
                style={{
                  height: 40, display: 'flex', alignItems: 'center', justifyContent: 'center',
                  cursor: 'pointer', borderRadius: '50%', position: 'relative',
                  transition: SPRING,
                }}
              >
                <div style={{
                  width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center',
                  borderRadius: '50%',
                  background: isSelected ? 'var(--blue)' : 'transparent',
                  border: isToday ? '2px solid var(--blue)' : '2px solid transparent',
                  color: isSelected ? '#fff' : 'var(--label)',
                  font: 'var(--text-subhead)',
                  fontWeight: isSelected || isToday ? 600 : 400,
                  transition: SPRING,
                }}>
                  {day}
                </div>
              </div>
            )
          })}
        </div>
      ))}
    </div>
  )
}

/* ────────────────────────────────────────────
   Wheel Column Component
   ──────────────────────────────────────────── */

function WheelColumn({ items, selectedIndex, onSelect, width = 70 }) {
  const VISIBLE = 5
  const CENTER = 2
  const opacities = [0.15, 0.4, 1, 0.4, 0.15]
  const scales = [0.85, 0.92, 1, 0.92, 0.85]

  // Compute which items to show (centered on selectedIndex)
  const visibleItems = []
  for (let i = -CENTER; i <= CENTER; i++) {
    const idx = selectedIndex + i
    if (idx >= 0 && idx < items.length) {
      visibleItems.push({ label: items[idx], index: idx, slot: i + CENTER })
    } else {
      visibleItems.push({ label: '', index: -1, slot: i + CENTER })
    }
  }

  return (
    <div style={{ width, position: 'relative', height: 200, overflow: 'hidden' }}>
      {visibleItems.map((item, i) => (
        <div
          key={i}
          onClick={() => item.index >= 0 && onSelect(item.index)}
          style={{
            height: 40,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            font: 'var(--text-body)',
            fontWeight: item.slot === CENTER ? 600 : 400,
            color: 'var(--label)',
            opacity: opacities[item.slot],
            transform: `scale(${scales[item.slot]})`,
            transition: EASE_IO,
            cursor: item.index >= 0 ? 'pointer' : 'default',
          }}
        >
          {item.label}
        </div>
      ))}
    </div>
  )
}


/* ════════════════════════════════════════════
   Main Page Component
   ════════════════════════════════════════════ */

export default function Pickers() {
  // Date Picker state
  const [selectedDay, setSelectedDay] = useState(30)
  const [displayMonth, setDisplayMonth] = useState(2) // March (0-indexed)
  const [displayYear, setDisplayYear] = useState(2026)

  // Compact picker
  const [compactOpen, setCompactOpen] = useState(false)
  const [compactDay, setCompactDay] = useState(30)
  const [compactMonth, setCompactMonth] = useState(2)
  const [compactYear, setCompactYear] = useState(2026)

  // Time picker
  const [hour, setHour] = useState(10)
  const [minute, setMinute] = useState(6) // index 6 = "30"
  const [ampm, setAmpm] = useState(0)     // 0=AM, 1=PM

  // Color picker
  const [hue, setHue] = useState(210)
  const [selectedSwatch, setSelectedSwatch] = useState(7) // Blue
  const [hexInput, setHexInput] = useState('#007AFF')

  // Option picker (font size)
  const FONT_SIZES = [10, 11, 12, 13, 14, 15, 16, 17, 18, 20, 22, 24, 28, 32, 36]
  const [fontSizeIdx, setFontSizeIdx] = useState(7) // 17

  const hours = Array.from({ length: 12 }, (_, i) => i + 1)
  const minutes = Array.from({ length: 12 }, (_, i) => String(i * 5).padStart(2, '0'))
  const ampmList = ['AM', 'PM']

  function handlePrevMonth() {
    if (displayMonth === 0) {
      setDisplayMonth(11)
      setDisplayYear(displayYear - 1)
    } else {
      setDisplayMonth(displayMonth - 1)
    }
  }
  function handleNextMonth() {
    if (displayMonth === 11) {
      setDisplayMonth(0)
      setDisplayYear(displayYear + 1)
    } else {
      setDisplayMonth(displayMonth + 1)
    }
  }

  function handleCompactPrev() {
    if (compactMonth === 0) {
      setCompactMonth(11)
      setCompactYear(compactYear - 1)
    } else {
      setCompactMonth(compactMonth - 1)
    }
  }
  function handleCompactNext() {
    if (compactMonth === 11) {
      setCompactMonth(0)
      setCompactYear(compactYear + 1)
    } else {
      setCompactMonth(compactMonth + 1)
    }
  }

  const compactLabel = `${MONTH_NAMES[compactMonth].slice(0, 3)} ${compactDay}, ${compactYear}`

  // Derive a CSS color from hue
  const currentColor = `hsl(${hue}, 100%, 50%)`

  // Convert HSL to hex (simplified)
  function hslToHex(h, s, l) {
    s /= 100; l /= 100
    const a = s * Math.min(l, 1 - l)
    const f = (n) => {
      const k = (n + h / 30) % 12
      const color = l - a * Math.max(Math.min(k - 3, 9 - k, 1), -1)
      return Math.round(255 * color).toString(16).padStart(2, '0')
    }
    return `#${f(0)}${f(8)}${f(4)}`.toUpperCase()
  }

  const displayHex = hexInput
  const hueBarRef = useRef(null)

  function handleHueBarClick(e) {
    const rect = e.currentTarget.getBoundingClientRect()
    const x = Math.max(0, Math.min(e.clientX - rect.left, rect.width))
    const newHue = Math.round((x / rect.width) * 360)
    setHue(newHue)
    setHexInput(hslToHex(newHue, 100, 50))
    setSelectedSwatch(-1)
  }

  function handleSwatchClick(index) {
    setSelectedSwatch(index)
    setHexInput(SYSTEM_COLORS[index].value)
  }

  function handleHexChange(e) {
    const val = e.target.value
    setHexInput(val)
    setSelectedSwatch(-1)
  }

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Pickers</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Date, time, color, and option pickers built with Liquid Glass materials. All pickers use translucent surfaces, spring animations, and iOS-native interaction patterns.
      </p>

      {/* ──────────────────────────────────────
          1. Date Picker  Inline Calendar
          ────────────────────────────────────── */}
      <Section title="Date Picker  Inline Calendar" description="A fully interactive glass calendar. Click any date to select it. Today is highlighted with a blue ring; selected date fills with blue.">
        <Preview gradient style={{ display: 'flex', justifyContent: 'center', padding: 32 }}>
          <InlineCalendar
            selectedDate={selectedDay}
            onSelectDate={setSelectedDay}
            displayYear={displayYear}
            displayMonth={displayMonth}
            onPrevMonth={handlePrevMonth}
            onNextMonth={handleNextMonth}
          />
        </Preview>
        <p style={{ font: 'var(--text-footnote)', color: 'var(--label-tertiary)', marginBottom: 16 }}>
          Selected: {MONTH_NAMES[displayMonth]} {selectedDay}, {displayYear}
        </p>
        <SpecTable
          headers={['Variant', 'Description']}
          rows={[
            ['Inline', 'Full calendar grid, always visible. Best for date range selection.'],
            ['Compact', 'Collapsed pill that expands into a mini calendar on click.'],
            ['Wheels', 'iOS-style scroll wheels for month/day/year.'],
          ]}
        />
      </Section>

      {/* ──────────────────────────────────────
          2. Date Picker  Compact
          ────────────────────────────────────── */}
      <Section title="Date Picker  Compact" description="A space-efficient pill that expands to reveal a mini calendar with a spring entrance animation.">
        <Preview gradient style={{ minHeight: compactOpen ? 420 : 100, transition: EASE_IO }}>
          <div style={{ position: 'relative', display: 'inline-block' }}>
            {/* Pill button */}
            <button
              onClick={() => setCompactOpen(!compactOpen)}
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: 8,
                padding: '7px 16px',
                height: 34,
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: compactOpen ? '1.5px solid var(--blue)' : '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-pill)',
                boxShadow: 'var(--glass-shadow)',
                cursor: 'pointer',
                font: 'var(--text-subhead)',
                fontWeight: 500,
                color: 'var(--blue)',
                transition: SPRING,
              }}
            >
              <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" opacity="0.7">
                <rect x="1" y="3" width="14" height="12" rx="2" fill="none" stroke="currentColor" strokeWidth="1.4"/>
                <line x1="1" y1="7" x2="15" y2="7" stroke="currentColor" strokeWidth="1.2"/>
                <line x1="5" y1="1" x2="5" y2="4.5" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/>
                <line x1="11" y1="1" x2="11" y2="4.5" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/>
              </svg>
              {compactLabel}
              <svg width="10" height="6" viewBox="0 0 10 6" fill="currentColor" style={{ transform: compactOpen ? 'rotate(180deg)' : 'rotate(0deg)', transition: SPRING }}>
                <path d="M1 1l4 4 4-4" stroke="currentColor" strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </button>

            {/* Dropdown calendar */}
            {compactOpen && (
              <div style={{
                position: 'absolute',
                top: 42,
                left: 0,
                zIndex: 10,
                animation: 'none',
                transform: 'scale(1)',
                opacity: 1,
                transition: SPRING,
              }}>
                <InlineCalendar
                  selectedDate={compactDay}
                  onSelectDate={(d) => { setCompactDay(d); setCompactOpen(false); }}
                  displayYear={compactYear}
                  displayMonth={compactMonth}
                  onPrevMonth={handleCompactPrev}
                  onNextMonth={handleCompactNext}
                />
              </div>
            )}
          </div>
        </Preview>
      </Section>

      {/* ──────────────────────────────────────
          3. Time Picker
          ────────────────────────────────────── */}
      <Section title="Time Picker" description="iOS-style wheel picker with three columns for hour, minute, and AM/PM. The center row is highlighted; surrounding rows fade to guide focus.">
        <Preview gradient style={{ display: 'flex', justifyContent: 'center', padding: 32 }}>
          <div style={{ ...glassContainer, width: 280, padding: 0, overflow: 'hidden' }}>
            {/* Selected value display */}
            <div style={{ textAlign: 'center', padding: '16px 20px 8px', font: 'var(--text-caption1)', color: 'var(--label-tertiary)', fontWeight: 500, letterSpacing: 0.5 }}>
              SELECTED TIME
            </div>
            <div style={{ textAlign: 'center', paddingBottom: 12, font: 'var(--text-title2)', color: 'var(--label)', fontWeight: 700 }}>
              {hours[hour]} : {minutes[minute]} {ampmList[ampm]}
            </div>

            {/* Wheel area */}
            <div style={{ position: 'relative', display: 'flex', justifyContent: 'center', padding: '0 16px 16px' }}>
              {/* Center highlight bar */}
              <div style={{
                position: 'absolute',
                top: '50%',
                left: 16,
                right: 16,
                height: 40,
                marginTop: -20,
                ...glassInner,
                borderRadius: 'var(--r-xs)',
                pointerEvents: 'none',
                zIndex: 0,
              }} />

              <div style={{ position: 'relative', zIndex: 1, display: 'flex', alignItems: 'center' }}>
                <WheelColumn items={hours} selectedIndex={hour} onSelect={setHour} width={60} />
                <span style={{ font: 'var(--text-body)', fontWeight: 700, color: 'var(--label)', margin: '0 2px', alignSelf: 'center' }}>:</span>
                <WheelColumn items={minutes} selectedIndex={minute} onSelect={setMinute} width={60} />
                <WheelColumn items={ampmList} selectedIndex={ampm} onSelect={setAmpm} width={60} />
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ──────────────────────────────────────
          4. Color Picker
          ────────────────────────────────────── */}
      <Section title="Color Picker" description="A comprehensive glass-styled color picker with a hue spectrum, system color swatches, and a hex input field.">
        <Preview gradient style={{ display: 'flex', justifyContent: 'center', padding: 32 }}>
          <div style={{ ...glassContainer, width: 340 }}>
            {/* Hue bar */}
            <div style={{ marginBottom: 16 }}>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)', marginBottom: 8, fontWeight: 500 }}>HUE</div>
              <div
                ref={hueBarRef}
                onClick={handleHueBarClick}
                style={{
                  position: 'relative',
                  height: 28,
                  borderRadius: 14,
                  background: 'linear-gradient(to right, #FF0000, #FFFF00, #00FF00, #00FFFF, #0000FF, #FF00FF, #FF0000)',
                  cursor: 'pointer',
                  border: '0.5px solid var(--glass-border)',
                }}
              >
                {/* Indicator */}
                <div style={{
                  position: 'absolute',
                  top: -2,
                  left: `${(hue / 360) * 100}%`,
                  marginLeft: -16,
                  width: 32,
                  height: 32,
                  borderRadius: '50%',
                  background: '#fff',
                  border: `3px solid ${currentColor}`,
                  boxShadow: '0 2px 8px rgba(0,0,0,0.2)',
                  transition: SPRING,
                  pointerEvents: 'none',
                }} />
              </div>
            </div>

            {/* Saturation/Brightness square */}
            <div style={{ marginBottom: 16 }}>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)', marginBottom: 8, fontWeight: 500 }}>SATURATION / BRIGHTNESS</div>
              <div style={{
                height: 140,
                borderRadius: 'var(--r-sm)',
                background: `linear-gradient(to bottom, transparent, #000), linear-gradient(to right, #fff, ${currentColor})`,
                border: '0.5px solid var(--glass-border)',
              }} />
            </div>

            {/* System color swatches */}
            <div style={{ marginBottom: 16 }}>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)', marginBottom: 8, fontWeight: 500 }}>SYSTEM COLORS</div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: 10 }}>
                {SYSTEM_COLORS.map((c, i) => (
                  <div
                    key={i}
                    onClick={() => handleSwatchClick(i)}
                    title={c.name}
                    style={{
                      width: 40,
                      height: 40,
                      borderRadius: 'var(--r-xs)',
                      background: c.value,
                      cursor: 'pointer',
                      border: selectedSwatch === i ? '3px solid #fff' : '2px solid transparent',
                      boxShadow: selectedSwatch === i ? `0 0 0 2px ${c.value}, 0 2px 8px rgba(0,0,0,0.2)` : '0 1px 4px rgba(0,0,0,0.12)',
                      transition: SPRING,
                      outline: 'none',
                    }}
                  />
                ))}
              </div>
            </div>

            {/* Color preview + hex */}
            <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
              <div style={{
                width: 56,
                height: 56,
                borderRadius: '50%',
                background: selectedSwatch >= 0 ? SYSTEM_COLORS[selectedSwatch].value : currentColor,
                border: '3px solid var(--glass-border)',
                boxShadow: `0 4px 16px ${selectedSwatch >= 0 ? SYSTEM_COLORS[selectedSwatch].value : currentColor}44`,
                flexShrink: 0,
                transition: EASE_IO,
              }} />
              <div style={{ flex: 1 }}>
                <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', marginBottom: 4 }}>HEX VALUE</div>
                <input
                  type="text"
                  value={hexInput}
                  onChange={handleHexChange}
                  style={{
                    width: '100%',
                    height: 36,
                    padding: '0 12px',
                    ...glassInner,
                    borderRadius: 'var(--r-xs)',
                    font: 'var(--text-subhead)',
                    fontFamily: 'var(--font-mono)',
                    color: 'var(--label)',
                    outline: 'none',
                    boxSizing: 'border-box',
                    transition: EASE_IO,
                  }}
                  onFocus={e => e.currentTarget.style.borderColor = 'var(--blue)'}
                  onBlur={e => e.currentTarget.style.borderColor = 'var(--glass-border)'}
                />
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ──────────────────────────────────────
          5. Option Picker (Wheels)
          ────────────────────────────────────── */}
      <Section title="Option Picker (Wheels)" description="A single-value wheel selector for picking from a list. Center item is emphasized; items above and below fade away.">
        <Preview gradient style={{ display: 'flex', justifyContent: 'center', padding: 32 }}>
          <div style={{ ...glassContainer, width: 200, padding: 0, overflow: 'hidden' }}>
            <div style={{ textAlign: 'center', padding: '14px 16px 4px', font: 'var(--text-caption1)', color: 'var(--label-tertiary)', fontWeight: 500, letterSpacing: 0.5 }}>
              FONT SIZE
            </div>
            <div style={{ textAlign: 'center', paddingBottom: 8, font: 'var(--text-title3)', color: 'var(--label)', fontWeight: 600 }}>
              {FONT_SIZES[fontSizeIdx]}pt
            </div>

            <div style={{ position: 'relative', padding: '0 16px 16px' }}>
              {/* Center highlight bar */}
              <div style={{
                position: 'absolute',
                top: '50%',
                left: 16,
                right: 16,
                height: 40,
                marginTop: -20,
                ...glassInner,
                borderRadius: 'var(--r-xs)',
                pointerEvents: 'none',
                zIndex: 0,
              }} />
              <div style={{ position: 'relative', zIndex: 1 }}>
                <WheelColumn
                  items={FONT_SIZES.map(s => `${s}pt`)}
                  selectedIndex={fontSizeIdx}
                  onSelect={setFontSizeIdx}
                  width={168}
                />
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ──────────────────────────────────────
          6. Picker Specs
          ────────────────────────────────────── */}
      <Section title="Picker Specs" description="Sizing and use-case reference for each picker variant.">
        <SpecTable
          headers={['Variant', 'Height', 'Use Case']}
          rows={[
            ['Inline Calendar', '~320px', 'When space allows, date range selection'],
            ['Compact', '34px (collapsed)', 'Space-constrained, single date'],
            ['Wheels', '~216px', 'Time, option values, familiar iOS pattern'],
            ['Menu', '34px (collapsed)', 'Simple option selection'],
          ]}
        />
      </Section>
    </div>
  )
}
