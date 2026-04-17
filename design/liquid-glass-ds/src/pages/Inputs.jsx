import { useState, useRef, useEffect, useCallback } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassInput, GlassSearch, GlassToggle, GlassSlider, GlassSegment, GlassButton } from '../components/Glass'

export default function Inputs() {
  const [toggle1, setToggle1] = useState(true)
  const [toggle2, setToggle2] = useState(false)
  const [sliderVal, setSliderVal] = useState(50)
  const [segment, setSegment] = useState('day')
  const [stepperVal, setStepperVal] = useState(3)

  // New state for enriched sections
  const [checks, setChecks] = useState({ a: false, b: true, c: 'indeterminate', d: false })
  const [radio, setRadio] = useState('medium')
  const [miniToggle, setMiniToggle] = useState(true)
  const [discreteVal, setDiscreteVal] = useState(50)
  const [rangeMin, setRangeMin] = useState(25)
  const [rangeMax, setRangeMax] = useState(75)
  const [verticalVal, setVerticalVal] = useState(60)
  const [showPassword, setShowPassword] = useState(false)
  const [passwordVal, setPasswordVal] = useState('mypassword')
  const [numericVal, setNumericVal] = useState(1234)
  const [textareaVal, setTextareaVal] = useState('')
  const [searchScope, setSearchScope] = useState('all')
  const textareaRef = useRef(null)

  const autoResize = useCallback(() => {
    const el = textareaRef.current
    if (el) {
      el.style.height = 'auto'
      el.style.height = el.scrollHeight + 'px'
    }
  }, [])

  useEffect(() => { autoResize() }, [textareaVal, autoResize])

  // Format number with commas
  const formatNumber = (n) => n.toLocaleString()

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Inputs</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Glass-styled form controls for capturing user input. Every control uses translucent materials with blur.
      </p>

      <Section title="Text Fields" description="Standard text inputs with glass material. Focus state adds a blue ring; disabled reduces opacity.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12, maxWidth: 360 }}>
            <GlassInput placeholder="Default input" />
            <GlassInput placeholder="Disabled input" disabled />
            <div style={{ border: '1.5px solid var(--red)', borderRadius: 'var(--r-md)', padding: 1 }}>
              <GlassInput placeholder="Error state" style={{ borderColor: 'transparent' }} />
            </div>
            <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.7)', margin: 0 }}>
              Click the default input to see the focus ring. Error state wraps with a red border.
            </p>
          </div>
        </Preview>
      </Section>

      <Section title="Search" description="Pill-shaped search field with a magnifying glass icon. Built for nav bars and toolbars.">
        <Preview gradient>
          <div style={{ maxWidth: 400 }}>
            <GlassSearch placeholder="Search" />
          </div>
        </Preview>
      </Section>

      <Section title="Toggle" description="iOS-style switches with glass tracks. Green when on, translucent when off.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 24, alignItems: 'center', flexWrap: 'wrap' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <GlassToggle checked={toggle1} onChange={() => setToggle1(!toggle1)} />
              <span style={{ font: 'var(--text-body)', color: '#fff' }}>{toggle1 ? 'On' : 'Off'}</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <GlassToggle checked={toggle2} onChange={() => setToggle2(!toggle2)} />
              <span style={{ font: 'var(--text-body)', color: '#fff' }}>{toggle2 ? 'On' : 'Off'}</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <GlassToggle checked disabled />
              <span style={{ font: 'var(--text-body)', color: 'rgba(255,255,255,0.5)' }}>Disabled</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <GlassToggle checked={false} disabled />
              <span style={{ font: 'var(--text-body)', color: 'rgba(255,255,255,0.5)' }}>Disabled</span>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Slider" description="Range input with a glass thumb and track. Drag to adjust values continuously.">
        <Preview gradient>
          <div style={{ maxWidth: 400 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
              <span style={{ font: 'var(--text-subhead)', color: '#fff' }}>Brightness</span>
              <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.7)' }}>{sliderVal}%</span>
            </div>
            <GlassSlider min={0} max={100} value={sliderVal} onChange={(e) => setSliderVal(Number(e.target.value))} />
          </div>
        </Preview>
      </Section>

      <Section title="Segmented Control" description="Mutually exclusive selection within a glass container. Active segment floats above with a solid background.">
        <Preview gradient>
          <GlassSegment
            items={[
              { label: 'Day', value: 'day' },
              { label: 'Week', value: 'week' },
              { label: 'Month', value: 'month' },
              { label: 'Year', value: 'year' },
            ]}
            value={segment}
            onChange={setSegment}
          />
        </Preview>
      </Section>

      <Section title="Stepper" description="Increment and decrement a value with glass buttons. A compact control for numeric adjustments.">
        <Preview gradient>
          <div style={{ display: 'inline-flex', alignItems: 'center', background: 'var(--glass-inner)', backdropFilter: 'blur(16px)', WebkitBackdropFilter: 'blur(16px)', border: '0.5px solid var(--glass-border)', borderRadius: 'var(--r-lg)', overflow: 'hidden' }}>
            <button
              onClick={() => setStepperVal(Math.max(0, stepperVal - 1))}
              style={{
                width: 44, height: 44, display: 'flex', alignItems: 'center', justifyContent: 'center',
                background: 'transparent', border: 'none', cursor: 'pointer', color: 'var(--blue)',
              }}
            >
              <svg width="18" height="2" viewBox="0 0 18 2" fill="currentColor"><rect width="18" height="2" rx="1"/></svg>
            </button>
            <div style={{
              width: 52, height: 44, display: 'flex', alignItems: 'center', justifyContent: 'center',
              borderLeft: '0.5px solid var(--separator)', borderRight: '0.5px solid var(--separator)',
              font: 'var(--text-body)', fontWeight: 600, color: '#fff',
            }}>
              {stepperVal}
            </div>
            <button
              onClick={() => setStepperVal(stepperVal + 1)}
              style={{
                width: 44, height: 44, display: 'flex', alignItems: 'center', justifyContent: 'center',
                background: 'transparent', border: 'none', cursor: 'pointer', color: 'var(--blue)',
              }}
            >
              <svg width="18" height="18" viewBox="0 0 18 18" fill="currentColor">
                <rect x="8" y="0" width="2" height="18" rx="1"/>
                <rect x="0" y="8" width="18" height="2" rx="1"/>
              </svg>
            </button>
          </div>
        </Preview>
      </Section>

      <Section title="Specs" description="Sizing reference for input controls.">
        <SpecTable
          headers={['Component', 'Height', 'Border Radius', 'Padding']}
          rows={[
            ['Text Input', '44px', '--r-md (16px)', '0 16px'],
            ['Search', '40px', '--r-pill', '0 16px 0 40px'],
            ['Toggle', '31px (51px wide)', '16px', 'N/A'],
            ['Slider Thumb', '28px', '50%', 'N/A'],
            ['Slider Track', '4px', '2px', 'N/A'],
            ['Segment', '38px', '--r-lg (22px)', '3px container'],
            ['Segment Item', '32px', '19px', '7px 18px'],
            ['Stepper', '44px', '--r-lg (22px)', '0'],
          ]}
        />
      </Section>

      {/* ================================================================
          NEW SECTIONS
          ================================================================ */}

      <Section title="Checkbox" description="macOS-style checkboxes with glass material. Supports unchecked, checked, indeterminate, and disabled states.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            {[
              { key: 'a', label: 'Unchecked item' },
              { key: 'b', label: 'Checked item' },
              { key: 'c', label: 'Indeterminate' },
              { key: 'd', label: 'Disabled', disabled: true },
            ].map((item) => {
              const val = checks[item.key]
              const isChecked = val === true
              const isIndet = val === 'indeterminate'
              return (
                <label
                  key={item.key}
                  style={{
                    display: 'flex', alignItems: 'center', gap: 10,
                    cursor: item.disabled ? 'default' : 'pointer',
                    opacity: item.disabled ? 0.35 : 1,
                  }}
                >
                  <button
                    disabled={item.disabled}
                    onClick={() => {
                      if (item.disabled) return
                      setChecks((prev) => ({
                        ...prev,
                        [item.key]: prev[item.key] === true ? false : prev[item.key] === 'indeterminate' ? true : true,
                      }))
                    }}
                    style={{
                      width: 20, height: 20, flexShrink: 0,
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      background: isChecked || isIndet ? 'var(--blue)' : 'var(--glass-inner)',
                      backdropFilter: isChecked || isIndet ? 'none' : 'blur(var(--blur-sm))',
                      WebkitBackdropFilter: isChecked || isIndet ? 'none' : 'blur(var(--blur-sm))',
                      border: isChecked || isIndet ? '0.5px solid var(--blue)' : '0.5px solid var(--glass-border)',
                      borderRadius: 'var(--r-xs)',
                      cursor: item.disabled ? 'default' : 'pointer',
                      padding: 0,
                      transform: isChecked || isIndet ? 'scale(1)' : 'scale(1)',
                      transition: 'transform var(--dur) var(--ease-spring), background var(--dur-fast) var(--ease), border-color var(--dur-fast) var(--ease)',
                    }}
                  >
                    {isChecked && (
                      <svg width="14" height="14" viewBox="0 0 16 16" fill="none" style={{ animation: 'checkPop var(--dur) var(--ease-spring)' }}>
                        <path d="M3.5 8.5L6.5 11.5L12.5 4.5" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                      </svg>
                    )}
                    {isIndet && (
                      <svg width="14" height="14" viewBox="0 0 16 16" fill="none">
                        <path d="M4 8H12" stroke="#fff" strokeWidth="2" strokeLinecap="round"/>
                      </svg>
                    )}
                  </button>
                  <span style={{ font: 'var(--text-body)', color: '#fff' }}>{item.label}</span>
                </label>
              )
            })}
          </div>
          <style>{`
            @keyframes checkPop {
              0% { transform: scale(0.5); opacity: 0; }
              60% { transform: scale(1.15); }
              100% { transform: scale(1); opacity: 1; }
            }
          `}</style>
        </Preview>
      </Section>

      <Section title="Radio Buttons" description="macOS-style radio group. Only one option can be selected at a time. Uses glass material for the outer ring.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            {[
              { value: 'small', label: 'Small' },
              { value: 'medium', label: 'Medium' },
              { value: 'large', label: 'Large' },
            ].map((item) => {
              const selected = radio === item.value
              return (
                <label
                  key={item.value}
                  onClick={() => setRadio(item.value)}
                  style={{ display: 'flex', alignItems: 'center', gap: 10, cursor: 'pointer' }}
                >
                  <div
                    style={{
                      width: 20, height: 20, flexShrink: 0,
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      background: 'var(--glass-inner)',
                      backdropFilter: 'blur(var(--blur-sm))',
                      WebkitBackdropFilter: 'blur(var(--blur-sm))',
                      border: selected ? '2px solid var(--blue)' : '0.5px solid var(--glass-border)',
                      borderRadius: '50%',
                      transition: 'border var(--dur-fast) var(--ease)',
                    }}
                  >
                    {selected && (
                      <div
                        style={{
                          width: 12, height: 12,
                          background: 'var(--blue)',
                          borderRadius: '50%',
                          animation: 'radioPop var(--dur) var(--ease-spring)',
                        }}
                      />
                    )}
                  </div>
                  <span style={{ font: 'var(--text-body)', color: '#fff' }}>{item.label}</span>
                </label>
              )
            })}
            {/* Disabled variant */}
            <label style={{ display: 'flex', alignItems: 'center', gap: 10, opacity: 0.35, cursor: 'default' }}>
              <div
                style={{
                  width: 20, height: 20, flexShrink: 0,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  background: 'var(--glass-inner)',
                  border: '0.5px solid var(--glass-border)',
                  borderRadius: '50%',
                }}
              />
              <span style={{ font: 'var(--text-body)', color: '#fff' }}>Disabled</span>
            </label>
          </div>
          <style>{`
            @keyframes radioPop {
              0% { transform: scale(0); }
              60% { transform: scale(1.2); }
              100% { transform: scale(1); }
            }
          `}</style>
        </Preview>
      </Section>

      <Section title="Mini Switch" description="A watchOS-sized smaller toggle (42x26) compared to the standard iOS toggle. Useful for compact layouts.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 32, alignItems: 'center', flexWrap: 'wrap' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <div
                onClick={() => setMiniToggle(!miniToggle)}
                style={{
                  width: 42, height: 26,
                  borderRadius: 13,
                  background: miniToggle ? 'var(--green)' : 'var(--glass-inner)',
                  backdropFilter: miniToggle ? 'none' : 'blur(var(--blur-sm))',
                  WebkitBackdropFilter: miniToggle ? 'none' : 'blur(var(--blur-sm))',
                  border: '0.5px solid var(--glass-border)',
                  position: 'relative',
                  cursor: 'pointer',
                  transition: 'background var(--dur) var(--ease)',
                }}
              >
                <div
                  style={{
                    width: 22, height: 22,
                    borderRadius: '50%',
                    background: '#fff',
                    boxShadow: '0 1px 3px rgba(0,0,0,0.15), 0 1px 1px rgba(0,0,0,0.06)',
                    position: 'absolute',
                    top: 2,
                    left: miniToggle ? 18 : 2,
                    transition: 'left var(--dur) var(--ease-spring)',
                  }}
                />
              </div>
              <span style={{ font: 'var(--text-subhead)', color: '#fff' }}>Mini (42x26)</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <GlassToggle checked={toggle1} onChange={() => setToggle1(!toggle1)} />
              <span style={{ font: 'var(--text-subhead)', color: '#fff' }}>Standard (51x31)</span>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Discrete Slider" description="A slider that snaps to specific step values. Tick marks indicate the available positions.">
        <Preview gradient>
          <div style={{ maxWidth: 400 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
              <span style={{ font: 'var(--text-subhead)', color: '#fff' }}>Quality</span>
              <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.7)' }}>{discreteVal}</span>
            </div>
            <GlassSlider
              min={0} max={100} step={25}
              value={discreteVal}
              onChange={(e) => setDiscreteVal(Number(e.target.value))}
            />
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6, padding: '0 2px' }}>
              {[0, 25, 50, 75, 100].map((tick) => (
                <div key={tick} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
                  <div style={{ width: 1, height: 8, background: 'rgba(255,255,255,0.4)', borderRadius: 1 }} />
                  <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.5)' }}>{tick}</span>
                </div>
              ))}
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Range Slider" description="Dual-thumb slider for selecting a min/max range. The filled area between thumbs is highlighted.">
        <Preview gradient>
          <div style={{ maxWidth: 400 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
              <span style={{ font: 'var(--text-subhead)', color: '#fff' }}>Price Range</span>
              <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.7)' }}>${rangeMin} - ${rangeMax}</span>
            </div>
            <div style={{ position: 'relative', height: 28 }}>
              {/* Track background */}
              <div style={{
                position: 'absolute', top: 12, left: 0, right: 0, height: 4,
                background: 'var(--glass-inner)',
                borderRadius: 2,
              }} />
              {/* Filled track between thumbs */}
              <div style={{
                position: 'absolute', top: 12, height: 4,
                left: `${rangeMin}%`, right: `${100 - rangeMax}%`,
                background: 'var(--blue)',
                borderRadius: 2,
              }} />
              {/* Min thumb */}
              <input
                type="range" min={0} max={100} value={rangeMin}
                onChange={(e) => {
                  const v = Number(e.target.value)
                  if (v < rangeMax) setRangeMin(v)
                }}
                style={{
                  position: 'absolute', top: 0, left: 0, width: '100%', height: 28,
                  WebkitAppearance: 'none', appearance: 'none',
                  background: 'transparent', pointerEvents: 'none',
                  zIndex: 2,
                }}
                className="range-thumb-only"
              />
              {/* Max thumb */}
              <input
                type="range" min={0} max={100} value={rangeMax}
                onChange={(e) => {
                  const v = Number(e.target.value)
                  if (v > rangeMin) setRangeMax(v)
                }}
                style={{
                  position: 'absolute', top: 0, left: 0, width: '100%', height: 28,
                  WebkitAppearance: 'none', appearance: 'none',
                  background: 'transparent', pointerEvents: 'none',
                  zIndex: 3,
                }}
                className="range-thumb-only"
              />
              <style>{`
                .range-thumb-only::-webkit-slider-thumb {
                  -webkit-appearance: none;
                  width: 28px; height: 28px;
                  border-radius: 50%;
                  background: #fff;
                  box-shadow: 0 1px 4px rgba(0,0,0,0.2), 0 0 0 0.5px rgba(0,0,0,0.04);
                  pointer-events: auto;
                  cursor: pointer;
                }
                .range-thumb-only::-moz-range-thumb {
                  width: 28px; height: 28px;
                  border: none;
                  border-radius: 50%;
                  background: #fff;
                  box-shadow: 0 1px 4px rgba(0,0,0,0.2), 0 0 0 0.5px rgba(0,0,0,0.04);
                  pointer-events: auto;
                  cursor: pointer;
                }
              `}</style>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Vertical Slider" description="Volume-style vertical slider with a glass thumb. Useful for audio controls and equalizer-like interfaces.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 32, alignItems: 'flex-end' }}>
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{ position: 'relative', width: 28, height: 200 }}>
                {/* Track */}
                <div style={{
                  position: 'absolute', left: 12, top: 0, width: 4, height: '100%',
                  background: 'var(--glass-inner)',
                  borderRadius: 2,
                }} />
                {/* Filled track */}
                <div style={{
                  position: 'absolute', left: 12, bottom: 0, width: 4,
                  height: `${verticalVal}%`,
                  background: 'var(--blue)',
                  borderRadius: 2,
                }} />
                {/* Thumb */}
                <div
                  style={{
                    position: 'absolute', left: 0,
                    bottom: `calc(${verticalVal}% - 14px)`,
                    width: 28, height: 28,
                    borderRadius: '50%',
                    background: '#fff',
                    boxShadow: '0 1px 4px rgba(0,0,0,0.2), 0 0 0 0.5px rgba(0,0,0,0.04)',
                    cursor: 'pointer',
                    transition: 'bottom 50ms linear',
                  }}
                />
                {/* Invisible range input rotated for interaction */}
                <input
                  type="range" min={0} max={100} value={verticalVal}
                  onChange={(e) => setVerticalVal(Number(e.target.value))}
                  style={{
                    position: 'absolute',
                    width: 200, height: 28,
                    left: -86, top: 86,
                    transform: 'rotate(-90deg)',
                    transformOrigin: 'center center',
                    WebkitAppearance: 'none', appearance: 'none',
                    background: 'transparent',
                    opacity: 0,
                    cursor: 'pointer',
                  }}
                />
              </div>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.6)' }}>{verticalVal}%</span>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Secure Field" description="Password input with a toggle to reveal or hide the entered text. Uses the eye icon convention.">
        <Preview gradient>
          <div style={{ maxWidth: 360 }}>
            <div style={{ position: 'relative' }}>
              <input
                type={showPassword ? 'text' : 'password'}
                value={passwordVal}
                onChange={(e) => setPasswordVal(e.target.value)}
                placeholder="Enter password"
                style={{
                  width: '100%', height: 44, padding: '0 44px 0 16px',
                  background: 'var(--glass-inner)',
                  backdropFilter: 'blur(var(--blur-sm))',
                  WebkitBackdropFilter: 'blur(var(--blur-sm))',
                  border: '0.5px solid var(--glass-border)',
                  borderRadius: 'var(--r-md)',
                  color: '#fff',
                  font: 'var(--text-body)',
                  outline: 'none',
                  boxSizing: 'border-box',
                }}
              />
              <button
                onClick={() => setShowPassword(!showPassword)}
                style={{
                  position: 'absolute', right: 4, top: 4,
                  width: 36, height: 36,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  background: 'transparent',
                  border: 'none',
                  borderRadius: 'var(--r-xs)',
                  cursor: 'pointer',
                  color: 'rgba(255,255,255,0.6)',
                  transition: 'color var(--dur-fast) var(--ease)',
                }}
                onMouseEnter={(e) => { e.currentTarget.style.color = '#fff'; }}
                onMouseLeave={(e) => { e.currentTarget.style.color = 'rgba(255,255,255,0.6)'; }}
              >
                {showPassword ? (
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19m-6.72-1.07a3 3 0 11-4.24-4.24"/>
                    <line x1="1" y1="1" x2="23" y2="23"/>
                  </svg>
                ) : (
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                    <circle cx="12" cy="12" r="3"/>
                  </svg>
                )}
              </button>
            </div>
            <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.5)', marginTop: 8, marginBottom: 0 }}>
              {showPassword ? 'Password visible' : 'Password hidden'} — click the eye icon to toggle.
            </p>
          </div>
        </Preview>
      </Section>

      <Section title="Numeric Field" description="Number-only input with increment/decrement stepper buttons and formatted display.">
        <Preview gradient>
          <div style={{ maxWidth: 240 }}>
            <div style={{
              display: 'flex', alignItems: 'center',
              background: 'var(--glass-inner)',
              backdropFilter: 'blur(var(--blur-sm))',
              WebkitBackdropFilter: 'blur(var(--blur-sm))',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-md)',
              overflow: 'hidden',
            }}>
              <input
                type="text"
                inputMode="numeric"
                value={formatNumber(numericVal)}
                onChange={(e) => {
                  const raw = e.target.value.replace(/[^0-9]/g, '')
                  if (raw !== '') setNumericVal(Number(raw))
                  else setNumericVal(0)
                }}
                style={{
                  flex: 1, height: 44, padding: '0 16px',
                  background: 'transparent',
                  border: 'none',
                  color: '#fff',
                  font: 'var(--text-body)',
                  fontVariantNumeric: 'tabular-nums',
                  outline: 'none',
                }}
              />
              <div style={{ display: 'flex', flexDirection: 'column', borderLeft: '0.5px solid var(--separator)' }}>
                <button
                  onClick={() => setNumericVal(numericVal + 1)}
                  style={{
                    width: 36, height: 22,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    background: 'transparent',
                    border: 'none',
                    borderBottom: '0.5px solid var(--separator)',
                    cursor: 'pointer',
                    color: 'var(--blue)',
                    padding: 0,
                  }}
                >
                  <svg width="12" height="12" viewBox="0 0 12 12" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round">
                    <path d="M3 7.5L6 4.5L9 7.5"/>
                  </svg>
                </button>
                <button
                  onClick={() => setNumericVal(Math.max(0, numericVal - 1))}
                  style={{
                    width: 36, height: 22,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    background: 'transparent',
                    border: 'none',
                    cursor: 'pointer',
                    color: 'var(--blue)',
                    padding: 0,
                  }}
                >
                  <svg width="12" height="12" viewBox="0 0 12 12" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round">
                    <path d="M3 4.5L6 7.5L9 4.5"/>
                  </svg>
                </button>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Multi-line Field" description="Auto-expanding textarea that grows as the user types. Includes a character count indicator.">
        <Preview gradient>
          <div style={{ maxWidth: 400 }}>
            <textarea
              ref={textareaRef}
              value={textareaVal}
              onChange={(e) => setTextareaVal(e.target.value)}
              placeholder="Start typing..."
              rows={2}
              style={{
                width: '100%', minHeight: 66,
                padding: '12px 16px',
                background: 'var(--glass-inner)',
                backdropFilter: 'blur(var(--blur-sm))',
                WebkitBackdropFilter: 'blur(var(--blur-sm))',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-md)',
                color: '#fff',
                font: 'var(--text-body)',
                outline: 'none',
                resize: 'none',
                overflow: 'hidden',
                boxSizing: 'border-box',
              }}
            />
            <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 4 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)' }}>
                {textareaVal.length} characters
              </span>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Field with Validation" description="Inline validation states showing valid, invalid, and warning feedback with colored borders and icons.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
            {/* Valid */}
            <div style={{ flex: '1 1 160px', minWidth: 160 }}>
              <div style={{ position: 'relative' }}>
                <input
                  type="text" defaultValue="hello@email.com" readOnly
                  style={{
                    width: '100%', height: 44, padding: '0 40px 0 16px',
                    background: 'var(--glass-inner)',
                    backdropFilter: 'blur(var(--blur-sm))',
                    WebkitBackdropFilter: 'blur(var(--blur-sm))',
                    border: '1.5px solid var(--green)',
                    borderRadius: 'var(--r-md)',
                    color: '#fff',
                    font: 'var(--text-body)',
                    outline: 'none',
                    boxSizing: 'border-box',
                  }}
                />
                <div style={{ position: 'absolute', right: 12, top: 12, color: 'var(--green)' }}>
                  <svg width="20" height="20" viewBox="0 0 16 16" fill="currentColor">
                    <path d="M13.78 4.22a.75.75 0 010 1.06l-7.25 7.25a.75.75 0 01-1.06 0L2.22 9.28a.75.75 0 011.06-1.06L6 10.94l6.72-6.72a.75.75 0 011.06 0z"/>
                  </svg>
                </div>
              </div>
              <p style={{ font: 'var(--text-caption1)', color: 'var(--green)', marginTop: 4, marginBottom: 0 }}>Valid email</p>
            </div>
            {/* Invalid */}
            <div style={{ flex: '1 1 160px', minWidth: 160 }}>
              <div style={{ position: 'relative' }}>
                <input
                  type="text" defaultValue="not-an-email" readOnly
                  style={{
                    width: '100%', height: 44, padding: '0 40px 0 16px',
                    background: 'var(--glass-inner)',
                    backdropFilter: 'blur(var(--blur-sm))',
                    WebkitBackdropFilter: 'blur(var(--blur-sm))',
                    border: '1.5px solid var(--red)',
                    borderRadius: 'var(--r-md)',
                    color: '#fff',
                    font: 'var(--text-body)',
                    outline: 'none',
                    boxSizing: 'border-box',
                  }}
                />
                <div style={{ position: 'absolute', right: 12, top: 12, color: 'var(--red)' }}>
                  <svg width="20" height="20" viewBox="0 0 16 16" fill="currentColor">
                    <path d="M3.72 3.72a.75.75 0 011.06 0L8 6.94l3.22-3.22a.75.75 0 111.06 1.06L9.06 8l3.22 3.22a.75.75 0 11-1.06 1.06L8 9.06l-3.22 3.22a.75.75 0 01-1.06-1.06L6.94 8 3.72 4.78a.75.75 0 010-1.06z"/>
                  </svg>
                </div>
              </div>
              <p style={{ font: 'var(--text-caption1)', color: 'var(--red)', marginTop: 4, marginBottom: 0 }}>Invalid email format</p>
            </div>
            {/* Warning */}
            <div style={{ flex: '1 1 160px', minWidth: 160 }}>
              <div style={{ position: 'relative' }}>
                <input
                  type="text" defaultValue="user@old-domain" readOnly
                  style={{
                    width: '100%', height: 44, padding: '0 40px 0 16px',
                    background: 'var(--glass-inner)',
                    backdropFilter: 'blur(var(--blur-sm))',
                    WebkitBackdropFilter: 'blur(var(--blur-sm))',
                    border: '1.5px solid var(--orange)',
                    borderRadius: 'var(--r-md)',
                    color: '#fff',
                    font: 'var(--text-body)',
                    outline: 'none',
                    boxSizing: 'border-box',
                  }}
                />
                <div style={{ position: 'absolute', right: 12, top: 12, color: 'var(--orange)' }}>
                  <svg width="20" height="20" viewBox="0 0 16 16" fill="currentColor">
                    <path d="M8.22 1.754a.25.25 0 00-.44 0L1.698 13.132a.25.25 0 00.22.368h12.164a.25.25 0 00.22-.368L8.22 1.754zm-1.763-.707c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0 0114.082 15H1.918a1.75 1.75 0 01-1.543-2.575L6.457 1.047zM9 11a1 1 0 11-2 0 1 1 0 012 0zm-.25-5.25a.75.75 0 00-1.5 0v2.5a.75.75 0 001.5 0v-2.5z"/>
                  </svg>
                </div>
              </div>
              <p style={{ font: 'var(--text-caption1)', color: 'var(--orange)', marginTop: 4, marginBottom: 0 }}>Domain may not exist</p>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Field with Icons" description="Text fields with leading and trailing icons for context and actions.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12, maxWidth: 360 }}>
            {/* Email field */}
            <div style={{ position: 'relative' }}>
              <div style={{ position: 'absolute', left: 14, top: 12, color: 'rgba(255,255,255,0.5)', pointerEvents: 'none' }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                  <rect x="2" y="4" width="20" height="16" rx="3"/>
                  <path d="M22 7l-10 6L2 7"/>
                </svg>
              </div>
              <input
                type="email" placeholder="Email address"
                style={{
                  width: '100%', height: 44, padding: '0 16px 0 44px',
                  background: 'var(--glass-inner)',
                  backdropFilter: 'blur(var(--blur-sm))',
                  WebkitBackdropFilter: 'blur(var(--blur-sm))',
                  border: '0.5px solid var(--glass-border)',
                  borderRadius: 'var(--r-md)',
                  color: '#fff',
                  font: 'var(--text-body)',
                  outline: 'none',
                  boxSizing: 'border-box',
                }}
              />
            </div>
            {/* Search field with clear */}
            <div style={{ position: 'relative' }}>
              <div style={{ position: 'absolute', left: 14, top: 12, color: 'rgba(255,255,255,0.5)', pointerEvents: 'none' }}>
                <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                  <path fillRule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clipRule="evenodd"/>
                </svg>
              </div>
              <input
                type="text" placeholder="Search files" defaultValue="design_system"
                style={{
                  width: '100%', height: 44, padding: '0 44px 0 44px',
                  background: 'var(--glass-inner)',
                  backdropFilter: 'blur(var(--blur-sm))',
                  WebkitBackdropFilter: 'blur(var(--blur-sm))',
                  border: '0.5px solid var(--glass-border)',
                  borderRadius: 'var(--r-md)',
                  color: '#fff',
                  font: 'var(--text-body)',
                  outline: 'none',
                  boxSizing: 'border-box',
                }}
              />
              <button
                style={{
                  position: 'absolute', right: 6, top: 6,
                  width: 32, height: 32,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  background: 'rgba(255,255,255,0.1)',
                  border: 'none',
                  borderRadius: '50%',
                  cursor: 'pointer',
                  color: 'rgba(255,255,255,0.6)',
                  padding: 0,
                }}
              >
                <svg width="14" height="14" viewBox="0 0 16 16" fill="currentColor">
                  <path d="M3.72 3.72a.75.75 0 011.06 0L8 6.94l3.22-3.22a.75.75 0 111.06 1.06L9.06 8l3.22 3.22a.75.75 0 11-1.06 1.06L8 9.06l-3.22 3.22a.75.75 0 01-1.06-1.06L6.94 8 3.72 4.78a.75.75 0 010-1.06z"/>
                </svg>
              </button>
            </div>
            {/* URL field */}
            <div style={{ position: 'relative' }}>
              <div style={{ position: 'absolute', left: 14, top: 12, color: 'rgba(255,255,255,0.5)', pointerEvents: 'none' }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                  <circle cx="12" cy="12" r="10"/>
                  <ellipse cx="12" cy="12" rx="4" ry="10"/>
                  <path d="M2 12h20"/>
                </svg>
              </div>
              <input
                type="url" placeholder="https://example.com"
                style={{
                  width: '100%', height: 44, padding: '0 44px 0 44px',
                  background: 'var(--glass-inner)',
                  backdropFilter: 'blur(var(--blur-sm))',
                  WebkitBackdropFilter: 'blur(var(--blur-sm))',
                  border: '0.5px solid var(--glass-border)',
                  borderRadius: 'var(--r-md)',
                  color: '#fff',
                  font: 'var(--text-body)',
                  outline: 'none',
                  boxSizing: 'border-box',
                }}
              />
              <div style={{ position: 'absolute', right: 14, top: 12, color: 'rgba(255,255,255,0.5)' }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M7 17L17 7M17 7H7M17 7V17"/>
                </svg>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Search with Scope Bar" description="Search field paired with a glass segmented control to filter results by content type.">
        <Preview gradient>
          <div style={{ maxWidth: 460 }}>
            <GlassSearch placeholder="Search files and folders" />
            <div style={{ marginTop: 12 }}>
              <GlassSegment
                items={[
                  { label: 'All', value: 'all' },
                  { label: 'Documents', value: 'documents' },
                  { label: 'Images', value: 'images' },
                  { label: 'Videos', value: 'videos' },
                ]}
                value={searchScope}
                onChange={setSearchScope}
              />
            </div>
            <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.5)', marginTop: 10, marginBottom: 0 }}>
              Searching in: <strong style={{ color: 'rgba(255,255,255,0.8)' }}>{searchScope.charAt(0).toUpperCase() + searchScope.slice(1)}</strong>
            </p>
          </div>
        </Preview>
      </Section>
    </div>
  )
}
