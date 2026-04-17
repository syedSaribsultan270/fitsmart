import { useState, useEffect } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton, GlassAlert, GlassProgress } from '../components/Glass'

/* File type icons */
function FileIcon({ type, size = 32 }) {
  const colors = { doc: 'var(--blue)', pdf: 'var(--red)', image: 'var(--green)', folder: 'var(--orange)' }
  const color = colors[type] || 'var(--gray)'
  return (
    <svg width={size} height={size} viewBox="0 0 32 32" fill="none">
      {type === 'folder' ? (
        <>
          <path d="M4 8a2 2 0 012-2h6l2 3h12a2 2 0 012 2v13a2 2 0 01-2 2H6a2 2 0 01-2-2V8z" fill={color} opacity="0.2" />
          <path d="M4 8a2 2 0 012-2h6l2 3h12a2 2 0 012 2v13a2 2 0 01-2 2H6a2 2 0 01-2-2V8z" stroke={color} strokeWidth="1.5" />
        </>
      ) : (
        <>
          <path d="M8 4h10l8 8v14a2 2 0 01-2 2H8a2 2 0 01-2-2V6a2 2 0 012-2z" fill={color} opacity="0.15" />
          <path d="M8 4h10l8 8v14a2 2 0 01-2 2H8a2 2 0 01-2-2V6a2 2 0 012-2z" stroke={color} strokeWidth="1.5" />
          <path d="M18 4v6a2 2 0 002 2h6" stroke={color} strokeWidth="1.5" />
          {type === 'doc' && (
            <g stroke={color} strokeWidth="1.2" strokeLinecap="round">
              <line x1="10" y1="16" x2="22" y2="16" />
              <line x1="10" y1="20" x2="18" y2="20" />
              <line x1="10" y1="24" x2="20" y2="24" />
            </g>
          )}
          {type === 'pdf' && (
            <text x="16" y="23" textAnchor="middle" fill={color} fontSize="8" fontWeight="700" fontFamily="var(--font-system)">PDF</text>
          )}
          {type === 'image' && (
            <g>
              <circle cx="13" cy="18" r="2" fill={color} opacity="0.5" />
              <path d="M10 24l4-5 3 3 3-4 4 6H10z" fill={color} opacity="0.4" />
            </g>
          )}
        </>
      )}
    </svg>
  )
}

/* Cloud sync icons */
function CloudIcon({ status, size = 20 }) {
  const statusColors = {
    synced: 'var(--green)',
    uploading: 'var(--blue)',
    downloading: 'var(--blue)',
    failed: 'var(--red)',
    offline: 'var(--gray)',
  }
  const color = statusColors[status] || 'var(--gray)'

  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M18 10h-1.26A8 8 0 109 20h9a5 5 0 000-10z" />
      {status === 'synced' && <path d="M9 15l2 2 4-4" />}
      {status === 'uploading' && <><line x1="12" y1="18" x2="12" y2="13" /><polyline points="9,15 12,12 15,15" /></>}
      {status === 'downloading' && <><line x1="12" y1="13" x2="12" y2="18" /><polyline points="9,16 12,19 15,16" /></>}
      {status === 'failed' && <><line x1="12" y1="13" x2="12" y2="16" /><circle cx="12" cy="18" r="0.5" fill={color} /></>}
      {status === 'offline' && <line x1="4" y1="4" x2="20" y2="20" />}
    </svg>
  )
}

/* App icon for share sheet */
function AppIcon({ label, color, icon }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6, cursor: 'pointer' }}>
      <div style={{
        width: 48, height: 48, borderRadius: 'var(--r-sm)',
        background: color,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: '#fff', fontSize: 20,
        boxShadow: '0 2px 8px rgba(0,0,0,0.15)',
        transition: 'transform var(--dur-fast) var(--ease-spring)',
      }}
        onMouseEnter={e => e.currentTarget.style.transform = 'scale(1.08)'}
        onMouseLeave={e => e.currentTarget.style.transform = 'scale(1)'}
      >
        {icon}
      </div>
      <span style={{ font: 'var(--text-caption2)', color: 'var(--label-secondary)' }}>{label}</span>
    </div>
  )
}

export default function DataManagement() {
  const [selectedFile, setSelectedFile] = useState(0)
  const [viewMode, setViewMode] = useState('grid')
  const [shareSheetOpen, setShareSheetOpen] = useState(false)
  const [syncProgress, setSyncProgress] = useState(72)

  /* Animate sync progress */
  useEffect(() => {
    const interval = setInterval(() => {
      setSyncProgress(p => {
        if (p >= 95) return 72
        return p + Math.random() * 3
      })
    }, 800)
    return () => clearInterval(interval)
  }, [])

  const files = [
    { name: 'Project Brief.docx', type: 'doc', date: 'Mar 28, 2026', size: '2.4 MB' },
    { name: 'Invoice.pdf', type: 'pdf', date: 'Mar 27, 2026', size: '1.1 MB' },
    { name: 'Photo.jpg', type: 'image', date: 'Mar 25, 2026', size: '4.8 MB' },
    { name: 'Design Assets', type: 'folder', date: 'Mar 24, 2026', size: '-- ' },
  ]

  const syncFiles = [
    { name: 'Presentation.key', status: 'synced', label: 'Synced' },
    { name: 'Budget.numbers', status: 'uploading', label: 'Uploading...' },
    { name: 'Photos.zip', status: 'downloading', label: 'Downloading...' },
    { name: 'Backup.dmg', status: 'failed', label: 'Sync failed' },
    { name: 'Draft.pages', status: 'offline', label: 'Offline' },
  ]

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Data Management</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        File browsing, iCloud sync, conflict resolution, share sheets, and clipboard patterns for Apple platforms.
      </p>

      {/* ── File Browser ── */}
      <Section title="File Browser" description="A glass-styled document browser with grid view, selection states, and toolbar.">
        <Preview>
          <div style={{ maxWidth: 600, margin: '0 auto' }}>
            {/* Toolbar */}
            <GlassPanel style={{
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              padding: '10px 16px', marginBottom: 12, borderRadius: 'var(--r-md)',
            }}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>Documents</div>
              <div style={{ display: 'flex', gap: 8 }}>
                <GlassButton
                  variant={viewMode === 'grid' ? 'filled' : 'glass'}
                  size="sm" icon
                  onClick={() => setViewMode('grid')}
                >
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                    <rect x="1" y="1" width="6" height="6" rx="1" />
                    <rect x="9" y="1" width="6" height="6" rx="1" />
                    <rect x="1" y="9" width="6" height="6" rx="1" />
                    <rect x="9" y="9" width="6" height="6" rx="1" />
                  </svg>
                </GlassButton>
                <GlassButton
                  variant={viewMode === 'list' ? 'filled' : 'glass'}
                  size="sm" icon
                  onClick={() => setViewMode('list')}
                >
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                    <rect x="1" y="2" width="14" height="2.5" rx="0.5" />
                    <rect x="1" y="6.75" width="14" height="2.5" rx="0.5" />
                    <rect x="1" y="11.5" width="14" height="2.5" rx="0.5" />
                  </svg>
                </GlassButton>
              </div>
            </GlassPanel>

            {/* File grid */}
            {viewMode === 'grid' ? (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(130px, 1fr))', gap: 12 }}>
                {files.map((file, i) => (
                  <GlassCard
                    key={i}
                    onClick={() => setSelectedFile(i)}
                    style={{
                      padding: 16, textAlign: 'center', cursor: 'pointer',
                      border: selectedFile === i ? '1.5px solid var(--blue)' : '0.5px solid var(--glass-border)',
                      borderRadius: 'var(--r-md)',
                      boxShadow: selectedFile === i ? '0 0 0 3px rgba(0,122,255,0.15)' : undefined,
                      transition: 'all var(--dur) var(--ease)',
                      minHeight: 120,
                      display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8,
                    }}
                  >
                    <FileIcon type={file.type} size={36} />
                    <div style={{ font: 'var(--text-caption1)', color: 'var(--label)', fontWeight: 500, wordBreak: 'break-word' }}>
                      {file.name}
                    </div>
                    <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>
                      {file.date}
                    </div>
                  </GlassCard>
                ))}
              </div>
            ) : (
              <GlassPanel variant="thick" padding={false}>
                {files.map((file, i) => (
                  <div
                    key={i}
                    onClick={() => setSelectedFile(i)}
                    style={{
                      display: 'flex', alignItems: 'center', gap: 12,
                      padding: '10px 16px', cursor: 'pointer',
                      background: selectedFile === i ? 'var(--glass-bg-tinted)' : 'transparent',
                      borderBottom: i < files.length - 1 ? '0.5px solid var(--separator)' : 'none',
                      transition: 'background var(--dur-fast) var(--ease)',
                    }}
                  >
                    <FileIcon type={file.type} size={28} />
                    <div style={{ flex: 1 }}>
                      <div style={{ font: 'var(--text-subhead)', color: 'var(--label)', fontWeight: 500 }}>{file.name}</div>
                      <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>{file.date} {file.size !== '-- ' && `  ${file.size}`}</div>
                    </div>
                  </div>
                ))}
              </GlassPanel>
            )}
          </div>
        </Preview>
      </Section>

      {/* ── iCloud Sync ── */}
      <Section title="iCloud Sync" description="Sync status indicators and progress for iCloud-connected files.">
        <Preview>
          <div style={{ maxWidth: 440, margin: '0 auto' }}>
            <GlassPanel variant="thick" padding={false}>
              {syncFiles.map((file, i) => (
                <div key={i} style={{
                  display: 'flex', alignItems: 'center', gap: 12,
                  padding: '12px 16px',
                  borderBottom: i < syncFiles.length - 1 ? '0.5px solid var(--separator)' : 'none',
                }}>
                  <CloudIcon status={file.status} size={20} />
                  <div style={{ flex: 1 }}>
                    <div style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>{file.name}</div>
                  </div>
                  <div style={{
                    font: 'var(--text-caption1)',
                    color: file.status === 'synced' ? 'var(--green)' :
                           file.status === 'failed' ? 'var(--red)' :
                           file.status === 'offline' ? 'var(--gray)' : 'var(--blue)',
                    fontWeight: 500,
                  }}>
                    {file.label}
                  </div>
                </div>
              ))}
            </GlassPanel>

            {/* Overall progress */}
            <div style={{ marginTop: 16 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                <span style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)' }}>Overall Sync Progress</span>
                <span style={{ font: 'var(--text-footnote)', color: 'var(--label-secondary)', fontFamily: 'var(--font-mono)' }}>
                  {Math.round(syncProgress)}%
                </span>
              </div>
              <GlassProgress value={syncProgress} />
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Conflict Resolution ── */}
      <Section title="Conflict Resolution" description="Handle file conflicts when multiple devices edit the same file simultaneously.">
        <Preview gradient>
          <div style={{ maxWidth: 480, margin: '0 auto' }}>
            <GlassPanel variant="thick" style={{ textAlign: 'center' }}>
              {/* Alert header */}
              <div style={{
                width: 40, height: 40, borderRadius: 'var(--r-sm)',
                background: 'rgba(255, 149, 0, 0.15)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                margin: '0 auto 12px',
              }}>
                <svg width="24" height="24" viewBox="0 0 24 24" fill="var(--orange)">
                  <path d="M12 2L1 21h22L12 2zm0 4l7.53 13H4.47L12 6zm-1 5v4h2v-4h-2zm0 6v2h2v-2h-2z" />
                </svg>
              </div>
              <div style={{ font: 'var(--text-title3)', color: 'var(--label)', marginBottom: 4 }}>
                Conflict Detected
              </div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)', marginBottom: 20 }}>
                "Project Brief.docx" was modified on two devices
              </div>

              {/* Two versions side by side */}
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, marginBottom: 20 }}>
                <GlassPanel style={{ textAlign: 'center', padding: 16 }}>
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="var(--blue)" style={{ marginBottom: 8 }}>
                    <rect x="5" y="2" width="14" height="20" rx="2" stroke="var(--blue)" strokeWidth="1.5" fill="none" />
                    <circle cx="12" cy="18" r="1" fill="var(--blue)" />
                  </svg>
                  <div style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label)', marginBottom: 4 }}>
                    This Device
                  </div>
                  <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>
                    Modified Mar 28, 10:32 AM
                  </div>
                  <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', marginTop: 2 }}>
                    2,847 words
                  </div>
                </GlassPanel>

                <GlassPanel style={{ textAlign: 'center', padding: 16 }}>
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--cyan)" strokeWidth="1.5" style={{ marginBottom: 8 }}>
                    <path d="M18 10h-1.26A8 8 0 109 20h9a5 5 0 000-10z" />
                  </svg>
                  <div style={{ font: 'var(--text-footnote)', fontWeight: 600, color: 'var(--label)', marginBottom: 4 }}>
                    iCloud
                  </div>
                  <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)' }}>
                    Modified Mar 28, 11:15 AM
                  </div>
                  <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', marginTop: 2 }}>
                    2,903 words
                  </div>
                </GlassPanel>
              </div>

              {/* Action buttons */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                <GlassButton variant="filled" style={{ width: '100%' }}>Keep This Device</GlassButton>
                <GlassButton variant="glass" style={{ width: '100%' }}>Keep iCloud</GlassButton>
                <GlassButton variant="plain" style={{ width: '100%', color: 'var(--blue)' }}>Keep Both</GlassButton>
              </div>
            </GlassPanel>
          </div>
        </Preview>
      </Section>

      {/* ── Share Sheet ── */}
      <Section title="Share Sheet" description="The system share sheet with app targets and action items in a glass bottom sheet.">
        <Preview gradient>
          <div style={{ maxWidth: 400, margin: '0 auto' }}>
            {/* Trigger */}
            {!shareSheetOpen && (
              <div style={{ textAlign: 'center' }}>
                <GlassButton variant="glass" onClick={() => setShareSheetOpen(true)}>
                  <svg width="16" height="16" viewBox="0 0 20 20" fill="currentColor" style={{ marginRight: 6 }}>
                    <path d="M15 8a3 3 0 10-2.977-2.63l-4.94 2.47a3 3 0 100 4.319l4.94 2.47a3 3 0 10.895-1.789l-4.94-2.47a3.027 3.027 0 000-.74l4.94-2.47C13.456 7.68 14.19 8 15 8z" />
                  </svg>
                  Share
                </GlassButton>
              </div>
            )}

            {/* Share sheet */}
            {shareSheetOpen && (
              <GlassPanel variant="thick" style={{
                animation: 'slideUp 0.4s cubic-bezier(0.34, 1.56, 0.64, 1)',
                borderRadius: 'var(--r-xl)',
              }}>
                <style>{`@keyframes slideUp { from { transform: translateY(40px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }`}</style>

                {/* App icons row */}
                <div style={{ display: 'flex', justifyContent: 'space-around', paddingBottom: 16, marginBottom: 12, borderBottom: '0.5px solid var(--separator)' }}>
                  <AppIcon label="Messages" color="#34C759" icon={
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="#fff"><path d="M2 5a2 2 0 012-2h7a2 2 0 012 2v4a2 2 0 01-2 2H9l-3 3v-3H4a2 2 0 01-2-2V5z" /><path d="M15 7v2a4 4 0 01-4 4H9.828l-1.766 1.767c.28.149.599.233.938.233h2l3 3v-3h2a2 2 0 002-2V9a2 2 0 00-2-2h-1z" /></svg>
                  } />
                  <AppIcon label="Mail" color="#007AFF" icon={
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="#fff"><path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z" /><path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z" /></svg>
                  } />
                  <AppIcon label="Notes" color="#FFCC00" icon={
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="#fff"><path fillRule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clipRule="evenodd" /></svg>
                  } />
                  <AppIcon label="AirDrop" color="linear-gradient(135deg, #007AFF, #5856D6)" icon={
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="#fff"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93z" /></svg>
                  } />
                </div>

                {/* Action list */}
                {[
                  { icon: '📋', label: 'Copy' },
                  { icon: '📁', label: 'Save to Files' },
                  { icon: '🖨️', label: 'Print' },
                  { icon: '🖼️', label: 'Add to Photos' },
                ].map((action, i) => (
                  <div key={i} style={{
                    display: 'flex', alignItems: 'center', gap: 12,
                    padding: '10px 4px', cursor: 'pointer',
                    borderBottom: i < 3 ? '0.5px solid var(--separator)' : 'none',
                    transition: 'background var(--dur-fast) var(--ease)',
                    borderRadius: 'var(--r-xs)',
                  }}
                    onMouseEnter={e => e.currentTarget.style.background = 'var(--fill-tertiary)'}
                    onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
                  >
                    <span style={{ fontSize: 18 }}>{action.icon}</span>
                    <span style={{ font: 'var(--text-body)', color: 'var(--label)' }}>{action.label}</span>
                  </div>
                ))}

                <div style={{ marginTop: 12, textAlign: 'center' }}>
                  <GlassButton variant="plain" onClick={() => setShareSheetOpen(false)} style={{ color: 'var(--blue)' }}>
                    Cancel
                  </GlassButton>
                </div>
              </GlassPanel>
            )}
          </div>
        </Preview>
      </Section>

      {/* ── Clipboard ── */}
      <Section title="Clipboard" description="Paste permission dialog for clipboard access between apps.">
        <Preview>
          <div style={{ maxWidth: 340, margin: '0 auto' }}>
            <GlassAlert
              title="Allow Paste from Safari?"
              message={`"App" would like to paste from Safari. This will allow the app to see what you last copied.`}
              actions={[
                { label: "Don't Allow", onClick: () => {} },
                { label: 'Allow Paste', primary: true, onClick: () => {} },
              ]}
            />
          </div>
        </Preview>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs">
        <SpecTable
          headers={['Element', 'Property', 'Value']}
          rows={[
            ['File card', 'Min size', '130 x 120 pt'],
            ['File card', 'Border radius', 'var(--r-md) (16px)'],
            ['Sync icon', 'Size', '16 x 16 / 20 x 20 pt'],
            ['Share sheet icon', 'Size', '48 x 48 pt'],
            ['Share sheet icon', 'Border radius', 'var(--r-sm) (12px)'],
            ['Bottom sheet', 'Border radius', 'var(--r-xl) (28px)'],
            ['Conflict card', 'Border radius', 'var(--r-lg) (22px)'],
          ]}
        />
      </Section>
    </div>
  )
}
