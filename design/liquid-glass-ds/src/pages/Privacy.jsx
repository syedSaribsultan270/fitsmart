import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

const timingGuidelines = [
  { title: 'Ask at the Moment of Need', desc: 'Request permissions only when the user performs an action that requires them, not at launch.' },
  { title: 'Explain the Benefit First', desc: 'Show a pre-prompt screen explaining why the permission is needed and what the user gains.' },
  { title: 'Degrade Gracefully if Denied', desc: 'The app must remain functional even if the user denies a permission. Offer alternatives.' },
  { title: 'Provide a Path to Settings', desc: 'If a permission was denied, show a clear way to re-enable it in Settings when the user tries again.' },
]

const dataHeaders = ['Data Type', 'Collect?', 'Guideline']
const dataRows = [
  ['Name', 'Only if needed', 'Use Sign in with Apple'],
  ['Email', 'Only if needed', 'Offer "Hide My Email"'],
  ['Location', 'Prefer approximate', 'Use "While Using" not "Always"'],
  ['Photos', 'Use picker, not full access', 'PhotosPicker API'],
  ['Contacts', 'Use picker, not full access', 'ContactAccessButton'],
]

const privacyGuidelines = [
  { title: 'Minimize Data', desc: 'Collect only what you need. If you can accomplish the task without personal data, do so.' },
  { title: 'Be Transparent', desc: 'Clearly explain what data you collect, why, and how long you keep it. No surprises.' },
  { title: 'Give Control', desc: 'Let users view, export, and delete their data. Provide granular privacy settings.' },
  { title: 'Process On-Device', desc: 'When possible, process data locally. Use on-device ML models instead of sending data to servers.' },
]

export default function Privacy() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Privacy</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Designing for user trust: permission flows, tracking transparency, data minimization, and privacy nutrition labels.
      </p>

      {/* Permission Requests */}
      <Section title="Permission Requests" description="The three-step flow for requesting user permissions.">
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 0 }}>
            {/* Step 1: Pre-prompt */}
            <GlassCard style={{ maxWidth: 320, width: '100%', textAlign: 'center' }}>
              <div style={{ fontSize: 32, marginBottom: 8 }}>&#128247;</div>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Camera Access</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 12 }}>
                We need camera access to scan documents and capture photos for your records.
              </div>
              <GlassButton variant="filled" size="sm">Continue</GlassButton>
              <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', marginTop: 8 }}>Step 1: Pre-prompt (your screen)</div>
            </GlassCard>

            {/* Arrow */}
            <div style={{ font: 'var(--text-title2)', color: 'var(--label-tertiary)', padding: '4px 0' }}>&darr;</div>

            {/* Step 2: System prompt */}
            <GlassPanel style={{ maxWidth: 320, width: '100%', textAlign: 'center', borderRadius: 'var(--r-lg)' }}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>
                &ldquo;App&rdquo; Would Like to Access the Camera
              </div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 16 }}>
                Allow camera access to scan documents.
              </div>
              <div style={{ display: 'flex', gap: 8, justifyContent: 'center' }}>
                <GlassButton variant="glass" size="sm">Don&apos;t Allow</GlassButton>
                <GlassButton variant="filled" size="sm">OK</GlassButton>
              </div>
              <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', marginTop: 10 }}>Step 2: System prompt (iOS)</div>
            </GlassPanel>

            {/* Arrow */}
            <div style={{ font: 'var(--text-title2)', color: 'var(--label-tertiary)', padding: '4px 0' }}>&darr;</div>

            {/* Step 3: Post-decision */}
            <GlassCard style={{ maxWidth: 320, width: '100%', textAlign: 'center' }}>
              <div style={{ fontSize: 32, marginBottom: 8, color: 'var(--green)' }}>&#10003;</div>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>Camera Access Granted</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>
                You can now scan documents and take photos.
              </div>
              <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', marginTop: 10 }}>Step 3: Enabled state</div>
            </GlassCard>
          </div>
        </Preview>
      </Section>

      {/* Timing */}
      <Section title="Timing" description="When and how to request permissions for maximum acceptance.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          {timingGuidelines.map((g) => (
            <GlassCard key={g.title}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>{g.title}</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>{g.desc}</div>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* Tracking Transparency */}
      <Section title="Tracking Transparency" description="App Tracking Transparency (ATT) is required when tracking users across apps and websites.">
        <Preview>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <GlassPanel style={{ maxWidth: 340, width: '100%', textAlign: 'center', borderRadius: 'var(--r-lg)' }}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 8 }}>
                &ldquo;App&rdquo; Would Like Permission to Track You Across Apps and Websites Owned by Other Companies
              </div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 16 }}>
                This allows us to provide personalized ads and measure ad effectiveness.
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                <GlassButton variant="filled" size="sm" style={{ width: '100%' }}>Ask App Not to Track</GlassButton>
                <GlassButton variant="glass" size="sm" style={{ width: '100%' }}>Allow</GlassButton>
              </div>
            </GlassPanel>
          </div>
        </Preview>
        <GlassCard style={{ marginTop: 8 }}>
          <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>
            <strong>ATT Requirements:</strong> You must call requestTrackingAuthorization before tracking. The system prompt cannot be customized beyond the purpose string. If the user denies, you must respect the decision immediately. The IDFA will return all zeros if tracking is not authorized.
          </div>
        </GlassCard>
      </Section>

      {/* Data Minimization */}
      <Section title="Data Minimization" description="Collect only what is necessary. Prefer system-provided pickers over full access.">
        <SpecTable headers={dataHeaders} rows={dataRows} />
      </Section>

      {/* Privacy Nutrition Labels */}
      <Section title="Privacy Nutrition Labels" description="App Store privacy details must accurately reflect your app's data practices.">
        <Preview>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <GlassPanel style={{ maxWidth: 380, width: '100%' }}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 16, textAlign: 'center' }}>App Privacy</div>

              {/* Data Used to Track You */}
              <div style={{ marginBottom: 16 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
                  <span style={{ fontSize: 16 }}>&#128065;</span>
                  <span style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>Data Used to Track You</span>
                </div>
                <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', paddingLeft: 24 }}>
                  {['Identifiers', 'Usage Data'].map((item) => (
                    <span key={item} style={{
                      padding: '3px 10px',
                      borderRadius: 'var(--r-pill)',
                      background: 'var(--fill)',
                      font: 'var(--text-caption1)',
                      color: 'var(--label-secondary)',
                    }}>{item}</span>
                  ))}
                </div>
              </div>

              <div style={{ borderBottom: '0.5px solid var(--separator)', marginBottom: 16 }} />

              {/* Data Linked to You */}
              <div style={{ marginBottom: 16 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
                  <span style={{ fontSize: 16 }}>&#128100;</span>
                  <span style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>Data Linked to You</span>
                </div>
                <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', paddingLeft: 24 }}>
                  {['Contact Info', 'Location'].map((item) => (
                    <span key={item} style={{
                      padding: '3px 10px',
                      borderRadius: 'var(--r-pill)',
                      background: 'var(--fill)',
                      font: 'var(--text-caption1)',
                      color: 'var(--label-secondary)',
                    }}>{item}</span>
                  ))}
                </div>
              </div>

              <div style={{ borderBottom: '0.5px solid var(--separator)', marginBottom: 16 }} />

              {/* Data Not Linked to You */}
              <div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
                  <span style={{ fontSize: 16 }}>&#128274;</span>
                  <span style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>Data Not Linked to You</span>
                </div>
                <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', paddingLeft: 24 }}>
                  {['Diagnostics'].map((item) => (
                    <span key={item} style={{
                      padding: '3px 10px',
                      borderRadius: 'var(--r-pill)',
                      background: 'var(--fill)',
                      font: 'var(--text-caption1)',
                      color: 'var(--label-secondary)',
                    }}>{item}</span>
                  ))}
                </div>
              </div>
            </GlassPanel>
          </div>
        </Preview>
      </Section>

      {/* Guidelines */}
      <Section title="Guidelines" description="Core principles for privacy-respecting design.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          {privacyGuidelines.map((g) => (
            <GlassCard key={g.title}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>{g.title}</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>{g.desc}</div>
            </GlassCard>
          ))}
        </div>
      </Section>
    </div>
  )
}
