import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { GlassPanel, GlassButton } from '../components/Glass'

function MenuItem({ label, shortcut, icon, destructive, disabled }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12, padding: '8px 12px',
      borderRadius: 'var(--r-sm)', cursor: disabled ? 'default' : 'pointer',
      color: destructive ? 'var(--red)' : disabled ? 'var(--label-tertiary)' : 'var(--label)',
      transition: 'background var(--motion-fast) var(--ease-io), transform var(--motion-fast) var(--spring)',
      opacity: disabled ? 0.5 : 1,
    }}
      onMouseEnter={(e) => { if (!disabled) e.currentTarget.style.background = 'var(--fill-tertiary)' }}
      onMouseLeave={(e) => { e.currentTarget.style.background = 'transparent' }}
    >
      {icon && <span style={{ width: 18, height: 18, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{icon}</span>}
      <span style={{ flex: 1, font: 'var(--text-body)', fontSize: 14 }}>{label}</span>
      {shortcut && <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', fontFamily: 'var(--font-mono)', flexShrink: 0 }}>{shortcut}</span>}
    </div>
  )
}

function MenuDivider() {
  return <div style={{ height: 0.5, background: 'var(--separator)', margin: '4px 12px' }} />
}

export default function Menus() {
  const [popupValue, setPopupValue] = useState('Medium')
  const [popupOpen, setPopupOpen] = useState(false)
  const [disclosure1, setDisclosure1] = useState(true)
  const [disclosure2, setDisclosure2] = useState(false)

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Menus</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Context menus, pull-down buttons, pop-up buttons, disclosure groups, and edit menus built with Liquid Glass.
      </p>

      <Section title="Context Menu" description="Floating glass menu with items, icons, keyboard shortcuts, dividers, and a destructive item.">
        <Preview gradient>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <GlassPanel style={{ width: 240, padding: '6px' }}>
              <MenuItem
                label="Open"
                shortcut="&#8984;O"
                icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>}
              />
              <MenuItem
                label="Duplicate"
                shortcut="&#8984;D"
                icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>}
              />
              <MenuItem
                label="Rename"
                icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>}
              />
              <MenuDivider />
              <MenuItem
                label="Share"
                shortcut="&#8984;&#8679;S"
                icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" y1="2" x2="12" y2="15"/></svg>}
              />
              <MenuItem
                label="Move to Folder"
                icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 19a2 2 0 01-2 2H4a2 2 0 01-2-2V5a2 2 0 012-2h5l2 3h9a2 2 0 012 2z"/></svg>}
              />
              <MenuDivider />
              <MenuItem
                label="Delete"
                shortcut="&#8984;&#9003;"
                destructive
                icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>}
              />
            </GlassPanel>
          </div>
        </Preview>
      </Section>

      <Section title="Pull-Down Button" description="A glass button that reveals a dropdown menu on click.">
        <Preview gradient>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <div style={{ position: 'relative', display: 'inline-block' }}>
              <GlassButton variant="glass" style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                Actions
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
              </GlassButton>
              <div style={{ position: 'absolute', top: '100%', left: 0, marginTop: 6, zIndex: 10 }}>
                <GlassPanel style={{ width: 200, padding: '6px' }}>
                  <MenuItem label="New File" shortcut="&#8984;N" />
                  <MenuItem label="New Folder" shortcut="&#8984;&#8679;N" />
                  <MenuDivider />
                  <MenuItem label="Import" />
                  <MenuItem label="Export" />
                </GlassPanel>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Pop-Up Button" description="Shows the current selection with a glass dropdown to change it.">
        <Preview gradient>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <div style={{ position: 'relative', display: 'inline-block' }}>
              <button
                onClick={() => setPopupOpen(!popupOpen)}
                style={{
                  display: 'inline-flex', alignItems: 'center', gap: 8, padding: '10px 16px',
                  background: 'var(--glass-inner)', backdropFilter: 'blur(16px)', WebkitBackdropFilter: 'blur(16px)',
                  border: '0.5px solid var(--glass-border-inner)', borderRadius: 'var(--r-lg)',
                  boxShadow: 'var(--glass-shadow-inner), 0 1px 3px rgba(0,0,0,0.04)',
                  cursor: 'pointer', font: 'var(--text-body)', fontWeight: 600, color: 'var(--label)',
                }}
              >
                Size: {popupValue}
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                  <polyline points="6 9 12 15 18 9"/>
                </svg>
              </button>
              {popupOpen && (
                <div style={{ position: 'absolute', top: '100%', left: 0, marginTop: 6, zIndex: 10 }}>
                  <GlassPanel style={{ width: 180, padding: '6px' }}>
                    {['Small', 'Medium', 'Large', 'Extra Large'].map((size) => (
                      <div
                        key={size}
                        onClick={() => { setPopupValue(size); setPopupOpen(false) }}
                        style={{
                          display: 'flex', alignItems: 'center', gap: 10, padding: '8px 12px',
                          borderRadius: 'var(--r-sm)', cursor: 'pointer', font: 'var(--text-body)', fontSize: 14,
                          color: popupValue === size ? 'var(--blue)' : 'var(--label)',
                          fontWeight: popupValue === size ? 600 : 400,
                          transition: 'background var(--dur-fast) var(--ease)',
                        }}
                        onMouseEnter={(e) => e.currentTarget.style.background = 'var(--fill-tertiary)'}
                        onMouseLeave={(e) => e.currentTarget.style.background = 'transparent'}
                      >
                        <span style={{ width: 18, textAlign: 'center' }}>
                          {popupValue === size && <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>}
                        </span>
                        {size}
                      </div>
                    ))}
                  </GlassPanel>
                </div>
              )}
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Disclosure" description="Expandable sections with a rotation animation on the chevron indicator.">
        <Preview gradient>
          <div style={{ maxWidth: 400 }}>
            <GlassPanel style={{ padding: 0, overflow: 'hidden' }}>
              {[
                { title: 'General', open: disclosure1, toggle: () => setDisclosure1(!disclosure1), content: 'Configure general settings like language, region, and date format for your account.' },
                { title: 'Advanced', open: disclosure2, toggle: () => setDisclosure2(!disclosure2), content: 'Advanced options include developer mode, experimental features, and diagnostic logging.' },
              ].map((item, i, arr) => (
                <div key={item.title}>
                  <button
                    onClick={item.toggle}
                    style={{
                      display: 'flex', alignItems: 'center', width: '100%', padding: '14px 20px',
                      background: 'transparent', border: 'none', cursor: 'pointer', gap: 10,
                      borderBottom: (item.open || i < arr.length - 1) ? '0.5px solid var(--separator)' : 'none',
                    }}
                  >
                    <svg
                      width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="var(--label-secondary)" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"
                      style={{
                        transform: item.open ? 'rotate(90deg)' : 'rotate(0deg)',
                        transition: 'transform var(--dur) var(--ease)',
                        flexShrink: 0,
                      }}
                    >
                      <polyline points="9 18 15 12 9 6"/>
                    </svg>
                    <span style={{ font: 'var(--text-body)', fontWeight: 600, color: 'var(--label)', textAlign: 'left' }}>{item.title}</span>
                  </button>
                  <div style={{
                    overflow: 'hidden',
                    maxHeight: item.open ? 200 : 0,
                    transition: 'max-height var(--dur-slow) var(--ease)',
                  }}>
                    <div style={{ padding: '12px 20px 16px 42px' }}>
                      <p style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', margin: 0 }}>{item.content}</p>
                    </div>
                  </div>
                </div>
              ))}
            </GlassPanel>
          </div>
        </Preview>
      </Section>

      <Section title="Edit Menu" description="Standard edit menu with Cut, Copy, Paste, and Select All actions plus keyboard shortcuts.">
        <Preview gradient>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <GlassPanel style={{ width: 220, padding: '6px' }}>
              <MenuItem
                label="Cut"
                shortcut="&#8984;X"
                icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="6" cy="6" r="3"/><circle cx="6" cy="18" r="3"/><line x1="20" y1="4" x2="8.12" y2="15.88"/><line x1="14.47" y1="14.48" x2="20" y2="20"/><line x1="8.12" y1="8.12" x2="12" y2="12"/></svg>}
              />
              <MenuItem
                label="Copy"
                shortcut="&#8984;C"
                icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>}
              />
              <MenuItem
                label="Paste"
                shortcut="&#8984;V"
                icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M16 4h2a2 2 0 012 2v14a2 2 0 01-2 2H6a2 2 0 01-2-2V6a2 2 0 012-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/></svg>}
              />
              <MenuDivider />
              <MenuItem
                label="Select All"
                shortcut="&#8984;A"
                icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><path d="M9 3v18"/><path d="M15 3v18"/><path d="M3 9h18"/><path d="M3 15h18"/></svg>}
              />
            </GlassPanel>
          </div>
        </Preview>
      </Section>
    </div>
  )
}
