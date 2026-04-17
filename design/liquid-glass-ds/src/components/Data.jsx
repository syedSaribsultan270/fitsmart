import { useState } from 'react';
import './Data.css';

/**
 * GlassRating — Star (or heart/thumb) rating with spring hover.
 */
export function GlassRating({
  value = 0,
  onChange,
  max = 5,
  size = 24,
  glyph = 'star',
  className = '',
}) {
  const [hoverValue, setHoverValue] = useState(null);

  const display = hoverValue !== null ? hoverValue : value;
  const interactive = !!onChange;

  const colors = {
    star: 'var(--blue)',
    heart: 'var(--red)',
    thumb: 'var(--green)',
  };
  const fillColor = colors[glyph] || colors.star;

  const glyphs = {
    star: (
      <path d="M12 2l3.09 6.26L22 9.27l-5 4.87L18.18 22 12 18.27 5.82 22 7 14.14l-5-4.87 6.91-1.01L12 2z" />
    ),
    heart: (
      <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" />
    ),
    thumb: (
      <path d="M1 21h4V9H1v12zM23 10c0-1.1-.9-2-2-2h-6.31l.95-4.57.03-.32c0-.41-.17-.79-.44-1.06L14.17 1 7.59 7.59C7.22 7.95 7 8.45 7 9v10c0 1.1.9 2 2 2h9c.83 0 1.54-.5 1.84-1.22l3.02-7.05c.09-.23.14-.47.14-.73v-2z" />
    ),
  };

  const handleClick = (i) => {
    if (!interactive) return;
    onChange(i + 1);
  };

  const handleMouseEnter = (i) => {
    if (!interactive) return;
    setHoverValue(i + 1);
  };

  const handleMouseLeave = () => {
    if (!interactive) return;
    setHoverValue(null);
  };

  return (
    <div
      className={`glass-rating ${interactive ? 'glass-rating--interactive' : ''} ${className}`}
      onMouseLeave={handleMouseLeave}
    >
      {Array.from({ length: max }, (_, i) => {
        const filled = display >= i + 1;
        const half = !filled && display >= i + 0.5;

        return (
          <svg
            key={i}
            className="glass-rating__glyph"
            viewBox="0 0 24 24"
            width={size}
            height={size}
            onClick={() => handleClick(i)}
            onMouseEnter={() => handleMouseEnter(i)}
          >
            {half ? (
              <>
                <defs>
                  <clipPath id={`half-clip-${i}`}>
                    <rect x="0" y="0" width="12" height="24" />
                  </clipPath>
                </defs>
                {/* Empty outline behind */}
                <g fill="none" stroke="var(--fill-secondary)" strokeWidth="1.5">
                  {glyphs[glyph]}
                </g>
                {/* Filled left half */}
                <g fill={fillColor} clipPath={`url(#half-clip-${i})`}>
                  {glyphs[glyph]}
                </g>
              </>
            ) : (
              <g
                fill={filled ? fillColor : 'none'}
                stroke={filled ? fillColor : 'var(--fill-secondary)'}
                strokeWidth={filled ? '0' : '1.5'}
              >
                {glyphs[glyph]}
              </g>
            )}
          </svg>
        );
      })}
    </div>
  );
}

/**
 * GlassTokenField — Tag/token input with glass pills.
 */
export function GlassTokenField({
  tokens = [],
  onAdd,
  onRemove,
  placeholder = 'Add tag...',
  className = '',
}) {
  const [inputValue, setInputValue] = useState('');

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && inputValue.trim()) {
      e.preventDefault();
      onAdd?.(inputValue.trim());
      setInputValue('');
    }
    if (e.key === 'Backspace' && !inputValue && tokens.length > 0) {
      onRemove?.(tokens.length - 1);
    }
  };

  return (
    <div className={`glass-token-field ${className}`}>
      {tokens.map((token, i) => (
        <span key={`${token}-${i}`} className="glass-token-pill">
          <span className="glass-token-pill__label">{token}</span>
          <button
            className="glass-token-pill__remove"
            onClick={() => onRemove?.(i)}
            aria-label={`Remove ${token}`}
          >
            <svg viewBox="0 0 16 16" width="10" height="10" fill="currentColor">
              <path d="M4.646 4.646a.5.5 0 01.708 0L8 7.293l2.646-2.647a.5.5 0 01.708.708L8.707 8l2.647 2.646a.5.5 0 01-.708.708L8 8.707l-2.646 2.647a.5.5 0 01-.708-.708L7.293 8 4.646 5.354a.5.5 0 010-.708z" />
            </svg>
          </button>
        </span>
      ))}
      <input
        className="glass-token-field__input"
        type="text"
        value={inputValue}
        onChange={(e) => setInputValue(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder={tokens.length === 0 ? placeholder : ''}
      />
    </div>
  );
}

/**
 * GlassActivityRings — Concentric activity rings (Apple Watch style).
 */
export function GlassActivityRings({
  move = 0,
  exercise = 0,
  stand = 0,
  size = 120,
  className = '',
}) {
  const center = size / 2;
  const strokeWidth = size * 0.1;
  const gap = strokeWidth * 0.4;

  const outerR = center - strokeWidth / 2 - 2;
  const midR = outerR - strokeWidth - gap;
  const innerR = midR - strokeWidth - gap;

  const circumference = (r) => 2 * Math.PI * r;

  const ring = (r, progress, color) => {
    const c = circumference(r);
    const offset = c - c * Math.min(Math.max(progress, 0), 1);
    return (
      <>
        {/* Background track */}
        <circle
          cx={center}
          cy={center}
          r={r}
          fill="none"
          stroke={color}
          strokeWidth={strokeWidth}
          strokeLinecap="round"
          opacity="0.15"
        />
        {/* Progress arc */}
        <circle
          className="glass-ring__arc"
          cx={center}
          cy={center}
          r={r}
          fill="none"
          stroke={color}
          strokeWidth={strokeWidth}
          strokeLinecap="round"
          strokeDasharray={c}
          strokeDashoffset={offset}
          transform={`rotate(-90 ${center} ${center})`}
        />
      </>
    );
  };

  return (
    <svg
      className={`glass-activity-rings ${className}`}
      viewBox={`0 0 ${size} ${size}`}
      width={size}
      height={size}
    >
      {ring(outerR, move, 'var(--red)')}
      {ring(midR, exercise, 'var(--green)')}
      {ring(innerR, stand, 'var(--cyan)')}
    </svg>
  );
}
