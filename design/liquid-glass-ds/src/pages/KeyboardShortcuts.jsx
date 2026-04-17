import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

/* Reusable key cap component */
function KeyCap({ children, style }) {
  return (
    <span style={{
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      minWidth: 28,
      height: 28,
      padding: '4px 8px',
      background: 'var(--glass-inner)',
      border: '0.5px solid var(--glass-border)',
      borderRadius: 'var(--r-xs)',
      fontFamily: 'var(--font-mono)',
      fontSize: 13,
      fontWeight: 500,
      color: 'var(--label)',
      boxShadow: 'var(--glass-shadow-inner), 0 1px 2px rgba(0,0,0,0.06)',
      userSelect: 'none',
      lineHeight: 1,
      ...style,
    }}>
      {children}
    </span>
  )
}

export default function KeyboardShortcuts() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Keyboard Shortcuts</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Discoverability overlays, modifier key references, command palette, and key cap styling for Liquid Glass interfaces.
      </p>

      {/* ── Discoverability Overlay ── */}
      <Section title="Discoverability Overlay" description="Hold the Command key to reveal available shortcuts in a glass overlay grid.">
        <Preview gradient>
          <GlassPanel style={{
            boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
            padding: 24,
          }}>
            <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 20, textAlign: 'center' }}>
              Keyboard Shortcuts
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(160px, 1fr))', gap: 12 }}>
              {[
                { keys: '\u2318C', desc: 'Copy' },
                { keys: '\u2318V', desc: 'Paste' },
                { keys: '\u2318X', desc: 'Cut' },
                { keys: '\u2318Z', desc: 'Undo' },
                { keys: '\u2318\u21e7Z', desc: 'Redo' },
                { keys: '\u2318N', desc: 'New' },
                { keys: '\u2318S', desc: 'Save' },
                { keys: '\u2318P', desc: 'Print' },
                { keys: '\u2318F', desc: 'Find' },
                { keys: '\u2318A', desc: 'Select All' },
              ].map(({ keys, desc }) => (
                <div key={keys} style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 10,
                  padding: '8px 12px',
                  background: 'var(--glass-inner)',
                  borderRadius: 'var(--r-sm)',
                  border: '0.5px solid var(--glass-border-inner)',
                }}>
                  <span style={{
                    fontFamily: 'var(--font-mono)',
                    fontSize: 13,
                    fontWeight: 500,
                    color: 'var(--label)',
                    background: 'var(--fill)',
                    padding: '3px 8px',
                    borderRadius: 'var(--r-xs)',
                    whiteSpace: 'nowrap',
                  }}>{keys}</span>
                  <span style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>{desc}</span>
                </div>
              ))}
            </div>
            <p style={{ font: 'var(--text-footnote)', color: 'var(--label-tertiary)', textAlign: 'center', marginTop: 16, marginBottom: 0 }}>
              Hold \u2318 to reveal available shortcuts
            </p>
          </GlassPanel>
        </Preview>
      </Section>

      {/* ── Modifier Keys ── */}
      <Section title="Modifier Keys" description="Reference table for Apple modifier keys and their roles.">
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10, maxWidth: 500, margin: '0 auto' }}>
            {[
              { symbol: '\u2318', name: 'Command', desc: 'Primary shortcuts' },
              { symbol: '\u2325', name: 'Option', desc: 'Alternate actions' },
              { symbol: '\u21e7', name: 'Shift', desc: 'Extend selection, reverse' },
              { symbol: '\u2303', name: 'Control', desc: 'Contextual menus' },
              { symbol: '\u21e5', name: 'Tab', desc: 'Move focus' },
              { symbol: '\u238b', name: 'Escape', desc: 'Cancel, dismiss' },
            ].map(({ symbol, name, desc }) => (
              <div key={symbol} style={{
                display: 'flex',
                alignItems: 'center',
                gap: 16,
                padding: '12px 16px',
                background: 'var(--glass-inner)',
                borderRadius: 'var(--r-md)',
                border: '0.5px solid var(--glass-border-inner)',
              }}>
                <KeyCap style={{ fontSize: 16, minWidth: 36, height: 36 }}>{symbol}</KeyCap>
                <div style={{ flex: 1 }}>
                  <div style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>{name}</div>
                  <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>{desc}</div>
                </div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ── Command Palette ── */}
      <Section title="Command Palette" description="A Spotlight-style search interface for discovering and running commands by name.">
        <Preview gradient>
          <div style={{ maxWidth: 440, margin: '0 auto' }}>
            <GlassPanel style={{
              padding: 0,
              overflow: 'hidden',
              boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
            }}>
              {/* Search field */}
              <div style={{
                padding: '16px 20px',
                borderBottom: '0.5px solid var(--separator)',
                display: 'flex',
                alignItems: 'center',
                gap: 10,
              }}>
                <svg width="18" height="18" viewBox="0 0 20 20" fill="var(--label-tertiary)">
                  <path fillRule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clipRule="evenodd"/>
                </svg>
                <span style={{ font: 'var(--text-body)', color: 'var(--label-tertiary)' }}>Type a command...</span>
              </div>

              {/* Results */}
              {[
                { name: 'Toggle Dark Mode', shortcut: '\u2318\u21e7D' },
                { name: 'New Document', shortcut: '\u2318N' },
                { name: 'Export as PDF', shortcut: '\u2318\u21e7E' },
              ].map(({ name, shortcut }, i, arr) => (
                <div key={name} style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 20px',
                  borderBottom: i < arr.length - 1 ? '0.5px solid var(--separator)' : 'none',
                  background: i === 0 ? 'var(--glass-bg-tinted)' : 'transparent',
                  cursor: 'pointer',
                }}>
                  <span style={{ font: 'var(--text-body)', color: 'var(--label)' }}>{name}</span>
                  <span style={{
                    fontFamily: 'var(--font-mono)',
                    fontSize: 12,
                    color: 'var(--label-tertiary)',
                    background: 'var(--fill)',
                    padding: '3px 8px',
                    borderRadius: 'var(--r-xs)',
                  }}>{shortcut}</span>
                </div>
              ))}

              {/* Recent section */}
              <div style={{
                borderTop: '0.5px solid var(--separator)',
                padding: '10px 20px 6px',
              }}>
                <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', textTransform: 'uppercase', letterSpacing: 0.5 }}>Recent</span>
              </div>
              {[
                { name: 'Find and Replace', shortcut: '\u2318\u2325F' },
                { name: 'Open Settings', shortcut: '\u2318,' },
              ].map(({ name, shortcut }, i, arr) => (
                <div key={name} style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '10px 20px',
                  borderBottom: i < arr.length - 1 ? '0.5px solid var(--separator)' : 'none',
                  cursor: 'pointer',
                }}>
                  <span style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>{name}</span>
                  <span style={{
                    fontFamily: 'var(--font-mono)',
                    fontSize: 12,
                    color: 'var(--label-quaternary)',
                    background: 'var(--fill-tertiary)',
                    padding: '3px 8px',
                    borderRadius: 'var(--r-xs)',
                  }}>{shortcut}</span>
                </div>
              ))}
            </GlassPanel>
          </div>
        </Preview>
      </Section>

      {/* ── Key Caps ── */}
      <Section title="Key Caps" description="Visual representations of keyboard keys styled as glass pills for use in documentation and UI.">
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
            {/* Individual keys */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 12 }}>Individual Keys</div>
              <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                {['\u2318', '\u21e7', '\u2325', '\u2303', '\u23ce', '\u232b', '\u21e5', 'Space'].map((key) => (
                  <KeyCap key={key}>{key}</KeyCap>
                ))}
              </div>
            </div>

            {/* Compound shortcuts */}
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 12 }}>Compound Shortcuts</div>
              <div style={{ display: 'flex', gap: 20, flexWrap: 'wrap', alignItems: 'center' }}>
                {/* ⌘ + C */}
                <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                  <KeyCap>{'\u2318'}</KeyCap>
                  <span style={{ color: 'var(--label-tertiary)', fontSize: 13 }}>+</span>
                  <KeyCap>C</KeyCap>
                </div>

                {/* ⌘ + ⇧ + Z */}
                <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                  <KeyCap>{'\u2318'}</KeyCap>
                  <span style={{ color: 'var(--label-tertiary)', fontSize: 13 }}>+</span>
                  <KeyCap>{'\u21e7'}</KeyCap>
                  <span style={{ color: 'var(--label-tertiary)', fontSize: 13 }}>+</span>
                  <KeyCap>Z</KeyCap>
                </div>

                {/* ⌥ + ⌘ + I */}
                <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                  <KeyCap>{'\u2325'}</KeyCap>
                  <span style={{ color: 'var(--label-tertiary)', fontSize: 13 }}>+</span>
                  <KeyCap>{'\u2318'}</KeyCap>
                  <span style={{ color: 'var(--label-tertiary)', fontSize: 13 }}>+</span>
                  <KeyCap>I</KeyCap>
                </div>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Guidelines ── */}
      <Section title="Shortcuts Guidelines" description="Best practices for keyboard shortcut design and discoverability.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: 16 }}>
          {[
            'Use standard system shortcuts (\u2318C, \u2318V) \u2014 don\'t override them',
            'Show shortcuts in menus next to the action',
            'Support the discoverability overlay (hold \u2318)',
            'Provide a command palette for power users',
          ].map((guideline) => (
            <GlassCard key={guideline} style={{ padding: 20 }}>
              <p style={{ font: 'var(--text-subhead)', color: 'var(--label)', margin: 0 }}>{guideline}</p>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs">
        <SpecTable
          headers={['Property', 'Value', 'Notes']}
          rows={[
            ['Key cap min size', '28px', 'Width and height minimum'],
            ['Key cap font', 'SF Mono 13px', 'Monospace for clarity'],
            ['Overlay delay', '500ms', 'Hold duration before showing'],
            ['Command palette max results', '8', 'Keep the list scannable'],
          ]}
        />
      </Section>
    </div>
  )
}
