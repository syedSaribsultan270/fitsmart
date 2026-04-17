import { Link } from 'react-router-dom'
import { GlassCard } from '../components/Glass'

const foundations = [
  { title: 'Typography', desc: 'SF Pro type scale, dynamic type, and font stacks', path: '/typography' },
  { title: 'Colors', desc: 'System colors, semantic tokens, and dark mode', path: '/colors' },
  { title: 'Spacing & Layout', desc: 'Spacing scale, layout margins, alignment grids, radii, and shadows', path: '/spacing' },
  { title: 'Iconography', desc: 'SF Symbols, app icons, and rendering modes', path: '/iconography' },
]

const components = [
  { title: 'Buttons', desc: 'Glass, filled, tinted, and plain button styles', path: '/buttons' },
  { title: 'Inputs', desc: 'Text fields, search bars, toggles, and sliders', path: '/inputs' },
  { title: 'Navigation', desc: 'Tab bars, toolbars, and navigation bars', path: '/navigation' },
  { title: 'Feedback', desc: 'Alerts, progress indicators, and toasts', path: '/feedback' },
  { title: 'Content', desc: 'Lists, cards, and grouped containers', path: '/content' },
  { title: 'Menus', desc: 'Context menus, popovers, and action sheets', path: '/menus' },
]

const guidelines = [
  { title: 'Motion', desc: 'Transitions, spring curves, and animation tokens', path: '/motion' },
  { title: 'Visual Principles', desc: 'Depth, translucency, and material layering', path: '/visual-principles' },
  { title: 'Accessibility', desc: 'Contrast, dynamic type, and VoiceOver support', path: '/accessibility' },
  { title: 'Patterns', desc: 'Common UI patterns and layout recipes', path: '/patterns' },
]

const gridStyle = {
  display: 'grid',
  gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
  gap: 16,
}

function CardGrid({ items }) {
  return (
    <div style={gridStyle}>
      {items.map((item) => (
        <Link key={item.path} to={item.path} style={{ textDecoration: 'none', color: 'inherit' }}>
          <GlassCard>
            <h3>{item.title}</h3>
            <p>{item.desc}</p>
          </GlassCard>
        </Link>
      ))}
    </div>
  )
}

export default function Overview() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 12 }}>
        Apple Liquid Glass Design System
      </h1>
      <p style={{
        font: 'var(--text-body)',
        color: 'var(--label-secondary)',
        maxWidth: 640,
        marginBottom: 48,
        lineHeight: 1.5,
      }}>
        Liquid Glass is the unifying material language introduced in iOS 26 and macOS Tahoe.
        Translucent, light-reactive surfaces float above content, blending depth, blur, and
        specular highlights to create interfaces that feel dimensional and alive. This design
        system documents every foundation, component, and guideline needed to build with
        Liquid Glass.
      </p>

      <h2 style={{ font: 'var(--text-title2)', marginBottom: 16 }}>Foundations</h2>
      <div style={{ marginBottom: 40 }}>
        <CardGrid items={foundations} />
      </div>

      <h2 style={{ font: 'var(--text-title2)', marginBottom: 16 }}>Components</h2>
      <div style={{ marginBottom: 40 }}>
        <CardGrid items={components} />
      </div>

      <h2 style={{ font: 'var(--text-title2)', marginBottom: 16 }}>Guidelines</h2>
      <div style={{ marginBottom: 40 }}>
        <CardGrid items={guidelines} />
      </div>
    </div>
  )
}
