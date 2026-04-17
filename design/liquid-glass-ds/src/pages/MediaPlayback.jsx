import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

export default function MediaPlayback() {
  const [playing, setPlaying] = useState(false)
  const [selectedDevice, setSelectedDevice] = useState('iPhone Speakers')

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Media Playback</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Now Playing controls, mini player, Picture in Picture, and AirPlay routing with Liquid Glass materials.
      </p>

      {/* ── Now Playing ── */}
      <Section title="Now Playing" description="Full media player interface with album art, transport controls, and a progress bar.">
        <Preview gradient style={{ padding: 32 }}>
          <div style={{
            maxWidth: 360, margin: '0 auto',
            background: 'var(--glass-bg)',
            backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
            WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
            border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-xl)',
            boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
            padding: 24,
          }}>
            {/* Album art */}
            <div style={{
              width: 120, height: 120, borderRadius: 'var(--r-lg)', margin: '0 auto 20px',
              background: 'linear-gradient(135deg, #1a1a2e, #16213e, #0f3460)',
              boxShadow: '0 8px 32px rgba(0,0,0,0.3)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <span style={{ fontSize: 40, opacity: 0.6 }}>&#9835;</span>
            </div>

            {/* Track info */}
            <div style={{ textAlign: 'center', marginBottom: 20 }}>
              <div style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>Glass Houses</div>
              <div style={{ font: 'var(--text-subhead)', color: 'var(--label-secondary)' }}>Billy Joel</div>
            </div>

            {/* Progress bar */}
            <div style={{ marginBottom: 6 }}>
              <div style={{ height: 4, background: 'var(--fill)', borderRadius: 2 }}>
                <div style={{ width: '38%', height: '100%', background: 'var(--label)', borderRadius: 2, position: 'relative' }}>
                  <div style={{
                    position: 'absolute', right: -5, top: -3,
                    width: 10, height: 10, borderRadius: '50%',
                    background: 'var(--label)',
                    boxShadow: '0 1px 4px rgba(0,0,0,0.2)',
                  }} />
                </div>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6 }}>
                <span style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', fontVariantNumeric: 'tabular-nums' }}>2:11</span>
                <span style={{ font: 'var(--text-caption2)', color: 'var(--label-tertiary)', fontVariantNumeric: 'tabular-nums' }}>-3:35</span>
              </div>
            </div>

            {/* Transport controls */}
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 20, marginTop: 16 }}>
              <button style={{
                width: 44, height: 44, borderRadius: '50%', border: 'none', cursor: 'pointer',
                background: 'var(--glass-inner)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <span style={{ color: 'var(--label)', fontSize: 16 }}>&#9198;</span>
              </button>
              <button onClick={() => setPlaying(v => !v)} style={{
                width: 56, height: 56, borderRadius: '50%', border: 'none', cursor: 'pointer',
                background: 'var(--label)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                boxShadow: '0 2px 12px rgba(0,0,0,0.15)',
              }}>
                <span style={{ color: 'var(--bg-primary)', fontSize: 22, marginLeft: playing ? 0 : 2 }}>
                  {playing ? '&#9646;&#9646;' : '&#9654;'}
                </span>
              </button>
              <button style={{
                width: 44, height: 44, borderRadius: '50%', border: 'none', cursor: 'pointer',
                background: 'var(--glass-inner)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <span style={{ color: 'var(--label)', fontSize: 16 }}>&#9197;</span>
              </button>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Mini Player ── */}
      <Section title="Mini Player" description="Collapsed playback bar that persists at the bottom of the app. Tap to expand the full Now Playing view.">
        <Preview gradient style={{ padding: 0, position: 'relative', height: 300 }}>
          <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', height: 230 }}>
            <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.3)' }}>App content</span>
          </div>
          <div style={{
            position: 'absolute', bottom: 12, left: 12, right: 12,
            height: 64,
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
            WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
            border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-pill)',
            boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
            display: 'flex', alignItems: 'center', gap: 12,
            padding: '0 8px 0 8px',
            cursor: 'pointer',
          }}>
            {/* Small album art */}
            <div style={{
              width: 48, height: 48, borderRadius: 'var(--r-md)', flexShrink: 0,
              background: 'linear-gradient(135deg, #1a1a2e, #16213e)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <span style={{ fontSize: 20, opacity: 0.6 }}>&#9835;</span>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ font: 'var(--text-subhead)', fontWeight: 600, color: 'var(--label)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>Glass Houses</div>
              <div style={{ font: 'var(--text-caption1)', color: 'var(--label-secondary)' }}>Billy Joel</div>
            </div>
            <button onClick={() => setPlaying(v => !v)} style={{
              width: 36, height: 36, borderRadius: '50%', border: 'none', cursor: 'pointer',
              background: 'transparent',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <span style={{ color: 'var(--label)', fontSize: 20 }}>
                {playing ? '&#9646;&#9646;' : '&#9654;'}
              </span>
            </button>
          </div>
        </Preview>
      </Section>

      {/* ── Picture in Picture ── */}
      <Section title="Picture in Picture" description="Floating video window with glass border that persists above other app content. Supports resize and corner anchoring.">
        <Preview gradient style={{ padding: 0, position: 'relative', height: 320 }}>
          {/* Mock app content */}
          <div style={{ padding: 24 }}>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              {[1, 2, 3, 4].map((i) => (
                <div key={i} style={{
                  height: 24, borderRadius: 'var(--r-xs)',
                  background: 'rgba(255,255,255,0.06)',
                  width: `${90 - i * 10}%`,
                }} />
              ))}
            </div>
          </div>

          {/* PiP window */}
          <div style={{
            position: 'absolute', bottom: 20, right: 20,
            width: 180, height: 120,
            borderRadius: 'var(--r-lg)',
            overflow: 'hidden',
            border: '0.5px solid var(--glass-border)',
            boxShadow: 'var(--glass-shadow-lg)',
            background: 'linear-gradient(135deg, #1a1a2e, #0f3460)',
          }}>
            {/* Video content mock */}
            <div style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <span style={{ fontSize: 32, opacity: 0.4 }}>&#9654;</span>
            </div>
            {/* Controls overlay */}
            <div style={{
              position: 'absolute', top: 6, right: 6,
              display: 'flex', gap: 4,
            }}>
              <div style={{
                width: 24, height: 24, borderRadius: '50%',
                background: 'rgba(0,0,0,0.5)',
                backdropFilter: 'blur(8px)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                cursor: 'pointer',
              }}>
                <span style={{ color: '#fff', fontSize: 10 }}>&#10005;</span>
              </div>
              <div style={{
                width: 24, height: 24, borderRadius: '50%',
                background: 'rgba(0,0,0,0.5)',
                backdropFilter: 'blur(8px)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                cursor: 'pointer',
              }}>
                <span style={{ color: '#fff', fontSize: 10 }}>&#8599;</span>
              </div>
            </div>
          </div>
          <p style={{
            position: 'absolute', bottom: 148, right: 20,
            font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.35)',
          }}>
            Corner-anchored &bull; Resizable
          </p>
        </Preview>
      </Section>

      {/* ── AirPlay Picker ── */}
      <Section title="AirPlay Picker" description="Glass sheet for selecting audio/video output destinations.">
        <Preview gradient style={{ padding: 32 }}>
          <div style={{
            maxWidth: 320, margin: '0 auto',
            background: 'var(--glass-bg-thick)',
            backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
            WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
            border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-xl)',
            boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
            overflow: 'hidden',
          }}>
            <div style={{ padding: '16px 20px 12px', borderBottom: '0.5px solid var(--separator)' }}>
              <span style={{ font: 'var(--text-headline)', color: 'var(--label)' }}>AirPlay</span>
            </div>
            {[
              { name: 'iPhone Speakers', icon: '&#128241;' },
              { name: 'AirPods Pro', icon: '&#127911;' },
              { name: 'Living Room', icon: '&#128250;' },
              { name: 'HomePod', icon: '&#127925;' },
            ].map((device, i, arr) => (
              <div key={device.name} style={{
                padding: '14px 20px',
                display: 'flex', alignItems: 'center', gap: 12,
                borderBottom: i < arr.length - 1 ? '0.5px solid var(--separator)' : 'none',
                cursor: 'pointer',
                background: selectedDevice === device.name ? 'var(--glass-bg-tinted)' : 'transparent',
              }} onClick={() => setSelectedDevice(device.name)}>
                <span style={{ fontSize: 18 }} dangerouslySetInnerHTML={{ __html: device.icon }} />
                <span style={{ font: 'var(--text-body)', color: 'var(--label)', flex: 1 }}>{device.name}</span>
                {selectedDevice === device.name && (
                  <span style={{ color: 'var(--blue)', fontSize: 16, fontWeight: 600 }}>&#10003;</span>
                )}
              </div>
            ))}
            {/* Volume slider */}
            <div style={{ padding: '12px 20px 16px', borderTop: '0.5px solid var(--separator)' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <span style={{ fontSize: 12, color: 'var(--label-tertiary)' }}>&#128264;</span>
                <div style={{ flex: 1, height: 4, background: 'var(--fill)', borderRadius: 2 }}>
                  <div style={{ width: '65%', height: '100%', background: 'var(--label)', borderRadius: 2 }} />
                </div>
                <span style={{ fontSize: 12, color: 'var(--label-tertiary)' }}>&#128266;</span>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Audio Routes ── */}
      <Section title="Audio Routes" description="Current and alternative audio output destinations with signal strength indicators.">
        <Preview gradient style={{ padding: 32 }}>
          <div style={{
            maxWidth: 320, margin: '0 auto',
            background: 'var(--glass-bg)',
            backdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
            WebkitBackdropFilter: 'blur(var(--blur-xl)) saturate(200%)',
            border: '0.5px solid var(--glass-border)',
            borderRadius: 'var(--r-xl)',
            boxShadow: 'var(--glass-shadow-lg), var(--glass-specular)',
            padding: 16,
          }}>
            {/* Current route */}
            <div style={{ marginBottom: 16 }}>
              <span style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', textTransform: 'uppercase', letterSpacing: 0.5 }}>Current</span>
              <div style={{
                marginTop: 8, padding: '12px 14px',
                background: 'var(--glass-bg-tinted)',
                borderRadius: 'var(--r-md)',
                display: 'flex', alignItems: 'center', gap: 10,
              }}>
                <span style={{ fontSize: 16 }}>&#128264;</span>
                <span style={{ font: 'var(--text-body)', fontWeight: 600, color: 'var(--blue)', flex: 1 }}>iPhone Speakers</span>
                {/* Signal bars */}
                <div style={{ display: 'flex', gap: 2, alignItems: 'flex-end' }}>
                  {[4, 6, 8, 10].map((h, i) => (
                    <div key={i} style={{ width: 3, height: h, borderRadius: 1, background: 'var(--blue)' }} />
                  ))}
                </div>
              </div>
            </div>

            {/* Other routes */}
            <span style={{ font: 'var(--text-caption1)', fontWeight: 600, color: 'var(--label-secondary)', textTransform: 'uppercase', letterSpacing: 0.5 }}>Other Devices</span>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 2, marginTop: 8 }}>
              {[
                { name: 'AirPods Pro', signal: [4, 6, 8, 10] },
                { name: 'Bedroom HomePod', signal: [4, 6, 8] },
                { name: 'Living Room', signal: [4, 6] },
              ].map((device) => (
                <div key={device.name} style={{
                  padding: '12px 14px',
                  borderRadius: 'var(--r-sm)',
                  display: 'flex', alignItems: 'center', gap: 10,
                  cursor: 'pointer',
                }}>
                  <span style={{ fontSize: 16 }}>&#127911;</span>
                  <span style={{ font: 'var(--text-body)', color: 'var(--label)', flex: 1 }}>{device.name}</span>
                  <div style={{ display: 'flex', gap: 2, alignItems: 'flex-end' }}>
                    {[4, 6, 8, 10].map((h, i) => (
                      <div key={i} style={{
                        width: 3, height: h, borderRadius: 1,
                        background: i < device.signal.length ? 'var(--label-secondary)' : 'var(--fill)',
                      }} />
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── Specs ── */}
      <Section title="Specs" description="Key dimensions for media playback components.">
        <SpecTable
          headers={['Element', 'Value']}
          rows={[
            ['Album art', '120 x 120 pt'],
            ['Mini player height', '64 px'],
            ['PiP minimum size', '150 x 100 pt'],
            ['Transport button', '44 x 44 pt'],
          ]}
        />
      </Section>
    </div>
  )
}
