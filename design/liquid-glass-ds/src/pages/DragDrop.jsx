import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

export default function DragDrop() {
  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Drag & Drop</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Drag and drop interactions with Liquid Glass materials. Visual feedback for drag sources, drop targets, reordering, and cross-app transfers.
      </p>

      {/* ── Drag Source ── */}
      <Section title="Drag Source" description="The dragged item lifts with increased shadow, slight rotation, and reduced opacity. A ghost outline marks its origin.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24 }}>
            {/* Dragging card */}
            <div style={{
              opacity: 0.6,
              transform: 'scale(1.03) rotate(2deg)',
              boxShadow: 'var(--glass-shadow-lg)',
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-lg)',
              padding: '16px 24px',
              width: 220,
              textAlign: 'center',
              transition: 'all var(--dur) var(--ease-spring)',
            }}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)', marginBottom: 4 }}>Photo.jpg</div>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)' }}>2.4 MB</div>
            </div>

            {/* Ghost outline */}
            <div style={{
              width: 220,
              height: 64,
              border: '2px dashed var(--glass-border)',
              borderRadius: 'var(--r-lg)',
              opacity: 0.4,
            }} />

            <span style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.5)', textAlign: 'center' }}>
              Drag preview follows the pointer with slight rotation
            </span>
          </div>
        </Preview>
      </Section>

      {/* ── Drop Target ── */}
      <Section title="Drop Target" description="Drop zones highlight with color and scale when a dragged item hovers over them, indicating valid targets.">
        <Preview>
          <div style={{ display: 'flex', gap: 24, justifyContent: 'center', alignItems: 'flex-start', flexWrap: 'wrap', position: 'relative' }}>
            {/* Folder A — normal */}
            <div style={{
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow), var(--glass-specular)',
              padding: 24,
              width: 180,
              textAlign: 'center',
            }}>
              <div style={{ fontSize: 36, marginBottom: 8 }}>&#128193;</div>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>Folder A</div>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-tertiary)', marginTop: 4 }}>3 items</div>
            </div>

            {/* Floating drag preview between folders */}
            <div style={{
              position: 'absolute',
              top: '50%',
              left: '50%',
              transform: 'translate(-50%, -50%) rotate(2deg)',
              opacity: 0.85,
              zIndex: 10,
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-md)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-md)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-md)',
              boxShadow: 'var(--glass-shadow-lg)',
              padding: '10px 16px',
            }}>
              <span style={{ font: 'var(--text-subhead)', color: 'var(--label)' }}>Photo.jpg</span>
            </div>

            {/* Folder B — hover state (valid drop target) */}
            <div style={{
              background: 'var(--glass-bg-tinted)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '2px solid var(--blue)',
              borderRadius: 'var(--r-xl)',
              boxShadow: 'var(--glass-shadow-lg), 0 0 0 4px rgba(0,122,255,0.1)',
              padding: 24,
              width: 180,
              textAlign: 'center',
              transform: 'scale(1.02)',
              transition: 'all var(--dur) var(--ease-spring)',
            }}>
              <div style={{ fontSize: 36, marginBottom: 8 }}>&#128194;</div>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>Folder B</div>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--blue)', marginTop: 4 }}>Drop here</div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Spring-loaded Folders ── */}
      <Section title="Spring-loaded Folders" description="Hovering over a folder while dragging opens it after a short delay, allowing navigation into nested content.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 32, justifyContent: 'center', flexWrap: 'wrap' }}>
            {/* Hovering state */}
            <div style={{ textAlign: 'center' }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 1, display: 'block', marginBottom: 12 }}>Hovering</span>
              <div style={{
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-xl)',
                boxShadow: 'var(--glass-shadow), var(--glass-specular)',
                padding: 24,
                width: 160,
                position: 'relative',
              }}>
                {/* Progress ring */}
                <div style={{ position: 'relative', width: 56, height: 56, margin: '0 auto 12px' }}>
                  <svg width="56" height="56" viewBox="0 0 56 56" style={{ position: 'absolute', top: 0, left: 0, transform: 'rotate(-90deg)' }}>
                    <circle cx="28" cy="28" r="24" fill="none" stroke="rgba(255,255,255,0.1)" strokeWidth="3" />
                    <circle cx="28" cy="28" r="24" fill="none" stroke="var(--blue)" strokeWidth="3"
                      strokeDasharray={`${2 * Math.PI * 24 * 0.65} ${2 * Math.PI * 24}`}
                      strokeLinecap="round"
                    />
                  </svg>
                  <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 28 }}>
                    &#128193;
                  </div>
                </div>
                <div style={{ font: 'var(--text-subhead)', color: 'var(--label)', textAlign: 'center' }}>Projects</div>
                <div style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', textAlign: 'center', marginTop: 2 }}>Hold to open...</div>
              </div>
            </div>

            {/* Opened state */}
            <div style={{ textAlign: 'center' }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: 1, display: 'block', marginBottom: 12 }}>Opened</span>
              <div style={{
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-xl)',
                boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
                padding: 16,
                width: 200,
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12 }}>
                  <span style={{ fontSize: 22 }}>&#128194;</span>
                  <span style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>Projects</span>
                </div>
                {['Design System', 'App Icons', 'Prototypes'].map((item, i, arr) => (
                  <div key={item} style={{
                    padding: '10px 12px',
                    background: 'var(--glass-inner)',
                    borderRadius: 'var(--r-sm)',
                    marginBottom: i < arr.length - 1 ? 6 : 0,
                    font: 'var(--text-subhead)',
                    color: 'var(--label)',
                    display: 'flex',
                    alignItems: 'center',
                    gap: 8,
                  }}>
                    <span style={{ fontSize: 14 }}>&#128196;</span>
                    {item}
                  </div>
                ))}
              </div>
            </div>
          </div>
          <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.5)', textAlign: 'center', marginTop: 16 }}>
            Hover over a folder while dragging to open it after a short delay
          </p>
        </Preview>
      </Section>

      {/* ── Reorder ── */}
      <Section title="Reorder" description="Items in a list can be reordered by dragging. The dragged item elevates while surrounding items animate to make space.">
        <Preview gradient>
          <div style={{ maxWidth: 360, margin: '0 auto', display: 'flex', flexDirection: 'column', gap: 0 }}>
            {['Reminders', 'Calendar'].map((item) => (
              <div key={item} style={{
                padding: '14px 20px',
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-md)',
                marginBottom: 4,
                display: 'flex',
                alignItems: 'center',
                gap: 12,
              }}>
                <span style={{ color: 'var(--label-tertiary)', fontSize: 14 }}>&#9776;</span>
                <span style={{ font: 'var(--text-body)', color: 'var(--label)' }}>{item}</span>
              </div>
            ))}

            {/* Gap where item 3 was */}
            <div style={{
              height: 50,
              borderRadius: 'var(--r-md)',
              border: '2px dashed rgba(255,255,255,0.1)',
              marginBottom: 4,
              transition: 'height 300ms var(--ease-spring)',
            }} />

            {/* Dragged item (item 3) — floating */}
            <div style={{
              padding: '14px 20px',
              background: 'var(--glass-bg)',
              backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
              border: '0.5px solid var(--glass-border)',
              borderRadius: 'var(--r-md)',
              boxShadow: 'var(--glass-shadow-lg)',
              transform: 'scale(1.03)',
              marginBottom: 4,
              display: 'flex',
              alignItems: 'center',
              gap: 12,
              position: 'relative',
              zIndex: 5,
            }}>
              <span style={{ color: 'var(--label-tertiary)', fontSize: 14 }}>&#9776;</span>
              <span style={{ font: 'var(--text-body)', color: 'var(--label)', fontWeight: 600 }}>Notes</span>
              <span style={{ font: 'var(--text-caption1)', color: 'var(--blue)', marginLeft: 'auto' }}>Dragging</span>
            </div>

            {['Photos', 'Messages'].map((item) => (
              <div key={item} style={{
                padding: '14px 20px',
                background: 'var(--glass-bg)',
                backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
                border: '0.5px solid var(--glass-border)',
                borderRadius: 'var(--r-md)',
                marginBottom: 4,
                display: 'flex',
                alignItems: 'center',
                gap: 12,
              }}>
                <span style={{ color: 'var(--label-tertiary)', fontSize: 14 }}>&#9776;</span>
                <span style={{ font: 'var(--text-body)', color: 'var(--label)' }}>{item}</span>
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ── Cross-app Drag ── */}
      <Section title="Cross-app Drag" description="Content can be dragged between apps in Split View or on iPad. The drag preview shows a thumbnail with a badge count for multi-item drags.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 2, borderRadius: 'var(--r-xl)', overflow: 'hidden', maxWidth: 600, margin: '0 auto', position: 'relative' }}>
            {/* App A */}
            <div style={{
              flex: 1,
              background: 'rgba(255,255,255,0.04)',
              padding: 20,
              minHeight: 220,
            }}>
              <div style={{
                font: 'var(--text-caption1)',
                color: 'rgba(255,255,255,0.4)',
                textTransform: 'uppercase',
                letterSpacing: 1,
                marginBottom: 12,
              }}>Photos</div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
                {['#3B82F6', '#8B5CF6', '#EC4899', '#F59E0B'].map((color, i) => (
                  <div key={i} style={{
                    aspectRatio: '1',
                    borderRadius: 'var(--r-sm)',
                    background: color,
                    opacity: i === 0 ? 0.3 : 0.7,
                    border: i === 0 ? '2px dashed rgba(255,255,255,0.2)' : 'none',
                  }} />
                ))}
              </div>
            </div>

            {/* Divider */}
            <div style={{ width: 2, background: 'rgba(255,255,255,0.1)' }} />

            {/* App B */}
            <div style={{
              flex: 1,
              background: 'rgba(255,255,255,0.04)',
              padding: 20,
              minHeight: 220,
            }}>
              <div style={{
                font: 'var(--text-caption1)',
                color: 'rgba(255,255,255,0.4)',
                textTransform: 'uppercase',
                letterSpacing: 1,
                marginBottom: 12,
              }}>Notes</div>
              <div style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.5)', lineHeight: 1.6 }}>
                Meeting notes from today...<br />
                <span style={{ display: 'inline-block', width: '80%', height: 1, background: 'rgba(255,255,255,0.1)', margin: '8px 0' }} /><br />
                Drop images here to attach
              </div>
            </div>

            {/* Drag preview floating between apps */}
            <div style={{
              position: 'absolute',
              top: '40%',
              left: '50%',
              transform: 'translate(-50%, -50%) rotate(3deg)',
              zIndex: 10,
            }}>
              <div style={{
                width: 64,
                height: 64,
                borderRadius: 'var(--r-md)',
                background: '#3B82F6',
                boxShadow: 'var(--glass-shadow-lg)',
                position: 'relative',
              }}>
                {/* Badge */}
                <div style={{
                  position: 'absolute',
                  top: -6,
                  right: -6,
                  width: 22,
                  height: 22,
                  borderRadius: '50%',
                  background: 'var(--red)',
                  color: 'white',
                  font: 'var(--text-caption2)',
                  fontWeight: 700,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  boxShadow: '0 2px 6px rgba(0,0,0,0.3)',
                }}>+1</div>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Guidelines ── */}
      <Section title="Drag & Drop Guidelines" description="Follow these principles to create intuitive drag-and-drop interactions.">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: 16 }}>
          {[
            'Show a preview of the dragged content',
            'Highlight valid drop targets with color and scale',
            'Animate items moving to make space',
            'Support spring-loaded folders for navigation',
            'Show a badge for multi-item drags',
            'Provide a ghost outline at the drag origin',
          ].map((guideline) => (
            <GlassCard key={guideline} style={{ padding: 20 }}>
              <p style={{ font: 'var(--text-subhead)', color: 'var(--label)', margin: 0 }}>{guideline}</p>
            </GlassCard>
          ))}
        </div>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs">
        <SpecTable
          headers={['Property', 'Value', 'Notes']}
          rows={[
            ['Drag preview opacity', '0.8', 'Slightly transparent to show it is being moved'],
            ['Preview rotation', '2-3deg', 'Slight tilt for physicality'],
            ['Drag shadow', '--glass-shadow-lg', 'Elevated shadow during drag'],
            ['Drop target scale', '1.02', 'Subtle grow on valid hover'],
            ['Spring-load delay', '800ms', 'Time before folder opens'],
            ['Reorder gap animation', '300ms spring', 'Items shift with spring easing'],
          ]}
        />
      </Section>
    </div>
  )
}
