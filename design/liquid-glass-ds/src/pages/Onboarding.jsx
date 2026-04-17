import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

/* Feature row icon helper */
function FeatureIcon({ children, color = 'var(--blue)' }) {
  return (
    <div style={{
      width: 32, height: 32, borderRadius: 'var(--r-xs)',
      background: color,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      flexShrink: 0,
    }}>
      {children}
    </div>
  )
}

/* Progress dots */
function ProgressDots({ total, current }) {
  return (
    <div style={{ display: 'flex', gap: 6, justifyContent: 'center' }}>
      {Array.from({ length: total }, (_, i) => (
        <div key={i} style={{
          width: i === current ? 8 : 6,
          height: i === current ? 8 : 6,
          borderRadius: '50%',
          background: i === current ? 'var(--blue)' : 'var(--label-quaternary)',
          transition: 'all var(--dur) var(--ease)',
        }} />
      ))}
    </div>
  )
}

export default function Onboarding() {
  const [tipStep, setTipStep] = useState(0)
  const [onboardingStep, setOnboardingStep] = useState(0)

  const tips = [
    { text: 'Tap here to create a new project', target: 'top-right', buttonLabel: 'New' },
    { text: 'Swipe to switch between views', target: 'center', buttonLabel: 'Views' },
    { text: 'Long-press for quick actions', target: 'bottom-left', buttonLabel: 'Actions' },
  ]

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Onboarding</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Welcome screens, feature highlights, permission priming, progressive disclosure, and best practices for first-run experiences.
      </p>

      {/* ── Welcome Screen ── */}
      <Section title="Welcome Screen" description="A full-screen welcome experience with app icon, feature highlights, and a primary call-to-action.">
        <Preview gradient style={{ minHeight: 480 }}>
          <div style={{ maxWidth: 360, margin: '0 auto', textAlign: 'center', padding: '24px 0' }}>
            {/* App icon */}
            <div style={{
              width: 80, height: 80, borderRadius: 'var(--r-lg)',
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-md))',
              WebkitBackdropFilter: 'blur(var(--blur-md))',
              border: '1px solid var(--glass-border)',
              boxShadow: 'var(--glass-shadow-lg)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              margin: '0 auto 20px',
              fontSize: 36,
            }}>
              <svg width="40" height="40" viewBox="0 0 40 40" fill="none">
                <rect x="4" y="4" width="32" height="32" rx="8" fill="var(--blue)" opacity="0.3" />
                <rect x="8" y="8" width="24" height="24" rx="6" fill="var(--blue)" opacity="0.5" />
                <rect x="12" y="12" width="16" height="16" rx="4" fill="var(--blue)" />
              </svg>
            </div>

            {/* App name */}
            <div style={{ font: 'var(--text-large-title)', color: 'var(--label)', marginBottom: 4 }}>
              GlassKit
            </div>
            <div style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 36 }}>
              Design with depth and light
            </div>

            {/* Feature rows */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 20, textAlign: 'left', marginBottom: 36 }}>
              <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
                <FeatureIcon color="var(--blue)">
                  <svg width="18" height="18" viewBox="0 0 20 20" fill="#fff">
                    <path d="M10 2a8 8 0 100 16 8 8 0 000-16zm0 2a6 6 0 11-5.17 9.05l-.01-.01A5.96 5.96 0 014 10a6 6 0 016-6z" opacity="0.6" />
                    <circle cx="10" cy="10" r="3" fill="#fff" />
                  </svg>
                </FeatureIcon>
                <div>
                  <div style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>Liquid Glass</div>
                  <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>Translucent materials that adapt to content</div>
                </div>
              </div>

              <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
                <FeatureIcon color="var(--purple)">
                  <svg width="18" height="18" viewBox="0 0 20 20" fill="#fff">
                    <path d="M5 3a2 2 0 00-2 2v10a2 2 0 002 2h5v-4a2 2 0 012-2h4V5a2 2 0 00-2-2H5z" />
                    <path d="M12 13a1 1 0 00-1 1v3.586l4.293-4.293A1 1 0 0014.586 13H12z" />
                  </svg>
                </FeatureIcon>
                <div>
                  <div style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>Spring Motion</div>
                  <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>Fluid animations that feel natural</div>
                </div>
              </div>

              <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
                <FeatureIcon color="var(--indigo)">
                  <svg width="18" height="18" viewBox="0 0 20 20" fill="#fff">
                    <path d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" />
                  </svg>
                </FeatureIcon>
                <div>
                  <div style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>Dark Mode</div>
                  <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>Beautiful in any lighting</div>
                </div>
              </div>
            </div>

            {/* Continue button */}
            <GlassButton variant="filled" style={{ width: '100%', minWidth: 280 }}>
              Continue
            </GlassButton>
          </div>
        </Preview>
      </Section>

      {/* ── Feature Highlights ── */}
      <Section title="Feature Highlights" description="Contextual tooltip callouts that guide users through key features on their first interaction.">
        <Preview>
          <div style={{ maxWidth: 400, margin: '0 auto' }}>
            {/* Mock app screen */}
            <GlassPanel variant="thick" style={{ minHeight: 280, position: 'relative', overflow: 'visible' }}>
              {/* Mock toolbar */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
                <div style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>My Projects</div>
                <GlassButton variant="filled" size="sm" style={{
                  position: 'relative',
                  boxShadow: tipStep === 0 ? '0 0 0 3px rgba(0,122,255,0.3)' : 'none',
                }}>
                  {tips[0].buttonLabel}
                </GlassButton>
              </div>

              {/* Mock content area */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                <div style={{
                  padding: '12px 16px', borderRadius: 'var(--r-sm)',
                  background: 'var(--fill-tertiary)',
                  display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                  boxShadow: tipStep === 1 ? '0 0 0 3px rgba(0,122,255,0.3)' : 'none',
                }}>
                  <span style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>Design System</span>
                  <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>12 files</span>
                </div>
                <div style={{
                  padding: '12px 16px', borderRadius: 'var(--r-sm)',
                  background: 'var(--fill-tertiary)',
                  display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                }}>
                  <span style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>Marketing Site</span>
                  <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>8 files</span>
                </div>
                <div style={{
                  padding: '12px 16px', borderRadius: 'var(--r-sm)',
                  background: 'var(--fill-tertiary)',
                  display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                  boxShadow: tipStep === 2 ? '0 0 0 3px rgba(0,122,255,0.3)' : 'none',
                }}>
                  <span style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>App Icons</span>
                  <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>3 files</span>
                </div>
              </div>

              {/* Tooltip callout */}
              <div style={{
                position: 'absolute',
                ...(tipStep === 0 ? { top: -12, right: 12, transform: 'translateY(-100%)' } :
                    tipStep === 1 ? { top: '50%', left: '50%', transform: 'translate(-50%, -50%)' } :
                    { bottom: -12, left: 12, transform: 'translateY(100%)' }),
                zIndex: 10,
                animation: 'tipBounce 0.5s cubic-bezier(0.34, 1.56, 0.64, 1)',
              }}>
                <style>{`@keyframes tipBounce { from { opacity: 0; transform: translateY(${tipStep === 2 ? '80%' : tipStep === 0 ? '-80%' : '-40%'}) scale(0.9); } to { opacity: 1; } }`}</style>
                <GlassPanel variant="thick" style={{
                  padding: '12px 16px',
                  boxShadow: 'var(--glass-shadow-lg)',
                  maxWidth: 220,
                }}>
                  <div style={{ font: 'var(--text-subhead)', color: 'var(--label)', marginBottom: 10 }}>
                    {tips[tipStep].text}
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <span style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>
                      {tipStep + 1} of {tips.length}
                    </span>
                    <GlassButton
                      variant="filled" size="sm"
                      onClick={() => setTipStep(s => (s + 1) % tips.length)}
                    >
                      {tipStep < tips.length - 1 ? 'Next' : 'Got it'}
                    </GlassButton>
                  </div>
                </GlassPanel>
                {/* Arrow pointer */}
                <div style={{
                  position: 'absolute',
                  ...(tipStep === 0 ? { bottom: -6, right: 24 } :
                      tipStep === 1 ? { bottom: -6, left: '50%', marginLeft: -6 } :
                      { top: -6, left: 24 }),
                  width: 12, height: 12,
                  background: 'var(--glass-bg-thick)',
                  border: '0.5px solid var(--glass-border)',
                  transform: 'rotate(45deg)',
                  boxShadow: 'var(--glass-shadow)',
                }} />
              </div>
            </GlassPanel>
          </div>
        </Preview>
      </Section>

      {/* ── Permission Priming ── */}
      <Section title="Permission Priming" description="Pre-permission screens explain WHY you need access before showing the system prompt.">
        <Preview gradient>
          <div style={{ maxWidth: 340, margin: '0 auto' }}>
            <GlassPanel variant="thick" style={{ textAlign: 'center' }}>
              {/* Location icon */}
              <div style={{
                width: 64, height: 64, borderRadius: 'var(--r-md)',
                background: 'rgba(0, 122, 255, 0.12)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                margin: '0 auto 16px',
              }}>
                <svg width="32" height="32" viewBox="0 0 24 24" fill="var(--blue)">
                  <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z" />
                </svg>
              </div>

              <div style={{ font: 'var(--text-title3)', color: 'var(--label)', marginBottom: 8 }}>
                Enable Location
              </div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', lineHeight: 1.5, marginBottom: 24 }}>
                We use your location to show nearby coffee shops and provide walking directions.
              </div>

              <div style={{ display: 'flex', gap: 12 }}>
                <GlassButton variant="glass" style={{ flex: 1 }}>Not Now</GlassButton>
                <GlassButton variant="filled" style={{ flex: 1 }}>Enable</GlassButton>
              </div>
            </GlassPanel>

            <p style={{ font: 'var(--text-footnote)', color: 'var(--label-tertiary)', textAlign: 'center', marginTop: 16, fontStyle: 'italic' }}>
              Always explain WHY before showing the system permission prompt.
            </p>
          </div>
        </Preview>
      </Section>

      {/* ── Progressive Disclosure ── */}
      <Section title="Progressive Disclosure" description="Reveal complexity gradually as users gain experience with your app.">
        <Preview>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 16 }}>
            {[
              {
                level: 'Basic',
                desc: 'Simple interface with essential options only. Perfect for first-time users.',
                items: ['Create', 'Edit', 'Share'],
                color: 'var(--green)',
                opacity: 0.4,
              },
              {
                level: 'Intermediate',
                desc: 'More features revealed as users become comfortable with the basics.',
                items: ['Create', 'Edit', 'Share', 'Templates', 'Folders', 'Tags'],
                color: 'var(--blue)',
                opacity: 0.6,
              },
              {
                level: 'Advanced',
                desc: 'Full power user interface with all capabilities exposed.',
                items: ['Create', 'Edit', 'Share', 'Templates', 'Folders', 'Tags', 'Automations', 'API Access', 'Plugins'],
                color: 'var(--purple)',
                opacity: 0.8,
              },
            ].map((stage, i) => (
              <GlassCard key={i}>
                <div style={{ padding: 20 }}>
                  <div style={{
                    display: 'inline-block', padding: '2px 10px',
                    borderRadius: 'var(--r-pill)', background: stage.color,
                    font: 'var(--text-caption2)', color: '#fff', fontWeight: 600,
                    marginBottom: 10, opacity: stage.opacity + 0.4,
                  }}>
                    {stage.level}
                  </div>
                  <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)', marginBottom: 12, lineHeight: 1.5 }}>
                    {stage.desc}
                  </div>
                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: 4 }}>
                    {stage.items.map((item, j) => (
                      <span key={j} style={{
                        font: 'var(--text-caption2)', color: 'var(--label-secondary)',
                        background: 'var(--fill)', borderRadius: 'var(--r-xs)',
                        padding: '2px 8px',
                      }}>
                        {item}
                      </span>
                    ))}
                  </div>
                </div>
              </GlassCard>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ── Skip Affordance ── */}
      <Section title="Skip Affordance" description="Always provide a way for users to skip onboarding and jump into the app.">
        <Preview gradient>
          <div style={{ maxWidth: 360, margin: '0 auto', position: 'relative', minHeight: 320 }}>
            {/* Skip button top-right */}
            <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 16 }}>
              <button style={{
                background: 'none', border: 'none', cursor: 'pointer',
                font: 'var(--text-subhead)', color: 'var(--label-secondary)',
                padding: '4px 8px',
              }}>
                Skip
              </button>
            </div>

            {/* Onboarding content */}
            <GlassPanel variant="thick" style={{ textAlign: 'center', minHeight: 200 }}>
              {onboardingStep === 0 && (
                <div style={{ animation: 'fadeIn 0.3s ease' }}>
                  <div style={{ fontSize: 40, marginBottom: 12 }}>
                    <svg width="48" height="48" viewBox="0 0 48 48" fill="var(--blue)">
                      <rect x="8" y="8" width="32" height="32" rx="8" opacity="0.2" />
                      <path d="M24 14l8 14H16l8-14z" />
                    </svg>
                  </div>
                  <div style={{ font: 'var(--text-title3)', color: 'var(--label)', marginBottom: 8 }}>
                    Welcome to GlassKit
                  </div>
                  <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', lineHeight: 1.5 }}>
                    Create stunning interfaces with Liquid Glass materials and fluid animations.
                  </div>
                </div>
              )}
              {onboardingStep === 1 && (
                <div style={{ animation: 'fadeIn 0.3s ease' }}>
                  <div style={{ fontSize: 40, marginBottom: 12 }}>
                    <svg width="48" height="48" viewBox="0 0 48 48" fill="var(--purple)">
                      <circle cx="24" cy="24" r="16" opacity="0.2" />
                      <circle cx="24" cy="24" r="8" />
                    </svg>
                  </div>
                  <div style={{ font: 'var(--text-title3)', color: 'var(--label)', marginBottom: 8 }}>
                    Design Tokens
                  </div>
                  <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', lineHeight: 1.5 }}>
                    A comprehensive token system for colors, spacing, typography, and glass materials.
                  </div>
                </div>
              )}
              {onboardingStep === 2 && (
                <div style={{ animation: 'fadeIn 0.3s ease' }}>
                  <div style={{ fontSize: 40, marginBottom: 12 }}>
                    <svg width="48" height="48" viewBox="0 0 48 48" fill="var(--green)">
                      <rect x="6" y="14" width="36" height="20" rx="4" opacity="0.2" />
                      <path d="M18 24l4 4 8-8" stroke="var(--green)" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" fill="none" />
                    </svg>
                  </div>
                  <div style={{ font: 'var(--text-title3)', color: 'var(--label)', marginBottom: 8 }}>
                    Ready to Build
                  </div>
                  <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', lineHeight: 1.5 }}>
                    You are all set. Start building beautiful glass-styled interfaces today.
                  </div>
                </div>
              )}
              <style>{`@keyframes fadeIn { from { opacity: 0; transform: translateX(20px); } to { opacity: 1; transform: translateX(0); } }`}</style>
            </GlassPanel>

            {/* Navigation */}
            <div style={{ marginTop: 20, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16 }}>
              {/* Progress dots */}
              <ProgressDots total={3} current={onboardingStep} />

              {/* Next / Get Started button */}
              <GlassButton
                variant="filled"
                style={{ width: '100%', minWidth: 280 }}
                onClick={() => setOnboardingStep(s => (s + 1) % 3)}
              >
                {onboardingStep === 2 ? 'Get Started' : 'Next'}
              </GlassButton>

              {/* Sign in link */}
              <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>
                Already have an account?{' '}
                <span style={{ color: 'var(--blue)', cursor: 'pointer', fontWeight: 500 }}>Sign In</span>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Guidelines ── */}
      <Section title="Guidelines" description="Best practices for designing effective onboarding experiences.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: 16 }}>
          {[
            { title: 'Max 3-5 Screens', desc: 'Keep onboarding short. Users want to start using your app, not read a manual.' },
            { title: 'Always Allow Skip', desc: 'Provide a visible skip option. Returning users and power users will appreciate it.' },
            { title: 'Benefits, Not Features', desc: 'Explain what users can accomplish, not technical details about your app.' },
            { title: 'Contextual Permissions', desc: 'Request permissions when the user encounters the feature that needs them.' },
            { title: 'Progressive Disclosure', desc: 'Reveal advanced features gradually as users become more experienced.' },
            { title: 'Respect the User', desc: 'Never force onboarding. Make it helpful, not a barrier to entry.' },
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
            ['Welcome icon', 'Size', '80 x 80 pt'],
            ['Welcome icon', 'Border radius', 'var(--r-lg) (22px)'],
            ['Feature icon', 'Size', '32 x 32 pt'],
            ['Feature icon', 'Border radius', 'var(--r-xs) (8px)'],
            ['Max screens', 'Count', '3-5'],
            ['CTA button', 'Min width', '280px'],
            ['Progress dot (inactive)', 'Size', '6px'],
            ['Progress dot (active)', 'Size', '8px'],
            ['Tooltip callout', 'Max width', '220px'],
            ['Permission icon', 'Size', '48 x 48 pt'],
          ]}
        />
      </Section>
    </div>
  )
}
