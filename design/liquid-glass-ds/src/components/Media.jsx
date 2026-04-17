import { useState } from 'react';
import './Media.css';

/**
 * GlassImage — Image display with glass placeholders and transitions.
 */
export function GlassImage({
  src,
  alt = '',
  mode = 'fill',
  radius = 'var(--r-lg)',
  placeholder = 'skeleton',
  placeholderColor,
  width,
  height,
  className = '',
  ...props
}) {
  const [loaded, setLoaded] = useState(false);
  const [error, setError] = useState(false);

  const showPlaceholder = !src || !loaded || error;

  const modeMap = {
    fill: 'cover',
    fit: 'contain',
    center: 'none',
  };

  return (
    <div
      className={`glass-image ${className}`}
      style={{ borderRadius: radius, width, height }}
      {...props}
    >
      {showPlaceholder && (
        <div
          className={`glass-image__placeholder glass-image__placeholder--${error ? placeholder : placeholder}`}
          style={placeholderColor ? { '--placeholder-color': placeholderColor } : undefined}
        >
          {placeholder === 'skeleton' && <div className="glass-image__shimmer" />}
        </div>
      )}
      {src && !error && (
        <img
          className={`glass-image__img ${loaded ? 'glass-image__img--loaded' : ''}`}
          src={src}
          alt={alt}
          style={{ objectFit: modeMap[mode] || 'cover' }}
          onLoad={() => setLoaded(true)}
          onError={() => setError(true)}
        />
      )}
    </div>
  );
}

/**
 * GlassGallery — Horizontal image gallery with glass chrome.
 */
export function GlassGallery({ images = [], className = '' }) {
  const [current, setCurrent] = useState(0);

  const scrollTo = (index) => {
    const el = document.getElementById(`glass-gallery-item-${index}`);
    if (el) {
      el.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
      setCurrent(index);
    }
  };

  const handleScroll = (e) => {
    const container = e.target;
    const scrollLeft = container.scrollLeft;
    const itemWidth = container.offsetWidth;
    const idx = Math.round(scrollLeft / itemWidth);
    if (idx !== current && idx >= 0 && idx < images.length) {
      setCurrent(idx);
    }
  };

  const prev = () => scrollTo(Math.max(0, current - 1));
  const next = () => scrollTo(Math.min(images.length - 1, current + 1));

  return (
    <div className={`glass-gallery ${className}`}>
      {/* Counter pill */}
      <div className="glass-gallery__counter">
        {current + 1} / {images.length}
      </div>

      {/* Scroll area */}
      <div className="glass-gallery__scroll" onScroll={handleScroll}>
        {images.map((img, i) => (
          <div
            key={i}
            id={`glass-gallery-item-${i}`}
            className="glass-gallery__item"
          >
            <img src={img.src} alt={img.alt || ''} className="glass-gallery__img" />
          </div>
        ))}
      </div>

      {/* Navigation arrows */}
      {images.length > 1 && (
        <>
          <button
            className="glass-gallery__arrow glass-gallery__arrow--prev"
            onClick={prev}
            disabled={current === 0}
            aria-label="Previous image"
          >
            <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <polyline points="15 18 9 12 15 6" />
            </svg>
          </button>
          <button
            className="glass-gallery__arrow glass-gallery__arrow--next"
            onClick={next}
            disabled={current === images.length - 1}
            aria-label="Next image"
          >
            <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <polyline points="9 18 15 12 9 6" />
            </svg>
          </button>
        </>
      )}

      {/* Dots */}
      {images.length > 1 && (
        <div className="glass-gallery__dots">
          {images.map((_, i) => (
            <button
              key={i}
              className={`glass-gallery__dot ${i === current ? 'glass-gallery__dot--active' : ''}`}
              onClick={() => scrollTo(i)}
              aria-label={`Go to image ${i + 1}`}
            />
          ))}
        </div>
      )}
    </div>
  );
}

/**
 * GlassImageWell — macOS-style image drop zone.
 */
export function GlassImageWell({ value, onChange, className = '' }) {
  const [dragOver, setDragOver] = useState(false);

  const handleDrop = (e) => {
    e.preventDefault();
    setDragOver(false);
    const file = e.dataTransfer?.files?.[0];
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader();
      reader.onload = (ev) => onChange?.(ev.target.result);
      reader.readAsDataURL(file);
    }
  };

  const handleDragOver = (e) => {
    e.preventDefault();
    setDragOver(true);
  };

  const handleDragLeave = () => setDragOver(false);

  const handleClick = () => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/*';
    input.onchange = (e) => {
      const file = e.target.files?.[0];
      if (file) {
        const reader = new FileReader();
        reader.onload = (ev) => onChange?.(ev.target.result);
        reader.readAsDataURL(file);
      }
    };
    input.click();
  };

  return (
    <div
      className={`glass-image-well ${value ? 'glass-image-well--filled' : ''} ${dragOver ? 'glass-image-well--dragover' : ''} ${className}`}
      onDrop={handleDrop}
      onDragOver={handleDragOver}
      onDragLeave={handleDragLeave}
      onClick={handleClick}
    >
      {value ? (
        <>
          <img className="glass-image-well__img" src={value} alt="Selected" />
          <div className="glass-image-well__overlay">
            <span className="glass-image-well__overlay-text">Change</span>
          </div>
        </>
      ) : (
        <div className="glass-image-well__empty">
          <svg className="glass-image-well__icon" viewBox="0 0 24 24" width="32" height="32" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
            <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
            <circle cx="8.5" cy="8.5" r="1.5" />
            <polyline points="21 15 16 10 5 21" />
          </svg>
          <span className="glass-image-well__label">Drop image here</span>
        </div>
      )}
    </div>
  );
}
