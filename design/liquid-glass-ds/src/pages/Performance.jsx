import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

const framePhases = [
  { label: 'Layout', ms: 2, color: 'var(--blue)' },
  { label: 'Paint', ms: 4, color: 'var(--purple)' },
  { label: 'Composite', ms: 2, color: 'var(--teal)' },
  { label: 'Idle', ms: 8.67, color: 'var(--green)' },
]

const scrollGuidelines = [
  'Avoid complex shadows during scroll',
  'Use cell reuse for lists',
  'Flatten view hierarchy',
]

const launchPhases = [
  { label: 'Process creation', ms: 50, color: 'var(--gray3)' },
  { label: 'dylib loading', ms: 100, color: 'var(--orange)' },
  { label: 'Runtime init', ms: 50, color: 'var(--yellow)' },
  { label: 'UIKit init', ms: 50, color: 'var(--blue)' },
  { label: 'App init', ms: 80, color: 'var(--purple)' },
  { label: 'First frame', ms: 70, color: 'var(--green)' },
]

const launchGuidelines = [
  'Defer non-essential work',
  'Lazy-load screens',
  'Minimize launch dependencies',
]

const batteryGuidelines = [
  { title: 'Use Location Only When Needed', desc: 'Request "While Using" instead of "Always". Stop location updates as soon as possible.' },
  { title: 'Batch Network Requests', desc: 'Combine multiple small requests into fewer larger ones. Use URLSession background configuration.' },
  { title: 'Prefer Background Transfers', desc: 'Use URLSession background transfers for large downloads. The system schedules them efficiently.' },
  { title: 'Reduce GPS Accuracy', desc: 'Use kCLLocationAccuracyReduced when approximate location is sufficient. It uses less power.' },
  { title: 'Pause Background Animations', desc: 'Stop all animations and timers when the app enters the background. Resume when foregrounded.' },
]

const specHeaders = ['Metric', 'Target', 'Notes']
const specRows = [
  ['Frame rate', '60fps (16.67ms/frame)', '120fps on ProMotion devices (8.33ms)'],
  ['Cold launch', '< 400ms to first frame', 'Measured from process creation'],
  ['Image memory', 'width x height x 4 bytes', '4000x3000 = 48MB uncompressed'],
  ['Background task limit', '30 seconds', 'Use background tasks for longer work'],
]

export default function Performance() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Performance</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Frame budgets, launch time optimization, memory management, and battery-efficient design patterns.
      </p>

      {/* 60fps Scrolling */}
      <Section title="60fps Scrolling" description="Every frame must be rendered within 16.67ms at 60fps. Exceeding the budget causes dropped frames.">
        <Preview>
          <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', marginBottom: 8 }}>Frame Budget: 16.67ms per frame at 60fps</div>

          {/* Frame timeline */}
          <div style={{
            display: 'flex',
            borderRadius: 'var(--r-sm)',
            overflow: 'hidden',
            height: 40,
            marginBottom: 12,
          }}>
            {framePhases.map((phase) => (
              <div key={phase.label} style={{
                flex: `${phase.ms} 0 0`,
                background: phase.color,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#fff',
                font: 'var(--text-caption2)',
                fontWeight: 600,
                minWidth: 0,
                overflow: 'hidden',
                whiteSpace: 'nowrap',
                padding: '0 4px',
              }}>
                {phase.label} ({phase.ms}ms)
              </div>
            ))}
          </div>

          {/* Dropped frame demo */}
          <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', marginBottom: 8 }}>Dropped Frame (work exceeds budget)</div>
          <div style={{
            display: 'flex',
            borderRadius: 'var(--r-sm)',
            overflow: 'hidden',
            height: 40,
            marginBottom: 16,
          }}>
            <div style={{ flex: '6 0 0', background: 'var(--blue)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', font: 'var(--text-caption2)', fontWeight: 600 }}>Layout (6ms)</div>
            <div style={{ flex: '8 0 0', background: 'var(--purple)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', font: 'var(--text-caption2)', fontWeight: 600 }}>Paint (8ms)</div>
            <div style={{ flex: '5 0 0', background: 'var(--red)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', font: 'var(--text-caption2)', fontWeight: 600 }}>
              Overflow!
            </div>
          </div>

          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {scrollGuidelines.map((g) => (
              <GlassCard key={g} style={{ flex: '1 1 180px' }}>
                <div style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>{g}</div>
              </GlassCard>
            ))}
          </div>
        </Preview>
      </Section>

      {/* Launch Time */}
      <Section title="Launch Time" description="Cold start must complete within 400ms to first frame. Each phase must be optimized.">
        <Preview>
          <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', marginBottom: 8 }}>Cold Start Budget: &lt; 400ms to first frame</div>

          {/* Launch timeline bar */}
          <div style={{
            display: 'flex',
            borderRadius: 'var(--r-sm)',
            overflow: 'hidden',
            height: 44,
            marginBottom: 12,
          }}>
            {launchPhases.map((phase) => (
              <div key={phase.label} style={{
                flex: `${phase.ms} 0 0`,
                background: phase.color,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#fff',
                font: 'var(--text-caption2)',
                fontWeight: 600,
                minWidth: 0,
                overflow: 'hidden',
                whiteSpace: 'nowrap',
                padding: '0 2px',
                borderRight: '1px solid rgba(255,255,255,0.2)',
              }}>
                {phase.ms}ms
              </div>
            ))}
          </div>

          {/* Legend */}
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12, marginBottom: 16 }}>
            {launchPhases.map((phase) => (
              <div key={phase.label} style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                <div style={{ width: 10, height: 10, borderRadius: 2, background: phase.color }} />
                <span style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>{phase.label}</span>
              </div>
            ))}
          </div>

          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {launchGuidelines.map((g) => (
              <GlassCard key={g} style={{ flex: '1 1 180px' }}>
                <div style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>{g}</div>
              </GlassCard>
            ))}
          </div>
        </Preview>
      </Section>

      {/* Memory */}
      <Section title="Memory" description="Images are the biggest memory consumers. Always downsample to display size.">
        <Preview>
          {/* Image downsampling visual */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 24, flexWrap: 'wrap', marginBottom: 16 }}>
            <div style={{ textAlign: 'center' }}>
              <div style={{
                width: 120,
                height: 90,
                borderRadius: 'var(--r-sm)',
                background: 'linear-gradient(135deg, var(--blue), var(--purple))',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                marginBottom: 6,
              }}>
                <span style={{ color: '#fff', font: 'var(--text-caption2)', fontWeight: 600 }}>4000 x 3000</span>
              </div>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--red)', fontWeight: 600 }}>48 MB in memory</div>
            </div>

            <div style={{ font: 'var(--text-title2)', color: 'var(--label-tertiary)' }}>&rarr;</div>

            <div style={{ textAlign: 'center' }}>
              <div style={{
                width: 60,
                height: 45,
                borderRadius: 'var(--r-xs)',
                background: 'linear-gradient(135deg, var(--blue), var(--purple))',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                marginBottom: 6,
              }}>
                <span style={{ color: '#fff', font: 'var(--text-caption2)', fontWeight: 600 }}>200x150</span>
              </div>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--green)', fontWeight: 600 }}>120 KB</div>
            </div>
          </div>

          {/* Cache hierarchy */}
          <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', marginBottom: 8 }}>Cache Hierarchy</div>
          <div style={{ display: 'flex', gap: 8, alignItems: 'center', justifyContent: 'center', marginBottom: 8 }}>
            {['Memory', 'Disk', 'Network'].map((level, i) => (
              <div key={level} style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <GlassPanel variant="thin" style={{ padding: '8px 16px', textAlign: 'center' }}>
                  <div style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)' }}>{level}</div>
                  <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>
                    {level === 'Memory' ? 'Fastest' : level === 'Disk' ? 'Fast' : 'Slowest'}
                  </div>
                </GlassPanel>
                {i < 2 && <span style={{ color: 'var(--label-tertiary)', fontSize: 18 }}>&rarr;</span>}
              </div>
            ))}
          </div>
        </Preview>
        <SpecTable
          headers={['Formula', 'Example', 'Result']}
          rows={[
            ['width x height x 4 bytes', '4000 x 3000 x 4', '48,000,000 bytes (48 MB)'],
            ['width x height x 4 bytes', '200 x 150 x 4', '120,000 bytes (120 KB)'],
          ]}
        />
      </Section>

      {/* Battery */}
      <Section title="Battery" description="Design for energy efficiency. Every watt counts on mobile.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          {batteryGuidelines.map((g) => (
            <GlassCard key={g.title}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 6 }}>{g.title}</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>{g.desc}</div>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* Specs */}
      <Section title="Performance Specs" description="Key metrics and targets for a responsive, efficient app.">
        <SpecTable headers={specHeaders} rows={specRows} />
      </Section>
    </div>
  )
}
