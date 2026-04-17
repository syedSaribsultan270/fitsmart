import { useState, useRef, useEffect, useCallback } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton, GlassInput, GlassToggle } from '../components/Glass'

/* Apple logo SVG */
function AppleLogo({ color = '#fff', size = 16 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill={color} style={{ flexShrink: 0 }}>
      <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
    </svg>
  )
}

/* Face ID icon */
function FaceIdIcon({ size = 48, color = 'var(--blue)' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 48 48" fill="none" stroke={color} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
      {/* Corner brackets */}
      <path d="M14 6H8a2 2 0 00-2 2v6" />
      <path d="M34 6h6a2 2 0 012 2v6" />
      <path d="M14 42H8a2 2 0 01-2-2v-6" />
      <path d="M34 42h6a2 2 0 002-2v-6" />
      {/* Face features */}
      <circle cx="18" cy="18" r="1.5" fill={color} stroke="none" />
      <circle cx="30" cy="18" r="1.5" fill={color} stroke="none" />
      <line x1="24" y1="20" x2="24" y2="27" />
      <path d="M18 32c1.5 2 4.5 3 6 3s4.5-1 6-3" />
    </svg>
  )
}

/* Key icon */
function KeyIcon({ size = 18, color = 'var(--label-secondary)' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 20 20" fill={color}>
      <path fillRule="evenodd" d="M13.5 2a5.5 5.5 0 00-4.9 8.01L3 15.6V18h2.4v-1.6H7v-1.6h1.6l1.39-1.39A5.5 5.5 0 1013.5 2zm1 3a1.5 1.5 0 110 3 1.5 1.5 0 010-3z" clipRule="evenodd" />
    </svg>
  )
}

/* Arrow down connector */
function ArrowDown() {
  return (
    <div style={{ display: 'flex', justifyContent: 'center', padding: '4px 0' }}>
      <svg width="20" height="28" viewBox="0 0 20 28" fill="none" stroke="var(--blue)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <line x1="10" y1="0" x2="10" y2="22" />
        <polyline points="5,17 10,22 15,17" />
      </svg>
    </div>
  )
}

export default function Authentication() {
  /* 2FA state */
  const [code, setCode] = useState(['', '', '', '', '', ''])
  const inputRefs = useRef([])
  const [timer, setTimer] = useState(272) // 4:32
  const [showPassword, setShowPassword] = useState(false)
  const [showSuggestion, setShowSuggestion] = useState(false)

  useEffect(() => {
    const interval = setInterval(() => {
      setTimer(t => (t > 0 ? t - 1 : 0))
    }, 1000)
    return () => clearInterval(interval)
  }, [])

  const formatTime = useCallback((s) => {
    const m = Math.floor(s / 60)
    const sec = s % 60
    return `${m}:${sec.toString().padStart(2, '0')}`
  }, [])

  const handleCodeChange = useCallback((index, value) => {
    if (value.length > 1) value = value.slice(-1)
    if (!/^\d*$/.test(value)) return
    setCode(prev => {
      const next = [...prev]
      next[index] = value
      return next
    })
    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus()
    }
  }, [])

  const handleCodeKeyDown = useCallback((index, e) => {
    if (e.key === 'Backspace' && !code[index] && index > 0) {
      inputRefs.current[index - 1]?.focus()
    }
  }, [code])

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Authentication</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Sign in with Apple, passkeys, password autofill, and two-factor authentication patterns for Apple platforms.
      </p>

      {/* ── Sign in with Apple ── */}
      <Section title="Sign in with Apple" description="Official button styles for Sign in with Apple. Always use the system-provided buttons for consistency and compliance.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16, alignItems: 'center', maxWidth: 320, margin: '0 auto' }}>
            {/* Black filled */}
            <button style={{
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
              width: '100%', minWidth: 280, height: 44,
              background: '#000', color: '#fff', border: 'none',
              borderRadius: 'var(--r-xs)', fontSize: 16, fontWeight: 500,
              fontFamily: 'var(--font-system)', cursor: 'pointer',
              transition: 'opacity var(--dur) var(--ease)',
            }}
              onMouseEnter={e => e.currentTarget.style.opacity = '0.85'}
              onMouseLeave={e => e.currentTarget.style.opacity = '1'}
            >
              <AppleLogo color="#fff" size={18} />
              Sign in with Apple
            </button>

            {/* White filled */}
            <button style={{
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
              width: '100%', minWidth: 280, height: 44,
              background: '#fff', color: '#000', border: '1px solid #000',
              borderRadius: 'var(--r-xs)', fontSize: 16, fontWeight: 500,
              fontFamily: 'var(--font-system)', cursor: 'pointer',
              transition: 'opacity var(--dur) var(--ease)',
            }}
              onMouseEnter={e => e.currentTarget.style.opacity = '0.85'}
              onMouseLeave={e => e.currentTarget.style.opacity = '1'}
            >
              <AppleLogo color="#000" size={18} />
              Sign in with Apple
            </button>

            {/* Outline */}
            <button style={{
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
              width: '100%', minWidth: 280, height: 44,
              background: 'transparent', color: '#fff', border: '1px solid rgba(255,255,255,0.6)',
              borderRadius: 'var(--r-xs)', fontSize: 16, fontWeight: 500,
              fontFamily: 'var(--font-system)', cursor: 'pointer',
              transition: 'opacity var(--dur) var(--ease)',
            }}
              onMouseEnter={e => e.currentTarget.style.opacity = '0.85'}
              onMouseLeave={e => e.currentTarget.style.opacity = '1'}
            >
              <AppleLogo color="#fff" size={18} />
              Sign in with Apple
            </button>
          </div>
          <p style={{ color: 'rgba(255,255,255,0.5)', font: 'var(--text-footnote)', textAlign: 'center', marginTop: 20 }}>
            Minimum button size: 280 x 44 pt. Follow Apple's Human Interface Guidelines for placement and styling.
          </p>
        </Preview>
      </Section>

      {/* ── Authentication Flow ── */}
      <Section title="Authentication Flow" description="Visual sequence of the Sign in with Apple authentication process.">
        <Preview>
          <div style={{ maxWidth: 400, margin: '0 auto' }}>
            {[
              { step: 1, icon: '👆', title: 'User taps Sign in with Apple', desc: 'The authentication flow begins when the user taps the Sign in with Apple button.' },
              { step: 2, icon: '🔐', title: 'System presents Face ID / Touch ID', desc: 'iOS presents the biometric authentication prompt for identity verification.' },
              { step: 3, icon: '📧', title: 'User chooses to share or hide email', desc: 'Apple offers a private relay email option to protect user privacy.' },
              { step: 4, icon: '✅', title: 'App receives user ID + credentials', desc: 'Your app receives a unique, stable user identifier and authorization credentials.' },
            ].map((item, i) => (
              <div key={i}>
                {i > 0 && <ArrowDown />}
                <GlassPanel style={{ display: 'flex', gap: 16, alignItems: 'flex-start' }}>
                  <div style={{
                    width: 40, height: 40, borderRadius: 'var(--r-sm)',
                    background: 'var(--glass-bg-tinted)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontSize: 20, flexShrink: 0,
                  }}>
                    {item.icon}
                  </div>
                  <div>
                    <div style={{ font: 'var(--text-footnote)', color: 'var(--blue)', fontWeight: 600, marginBottom: 2 }}>
                      Step {item.step}
                    </div>
                    <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 4 }}>
                      {item.title}
                    </div>
                    <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>
                      {item.desc}
                    </div>
                  </div>
                </GlassPanel>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ── Passkeys ── */}
      <Section title="Passkeys" description="Passkeys replace passwords with biometric, phishing-resistant authentication using Face ID or Touch ID.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 24, alignItems: 'center', maxWidth: 360, margin: '0 auto' }}>
            {/* Main passkey card */}
            <GlassPanel variant="thick" style={{ textAlign: 'center', width: '100%' }}>
              <div style={{ marginBottom: 16, display: 'flex', justifyContent: 'center' }}>
                <FaceIdIcon size={56} color="var(--blue)" />
              </div>
              <div style={{ font: 'var(--text-title2)', color: 'var(--label)', marginBottom: 8 }}>
                Sign in with Passkey
              </div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', lineHeight: 1.5 }}>
                Passkeys use biometric authentication for a faster, more secure sign-in experience. No passwords to remember or phish.
              </div>
            </GlassPanel>

            {/* Mock auth sheet */}
            <GlassPanel variant="thick" style={{ width: '100%', textAlign: 'center' }}>
              <div style={{ marginBottom: 12, display: 'flex', justifyContent: 'center' }}>
                <FaceIdIcon size={40} color="var(--blue)" />
              </div>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 4 }}>
                Confirm with Face ID
              </div>
              <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)', marginBottom: 16 }}>
                Double-click to confirm
              </div>
              <GlassButton variant="plain" style={{ color: 'var(--blue)', font: 'var(--text-body)' }}>
                Cancel
              </GlassButton>
            </GlassPanel>
          </div>
        </Preview>
      </Section>

      {/* ── Password Autofill ── */}
      <Section title="Password Autofill" description="Support password autofill and strong password suggestions for frictionless account creation.">
        <Preview>
          <div style={{ maxWidth: 360, margin: '0 auto' }}>
            <GlassPanel variant="thick">
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 20 }}>
                Create Account
              </div>

              {/* Username field */}
              <div style={{ marginBottom: 16 }}>
                <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>
                  Username
                </label>
                <div style={{ position: 'relative' }}>
                  <div style={{ position: 'absolute', left: 12, top: '50%', transform: 'translateY(-50%)' }}>
                    <KeyIcon size={16} />
                  </div>
                  <GlassInput
                    placeholder="username@email.com"
                    style={{ width: '100%', paddingLeft: 36, boxSizing: 'border-box' }}
                    autoComplete="username"
                  />
                </div>
              </div>

              {/* Password field with suggestion */}
              <div style={{ marginBottom: 20, position: 'relative' }}>
                <label style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label-secondary)', display: 'block', marginBottom: 6 }}>
                  Password
                </label>
                <div style={{ position: 'relative' }}>
                  <GlassInput
                    type={showPassword ? 'text' : 'password'}
                    placeholder="Enter password"
                    value="x7Kq-m2Np-v9Rz"
                    readOnly
                    onFocus={() => setShowSuggestion(true)}
                    style={{ width: '100%', paddingRight: 40, boxSizing: 'border-box', fontFamily: 'var(--font-mono)', fontSize: 14 }}
                    autoComplete="new-password"
                  />
                  <button
                    onClick={() => setShowPassword(p => !p)}
                    style={{
                      position: 'absolute', right: 10, top: '50%', transform: 'translateY(-50%)',
                      background: 'none', border: 'none', cursor: 'pointer', padding: 4,
                      color: 'var(--label-secondary)', fontSize: 14,
                    }}
                  >
                    {showPassword ? (
                      <svg width="18" height="18" viewBox="0 0 20 20" fill="currentColor">
                        <path d="M10 4C5.588 4 1.878 6.86.514 10.001 1.878 13.14 5.588 16 10 16s8.122-2.86 9.486-5.999C18.122 6.86 14.412 4 10 4zm0 10a4 4 0 110-8 4 4 0 010 8zm0-6.5a2.5 2.5 0 100 5 2.5 2.5 0 000-5z" />
                      </svg>
                    ) : (
                      <svg width="18" height="18" viewBox="0 0 20 20" fill="currentColor">
                        <path d="M3.707 2.293a1 1 0 00-1.414 1.414l14 14a1 1 0 001.414-1.414l-1.473-1.473C17.418 13.586 18.694 12 19.486 10c-1.364-3.14-5.074-6-9.486-6-1.47 0-2.863.372-4.12 1.002L3.707 2.293zM10 8a2 2 0 012 2l-.002.07L8.93 7.002A2 2 0 0110 8zm-6.072 2c.913-1.676 2.405-3.13 4.197-3.81L6.586 4.65C4.237 5.81 2.386 7.693.514 10c.91 2.09 2.47 3.84 4.414 4.95l1.445-1.446C4.88 12.66 3.63 11.29 3.928 10z" />
                      </svg>
                    )}
                  </button>
                </div>

                {/* Suggested password popover */}
                {showSuggestion && (
                  <div style={{
                    position: 'absolute', bottom: '100%', left: 0, right: 0,
                    marginBottom: 8, zIndex: 10,
                  }}>
                    <GlassPanel variant="thick" style={{
                      padding: '12px 16px',
                      boxShadow: 'var(--glass-shadow-lg)',
                    }}>
                      <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)', marginBottom: 6 }}>
                        Suggested Strong Password
                      </div>
                      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
                        <code style={{
                          font: 'var(--text-callout)', fontFamily: 'var(--font-mono)',
                          color: 'var(--label)', fontWeight: 500,
                          letterSpacing: '0.5px',
                        }}>
                          x7Kq-m2Np-v9Rz
                        </code>
                        <GlassButton variant="filled" size="sm" onClick={() => setShowSuggestion(false)}>
                          Use
                        </GlassButton>
                      </div>
                    </GlassPanel>
                  </div>
                )}
              </div>

              <GlassButton variant="filled" style={{ width: '100%' }}>
                Create Account
              </GlassButton>
            </GlassPanel>

            <p style={{ font: 'var(--text-footnote)', color: 'var(--label-tertiary)', marginTop: 12, textAlign: 'center' }}>
              Configure Associated Domains to enable AutoFill and universal links.
            </p>
          </div>
        </Preview>
      </Section>

      {/* ── Two-Factor Authentication ── */}
      <Section title="Two-Factor Authentication" description="Six-digit verification code input with auto-advance, SMS auto-fill support, and expiration timer.">
        <Preview gradient>
          <div style={{ maxWidth: 400, margin: '0 auto', textAlign: 'center' }}>
            <div style={{ font: 'var(--text-title3)', color: 'var(--label)', marginBottom: 8 }}>
              Enter Verification Code
            </div>
            <p style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 24 }}>
              We sent a 6-digit code to your phone
            </p>

            {/* 6 code inputs */}
            <div style={{ display: 'flex', gap: 8, justifyContent: 'center', marginBottom: 16 }}>
              {code.map((digit, i) => (
                <input
                  key={i}
                  ref={el => inputRefs.current[i] = el}
                  type="text"
                  inputMode="numeric"
                  maxLength={1}
                  value={digit}
                  onChange={e => handleCodeChange(i, e.target.value)}
                  onKeyDown={e => handleCodeKeyDown(i, e)}
                  onFocus={e => e.target.select()}
                  style={{
                    width: 44, height: 48,
                    background: 'var(--glass-bg)',
                    backdropFilter: 'blur(var(--blur-md))',
                    WebkitBackdropFilter: 'blur(var(--blur-md))',
                    border: digit ? '1.5px solid var(--blue)' : '1px solid var(--glass-border)',
                    borderRadius: 'var(--r-sm)',
                    textAlign: 'center',
                    fontSize: 22,
                    fontWeight: 600,
                    fontFamily: 'var(--font-mono)',
                    color: 'var(--label)',
                    outline: 'none',
                    caretColor: 'var(--blue)',
                    transition: 'border-color var(--dur) var(--ease), box-shadow var(--dur) var(--ease)',
                    boxShadow: digit ? '0 0 0 3px rgba(0,122,255,0.15)' : 'var(--glass-shadow)',
                  }}
                />
              ))}
            </div>

            {/* Auto-fill note */}
            <div style={{
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
              font: 'var(--text-caption1)', color: 'var(--label-secondary)', marginBottom: 8,
            }}>
              <svg width="14" height="14" viewBox="0 0 20 20" fill="var(--blue)">
                <path d="M2 5a2 2 0 012-2h7a2 2 0 012 2v4a2 2 0 01-2 2H9l-3 3v-3H4a2 2 0 01-2-2V5z" />
                <path d="M15 7v2a4 4 0 01-4 4H9.828l-1.766 1.767c.28.149.599.233.938.233h2l3 3v-3h2a2 2 0 002-2V9a2 2 0 00-2-2h-1z" />
              </svg>
              Code from SMS fills automatically
            </div>

            {/* Timer */}
            <div style={{
              font: 'var(--text-footnote)',
              color: timer < 60 ? 'var(--red)' : 'var(--label-secondary)',
              fontFamily: 'var(--font-mono)',
              fontWeight: 500,
            }}>
              Code expires in {formatTime(timer)}
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs">
        <SpecTable
          headers={['Element', 'Property', 'Value']}
          rows={[
            ['SIWA Button', 'Min size', '280 x 44 pt'],
            ['SIWA Button', 'Border radius', 'var(--r-xs) (8px)'],
            ['Code Field', 'Size', '44 x 48 pt'],
            ['Code Field', 'Font', 'Mono, 22px, semibold'],
            ['Code Field', 'Border radius', 'var(--r-sm) (12px)'],
            ['Passkey Sheet', 'Border radius', 'var(--r-2xl) (36px)'],
            ['Passkey Sheet', 'Backdrop blur', 'var(--blur-lg)'],
            ['Auth Flow Step', 'Icon size', '40 x 40 pt'],
          ]}
        />
      </Section>
    </div>
  )
}
