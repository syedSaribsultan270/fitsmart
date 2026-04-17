import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

const copyRules = [
  { category: 'Button Labels', good: 'Save', bad: 'Click here to save your data' },
  { category: 'Error Messages', good: 'Email address is invalid', bad: 'Error 422: validation failed' },
  { category: 'Empty States', good: 'No messages yet', bad: 'Your inbox is empty at this time' },
  { category: 'Confirmations', good: 'Delete photo?', bad: 'Are you sure you want to permanently delete this photo from your library?' },
  { category: 'Placeholders', good: 'Search', bad: 'Enter your search query here' },
]

const terminologyHeaders = ['Use', "Don't Use", 'Platform']
const terminologyRows = [
  ['tap', 'click, press', 'iOS'],
  ['click', 'tap', 'macOS'],
  ['swipe', 'slide, drag', 'iOS'],
  ['long press', 'press and hold', 'iOS'],
  ['Home Screen', 'desktop, launcher', 'iOS'],
  ['app', 'application', 'All'],
  ['Wi-Fi', 'wifi, WiFi, WIFI', 'All'],
  ['iCloud', 'I-cloud, i-Cloud', 'All'],
]

const capitalizationExamples = [
  { style: 'Title Case', examples: ['Save to Files', 'Add to Library'], usage: 'Buttons, menu items, tab labels' },
  { style: 'Sentence case', examples: ['Your account has been updated', 'Last synced 5 minutes ago'], usage: 'Labels, descriptions, body text' },
  { style: 'ALL CAPS', examples: ['GB', 'MB', 'URL'], usage: 'Abbreviations only. Never for emphasis.' },
]

const punctuationRules = [
  { title: 'No Periods on Short Text', desc: 'Do not use periods on labels, buttons, or list items. They add visual noise to brief text.' },
  { title: 'Ellipsis for Continuation', desc: 'Use an ellipsis (...) to indicate truncation or that more input is needed, such as "Save As..." or "Choose File..."' },
  { title: 'Em Dash for Asides', desc: 'Use an em dash (\u2014) not a hyphen (-) or en dash (\u2013) for parenthetical asides within a sentence.' },
  { title: 'Oxford Comma', desc: 'Always use the Oxford comma: "Photos, Videos, and Documents" not "Photos, Videos and Documents."' },
]

const errorHeaders = ['Scenario', 'Template', 'Example']
const errorRows = [
  ['Required field', '[Field] is required', 'Email is required'],
  ['Invalid format', '[Field] is invalid', 'Email address is invalid'],
  ['Too short', '[Field] must be at least [N] characters', 'Password must be at least 8 characters'],
  ['Permission denied', 'Allow [permission] to [benefit]', 'Allow location to find nearby stores'],
  ['Network error', 'Couldn\'t [action]. Check your connection.', 'Couldn\'t load photos. Check your connection.'],
]

const toneGuidelines = [
  { title: 'Be Direct', desc: 'Say what you mean in as few words as possible. Remove filler words and unnecessary qualifiers.' },
  { title: 'Be Positive', desc: 'Frame guidance as what to do, not what to avoid. "Use sentence case" is better than "Don\'t use all caps."' },
  { title: 'Be Helpful', desc: 'Always offer a next step. An error message without a resolution path is just a dead end.' },
  { title: 'Be Human', desc: 'Write like a knowledgeable friend, not a robot. Avoid jargon, technical codes, and stilted formal language.' },
  { title: 'Be Respectful', desc: 'Never blame the user. "Something went wrong" is better than "You entered an invalid value."' },
]

export default function WritingTone() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Writing & Tone</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        UI copy guidelines, Apple platform terminology, capitalization rules, and error message templates.
      </p>

      {/* UI Copy Rules */}
      <Section title="UI Copy Rules" description="Short, clear, and actionable. Every word must earn its place.">
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          {copyRules.map((rule) => (
            <GlassCard key={rule.category}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 8 }}>{rule.category}</div>
              <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
                <div style={{ flex: '1 1 160px' }}>
                  <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--green)', marginBottom: 4 }}>Do</div>
                  <div style={{
                    padding: '6px 12px',
                    borderRadius: 'var(--r-sm)',
                    background: 'rgba(52, 199, 89, 0.1)',
                    font: 'var(--text-subhead)',
                    color: 'var(--label)',
                  }}>{rule.good}</div>
                </div>
                <div style={{ flex: '1 1 160px' }}>
                  <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--red)', marginBottom: 4 }}>Don&apos;t</div>
                  <div style={{
                    padding: '6px 12px',
                    borderRadius: 'var(--r-sm)',
                    background: 'rgba(255, 59, 48, 0.1)',
                    font: 'var(--text-subhead)',
                    color: 'var(--label)',
                  }}>{rule.bad}</div>
                </div>
              </div>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* Apple Terminology */}
      <Section title="Apple Terminology" description="Use the correct platform-specific terms. These are defined by Apple's style guide.">
        <SpecTable headers={terminologyHeaders} rows={terminologyRows} />
      </Section>

      {/* Capitalization */}
      <Section title="Capitalization" description="Consistent capitalization reinforces the visual hierarchy.">
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {capitalizationExamples.map((cap) => (
              <div key={cap.style}>
                <div style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)', marginBottom: 6 }}>{cap.style}</div>
                <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 4 }}>
                  {cap.examples.map((ex) => (
                    <span key={ex} style={{
                      display: 'inline-block',
                      padding: '4px 14px',
                      borderRadius: 'var(--r-pill)',
                      background: 'var(--glass-bg)',
                      backdropFilter: 'blur(var(--blur-sm))',
                      WebkitBackdropFilter: 'blur(var(--blur-sm))',
                      border: '0.5px solid var(--glass-border)',
                      font: 'var(--text-footnote)',
                      color: 'var(--label)',
                    }}>{ex}</span>
                  ))}
                </div>
                <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>{cap.usage}</div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* Punctuation */}
      <Section title="Punctuation" description="Small marks, big impact on clarity and professionalism.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          {punctuationRules.map((rule) => (
            <GlassCard key={rule.title}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>{rule.title}</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>{rule.desc}</div>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* Error Message Templates */}
      <Section title="Error Message Templates" description="Consistent, predictable patterns for every error state.">
        <SpecTable headers={errorHeaders} rows={errorRows} />
      </Section>

      {/* Tone Guidelines */}
      <Section title="Tone Guidelines" description="The voice behind every label, alert, and message.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          {toneGuidelines.map((g) => (
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
