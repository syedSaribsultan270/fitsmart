import { useState, useRef } from 'react'
import './Picker.css'


/* ================================================================
   Helper: month/day utilities
   ================================================================ */

const MONTHS = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const WEEKDAYS = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

function daysInMonth(year, month) {
  return new Date(year, month + 1, 0).getDate();
}

function firstDayOfMonth(year, month) {
  return new Date(year, month, 1).getDay();
}

function isSameDay(a, b) {
  return (
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate()
  );
}


/**
 * GlassDatePicker — Inline calendar picker with glass container.
 */
export function GlassDatePicker({ value, onChange, className = '' }) {
  const selected = value ? new Date(value + 'T00:00:00') : null;
  const today = new Date();

  const [viewYear, setViewYear] = useState(selected ? selected.getFullYear() : today.getFullYear());
  const [viewMonth, setViewMonth] = useState(selected ? selected.getMonth() : today.getMonth());

  const totalDays = daysInMonth(viewYear, viewMonth);
  const startDay = firstDayOfMonth(viewYear, viewMonth);

  const goPrev = () => {
    if (viewMonth === 0) {
      setViewMonth(11);
      setViewYear(viewYear - 1);
    } else {
      setViewMonth(viewMonth - 1);
    }
  };

  const goNext = () => {
    if (viewMonth === 11) {
      setViewMonth(0);
      setViewYear(viewYear + 1);
    } else {
      setViewMonth(viewMonth + 1);
    }
  };

  const handleDayClick = (day) => {
    const m = String(viewMonth + 1).padStart(2, '0');
    const d = String(day).padStart(2, '0');
    onChange?.(`${viewYear}-${m}-${d}`);
  };

  // Build grid cells: leading blanks + day numbers
  const cells = [];
  for (let i = 0; i < startDay; i++) {
    cells.push(<div key={`blank-${i}`} className="picker-date__cell picker-date__cell--blank" />);
  }
  for (let day = 1; day <= totalDays; day++) {
    const dateObj = new Date(viewYear, viewMonth, day);
    const isToday = isSameDay(dateObj, today);
    const isSelected = selected && isSameDay(dateObj, selected);

    cells.push(
      <button
        key={day}
        className={`picker-date__cell ${isToday ? 'picker-date__cell--today' : ''} ${isSelected ? 'picker-date__cell--selected' : ''}`}
        onClick={() => handleDayClick(day)}
      >
        {day}
      </button>
    );
  }

  return (
    <div className={`picker-date ${className}`}>
      <div className="picker-date__header">
        <button className="picker-date__nav" onClick={goPrev} aria-label="Previous month">
          <svg width="8" height="13" viewBox="0 0 8 13" fill="currentColor">
            <path d="M7.4 1.4 6 0 0 6.5 6 13l1.4-1.4L2.8 6.5z" />
          </svg>
        </button>
        <span className="picker-date__title">{MONTHS[viewMonth]} {viewYear}</span>
        <button className="picker-date__nav" onClick={goNext} aria-label="Next month">
          <svg width="8" height="13" viewBox="0 0 8 13" fill="currentColor">
            <path d="M.6 1.4 2 0l6 6.5L2 13 .6 11.6 5.2 6.5z" />
          </svg>
        </button>
      </div>
      <div className="picker-date__weekdays">
        {WEEKDAYS.map((wd) => (
          <div key={wd} className="picker-date__weekday">{wd}</div>
        ))}
      </div>
      <div className="picker-date__grid">
        {cells}
      </div>
    </div>
  );
}


/**
 * GlassTimePicker — Wheels-style time picker (visual mock).
 */
export function GlassTimePicker({ value = '10:30', onChange, className = '' }) {
  const [h, rawM] = value.split(':').map(Number);
  const hour12 = h === 0 ? 12 : h > 12 ? h - 12 : h;
  const period = h >= 12 ? 'PM' : 'AM';
  const minute = rawM;

  const hours = Array.from({ length: 12 }, (_, i) => i + 1);
  const minutes = Array.from({ length: 12 }, (_, i) => i * 5);
  const periods = ['AM', 'PM'];

  const selectHour = (hr) => {
    const h24 = period === 'AM' ? (hr === 12 ? 0 : hr) : (hr === 12 ? 12 : hr + 12);
    const m = String(minute).padStart(2, '0');
    onChange?.(`${String(h24).padStart(2, '0')}:${m}`);
  };

  const selectMinute = (min) => {
    const h24 = period === 'AM' ? (hour12 === 12 ? 0 : hour12) : (hour12 === 12 ? 12 : hour12 + 12);
    onChange?.(`${String(h24).padStart(2, '0')}:${String(min).padStart(2, '0')}`);
  };

  const selectPeriod = (p) => {
    let h24;
    if (p === 'AM') {
      h24 = hour12 === 12 ? 0 : hour12;
    } else {
      h24 = hour12 === 12 ? 12 : hour12 + 12;
    }
    onChange?.(`${String(h24).padStart(2, '0')}:${String(minute).padStart(2, '0')}`);
  };

  return (
    <div className={`picker-time ${className}`}>
      <div className="picker-time__highlight" />

      <div className="picker-time__column">
        {hours.map((hr) => (
          <button
            key={hr}
            className={`picker-time__item ${hr === hour12 ? 'picker-time__item--selected' : ''}`}
            onClick={() => selectHour(hr)}
          >
            {hr}
          </button>
        ))}
      </div>

      <div className="picker-time__column">
        {minutes.map((min) => (
          <button
            key={min}
            className={`picker-time__item ${min === minute ? 'picker-time__item--selected' : ''}`}
            onClick={() => selectMinute(min)}
          >
            {String(min).padStart(2, '0')}
          </button>
        ))}
      </div>

      <div className="picker-time__column picker-time__column--narrow">
        {periods.map((p) => (
          <button
            key={p}
            className={`picker-time__item ${p === period ? 'picker-time__item--selected' : ''}`}
            onClick={() => selectPeriod(p)}
          >
            {p}
          </button>
        ))}
      </div>
    </div>
  );
}


/**
 * GlassColorPicker — Spectrum + swatches color picker.
 */
const DEFAULT_SWATCHES = [
  '#FF3B30', '#FF9500', '#FFCC00', '#34C759',
  '#007AFF', '#5856D6', '#AF52DE', '#FF2D55',
];

export function GlassColorPicker({ value = '#007AFF', onChange, className = '' }) {
  const spectrumRef = useRef(null);
  const [dragging, setDragging] = useState(false);

  // Hue from hex (simplified)
  const hexToHue = (hex) => {
    const r = parseInt(hex.slice(1, 3), 16) / 255;
    const g = parseInt(hex.slice(3, 5), 16) / 255;
    const b = parseInt(hex.slice(5, 7), 16) / 255;
    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    const d = max - min;
    if (d === 0) return 0;
    let h;
    if (max === r) h = ((g - b) / d) % 6;
    else if (max === g) h = (b - r) / d + 2;
    else h = (r - g) / d + 4;
    h = Math.round(h * 60);
    if (h < 0) h += 360;
    return h;
  };

  const hueToHex = (hue) => {
    const h = hue / 60;
    const x = 1 - Math.abs(h % 2 - 1);
    let r = 0, g = 0, b = 0;
    if (h >= 0 && h < 1) { r = 1; g = x; }
    else if (h < 2) { r = x; g = 1; }
    else if (h < 3) { g = 1; b = x; }
    else if (h < 4) { g = x; b = 1; }
    else if (h < 5) { r = x; b = 1; }
    else { r = 1; b = x; }
    const toHex = (v) => Math.round(v * 255).toString(16).padStart(2, '0');
    return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
  };

  const currentHue = hexToHue(value);
  const huePercent = (currentHue / 360) * 100;

  const handleSpectrumClick = (e) => {
    const rect = spectrumRef.current.getBoundingClientRect();
    const x = Math.max(0, Math.min(e.clientX - rect.left, rect.width));
    const hue = Math.round((x / rect.width) * 360);
    onChange?.(hueToHex(hue));
  };

  const handleSpectrumPointerDown = (e) => {
    setDragging(true);
    handleSpectrumClick(e);
    const onMove = (ev) => handleSpectrumClick(ev);
    const onUp = () => {
      setDragging(false);
      window.removeEventListener('pointermove', onMove);
      window.removeEventListener('pointerup', onUp);
    };
    window.addEventListener('pointermove', onMove);
    window.addEventListener('pointerup', onUp);
  };

  const handleHexInput = (e) => {
    let hex = e.target.value;
    if (!hex.startsWith('#')) hex = '#' + hex;
    if (/^#[0-9A-Fa-f]{6}$/.test(hex)) {
      onChange?.(hex);
    }
  };

  return (
    <div className={`picker-color ${className}`}>
      {/* Spectrum bar */}
      <div
        className="picker-color__spectrum"
        ref={spectrumRef}
        onPointerDown={handleSpectrumPointerDown}
      >
        <div
          className={`picker-color__indicator ${dragging ? 'picker-color__indicator--active' : ''}`}
          style={{ left: `${huePercent}%` }}
        />
      </div>

      {/* Saturation/brightness square (simplified gradient) */}
      <div
        className="picker-color__saturation"
        style={{
          background: `linear-gradient(to bottom, transparent, #000), linear-gradient(to right, #fff, ${hueToHex(currentHue)})`,
        }}
      />

      {/* Swatches + preview + hex input */}
      <div className="picker-color__bottom">
        <div className="picker-color__swatches">
          {DEFAULT_SWATCHES.map((swatch) => (
            <button
              key={swatch}
              className={`picker-color__swatch ${swatch.toLowerCase() === value.toLowerCase() ? 'picker-color__swatch--selected' : ''}`}
              style={{ background: swatch }}
              onClick={() => onChange?.(swatch)}
              aria-label={`Color ${swatch}`}
            />
          ))}
        </div>
        <div className="picker-color__controls">
          <div className="picker-color__preview" style={{ background: value }} />
          <input
            className="picker-color__hex-input"
            type="text"
            value={value}
            onChange={handleHexInput}
            maxLength={7}
            spellCheck={false}
          />
        </div>
      </div>
    </div>
  );
}


/**
 * GlassOptionPicker — Wheel-style option picker (visual mock).
 */
export function GlassOptionPicker({ options = [], value, onChange, className = '' }) {
  const currentIndex = options.indexOf(value);
  const safeIndex = currentIndex === -1 ? 0 : currentIndex;

  // Show 2 items above and below the selected item
  const getVisibleItem = (offset) => {
    const idx = safeIndex + offset;
    if (idx < 0 || idx >= options.length) return null;
    return options[idx];
  };

  const opacityMap = { '-2': 0.15, '-1': 0.4, 0: 1, 1: 0.4, 2: 0.15 };
  const scaleMap = { '-2': 0.85, '-1': 0.92, 0: 1, 1: 0.92, 2: 0.85 };

  return (
    <div className={`picker-option ${className}`}>
      <div className="picker-option__highlight" />
      <div className="picker-option__items">
        {[-2, -1, 0, 1, 2].map((offset) => {
          const item = getVisibleItem(offset);
          if (item == null) return <div key={offset} className="picker-option__item picker-option__item--empty" />;
          return (
            <button
              key={offset}
              className={`picker-option__item ${offset === 0 ? 'picker-option__item--selected' : ''}`}
              style={{
                opacity: opacityMap[offset],
                transform: `scale(${scaleMap[offset]})`,
              }}
              onClick={() => onChange?.(item)}
            >
              {item}
            </button>
          );
        })}
      </div>
    </div>
  );
}
