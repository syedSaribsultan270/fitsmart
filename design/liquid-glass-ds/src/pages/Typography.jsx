import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'

const fontFamilies = [
  { name: 'SF Pro (System)', token: '--font-system', family: 'var(--font-system)' },
  { name: 'SF Pro Rounded', token: '--font-rounded', family: 'var(--font-rounded)' },
  { name: 'New York (Serif)', token: '--font-serif', family: 'var(--font-serif)' },
  { name: 'SF Mono', token: '--font-mono', family: 'var(--font-mono)' },
]

const typeScale = [
  { name: 'Large Title', token: '--text-large-title', size: '34px', weight: '700', leading: '41px' },
  { name: 'Title 1', token: '--text-title1', size: '28px', weight: '700', leading: '34px' },
  { name: 'Title 2', token: '--text-title2', size: '22px', weight: '700', leading: '28px' },
  { name: 'Title 3', token: '--text-title3', size: '20px', weight: '600', leading: '25px' },
  { name: 'Headline', token: '--text-headline', size: '17px', weight: '600', leading: '22px' },
  { name: 'Body', token: '--text-body', size: '17px', weight: '400', leading: '22px' },
  { name: 'Callout', token: '--text-callout', size: '16px', weight: '400', leading: '21px' },
  { name: 'Subhead', token: '--text-subhead', size: '15px', weight: '400', leading: '20px' },
  { name: 'Footnote', token: '--text-footnote', size: '13px', weight: '400', leading: '18px' },
  { name: 'Caption 1', token: '--text-caption1', size: '12px', weight: '400', leading: '16px' },
  { name: 'Caption 2', token: '--text-caption2', size: '11px', weight: '400', leading: '13px' },
]

const fontWeights = [
  { name: 'Ultralight', value: 100 },
  { name: 'Thin', value: 200 },
  { name: 'Light', value: 300 },
  { name: 'Regular', value: 400 },
  { name: 'Medium', value: 500 },
  { name: 'Semibold', value: 600 },
  { name: 'Bold', value: 700 },
  { name: 'Heavy', value: 800 },
  { name: 'Black', value: 900 },
]

const dynamicTypeHeaders = ['Style', 'xSmall', 'Small', 'Medium', 'Large', 'xLarge', 'xxLarge', 'xxxLarge']
const dynamicTypeRows = [
  ['Large Title', '31/38', '32/39', '33/40', '34/41', '36/43', '38/46', '40/48'],
  ['Title 1', '25/31', '26/32', '27/33', '28/34', '30/37', '32/39', '34/41'],
  ['Title 2', '19/24', '20/25', '21/26', '22/28', '24/30', '26/32', '28/34'],
  ['Title 3', '17/22', '18/23', '19/24', '20/25', '22/28', '24/30', '26/32'],
  ['Headline', '14/19', '15/20', '16/21', '17/22', '19/24', '21/26', '23/29'],
  ['Body', '14/19', '15/20', '16/21', '17/22', '19/24', '21/26', '23/29'],
  ['Callout', '13/18', '14/19', '15/20', '16/21', '18/23', '20/25', '22/28'],
  ['Subhead', '12/16', '13/18', '14/19', '15/20', '17/22', '19/24', '21/28'],
  ['Footnote', '12/16', '12/16', '12/16', '13/18', '15/20', '17/22', '19/24'],
  ['Caption 1', '11/13', '11/13', '11/13', '12/16', '14/19', '16/21', '18/23'],
  ['Caption 2', '11/13', '11/13', '11/13', '11/13', '13/18', '15/20', '17/22'],
]

const platformHeaders = ['Style', 'iOS Size', 'iOS Weight', 'macOS Size', 'macOS Weight']
const platformRows = [
  ['Large Title', '34px', 'Regular (Bold*)', '26px', 'Regular (Bold*)'],
  ['Title 1', '28px', 'Regular (Bold*)', '22px', 'Regular (Bold*)'],
  ['Title 2', '22px', 'Regular (Bold*)', '17px', 'Regular (Bold*)'],
  ['Title 3', '20px', 'Regular (Semi*)', '15px', 'Regular (Semi*)'],
  ['Headline', '17px', 'Semibold', '13px', 'Bold (Heavy*)'],
  ['Body', '17px', 'Regular (Semi*)', '13px', 'Regular (Semi*)'],
  ['Callout', '16px', 'Regular (Semi*)', '12px', 'Regular (Semi*)'],
  ['Subhead', '15px', 'Regular (Semi*)', '11px', 'Regular (Semi*)'],
  ['Footnote', '13px', 'Regular (Semi*)', '10px', 'Regular (Semi*)'],
  ['Caption 1', '12px', 'Regular (Semi*)', '10px', 'Regular (Medium*)'],
  ['Caption 2', '11px', 'Regular (Semi*)', '10px', 'Medium (Semi*)'],
]

export default function Typography() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Typography</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        The Apple type system built on SF Pro, with dynamic sizing across all platforms.
      </p>

      <Section title="Font Families" description="Four font stacks available across the system">
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 32 }}>
            {fontFamilies.map((f) => (
              <div key={f.token}>
                <div style={{ font: 'var(--text-footnote)', color: 'var(--label-tertiary)', marginBottom: 4 }}>
                  {f.name} <span style={{ fontFamily: 'var(--font-mono)', fontSize: 12 }}>{f.token}</span>
                </div>
                <div style={{ fontFamily: f.family, fontSize: 24, lineHeight: 1.3 }}>
                  The quick brown fox jumps over the lazy dog
                </div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      <Section title="Type Scale" description="iOS Large (default) text styles">
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            {typeScale.map((t) => (
              <div key={t.token} style={{ display: 'flex', alignItems: 'baseline', gap: 16, flexWrap: 'wrap' }}>
                <div style={{ minWidth: 100, font: 'var(--text-footnote)', color: 'var(--label-tertiary)', flexShrink: 0 }}>
                  {t.name}
                </div>
                <div style={{ font: `var(${t.token})`, flex: 1, minWidth: 200 }}>
                  The quick brown fox
                </div>
                <div style={{ fontFamily: 'var(--font-mono)', fontSize: 12, color: 'var(--label-tertiary)', flexShrink: 0 }}>
                  {t.size} / {t.weight} / {t.leading}
                </div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      <Section title="Font Weights" description="Nine weights from Ultralight to Black">
        <Preview>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {fontWeights.map((w) => (
              <div key={w.value} style={{ display: 'flex', alignItems: 'baseline', gap: 16 }}>
                <div style={{ minWidth: 100, font: 'var(--text-footnote)', color: 'var(--label-tertiary)' }}>
                  {w.name} ({w.value})
                </div>
                <div style={{ fontSize: 20, fontWeight: w.value, fontFamily: 'var(--font-system)' }}>
                  San Francisco
                </div>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      <Section title="Dynamic Type" description="Size/Leading values across all 7 standard content size categories (iOS)">
        <SpecTable headers={dynamicTypeHeaders} rows={dynamicTypeRows} />
      </Section>

      <Section title="Platform Comparison" description="iOS vs macOS text style defaults. (*) = emphasized weight.">
        <SpecTable headers={platformHeaders} rows={platformRows} />
      </Section>
    </div>
  )
}
