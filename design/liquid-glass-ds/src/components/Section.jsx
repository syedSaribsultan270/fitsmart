export function Section({ title, description, children }) {
  return (
    <section style={{ marginBottom: 48 }}>
      <h2 style={{ marginBottom: 8 }}>{title}</h2>
      {description && <p style={{ color: 'var(--label-secondary)', marginBottom: 24 }}>{description}</p>}
      {children}
    </section>
  )
}

/**
 * Preview container.
 * gradient={true} → grainy B&W gradient so glass effect is visible
 */
export function Preview({ children, style, gradient }) {
  if (!gradient) {
    return (
      <div style={{
        background: 'var(--glass-inner)',
        backdropFilter: 'blur(var(--blur-sm))',
        WebkitBackdropFilter: 'blur(var(--blur-sm))',
        border: '0.5px solid var(--glass-border)',
        borderRadius: 'var(--r-xl)',
        padding: 24,
        marginBottom: 16,
        ...style,
      }}>
        {children}
      </div>
    )
  }

  return (
    <div style={{
      borderRadius: 'var(--r-xl)',
      padding: 24,
      marginBottom: 16,
      position: 'relative',
      overflow: 'hidden',
      background: 'linear-gradient(135deg, #181818 0%, #2e2e2e 25%, #1a1a1a 50%, #333 75%, #1c1c1c 100%)',
      ...style,
    }}>
      {/* Grain texture via CSS background-image (no SVG id collisions) */}
      <div style={{
        position: 'absolute',
        inset: 0,
        opacity: 0.4,
        mixBlendMode: 'overlay',
        pointerEvents: 'none',
        backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='300' height='300'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='4' stitchTiles='stitch'/%3E%3CfeColorMatrix type='saturate' values='0'/%3E%3C/filter%3E%3Crect width='300' height='300' filter='url(%23n)'/%3E%3C/svg%3E")`,
      }} />
      {/* Subtle light pools */}
      <div style={{
        position: 'absolute',
        inset: 0,
        background: 'radial-gradient(ellipse at 25% 15%, rgba(255,255,255,0.07) 0%, transparent 55%), radial-gradient(ellipse at 75% 75%, rgba(255,255,255,0.04) 0%, transparent 45%)',
        pointerEvents: 'none',
      }} />
      <div style={{ position: 'relative', zIndex: 1 }}>
        {children}
      </div>
    </div>
  )
}
