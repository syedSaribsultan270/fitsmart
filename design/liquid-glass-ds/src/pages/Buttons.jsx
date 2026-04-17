import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassButton } from '../components/Glass'

export default function Buttons() {
  const [toggleBold, setToggleBold] = useState(true)
  const [toggleItalic, setToggleItalic] = useState(false)
  const [toggleUnderline, setToggleUnderline] = useState(false)
  const [toggleStrike, setToggleStrike] = useState(false)

  const [menuOpen, setMenuOpen] = useState(false)
  const [sortValue, setSortValue] = useState('Date')

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Buttons</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Liquid Glass buttons bring depth and translucency to interactive controls. The glass variant is the signature style.
      </p>

      <Section title="Button Styles" description="Four distinct variants for different levels of emphasis. Glass is the featured variant with full frosted translucency.">
        <Preview gradient>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12, alignItems: 'center' }}>
            <GlassButton variant="glass">Glass</GlassButton>
            <GlassButton variant="filled">Filled</GlassButton>
            <GlassButton variant="tinted">Tinted</GlassButton>
            <GlassButton variant="plain">Plain</GlassButton>
          </div>
        </Preview>
      </Section>

      <Section title="Button Sizes" description="Three sizes to fit different layout contexts. All sizes are available in every variant.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {['glass', 'filled', 'tinted', 'plain'].map((variant) => (
              <div key={variant} style={{ display: 'flex', flexWrap: 'wrap', gap: 12, alignItems: 'center' }}>
                <GlassButton variant={variant} size="sm">Small</GlassButton>
                <GlassButton variant={variant} size="md">Medium</GlassButton>
                <GlassButton variant={variant} size="lg">Large</GlassButton>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      <Section title="Button States" description="Buttons respond to interaction with subtle visual feedback. Hover state brightens the glass surface; disabled state reduces opacity to 35%.">
        <Preview gradient>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12, alignItems: 'center' }}>
            <GlassButton variant="glass">Default</GlassButton>
            <GlassButton variant="glass" style={{ background: 'var(--glass-inner-hover)' }}>Hover Preview</GlassButton>
            <GlassButton variant="glass" disabled>Disabled</GlassButton>
          </div>
          <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.7)', marginTop: 12, marginBottom: 0 }}>
            Hover state is shown as a static preview. The actual hover effect applies on mouse interaction.
          </p>
        </Preview>
        <Preview gradient>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12, alignItems: 'center' }}>
            <GlassButton variant="filled">Default</GlassButton>
            <GlassButton variant="filled" disabled>Disabled</GlassButton>
            <GlassButton variant="tinted">Default</GlassButton>
            <GlassButton variant="tinted" disabled>Disabled</GlassButton>
          </div>
        </Preview>
      </Section>

      <Section title="Icon Buttons" description="Circular glass buttons for icon-only actions. Use the icon prop for a perfectly round shape.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
            <GlassButton variant="glass" icon>
              <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                <path d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"/>
              </svg>
            </GlassButton>
            <GlassButton variant="glass" icon>
              <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clipRule="evenodd"/>
              </svg>
            </GlassButton>
            <GlassButton variant="glass" icon>
              <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clipRule="evenodd"/>
              </svg>
            </GlassButton>
            <GlassButton variant="filled" icon>
              <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                <path d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"/>
              </svg>
            </GlassButton>
            <GlassButton variant="tinted" icon>
              <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clipRule="evenodd"/>
              </svg>
            </GlassButton>
          </div>
        </Preview>
        <Preview gradient>
          <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
            <GlassButton variant="glass" icon size="sm">
              <svg width="16" height="16" viewBox="0 0 20 20" fill="currentColor">
                <path d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"/>
              </svg>
            </GlassButton>
            <GlassButton variant="glass" icon size="md">
              <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                <path d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"/>
              </svg>
            </GlassButton>
            <GlassButton variant="glass" icon size="lg">
              <svg width="24" height="24" viewBox="0 0 20 20" fill="currentColor">
                <path d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"/>
              </svg>
            </GlassButton>
          </div>
        </Preview>
      </Section>

      <Section title="Pill Buttons" description="Fully rounded buttons using the pill prop. Great for tags, filters, and floating actions.">
        <Preview gradient>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12, alignItems: 'center' }}>
            <GlassButton variant="glass" pill>Glass Pill</GlassButton>
            <GlassButton variant="filled" pill>Filled Pill</GlassButton>
            <GlassButton variant="tinted" pill>Tinted Pill</GlassButton>
            <GlassButton variant="plain" pill>Plain Pill</GlassButton>
          </div>
        </Preview>
      </Section>

      <Section title="Destructive" description="Red-colored buttons for irreversible or dangerous actions. Available in filled and tinted styles.">
        <Preview gradient>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12, alignItems: 'center' }}>
            <GlassButton variant="filled" color="var(--red)">Delete</GlassButton>
            <GlassButton variant="tinted" color="var(--red)" style={{ color: 'var(--red)', borderColor: 'rgba(255,59,48,0.08)', background: 'rgba(255,59,48,0.1)' }}>Remove</GlassButton>
          </div>
        </Preview>
      </Section>

      <Section title="Button Specs" description="Sizing and spacing reference for all button sizes.">
        <SpecTable
          headers={['Size', 'Min Height', 'Padding', 'Border Radius', 'Font']}
          rows={[
            ['Small', '32px', '7px 16px', '--r-md (16px)', '--text-subhead (15px)'],
            ['Medium', '44px', '10px 22px', '--r-lg (22px)', '--text-body (17px)'],
            ['Large', '50px', '14px 28px', '--r-xl (28px)', '17px semibold'],
            ['Pill', 'Inherits size', 'Inherits size', '--r-pill (9999px)', 'Inherits size'],
            ['Icon', '44px', '0', '50%', 'N/A'],
            ['Icon Small', '32px', '0', '50%', 'N/A'],
            ['Icon Large', '56px', '0', '50%', 'N/A'],
          ]}
        />
      </Section>

      {/* ================================================================
          NEW SECTIONS — Toggle, Close, FAB, Menu, Accessibility
          ================================================================ */}

      <Section title="Toggle Buttons" description="Buttons with pressed/unpressed state for toolbar-style controls like text formatting. Each button independently toggles on or off.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            {[
              { label: 'B', weight: 700, active: toggleBold, set: setToggleBold },
              { label: 'I', weight: 400, fontStyle: 'italic', active: toggleItalic, set: setToggleItalic },
              { label: 'U', weight: 400, textDecoration: 'underline', active: toggleUnderline, set: setToggleUnderline },
              { label: 'S', weight: 400, textDecoration: 'line-through', active: toggleStrike, set: setToggleStrike },
            ].map((btn) => (
              <button
                key={btn.label}
                onClick={() => btn.set(!btn.active)}
                style={{
                  width: 40, height: 40,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  background: btn.active ? 'var(--glass-bg-tinted)' : 'var(--glass-inner)',
                  backdropFilter: 'blur(var(--blur-sm))',
                  WebkitBackdropFilter: 'blur(var(--blur-sm))',
                  border: '0.5px solid var(--glass-border)',
                  borderRadius: 'var(--r-xs)',
                  color: btn.active ? 'var(--blue)' : 'var(--label)',
                  font: 'var(--text-body)',
                  fontWeight: btn.weight,
                  fontStyle: btn.fontStyle || 'normal',
                  textDecoration: btn.textDecoration || 'none',
                  cursor: 'pointer',
                  transform: btn.active ? 'scale(0.97)' : 'scale(1)',
                  transition: 'transform var(--dur) var(--ease-spring), background var(--dur) var(--ease), color var(--dur) var(--ease)',
                }}
              >
                {btn.label}
              </button>
            ))}
          </div>
          <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.7)', marginTop: 12, marginBottom: 0 }}>
            Currently active: {[toggleBold && 'Bold', toggleItalic && 'Italic', toggleUnderline && 'Underline', toggleStrike && 'Strikethrough'].filter(Boolean).join(', ') || 'None'}
          </p>
        </Preview>
      </Section>

      <Section title="Close / Dismiss Button" description="Standard circle-X close button seen on sheets, modals, and popovers. Available in three sizes.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 16, alignItems: 'center' }}>
            {[
              { size: 28, iconSize: 12, label: 'Small' },
              { size: 32, iconSize: 14, label: 'Medium' },
              { size: 40, iconSize: 16, label: 'Large' },
            ].map((item) => (
              <div key={item.label} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                <button
                  style={{
                    width: item.size, height: item.size,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    background: 'var(--glass-bg)',
                    backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                    WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                    border: '0.5px solid var(--glass-border)',
                    borderRadius: '50%',
                    boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                    cursor: 'pointer',
                    color: 'var(--label-secondary)',
                    transition: 'transform var(--dur) var(--ease-spring), background var(--dur-fast) var(--ease), color var(--dur-fast) var(--ease)',
                    padding: 0,
                  }}
                  onMouseEnter={(e) => { e.currentTarget.style.background = 'var(--glass-bg-hover)'; e.currentTarget.style.color = 'var(--label)'; }}
                  onMouseLeave={(e) => { e.currentTarget.style.background = 'var(--glass-bg)'; e.currentTarget.style.color = 'var(--label-secondary)'; e.currentTarget.style.transform = 'scale(1)'; }}
                  onPointerDown={(e) => { e.currentTarget.style.transform = 'scale(0.9)'; }}
                  onPointerUp={(e) => { e.currentTarget.style.transform = 'scale(1)'; }}
                >
                  <svg width={item.iconSize} height={item.iconSize} viewBox="0 0 16 16" fill="currentColor">
                    <path d="M3.72 3.72a.75.75 0 011.06 0L8 6.94l3.22-3.22a.75.75 0 111.06 1.06L9.06 8l3.22 3.22a.75.75 0 11-1.06 1.06L8 9.06l-3.22 3.22a.75.75 0 01-1.06-1.06L6.94 8 3.72 4.78a.75.75 0 010-1.06z"/>
                  </svg>
                </button>
                <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.6)' }}>{item.label}</span>
              </div>
            ))}
          </div>
        </Preview>
        <Preview>
          <p style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)', marginTop: 0, marginBottom: 8 }}>On light background</p>
          <div style={{ display: 'flex', gap: 16, alignItems: 'center' }}>
            {[28, 32, 40].map((size) => (
              <button
                key={size}
                style={{
                  width: size, height: size,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  background: 'var(--glass-bg)',
                  backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                  WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                  border: '0.5px solid var(--glass-border)',
                  borderRadius: '50%',
                  boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                  cursor: 'pointer',
                  color: 'var(--label-secondary)',
                  transition: 'transform var(--dur) var(--ease-spring), background var(--dur-fast) var(--ease)',
                  padding: 0,
                }}
                onMouseEnter={(e) => { e.currentTarget.style.background = 'var(--glass-bg-hover)'; e.currentTarget.style.color = 'var(--label)'; }}
                onMouseLeave={(e) => { e.currentTarget.style.background = 'var(--glass-bg)'; e.currentTarget.style.color = 'var(--label-secondary)'; e.currentTarget.style.transform = 'scale(1)'; }}
                onPointerDown={(e) => { e.currentTarget.style.transform = 'scale(0.9)'; }}
                onPointerUp={(e) => { e.currentTarget.style.transform = 'scale(1)'; }}
              >
                <svg width={size * 0.4} height={size * 0.4} viewBox="0 0 16 16" fill="currentColor">
                  <path d="M3.72 3.72a.75.75 0 011.06 0L8 6.94l3.22-3.22a.75.75 0 111.06 1.06L9.06 8l3.22 3.22a.75.75 0 11-1.06 1.06L8 9.06l-3.22 3.22a.75.75 0 01-1.06-1.06L6.94 8 3.72 4.78a.75.75 0 010-1.06z"/>
                </svg>
              </button>
            ))}
          </div>
        </Preview>
      </Section>

      <Section title="Floating Action Button" description="Large prominent circular button for the primary action. Available in filled blue, glass translucent, and mini sizes.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 20, alignItems: 'flex-end' }}>
            {/* Filled FAB */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <button
                style={{
                  width: 56, height: 56,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  background: 'var(--blue)',
                  border: 'none',
                  borderRadius: '50%',
                  boxShadow: 'var(--glass-shadow-lg)',
                  cursor: 'pointer',
                  color: '#fff',
                  padding: 0,
                  transition: 'transform var(--dur) var(--ease-spring), box-shadow var(--dur) var(--ease)',
                }}
                onMouseEnter={(e) => { e.currentTarget.style.transform = 'scale(1.05)'; e.currentTarget.style.boxShadow = 'var(--glass-shadow-lg), 0 8px 32px rgba(0,122,255,0.3)'; }}
                onMouseLeave={(e) => { e.currentTarget.style.transform = 'scale(1)'; e.currentTarget.style.boxShadow = 'var(--glass-shadow-lg)'; }}
              >
                <svg width="24" height="24" viewBox="0 0 20 20" fill="currentColor">
                  <path d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"/>
                </svg>
              </button>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.6)' }}>Filled</span>
            </div>

            {/* Glass FAB */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <button
                style={{
                  width: 56, height: 56,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  background: 'var(--glass-bg)',
                  backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                  WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                  border: '0.5px solid var(--glass-border)',
                  borderRadius: '50%',
                  boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
                  cursor: 'pointer',
                  color: 'var(--blue)',
                  padding: 0,
                  transition: 'transform var(--dur) var(--ease-spring), box-shadow var(--dur) var(--ease)',
                }}
                onMouseEnter={(e) => { e.currentTarget.style.transform = 'scale(1.05)'; }}
                onMouseLeave={(e) => { e.currentTarget.style.transform = 'scale(1)'; }}
              >
                <svg width="24" height="24" viewBox="0 0 20 20" fill="currentColor">
                  <path d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"/>
                </svg>
              </button>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.6)' }}>Glass</span>
            </div>

            {/* Mini FAB */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <button
                style={{
                  width: 44, height: 44,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  background: 'var(--blue)',
                  border: 'none',
                  borderRadius: '50%',
                  boxShadow: 'var(--glass-shadow-lg)',
                  cursor: 'pointer',
                  color: '#fff',
                  padding: 0,
                  transition: 'transform var(--dur) var(--ease-spring), box-shadow var(--dur) var(--ease)',
                }}
                onMouseEnter={(e) => { e.currentTarget.style.transform = 'scale(1.05)'; e.currentTarget.style.boxShadow = 'var(--glass-shadow-lg), 0 8px 32px rgba(0,122,255,0.3)'; }}
                onMouseLeave={(e) => { e.currentTarget.style.transform = 'scale(1)'; e.currentTarget.style.boxShadow = 'var(--glass-shadow-lg)'; }}
              >
                <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                  <path d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"/>
                </svg>
              </button>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.6)' }}>Mini</span>
            </div>
          </div>
        </Preview>
      </Section>

      <Section title="Button with Menu" description="A button that toggles a glass dropdown on click. Selecting an option updates the button label and closes the menu.">
        <Preview gradient>
          <div style={{ position: 'relative', display: 'inline-block' }}>
            <button
              onClick={() => setMenuOpen(!menuOpen)}
              style={{
                display: 'flex', alignItems: 'center', gap: 6,
                height: 44, padding: '0 18px',
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-lg)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                color: '#fff',
                font: 'var(--text-body)',
                cursor: 'pointer',
                transition: 'background var(--dur-fast) var(--ease)',
              }}
            >
              Sort: {sortValue}
              <svg width="12" height="12" viewBox="0 0 12 12" fill="currentColor" style={{ opacity: 0.7, transform: menuOpen ? 'rotate(180deg)' : 'rotate(0deg)', transition: 'transform var(--dur) var(--ease-spring)' }}>
                <path d="M2.5 4.5L6 8l3.5-3.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none"/>
              </svg>
            </button>
            {menuOpen && (
              <div
                style={{
                  position: 'absolute',
                  top: 'calc(100% + 6px)',
                  left: 0,
                  minWidth: 160,
                  background: 'var(--glass-bg)',
                  backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                  WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                  border: '0.5px solid var(--glass-border)',
                  borderRadius: 'var(--r-xl)',
                  boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
                  padding: '6px',
                  zIndex: 10,
                  animation: 'glassMenuEnter var(--dur) var(--ease-spring) both',
                }}
              >
                <style>{`
                  @keyframes glassMenuEnter {
                    from { opacity: 0; transform: translateY(-8px) scale(0.96); }
                    to { opacity: 1; transform: translateY(0) scale(1); }
                  }
                `}</style>
                {['Date', 'Name', 'Size', 'Type'].map((option) => (
                  <button
                    key={option}
                    onClick={() => { setSortValue(option); setMenuOpen(false); }}
                    style={{
                      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                      width: '100%', padding: '10px 14px',
                      background: sortValue === option ? 'var(--glass-bg-tinted)' : 'transparent',
                      border: 'none',
                      borderRadius: 'var(--r-md)',
                      color: sortValue === option ? 'var(--blue)' : '#fff',
                      font: 'var(--text-body)',
                      cursor: 'pointer',
                      transition: 'background var(--dur-fast) var(--ease)',
                      textAlign: 'left',
                    }}
                    onMouseEnter={(e) => { if (sortValue !== option) e.currentTarget.style.background = 'var(--glass-inner-hover)'; }}
                    onMouseLeave={(e) => { e.currentTarget.style.background = sortValue === option ? 'var(--glass-bg-tinted)' : 'transparent'; }}
                  >
                    {option}
                    {sortValue === option && (
                      <svg width="14" height="14" viewBox="0 0 16 16" fill="var(--blue)">
                        <path d="M13.78 4.22a.75.75 0 010 1.06l-7.25 7.25a.75.75 0 01-1.06 0L2.22 9.28a.75.75 0 011.06-1.06L6 10.94l6.72-6.72a.75.75 0 011.06 0z"/>
                      </svg>
                    )}
                  </button>
                ))}
              </div>
            )}
          </div>
          <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.7)', marginTop: 16, marginBottom: 0 }}>
            Click the button to open the dropdown menu. Selecting an option updates the label.
          </p>
        </Preview>
      </Section>

      <Section title="Accessibility Sizes" description="Buttons scale for larger accessibility text sizes (Dynamic Type). All buttons maintain a minimum 44x44pt tap target.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {[
              { label: 'Default', height: 44, fontSize: 17, description: 'Standard size' },
              { label: 'Large', height: 50, fontSize: 19, description: 'Large text' },
              { label: 'AX1', height: 60, fontSize: 23, description: 'Accessibility Extra Large' },
            ].map((tier) => (
              <div key={tier.label} style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
                <button
                  style={{
                    height: tier.height,
                    padding: `0 ${tier.height * 0.55}px`,
                    background: 'var(--blue)',
                    border: 'none',
                    borderRadius: tier.height / 2,
                    color: '#fff',
                    fontSize: tier.fontSize,
                    fontWeight: 600,
                    fontFamily: 'var(--font-system)',
                    cursor: 'pointer',
                    transition: 'transform var(--dur) var(--ease-spring)',
                  }}
                >
                  Confirm
                </button>
                <div>
                  <span style={{ font: 'var(--text-subhead)', color: '#fff', fontWeight: 600 }}>{tier.label}</span>
                  <span style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.6)', marginLeft: 8 }}>
                    {tier.height}px / {tier.fontSize}px
                  </span>
                </div>
              </div>
            ))}
          </div>
          <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.7)', marginTop: 16, marginBottom: 0 }}>
            All interactive elements maintain the minimum 44x44pt tap target required by Apple HIG for accessibility.
          </p>
        </Preview>
      </Section>
    </div>
  )
}
