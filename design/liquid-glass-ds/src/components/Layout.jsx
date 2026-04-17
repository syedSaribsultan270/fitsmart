import { useState, useEffect, useCallback } from 'react'
import { NavLink, useLocation } from 'react-router-dom'
import './Layout.css'

const navSections = [
  {
    label: 'Foundations',
    links: [
      { to: '/typography', label: 'Typography' },
      { to: '/colors', label: 'Colors' },
      { to: '/spacing', label: 'Spacing & Layout' },
      { to: '/layout-system', label: 'Layout System' },
      { to: '/elevation', label: 'Elevation & Depth' },
      { to: '/iconography', label: 'Iconography' },
    ],
  },
  {
    label: 'Components',
    links: [
      { to: '/buttons', label: 'Buttons' },
      { to: '/inputs', label: 'Inputs' },
      { to: '/pickers', label: 'Pickers' },
      { to: '/text-views', label: 'Text Views' },
      { to: '/navigation', label: 'Navigation' },
      { to: '/feedback', label: 'Feedback' },
      { to: '/content', label: 'Content' },
      { to: '/menus', label: 'Menus' },
      { to: '/tab-views', label: 'Tab Views' },
      { to: '/popovers', label: 'Popovers' },
      { to: '/token-fields', label: 'Token Fields' },
      { to: '/combo-box', label: 'Combo Box' },
      { to: '/rating', label: 'Rating' },
      { to: '/image-views', label: 'Image Views' },
      { to: '/tooltips', label: 'Tooltips' },
      { to: '/breadcrumbs', label: 'Breadcrumbs' },
    ],
  },
  {
    label: 'Patterns',
    links: [
      { to: '/patterns', label: 'Overview' },
      { to: '/empty-states', label: 'Empty States' },
      { to: '/loading-states', label: 'Loading States' },
      { to: '/error-handling', label: 'Error Handling' },
      { to: '/drag-drop', label: 'Drag & Drop' },
      { to: '/undo-redo', label: 'Undo & Redo' },
      { to: '/keyboard-shortcuts', label: 'Keyboard Shortcuts' },
      { to: '/haptic-patterns', label: 'Haptic Patterns' },
      { to: '/auth', label: 'Authentication' },
      { to: '/forms', label: 'Forms & Validation' },
      { to: '/data', label: 'Data Management' },
      { to: '/onboarding', label: 'Onboarding' },
    ],
  },
  {
    label: 'Platform',
    links: [
      { to: '/widgets', label: 'Widgets' },
      { to: '/live-activities', label: 'Live Activities' },
      { to: '/notifications', label: 'Notifications' },
      { to: '/media', label: 'Media Playback' },
      { to: '/maps', label: 'Maps & Location' },
      { to: '/platforms', label: 'Platform Specifics' },
    ],
  },
  {
    label: 'Guidelines',
    links: [
      { to: '/motion', label: 'Motion' },
      { to: '/visual-principles', label: 'Visual Principles' },
      { to: '/accessibility', label: 'Accessibility' },
      { to: '/i18n', label: 'Internationalization' },
      { to: '/privacy', label: 'Privacy' },
      { to: '/performance', label: 'Performance' },
      { to: '/writing', label: 'Writing & Tone' },
    ],
  },
]

function getInitialTheme() {
  const stored = localStorage.getItem('theme')
  if (stored) return stored
  if (window.matchMedia('(prefers-color-scheme: dark)').matches) return 'dark'
  return 'light'
}

export default function Layout({ children }) {
  const [theme, setTheme] = useState(getInitialTheme)
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const location = useLocation()

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme)
    localStorage.setItem('theme', theme)
  }, [theme])

  // Close sidebar on route change (mobile)
  useEffect(() => {
    setSidebarOpen(false)
  }, [location.pathname])

  const toggleTheme = useCallback(() => {
    setTheme(prev => (prev === 'dark' ? 'light' : 'dark'))
  }, [])

  return (
    <div className="layout">
      {/* Mobile hamburger */}
      <button
        className="layout__hamburger"
        onClick={() => setSidebarOpen(o => !o)}
        aria-label={sidebarOpen ? 'Close navigation' : 'Open navigation'}
      >
        <span className={`layout__hamburger-icon ${sidebarOpen ? 'open' : ''}`} />
      </button>

      {/* Overlay for mobile */}
      {sidebarOpen && (
        <div className="layout__overlay" onClick={() => setSidebarOpen(false)} />
      )}

      {/* Sidebar */}
      <aside className={`layout__sidebar ${sidebarOpen ? 'layout__sidebar--open' : ''}`}>
        <div className="layout__sidebar-header">
          <NavLink to="/" className="layout__logo">
            Apple Liquid Glass
          </NavLink>
          <button
            className="layout__theme-toggle"
            onClick={toggleTheme}
            aria-label={`Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`}
          >
            {theme === 'dark' ? (
              <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                <path d="M8 1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-1 0v-1A.5.5 0 0 1 8 1zm0 11a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-1 0v-1A.5.5 0 0 1 8 12zm7-4a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1 0-1h1A.5.5 0 0 1 15 8zM4 8a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1 0-1h1A.5.5 0 0 1 4 8zm8.95-3.54a.5.5 0 0 1 0 .71l-.71.7a.5.5 0 0 1-.7-.7l.7-.71a.5.5 0 0 1 .71 0zM4.46 11.54a.5.5 0 0 1 0 .71l-.7.7a.5.5 0 0 1-.71-.7l.7-.71a.5.5 0 0 1 .71 0zm8.08 0a.5.5 0 0 1 .71 0l.7.7a.5.5 0 0 1-.7.71l-.71-.7a.5.5 0 0 1 0-.71zM4.46 4.46a.5.5 0 0 1 .71 0l-.7-.71a.5.5 0 0 1-.71.7l.7.71zM3.05 4.46a.5.5 0 0 1 0-.71l.7-.7a.5.5 0 0 1 .71.7l-.7.71a.5.5 0 0 1-.71 0zM8 4.5a3.5 3.5 0 1 0 0 7 3.5 3.5 0 0 0 0-7z"/>
              </svg>
            ) : (
              <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                <path d="M6.2 1a.5.5 0 0 0-.55.45A5.5 5.5 0 0 0 12.55 9.35a.5.5 0 0 0-.1-.95A6.5 6.5 0 0 1 6.65.55.5.5 0 0 0 6.2 1z"/>
              </svg>
            )}
          </button>
        </div>

        <nav className="layout__nav">
          <div className="layout__nav-section">
            <NavLink
              to="/"
              end
              className={({ isActive }) =>
                `layout__nav-link ${isActive ? 'layout__nav-link--active' : ''}`
              }
            >
              Overview
            </NavLink>
          </div>

          {navSections.map(section => (
            <div key={section.label} className="layout__nav-section">
              <div className="layout__nav-label">{section.label}</div>
              {section.links.map(link => (
                <NavLink
                  key={link.to}
                  to={link.to}
                  className={({ isActive }) =>
                    `layout__nav-link ${isActive ? 'layout__nav-link--active' : ''}`
                  }
                >
                  {link.label}
                </NavLink>
              ))}
            </div>
          ))}
        </nav>
      </aside>

      {/* Main content */}
      <main className="layout__main">
        <div className="layout__content">
          {children}
        </div>
      </main>
    </div>
  )
}
