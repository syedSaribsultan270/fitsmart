import { useState, useRef, useCallback } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton, GlassInput, GlassToggle, GlassSegment } from '../components/Glass'

/* Check icon */
function CheckIcon({ size = 16, color = 'var(--green)' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 20 20" fill={color}>
      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
    </svg>
  )
}

/* Error icon */
function ErrorIcon({ size = 16, color = 'var(--red)' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 20 20" fill={color}>
      <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
    </svg>
  )
}

/* Spinner */
function Spinner({ size = 18 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{
      animation: 'spin 1s linear infinite',
    }}>
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
      <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="3" opacity="0.25" />
      <path d="M12 2a10 10 0 019.95 9" stroke="currentColor" strokeWidth="3" strokeLinecap="round" />
    </svg>
  )
}

export default function FormsValidation() {
  /* Form layout state */
  const [formData, setFormData] = useState({
    firstName: '', lastName: '', email: '', phone: '',
  })

  /* Grouped sections state */
  const [groupData, setGroupData] = useState({
    username: '', groupEmail: '', displayName: '', bio: '',
    notifications: true, theme: 'system',
  })

  /* Inline validation state */
  const [valEmail, setValEmail] = useState('')
  const [valEmailTouched, setValEmailTouched] = useState(false)
  const [valPassword, setValPassword] = useState('')
  const [valConfirm, setValConfirm] = useState('')
  const [valConfirmTouched, setValConfirmTouched] = useState(false)
  const [valPhone, setValPhone] = useState('')
  const [valPhoneTouched, setValPhoneTouched] = useState(false)

  /* Loading state */
  const [isSubmitting, setIsSubmitting] = useState(false)

  /* Validation helpers */
  const isValidEmail = useCallback((e) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e), [])
  const isValidPhone = useCallback((p) => /^\+?[\d\s()-]{7,}$/.test(p), [])

  const getPasswordStrength = useCallback((pw) => {
    if (!pw) return { label: '', color: 'transparent', width: 0 }
    let score = 0
    if (pw.length >= 6) score++
    if (pw.length >= 10) score++
    if (/[A-Z]/.test(pw)) score++
    if (/[0-9]/.test(pw)) score++
    if (/[^A-Za-z0-9]/.test(pw)) score++
    if (score <= 1) return { label: 'Weak', color: 'var(--red)', width: 25 }
    if (score <= 3) return { label: 'Fair', color: 'var(--orange)', width: 55 }
    return { label: 'Strong', color: 'var(--green)', width: 100 }
  }, [])

  const strength = getPasswordStrength(valPassword)

  const handleFakeSubmit = useCallback(() => {
    setIsSubmitting(true)
    setTimeout(() => setIsSubmitting(false), 2500)
  }, [])

  const fieldRefs = useRef({})

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Forms & Validation</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Form layout patterns, inline validation, error states, and best practices for data entry in glass-styled interfaces.
      </p>

      {/* ── Form Layout ── */}
      <Section title="Form Layout" description="A complete glass-styled form with proper label placement and field arrangement.">
        <Preview>
          <div style={{ maxWidth: 480, margin: '0 auto' }}>
            <GlassPanel variant="thick">
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 20 }}>
                Personal Information
              </div>

              {/* Name row */}
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 16 }}>
                <div>
                  <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>
                    First Name
                  </label>
                  <GlassInput
                    placeholder="John"
                    value={formData.firstName}
                    onChange={e => setFormData(d => ({ ...d, firstName: e.target.value }))}
                    style={{ width: '100%', boxSizing: 'border-box' }}
                  />
                </div>
                <div>
                  <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>
                    Last Name
                  </label>
                  <GlassInput
                    placeholder="Appleseed"
                    value={formData.lastName}
                    onChange={e => setFormData(d => ({ ...d, lastName: e.target.value }))}
                    style={{ width: '100%', boxSizing: 'border-box' }}
                  />
                </div>
              </div>

              {/* Email */}
              <div style={{ marginBottom: 16 }}>
                <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>
                  Email
                </label>
                <GlassInput
                  type="email"
                  placeholder="john@example.com"
                  value={formData.email}
                  onChange={e => setFormData(d => ({ ...d, email: e.target.value }))}
                  style={{ width: '100%', boxSizing: 'border-box' }}
                />
              </div>

              {/* Phone */}
              <div style={{ marginBottom: 24 }}>
                <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>
                  Phone
                </label>
                <GlassInput
                  type="tel"
                  placeholder="+1 (555) 123-4567"
                  value={formData.phone}
                  onChange={e => setFormData(d => ({ ...d, phone: e.target.value }))}
                  style={{ width: '100%', boxSizing: 'border-box' }}
                />
              </div>

              <GlassButton variant="filled" style={{ width: '100%' }}>
                Submit
              </GlassButton>
            </GlassPanel>
          </div>
        </Preview>
      </Section>

      {/* ── Grouped Sections ── */}
      <Section title="Grouped Sections" description="Organize related fields into distinct glass containers with section headers.">
        <Preview>
          <div style={{ maxWidth: 480, margin: '0 auto', display: 'flex', flexDirection: 'column', gap: 24 }}>
            {/* Account */}
            <div>
              <div style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 8, paddingLeft: 4 }}>
                Account
              </div>
              <GlassPanel variant="thick">
                <div style={{ marginBottom: 16 }}>
                  <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>Username</label>
                  <GlassInput
                    placeholder="johndoe"
                    value={groupData.username}
                    onChange={e => setGroupData(d => ({ ...d, username: e.target.value }))}
                    style={{ width: '100%', boxSizing: 'border-box' }}
                  />
                </div>
                <div>
                  <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>Email</label>
                  <GlassInput
                    type="email"
                    placeholder="john@example.com"
                    value={groupData.groupEmail}
                    onChange={e => setGroupData(d => ({ ...d, groupEmail: e.target.value }))}
                    style={{ width: '100%', boxSizing: 'border-box' }}
                  />
                </div>
              </GlassPanel>
            </div>

            {/* Profile */}
            <div>
              <div style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 8, paddingLeft: 4 }}>
                Profile
              </div>
              <GlassPanel variant="thick">
                <div style={{ marginBottom: 16 }}>
                  <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>Display Name</label>
                  <GlassInput
                    placeholder="John Appleseed"
                    value={groupData.displayName}
                    onChange={e => setGroupData(d => ({ ...d, displayName: e.target.value }))}
                    style={{ width: '100%', boxSizing: 'border-box' }}
                  />
                </div>
                <div>
                  <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>Bio</label>
                  <textarea
                    className="glass-input"
                    placeholder="Tell us about yourself..."
                    value={groupData.bio}
                    onChange={e => setGroupData(d => ({ ...d, bio: e.target.value }))}
                    rows={3}
                    style={{ width: '100%', boxSizing: 'border-box', resize: 'vertical', fontFamily: 'var(--font-system)' }}
                  />
                </div>
              </GlassPanel>
            </div>

            {/* Preferences */}
            <div>
              <div style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 8, paddingLeft: 4 }}>
                Preferences
              </div>
              <GlassPanel variant="thick">
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 20 }}>
                  <div>
                    <div style={{ font: 'var(--text-body)', color: 'var(--label)' }}>Notifications</div>
                    <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>Receive push notifications</div>
                  </div>
                  <GlassToggle
                    checked={groupData.notifications}
                    onChange={() => setGroupData(d => ({ ...d, notifications: !d.notifications }))}
                  />
                </div>
                <div>
                  <div style={{ font: 'var(--text-body)', color: 'var(--label)', marginBottom: 8 }}>Theme</div>
                  <GlassSegment
                    items={[
                      { label: 'Light', value: 'light' },
                      { label: 'Dark', value: 'dark' },
                      { label: 'System', value: 'system' },
                    ]}
                    value={groupData.theme}
                    onChange={v => setGroupData(d => ({ ...d, theme: v }))}
                  />
                </div>
              </GlassPanel>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Inline Validation ── */}
      <Section title="Inline Validation" description="Real-time field validation with visual feedback. Fields validate on blur and show contextual success or error states.">
        <Preview>
          <div style={{ maxWidth: 420, margin: '0 auto' }}>
            <GlassPanel variant="thick">
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 20 }}>
                Create Account
              </div>

              {/* Email */}
              <div style={{ marginBottom: 16 }} ref={el => fieldRefs.current.email = el}>
                <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>Email</label>
                <div style={{ position: 'relative' }}>
                  <GlassInput
                    type="email"
                    placeholder="you@example.com"
                    value={valEmail}
                    onChange={e => setValEmail(e.target.value)}
                    onBlur={() => setValEmailTouched(true)}
                    style={{
                      width: '100%', boxSizing: 'border-box', paddingRight: 36,
                      borderColor: valEmailTouched ? (isValidEmail(valEmail) ? 'var(--green)' : 'var(--red)') : undefined,
                    }}
                  />
                  {valEmailTouched && (
                    <div style={{ position: 'absolute', right: 10, top: '50%', transform: 'translateY(-50%)' }}>
                      {isValidEmail(valEmail) ? <CheckIcon /> : <ErrorIcon />}
                    </div>
                  )}
                </div>
                {valEmailTouched && !isValidEmail(valEmail) && (
                  <div style={{ font: 'var(--text-caption1)', color: 'var(--red)', marginTop: 4 }}>
                    Please enter a valid email address
                  </div>
                )}
              </div>

              {/* Password + strength */}
              <div style={{ marginBottom: 16 }}>
                <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>Password</label>
                <GlassInput
                  type="password"
                  placeholder="At least 8 characters"
                  value={valPassword}
                  onChange={e => setValPassword(e.target.value)}
                  style={{ width: '100%', boxSizing: 'border-box' }}
                />
                {valPassword && (
                  <div style={{ marginTop: 8 }}>
                    <div style={{
                      height: 4, borderRadius: 2, background: 'var(--fill)',
                      overflow: 'hidden', marginBottom: 4,
                    }}>
                      <div style={{
                        height: '100%', borderRadius: 2,
                        background: strength.color,
                        width: `${strength.width}%`,
                        transition: 'width var(--dur-slow) var(--ease), background var(--dur) var(--ease)',
                      }} />
                    </div>
                    <div style={{ font: 'var(--text-caption2)', color: strength.color, fontWeight: 500 }}>
                      {strength.label}
                    </div>
                  </div>
                )}
              </div>

              {/* Confirm password */}
              <div style={{ marginBottom: 16 }} ref={el => fieldRefs.current.confirm = el}>
                <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>Confirm Password</label>
                <div style={{ position: 'relative' }}>
                  <GlassInput
                    type="password"
                    placeholder="Re-enter password"
                    value={valConfirm}
                    onChange={e => setValConfirm(e.target.value)}
                    onBlur={() => setValConfirmTouched(true)}
                    style={{
                      width: '100%', boxSizing: 'border-box', paddingRight: 36,
                      borderColor: valConfirmTouched ? (valConfirm && valConfirm === valPassword ? 'var(--green)' : 'var(--red)') : undefined,
                    }}
                  />
                  {valConfirmTouched && valConfirm && (
                    <div style={{ position: 'absolute', right: 10, top: '50%', transform: 'translateY(-50%)' }}>
                      {valConfirm === valPassword ? <CheckIcon /> : <ErrorIcon />}
                    </div>
                  )}
                </div>
                {valConfirmTouched && valConfirm && valConfirm !== valPassword && (
                  <div style={{ font: 'var(--text-caption1)', color: 'var(--red)', marginTop: 4 }}>
                    Passwords do not match
                  </div>
                )}
              </div>

              {/* Phone */}
              <div style={{ marginBottom: 24 }} ref={el => fieldRefs.current.phone = el}>
                <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>Phone</label>
                <div style={{ position: 'relative' }}>
                  <GlassInput
                    type="tel"
                    placeholder="+1 (555) 123-4567"
                    value={valPhone}
                    onChange={e => setValPhone(e.target.value)}
                    onBlur={() => setValPhoneTouched(true)}
                    style={{
                      width: '100%', boxSizing: 'border-box', paddingRight: 36,
                      borderColor: valPhoneTouched && valPhone ? (isValidPhone(valPhone) ? 'var(--green)' : 'var(--red)') : undefined,
                    }}
                  />
                  {valPhoneTouched && valPhone && (
                    <div style={{ position: 'absolute', right: 10, top: '50%', transform: 'translateY(-50%)' }}>
                      {isValidPhone(valPhone) ? <CheckIcon /> : <ErrorIcon />}
                    </div>
                  )}
                </div>
                {valPhoneTouched && valPhone && !isValidPhone(valPhone) && (
                  <div style={{ font: 'var(--text-caption1)', color: 'var(--red)', marginTop: 4 }}>
                    Please enter a valid phone number
                  </div>
                )}
              </div>

              <GlassButton variant="filled" style={{ width: '100%' }}>
                Create Account
              </GlassButton>
            </GlassPanel>
          </div>
        </Preview>
      </Section>

      {/* ── Error Summary ── */}
      <Section title="Error Summary" description="A glass error banner at the top of the form listing all validation errors.">
        <Preview>
          <div style={{ maxWidth: 480, margin: '0 auto' }}>
            {/* Error banner */}
            <GlassPanel style={{
              background: 'rgba(255, 59, 48, 0.08)',
              borderColor: 'rgba(255, 59, 48, 0.2)',
              marginBottom: 16,
            }}>
              <div style={{ display: 'flex', gap: 10, alignItems: 'flex-start' }}>
                <ErrorIcon size={20} />
                <div>
                  <div style={{ font: 'var(--text-headline)', color: 'var(--red)', marginBottom: 8 }}>
                    Please fix the following errors:
                  </div>
                  <ul style={{ margin: 0, paddingLeft: 18, font: 'var(--text-subhead)', color: 'var(--label-secondary)', lineHeight: 1.8 }}>
                    <li style={{ cursor: 'pointer', textDecoration: 'underline', textDecorationColor: 'var(--separator)' }}
                      onClick={() => fieldRefs.current.email?.scrollIntoView({ behavior: 'smooth', block: 'center' })}>
                      Email address is required
                    </li>
                    <li style={{ cursor: 'pointer', textDecoration: 'underline', textDecorationColor: 'var(--separator)' }}>
                      Password must be at least 8 characters
                    </li>
                    <li style={{ cursor: 'pointer', textDecoration: 'underline', textDecorationColor: 'var(--separator)' }}>
                      Phone number format is invalid
                    </li>
                  </ul>
                </div>
              </div>
            </GlassPanel>

            {/* Form stub */}
            <GlassPanel variant="thick" style={{ opacity: 0.6 }}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 16 }}>Registration</div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                <GlassInput placeholder="Email" style={{ width: '100%', boxSizing: 'border-box', borderColor: 'var(--red)' }} />
                <GlassInput placeholder="Password" type="password" style={{ width: '100%', boxSizing: 'border-box', borderColor: 'var(--red)' }} />
                <GlassInput placeholder="Phone" type="tel" style={{ width: '100%', boxSizing: 'border-box', borderColor: 'var(--red)' }} />
              </div>
            </GlassPanel>
          </div>
        </Preview>
      </Section>

      {/* ── Disabled & Loading States ── */}
      <Section title="Disabled & Loading States" description="Forms in disabled and loading/submitting states with visual indicators.">
        <Preview>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: 24 }}>
            {/* Disabled form */}
            <div>
              <div style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 8, paddingLeft: 4 }}>
                Disabled
              </div>
              <GlassPanel variant="thick" style={{ opacity: 0.35, pointerEvents: 'none' }}>
                <div style={{ marginBottom: 12 }}>
                  <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>Name</label>
                  <GlassInput placeholder="John" disabled style={{ width: '100%', boxSizing: 'border-box' }} />
                </div>
                <div style={{ marginBottom: 12 }}>
                  <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>Email</label>
                  <GlassInput placeholder="john@example.com" disabled style={{ width: '100%', boxSizing: 'border-box' }} />
                </div>
                <GlassButton variant="filled" disabled style={{ width: '100%' }}>Submit</GlassButton>
              </GlassPanel>
            </div>

            {/* Loading/submitting form */}
            <div>
              <div style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 8, paddingLeft: 4 }}>
                Submitting
              </div>
              <div style={{ position: 'relative' }}>
                <GlassPanel variant="thick" style={{ opacity: isSubmitting ? 0.5 : 1, transition: 'opacity var(--dur) var(--ease)', pointerEvents: isSubmitting ? 'none' : 'auto' }}>
                  <div style={{ marginBottom: 12 }}>
                    <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>Name</label>
                    <GlassInput placeholder="John Appleseed" style={{ width: '100%', boxSizing: 'border-box' }} />
                  </div>
                  <div style={{ marginBottom: 12 }}>
                    <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>Email</label>
                    <GlassInput placeholder="john@example.com" style={{ width: '100%', boxSizing: 'border-box' }} />
                  </div>
                  <GlassButton variant="filled" style={{ width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }} onClick={handleFakeSubmit}>
                    {isSubmitting && <Spinner size={16} />}
                    {isSubmitting ? 'Submitting...' : 'Submit'}
                  </GlassButton>
                </GlassPanel>

                {/* Glass overlay */}
                {isSubmitting && (
                  <div style={{
                    position: 'absolute', inset: 0,
                    background: 'var(--glass-bg-thin)',
                    backdropFilter: 'blur(4px)',
                    WebkitBackdropFilter: 'blur(4px)',
                    borderRadius: 'var(--r-lg)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                  }}>
                    <Spinner size={32} />
                  </div>
                )}
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Form Guidelines ── */}
      <Section title="Form Guidelines" description="Best practices for designing forms in glass-styled interfaces.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: 16 }}>
          {[
            { title: 'Labels Above', desc: 'Always place labels above input fields for better readability and scanning.' },
            { title: 'Group Related', desc: 'Group related fields together in glass containers with section headers.' },
            { title: 'Validate Inline', desc: 'Validate fields on blur, not on submit. Provide immediate feedback.' },
            { title: 'Preserve Input', desc: 'Never clear user input on error. Keep values and highlight issues.' },
            { title: 'Clear Messages', desc: 'Use specific, actionable error messages that explain how to fix issues.' },
            { title: 'Accessible Forms', desc: 'Associate labels with inputs. Use ARIA attributes for screen readers.' },
          ].map((item, i) => (
            <GlassCard key={i}>
              <div style={{ padding: 20 }}>
                <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>
                  {item.title}
                </div>
                <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)', lineHeight: 1.5 }}>
                  {item.desc}
                </div>
              </div>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs">
        <SpecTable
          headers={['Element', 'Property', 'Value']}
          rows={[
            ['Label', 'Font', 'Footnote, semibold'],
            ['Label', 'Color', 'var(--label-secondary)'],
            ['Field gap', 'Spacing', '16px'],
            ['Section gap', 'Spacing', '32px'],
            ['Error color', 'Color', '--red (#FF3B30)'],
            ['Success color', 'Color', '--green (#34C759)'],
            ['Strength bar', 'Height', '4px'],
            ['Error banner', 'Background', 'rgba(255,59,48,0.08)'],
          ]}
        />
      </Section>
    </div>
  )
}
