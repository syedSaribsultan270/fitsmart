import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

/* ------------------------------------------------------------------ */
/*  Chevron separator SVG                                             */
/* ------------------------------------------------------------------ */
function Chevron() {
  return (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" stroke="var(--label-quaternary)" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0 }}>
      <path d="M4.5 2.5L7.5 6 4.5 9.5" />
    </svg>
  )
}

/* ------------------------------------------------------------------ */
/*  Small icons for breadcrumb-with-icons section                     */
/* ------------------------------------------------------------------ */
const icons = {
  home: (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z" />
      <polyline points="9 22 9 12 15 12 15 22" />
    </svg>
  ),
  folder: (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M22 19a2 2 0 01-2 2H4a2 2 0 01-2-2V5a2 2 0 012-2h5l2 3h9a2 2 0 012 2z" />
    </svg>
  ),
  code: (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <polyline points="16 18 22 12 16 6" />
      <polyline points="8 6 2 12 8 18" />
    </svg>
  ),
  palette: (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="13.5" cy="6.5" r="1.5" />
      <circle cx="17.5" cy="10.5" r="1.5" />
      <circle cx="8.5" cy="7.5" r="1.5" />
      <circle cx="6.5" cy="12.5" r="1.5" />
      <path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.9 0 1.7-.8 1.7-1.7 0-.4-.2-.8-.4-1.1-.3-.3-.4-.7-.4-1.1 0-.9.8-1.7 1.7-1.7H16c3.3 0 6-2.7 6-6 0-5.2-4.5-8.5-10-8.5z" />
    </svg>
  ),
}

export default function Breadcrumbs() {
  /* Pop-up breadcrumb state */
  const [openSegment, setOpenSegment] = useState(null)
  const siblings = {
    Home: ['Home', 'Recents', 'Favorites'],
    Documents: ['Documents', 'Downloads', 'Desktop', 'Pictures'],
    Projects: ['Projects', 'Archive', 'Shared'],
    'Design System': ['Design System', 'iOS App', 'Website'],
  }

  /* Truncated breadcrumb state */
  const [expanded, setExpanded] = useState(false)
  const longPath = ['Home', 'Documents', 'Work', 'Projects', 'Design', 'Subfolder', 'Current']

  const segmentStyle = (isLast) => ({
    font: 'var(--text-subhead)',
    color: isLast ? 'var(--label)' : 'var(--label-secondary)',
    fontWeight: isLast ? 600 : 400,
    cursor: isLast ? 'default' : 'pointer',
    textDecoration: 'none',
    border: 'none',
    background: 'none',
    padding: 0,
    transition: 'color 150ms var(--ease)',
  })

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Breadcrumbs</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Path-based navigation showing hierarchy. Segments are clickable, with chevron separators and glass containers.
      </p>

      {/* ============================================================
          1. Standard Breadcrumb
          ============================================================ */}
      <Section title="Standard Breadcrumb" description="Horizontal row of clickable path segments. Current segment is bold and non-clickable.">
        <Preview>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 4, height: 36,
            background: 'var(--glass-bg)',
            backdropFilter: 'blur(var(--blur-md))',
            WebkitBackdropFilter: 'blur(var(--blur-md))',
            borderRadius: 'var(--r-lg)',
            padding: '0 16px',
            border: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-shadow)',
          }}>
            {['Home', 'Documents', 'Projects', 'Design System'].map((seg, i, arr) => {
              const isLast = i === arr.length - 1
              return (
                <span key={seg} style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                  {i > 0 && <Chevron />}
                  <button
                    style={{
                      ...segmentStyle(isLast),
                      ...(isLast ? {} : { cursor: 'pointer' }),
                    }}
                    onMouseEnter={(e) => { if (!isLast) e.target.style.color = 'var(--blue)' }}
                    onMouseLeave={(e) => { if (!isLast) e.target.style.color = 'var(--label-secondary)' }}
                    onClick={(e) => { if (!isLast) e.preventDefault() }}
                  >
                    {seg}
                  </button>
                </span>
              )
            })}
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          2. Pop-up Breadcrumb
          ============================================================ */}
      <Section title="Pop-up Breadcrumb" description="Click a segment to reveal a dropdown of sibling items at that level.">
        <Preview>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 4, height: 36,
            background: 'var(--glass-bg)',
            backdropFilter: 'blur(var(--blur-md))',
            WebkitBackdropFilter: 'blur(var(--blur-md))',
            borderRadius: 'var(--r-lg)',
            padding: '0 16px',
            border: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-shadow)',
            position: 'relative',
          }}>
            {['Home', 'Documents', 'Projects', 'Design System'].map((seg, i, arr) => {
              const isLast = i === arr.length - 1
              const isOpen = openSegment === seg
              return (
                <span key={seg} style={{ display: 'inline-flex', alignItems: 'center', gap: 4, position: 'relative' }}>
                  {i > 0 && <Chevron />}
                  <button
                    style={{
                      ...segmentStyle(isLast),
                      color: isOpen ? 'var(--blue)' : (isLast ? 'var(--label)' : 'var(--label-secondary)'),
                      cursor: 'pointer',
                    }}
                    onClick={() => setOpenSegment(isOpen ? null : seg)}
                  >
                    {seg}
                  </button>

                  {/* Dropdown */}
                  {isOpen && siblings[seg] && (
                    <div style={{
                      position: 'absolute', top: '100%', left: 0, marginTop: 8, zIndex: 100,
                      background: 'var(--glass-bg-thick)',
                      backdropFilter: 'blur(var(--blur-lg))',
                      WebkitBackdropFilter: 'blur(var(--blur-lg))',
                      borderRadius: 'var(--r-md)',
                      border: '0.5px solid var(--glass-border)',
                      boxShadow: 'var(--glass-shadow-lg)',
                      padding: '4px 0',
                      minWidth: 160,
                      animation: 'breadcrumbDropIn 200ms var(--ease-spring) forwards',
                    }}>
                      {siblings[seg].map((item) => (
                        <button
                          key={item}
                          onClick={() => setOpenSegment(null)}
                          style={{
                            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                            width: '100%', padding: '8px 14px', border: 'none', background: 'none',
                            font: 'var(--text-subhead)', color: 'var(--label)', cursor: 'pointer',
                            textAlign: 'left',
                          }}
                          onMouseEnter={(e) => { e.currentTarget.style.background = 'var(--fill)' }}
                          onMouseLeave={(e) => { e.currentTarget.style.background = 'none' }}
                        >
                          {item}
                          {item === seg && (
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                              <polyline points="20 6 9 17 4 12" />
                            </svg>
                          )}
                        </button>
                      ))}
                    </div>
                  )}
                </span>
              )
            })}
          </div>
          {/* Click-away handler */}
          {openSegment && (
            <div
              onClick={() => setOpenSegment(null)}
              style={{ position: 'fixed', inset: 0, zIndex: 50 }}
            />
          )}
        </Preview>
      </Section>

      {/* ============================================================
          3. Truncated Breadcrumb
          ============================================================ */}
      <Section title="Truncated Breadcrumb" description="Long paths collapse middle segments to an ellipsis. Click to expand.">
        <style>{`
          @keyframes breadcrumbDropIn {
            from { opacity: 0; transform: scale(0.96) translateY(-4px); }
            to   { opacity: 1; transform: scale(1) translateY(0); }
          }
        `}</style>
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {/* Collapsed */}
            <div>
              <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', marginBottom: 6, display: 'block' }}>Collapsed</span>
              <div style={{
                display: 'inline-flex', alignItems: 'center', gap: 4, height: 36,
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-md))',
                WebkitBackdropFilter: 'blur(var(--blur-md))',
                borderRadius: 'var(--r-lg)',
                padding: '0 16px',
                border: '0.5px solid var(--glass-border)',
                boxShadow: 'var(--glass-shadow)',
                position: 'relative',
              }}>
                {/* Home */}
                <button style={segmentStyle(false)}>Home</button>
                <Chevron />

                {/* Ellipsis */}
                <span style={{ position: 'relative' }}>
                  <button
                    style={{
                      ...segmentStyle(false),
                      cursor: 'pointer', padding: '2px 4px', borderRadius: 'var(--r-xs)',
                    }}
                    onClick={() => setExpanded(!expanded)}
                    onMouseEnter={(e) => { e.target.style.background = 'var(--fill)' }}
                    onMouseLeave={(e) => { e.target.style.background = 'none' }}
                  >
                    ...
                  </button>

                  {expanded && (
                    <div style={{
                      position: 'absolute', top: '100%', left: 0, marginTop: 8, zIndex: 100,
                      background: 'var(--glass-bg-thick)',
                      backdropFilter: 'blur(var(--blur-lg))',
                      WebkitBackdropFilter: 'blur(var(--blur-lg))',
                      borderRadius: 'var(--r-md)',
                      border: '0.5px solid var(--glass-border)',
                      boxShadow: 'var(--glass-shadow-lg)',
                      padding: '4px 0',
                      minWidth: 140,
                      animation: 'breadcrumbDropIn 200ms var(--ease-spring) forwards',
                    }}>
                      {longPath.slice(1, -2).map((item) => (
                        <button
                          key={item}
                          onClick={() => setExpanded(false)}
                          style={{
                            display: 'block', width: '100%', padding: '8px 14px',
                            border: 'none', background: 'none',
                            font: 'var(--text-subhead)', color: 'var(--label)', cursor: 'pointer',
                            textAlign: 'left',
                          }}
                          onMouseEnter={(e) => { e.currentTarget.style.background = 'var(--fill)' }}
                          onMouseLeave={(e) => { e.currentTarget.style.background = 'none' }}
                        >
                          {item}
                        </button>
                      ))}
                    </div>
                  )}
                </span>
                <Chevron />

                {/* Second to last */}
                <button style={segmentStyle(false)}>{longPath[longPath.length - 2]}</button>
                <Chevron />

                {/* Last */}
                <button style={segmentStyle(true)}>{longPath[longPath.length - 1]}</button>
              </div>
            </div>

            {/* Expanded inline */}
            <div>
              <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', marginBottom: 6, display: 'block' }}>Expanded</span>
              <div style={{
                display: 'inline-flex', alignItems: 'center', gap: 4, height: 36,
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-md))',
                WebkitBackdropFilter: 'blur(var(--blur-md))',
                borderRadius: 'var(--r-lg)',
                padding: '0 16px',
                border: '0.5px solid var(--glass-border)',
                boxShadow: 'var(--glass-shadow)',
                flexWrap: 'wrap',
              }}>
                {longPath.map((seg, i) => {
                  const isLast = i === longPath.length - 1
                  return (
                    <span key={seg} style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                      {i > 0 && <Chevron />}
                      <button style={segmentStyle(isLast)}>{seg}</button>
                    </span>
                  )
                })}
              </div>
            </div>
          </div>
          {expanded && (
            <div onClick={() => setExpanded(false)} style={{ position: 'fixed', inset: 0, zIndex: 50 }} />
          )}
        </Preview>
      </Section>

      {/* ============================================================
          4. Breadcrumb with Icons
          ============================================================ */}
      <Section title="Breadcrumb with Icons" description="Each path segment includes a small inline icon for quick visual recognition.">
        <Preview>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 4, height: 36,
            background: 'var(--glass-bg)',
            backdropFilter: 'blur(var(--blur-md))',
            WebkitBackdropFilter: 'blur(var(--blur-md))',
            borderRadius: 'var(--r-lg)',
            padding: '0 16px',
            border: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-shadow)',
          }}>
            {[
              { label: 'Home', icon: icons.home },
              { label: 'Documents', icon: icons.folder },
              { label: 'Projects', icon: icons.code },
              { label: 'Design System', icon: icons.palette },
            ].map((seg, i, arr) => {
              const isLast = i === arr.length - 1
              return (
                <span key={seg.label} style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                  {i > 0 && <Chevron />}
                  <button
                    style={{
                      ...segmentStyle(isLast),
                      display: 'inline-flex', alignItems: 'center', gap: 4,
                    }}
                    onMouseEnter={(e) => { if (!isLast) e.currentTarget.style.color = 'var(--blue)' }}
                    onMouseLeave={(e) => { if (!isLast) e.currentTarget.style.color = 'var(--label-secondary)' }}
                  >
                    <span style={{ display: 'flex', alignItems: 'center', color: 'inherit' }}>{seg.icon}</span>
                    {seg.label}
                  </button>
                </span>
              )
            })}
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          5. Breadcrumb Specs
          ============================================================ */}
      <Section title="Breadcrumb Specs">
        <SpecTable
          headers={['Property', 'Value']}
          rows={[
            ['Height', '36px'],
            ['Font', 'subhead (15px)'],
            ['Separator', 'Chevron right, 12x12, --label-quaternary'],
            ['Gap', '4px between separator and text'],
            ['Active segment', '--label, font-weight 600'],
            ['Inactive segment', '--label-secondary, hover --blue'],
            ['Truncation threshold', '4 segments'],
          ]}
        />
      </Section>
    </div>
  )
}
