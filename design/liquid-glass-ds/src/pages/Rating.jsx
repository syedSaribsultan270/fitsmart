import { useState } from 'react'
import { Section, Preview } from '../components/Section'
import { SpecTable } from '../components/SpecTable'

/* ── SVG Paths ────────────────────────────────────────────────────── */

const STAR_PATH = 'M12 2l2.94 5.95L21 8.86l-4.5 4.38L17.63 19.2 12 16.27 6.37 19.2l1.13-5.96L3 8.86l6.06-.91L12 2z'
const HEART_PATH = 'M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z'
const THUMB_PATH = 'M2 20h2V10H2v10zm20-9a2 2 0 0 0-2-2h-6.32l.95-4.57.03-.32a1.5 1.5 0 0 0-.44-1.06L13.17 2 7.59 7.59A2 2 0 0 0 7 9v9a2 2 0 0 0 2 2h9c.83 0 1.54-.5 1.84-1.22l3.02-7.05A2 2 0 0 0 22 11z'

/* ── Star glyph component ─────────────────────────────────────────── */

function StarGlyph({ filled, half, color = 'var(--blue)', size = 24, id }) {
  if (half) {
    const clipId = `half-clip-${id || Math.random()}`
    return (
      <svg width={size} height={size} viewBox="0 0 24 24" style={{ display: 'block' }}>
        <defs>
          <clipPath id={clipId}>
            <rect x="0" y="0" width="12" height="24" />
          </clipPath>
        </defs>
        {/* Empty outline */}
        <path d={STAR_PATH} fill="none" stroke="var(--fill-secondary)" strokeWidth="1.5" />
        {/* Filled left half */}
        <path d={STAR_PATH} fill={color} clipPath={`url(#${clipId})`} />
      </svg>
    )
  }
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" style={{ display: 'block' }}>
      {filled ? (
        <path d={STAR_PATH} fill={color} />
      ) : (
        <path d={STAR_PATH} fill="none" stroke="var(--fill-secondary)" strokeWidth="1.5" />
      )}
    </svg>
  )
}

/* ── Interactive star rating ──────────────────────────────────────── */

function StarRating({ value, onChange, count = 5, color = 'var(--blue)', size = 24, readOnly = false }) {
  const [hoverVal, setHoverVal] = useState(null)
  const display = hoverVal !== null ? hoverVal : value

  return (
    <div style={{ display: 'inline-flex', gap: 2 }}>
      {Array.from({ length: count }, (_, i) => {
        const starIndex = i + 1
        const filled = display >= starIndex
        return (
          <div
            key={i}
            style={{
              width: readOnly ? size : 32,
              height: readOnly ? size : 32,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: readOnly ? 'default' : 'pointer',
              transform: !readOnly && hoverVal !== null && hoverVal >= starIndex ? 'scale(1.12)' : 'scale(1)',
              transition: 'transform 0.25s cubic-bezier(0.34, 1.56, 0.64, 1)',
            }}
            onMouseEnter={() => !readOnly && setHoverVal(starIndex)}
            onMouseLeave={() => !readOnly && setHoverVal(null)}
            onClick={() => !readOnly && onChange?.(starIndex === value ? 0 : starIndex)}
          >
            <StarGlyph filled={filled} color={color} size={size} />
          </div>
        )
      })}
    </div>
  )
}

/* ── Half-star rating ─────────────────────────────────────────────── */

function HalfStarRating({ value, onChange, count = 5, color = 'var(--blue)', size = 24 }) {
  const [hoverVal, setHoverVal] = useState(null)
  const display = hoverVal !== null ? hoverVal : value

  const handleMouseMove = (e, starIndex) => {
    const rect = e.currentTarget.getBoundingClientRect()
    const x = e.clientX - rect.left
    const isLeft = x < rect.width / 2
    setHoverVal(isLeft ? starIndex - 0.5 : starIndex)
  }

  const handleClick = (e, starIndex) => {
    const rect = e.currentTarget.getBoundingClientRect()
    const x = e.clientX - rect.left
    const isLeft = x < rect.width / 2
    const newVal = isLeft ? starIndex - 0.5 : starIndex
    onChange?.(newVal === value ? 0 : newVal)
  }

  return (
    <div style={{ display: 'inline-flex', gap: 2 }}>
      {Array.from({ length: count }, (_, i) => {
        const starIndex = i + 1
        const filled = display >= starIndex
        const halfFilled = !filled && display >= starIndex - 0.5
        return (
          <div
            key={i}
            style={{
              width: 32,
              height: 32,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              transform: hoverVal !== null && display >= starIndex - 0.5 ? 'scale(1.12)' : 'scale(1)',
              transition: 'transform 0.25s cubic-bezier(0.34, 1.56, 0.64, 1)',
            }}
            onMouseMove={(e) => handleMouseMove(e, starIndex)}
            onMouseLeave={() => setHoverVal(null)}
            onClick={(e) => handleClick(e, starIndex)}
          >
            <StarGlyph
              filled={filled}
              half={halfFilled}
              color={color}
              size={size}
              id={`half-${i}`}
            />
          </div>
        )
      })}
      <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.7)', marginLeft: 8, alignSelf: 'center' }}>
        {display}
      </span>
    </div>
  )
}

/* ── Read-only rating with value ──────────────────────────────────── */

function ReadOnlyRating({ value, count = 5, color = 'var(--blue)', size = 24 }) {
  return (
    <div style={{ display: 'inline-flex', gap: 2, alignItems: 'center' }}>
      {Array.from({ length: count }, (_, i) => {
        const starIndex = i + 1
        const filled = value >= starIndex
        const halfFilled = !filled && value >= starIndex - 0.5
        return (
          <StarGlyph
            key={i}
            filled={filled}
            half={halfFilled}
            color={color}
            size={size}
            id={`ro-${value}-${i}`}
          />
        )
      })}
      <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.7)', marginLeft: 8, fontWeight: 600 }}>
        {value}
      </span>
    </div>
  )
}

/* ── Custom glyph rating ──────────────────────────────────────────── */

function CustomGlyphRating({ value, onChange, path, color, count = 5, size = 24 }) {
  const [hoverVal, setHoverVal] = useState(null)
  const display = hoverVal !== null ? hoverVal : value

  return (
    <div style={{ display: 'inline-flex', gap: 2 }}>
      {Array.from({ length: count }, (_, i) => {
        const idx = i + 1
        const filled = display >= idx
        return (
          <div
            key={i}
            style={{
              width: 32,
              height: 32,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              transform: hoverVal !== null && hoverVal >= idx ? 'scale(1.12)' : 'scale(1)',
              transition: 'transform 0.25s cubic-bezier(0.34, 1.56, 0.64, 1)',
            }}
            onMouseEnter={() => setHoverVal(idx)}
            onMouseLeave={() => setHoverVal(null)}
            onClick={() => onChange?.(idx === value ? 0 : idx)}
          >
            <svg width={size} height={size} viewBox="0 0 24 24" style={{ display: 'block' }}>
              {filled ? (
                <path d={path} fill={color} />
              ) : (
                <path d={path} fill="none" stroke="var(--fill-secondary)" strokeWidth="1.5" />
              )}
            </svg>
          </div>
        )
      })}
    </div>
  )
}

/* ── Compact inline rating ────────────────────────────────────────── */

function CompactRating({ value, fontStyle }) {
  return (
    <span style={{ font: fontStyle, color: '#fff', display: 'inline-flex', alignItems: 'center', gap: 4 }}>
      <strong>{value}</strong>
      <svg width="14" height="14" viewBox="0 0 24 24" style={{ display: 'inline-block', verticalAlign: 'middle' }}>
        <path d={STAR_PATH} fill="var(--blue)" />
      </svg>
    </span>
  )
}

/* ── Main page ────────────────────────────────────────────────────── */

export default function Rating() {
  /* Section 1 — Interactive star rating */
  const [rating1, setRating1] = useState(0)
  const [rating2, setRating2] = useState(3)
  const [rating3, setRating3] = useState(5)

  /* Section 2 — Half-star rating */
  const [halfRating, setHalfRating] = useState(3.5)

  /* Section 4 — Custom glyphs */
  const [heartRating, setHeartRating] = useState(3)
  const [thumbRating, setThumbRating] = useState(2)
  const [circleRating, setCircleRating] = useState(4)

  return (
    <div>
      <h1 style={{ font: 'var(--text-large-title)', marginBottom: 8 }}>Rating</h1>
      <p style={{ font: 'var(--text-body)', color: 'var(--label-secondary)', marginBottom: 48 }}>
        Interactive and read-only rating controls with star, half-star, and custom glyph variants. Built with SVG and spring animations.
      </p>

      {/* ── 1. Star Rating -- Interactive ─────────────────────────── */}
      <Section title="Star Rating -- Interactive" description="Click to set a rating. Stars scale up on hover with a spring transition. Click a selected star to reset it.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8, textTransform: 'uppercase', letterSpacing: 1 }}>Unset (0)</div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <StarRating value={rating1} onChange={setRating1} />
                <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.6)' }}>
                  {rating1 === 0 ? 'Tap to rate' : `${rating1}/5`}
                </span>
              </div>
            </div>
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8, textTransform: 'uppercase', letterSpacing: 1 }}>Partial (3)</div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <StarRating value={rating2} onChange={setRating2} />
                <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.6)' }}>{rating2}/5</span>
              </div>
            </div>
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8, textTransform: 'uppercase', letterSpacing: 1 }}>Full (5)</div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <StarRating value={rating3} onChange={setRating3} />
                <span style={{ font: 'var(--text-subhead)', color: 'rgba(255,255,255,0.6)' }}>{rating3}/5</span>
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── 2. Half-star Rating ───────────────────────────────────── */}
      <Section title="Half-star Rating" description="Supports 0.5 increments. Hover the left half of a star for a half rating, the right half for a full star.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <HalfStarRating value={halfRating} onChange={setHalfRating} />
            <p style={{ font: 'var(--text-footnote)', color: 'rgba(255,255,255,0.6)', margin: 0 }}>
              Move your cursor across the left and right halves of each star.
            </p>
          </div>
        </Preview>
      </Section>

      {/* ── 3. Read-only Rating ───────────────────────────────────── */}
      <Section title="Read-only Rating" description="Non-interactive display for showing existing ratings. No hover or click behavior.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            <ReadOnlyRating value={4.5} />
            <ReadOnlyRating value={3.0} />
            <ReadOnlyRating value={1.5} />
          </div>
        </Preview>
      </Section>

      {/* ── 4. Custom Glyphs ──────────────────────────────────────── */}
      <Section title="Custom Glyphs" description="The rating system works with any SVG glyph: hearts, thumbs up, or circles.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8, textTransform: 'uppercase', letterSpacing: 1 }}>Hearts</div>
              <CustomGlyphRating value={heartRating} onChange={setHeartRating} path={HEART_PATH} color="var(--red)" />
            </div>
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8, textTransform: 'uppercase', letterSpacing: 1 }}>Thumbs Up</div>
              <CustomGlyphRating value={thumbRating} onChange={setThumbRating} path={THUMB_PATH} color="var(--green)" />
            </div>
            <div>
              <div style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', marginBottom: 8, textTransform: 'uppercase', letterSpacing: 1 }}>Circles</div>
              <div style={{ display: 'inline-flex', gap: 2 }}>
                {Array.from({ length: 5 }, (_, i) => {
                  const idx = i + 1
                  const filled = circleRating >= idx
                  return (
                    <div
                      key={i}
                      style={{
                        width: 32,
                        height: 32,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        cursor: 'pointer',
                        transition: 'transform 0.25s cubic-bezier(0.34, 1.56, 0.64, 1)',
                      }}
                      onClick={() => setCircleRating(idx === circleRating ? 0 : idx)}
                    >
                      <svg width="24" height="24" viewBox="0 0 24 24">
                        {filled ? (
                          <circle cx="12" cy="12" r="10" fill="var(--blue)" />
                        ) : (
                          <circle cx="12" cy="12" r="10" fill="none" stroke="var(--fill-secondary)" strokeWidth="1.5" />
                        )}
                      </svg>
                    </div>
                  )
                })}
              </div>
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── 5. Compact Rating ─────────────────────────────────────── */}
      <Section title="Compact Rating" description="Small inline rating display suitable for lists, cards, and metadata rows.">
        <Preview gradient>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', width: 60, textTransform: 'uppercase', letterSpacing: 1 }}>Caption</span>
              <CompactRating value="4.5" fontStyle="var(--text-caption1)" />
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', width: 60, textTransform: 'uppercase', letterSpacing: 1 }}>Body</span>
              <CompactRating value="4.5" fontStyle="var(--text-body)" />
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <span style={{ font: 'var(--text-caption1)', color: 'rgba(255,255,255,0.5)', width: 60, textTransform: 'uppercase', letterSpacing: 1 }}>Headline</span>
              <CompactRating value="4.5" fontStyle="var(--text-headline)" />
            </div>
          </div>
        </Preview>
      </Section>

      {/* ── 6. Specs ──────────────────────────────────────────────── */}
      <Section title="Rating Specs" description="Sizing and interaction reference for rating components.">
        <SpecTable
          headers={['Property', 'Value']}
          rows={[
            ['Default size', '24x24 per glyph'],
            ['Gap', '2px'],
            ['Interactive hit area', '32x32 (larger than visual)'],
            ['Half-star support', 'Left/right halves of glyph'],
            ['Colors', 'Star: --blue, Heart: --red, Thumb: --green'],
            ['Hover scale', '1.12 (spring)'],
            ['Read-only cursor', 'default'],
            ['Interactive cursor', 'pointer'],
          ]}
        />
      </Section>
    </div>
  )
}
