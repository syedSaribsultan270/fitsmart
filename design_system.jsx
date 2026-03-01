import { useState } from "react";

const SECTIONS = [
  "Overview",
  "Colors",
  "Typography",
  "Spacing",
  "Components",
  "Icons & States",
  "Firebase & Security",
  "Architecture",
];

// ─── Design Tokens ───
const tokens = {
  colors: {
    brand: {
      lime: "#BDFF3A",
      limeMuted: "#9AD42A",
      limeGlow: "rgba(189,255,58,0.15)",
      coral: "#FF6B6B",
      coralMuted: "#E85555",
      cyan: "#3ADFFF",
      cyanMuted: "#2BB8D4",
    },
    bg: {
      primary: "#0A0A0C",
      secondary: "#111114",
      tertiary: "#18181C",
      elevated: "#1F1F24",
      overlay: "rgba(10,10,12,0.85)",
    },
    surface: {
      card: "#16161A",
      cardHover: "#1C1C21",
      cardBorder: "#2A2A30",
      input: "#111114",
      inputBorder: "#2A2A30",
      inputFocus: "#BDFF3A",
    },
    text: {
      primary: "#F0F0F2",
      secondary: "#A0A0A8",
      tertiary: "#6B6B75",
      inverse: "#0A0A0C",
      link: "#3ADFFF",
    },
    semantic: {
      success: "#34D399",
      warning: "#FBBF24",
      error: "#F87171",
      info: "#60A5FA",
      successBg: "rgba(52,211,153,0.12)",
      warningBg: "rgba(251,191,36,0.12)",
      errorBg: "rgba(248,113,113,0.12)",
      infoBg: "rgba(96,165,250,0.12)",
    },
    macro: {
      protein: "#3ADFFF",
      carbs: "#BDFF3A",
      fat: "#FF6B6B",
      fiber: "#A78BFA",
      calories: "#FBBF24",
    },
  },
  spacing: [0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96, 128],
  radius: { none: 0, sm: 6, md: 10, lg: 14, xl: 20, full: 9999 },
  typography: {
    display: { size: 40, weight: 800, height: 1.1, tracking: -1.5 },
    h1: { size: 32, weight: 700, height: 1.2, tracking: -0.8 },
    h2: { size: 24, weight: 700, height: 1.25, tracking: -0.5 },
    h3: { size: 20, weight: 600, height: 1.3, tracking: -0.3 },
    body: { size: 15, weight: 400, height: 1.55, tracking: 0 },
    bodyMedium: { size: 15, weight: 500, height: 1.55, tracking: 0 },
    caption: { size: 13, weight: 500, height: 1.4, tracking: 0.2 },
    overline: { size: 11, weight: 700, height: 1.3, tracking: 1.5 },
    mono: { size: 13, weight: 500, height: 1.5, tracking: 0 },
  },
};

// ─── Reusable Styles ───
const pill = (active) => ({
  padding: "7px 16px",
  borderRadius: 9999,
  fontSize: 13,
  fontWeight: 600,
  cursor: "pointer",
  border: "1.5px solid",
  borderColor: active ? tokens.colors.brand.lime : tokens.colors.surface.cardBorder,
  background: active ? tokens.colors.brand.lime : "transparent",
  color: active ? tokens.colors.bg.primary : tokens.colors.text.secondary,
  transition: "all 0.2s",
  whiteSpace: "nowrap",
  letterSpacing: 0.3,
});

const sectionTitle = {
  fontSize: 28,
  fontWeight: 700,
  color: tokens.colors.text.primary,
  letterSpacing: -0.5,
  marginBottom: 8,
};

const sectionSub = {
  fontSize: 14,
  color: tokens.colors.text.tertiary,
  lineHeight: 1.6,
  marginBottom: 32,
  maxWidth: 600,
};

const cardBase = {
  background: tokens.colors.surface.card,
  border: `1px solid ${tokens.colors.surface.cardBorder}`,
  borderRadius: tokens.radius.lg,
  padding: 20,
};

const labelStyle = {
  fontSize: 11,
  fontWeight: 700,
  color: tokens.colors.text.tertiary,
  letterSpacing: 1.5,
  textTransform: "uppercase",
  marginBottom: 12,
};

const codeBlock = {
  background: tokens.colors.bg.secondary,
  border: `1px solid ${tokens.colors.surface.cardBorder}`,
  borderRadius: tokens.radius.md,
  padding: 16,
  fontFamily: "'JetBrains Mono', 'Fira Code', monospace",
  fontSize: 12,
  color: tokens.colors.text.secondary,
  lineHeight: 1.7,
  overflowX: "auto",
  whiteSpace: "pre",
};

// ─── Color Swatch Component ───
function Swatch({ name, hex, large, label }) {
  const isLight = ["#BDFF3A", "#FBBF24", "#F0F0F2", "#34D399", "#3ADFFF"].includes(hex);
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 6, minWidth: large ? 100 : 72 }}>
      <div
        style={{
          width: "100%",
          height: large ? 56 : 40,
          borderRadius: tokens.radius.md,
          background: hex,
          border: `1px solid ${hex === tokens.colors.bg.primary ? tokens.colors.surface.cardBorder : "transparent"}`,
          display: "flex",
          alignItems: "flex-end",
          padding: "0 6px 4px",
        }}
      >
        <span style={{ fontSize: 9, fontWeight: 600, color: isLight ? "#0A0A0C" : "#fff", opacity: 0.7 }}>
          {hex}
        </span>
      </div>
      <span style={{ fontSize: 11, fontWeight: 500, color: tokens.colors.text.secondary }}>{label || name}</span>
    </div>
  );
}

// ─── Section: Overview ───
function Overview() {
  return (
    <div>
      <h2 style={sectionTitle}>Design System Overview</h2>
      <p style={sectionSub}>
        A dark-first, performance-oriented design system built for FitGenius AI. Inspired by
        Higgsfield's bold neon-on-dark aesthetic and PostHog's structured component architecture.
      </p>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16, marginBottom: 32 }}>
        {[
          { title: "Dark-First", desc: "OLED-optimized blacks with high-contrast vibrant accents. Every surface is intentionally layered.", icon: "🌑" },
          { title: "Macro-Coded Colors", desc: "Protein=Cyan, Carbs=Lime, Fat=Coral. Consistent across all charts, cards, and badges.", icon: "🎨" },
          { title: "Component Tokens", desc: "Every value is tokenized. Colors, spacing, radii, and typography scale from a single source of truth.", icon: "🔧" },
          { title: "Security-Native", desc: "Firebase Auth + Firestore rules + client-side encryption baked into the architecture from day one.", icon: "🔒" },
        ].map((item) => (
          <div key={item.title} style={{ ...cardBase, display: "flex", gap: 14, alignItems: "flex-start" }}>
            <span style={{ fontSize: 24 }}>{item.icon}</span>
            <div>
              <div style={{ fontSize: 15, fontWeight: 600, color: tokens.colors.text.primary, marginBottom: 4 }}>
                {item.title}
              </div>
              <div style={{ fontSize: 13, color: tokens.colors.text.tertiary, lineHeight: 1.5 }}>{item.desc}</div>
            </div>
          </div>
        ))}
      </div>

      <div style={labelStyle}>Design Principles</div>
      <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
        {[
          ["Hierarchy through luminance", "Surfaces layer from #0A0A0C → #111114 → #18181C → #1F1F24. Information importance maps to brightness."],
          ["Color is functional, not decorative", "Every color communicates meaning: macros, status, or action. No color is used without purpose."],
          ["Touch targets ≥ 48dp", "Every interactive element meets accessibility guidelines. Generous padding, clear hit areas."],
          ["Progressive disclosure", "Show the summary first, details on demand. Dashboard → Detail → Raw Data."],
          ["Offline-first visual feedback", "Skeleton loaders, optimistic updates, and queued-state indicators for AI features."],
        ].map(([title, desc], i) => (
          <div key={i} style={{ display: "flex", gap: 12, padding: "12px 16px", borderRadius: tokens.radius.md, background: tokens.colors.bg.tertiary }}>
            <span style={{ color: tokens.colors.brand.lime, fontWeight: 700, fontSize: 14, minWidth: 20 }}>{String(i + 1).padStart(2, "0")}</span>
            <div>
              <span style={{ fontSize: 14, fontWeight: 600, color: tokens.colors.text.primary }}>{title}</span>
              <span style={{ fontSize: 13, color: tokens.colors.text.tertiary, marginLeft: 8 }}>{desc}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Section: Colors ───
function Colors() {
  return (
    <div>
      <h2 style={sectionTitle}>Color System</h2>
      <p style={sectionSub}>
        Five color groups: Brand, Background layers, Surface, Text, and Semantic. Plus a dedicated
        macro-nutrient palette used consistently across all data visualizations.
      </p>

      <div style={labelStyle}>Brand Palette</div>
      <div style={{ display: "flex", gap: 12, flexWrap: "wrap", marginBottom: 28 }}>
        <Swatch name="Lime" hex="#BDFF3A" large label="lime (primary)" />
        <Swatch name="LimeMuted" hex="#9AD42A" large label="lime.muted" />
        <Swatch name="Coral" hex="#FF6B6B" large label="coral" />
        <Swatch name="CoralMuted" hex="#E85555" large label="coral.muted" />
        <Swatch name="Cyan" hex="#3ADFFF" large label="cyan" />
        <Swatch name="CyanMuted" hex="#2BB8D4" large label="cyan.muted" />
      </div>

      <div style={labelStyle}>Background Layers (Depth Stack)</div>
      <div style={{ display: "flex", gap: 8, marginBottom: 28 }}>
        {[
          ["primary", "#0A0A0C"],
          ["secondary", "#111114"],
          ["tertiary", "#18181C"],
          ["elevated", "#1F1F24"],
        ].map(([n, h]) => (
          <div key={n} style={{ flex: 1 }}>
            <div style={{ height: 48, borderRadius: tokens.radius.md, background: h, border: `1px solid ${tokens.colors.surface.cardBorder}`, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <span style={{ fontSize: 10, color: tokens.colors.text.tertiary, fontFamily: "monospace" }}>{h}</span>
            </div>
            <span style={{ fontSize: 11, color: tokens.colors.text.tertiary, marginTop: 4, display: "block" }}>bg.{n}</span>
          </div>
        ))}
      </div>

      <div style={labelStyle}>Macro Nutrient Colors</div>
      <p style={{ fontSize: 13, color: tokens.colors.text.secondary, marginBottom: 16, lineHeight: 1.5 }}>
        These are used in every chart, progress ring, card badge, and data visualization. They never change meaning.
      </p>
      <div style={{ display: "flex", gap: 12, marginBottom: 28 }}>
        {[
          ["Protein", "#3ADFFF", "P"],
          ["Carbs", "#BDFF3A", "C"],
          ["Fat", "#FF6B6B", "F"],
          ["Fiber", "#A78BFA", "Fi"],
          ["Calories", "#FBBF24", "Cal"],
        ].map(([name, hex, abbr]) => (
          <div key={name} style={{ ...cardBase, flex: 1, textAlign: "center", padding: 14 }}>
            <div style={{ width: 36, height: 36, borderRadius: "50%", background: hex, margin: "0 auto 8px", display: "flex", alignItems: "center", justifyContent: "center" }}>
              <span style={{ fontSize: 11, fontWeight: 800, color: "#0A0A0C" }}>{abbr}</span>
            </div>
            <div style={{ fontSize: 13, fontWeight: 600, color: tokens.colors.text.primary }}>{name}</div>
            <div style={{ fontSize: 11, color: tokens.colors.text.tertiary, fontFamily: "monospace" }}>{hex}</div>
          </div>
        ))}
      </div>

      <div style={labelStyle}>Semantic States</div>
      <div style={{ display: "flex", gap: 12, marginBottom: 28 }}>
        {[
          ["Success", "#34D399", "rgba(52,211,153,0.12)", "Goal met, PR achieved"],
          ["Warning", "#FBBF24", "rgba(251,191,36,0.12)", "Approaching limit"],
          ["Error", "#F87171", "rgba(248,113,113,0.12)", "Over target, failed"],
          ["Info", "#60A5FA", "rgba(96,165,250,0.12)", "Neutral tip, AI insight"],
        ].map(([name, fg, bg, desc]) => (
          <div key={name} style={{ flex: 1, padding: 14, borderRadius: tokens.radius.md, background: bg, border: `1px solid ${fg}22` }}>
            <div style={{ width: 10, height: 10, borderRadius: "50%", background: fg, marginBottom: 8 }} />
            <div style={{ fontSize: 13, fontWeight: 600, color: fg }}>{name}</div>
            <div style={{ fontSize: 11, color: tokens.colors.text.tertiary, marginTop: 2 }}>{desc}</div>
          </div>
        ))}
      </div>

      <div style={labelStyle}>Dart Token Usage</div>
      <pre style={codeBlock}>{`abstract class AppColors {
  // Brand
  static const lime       = Color(0xFFBDFF3A);
  static const limeMuted  = Color(0xFF9AD42A);
  static const coral      = Color(0xFFFF6B6B);
  static const cyan       = Color(0xFF3ADFFF);
  
  // Backgrounds (depth stack)
  static const bgPrimary   = Color(0xFF0A0A0C);
  static const bgSecondary = Color(0xFF111114);
  static const bgTertiary  = Color(0xFF18181C);
  static const bgElevated  = Color(0xFF1F1F24);
  
  // Macro nutrients (never reassign)
  static const protein  = Color(0xFF3ADFFF);
  static const carbs    = Color(0xFFBDFF3A);
  static const fat      = Color(0xFFFF6B6B);
  static const fiber    = Color(0xFFA78BFA);
  static const calories = Color(0xFFFBBF24);
}`}</pre>
    </div>
  );
}

// ─── Section: Typography ───
function Typography() {
  const rows = [
    ["Display", "Satoshi", 40, 800, -1.5, "1.1", "App title, hero stats"],
    ["H1", "Satoshi", 32, 700, -0.8, "1.2", "Screen titles"],
    ["H2", "Satoshi", 24, 700, -0.5, "1.25", "Section headers"],
    ["H3", "Satoshi", 20, 600, -0.3, "1.3", "Card titles, labels"],
    ["Body", "Satoshi", 15, 400, 0, "1.55", "Default text"],
    ["Body Medium", "Satoshi", 15, 500, 0, "1.55", "Emphasized body"],
    ["Caption", "Satoshi", 13, 500, 0.2, "1.4", "Timestamps, metadata"],
    ["Overline", "Satoshi", 11, 700, 1.5, "1.3", "Labels, section dividers"],
    ["Mono", "JetBrains Mono", 13, 500, 0, "1.5", "Stats, numbers, code"],
  ];

  return (
    <div>
      <h2 style={sectionTitle}>Typography</h2>
      <p style={sectionSub}>
        Satoshi as the primary typeface — geometric, modern, with excellent legibility at small sizes.
        JetBrains Mono for all numerical/data displays.
      </p>

      <div style={{ display: "flex", flexDirection: "column", gap: 2, marginBottom: 32 }}>
        <div style={{ display: "grid", gridTemplateColumns: "100px 120px 50px 50px 50px 40px 1fr", gap: 12, padding: "8px 12px", borderRadius: tokens.radius.sm, background: tokens.colors.bg.tertiary }}>
          {["Style", "Font", "Size", "Wt", "Track", "LH", "Usage"].map((h) => (
            <span key={h} style={{ fontSize: 10, fontWeight: 700, color: tokens.colors.text.tertiary, textTransform: "uppercase", letterSpacing: 1 }}>{h}</span>
          ))}
        </div>
        {rows.map(([style, font, size, weight, tracking, lh, usage], i) => (
          <div key={style} style={{ display: "grid", gridTemplateColumns: "100px 120px 50px 50px 50px 40px 1fr", gap: 12, padding: "10px 12px", borderBottom: `1px solid ${tokens.colors.surface.cardBorder}` }}>
            <span style={{ fontSize: 13, fontWeight: 600, color: tokens.colors.brand.lime }}>{style}</span>
            <span style={{ fontSize: 12, color: tokens.colors.text.secondary, fontFamily: "monospace" }}>{font}</span>
            <span style={{ fontSize: 12, color: tokens.colors.text.secondary }}>{size}px</span>
            <span style={{ fontSize: 12, color: tokens.colors.text.secondary }}>{weight}</span>
            <span style={{ fontSize: 12, color: tokens.colors.text.secondary }}>{tracking}</span>
            <span style={{ fontSize: 12, color: tokens.colors.text.secondary }}>{lh}</span>
            <span style={{ fontSize: 12, color: tokens.colors.text.tertiary }}>{usage}</span>
          </div>
        ))}
      </div>

      <div style={labelStyle}>Type Scale Preview</div>
      <div style={{ ...cardBase, display: "flex", flexDirection: "column", gap: 16, marginBottom: 28 }}>
        <span style={{ fontSize: 40, fontWeight: 800, color: tokens.colors.text.primary, letterSpacing: -1.5, lineHeight: 1.1 }}>2,347 kcal</span>
        <span style={{ fontSize: 32, fontWeight: 700, color: tokens.colors.text.primary, letterSpacing: -0.8 }}>Today's Summary</span>
        <span style={{ fontSize: 24, fontWeight: 700, color: tokens.colors.text.primary, letterSpacing: -0.5 }}>Nutrition Breakdown</span>
        <span style={{ fontSize: 20, fontWeight: 600, color: tokens.colors.text.primary, letterSpacing: -0.3 }}>Meal Analysis Result</span>
        <span style={{ fontSize: 15, color: tokens.colors.text.secondary, lineHeight: 1.55 }}>You've consumed 68% of your daily protein target. Consider adding a high-protein snack before your evening workout.</span>
        <span style={{ fontSize: 13, fontWeight: 500, color: tokens.colors.text.tertiary }}>Logged 2 hours ago · AI Confidence: 94%</span>
        <span style={{ fontSize: 11, fontWeight: 700, color: tokens.colors.text.tertiary, letterSpacing: 1.5, textTransform: "uppercase" }}>Macro Breakdown</span>
        <span style={{ fontSize: 13, fontFamily: "'JetBrains Mono', monospace", color: tokens.colors.brand.lime }}>P: 142g · C: 210g · F: 58g</span>
      </div>

      <div style={labelStyle}>Dart Implementation</div>
      <pre style={codeBlock}>{`abstract class AppTypography {
  static const _satoshi = 'Satoshi';
  static const _mono    = 'JetBrains Mono';

  static final display = TextStyle(
    fontFamily: _satoshi, fontSize: 40, fontWeight: FontWeight.w800,
    height: 1.1, letterSpacing: -1.5, color: AppColors.textPrimary,
  );
  static final h1 = TextStyle(
    fontFamily: _satoshi, fontSize: 32, fontWeight: FontWeight.w700,
    height: 1.2, letterSpacing: -0.8, color: AppColors.textPrimary,
  );
  // ... h2, h3, body, bodyMedium, caption, overline
  static final mono = TextStyle(
    fontFamily: _mono, fontSize: 13, fontWeight: FontWeight.w500,
    height: 1.5, color: AppColors.lime,
  );
}`}</pre>
    </div>
  );
}

// ─── Section: Spacing ───
function Spacing() {
  const scale = [
    [0, "none", "—"],
    [2, "xxs", "Hairline borders"],
    [4, "xs", "Icon-to-text gap"],
    [8, "sm", "Tight element spacing"],
    [12, "md", "Default inner padding"],
    [16, "lg", "Card inner padding"],
    [20, "xl", "Section gaps"],
    [24, "2xl", "Between cards"],
    [32, "3xl", "Section spacing"],
    [48, "4xl", "Major section breaks"],
    [64, "5xl", "Screen-level padding"],
  ];

  return (
    <div>
      <h2 style={sectionTitle}>Spacing & Layout</h2>
      <p style={sectionSub}>
        A base-4 spacing scale ensuring consistent rhythm. All spacing values are multiples of 4dp.
      </p>

      <div style={labelStyle}>Spacing Scale</div>
      <div style={{ display: "flex", flexDirection: "column", gap: 3, marginBottom: 32 }}>
        {scale.map(([px, name, usage]) => (
          <div key={name} style={{ display: "flex", alignItems: "center", gap: 16, padding: "6px 0" }}>
            <span style={{ fontSize: 12, fontWeight: 600, color: tokens.colors.brand.lime, minWidth: 36, textAlign: "right", fontFamily: "monospace" }}>{px}dp</span>
            <div style={{ width: Math.max(px * 2.5, 4), height: 14, borderRadius: 3, background: `${tokens.colors.brand.lime}${px === 0 ? "20" : ""}`, opacity: 0.2 + (px / 80) }} />
            <span style={{ fontSize: 12, fontWeight: 600, color: tokens.colors.text.primary, minWidth: 40 }}>{name}</span>
            <span style={{ fontSize: 12, color: tokens.colors.text.tertiary }}>{usage}</span>
          </div>
        ))}
      </div>

      <div style={labelStyle}>Border Radius Tokens</div>
      <div style={{ display: "flex", gap: 16, marginBottom: 32 }}>
        {[
          ["none", 0],
          ["sm", 6],
          ["md", 10],
          ["lg", 14],
          ["xl", 20],
          ["full", 9999],
        ].map(([name, r]) => (
          <div key={name} style={{ textAlign: "center" }}>
            <div style={{ width: 48, height: 48, borderRadius: Math.min(r, 24), border: `2px solid ${tokens.colors.brand.lime}40`, background: tokens.colors.bg.tertiary, marginBottom: 6 }} />
            <div style={{ fontSize: 11, fontWeight: 600, color: tokens.colors.text.primary }}>{name}</div>
            <div style={{ fontSize: 10, color: tokens.colors.text.tertiary, fontFamily: "monospace" }}>{r}dp</div>
          </div>
        ))}
      </div>

      <div style={labelStyle}>Layout Grid</div>
      <div style={{ ...cardBase, marginBottom: 28 }}>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginBottom: 12 }}>
          {[
            ["Screen Padding", "20dp horizontal"],
            ["Card Padding", "16dp all sides"],
            ["Card Gap", "12dp between cards"],
            ["Section Gap", "32dp between sections"],
            ["Bottom Nav Height", "64dp + safe area"],
            ["FAB Position", "20dp from edges"],
          ].map(([k, v]) => (
            <div key={k} style={{ display: "flex", justifyContent: "space-between", padding: "8px 12px", borderRadius: tokens.radius.sm, background: tokens.colors.bg.tertiary }}>
              <span style={{ fontSize: 12, color: tokens.colors.text.secondary }}>{k}</span>
              <span style={{ fontSize: 12, fontWeight: 600, color: tokens.colors.brand.lime, fontFamily: "monospace" }}>{v}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── Section: Components ───
function Components() {
  const [btnHover, setBtnHover] = useState(null);

  return (
    <div>
      <h2 style={sectionTitle}>Component Library</h2>
      <p style={sectionSub}>
        Modular, token-based components. Every component supports dark mode natively and
        follows the 48dp minimum touch target rule.
      </p>

      {/* Buttons */}
      <div style={labelStyle}>Buttons</div>
      <div style={{ display: "flex", gap: 12, marginBottom: 24, flexWrap: "wrap", alignItems: "center" }}>
        {[
          { label: "Log Meal", variant: "primary", bg: tokens.colors.brand.lime, color: "#0A0A0C", border: "none" },
          { label: "View Plan", variant: "secondary", bg: "transparent", color: tokens.colors.brand.lime, border: `1.5px solid ${tokens.colors.brand.lime}` },
          { label: "Cancel", variant: "ghost", bg: "transparent", color: tokens.colors.text.secondary, border: `1.5px solid ${tokens.colors.surface.cardBorder}` },
          { label: "Delete", variant: "danger", bg: tokens.colors.semantic.errorBg, color: tokens.colors.semantic.error, border: `1.5px solid ${tokens.colors.semantic.error}33` },
        ].map((btn) => (
          <button
            key={btn.variant}
            onMouseEnter={() => setBtnHover(btn.variant)}
            onMouseLeave={() => setBtnHover(null)}
            style={{
              padding: "12px 24px",
              borderRadius: tokens.radius.md,
              fontSize: 14,
              fontWeight: 600,
              cursor: "pointer",
              background: btn.bg,
              color: btn.color,
              border: btn.border,
              transform: btnHover === btn.variant ? "translateY(-1px)" : "none",
              boxShadow: btnHover === btn.variant && btn.variant === "primary" ? `0 4px 20px ${tokens.colors.brand.limeGlow}` : "none",
              transition: "all 0.2s",
            }}
          >
            {btn.label}
          </button>
        ))}
        <button style={{ width: 48, height: 48, borderRadius: "50%", background: tokens.colors.brand.lime, border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 22, color: "#0A0A0C", fontWeight: 700 }}>+</button>
      </div>

      {/* Cards */}
      <div style={labelStyle}>Cards</div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginBottom: 24 }}>
        {/* Meal Card */}
        <div style={{ ...cardBase }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
            <span style={{ fontSize: 11, fontWeight: 700, color: tokens.colors.text.tertiary, textTransform: "uppercase", letterSpacing: 1 }}>Lunch</span>
            <span style={{ fontSize: 11, color: tokens.colors.semantic.success, fontWeight: 600, padding: "2px 8px", borderRadius: 9999, background: tokens.colors.semantic.successBg }}>Logged</span>
          </div>
          <div style={{ fontSize: 16, fontWeight: 600, color: tokens.colors.text.primary, marginBottom: 4 }}>Grilled Chicken Bowl</div>
          <div style={{ fontSize: 13, color: tokens.colors.text.tertiary, marginBottom: 14 }}>Rice, grilled chicken, mixed veggies</div>
          <div style={{ display: "flex", gap: 16 }}>
            {[
              ["P", "38g", tokens.colors.macro.protein],
              ["C", "62g", tokens.colors.macro.carbs],
              ["F", "14g", tokens.colors.macro.fat],
            ].map(([l, v, c]) => (
              <div key={l} style={{ display: "flex", alignItems: "center", gap: 4 }}>
                <div style={{ width: 6, height: 6, borderRadius: "50%", background: c }} />
                <span style={{ fontSize: 12, fontFamily: "monospace", fontWeight: 600, color: c }}>{v}</span>
              </div>
            ))}
            <span style={{ fontSize: 13, fontWeight: 700, color: tokens.colors.macro.calories, marginLeft: "auto", fontFamily: "monospace" }}>520 kcal</span>
          </div>
        </div>

        {/* Workout Card */}
        <div style={{ ...cardBase }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
            <span style={{ fontSize: 11, fontWeight: 700, color: tokens.colors.text.tertiary, textTransform: "uppercase", letterSpacing: 1 }}>Today's Workout</span>
            <span style={{ fontSize: 11, color: tokens.colors.brand.cyan, fontWeight: 600, padding: "2px 8px", borderRadius: 9999, background: "rgba(58,223,255,0.12)" }}>Scheduled</span>
          </div>
          <div style={{ fontSize: 16, fontWeight: 600, color: tokens.colors.text.primary, marginBottom: 4 }}>Upper Body Push</div>
          <div style={{ fontSize: 13, color: tokens.colors.text.tertiary, marginBottom: 14 }}>Chest, Shoulders, Triceps · 5 exercises</div>
          <div style={{ display: "flex", gap: 12, alignItems: "center" }}>
            <span style={{ fontSize: 12, color: tokens.colors.text.secondary }}>~45 min</span>
            <span style={{ fontSize: 12, color: tokens.colors.text.tertiary }}>·</span>
            <span style={{ fontSize: 12, color: tokens.colors.text.secondary }}>Intermediate</span>
            <button style={{ marginLeft: "auto", padding: "6px 14px", borderRadius: tokens.radius.sm, background: tokens.colors.brand.lime, color: "#0A0A0C", border: "none", fontSize: 12, fontWeight: 700, cursor: "pointer" }}>Start</button>
          </div>
        </div>
      </div>

      {/* Progress Ring */}
      <div style={labelStyle}>Progress Ring (Calorie Tracker)</div>
      <div style={{ ...cardBase, display: "flex", alignItems: "center", gap: 24, marginBottom: 24 }}>
        <svg width="100" height="100" viewBox="0 0 100 100">
          <circle cx="50" cy="50" r="42" fill="none" stroke={tokens.colors.bg.tertiary} strokeWidth="8" />
          <circle cx="50" cy="50" r="42" fill="none" stroke={tokens.colors.macro.calories} strokeWidth="8" strokeDasharray={`${2 * Math.PI * 42 * 0.68} ${2 * Math.PI * 42}`} strokeLinecap="round" transform="rotate(-90 50 50)" style={{ transition: "stroke-dasharray 1s ease" }} />
          <text x="50" y="44" textAnchor="middle" fill={tokens.colors.text.primary} fontSize="18" fontWeight="800" fontFamily="monospace">68%</text>
          <text x="50" y="60" textAnchor="middle" fill={tokens.colors.text.tertiary} fontSize="9" fontWeight="600">1,428 / 2,100</text>
        </svg>
        <div style={{ display: "flex", flexDirection: "column", gap: 8, flex: 1 }}>
          {[
            ["Protein", 142, 180, tokens.colors.macro.protein],
            ["Carbs", 165, 210, tokens.colors.macro.carbs],
            ["Fat", 42, 70, tokens.colors.macro.fat],
          ].map(([name, cur, target, color]) => (
            <div key={name}>
              <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 4 }}>
                <span style={{ fontSize: 12, fontWeight: 500, color: tokens.colors.text.secondary }}>{name}</span>
                <span style={{ fontSize: 12, fontFamily: "monospace", fontWeight: 600, color }}>{cur}g / {target}g</span>
              </div>
              <div style={{ height: 6, borderRadius: 3, background: tokens.colors.bg.tertiary }}>
                <div style={{ height: "100%", borderRadius: 3, background: color, width: `${(cur / target) * 100}%`, transition: "width 0.8s ease" }} />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Input Fields */}
      <div style={labelStyle}>Inputs & Controls</div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginBottom: 24 }}>
        <div>
          <div style={{ fontSize: 12, fontWeight: 600, color: tokens.colors.text.secondary, marginBottom: 6 }}>Search Food</div>
          <div style={{ display: "flex", alignItems: "center", padding: "12px 14px", borderRadius: tokens.radius.md, background: tokens.colors.surface.input, border: `1.5px solid ${tokens.colors.surface.inputBorder}`, gap: 8 }}>
            <span style={{ color: tokens.colors.text.tertiary }}>🔍</span>
            <span style={{ fontSize: 14, color: tokens.colors.text.tertiary }}>Search foods or scan barcode...</span>
          </div>
        </div>
        <div>
          <div style={{ fontSize: 12, fontWeight: 600, color: tokens.colors.text.secondary, marginBottom: 6 }}>Quantity</div>
          <div style={{ display: "flex", alignItems: "center", padding: "12px 14px", borderRadius: tokens.radius.md, background: tokens.colors.surface.input, border: `1.5px solid ${tokens.colors.brand.lime}`, gap: 8, boxShadow: `0 0 0 3px ${tokens.colors.brand.limeGlow}` }}>
            <span style={{ fontSize: 14, color: tokens.colors.text.primary, fontWeight: 500 }}>150</span>
            <span style={{ fontSize: 13, color: tokens.colors.text.tertiary, marginLeft: "auto", fontWeight: 500 }}>grams</span>
          </div>
        </div>
      </div>

      {/* Chips/Tags */}
      <div style={labelStyle}>Chips & Tags</div>
      <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 24 }}>
        {["Halal", "High Protein", "Low Carb", "Dairy Free", "Under 30 min"].map((tag, i) => (
          <span key={tag} style={{ padding: "6px 14px", borderRadius: 9999, fontSize: 12, fontWeight: 600, background: i < 2 ? tokens.colors.brand.limeGlow : tokens.colors.bg.tertiary, color: i < 2 ? tokens.colors.brand.lime : tokens.colors.text.secondary, border: `1px solid ${i < 2 ? tokens.colors.brand.lime + "33" : tokens.colors.surface.cardBorder}` }}>{tag}</span>
        ))}
      </div>

      {/* Bottom Nav */}
      <div style={labelStyle}>Bottom Navigation</div>
      <div style={{ borderRadius: tokens.radius.lg, overflow: "hidden", background: tokens.colors.bg.secondary, border: `1px solid ${tokens.colors.surface.cardBorder}`, padding: "10px 0" }}>
        <div style={{ display: "flex", justifyContent: "space-around" }}>
          {[
            ["Home", true],
            ["Nutrition", false],
            ["", false],
            ["Workout", false],
            ["Coach", false],
          ].map(([label, active], i) =>
            i === 2 ? (
              <div key="fab" style={{ width: 48, height: 48, borderRadius: "50%", background: tokens.colors.brand.lime, display: "flex", alignItems: "center", justifyContent: "center", marginTop: -20, boxShadow: `0 4px 16px ${tokens.colors.brand.limeGlow}` }}>
                <span style={{ fontSize: 24, fontWeight: 700, color: "#0A0A0C", lineHeight: 1 }}>+</span>
              </div>
            ) : (
              <div key={label} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 3 }}>
                <div style={{ width: 22, height: 22, borderRadius: 6, background: active ? tokens.colors.brand.lime + "20" : "transparent" }} />
                <span style={{ fontSize: 10, fontWeight: active ? 700 : 500, color: active ? tokens.colors.brand.lime : tokens.colors.text.tertiary }}>{label}</span>
              </div>
            )
          )}
        </div>
      </div>
    </div>
  );
}

// ─── Section: Icons & States ───
function IconsStates() {
  return (
    <div>
      <h2 style={sectionTitle}>Icons, States & Feedback</h2>
      <p style={sectionSub}>
        Phosphor Icons (light weight, 24dp) as the icon set. Consistent state patterns for loading,
        empty, error, and AI-processing states.
      </p>

      <div style={labelStyle}>Icon Specifications</div>
      <div style={{ ...cardBase, marginBottom: 24 }}>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
          {[
            ["Icon Set", "Phosphor Icons (light weight)"],
            ["Default Size", "24dp (touchable: 48dp hit area)"],
            ["Active Color", tokens.colors.brand.lime],
            ["Inactive Color", tokens.colors.text.tertiary],
            ["Stroke Width", "1.5px"],
            ["Tab Bar Icons", "24dp with 4dp label gap"],
          ].map(([k, v]) => (
            <div key={k} style={{ display: "flex", justifyContent: "space-between", padding: "8px 12px", borderRadius: tokens.radius.sm, background: tokens.colors.bg.tertiary }}>
              <span style={{ fontSize: 12, color: tokens.colors.text.secondary }}>{k}</span>
              <span style={{ fontSize: 12, fontWeight: 600, color: tokens.colors.text.primary, fontFamily: v.startsWith("#") ? "monospace" : "inherit" }}>{v}</span>
            </div>
          ))}
        </div>
      </div>

      <div style={labelStyle}>Loading States</div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 12, marginBottom: 24 }}>
        {[
          ["Skeleton", "Data loading", "Pulse animation on bg.tertiary shapes mimicking content layout"],
          ["AI Processing", "Gemini in-flight", "Lime shimmer wave + \"Analyzing...\" text + brain icon"],
          ["Inline Spinner", "Button/action", "16dp spinning ring in button color, replaces label"],
        ].map(([name, trigger, spec]) => (
          <div key={name} style={{ ...cardBase, padding: 16 }}>
            <div style={{ fontSize: 13, fontWeight: 600, color: tokens.colors.brand.lime, marginBottom: 4 }}>{name}</div>
            <div style={{ fontSize: 11, fontWeight: 600, color: tokens.colors.text.secondary, marginBottom: 6 }}>{trigger}</div>
            <div style={{ fontSize: 11, color: tokens.colors.text.tertiary, lineHeight: 1.5 }}>{spec}</div>
          </div>
        ))}
      </div>

      <div style={labelStyle}>Empty & Error States</div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginBottom: 24 }}>
        {[
          ["No Meals Logged", "Illustration + \"Your plate is empty\" + CTA button \"Log your first meal\"", tokens.colors.text.tertiary],
          ["AI Unavailable", "Cloud-off icon + \"AI coach is resting\" + \"Using local estimates\" + subtle retry", tokens.colors.semantic.warning],
          ["Network Error", "Wifi-off icon + \"You're offline\" + \"Your data is saved locally\" + auto-retry indicator", tokens.colors.semantic.error],
          ["Rate Limited", "Hourglass icon + \"AI is busy\" + progress bar showing cooldown + queued count badge", tokens.colors.semantic.info],
        ].map(([title, desc, color]) => (
          <div key={title} style={{ ...cardBase, borderLeft: `3px solid ${color}`, padding: 16 }}>
            <div style={{ fontSize: 13, fontWeight: 600, color, marginBottom: 6 }}>{title}</div>
            <div style={{ fontSize: 12, color: tokens.colors.text.tertiary, lineHeight: 1.5 }}>{desc}</div>
          </div>
        ))}
      </div>

      <div style={labelStyle}>Toast / Snackbar Patterns</div>
      <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
        {[
          ["Meal logged successfully", tokens.colors.semantic.success, "✓"],
          ["New personal record! Bench Press 80kg", tokens.colors.macro.calories, "🏆"],
          ["AI analysis queued — you're offline", tokens.colors.semantic.warning, "⏳"],
          ["Failed to sync. Tap to retry.", tokens.colors.semantic.error, "✕"],
        ].map(([msg, color, icon]) => (
          <div key={msg} style={{ display: "flex", alignItems: "center", gap: 12, padding: "12px 16px", borderRadius: tokens.radius.md, background: tokens.colors.bg.elevated, border: `1px solid ${color}22` }}>
            <span style={{ width: 28, height: 28, borderRadius: "50%", background: `${color}20`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 14 }}>{icon}</span>
            <span style={{ fontSize: 13, fontWeight: 500, color: tokens.colors.text.primary, flex: 1 }}>{msg}</span>
            <span style={{ fontSize: 12, color: tokens.colors.text.tertiary, cursor: "pointer" }}>Dismiss</span>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Section: Firebase & Security ───
function FirebaseSecurity() {
  return (
    <div>
      <h2 style={sectionTitle}>Firebase Architecture & Security</h2>
      <p style={sectionSub}>
        Defense-in-depth security with Firebase as the backend. Every layer adds protection: authentication,
        authorization, encryption, and validation.
      </p>

      <div style={labelStyle}>Firebase Services Used</div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginBottom: 28 }}>
        {[
          ["Firebase Auth", "Email/password + Google Sign-In + Apple Sign-In. MFA via SMS/TOTP. Anonymous auth for onboarding trial."],
          ["Cloud Firestore", "Primary database. User-scoped collections with security rules. Offline persistence enabled."],
          ["Firebase Storage", "Progress photos + meal images. Compressed before upload. User-scoped paths."],
          ["Cloud Functions", "Server-side validation, Gemini API proxy (hides API key), rate limit enforcement."],
          ["Firebase App Check", "Device attestation (Play Integrity / DeviceCheck) blocks bots and abuse."],
          ["Remote Config", "Feature flags, AI prompt versions, rate limit thresholds. No app update needed."],
        ].map(([title, desc]) => (
          <div key={title} style={{ ...cardBase }}>
            <div style={{ fontSize: 14, fontWeight: 600, color: tokens.colors.brand.cyan, marginBottom: 6 }}>{title}</div>
            <div style={{ fontSize: 12, color: tokens.colors.text.tertiary, lineHeight: 1.6 }}>{desc}</div>
          </div>
        ))}
      </div>

      <div style={labelStyle}>Firestore Data Structure</div>
      <pre style={{ ...codeBlock, marginBottom: 28 }}>{`users/{uid}/
  ├── profile          # UserProfile (latest)
  ├── goals            # UserGoals
  ├── targets          # Computed DailyNutritionTargets
  │
  ├── meal_logs/{id}          # MealLog documents
  │   └── items/{id}          # MealLogItem sub-collection
  │
  ├── meal_plans/{id}         # AI-generated plans
  │   └── days/{date}/meals   # PlannedMeal sub-collection
  │
  ├── workout_logs/{id}       # Completed workouts
  │   └── exercises/{id}      # WorkoutLogExercise + sets
  │
  ├── workout_plans/{id}      # AI-generated programs
  ├── progress/{id}           # ProgressEntry snapshots
  ├── recipes/{id}            # User-created recipes
  └── ai_conversations/{id}   # Chat history
      └── messages/{id}

// Shared (read-only for users)
food_items/{id}               # Global food database
exercises/{id}                # Global exercise database`}</pre>

      <div style={labelStyle}>Security Rules Pattern</div>
      <pre style={{ ...codeBlock, marginBottom: 28 }}>{`rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data: owner-only access
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == uid;
    }
    
    // Global food DB: authenticated read-only
    match /food_items/{id} {
      allow read: if request.auth != null;
      allow write: if false; // admin-only via Cloud Functions
    }
    
    // Global exercise DB: authenticated read-only
    match /exercises/{id} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}`}</pre>

      <div style={labelStyle}>Security Architecture (7 Layers)</div>
      <div style={{ display: "flex", flexDirection: "column", gap: 3, marginBottom: 28 }}>
        {[
          ["1. Transport", "TLS 1.3", "All traffic encrypted in transit. Certificate pinning on API calls to prevent MITM.", tokens.colors.brand.lime],
          ["2. Device Attestation", "Firebase App Check", "Play Integrity (Android) + DeviceCheck (iOS). Blocks emulators, rooted devices, and bots.", tokens.colors.brand.lime],
          ["3. Authentication", "Firebase Auth + MFA", "Email/password with strong password policy. Optional TOTP/SMS MFA. Biometric unlock for returning sessions.", tokens.colors.brand.cyan],
          ["4. Authorization", "Firestore Rules", "User-scoped rules: users can ONLY read/write their own data. No cross-user access possible.", tokens.colors.brand.cyan],
          ["5. API Security", "Cloud Functions Proxy", "Gemini API key stored in Secret Manager. Cloud Function proxies requests, enforces per-user rate limits, validates input schemas.", tokens.colors.macro.calories],
          ["6. Data Encryption", "AES-256 at Rest", "Firestore encrypts at rest by default. Sensitive fields (health data) additionally encrypted client-side with user-derived key via flutter_secure_storage.", tokens.colors.macro.calories],
          ["7. Client Hardening", "Obfuscation + Pinning", "ProGuard/R8 (Android), code obfuscation (Flutter), no secrets in client bundle, jailbreak/root detection.", tokens.colors.brand.coral],
        ].map(([layer, tech, desc, color]) => (
          <div key={layer} style={{ display: "flex", gap: 14, padding: "14px 16px", borderRadius: tokens.radius.md, background: tokens.colors.bg.tertiary, borderLeft: `3px solid ${color}` }}>
            <div style={{ minWidth: 130 }}>
              <div style={{ fontSize: 12, fontWeight: 700, color }}>{layer}</div>
              <div style={{ fontSize: 11, fontWeight: 600, color: tokens.colors.text.secondary, marginTop: 2 }}>{tech}</div>
            </div>
            <div style={{ fontSize: 12, color: tokens.colors.text.tertiary, lineHeight: 1.5 }}>{desc}</div>
          </div>
        ))}
      </div>

      <div style={labelStyle}>Gemini API Proxy (Cloud Function)</div>
      <pre style={{ ...codeBlock, marginBottom: 28 }}>{`// Cloud Function: geminiProxy
// - API key in Secret Manager (never on client)
// - Per-user rate limiting (Redis/Firestore counter)
// - Input schema validation (reject malformed prompts)
// - App Check token verification
// - Response caching (identical prompts → cached result)

exports.geminiProxy = onCall({
  enforceAppCheck: true,    // Reject unverified devices
  consumeAppCheckToken: true // One-time token (replay protection)
}, async (request) => {
  // 1. Verify authenticated user
  if (!request.auth) throw new HttpsError('unauthenticated');
  
  // 2. Check per-user rate limit (15 RPM, 800 RPD)
  await enforceRateLimit(request.auth.uid);
  
  // 3. Validate input schema
  validatePromptSchema(request.data);
  
  // 4. Check cache
  const cached = await checkCache(request.data);
  if (cached) return cached;
  
  // 5. Call Gemini with server-side API key
  const response = await gemini.generateContent({
    model: 'gemini-2.0-flash',
    ...request.data
  });
  
  // 6. Cache + return
  await cacheResponse(request.data, response);
  return response;
});`}</pre>

      <div style={labelStyle}>Additional Security Measures</div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
        {[
          ["Session Management", "Firebase Auth tokens auto-refresh. Force re-auth for sensitive ops (delete account, export data). Max 30-day session with biometric re-verify."],
          ["Data Minimization", "Only essential health data collected. No location tracking. Meal photos stored compressed, auto-deleted after 90 days unless user opts to keep."],
          ["Audit Logging", "Cloud Function logs all AI requests with uid, timestamp, request type. No prompt content logged. Anomaly detection on usage patterns."],
          ["GDPR/Privacy", "Full data export (JSON) via Cloud Function. Account deletion cascades all sub-collections. Privacy policy in-app. Consent management for AI analysis."],
          ["Input Sanitization", "All user inputs validated and sanitized before Firestore writes. Firestore rules enforce data types and field constraints."],
          ["Dependency Security", "Automated Dependabot for Flutter packages. No third-party SDKs with network access besides Firebase. Regular security audits."],
        ].map(([title, desc]) => (
          <div key={title} style={{ ...cardBase, padding: 16 }}>
            <div style={{ fontSize: 13, fontWeight: 600, color: tokens.colors.text.primary, marginBottom: 6 }}>{title}</div>
            <div style={{ fontSize: 12, color: tokens.colors.text.tertiary, lineHeight: 1.6 }}>{desc}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Section: Architecture ───
function Architecture() {
  return (
    <div>
      <h2 style={sectionTitle}>Flutter Architecture</h2>
      <p style={sectionSub}>
        Feature-first modular architecture with Riverpod for state, Drift for local cache,
        and Firebase as the cloud backend.
      </p>

      <div style={labelStyle}>Project Structure</div>
      <pre style={{ ...codeBlock, marginBottom: 28 }}>{`lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart         # All color tokens
│   │   ├── app_typography.dart     # All text styles
│   │   ├── app_spacing.dart        # Spacing constants
│   │   ├── app_radius.dart         # Border radius tokens
│   │   ├── app_shadows.dart        # Elevation shadows
│   │   └── app_theme.dart          # ThemeData assembly
│   ├── firebase/
│   │   ├── firebase_service.dart   # Init + config
│   │   ├── auth_service.dart       # Auth wrapper
│   │   ├── firestore_service.dart  # CRUD abstraction
│   │   ├── storage_service.dart    # Image upload/download
│   │   └── functions_service.dart  # Cloud Function calls
│   ├── security/
│   │   ├── encryption_service.dart # AES-256 client-side
│   │   ├── secure_storage.dart     # flutter_secure_storage
│   │   ├── app_check_service.dart  # Device attestation
│   │   ├── biometric_service.dart  # Fingerprint/FaceID
│   │   └── certificate_pinning.dart
│   ├── ai/
│   │   ├── gemini_client.dart      # Via Cloud Function proxy
│   │   ├── prompt_builder.dart     # Context compression
│   │   ├── response_cache.dart     # Local cache layer
│   │   ├── rate_limiter.dart       # Client-side token bucket
│   │   └── schemas/               # JSON response schemas
│   ├── database/
│   │   ├── app_database.dart       # Drift local DB (offline cache)
│   │   └── daos/                   # Data Access Objects
│   ├── widgets/                    # Shared components
│   │   ├── buttons.dart
│   │   ├── cards.dart
│   │   ├── inputs.dart
│   │   ├── macro_bar.dart
│   │   ├── calorie_ring.dart
│   │   ├── chips.dart
│   │   ├── bottom_nav.dart
│   │   ├── toast.dart
│   │   ├── skeleton_loader.dart
│   │   └── ai_loading.dart
│   └── utils/
│       ├── validators.dart
│       ├── formatters.dart
│       └── extensions.dart
│
├── features/
│   ├── onboarding/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── services/
│   │   └── screens/
│   ├── dashboard/
│   ├── nutrition/
│   │   ├── models/
│   │   │   ├── food_item.dart
│   │   │   ├── meal_log.dart
│   │   │   └── meal_analysis.dart
│   │   ├── providers/
│   │   │   ├── meal_log_provider.dart
│   │   │   └── food_search_provider.dart
│   │   ├── services/
│   │   │   ├── nutrition_service.dart
│   │   │   ├── meal_log_service.dart
│   │   │   └── meal_analysis_service.dart
│   │   └── screens/
│   │       ├── meal_log_screen.dart
│   │       ├── food_search_screen.dart
│   │       └── meal_detail_screen.dart
│   ├── meal_plans/
│   ├── fitness/
│   ├── workout_plans/
│   ├── progress/
│   ├── coach/
│   └── settings/
│
├── router.dart                     # GoRouter config
└── main.dart                       # App entry + Firebase init`}</pre>

      <div style={labelStyle}>Data Flow: Firestore ↔ Local Cache ↔ UI</div>
      <div style={{ ...cardBase, marginBottom: 28 }}>
        <pre style={{ fontSize: 12, color: tokens.colors.text.secondary, fontFamily: "monospace", lineHeight: 1.8, margin: 0, whiteSpace: "pre" }}>{`┌──────────────┐     ┌─────────────────┐     ┌──────────────┐
│   Flutter UI  │◄────│  Riverpod State  │◄────│  Drift (SQL)  │
│  (Reactive)   │     │   (Providers)    │     │  Local Cache  │
└──────┬───────┘     └───────┬─────────┘     └──────┬───────┘
       │ user action         │ service call          │ read/write
       ▼                     ▼                       │
┌──────────────┐     ┌─────────────────┐            │
│  Controller   │────▶│  Service Layer   │────────────┘
│  (Provider)   │     │  (Business Logic)│──────┐
└──────────────┘     └─────────────────┘      │
                                               ▼
                     ┌─────────────────┐  ┌──────────────┐
                     │  Cloud Function  │◄─│  Firestore    │
                     │  (Gemini Proxy)  │  │  (Cloud DB)   │
                     └─────────────────┘  └──────────────┘

SYNC STRATEGY:
• Writes: Local DB first → Firestore sync (optimistic)
• Reads: Local DB (instant) + Firestore listener (fresh)
• Conflicts: Last-write-wins with server timestamp
• Offline: Full local DB, queue Firestore writes`}</pre>
      </div>

      <div style={labelStyle}>Key Dart Packages</div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
        {[
          ["flutter_riverpod", "State management & DI"],
          ["drift + sqlite3_flutter_libs", "Local SQLite database"],
          ["firebase_core / auth / firestore / storage", "Firebase services"],
          ["cloud_functions", "Cloud Function calls"],
          ["firebase_app_check", "Device attestation"],
          ["dio", "HTTP client with interceptors"],
          ["flutter_secure_storage", "Encrypted key storage"],
          ["local_auth", "Biometric authentication"],
          ["go_router", "Declarative navigation"],
          ["fl_chart", "Charts & visualizations"],
          ["image_picker + image", "Camera + compression"],
          ["phosphor_flutter", "Icon set"],
          ["cached_network_image", "Image caching"],
          ["connectivity_plus", "Network state"],
        ].map(([pkg, desc]) => (
          <div key={pkg} style={{ display: "flex", justifyContent: "space-between", padding: "8px 12px", borderRadius: tokens.radius.sm, background: tokens.colors.bg.tertiary }}>
            <span style={{ fontSize: 12, fontFamily: "monospace", color: tokens.colors.brand.cyan }}>{pkg}</span>
            <span style={{ fontSize: 11, color: tokens.colors.text.tertiary }}>{desc}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Main App ───
export default function DesignSystem() {
  const [activeSection, setActiveSection] = useState("Overview");

  const renderSection = () => {
    switch (activeSection) {
      case "Overview": return <Overview />;
      case "Colors": return <Colors />;
      case "Typography": return <Typography />;
      case "Spacing": return <Spacing />;
      case "Components": return <Components />;
      case "Icons & States": return <IconsStates />;
      case "Firebase & Security": return <FirebaseSecurity />;
      case "Architecture": return <Architecture />;
      default: return <Overview />;
    }
  };

  return (
    <div style={{ minHeight: "100vh", background: tokens.colors.bg.primary, color: tokens.colors.text.primary, fontFamily: "'Satoshi', 'DM Sans', system-ui, sans-serif" }}>
      {/* Header */}
      <div style={{ position: "sticky", top: 0, zIndex: 100, background: tokens.colors.bg.overlay, backdropFilter: "blur(16px)", borderBottom: `1px solid ${tokens.colors.surface.cardBorder}` }}>
        <div style={{ maxWidth: 960, margin: "0 auto", padding: "14px 24px" }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
              <div style={{ width: 28, height: 28, borderRadius: 8, background: tokens.colors.brand.lime, display: "flex", alignItems: "center", justifyContent: "center" }}>
                <span style={{ fontSize: 14, fontWeight: 900, color: "#0A0A0C" }}>F</span>
              </div>
              <span style={{ fontSize: 16, fontWeight: 700, color: tokens.colors.text.primary, letterSpacing: -0.3 }}>FitGenius AI</span>
              <span style={{ fontSize: 11, fontWeight: 600, color: tokens.colors.text.tertiary, padding: "2px 8px", borderRadius: 9999, border: `1px solid ${tokens.colors.surface.cardBorder}`, marginLeft: 4 }}>Design System v1.0</span>
            </div>
            <span style={{ fontSize: 11, color: tokens.colors.text.tertiary }}>Flutter · Firebase · Gemini</span>
          </div>
          <div style={{ display: "flex", gap: 6, overflowX: "auto", paddingBottom: 2 }}>
            {SECTIONS.map((s) => (
              <button key={s} onClick={() => setActiveSection(s)} style={pill(activeSection === s)}>
                {s}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Content */}
      <div style={{ maxWidth: 960, margin: "0 auto", padding: "32px 24px 80px" }}>
        {renderSection()}
      </div>
    </div>
  );
}
