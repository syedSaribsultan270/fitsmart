import { useState, useEffect, useRef } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'
import { GlassPanel, GlassCard, GlassButton } from '../components/Glass'

export default function ImageViews() {
  /* ---------- Async Loading state ---------- */
  const [imageLoaded, setImageLoaded] = useState(false)
  const [loading, setLoading] = useState(false)

  const handleLoadImage = () => {
    setImageLoaded(false)
    setLoading(true)
    setTimeout(() => {
      setLoading(false)
      setImageLoaded(true)
    }, 1500)
  }

  /* ---------- Gallery state ---------- */
  const [galleryIndex, setGalleryIndex] = useState(0)
  const scrollRef = useRef(null)
  const galleryColors = [
    'linear-gradient(135deg, #FF3B30, #FF9500)',
    'linear-gradient(135deg, #34C759, #00C7BE)',
    'linear-gradient(135deg, #007AFF, #5856D6)',
    'linear-gradient(135deg, #AF52DE, #FF2D55)',
    'linear-gradient(135deg, #FFCC00, #FF9500)',
  ]

  const scrollToIndex = (idx) => {
    const clamped = Math.max(0, Math.min(idx, galleryColors.length - 1))
    setGalleryIndex(clamped)
    if (scrollRef.current) {
      const child = scrollRef.current.children[clamped]
      if (child) child.scrollIntoView({ behavior: 'smooth', inline: 'start', block: 'nearest' })
    }
  }

  /* Shared mock-image gradient */
  const mockImage = 'linear-gradient(135deg, #FF3B30 0%, #FF9500 30%, #FFCC00 50%, #34C759 70%, #007AFF 100%)'

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Image Views</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Content modes, corner masking, placeholders, async loading, and gallery patterns for displaying images.
      </p>

      {/* ============================================================
          1. Content Modes
          ============================================================ */}
      <Section title="Content Modes" description="How an image fills its container. Aspect Fill crops, Aspect Fit letterboxes, and Scale to Fill stretches.">
        <Preview gradient>
          <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap' }}>
            {/* Aspect Fill */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 200, height: 150, borderRadius: 'var(--r-lg)', overflow: 'hidden',
                border: '0.5px solid rgba(255,255,255,0.15)',
              }}>
                <div style={{
                  width: '120%', height: '120%', marginTop: '-10%', marginLeft: '-10%',
                  background: mockImage,
                }} />
              </div>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.7)' }}>
                Aspect Fill (cover)
              </span>
            </div>

            {/* Aspect Fit */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 200, height: 150, borderRadius: 'var(--r-lg)', overflow: 'hidden',
                border: '0.5px solid rgba(255,255,255,0.15)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                background: 'rgba(0,0,0,0.3)',
              }}>
                <div style={{
                  width: '80%', height: '80%',
                  background: mockImage, borderRadius: 4,
                }} />
              </div>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.7)' }}>
                Aspect Fit (contain)
              </span>
            </div>

            {/* Scale to Fill */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 200, height: 150, borderRadius: 'var(--r-lg)', overflow: 'hidden',
                border: '0.5px solid rgba(255,255,255,0.15)',
              }}>
                <div style={{
                  width: '100%', height: '100%',
                  background: mockImage,
                }} />
              </div>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.7)' }}>
                Scale to Fill (fill)
              </span>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          2. Corner Masking
          ============================================================ */}
      <Section title="Corner Masking" description="Different border-radius values to mask image corners, from sharp to fully circular.">
        <Preview gradient>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(120px, 1fr))', gap: 20 }}>
            {[
              { label: 'None', radius: 0 },
              { label: 'Small', radius: 'var(--r-sm)' },
              { label: 'Medium', radius: 'var(--r-lg)' },
              { label: 'Large', radius: 'var(--r-2xl)' },
              { label: 'Circle', radius: '50%' },
              { label: 'Squircle', radius: 'var(--r-2xl)' },
            ].map((item) => (
              <div key={item.label} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                <div style={{
                  width: item.label === 'Circle' ? 100 : 100,
                  height: 100,
                  borderRadius: item.radius,
                  background: 'linear-gradient(135deg, #5856D6, #AF52DE, #FF2D55)',
                  border: '0.5px solid rgba(255,255,255,0.15)',
                  ...(item.label === 'Squircle' ? {
                    /* Continuous corner approximation */
                    borderRadius: 'var(--r-2xl)',
                    WebkitMaskImage: 'paint(squircle)',
                  } : {}),
                }} />
                <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.7)', textAlign: 'center' }}>
                  {item.label}
                  {item.label === 'None' && ' (0)'}
                  {item.label === 'Small' && ' (12px)'}
                  {item.label === 'Medium' && ' (22px)'}
                  {item.label === 'Large' && ' (36px)'}
                  {item.label === 'Circle' && ' (50%)'}
                </span>
                {item.label === 'Squircle' && (
                  <span style={{ font: 'var(--text-caption2)', color: 'rgba(255,255,255,0.4)', textAlign: 'center', maxWidth: 100 }}>
                    iOS uses continuous corners natively
                  </span>
                )}
              </div>
            ))}
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          3. Placeholder States
          ============================================================ */}
      <Section title="Placeholder States" description="Visual placeholders shown while images are loading.">
        <style>{`
          @keyframes shimmer {
            0% { background-position: -200px 0; }
            100% { background-position: 200px 0; }
          }
        `}</style>
        <Preview gradient>
          <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap' }}>
            {/* Skeleton */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 200, height: 150, borderRadius: 'var(--r-lg)', overflow: 'hidden',
                background: 'linear-gradient(90deg, rgba(255,255,255,0.06) 25%, rgba(255,255,255,0.15) 50%, rgba(255,255,255,0.06) 75%)',
                backgroundSize: '400px 100%',
                animation: 'shimmer 1.5s ease-in-out infinite',
              }} />
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.7)' }}>Skeleton</span>
            </div>

            {/* Blur */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 200, height: 150, borderRadius: 'var(--r-lg)', overflow: 'hidden',
                background: 'rgba(120,120,128,0.3)',
                filter: 'blur(20px)',
              }} />
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.7)' }}>Blur</span>
            </div>

            {/* Color */}
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 200, height: 150, borderRadius: 'var(--r-lg)', overflow: 'hidden',
                background: '#E5E5EA',
              }} />
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.7)' }}>Color</span>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          4. Async Loading
          ============================================================ */}
      <Section title="Async Loading" description="Interactive demo simulating a 1.5s network fetch with skeleton-to-image transition.">
        <style>{`
          @keyframes shimmerAsync {
            0% { background-position: -200px 0; }
            100% { background-position: 200px 0; }
          }
          @keyframes fadeInImage {
            from { opacity: 0; }
            to { opacity: 1; }
          }
        `}</style>
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16 }}>
            <div style={{
              width: 280, height: 180, borderRadius: 'var(--r-lg)', overflow: 'hidden',
              position: 'relative',
              border: '0.5px solid rgba(255,255,255,0.15)',
            }}>
              {/* Skeleton / placeholder */}
              {!imageLoaded && (
                <div style={{
                  width: '100%', height: '100%',
                  background: loading
                    ? 'linear-gradient(90deg, rgba(255,255,255,0.06) 25%, rgba(255,255,255,0.15) 50%, rgba(255,255,255,0.06) 75%)'
                    : 'rgba(255,255,255,0.06)',
                  backgroundSize: '400px 100%',
                  animation: loading ? 'shimmerAsync 1.5s ease-in-out infinite' : 'none',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }} >
                  {!loading && (
                    <span style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.4)' }}>
                      No image loaded
                    </span>
                  )}
                </div>
              )}

              {/* Loaded image */}
              {imageLoaded && (
                <div style={{
                  width: '100%', height: '100%',
                  background: mockImage,
                  animation: 'fadeInImage 400ms ease-in-out',
                }} />
              )}
            </div>

            <GlassButton onClick={handleLoadImage} disabled={loading}>
              {loading ? 'Loading...' : imageLoaded ? 'Reload Image' : 'Load Image'}
            </GlassButton>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          5. Gallery
          ============================================================ */}
      <Section title="Gallery" description="Horizontal scrolling gallery with snap, page indicators, and navigation buttons.">
        <Preview gradient>
          <div style={{
            background: 'rgba(255,255,255,0.08)',
            backdropFilter: 'blur(32px)',
            WebkitBackdropFilter: 'blur(32px)',
            borderRadius: 'var(--r-xl)',
            padding: 16,
            position: 'relative',
            overflow: 'hidden',
            border: '0.5px solid rgba(255,255,255,0.12)',
          }}>
            {/* Counter pill */}
            <div style={{
              position: 'absolute', top: 24, right: 24, zIndex: 2,
              background: 'rgba(0,0,0,0.4)',
              backdropFilter: 'blur(16px)',
              WebkitBackdropFilter: 'blur(16px)',
              borderRadius: 'var(--r-pill)',
              padding: '4px 10px',
              font: 'var(--text-caption2)',
              color: 'rgba(255,255,255,0.8)',
            }}>
              {galleryIndex + 1} / {galleryColors.length}
            </div>

            {/* Scrollable images */}
            <div
              ref={scrollRef}
              style={{
                display: 'flex', gap: 12, overflowX: 'auto',
                scrollSnapType: 'x mandatory',
                scrollbarWidth: 'none',
                msOverflowStyle: 'none',
              }}
            >
              {galleryColors.map((bg, i) => (
                <div key={i} style={{
                  minWidth: '100%', height: 200, borderRadius: 'var(--r-lg)',
                  background: bg,
                  scrollSnapAlign: 'start',
                  flexShrink: 0,
                }} />
              ))}
            </div>

            {/* Navigation + dots */}
            <div style={{
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              gap: 16, marginTop: 12,
            }}>
              <GlassButton
                size="sm"
                onClick={() => scrollToIndex(galleryIndex - 1)}
                disabled={galleryIndex === 0}
                style={{ padding: '6px 10px', minWidth: 0 }}
              >
                <svg width="14" height="14" viewBox="0 0 14 14" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M9 2L4 7l5 5" />
                </svg>
              </GlassButton>

              {/* Page dots */}
              <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                {galleryColors.map((_, i) => (
                  <div
                    key={i}
                    onClick={() => scrollToIndex(i)}
                    style={{
                      width: galleryIndex === i ? 8 : 6,
                      height: galleryIndex === i ? 8 : 6,
                      borderRadius: '50%',
                      background: galleryIndex === i ? 'var(--blue)' : 'var(--fill-secondary)',
                      transition: 'all 200ms var(--ease)',
                      cursor: 'pointer',
                    }}
                  />
                ))}
              </div>

              <GlassButton
                size="sm"
                onClick={() => scrollToIndex(galleryIndex + 1)}
                disabled={galleryIndex === galleryColors.length - 1}
                style={{ padding: '6px 10px', minWidth: 0 }}
              >
                <svg width="14" height="14" viewBox="0 0 14 14" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M5 2l5 5-5 5" />
                </svg>
              </GlassButton>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ============================================================
          6. Image View Specs
          ============================================================ */}
      <Section title="Image View Specs">
        <SpecTable
          headers={['Property', 'Value']}
          rows={[
            ['Default radius', 'var(--r-lg) / 22px'],
            ['Placeholder shimmer duration', '1.5s'],
            ['Load fade-in', '400ms ease-io'],
            ['Gallery scroll-snap', 'x mandatory'],
            ['Gallery dot size', '6px (inactive) / 8px (active)'],
            ['Gallery dot color', '--fill-secondary / --blue'],
          ]}
        />
      </Section>
    </div>
  )
}
