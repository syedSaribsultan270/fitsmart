import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton, GlassProgress } from '../components/Glass'

export default function EmptyStates() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Empty States</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Thoughtful empty states guide users when there is no content to display. Each state communicates context, offers guidance, and provides a clear action.
      </p>

      {/* ── First Use ── */}
      <Section title="First Use" description="When the user hasn't created anything yet. A welcoming state that encourages the first action.">
        <Preview gradient>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 32, justifyContent: 'center' }}>
            {/* Simple variant */}
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              padding: 32,
              maxWidth: 300,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              textAlign: 'center',
              gap: 12,
            }}>
              {/* Document outline icon */}
              <svg width="56" height="56" viewBox="0 0 56 56" fill="none" style={{ color: 'var(--label-tertiary)' }}>
                <rect x="12" y="6" width="32" height="44" rx="4" stroke="currentColor" strokeWidth="2" fill="none" />
                <line x1="20" y1="18" x2="36" y2="18" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
                <line x1="20" y1="26" x2="36" y2="26" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
                <line x1="20" y1="34" x2="30" y2="34" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
              </svg>
              <h3 style={{ font: 'var(--text-headline)', color: 'var(--label)', margin: 0 }}>No Notes Yet</h3>
              <p style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', margin: 0 }}>
                Create your first note to get started.
              </p>
              <div style={{ marginTop: 8 }}>
                <GlassButton variant="filled">Create Note</GlassButton>
              </div>
            </div>

            {/* Illustration variant */}
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              padding: 32,
              maxWidth: 300,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              textAlign: 'center',
              gap: 12,
            }}>
              {/* Concentric circles + document icon illustration */}
              <div style={{ position: 'relative', width: 80, height: 80, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <div style={{
                  position: 'absolute', width: 80, height: 80, borderRadius: '50%',
                  border: '1px solid rgba(255,255,255,0.08)',
                }} />
                <div style={{
                  position: 'absolute', width: 60, height: 60, borderRadius: '50%',
                  border: '1px solid rgba(255,255,255,0.12)',
                }} />
                <div style={{
                  position: 'absolute', width: 40, height: 40, borderRadius: '50%',
                  border: '1px solid rgba(255,255,255,0.18)',
                }} />
                <svg width="28" height="28" viewBox="0 0 28 28" fill="none" style={{ position: 'relative', zIndex: 1, color: 'var(--label-tertiary)' }}>
                  <rect x="5" y="2" width="18" height="24" rx="3" stroke="currentColor" strokeWidth="1.5" fill="none" />
                  <line x1="9" y1="9" x2="19" y2="9" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                  <line x1="9" y1="14" x2="19" y2="14" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                  <line x1="9" y1="19" x2="15" y2="19" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                </svg>
              </div>
              <h3 style={{ font: 'var(--text-headline)', color: 'var(--label)', margin: 0 }}>No Notes Yet</h3>
              <p style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', margin: 0 }}>
                Create your first note to get started.
              </p>
              <div style={{ marginTop: 8 }}>
                <GlassButton variant="filled">Create Note</GlassButton>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── No Results ── */}
      <Section title="No Results" description="When a search returns no matching items. Helps the user understand what happened and how to recover.">
        <Preview gradient>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              padding: 32,
              maxWidth: 300,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              textAlign: 'center',
              gap: 12,
            }}>
              {/* Magnifying glass with X */}
              <svg width="48" height="48" viewBox="0 0 48 48" fill="none" style={{ color: 'var(--label-tertiary)' }}>
                <circle cx="20" cy="20" r="12" stroke="currentColor" strokeWidth="2.5" fill="none" />
                <line x1="29" y1="29" x2="40" y2="40" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" />
                <line x1="15" y1="15" x2="25" y2="25" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
                <line x1="25" y1="15" x2="15" y2="25" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
              </svg>
              <h3 style={{ font: 'var(--text-headline)', color: 'var(--label)', margin: 0 }}>No Results</h3>
              <p style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', margin: 0 }}>
                No results for "xyzzyx". Try a different search term.
              </p>
              <div style={{ marginTop: 8 }}>
                <GlassButton variant="plain">Clear Search</GlassButton>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Error State ── */}
      <Section title="Error State" description="When something has gone wrong and content cannot be displayed. Provides a path to recovery.">
        <Preview gradient>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              padding: 32,
              maxWidth: 300,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              textAlign: 'center',
              gap: 12,
            }}>
              {/* Exclamation triangle */}
              <svg width="48" height="48" viewBox="0 0 48 48" fill="none" style={{ color: 'var(--red)' }}>
                <path d="M24 6L44 42H4L24 6Z" stroke="currentColor" strokeWidth="2.5" strokeLinejoin="round" fill="none" />
                <line x1="24" y1="20" x2="24" y2="30" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" />
                <circle cx="24" cy="35" r="1.5" fill="currentColor" />
              </svg>
              <h3 style={{ font: 'var(--text-headline)', color: 'var(--label)', margin: 0 }}>Something Went Wrong</h3>
              <p style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', margin: 0 }}>
                We couldn't load your data. Please try again.
              </p>
              <div style={{ display: 'flex', gap: 12, marginTop: 8 }}>
                <GlassButton variant="plain">Go Back</GlassButton>
                <GlassButton variant="filled">Retry</GlassButton>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Offline ── */}
      <Section title="Offline" description="When the device has no internet connection. Communicates the issue and offers a retry path.">
        <Preview gradient>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              padding: 32,
              maxWidth: 300,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              textAlign: 'center',
              gap: 12,
            }}>
              {/* Wifi-off icon */}
              <svg width="48" height="48" viewBox="0 0 48 48" fill="none" style={{ color: 'var(--orange)' }}>
                <path d="M8 18C12.4 13.6 18 11 24 11C30 11 35.6 13.6 40 18" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" fill="none" />
                <path d="M14 25C16.7 22.3 20.2 21 24 21C27.8 21 31.3 22.3 34 25" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" fill="none" />
                <path d="M19 32C20.3 30.7 22.1 30 24 30C25.9 30 27.7 30.7 29 32" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" fill="none" />
                <circle cx="24" cy="37" r="2" fill="currentColor" />
                {/* Slash line */}
                <line x1="8" y1="40" x2="40" y2="8" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" />
              </svg>
              <h3 style={{ font: 'var(--text-headline)', color: 'var(--label)', margin: 0 }}>You're Offline</h3>
              <p style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', margin: 0 }}>
                Check your connection and try again.
              </p>
              <div style={{ marginTop: 8 }}>
                <GlassButton variant="filled">Try Again</GlassButton>
              </div>
              <p style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', margin: 0 }}>
                Last synced 5 minutes ago
              </p>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Permission Required ── */}
      <Section title="Permission Required" description="When the app needs access that the user has not yet granted. Clearly states what is needed and why.">
        <Preview gradient>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              padding: 32,
              maxWidth: 300,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              textAlign: 'center',
              gap: 12,
            }}>
              {/* Lock icon */}
              <svg width="48" height="48" viewBox="0 0 48 48" fill="none" style={{ color: 'var(--label-secondary)' }}>
                <rect x="12" y="22" width="24" height="18" rx="4" stroke="currentColor" strokeWidth="2.5" fill="none" />
                <path d="M16 22V16C16 11.6 19.6 8 24 8C28.4 8 32 11.6 32 16V22" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" fill="none" />
                <circle cx="24" cy="32" r="2.5" fill="currentColor" />
                <line x1="24" y1="34.5" x2="24" y2="37" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
              </svg>
              <h3 style={{ font: 'var(--text-headline)', color: 'var(--label)', margin: 0 }}>Photos Access Required</h3>
              <p style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', margin: 0 }}>
                Allow access to your photo library to continue.
              </p>
              <div style={{ marginTop: 8 }}>
                <GlassButton variant="filled">Open Settings</GlassButton>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Empty State Guidelines ── */}
      <Section title="Empty State Guidelines" description="Best practices for designing effective empty states.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: 16 }}>
          {[
            'Use a clear, concise title',
            'Provide a helpful description',
            'Always offer an action',
            'Use appropriate icons — not decorative illustrations',
            'Match the emotional tone to the context',
          ].map((guideline) => (
            <GlassCard key={guideline} style={{ padding: 20 }}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
                <svg width="20" height="20" viewBox="0 0 20 20" fill="none" style={{ color: 'var(--green)', flexShrink: 0, marginTop: 1 }}>
                  <circle cx="10" cy="10" r="9" stroke="currentColor" strokeWidth="1.5" fill="none" />
                  <path d="M6 10L9 13L14 7" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
                <span style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>{guideline}</span>
              </div>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs" description="Reference values for implementing empty states.">
        <SpecTable
          headers={['Property', 'Value']}
          rows={[
            ['Icon size', '48-56px'],
            ['Title font', 'var(--text-headline)'],
            ['Description font', 'var(--text-subhead), secondary color'],
            ['Max width', '300px'],
            ['Vertical gap', '12px'],
            ['Action button margin-top', '20px'],
          ]}
        />
      </Section>
    </div>
  )
}
