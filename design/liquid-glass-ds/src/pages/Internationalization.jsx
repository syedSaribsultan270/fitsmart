import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

const dateFormats = [
  { locale: 'US', date: 'March 30, 2026', time: '10:30 AM' },
  { locale: 'UK', date: '30 March 2026', time: '10:30' },
  { locale: 'Japan', date: '2026\u5E743\u670830\u65E5', time: '10:30' },
  { locale: 'Germany', date: '30. M\u00E4rz 2026', time: '10:30' },
]

const relativeTimes = ['5 minutes ago', 'Yesterday', 'Last week']

const numberFormats = [
  { locale: 'US', number: '1,234.56', currency: '$1,234.56' },
  { locale: 'Germany', number: '1.234,56', currency: '1.234,56 \u20AC' },
  { locale: 'India', number: '1,23,456.78', currency: '\u20B91,23,456.78' },
  { locale: 'Arabic', number: '\u0661\u066C\u0662\u0663\u0664\u066B\u0665\u0666', currency: '' },
]

const pluralHeaders = ['Language', 'Zero', 'One', 'Two', 'Few', 'Many', 'Other']
const pluralRows = [
  ['English', '\u2014', '1 item', '\u2014', '\u2014', '\u2014', 'N items'],
  ['Arabic', '0 \u0639\u0646\u0627\u0635\u0631', '\u0639\u0646\u0635\u0631 \u0648\u0627\u062D\u062F', '\u0639\u0646\u0635\u0631\u0627\u0646', '3 \u0639\u0646\u0627\u0635\u0631', '11 \u0639\u0646\u0635\u0631\u0627\u064B', '100 \u0639\u0646\u0635\u0631'],
  ['Russian', '\u2014', '1 \u044D\u043B\u0435\u043C\u0435\u043D\u0442', '\u2014', '2 \u044D\u043B\u0435\u043C\u0435\u043D\u0442\u0430', '5 \u044D\u043B\u0435\u043C\u0435\u043D\u0442\u043E\u0432', '21 \u044D\u043B\u0435\u043C\u0435\u043D\u0442'],
]

const textExpansions = [
  { lang: 'English', label: 'Submit', pct: 100 },
  { lang: 'German', label: 'Einreichen', pct: 155 },
  { lang: 'Finnish', label: 'L\u00E4het\u00E4', pct: 120 },
  { lang: 'Thai', label: '\u0E2A\u0E48\u0E07', pct: 60 },
]

const guidelines = [
  { title: 'Use Auto Layout', desc: 'Let content determine container sizes. Never hardcode widths or heights for text containers.' },
  { title: 'Never Hardcode Widths', desc: 'Text length varies dramatically between languages. A 10-character English label may become 25 characters in German.' },
  { title: 'Test with Pseudolocalization', desc: 'Use tools that expand strings and add accented characters to catch layout issues before real translations arrive.' },
  { title: 'Support RTL + LTR', desc: 'Use leading/trailing constraints instead of left/right. Test your entire UI in both directions.' },
  { title: 'Use System Formatters', desc: 'Use DateFormatter, NumberFormatter, and MeasurementFormatter. Never manually format dates, numbers, or units.' },
]

export default function Internationalization() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Internationalization</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Designing for a global audience: RTL support, locale-aware formatting, pluralization rules, and text expansion.
      </p>

      {/* RTL Layout */}
      <Section title="RTL Layout" description="Every layout must work flawlessly in both LTR and RTL directions. Use leading/trailing instead of left/right.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: 16 }}>
          {/* LTR Mock */}
          <Preview>
            <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', marginBottom: 12, textAlign: 'center' }}>LTR (English)</div>
            <GlassPanel style={{ marginBottom: 12 }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <span style={{ fontSize: 18, color: 'var(--blue)' }}>&larr;</span>
                <span style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>Settings</span>
                <span style={{ fontSize: 14, color: 'var(--blue)', fontWeight: 500 }}>Edit</span>
              </div>
            </GlassPanel>
            {['Wi-Fi', 'Bluetooth', 'Notifications'].map((item) => (
              <GlassPanel key={item} style={{ marginBottom: 4, padding: '10px 16px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                  <span style={{ fontSize: 18 }}>{item === 'Wi-Fi' ? '\uD83D\uDCF6' : item === 'Bluetooth' ? '\uD83D\uDD35' : '\uD83D\uDD14'}</span>
                  <span style={{ font: 'var(--text-body)', color: 'var(--label)', flex: 1 }}>{item}</span>
                  <span style={{ color: 'var(--label-tertiary)', fontSize: 18 }}>&rsaquo;</span>
                </div>
              </GlassPanel>
            ))}
          </Preview>

          {/* RTL Mock */}
          <Preview>
            <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', marginBottom: 12, textAlign: 'center' }}>RTL (Arabic)</div>
            <GlassPanel style={{ marginBottom: 12 }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', direction: 'rtl' }}>
                <span style={{ fontSize: 18, color: 'var(--blue)' }}>&rarr;</span>
                <span style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>{'\u0627\u0644\u0625\u0639\u062F\u0627\u062F\u0627\u062A'}</span>
                <span style={{ fontSize: 14, color: 'var(--blue)', fontWeight: 500 }}>{'\u062A\u062D\u0631\u064A\u0631'}</span>
              </div>
            </GlassPanel>
            {[
              { icon: '\uD83D\uDCF6', label: '\u0634\u0628\u0643\u0629 \u0644\u0627\u0633\u0644\u0643\u064A\u0629' },
              { icon: '\uD83D\uDD35', label: '\u0628\u0644\u0648\u062A\u0648\u062B' },
              { icon: '\uD83D\uDD14', label: '\u0627\u0644\u0625\u0634\u0639\u0627\u0631\u0627\u062A' },
            ].map((item) => (
              <GlassPanel key={item.label} style={{ marginBottom: 4, padding: '10px 16px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12, direction: 'rtl' }}>
                  <span style={{ fontSize: 18 }}>{item.icon}</span>
                  <span style={{ font: 'var(--text-body)', color: 'var(--label)', flex: 1, textAlign: 'right' }}>{item.label}</span>
                  <span style={{ color: 'var(--label-tertiary)', fontSize: 18 }}>&lsaquo;</span>
                </div>
              </GlassPanel>
            ))}
          </Preview>
        </div>
        <GlassCard style={{ marginTop: 16 }}>
          <div style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>
            Always use <strong>leading</strong> and <strong>trailing</strong> constraints instead of left and right. The system automatically mirrors your layout for RTL languages like Arabic and Hebrew.
          </div>
        </GlassCard>
      </Section>

      {/* Date & Time Formatting */}
      <Section title="Date & Time Formatting" description="Dates and times must be formatted according to the user's locale. Never hardcode format strings.">
        <Preview>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12, marginBottom: 16 }}>
            {dateFormats.map((f) => (
              <GlassPanel key={f.locale} variant="thin" style={{ flex: '1 1 180px', textAlign: 'center', padding: '12px 16px' }}>
                <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', marginBottom: 8 }}>{f.locale}</div>
                <div style={{ font: 'var(--text-subhead)', color: 'var(--label)', marginBottom: 4 }}>{f.date}</div>
                <div style={{
                  display: 'inline-block',
                  padding: '2px 10px',
                  borderRadius: 'var(--r-pill)',
                  background: 'var(--fill)',
                  font: 'var(--text-caption1)',
                  color: 'var(--label-secondary)',
                }}>{f.time}</div>
              </GlassPanel>
            ))}
          </div>
          <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', marginBottom: 8 }}>Relative Time</div>
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {relativeTimes.map((t) => (
              <span key={t} style={{
                display: 'inline-block',
                padding: '4px 14px',
                borderRadius: 'var(--r-pill)',
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-sm))',
                WebkitBackdropFilter: 'blur(var(--blur-sm))',
                border: '0.5px solid var(--glass-border)',
                font: 'var(--text-footnote)',
                color: 'var(--label)',
              }}>{t}</span>
            ))}
          </div>
        </Preview>
        <SpecTable
          headers={['Locale', 'Date Format', 'Time Format']}
          rows={dateFormats.map((f) => [f.locale, f.date, f.time])}
        />
      </Section>

      {/* Number Formatting */}
      <Section title="Number Formatting" description="Number and currency formatting varies significantly across locales.">
        <Preview>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12 }}>
            {numberFormats.map((f) => (
              <div key={f.locale} style={{ flex: '1 1 160px', textAlign: 'center' }}>
                <div style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', marginBottom: 8 }}>{f.locale}</div>
                <span style={{
                  display: 'inline-block',
                  padding: '6px 16px',
                  borderRadius: 'var(--r-pill)',
                  background: 'var(--glass-bg)',
                  backdropFilter: 'blur(var(--blur-sm))',
                  WebkitBackdropFilter: 'blur(var(--blur-sm))',
                  border: '0.5px solid var(--glass-border)',
                  font: 'var(--text-body)',
                  fontWeight: 500,
                  color: 'var(--label)',
                  marginBottom: 6,
                }}>{f.number}</span>
                {f.currency && (
                  <div style={{ marginTop: 6 }}>
                    <span style={{
                      display: 'inline-block',
                      padding: '4px 12px',
                      borderRadius: 'var(--r-pill)',
                      background: 'var(--glass-bg-tinted)',
                      font: 'var(--text-footnote)',
                      fontWeight: 600,
                      color: 'var(--blue)',
                    }}>{f.currency}</span>
                  </div>
                )}
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* Pluralization */}
      <Section title="Pluralization" description="Different languages have different plural rules. Arabic has six plural forms; English has two.">
        <SpecTable headers={pluralHeaders} rows={pluralRows} />
      </Section>

      {/* Text Expansion */}
      <Section title="Text Expansion" description="The same label can vary dramatically in length across languages. Always design for the longest translation.">
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12, maxWidth: 400 }}>
            {textExpansions.map((t) => (
              <div key={t.lang} style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <div style={{ width: 60, font: 'var(--text-caption1)', color: 'var(--label-secondary)', flexShrink: 0 }}>{t.lang}</div>
                <GlassButton
                  variant="filled"
                  size="sm"
                  style={{ minWidth: `${t.pct}px`, pointerEvents: 'none' }}
                >
                  {t.label}
                </GlassButton>
                <span style={{
                  font: 'var(--text-caption1)',
                  fontFamily: 'var(--font-mono)',
                  color: 'var(--label-tertiary)',
                  flexShrink: 0,
                }}>{t.pct}%</span>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* Guidelines */}
      <Section title="Guidelines" description="Core principles for building globally-ready interfaces.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16 }}>
          {guidelines.map((g) => (
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
