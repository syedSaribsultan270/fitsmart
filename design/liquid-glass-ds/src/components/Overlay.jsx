import { useState, useEffect, useRef } from 'react'
import './Overlay.css'


/**
 * GlassPopover — Floating glass panel with a directional arrow.
 */
export function GlassPopover({
  children,
  arrow = 'top',
  className = '',
  style,
  ...props
}) {
  return (
    <div
      className={`glass-popover glass-popover--arrow-${arrow} ${className}`}
      style={style}
      {...props}
    >
      <div className="glass-popover__arrow" />
      <div className="glass-popover__content">
        {children}
      </div>
    </div>
  );
}


/**
 * GlassTooltip — Tooltip with glass background, shown on hover after a delay.
 */
export function GlassTooltip({
  text,
  children,
  position = 'top',
  delay = 600,
  className = '',
}) {
  const [visible, setVisible] = useState(false);
  const timeoutRef = useRef(null);

  const show = () => {
    timeoutRef.current = setTimeout(() => setVisible(true), delay);
  };

  const hide = () => {
    clearTimeout(timeoutRef.current);
    setVisible(false);
  };

  useEffect(() => {
    return () => clearTimeout(timeoutRef.current);
  }, []);

  return (
    <span
      className={`glass-tooltip-trigger ${className}`}
      onPointerEnter={show}
      onPointerLeave={hide}
      onFocus={show}
      onBlur={hide}
    >
      {children}
      {visible && (
        <span
          className={`glass-tooltip glass-tooltip--${position}`}
          role="tooltip"
        >
          <span className="glass-tooltip__arrow" />
          {text}
        </span>
      )}
    </span>
  );
}


/**
 * GlassSheet — Bottom sheet with detents, backdrop, and spring animation.
 */
export function GlassSheet({
  open,
  onClose,
  detent = 'half',
  customHeight,
  children,
  className = '',
}) {
  const [rendering, setRendering] = useState(false);
  const [animatingOut, setAnimatingOut] = useState(false);

  useEffect(() => {
    if (open) {
      setRendering(true);
      setAnimatingOut(false);
    } else if (rendering) {
      setAnimatingOut(true);
      const timer = setTimeout(() => {
        setRendering(false);
        setAnimatingOut(false);
      }, 350); // matches --motion-slow
      return () => clearTimeout(timer);
    }
  }, [open]);

  if (!rendering) return null;

  const heightMap = {
    half: '50vh',
    full: '90vh',
    custom: customHeight || '50vh',
  };

  const sheetHeight = heightMap[detent] || heightMap.half;

  const handleBackdropClick = (e) => {
    if (e.target === e.currentTarget) {
      onClose?.();
    }
  };

  return (
    <div
      className={`glass-sheet-backdrop ${animatingOut ? 'glass-sheet-backdrop--out' : ''}`}
      onClick={handleBackdropClick}
    >
      <div
        className={`glass-sheet ${animatingOut ? 'glass-sheet--out' : ''} ${className}`}
        style={{ height: sheetHeight }}
      >
        <div className="glass-sheet__indicator" />
        <div className="glass-sheet__content">
          {children}
        </div>
      </div>
    </div>
  );
}
