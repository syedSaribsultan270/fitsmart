import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton, GlassInput, GlassAlert } from '../components/Glass'

const navTypes = [
  { title: 'Hierarchical', desc: 'Drill-down navigation with a clear back path. Used in Settings, Mail, and most content apps. Each screen pushes onto a navigation stack.' },
  { title: 'Flat', desc: 'Tab-based navigation where all top-level sections are equally accessible. Used in Music, App Store, and Clock. Maximum 5 tabs.' },
  { title: 'Content-Driven', desc: 'Navigation emerges from content itself. Used in News, Photos, and Safari. Users flow between items without a rigid hierarchy.' },
  { title: 'Modal', desc: 'Temporary focused flows that block the main interface. Used for creation, editing, or multi-step tasks that require completion or dismissal.' },
]

const gestureHeaders = ['Gesture', 'Action', 'Example']
const gestureRows = [
  ['Tap', 'Primary action / select', 'Open item, toggle control'],
  ['Long Press', 'Context menu / preview', 'Peek at link, show actions'],
  ['Swipe (horizontal)', 'Navigate / reveal actions', 'Go back, delete row'],
  ['Swipe (vertical)', 'Scroll / dismiss', 'Scroll list, dismiss sheet'],
  ['Pinch', 'Zoom / scale', 'Photo zoom, map scale'],
  ['Rotate', 'Rotate content', 'Rotate image, adjust angle'],
  ['Pan', 'Move / reposition', 'Drag item, move map'],
  ['Edge Swipe', 'System navigation', 'Back gesture from left edge'],
]

const modalityHeaders = ['Type', 'Use Case', 'Dismissal', 'Size']
const modalityRows = [
  ['Alert', 'Confirm destructive actions, error states', 'Button tap only', 'Fixed compact'],
  ['Action Sheet', 'Choose from multiple related options', 'Tap option or cancel', 'Bottom-anchored'],
  ['Sheet', 'Extended content or multi-step flows', 'Swipe down or close button', 'Half / full screen'],
  ['Popover', 'Contextual content near trigger', 'Tap outside', 'Auto-sized, arrowed'],
]

const onboardingTypes = [
  { title: 'Welcome', desc: 'First-launch experience with 2-3 screens max. Show the app\'s core value, not feature lists. Use imagery over text. Let users skip.' },
  { title: 'Contextual Tips', desc: 'In-context coaching that appears when users first encounter a feature. Brief, dismissible, and non-blocking. Use coach marks sparingly.' },
  { title: 'Tutorial', desc: 'Interactive walkthrough for complex features. Let users learn by doing rather than reading. Provide a way to revisit from Settings.' },
]

const notificationHeaders = ['Type', 'Persistence', 'Interruption', 'Use Case']
const notificationRows = [
  ['Banner', 'Auto-dismiss (5s)', 'Low', 'New message, update available'],
  ['Alert', 'Requires action', 'High', 'Calendar event, reminder'],
  ['Badge', 'Until cleared', 'None', 'Unread count, pending action'],
  ['Sound', 'Momentary', 'Medium', 'New message, completed task'],
  ['Critical Alert', 'Requires action', 'Maximum', 'Health alert, security warning'],
]

export default function Patterns() {
  const [searchQuery, setSearchQuery] = useState('')
  const [formName, setFormName] = useState('')
  const [formEmail, setFormEmail] = useState('')
  const [formSubmitted, setFormSubmitted] = useState(false)
  const [formErrors, setFormErrors] = useState({})

  const suggestions = ['Weather', 'Calendar events', 'Nearby restaurants', 'Flight status', 'Package tracking']
  const filteredSuggestions = searchQuery
    ? suggestions.filter((s) => s.toLowerCase().includes(searchQuery.toLowerCase()))
    : suggestions

  const handleFormSubmit = () => {
    const errors = {}
    if (!formName.trim()) errors.name = 'Name is required'
    if (!formEmail.trim()) errors.email = 'Email is required'
    else if (!/\S+@\S+\.\S+/.test(formEmail)) errors.email = 'Enter a valid email'
    setFormErrors(errors)
    if (Object.keys(errors).length === 0) {
      setFormSubmitted(true)
      setTimeout(() => setFormSubmitted(false), 2000)
    }
  }

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Patterns</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Common interaction patterns, navigation models, gesture vocabulary, and UI recipes.
      </p>

      {/* Navigation Types */}
      <Section title="Navigation Types" description="Four primary navigation models used across Apple platforms.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          {navTypes.map((n) => (
            <GlassCard key={n.title}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>{n.title}</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>{n.desc}</div>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* Gesture Reference */}
      <Section title="Gesture Reference" description="Standard gesture vocabulary across iOS and iPadOS.">
        <SpecTable headers={gestureHeaders} rows={gestureRows} />
      </Section>

      {/* Modality Guide */}
      <Section title="Modality Guide" description="Choosing the right modal presentation style.">
        <SpecTable headers={modalityHeaders} rows={modalityRows} />
      </Section>

      {/* Onboarding */}
      <Section title="Onboarding" description="Three approaches to introducing users to your app.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          {onboardingTypes.map((o) => (
            <GlassCard key={o.title}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>{o.title}</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>{o.desc}</div>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* Search */}
      <Section title="Search" description="Glass search bar with suggestions and results.">
        <Preview>
          <div style={{ maxWidth: 420 }}>
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              borderRadius: 'var(--r-pill)',
              border: '0.5px solid var(--glass-border)',
              boxShadow: 'var(--glass-shadow)',
              padding: '8px 16px',
              display: 'flex',
              alignItems: 'center',
              gap: 8,
              marginBottom: 12,
            }}>
              <svg width="16" height="16" viewBox="0 0 20 20" fill="var(--label-tertiary)">
                <path fillRule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clipRule="evenodd" />
              </svg>
              <input
                type="text"
                placeholder="Search..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{
                  flex: 1,
                  border: 'none',
                  background: 'transparent',
                  outline: 'none',
                  font: 'var(--text-body)',
                  color: 'var(--label)',
                }}
              />
              {searchQuery && (
                <button
                  onClick={() => setSearchQuery('')}
                  style={{
                    background: 'var(--fill)',
                    border: 'none',
                    borderRadius: '50%',
                    width: 20,
                    height: 20,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: 12,
                    color: 'var(--label-secondary)',
                  }}
                >
                  x
                </button>
              )}
            </div>
            <GlassPanel style={{ padding: 0 }}>
              <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', padding: '10px 16px 6px' }}>
                {searchQuery ? 'Results' : 'Suggestions'}
              </div>
              {filteredSuggestions.map((s, i) => (
                <div key={s} style={{
                  padding: '10px 16px',
                  font: 'var(--text-body)',
                  color: 'var(--label)',
                  borderTop: i > 0 ? '0.5px solid var(--separator)' : 'none',
                  cursor: 'pointer',
                }}>
                  {s}
                </div>
              ))}
              {filteredSuggestions.length === 0 && (
                <div style={{ padding: '16px', font: 'var(--text-body)', color: 'var(--label-tertiary)', textAlign: 'center' }}>
                  No results found
                </div>
              )}
            </GlassPanel>
          </div>
        </Preview>
      </Section>

      {/* Forms */}
      <Section title="Forms" description="Glass form pattern with inline validation.">
        <Preview>
          <div style={{ maxWidth: 400 }}>
            <GlassPanel>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 16 }}>Create Account</div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                <div>
                  <label style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 4 }}>
                    Name
                  </label>
                  <GlassInput
                    placeholder="Full name"
                    value={formName}
                    onChange={(e) => { setFormName(e.target.value); setFormErrors((prev) => ({ ...prev, name: undefined })) }}
                    style={formErrors.name ? { borderColor: 'var(--red)' } : undefined}
                  />
                  {formErrors.name && <div style={{ font: 'var(--text-caption2)', color: 'var(--red)', marginTop: 4 }}>{formErrors.name}</div>}
                </div>
                <div>
                  <label style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 4 }}>
                    Email
                  </label>
                  <GlassInput
                    type="email"
                    placeholder="you@example.com"
                    value={formEmail}
                    onChange={(e) => { setFormEmail(e.target.value); setFormErrors((prev) => ({ ...prev, email: undefined })) }}
                    style={formErrors.email ? { borderColor: 'var(--red)' } : undefined}
                  />
                  {formErrors.email && <div style={{ font: 'var(--text-caption2)', color: 'var(--red)', marginTop: 4 }}>{formErrors.email}</div>}
                </div>
                <div style={{ display: 'flex', gap: 8, marginTop: 4 }}>
                  <GlassButton variant="filled" onClick={handleFormSubmit}>
                    {formSubmitted ? 'Submitted!' : 'Submit'}
                  </GlassButton>
                  <GlassButton variant="glass" onClick={() => { setFormName(''); setFormEmail(''); setFormErrors({}) }}>
                    Reset
                  </GlassButton>
                </div>
              </div>
            </GlassPanel>
          </div>
        </Preview>
      </Section>

      {/* Notifications */}
      <Section title="Notifications" description="Notification types, persistence levels, and usage guidance.">
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12, maxWidth: 400 }}>
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              borderRadius: 'var(--r-xl)',
              border: '0.5px solid var(--glass-border)',
              boxShadow: 'var(--glass-shadow-lg)',
              padding: '12px 16px',
              display: 'flex',
              alignItems: 'center',
              gap: 12,
            }}>
              <div style={{ width: 36, height: 36, borderRadius: 'var(--r-sm)', background: 'var(--blue)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <span style={{ color: '#fff', fontSize: 18 }}>M</span>
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>Messages</div>
                <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>Hey! Are you coming tonight?</div>
              </div>
              <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>now</div>
            </div>

            <GlassAlert
              title="Calendar"
              message="Team standup in 5 minutes"
              actions={[
                { label: 'Snooze', onClick: () => {} },
                { label: 'View', primary: true, onClick: () => {} },
              ]}
            />

            <div style={{
              background: 'var(--glass-bg-thin)',
              backdropFilter: 'blur(var(--blur-md))',
              WebkitBackdropFilter: 'blur(var(--blur-md))',
              borderRadius: 'var(--r-lg)',
              border: '0.5px solid var(--glass-border)',
              padding: '10px 16px',
              display: 'flex',
              alignItems: 'center',
              gap: 10,
            }}>
              <div style={{ width: 8, height: 8, borderRadius: '50%', background: 'var(--red)' }} />
              <div style={{ font: 'var(--text-footnote)', color: 'var(--label)' }}>Critical: Storage almost full</div>
            </div>
          </div>
        </Preview>
        <SpecTable headers={notificationHeaders} rows={notificationRows} />
      </Section>
    </div>
  )
}
