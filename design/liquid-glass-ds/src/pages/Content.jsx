import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassList, GlassListItem, GlassToggle, GlassButton } from '../components/Glass'

export default function Content() {
  const [listToggle, setListToggle] = useState(true)
  const [openSections, setOpenSections] = useState([0])
  const [singleSelect, setSingleSelect] = useState(1)
  const [multiSelect, setMultiSelect] = useState([0, 2, 4])

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Content</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Typography, lists, tables, charts, and gauges for displaying structured content.
      </p>

      <Section title="Labels" description="Four-level typographic hierarchy for content organization. Each level uses progressively lighter color and smaller size.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            <div>
              <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 0.5 }}>Primary</span>
              <p style={{ font: 'var(--text-large-title)', color: '#fff', margin: '2px 0 0' }}>Welcome Back</p>
            </div>
            <div>
              <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 0.5 }}>Secondary</span>
              <p style={{ font: 'var(--text-title2)', color: 'rgba(255,255,255,0.85)', margin: '2px 0 0' }}>Your library is up to date</p>
            </div>
            <div>
              <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 0.5 }}>Tertiary</span>
              <p style={{ font: 'var(--text-body)', color: 'rgba(255,255,255,0.6)', margin: '2px 0 0' }}>Last synced 3 minutes ago across all your devices.</p>
            </div>
            <div>
              <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 0.5 }}>Quaternary</span>
              <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.35)', margin: '2px 0 0' }}>Build 26.0 (24A335) — All rights reserved.</p>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Lists" description="Grouped lists with glass material. Items can have accessories like chevrons, checkmarks, and toggles.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16, maxWidth: 400 }}>
            <GlassList header="General">
              <GlassListItem
                onClick={() => {}}
                accessory={
                  <svg width="8" height="14" viewBox="0 0 8 14" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M1 1l6 6-6 6"/></svg>
                }
              >
                <span style={{ font: 'var(--text-body)' }}>Notifications</span>
              </GlassListItem>
              <GlassListItem
                onClick={() => {}}
                accessory={
                  <svg width="8" height="14" viewBox="0 0 8 14" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M1 1l6 6-6 6"/></svg>
                }
              >
                <span style={{ font: 'var(--text-body)' }}>Sounds & Haptics</span>
              </GlassListItem>
              <GlassListItem
                onClick={() => {}}
                accessory={
                  <svg width="8" height="14" viewBox="0 0 8 14" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M1 1l6 6-6 6"/></svg>
                }
              >
                <span style={{ font: 'var(--text-body)' }}>Focus</span>
              </GlassListItem>
            </GlassList>

            <GlassList header="Preferences">
              <GlassListItem
                accessory={
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                }
              >
                <span style={{ font: 'var(--text-body)' }}>Automatic</span>
              </GlassListItem>
              <GlassListItem>
                <span style={{ font: 'var(--text-body)' }}>Light</span>
              </GlassListItem>
              <GlassListItem>
                <span style={{ font: 'var(--text-body)' }}>Dark</span>
              </GlassListItem>
            </GlassList>

            <GlassList header="Controls">
              <GlassListItem
                accessory={<GlassToggle checked={listToggle} onChange={() => setListToggle(!listToggle)} />}
              >
                <span style={{ font: 'var(--text-body)' }}>Wi-Fi</span>
              </GlassListItem>
              <GlassListItem
                accessory={<GlassToggle checked={false} disabled />}
              >
                <span style={{ font: 'var(--text-body)' }}>Bluetooth</span>
              </GlassListItem>
            </GlassList>
          </div>
        </Preview>
      </Section>

      <Section title="Tables" description="Structured data in a glass table. Useful for specifications, metrics, and reference data.">
        <SpecTable
          headers={['Device', 'Display', 'Chip', 'Storage']}
          rows={[
            ['iPhone 17 Pro', '6.3" OLED', 'A19 Pro', '256GB'],
            ['iPad Pro M5', '13" OLED', 'M5', '512GB'],
            ['MacBook Air', '15.3" Liquid Retina', 'M5', '512GB'],
            ['Apple Watch Ultra 3', '2.1" OLED', 'S11', '64GB'],
          ]}
        />
      </Section>

      <Section title="Charts" description="Simple CSS-based charts for data visualization. Bar chart and pie chart examples.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 40, flexWrap: 'wrap', alignItems: 'flex-end' }}>
            <div>
              <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.6)', marginBottom: 12 }}>Weekly Activity</p>
              <div style={{ display: 'flex', gap: 6, alignItems: 'flex-end', height: 120 }}>
                {[65, 40, 85, 55, 90, 70, 45].map((val, i) => (
                  <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
                    <div style={{
                      width: 24, height: `${val}%`,
                      background: i === 4 ? 'var(--blue)' : 'rgba(255,255,255,0.3)',
                      borderRadius: 4,
                    }} />
                    <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.5)' }}>
                      {['M', 'T', 'W', 'T', 'F', 'S', 'S'][i]}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            <div>
              <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.6)', marginBottom: 12 }}>Storage</p>
              <div style={{
                width: 120, height: 120, borderRadius: '50%',
                background: 'conic-gradient(var(--blue) 0deg 144deg, var(--green) 144deg 216deg, var(--orange) 216deg 270deg, var(--purple) 270deg 324deg, rgba(255,255,255,0.2) 324deg 360deg)',
                boxShadow: 'inset 0 0 0 2px rgba(255,255,255,0.1)',
              }} />
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px 12px', marginTop: 8 }}>
                {[
                  { color: 'var(--blue)', label: 'Apps' },
                  { color: 'var(--green)', label: 'Media' },
                  { color: 'var(--orange)', label: 'Photos' },
                  { color: 'var(--purple)', label: 'Other' },
                ].map((item) => (
                  <div key={item.label} style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                    <div style={{ width: 8, height: 8, borderRadius: 2, background: item.color }} />
                    <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.6)' }}>{item.label}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Gauges" description="Circular arc gauges and linear gauges for displaying measured values.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 40, flexWrap: 'wrap', alignItems: 'center' }}>
            <div style={{ textAlign: 'center' }}>
              <div style={{
                width: 120, height: 120, borderRadius: '50%', position: 'relative',
                background: `conic-gradient(var(--green) 0deg ${0.72 * 360}deg, rgba(255,255,255,0.12) ${0.72 * 360}deg 360deg)`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <div style={{
                  width: 96, height: 96, borderRadius: '50%',
                  background: 'rgba(0,0,0,0.3)',
                  backdropFilter: 'blur(16px)',
                  WebkitBackdropFilter: 'blur(16px)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  flexDirection: 'column',
                }}>
                  <span style={{ font: 'var(--text-title1)', color: '#fff' }}>72</span>
                  <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.5)' }}>%</span>
                </div>
              </div>
              <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.6)', marginTop: 8, marginBottom: 0 }}>Battery</p>
            </div>

            <div style={{ flex: 1, minWidth: 200, display: 'flex', flexDirection: 'column', gap: 16 }}>
              {[
                { label: 'CPU', value: 45, color: 'var(--green)' },
                { label: 'Memory', value: 68, color: 'var(--orange)' },
                { label: 'Disk', value: 82, color: 'var(--red)' },
              ].map((gauge) => (
                <div key={gauge.label}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                    <span style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.7)' }}>{gauge.label}</span>
                    <span style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.5)' }}>{gauge.value}%</span>
                  </div>
                  <div style={{
                    width: '100%', height: 6, borderRadius: 3,
                    background: 'rgba(255,255,255,0.12)', overflow: 'hidden',
                  }}>
                    <div style={{
                      width: `${gauge.value}%`, height: '100%', borderRadius: 3,
                      background: gauge.color,
                      transition: 'width 400ms var(--ease)',
                    }} />
                  </div>
                </div>
              ))}
            </div>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          Activity Rings
          ============================================================ */}
      <Section title="Activity Rings" description="Concentric SVG arc rings showing move, exercise, and stand progress. Inspired by Apple Watch.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 40, flexWrap: 'wrap', alignItems: 'flex-end', justifyContent: 'center' }}>
            {[
              { label: 'Small', size: 80 },
              { label: 'Medium', size: 120 },
              { label: 'Large', size: 180 },
            ].map(({ label, size }) => {
              const rings = [
                { name: 'Move', color: 'var(--red)', r: 52, progress: 0.78 },
                { name: 'Exercise', color: 'var(--green)', r: 40, progress: 0.62 },
                { name: 'Stand', color: 'var(--cyan)', r: 28, progress: 0.91 },
              ]
              return (
                <div key={label} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                  <svg width={size} height={size} viewBox="0 0 120 120">
                    {rings.map(({ name, color, r, progress }) => {
                      const circumference = 2 * Math.PI * r
                      const offset = circumference * (1 - progress)
                      return (
                        <g key={name}>
                          {/* Background track */}
                          <circle
                            cx="60" cy="60" r={r}
                            fill="none" stroke={color} strokeWidth="10"
                            opacity="0.15"
                          />
                          {/* Progress arc */}
                          <circle
                            cx="60" cy="60" r={r}
                            fill="none" stroke={color} strokeWidth="10"
                            strokeLinecap="round"
                            strokeDasharray={circumference}
                            strokeDashoffset={offset}
                            transform="rotate(-90 60 60)"
                          />
                        </g>
                      )
                    })}
                  </svg>
                  <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.7)' }}>{label} ({size}px)</span>
                </div>
              )
            })}
          </div>
          {/* Legend */}
          <div style={{ display: 'flex', gap: 20, justifyContent: 'center', marginTop: 16 }}>
            {[
              { color: 'var(--red)', label: 'Move 78%' },
              { color: 'var(--green)', label: 'Exercise 62%' },
              { color: 'var(--cyan)', label: 'Stand 91%' },
            ].map((item) => (
              <div key={item.label} style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <div style={{ width: 10, height: 10, borderRadius: '50%', background: item.color }} />
                <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.6)' }}>{item.label}</span>
              </div>
            ))}
          </div>
        </Preview>

        <SpecTable
          headers={['Ring', 'Color', 'Radius', 'Usage']}
          rows={[
            ['Move (outer)', '--red', 'r=52, stroke-width 10', 'Daily movement calories'],
            ['Exercise (middle)', '--green', 'r=40, stroke-width 10', 'Active workout minutes'],
            ['Stand (inner)', '--cyan', 'r=28, stroke-width 10', 'Hourly stand goals'],
          ]}
        />
      </Section>

      {/* ============================================================
          Image Display
          ============================================================ */}
      <Section title="Image Display" description="Mock image containers with different content modes. See the full Image Views page for detailed patterns.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap' }}>
            {[
              { label: 'Cover', fit: 'cover' },
              { label: 'Contain', fit: 'contain' },
              { label: 'Fill', fit: 'fill' },
            ].map(({ label, fit }) => (
              <div key={label} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                <div style={{
                  width: 160, height: 120, borderRadius: 'var(--r-lg)',
                  overflow: 'hidden',
                  border: '0.5px solid rgba(255,255,255,0.15)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  background: fit === 'contain' ? 'rgba(0,0,0,0.3)' : 'none',
                }}>
                  <div style={{
                    width: fit === 'cover' ? '120%' : (fit === 'contain' ? '80%' : '100%'),
                    height: fit === 'cover' ? '120%' : (fit === 'contain' ? '80%' : '100%'),
                    background: 'linear-gradient(135deg, #FF3B30 0%, #FF9500 30%, #FFCC00 50%, #34C759 70%, #007AFF 100%)',
                    borderRadius: fit === 'contain' ? 4 : 0,
                  }} />
                </div>
                <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.7)' }}>object-fit: {fit}</span>
              </div>
            ))}
          </div>
        </Preview>
        <p style={{ font: 'var(--text-footnote)', color: 'var(--label-tertiary)', marginTop: 4 }}>
          For loading states, galleries, and corner masking, see the <a href="/image-views" style={{ color: 'var(--blue)' }}>Image Views</a> page.
        </p>
      </Section>

      {/* ============================================================
          Swipe Actions
          ============================================================ */}
      <Section title="Swipe Actions" description="List items with swipe-to-reveal actions. Trailing swipe reveals destructive and secondary actions; leading swipe reveals a quick action.">
        <Preview gradient>
          <div style={{ maxWidth: 400, display: 'flex', flexDirection: 'column', gap: 1, borderRadius: 'var(--r-lg)', overflow: 'hidden' }}>
            {/* Item 1: Trailing actions revealed (swiped left) */}
            <div style={{ position: 'relative', height: 52, overflow: 'hidden' }}>
              <div style={{
                position: 'absolute', right: 0, top: 0, bottom: 0,
                display: 'flex',
              }}>
                <button style={{
                  width: 72, height: '100%', border: 'none', cursor: 'pointer',
                  background: 'var(--orange)', color: '#fff',
                  font: 'var(--text-subhead)', fontWeight: 600,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>Archive</button>
                <button style={{
                  width: 72, height: '100%', border: 'none', cursor: 'pointer',
                  background: 'var(--red)', color: '#fff',
                  font: 'var(--text-subhead)', fontWeight: 600,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>Delete</button>
              </div>
              <div style={{
                position: 'relative',
                height: '100%',
                background: 'var(--glass-bg-thick)',
                backdropFilter: 'blur(48px) saturate(200%)',
                WebkitBackdropFilter: 'blur(48px) saturate(200%)',
                display: 'flex', alignItems: 'center', padding: '0 16px',
                transform: 'translateX(-144px)',
                transition: 'transform var(--dur) var(--ease)',
                borderBottom: '0.5px solid var(--glass-border)',
              }}>
                <span style={{ font: 'var(--text-body)', color: '#fff' }}>Inbox Item 1</span>
              </div>
            </div>

            {/* Item 2: Leading action revealed (swiped right) */}
            <div style={{ position: 'relative', height: 52, overflow: 'hidden' }}>
              <div style={{
                position: 'absolute', left: 0, top: 0, bottom: 0,
                display: 'flex',
              }}>
                <button style={{
                  width: 72, height: '100%', border: 'none', cursor: 'pointer',
                  background: 'var(--blue)', color: '#fff',
                  font: 'var(--text-subhead)', fontWeight: 600,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>Pin</button>
              </div>
              <div style={{
                position: 'relative',
                height: '100%',
                background: 'var(--glass-bg-thick)',
                backdropFilter: 'blur(48px) saturate(200%)',
                WebkitBackdropFilter: 'blur(48px) saturate(200%)',
                display: 'flex', alignItems: 'center', padding: '0 16px',
                transform: 'translateX(72px)',
                transition: 'transform var(--dur) var(--ease)',
                borderBottom: '0.5px solid var(--glass-border)',
              }}>
                <span style={{ font: 'var(--text-body)', color: '#fff' }}>Inbox Item 2</span>
              </div>
            </div>

            {/* Item 3: Normal (not swiped) */}
            <div style={{ position: 'relative', height: 52, overflow: 'hidden' }}>
              <div style={{
                position: 'relative',
                height: '100%',
                background: 'var(--glass-bg-thick)',
                backdropFilter: 'blur(48px) saturate(200%)',
                WebkitBackdropFilter: 'blur(48px) saturate(200%)',
                display: 'flex', alignItems: 'center', padding: '0 16px',
              }}>
                <span style={{ font: 'var(--text-body)', color: '#fff' }}>Inbox Item 3</span>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          Reorderable List
          ============================================================ */}
      <Section title="Reorderable List" description="List with drag handles indicating reorderable items. One item shown in the 'grabbed' state with lift and shadow.">
        <Preview gradient>
          <div style={{ maxWidth: 400 }}>
            <GlassList header="Favorites">
              {['Photos', 'Camera', 'Messages', 'Weather', 'Notes'].map((item, i) => {
                const isGrabbed = i === 2
                return (
                  <div
                    key={item}
                    style={{
                      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                      padding: '12px 16px',
                      borderBottom: '0.5px solid rgba(255,255,255,0.08)',
                      background: isGrabbed ? 'var(--glass-bg-hover)' : 'transparent',
                      transform: isGrabbed ? 'translateY(-2px) scale(1.02)' : 'none',
                      boxShadow: isGrabbed ? 'var(--glass-shadow-lg)' : 'none',
                      opacity: (!isGrabbed && i !== 2) ? 0.9 : 1,
                      borderRadius: isGrabbed ? 'var(--r-sm)' : 0,
                      position: 'relative',
                      zIndex: isGrabbed ? 10 : 1,
                      transition: 'all var(--dur) var(--ease)',
                    }}
                  >
                    <span style={{ font: 'var(--text-body)', color: '#fff' }}>{item}</span>
                    {/* Grip / drag handle icon (three horizontal lines) */}
                    <svg width="18" height="18" viewBox="0 0 18 18" fill="none" style={{ flexShrink: 0 }}>
                      <line x1="4" y1="5" x2="14" y2="5" stroke="var(--label-tertiary)" strokeWidth="1.5" strokeLinecap="round" />
                      <line x1="4" y1="9" x2="14" y2="9" stroke="var(--label-tertiary)" strokeWidth="1.5" strokeLinecap="round" />
                      <line x1="4" y1="13" x2="14" y2="13" stroke="var(--label-tertiary)" strokeWidth="1.5" strokeLinecap="round" />
                    </svg>
                  </div>
                )
              })}
            </GlassList>
            <p style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginTop: 8, textAlign: 'center' }}>
              Drag handles indicate reorderable items
            </p>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          Expandable / Accordion
          ============================================================ */}
      <Section title="Expandable / Accordion" description="Collapsible sections in a grouped list. Chevron rotates on expand and content animates with smooth height transition.">
        <Preview gradient>
          <div style={{
            maxWidth: 400,
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(48px) saturate(200%)',
            WebkitBackdropFilter: 'blur(48px) saturate(200%)',
            borderRadius: 'var(--r-lg)',
            border: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-shadow), var(--glass-specular)',
            overflow: 'hidden',
          }}>
            {[
              { title: 'Getting Started', children: ['Introduction', 'Installation', 'Quick Start'] },
              { title: 'Components', children: ['Buttons', 'Inputs', 'Cards'] },
              { title: 'Advanced', children: ['Theming', 'Animations', 'Performance'] },
            ].map((section, sIdx) => {
              const isOpen = openSections.includes(sIdx)
              return (
                <div key={section.title}>
                  {/* Section header */}
                  <button
                    onClick={() => {
                      setOpenSections(prev =>
                        prev.includes(sIdx)
                          ? prev.filter(i => i !== sIdx)
                          : [...prev, sIdx]
                      )
                    }}
                    style={{
                      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                      width: '100%', padding: '14px 16px',
                      background: 'none', border: 'none', cursor: 'pointer',
                      borderBottom: '0.5px solid rgba(255,255,255,0.08)',
                    }}
                  >
                    <span style={{ font: 'var(--text-headline)', color: '#fff' }}>{section.title}</span>
                    <svg
                      width="12" height="12" viewBox="0 0 12 12" fill="none"
                      stroke="rgba(255,255,255,0.5)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                      style={{
                        transform: isOpen ? 'rotate(90deg)' : 'rotate(0deg)',
                        transition: 'transform var(--dur) var(--ease-spring)',
                      }}
                    >
                      <path d="M4 2l4 4-4 4" />
                    </svg>
                  </button>
                  {/* Collapsible content area */}
                  <div style={{
                    maxHeight: isOpen ? 200 : 0,
                    overflow: 'hidden',
                    transition: 'max-height var(--dur-slow) var(--ease)',
                  }}>
                    {section.children.map((child, cIdx) => (
                      <div
                        key={child}
                        style={{
                          padding: '10px 16px 10px 32px',
                          font: 'var(--text-body)', color: 'rgba(255,255,255,0.7)',
                          borderBottom: cIdx < section.children.length - 1 ? '0.5px solid rgba(255,255,255,0.05)' : 'none',
                        }}
                      >
                        {child}
                      </div>
                    ))}
                  </div>
                </div>
              )
            })}
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          Selection Modes
          ============================================================ */}
      <Section title="Selection Modes" description="Single-select and multi-select list patterns. Single select uses a checkmark accessory; multi-select uses filled circle checkboxes.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap', maxWidth: 800 }}>
            {/* Single Select */}
            <div style={{ flex: 1, minWidth: 280 }}>
              <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 8 }}>Single Select</p>
              <GlassList>
                {['Automatic', 'Light', 'Dark', 'High Contrast'].map((item, i) => (
                  <GlassListItem
                    key={item}
                    onClick={() => setSingleSelect(i)}
                    accessory={
                      singleSelect === i
                        ? <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                        : null
                    }
                  >
                    <span style={{ font: 'var(--text-body)' }}>{item}</span>
                  </GlassListItem>
                ))}
              </GlassList>
            </div>

            {/* Multi Select */}
            <div style={{ flex: 1, minWidth: 280 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
                <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 0.5, margin: 0 }}>Multi Select</p>
                <span style={{ font: 'var(--text-caption1)', color: 'var(--blue)', fontWeight: 600 }}>{multiSelect.length} selected</span>
              </div>
              <GlassList>
                {['Photos', 'Camera', 'Maps', 'Notes', 'Calendar'].map((item, i) => {
                  const isSelected = multiSelect.includes(i)
                  return (
                    <GlassListItem
                      key={item}
                      onClick={() => {
                        setMultiSelect(prev =>
                          prev.includes(i) ? prev.filter(x => x !== i) : [...prev, i]
                        )
                      }}
                      accessory={
                        <div style={{
                          width: 22, height: 22, borderRadius: '50%',
                          background: isSelected ? 'var(--blue)' : 'transparent',
                          border: isSelected ? 'none' : '2px solid rgba(255,255,255,0.3)',
                          display: 'flex', alignItems: 'center', justifyContent: 'center',
                          transition: 'all var(--dur-fast) var(--ease)',
                        }}>
                          {isSelected && (
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                              <polyline points="20 6 9 17 4 12" />
                            </svg>
                          )}
                        </div>
                      }
                    >
                      <span style={{ font: 'var(--text-body)' }}>{item}</span>
                    </GlassListItem>
                  )
                })}
              </GlassList>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          Pull to Refresh
          ============================================================ */}
      <Section title="Pull to Refresh" description="Visual mock of the pull-to-refresh pattern showing the pulled and refreshing states.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 32, flexWrap: 'wrap', justifyContent: 'center' }}>
            {/* Pulled state */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, minWidth: 200 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8 }}>Pulled State</span>
              {/* Spinner arrow icon */}
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.5)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ marginBottom: 4 }}>
                <polyline points="1 4 1 10 7 10" />
                <path d="M3.51 15a9 9 0 100-6.97L1 10" />
              </svg>
              <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.4)', marginBottom: 8 }}>Release to refresh</span>
              <div style={{
                width: 200,
                background: 'var(--glass-bg-thick)',
                backdropFilter: 'blur(48px) saturate(200%)',
                WebkitBackdropFilter: 'blur(48px) saturate(200%)',
                borderRadius: 'var(--r-lg)',
                border: '0.5px solid var(--glass-border)',
                boxShadow: 'var(--glass-shadow)',
                overflow: 'hidden',
              }}>
                {['Item A', 'Item B', 'Item C'].map((item, i) => (
                  <div key={item} style={{
                    padding: '10px 14px',
                    font: 'var(--text-body)', color: 'rgba(255,255,255,0.8)',
                    borderBottom: i < 2 ? '0.5px solid rgba(255,255,255,0.08)' : 'none',
                  }}>{item}</div>
                ))}
              </div>
            </div>

            {/* Refreshing state */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, minWidth: 200 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8 }}>Refreshing State</span>
              {/* Spinning indicator */}
              <div style={{
                width: 20, height: 20, marginBottom: 4,
                border: '2.5px solid rgba(255,255,255,0.15)',
                borderTopColor: 'var(--blue)',
                borderRadius: '50%',
                animation: 'spin 0.8s linear infinite',
              }} />
              <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.4)', marginBottom: 8 }}>Updating...</span>
              <div style={{
                width: 200,
                background: 'var(--glass-bg-thick)',
                backdropFilter: 'blur(48px) saturate(200%)',
                WebkitBackdropFilter: 'blur(48px) saturate(200%)',
                borderRadius: 'var(--r-lg)',
                border: '0.5px solid var(--glass-border)',
                boxShadow: 'var(--glass-shadow)',
                overflow: 'hidden',
              }}>
                {['Item A', 'Item B', 'Item C'].map((item, i) => (
                  <div key={item} style={{
                    padding: '10px 14px',
                    font: 'var(--text-body)', color: 'rgba(255,255,255,0.8)',
                    borderBottom: i < 2 ? '0.5px solid rgba(255,255,255,0.08)' : 'none',
                  }}>{item}</div>
                ))}
              </div>
            </div>
          </div>
          <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
        </Preview>
      </Section>

      {/* ============================================================
          Empty State
          ============================================================ */}
      <Section title="Empty State" description="What to show when a list has no items. Centered icon, title, description, and an action button.">
        <Preview gradient>
          <div style={{
            maxWidth: 360,
            margin: '0 auto',
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(48px) saturate(200%)',
            WebkitBackdropFilter: 'blur(48px) saturate(200%)',
            borderRadius: 'var(--r-xl)',
            border: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-shadow), var(--glass-specular)',
            padding: '48px 32px',
            display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center',
          }}>
            {/* Tray / inbox icon */}
            <svg width="48" height="48" viewBox="0 0 48 48" fill="none" stroke="var(--label-tertiary)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ marginBottom: 16 }}>
              <path d="M8 32h8l4 6h8l4-6h8" />
              <rect x="6" y="10" width="36" height="28" rx="4" />
              <path d="M6 32h36" />
            </svg>
            <h3 style={{ font: 'var(--text-title2)', color: '#fff', margin: '0 0 6px' }}>No Items Yet</h3>
            <p style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)', margin: '0 0 24px' }}>
              Items you add will appear here.
            </p>
            <GlassButton variant="filled">Add Item</GlassButton>
          </div>
        </Preview>
      </Section>
    </div>
  )
}
