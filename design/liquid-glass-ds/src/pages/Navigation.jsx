import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassSearch, GlassSegment } from '../components/Glass'

const tabBarItems = [
  { label: 'Home', icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0a1 1 0 01-1-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 01-1 1h-2z"/></svg> },
  { label: 'Search', icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg> },
  { label: 'Library', icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg> },
  { label: 'Favorites', icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"/></svg> },
  { label: 'Settings', icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 01-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg> },
]

const sidebarItems = [
  { section: 'Favorites', items: ['Home', 'Recents', 'Shared'] },
  { section: 'Library', items: ['Photos', 'Documents', 'Downloads'] },
]

export default function Navigation() {
  const [activeTab, setActiveTab] = useState(0)
  const [activeSidebarItem, setActiveSidebarItem] = useState('Home')
  const [segNavValue, setSegNavValue] = useState('week')

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Navigation</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Navigation patterns built with Liquid Glass materials. Tab bars, nav bars, sidebars, and toolbars.
      </p>

      <Section title="Tab Bar" description="iOS-style tab bar using a floating glass pill. Active tab is highlighted with the system blue color.">
        <Preview gradient style={{ padding: 0, position: 'relative', height: 320, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
          <div style={{ padding: 24, flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ font: 'var(--text-title2)', color: '#fff' }}>{tabBarItems[activeTab].label}</span>
          </div>
          <div style={{
            margin: '0 8px 8px',
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(48px) saturate(200%)',
            WebkitBackdropFilter: 'blur(48px) saturate(200%)',
            borderRadius: 'var(--r-2xl)',
            border: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
            padding: '8px 4px',
            display: 'flex',
            justifyContent: 'space-around',
          }}>
            {tabBarItems.map((item, i) => (
              <button
                key={i}
                onClick={() => setActiveTab(i)}
                style={{
                  display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
                  background: 'none', border: 'none', cursor: 'pointer', padding: '4px 12px',
                  color: activeTab === i ? 'var(--blue)' : 'var(--label-secondary)',
                  transition: 'color var(--dur) var(--ease)',
                }}
              >
                {item.icon}
                <span style={{ font: 'var(--text-caption2)', fontWeight: activeTab === i ? 600 : 400 }}>{item.label}</span>
              </button>
            ))}
          </div>
        </Preview>
      </Section>

      <Section title="Navigation Bar" description="Standard and large title variants. Standard centers the title at 44px; large title variant is 96px with a left-aligned prominent heading.">
        <Preview gradient style={{ padding: 0, overflow: 'hidden' }}>
          <div style={{
            height: 44, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 16px',
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(48px) saturate(200%)',
            WebkitBackdropFilter: 'blur(48px) saturate(200%)',
            borderBottom: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-specular)',
            position: 'relative',
          }}>
            <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', font: 'var(--text-body)', display: 'flex', alignItems: 'center', gap: 4, zIndex: 1 }}>
              <svg width="12" height="20" viewBox="0 0 12 20" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M10 2L2 10l8 8"/></svg>
              Back
            </button>
            <span style={{ font: 'var(--text-headline)', position: 'absolute', left: '50%', transform: 'translateX(-50%)' }}>Settings</span>
            <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', font: 'var(--text-body)', zIndex: 1 }}>Done</button>
          </div>
          <div style={{ height: 120, padding: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)' }}>Page content</span>
          </div>
        </Preview>

        <Preview gradient style={{ padding: 0, overflow: 'hidden' }}>
          <div style={{
            height: 96, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', padding: '0 16px 8px',
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(48px) saturate(200%)',
            WebkitBackdropFilter: 'blur(48px) saturate(200%)',
            borderBottom: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-specular)',
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 4 }}>
              <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', font: 'var(--text-body)' }}>Cancel</button>
              <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', font: 'var(--text-body)', fontWeight: 600 }}>Save</button>
            </div>
            <span style={{ font: 'var(--text-large-title)' }}>Settings</span>
          </div>
          <div style={{ height: 120, padding: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)' }}>Page content</span>
          </div>
        </Preview>
      </Section>

      <Section title="Sidebar" description="macOS/iPadOS sidebar with glass material, section headers, and selected state highlighting.">
        <Preview gradient style={{ padding: 12 }}>
          <div style={{
            width: 260,
            background: 'var(--glass-bg-sidebar)',
            backdropFilter: 'blur(48px) saturate(180%)',
            WebkitBackdropFilter: 'blur(48px) saturate(180%)',
            border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-xl)',
            boxShadow: 'var(--glass-shadow), var(--glass-specular)',
            padding: '12px 8px',
          }}>
            {sidebarItems.map((group) => (
              <div key={group.section} style={{ marginBottom: 16 }}>
                <div style={{
                  font: 'var(--text-footnote)', fontWeight: 600,
                  color: 'var(--label-secondary)', textTransform: 'uppercase', letterSpacing: 0.5,
                  padding: '4px 12px 6px',
                }}>{group.section}</div>
                {group.items.map((item) => (
                  <button
                    key={item}
                    onClick={() => setActiveSidebarItem(item)}
                    style={{
                      display: 'flex', alignItems: 'center', gap: 10, width: '100%',
                      padding: '8px 12px', borderRadius: 'var(--r-sm)', border: 'none', cursor: 'pointer',
                      font: 'var(--text-body)', textAlign: 'left',
                      background: activeSidebarItem === item ? 'var(--glass-bg-tinted)' : 'transparent',
                      color: activeSidebarItem === item ? 'var(--blue)' : 'var(--label)',
                      fontWeight: activeSidebarItem === item ? 600 : 400,
                      transition: 'all var(--dur-fast) var(--ease)',
                    }}
                  >
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                    </svg>
                    {item}
                  </button>
                ))}
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      <Section title="Toolbar" description="Bottom toolbar with icon actions on a glass surface.">
        <Preview gradient style={{ padding: 0, overflow: 'hidden' }}>
          <div style={{ height: 100, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)' }}>Content area</span>
          </div>
          <div style={{
            height: 48, display: 'flex', alignItems: 'center', justifyContent: 'space-around', padding: '0 24px',
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(48px) saturate(200%)',
            WebkitBackdropFilter: 'blur(48px) saturate(200%)',
            borderTop: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-specular)',
          }}>
            {[
              { name: 'share', color: 'var(--blue)', path: <><path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" y1="2" x2="12" y2="15"/></> },
              { name: 'bookmark', color: 'var(--blue)', path: <path d="M19 21l-7-5-7 5V5a2 2 0 012-2h10a2 2 0 012 2z"/> },
              { name: 'copy', color: 'var(--blue)', path: <><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></> },
              { name: 'trash', color: 'var(--red)', path: <><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></> },
            ].map((action) => (
              <button key={action.name} style={{
                background: 'none', border: 'none', cursor: 'pointer', padding: 8,
                color: action.color, display: 'flex', alignItems: 'center',
              }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">{action.path}</svg>
              </button>
            ))}
          </div>
        </Preview>
      </Section>

      <Section title="Search Bar" description="Search field embedded in a navigation bar context.">
        <Preview gradient style={{ padding: 0, overflow: 'hidden' }}>
          <div style={{
            padding: '10px 16px',
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(48px) saturate(200%)',
            WebkitBackdropFilter: 'blur(48px) saturate(200%)',
            borderBottom: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-specular)',
          }}>
            <GlassSearch placeholder="Search files and folders" />
          </div>
          <div style={{ height: 100, padding: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)' }}>Results appear here</span>
          </div>
        </Preview>
      </Section>

      <Section title="Specs" description="Standard bar heights for navigation elements.">
        <SpecTable
          headers={['Element', 'Height', 'Blur', 'Notes']}
          rows={[
            ['Tab Bar', '83px (49px + safe area)', '--blur-xl (72px)', 'Floating pill, 8px margin'],
            ['Nav Bar (Standard)', '44px', '--blur-xl (72px)', 'Centered title, back button'],
            ['Nav Bar (Large Title)', '96px', '--blur-xl (72px)', 'Left-aligned large title'],
            ['Sidebar', 'Full height', '--blur-xl (72px)', '260px width, 8px inner padding'],
            ['Toolbar', '48px', '--blur-xl (72px)', 'Icon buttons spaced evenly'],
            ['Search Bar', '60px (with padding)', '--blur-sm (16px)', 'Pill-shaped, 40px input height'],
          ]}
        />
      </Section>

      {/* ============================================================
          Search in Nav Bar
          ============================================================ */}
      <Section title="Search in Nav Bar" description="Navigation bar with an integrated search field. Shows collapsed state with title and expanded state with full search input.">
        {/* Collapsed state — title only */}
        <Preview gradient style={{ padding: 0, overflow: 'hidden' }}>
          <div style={{
            height: 56, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 12px',
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(48px) saturate(200%)',
            WebkitBackdropFilter: 'blur(48px) saturate(200%)',
            borderBottom: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-specular)',
          }}>
            {/* Back arrow */}
            <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center' }}>
              <svg width="12" height="20" viewBox="0 0 12 20" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M10 2L2 10l8 8"/></svg>
            </button>
            {/* Title in center */}
            <span style={{ font: 'var(--text-headline)', color: '#fff', position: 'absolute', left: '50%', transform: 'translateX(-50%)' }}>Search</span>
            {/* Filter icon */}
            <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center' }}>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="4" y1="6" x2="20" y2="6" /><line x1="8" y1="12" x2="16" y2="12" /><line x1="11" y1="18" x2="13" y2="18" />
              </svg>
            </button>
          </div>
          <div style={{ height: 80, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.4)' }}>Collapsed — tap to expand search</span>
          </div>
        </Preview>

        {/* Expanded state — full search field */}
        <Preview gradient style={{ padding: 0, overflow: 'hidden' }}>
          <div style={{
            height: 56, display: 'flex', alignItems: 'center', gap: 8, padding: '0 12px',
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(48px) saturate(200%)',
            WebkitBackdropFilter: 'blur(48px) saturate(200%)',
            borderBottom: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-specular)',
          }}>
            {/* Back arrow */}
            <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', flexShrink: 0 }}>
              <svg width="12" height="20" viewBox="0 0 12 20" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M10 2L2 10l8 8"/></svg>
            </button>
            {/* Search field taking most width */}
            <div style={{ flex: 1 }}>
              <GlassSearch placeholder="Search..." />
            </div>
            {/* Filter icon */}
            <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', flexShrink: 0 }}>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="4" y1="6" x2="20" y2="6" /><line x1="8" y1="12" x2="16" y2="12" /><line x1="11" y1="18" x2="13" y2="18" />
              </svg>
            </button>
          </div>
          <div style={{ height: 80, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.4)' }}>Expanded — search field active</span>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          Segmented in Nav Bar
          ============================================================ */}
      <Section title="Segmented in Nav Bar" description="Navigation bar with a GlassSegment control as the title area. Useful for switching between time views or content categories.">
        <Preview gradient style={{ padding: 0, overflow: 'hidden' }}>
          <div style={{
            height: 56, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 12px',
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(48px) saturate(200%)',
            WebkitBackdropFilter: 'blur(48px) saturate(200%)',
            borderBottom: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-specular)',
          }}>
            {/* Back button */}
            <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', gap: 4, flexShrink: 0 }}>
              <svg width="12" height="20" viewBox="0 0 12 20" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M10 2L2 10l8 8"/></svg>
              <span style={{ font: 'var(--text-body)' }}>Back</span>
            </button>
            {/* Segmented control in center */}
            <div style={{ transform: 'scale(0.9)', transformOrigin: 'center' }}>
              <GlassSegment
                items={[
                  { value: 'day', label: 'Day' },
                  { value: 'week', label: 'Week' },
                  { value: 'month', label: 'Month' },
                ]}
                value={segNavValue}
                onChange={setSegNavValue}
              />
            </div>
            {/* Add button */}
            <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', flexShrink: 0 }}>
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" />
              </svg>
            </button>
          </div>
          <div style={{ height: 120, padding: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)' }}>{segNavValue.charAt(0).toUpperCase() + segNavValue.slice(1)} view content</span>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          Custom Title View
          ============================================================ */}
      <Section title="Custom Title View" description="Navigation bar with a non-text title view. A small logo or icon replaces the text title, with an optional app name below.">
        <Preview gradient style={{ padding: 0, overflow: 'hidden' }}>
          <div style={{
            height: 56, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 12px',
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(48px) saturate(200%)',
            WebkitBackdropFilter: 'blur(48px) saturate(200%)',
            borderBottom: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-specular)',
            position: 'relative',
          }}>
            {/* Back button */}
            <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', gap: 4, zIndex: 1 }}>
              <svg width="12" height="20" viewBox="0 0 12 20" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M10 2L2 10l8 8"/></svg>
              <span style={{ font: 'var(--text-body)' }}>Back</span>
            </button>
            {/* Center: diamond logo + app name */}
            <div style={{ position: 'absolute', left: '50%', top: '50%', transform: 'translate(-50%, -50%)', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 1 }}>
              {/* Diamond icon */}
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <polygon points="12 2 22 12 12 22 2 12" />
              </svg>
              <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.6)', letterSpacing: 0.5 }}>GlassKit</span>
            </div>
            {/* Action button */}
            <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', zIndex: 1 }}>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="12" r="1" /><circle cx="19" cy="12" r="1" /><circle cx="5" cy="12" r="1" />
              </svg>
            </button>
          </div>
          <div style={{ height: 120, padding: 24, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)' }}>Page content</span>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          Transparent / Scroll-hide Nav
          ============================================================ */}
      <Section title="Transparent / Scroll-hide Nav" description="Navigation bar transitions from transparent at the top of the page to a glass background when scrolled. Title moves from the content area into the bar.">
        <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
          {/* At Top — transparent nav */}
          <div style={{ flex: 1, minWidth: 300 }}>
            <Preview gradient style={{ padding: 0, overflow: 'hidden' }}>
              <div style={{
                height: 56, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 16px',
                background: 'transparent',
                position: 'relative',
              }}>
                <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', padding: 4, display: 'flex', alignItems: 'center', gap: 4 }}>
                  <svg width="12" height="20" viewBox="0 0 12 20" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M10 2L2 10l8 8"/></svg>
                  <span style={{ font: 'var(--text-body)' }}>Back</span>
                </button>
                <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', font: 'var(--text-body)', padding: 4 }}>Edit</button>
              </div>
              {/* Large title in content area */}
              <div style={{ padding: '0 16px 24px' }}>
                <h2 style={{ font: 'var(--text-large-title)', color: '#fff', margin: 0 }}>Library</h2>
              </div>
              <div style={{ height: 80, padding: '0 16px', display: 'flex', alignItems: 'flex-start' }}>
                <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)' }}>Scrollable content below...</span>
              </div>
              {/* Label */}
              <div style={{ padding: '8px 16px', background: 'rgba(0,0,0,0.2)', textAlign: 'center' }}>
                <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)' }}>At Top</span>
              </div>
            </Preview>
          </div>

          {/* Scrolled — glass nav with title */}
          <div style={{ flex: 1, minWidth: 300 }}>
            <Preview gradient style={{ padding: 0, overflow: 'hidden' }}>
              <div style={{
                height: 56, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 16px',
                background: 'var(--glass-bg-thick)',
                backdropFilter: 'blur(48px) saturate(200%)',
                WebkitBackdropFilter: 'blur(48px) saturate(200%)',
                borderBottom: '0.5px solid var(--glass-border)',
                boxShadow: 'var(--glass-specular)',
                position: 'relative',
                transition: 'background var(--dur-slow) var(--ease)',
              }}>
                <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', padding: 4, display: 'flex', alignItems: 'center', gap: 4, zIndex: 1 }}>
                  <svg width="12" height="20" viewBox="0 0 12 20" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M10 2L2 10l8 8"/></svg>
                  <span style={{ font: 'var(--text-body)' }}>Back</span>
                </button>
                {/* Title has moved into the nav bar */}
                <span style={{ font: 'var(--text-headline)', color: '#fff', position: 'absolute', left: '50%', transform: 'translateX(-50%)' }}>Library</span>
                <button style={{ background: 'none', border: 'none', color: 'var(--blue)', cursor: 'pointer', font: 'var(--text-body)', padding: 4, zIndex: 1 }}>Edit</button>
              </div>
              {/* Content — scrolled up, title no longer visible in content */}
              <div style={{ padding: '16px', height: 104, display: 'flex', alignItems: 'flex-start' }}>
                <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)' }}>Scrollable content continues...</span>
              </div>
              {/* Label */}
              <div style={{ padding: '8px 16px', background: 'rgba(0,0,0,0.2)', textAlign: 'center' }}>
                <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)' }}>Scrolled</span>
              </div>
            </Preview>
          </div>
        </div>
      </Section>
    </div>
  )
}
