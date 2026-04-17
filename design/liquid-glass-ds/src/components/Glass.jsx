import { useState, useRef, useCallback } from 'react';
import './Glass.css';

/**
 * GlassPanel — The core Liquid Glass surface.
 */
export function GlassPanel({
  children,
  className = '',
  variant = 'regular',
  padding = true,
  as: Tag = 'div',
  style,
  ...props
}) {
  return (
    <Tag
      className={`glass glass--${variant} ${padding ? 'glass--padded' : ''} ${className}`}
      style={style}
      {...props}
    >
      {children}
    </Tag>
  );
}

/**
 * GlassCard — Clickable/hoverable glass card
 */
export function GlassCard({ children, className = '', href, onClick, style, ...props }) {
  const Tag = href ? 'a' : 'div';
  return (
    <Tag
      className={`glass-card ${className}`}
      href={href}
      onClick={onClick}
      style={style}
      {...props}
    >
      {children}
    </Tag>
  );
}

/**
 * GlassButton — Button with glass material + spring press
 */
export function GlassButton({
  children,
  className = '',
  variant = 'glass',
  size = 'md',
  pill = false,
  icon = false,
  color,
  ...props
}) {
  return (
    <button
      className={`glass-btn glass-btn--${variant} glass-btn--${size} ${pill ? 'glass-btn--pill' : ''} ${icon ? 'glass-btn--icon' : ''} ${className}`}
      style={color ? { '--btn-color': color } : undefined}
      {...props}
    >
      {children}
    </button>
  );
}

/**
 * GlassToggle — iOS switch with glass-on-press + springy thumb.
 * The track turns Liquid Glass when you press/drag, and the thumb
 * stretches horizontally (iOS squish effect).
 */
export function GlassToggle({ checked, onChange, disabled, className = '' }) {
  const [pressing, setPressing] = useState(false);

  const handlePointerDown = useCallback(() => setPressing(true), []);
  const handlePointerUp = useCallback(() => setPressing(false), []);

  return (
    <label
      className={`glass-toggle ${disabled ? 'glass-toggle--disabled' : ''} ${pressing ? 'glass-toggle--active' : ''} ${className}`}
      onPointerDown={handlePointerDown}
      onPointerUp={handlePointerUp}
      onPointerLeave={handlePointerUp}
    >
      <input type="checkbox" checked={checked} onChange={onChange} disabled={disabled} />
      <span className="glass-toggle__track">
        <span className="glass-toggle__thumb" />
      </span>
    </label>
  );
}

/**
 * GlassInput — Text field with glass material
 */
export function GlassInput({ className = '', ...props }) {
  return <input className={`glass-input ${className}`} {...props} />;
}

/**
 * GlassSegment — Segmented control with a sliding glass pill indicator.
 * The active background smoothly translates between segments.
 */
export function GlassSegment({ items, value, onChange, className = '' }) {
  const containerRef = useRef(null);
  const [pill, setPill] = useState({ left: 0, width: 0 });
  const itemRefs = useRef({});

  const updatePill = useCallback(() => {
    const container = containerRef.current;
    const activeEl = itemRefs.current[value];
    if (!container || !activeEl) return;
    const cRect = container.getBoundingClientRect();
    const aRect = activeEl.getBoundingClientRect();
    setPill({ left: aRect.left - cRect.left, width: aRect.width });
  }, [value]);

  // Measure on mount + value change
  useState(() => {
    requestAnimationFrame(updatePill);
  });

  // Re-measure when value changes
  const prevValue = useRef(value);
  if (prevValue.current !== value) {
    prevValue.current = value;
    requestAnimationFrame(updatePill);
  }

  return (
    <div className={`glass-segment ${className}`} ref={containerRef}>
      {/* Sliding pill indicator */}
      <div
        className="glass-segment__pill"
        style={{ left: pill.left, width: pill.width }}
      />
      {items.map((item) => (
        <button
          key={item.value}
          ref={(el) => { itemRefs.current[item.value] = el; }}
          className={`glass-segment__item ${value === item.value ? 'active' : ''}`}
          onClick={() => {
            onChange?.(item.value);
            // Measure after React re-renders
            requestAnimationFrame(() => {
              const container = containerRef.current;
              const el = itemRefs.current[item.value];
              if (!container || !el) return;
              const cRect = container.getBoundingClientRect();
              const aRect = el.getBoundingClientRect();
              setPill({ left: aRect.left - cRect.left, width: aRect.width });
            });
          }}
        >
          {item.label}
        </button>
      ))}
    </div>
  );
}

/**
 * GlassSlider — Range input. Thumb grows + gets glass glow on drag.
 */
export function GlassSlider({ className = '', ...props }) {
  return <input type="range" className={`glass-slider ${className}`} {...props} />;
}

/**
 * GlassSearch — Pill-shaped search with glass background
 */
export function GlassSearch({ className = '', ...props }) {
  return (
    <div className={`glass-search ${className}`}>
      <svg className="glass-search__icon" viewBox="0 0 20 20" fill="currentColor">
        <path fillRule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clipRule="evenodd"/>
      </svg>
      <input className="glass-search__input" type="search" {...props} />
    </div>
  );
}

/**
 * GlassAlert — Alert dialog with scale-bounce entrance
 */
export function GlassAlert({ title, message, actions = [], className = '' }) {
  return (
    <div className={`glass-alert ${className}`}>
      <div className="glass-alert__body">
        <div className="glass-alert__title">{title}</div>
        {message && <div className="glass-alert__msg">{message}</div>}
      </div>
      <div className="glass-alert__actions">
        {actions.map((action, i) => (
          <button
            key={i}
            className={`glass-alert__btn ${action.primary ? 'glass-alert__btn--primary' : ''} ${action.destructive ? 'glass-alert__btn--destructive' : ''}`}
            onClick={action.onClick}
          >
            {action.label}
          </button>
        ))}
      </div>
    </div>
  );
}

/**
 * GlassProgress — Progress bar
 */
export function GlassProgress({ value = 0, className = '' }) {
  return (
    <div className={`glass-progress ${className}`}>
      <div className="glass-progress__fill" style={{ width: `${value}%` }} />
    </div>
  );
}

/**
 * GlassDropdown — Wrapper that adds entrance animation to dropdown content
 */
export function GlassDropdown({ open, children, direction = 'down', className = '' }) {
  if (!open) return null;
  return (
    <div className={`${direction === 'up' ? 'glass-dropdown-up' : 'glass-dropdown-enter'} ${className}`}>
      {children}
    </div>
  );
}

/**
 * GlassList — Grouped list with glass container
 */
export function GlassList({ children, header, className = '' }) {
  return (
    <div className={`glass-list ${className}`}>
      {header && <div className="glass-list__header">{header}</div>}
      <div className="glass-list__items">{children}</div>
    </div>
  );
}

export function GlassListItem({ children, accessory, onClick, className = '' }) {
  return (
    <div className={`glass-list__item ${onClick ? 'glass-list__item--interactive' : ''} ${className}`} onClick={onClick}>
      <div className="glass-list__item-content">{children}</div>
      {accessory && <div className="glass-list__item-accessory">{accessory}</div>}
    </div>
  );
}
