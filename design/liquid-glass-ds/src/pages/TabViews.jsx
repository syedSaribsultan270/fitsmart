import { useState, useRef, useEffect, useCallback } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassSegment, GlassButton } from '../components/Glass'

/* ── Shared glass style ── */
const glass = {
  background: 'var(--glass-bg)',
  backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
  WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
  border: '0.5px solid var(--glass-border)',
  borderRadius: 'var(--r-xl)',
  boxShadow: 'var(--glass-shadow), var(--glass-specular)',
}

/* ── Placeholder card grid ── */
function CardGrid({ count = 4, label }) {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 12 }}>
      {Array.from({ length: count }, (_, i) => (
        <div key={i} style={{
          background: 'var(--glass-inner)',
          borderRadius: 'var(--r-md)',
          border: '0.5px solid var(--glass-border)',
          padding: 16,
          minHeight: 72,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}>
          <span style={{ font: 'var(--text-footnote)', color: 'var(--label-tertiary)' }}>
            {label} {i + 1}
          </span>
        </div>
      ))}
    </div>
  )
}

export default function TabViews() {
  /* ── State for each demo ── */
  const [segTab, setSegTab] = useState('foryou')
  const [scrollTab, setScrollTab] = useState('All')
  const [page, setPage] = useState(0)
  const [sidebarItem, setSidebarItem] = useState('Inbox')

  /* ── Scrollable tab underline position ── */
  const scrollTabsRef = useRef(null)
  const activeTabRef = useRef(null)
  const [underline, setUnderline] = useState({ left: 0, width: 0 })

  const measureUnderline = useCallback(() => {
    const container = scrollTabsRef.current
    const active = activeTabRef.current
    if (!container || !active) return
    const cRect = container.getBoundingClientRect()
    const aRect = active.getBoundingClientRect()
    setUnderline({ left: aRect.left - cRect.left, width: aRect.width })
  }, [])

  useEffect(() => {
    requestAnimationFrame(measureUnderline)
  }, [scrollTab, measureUnderline])

  const scrollTabs = ['All', 'Music', 'Podcasts', 'Audiobooks', 'Radio', 'Videos', 'Playlists']

  const segTabContent = {
    foryou: { label: 'For You', count: 4 },
    trending: { label: 'Trending', count: 6 },
    following: { label: 'Following', count: 2 },
  }

  const sidebarItems = ['Inbox', 'Drafts', 'Sent', 'Archive', 'Trash']
  const sidebarDetail = {
    Inbox: { title: 'Inbox', desc: 'You have 3 new messages waiting to be read.' },
    Drafts: { title: 'Drafts', desc: '2 unsent drafts saved for later.' },
    Sent: { title: 'Sent', desc: 'All sent messages from the past 30 days.' },
    Archive: { title: 'Archive', desc: 'Messages you have archived for reference.' },
    Trash: { title: 'Trash', desc: 'Deleted messages are removed after 30 days.' },
  }

  const pageContent = [
    { title: 'Welcome', desc: 'Get started with Liquid Glass in just a few steps.' },
    { title: 'Customize', desc: 'Personalize your experience with themes and preferences.' },
    { title: 'Ready', desc: 'You are all set. Start building beautiful interfaces.' },
  ]

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Tab Views</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Segmented controls, scrollable tabs, page-style navigation, and sidebar-detail layouts using Liquid Glass materials.
      </p>

      {/* ── 1. Top Tabs (Segmented) ── */}
      <Section title="Top Tabs (Segmented)" description="Glass segmented control for switching between a fixed set of categories.">
        <Preview gradient style={{ minHeight: 280 }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            <div style={{ display: 'flex', justifyContent: 'center' }}>
              <GlassSegment
                items={[
                  { value: 'foryou', label: 'For You' },
                  { value: 'trending', label: 'Trending' },
                  { value: 'following', label: 'Following' },
                ]}
                value={segTab}
                onChange={setSegTab}
              />
            </div>
            <CardGrid count={segTabContent[segTab].count} label={segTabContent[segTab].label} />
          </div>
        </Preview>
      </Section>

      {/* ── 2. Top Tabs (Scrollable) ── */}
      <Section title="Top Tabs (Scrollable)" description="Horizontally scrollable text tabs with a sliding underline indicator. Ideal for 5+ categories.">
        <Preview gradient style={{ minHeight: 260 }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            {/* Tab bar */}
            <div
              ref={scrollTabsRef}
              style={{
                display: 'flex',
                gap: 0,
                overflowX: 'auto',
                scrollSnapType: 'x mandatory',
                position: 'relative',
                borderBottom: '0.5px solid var(--separator)',
                paddingBottom: 0,
                msOverflowStyle: 'none',
                scrollbarWidth: 'none',
              }}
            >
              {/* Sliding underline */}
              <div style={{
                position: 'absolute',
                bottom: 0,
                height: 2.5,
                borderRadius: 2,
                background: 'var(--blue)',
                transition: 'left 300ms cubic-bezier(0.34,1.56,0.64,1), width 300ms cubic-bezier(0.34,1.56,0.64,1)',
                left: underline.left,
                width: underline.width,
              }} />

              {scrollTabs.map((tab) => (
                <button
                  key={tab}
                  ref={tab === scrollTab ? activeTabRef : null}
                  onClick={() => setScrollTab(tab)}
                  style={{
                    font: 'var(--text-subhead)',
                    fontWeight: tab === scrollTab ? 600 : 400,
                    color: tab === scrollTab ? 'var(--blue)' : 'var(--label-secondary)',
                    background: 'transparent',
                    border: 'none',
                    padding: '10px 16px',
                    cursor: 'pointer',
                    whiteSpace: 'nowrap',
                    scrollSnapAlign: 'start',
                    transition: 'color 200ms cubic-bezier(0.42,0,0.58,1)',
                    flexShrink: 0,
                  }}
                >
                  {tab}
                </button>
              ))}
            </div>

            {/* Content */}
            <div style={{
              ...glass,
              padding: 20,
              minHeight: 100,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}>
              <span style={{ font: 'var(--text-body)', color: 'var(--label-secondary)' }}>
                Showing results for "{scrollTab}"
              </span>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── 3. Page-style Tabs ── */}
      <Section title="Page-style Tabs" description="Swipeable pages with dot indicator and navigation arrows. Commonly used for onboarding and galleries.">
        <Preview gradient style={{ minHeight: 280 }}>
          <div style={{ position: 'relative' }}>
            {/* Page content */}
            <div style={{
              ...glass,
              padding: 32,
              minHeight: 180,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              textAlign: 'center',
              transition: 'all 300ms cubic-bezier(0.34,1.56,0.64,1)',
            }}>
              <div style={{ font: 'var(--text-title2)', marginBottom: 8 }}>
                {pageContent[page].title}
              </div>
              <div style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', maxWidth: 320 }}>
                {pageContent[page].desc}
              </div>
            </div>

            {/* Left arrow */}
            <button
              onClick={() => setPage((p) => Math.max(0, p - 1))}
              disabled={page === 0}
              style={{
                position: 'absolute',
                left: -6,
                top: '50%',
                transform: 'translateY(-50%)',
                width: 36,
                height: 36,
                borderRadius: '50%',
                background: 'var(--glass-inner)',
                backdropFilter: 'blur(var(--blur-sm))',
                WebkitBackdropFilter: 'blur(var(--blur-sm))',
                border: '0.5px solid var(--glass-border)',
                color: 'var(--label)',
                cursor: page === 0 ? 'not-allowed' : 'pointer',
                opacity: page === 0 ? 0.3 : 1,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: 18,
                transition: 'opacity 200ms cubic-bezier(0.42,0,0.58,1)',
              }}
            >
              &#8249;
            </button>

            {/* Right arrow */}
            <button
              onClick={() => setPage((p) => Math.min(pageContent.length - 1, p + 1))}
              disabled={page === pageContent.length - 1}
              style={{
                position: 'absolute',
                right: -6,
                top: '50%',
                transform: 'translateY(-50%)',
                width: 36,
                height: 36,
                borderRadius: '50%',
                background: 'var(--glass-inner)',
                backdropFilter: 'blur(var(--blur-sm))',
                WebkitBackdropFilter: 'blur(var(--blur-sm))',
                border: '0.5px solid var(--glass-border)',
                color: 'var(--label)',
                cursor: page === pageContent.length - 1 ? 'not-allowed' : 'pointer',
                opacity: page === pageContent.length - 1 ? 0.3 : 1,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: 18,
                transition: 'opacity 200ms cubic-bezier(0.42,0,0.58,1)',
              }}
            >
              &#8250;
            </button>

            {/* Dot indicator */}
            <div style={{ display: 'flex', justifyContent: 'center', gap: 8, marginTop: 16 }}>
              {pageContent.map((_, i) => (
                <button
                  key={i}
                  onClick={() => setPage(i)}
                  style={{
                    width: i === page ? 10 : 7,
                    height: i === page ? 10 : 7,
                    borderRadius: '50%',
                    background: i === page ? 'var(--blue)' : 'rgba(255,255,255,0.35)',
                    border: 'none',
                    padding: 0,
                    cursor: 'pointer',
                    transition: 'all 300ms cubic-bezier(0.34,1.56,0.64,1)',
                  }}
                />
              ))}
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── 4. Sidebar + Detail ── */}
      <Section title="Sidebar + Detail" description="iPad / Mac-style master-detail layout with a glass sidebar and content area.">
        <Preview gradient style={{ minHeight: 320 }}>
          <div style={{ display: 'flex', gap: 1, borderRadius: 'var(--r-xl)', overflow: 'hidden', minHeight: 280 }}>
            {/* Sidebar */}
            <div style={{
              width: 200,
              flexShrink: 0,
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              borderRight: '0.5px solid var(--glass-border)',
              boxShadow: 'var(--glass-specular)',
              padding: '12px 8px',
              display: 'flex',
              flexDirection: 'column',
              gap: 2,
            }}>
              {sidebarItems.map((item) => (
                <button
                  key={item}
                  onClick={() => setSidebarItem(item)}
                  style={{
                    font: 'var(--text-body)',
                    fontWeight: item === sidebarItem ? 600 : 400,
                    color: item === sidebarItem ? 'var(--label)' : 'var(--label-secondary)',
                    background: item === sidebarItem ? 'var(--glass-bg-tinted)' : 'transparent',
                    backdropFilter: item === sidebarItem ? 'blur(var(--blur-sm))' : 'none',
                    WebkitBackdropFilter: item === sidebarItem ? 'blur(var(--blur-sm))' : 'none',
                    border: item === sidebarItem ? '0.5px solid rgba(0,122,255,0.15)' : '0.5px solid transparent',
                    borderRadius: 'var(--r-md)',
                    padding: '10px 14px',
                    textAlign: 'left',
                    cursor: 'pointer',
                    transition: 'all 200ms cubic-bezier(0.42,0,0.58,1)',
                    width: '100%',
                  }}
                >
                  {item}
                </button>
              ))}
            </div>

            {/* Detail */}
            <div style={{
              flex: 1,
              background: 'var(--glass-bg-thin)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              padding: 24,
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'center',
            }}>
              <div style={{ font: 'var(--text-title2)', marginBottom: 8 }}>
                {sidebarDetail[sidebarItem].title}
              </div>
              <div style={{ font: 'var(--text-body)', color: 'var(--label-secondary)' }}>
                {sidebarDetail[sidebarItem].desc}
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── 5. Tab View Specs ── */}
      <Section title="Tab View Specs">
        <SpecTable
          headers={['Variant', 'Height', 'Behavior', 'Best For']}
          rows={[
            ['Segmented', '44px', 'Tap to switch', '2-5 fixed categories'],
            ['Scrollable', '44px', 'Swipe/tap, scroll overflow', '5+ categories'],
            ['Page-style', 'Full area', 'Swipe pages, dot indicator', 'Onboarding, galleries'],
            ['Sidebar+Detail', 'Full height', 'Select from list', 'iPad/Mac master-detail'],
          ]}
        />
      </Section>
    </div>
  )
}
