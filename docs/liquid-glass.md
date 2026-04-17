# Liquid Glass — FitSmart AI Implementation Guide

> **The complete, authoritative reference** for Apple's iOS 26 Liquid Glass design language and how we implement it inside FitSmart AI (Flutter).
>
> Read this *before* touching any UI surface. The cost of fighting the system is high; the reward for following it is a phone-native premium feel that converts.

---

## 1. What Liquid Glass is

Liquid Glass is Apple's new system material introduced at WWDC 2025 — the most significant visual overhaul since iOS 7, shipping across iOS / iPadOS / macOS Tahoe / watchOS / tvOS 26.

It is **not** frosted glass. It is **not** a blur filter. It is a translucent material that **reflects and refracts its surroundings** in real time, with:

- **Real-time light bending** (lensing) — light sources behind the surface bend through it
- **Specular highlights** — surfaces respond to device motion and ambient light
- **Adaptive shadows** — dimensional, not painted
- **Dynamic transformation** — surfaces morph as content scrolls
- **Concentric geometry** — nested surfaces share corner radii with the device hardware

Apple's three pillars (memorise these):

| Pillar | Meaning |
|---|---|
| **Hierarchy** | Controls and chrome elevate above content. Content is sovereign; chrome serves it. |
| **Harmony** | Interface geometry follows hardware geometry (concentric corners, aligned curves). |
| **Consistency** | Adopt platform conventions; surfaces adapt across screen sizes. |

Source: Apple HIG · [Apple Newsroom announcement](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/) · [createwithswift breakdown](https://www.createwithswift.com/liquid-glass-redefining-design-through-hierarchy-harmony-and-consistency/)

---

## 2. The three-layer model (the most important rule)

Apple's HIG defines **three z-axis layers**. Glass is allowed on **exactly one** of them.

```
┌─────────────────────────────────────────┐
│  3. OVERLAY                             │  ← vibrancy / fills *on* glass
│     (badges, tints, accent CTAs)        │
├─────────────────────────────────────────┤
│  2. NAVIGATION  ← Liquid Glass lives    │  ← nav bars, tab bars, sheets,
│     HERE AND ONLY HERE                  │     popovers, menus, toolbars,
│                                         │     floating buttons, controls
├─────────────────────────────────────────┤
│  1. CONTENT                             │  ← lists, cards, media,
│     SOLID — never glass                 │     tables, scrollable text
└─────────────────────────────────────────┘
```

**Quote from Apple:** *"Liquid Glass is exclusively for the navigation layer that floats above app content. Never apply to content itself (lists, tables, media)."*

**Anti-pattern Apple explicitly calls out:** glass-on-glass stacking. Two layers of glass create confusing depth.

---

## 3. Where glass goes (and where it doesn't)

### ✅ Apple says glass YES on:
- Tab bars, navigation bars, toolbars
- Sheets and popovers
- Menus and context menus
- Floating action buttons / controls
- Sidebars (iPad, Mac)
- Date/time pickers, sliders, segmented controls
- Notification banners

### ❌ Apple says glass NO on:
- **Content surfaces** — meal cards, workout rows, list tiles, profile cards
- **Charts and data viz** — backgrounds must be solid for legibility
- **Long text passages** — articles, FAQs, legal copy
- **Full-screen backgrounds** — splash, hero images
- **Buttons used as primary CTAs** — solid is more clickable
- **Glass on top of glass** — pick one
- **Anything that needs maximum text contrast** — error states, transient toasts

### 🔍 Greyzone — case-by-case
- **Empty states** — usually OK if there's a single mascot/illustration, not dense info
- **Onboarding cards** — OK, they're chrome-like
- **Settings rows** — OK, but only if the row spacing reads as hierarchy

---

## 4. Material variants

Apple ships three glass variants (SwiftUI: `Glass.regular`, `Glass.clear`, `Glass.identity`):

| Variant | When to use | Transparency |
|---|---|---|
| **`regular`** | Default for all chrome | Medium — adapts to any content |
| **`clear`** | Over media-rich backgrounds (photos, video) | High — requires a dimming layer below |
| **`identity`** | Conditional disable (no glass applied) | None |

Plus two modifiers:
- **`.tint(color)`** — accent-tints the glass (use for CTAs ONLY, semantic, not decorative)
- **`.interactive()`** — subtle response to touch (subtle scale/highlight)

Plus two button styles:
- **`.glass`** — translucent button on a glass surface
- **`.glassProminent`** — opaque primary (solid CTA, but with glass-rim treatment)

---

## 5. Tinting discipline

Apple is strict here:

> *"Use [tint] selectively for call-to-action only. Tinting should convey semantic meaning, NOT decoration."*

Translation: a glass surface is colorless by default. The accent only flows through it when the surface IS the call to action (e.g. a "Buy" button). Decorative tinting (every banner is faintly green because it looks nice) is wrong.

In FitSmart that means:
- **Lime tint allowed**: paywall hero card, "Continue" button, the CTA on the upgrade banner
- **Lime tint disallowed**: bottom nav, app bars, every modal sheet, every empty state

---

## 6. Concentricity (Harmony pillar)

Nested glass shapes inherit corner radii from the hardware they sit in.

**Rule:** the corner radius of an inner glass surface = `outer corner radius − margin to outer edge`.

Example on iPhone 15 Pro (corner radius ≈ 55pt):
- A pinned tab bar inset 8pt from the screen edge → its corners should be ~47pt, not 12pt
- A sheet that covers the full screen → it adopts the device's 55pt radius, not its own

**Why it matters:** non-concentric corners look broken to the eye even when you can't articulate why. The interface "feels misaligned."

---

## 7. Light, dark, and accessibility — automatic

Apple's biggest selling point: **glass adapts itself**. The system handles:

| Setting | Behavior |
|---|---|
| **Reduce Transparency** | Glass becomes opaque-frosted — same shape, lost translucency |
| **Increase Contrast** | Adds borders, deepens edges, stark colors |
| **Reduce Motion** | Specular and morphing animations tone down or stop |
| **Light vs Dark** | Refraction maths recompute; tints shift in saturation |

> *"Never override unless absolutely necessary."*

For FitSmart this means: respect `MediaQuery.of(context).accessibleNavigation`, `boldText`, `disableAnimations`, `highContrast`. Don't hardcode tints that ignore them.

---

## 8. Dynamic behavior (the "liquid" part)

Glass is alive in ways frosted glass never was:

- **Scroll-shrink** — tab bars and nav bars shrink as the user scrolls into content. Apple ships `.tabBarMinimizeBehavior(.onScrollDown)` for this.
- **Morph between states** — when surface adjacent glass elements share a `GlassEffectContainer + namespace + glassEffectID`, they fluidly morph during state changes. (E.g. play button morphing into pause.)
- **Specular highlights** track the device's gyroscope on iOS — light "rolls" across the surface as you tilt the phone.
- **Lensing** — visible content behind the glass distorts subtly through the surface, like a real glass pane.

**Performance cost is real:** Apple's own measurements show ~13% extra battery drain on iPhone 16 Pro Max vs iOS 18. Mitigations:
1. `GlassEffectContainer` to group neighbors (one render pass, not many)
2. `Glass.identity` to toggle off without layout recalc
3. Limit *continuous* animations — let glass "rest in steady state"
4. Test on 3-year-old hardware before shipping

---

## 9. What we CAN do in Flutter — and what we can't

This is the honest section. Flutter is not SwiftUI. We get the spirit, not the spec.

### ✅ We CAN do (and already do):

- `BackdropFilter` + `ImageFilter.blur` — Gaussian blur of content behind a clip
- Translucent fill colors with theme-aware alpha
- Animated state transitions, scale, springs
- Top-edge rim highlight gradients (the "glass rim catches light" cue)
- Accent borders that pull through the user's chosen accent
- Light/dark theme adaptation via `Theme.of(context).brightness`
- Performance gating — sigma 8 on web, 18-24 on native

### ⚠️ We CAN approximate, with quality loss:

- Specular highlights — we can fake them with subtle gradient overlays, but they don't track gyroscope without a custom plugin
- Concentricity — we can hand-tune radii to match device, but without the SwiftUI auto-shape engine
- Vibrancy — we can layer translucent fills, but Apple's saturation/luminosity vibrancy isn't free

### ❌ We CAN'T do (without writing a custom GLSL shader):

- **True refraction / lensing** — light *bending* through the surface. Flutter blur is post-process Gaussian, not optical refraction
- **Real-time scroll-tracked specular** — the highlight that moves as you tilt the device
- **Apple's exact material maths** — proprietary shaders we have no access to

### 🛠 What we did about it (the design compromise)

We built **two-tier glass**:

1. **Tier 1 — true backdrop glass** (`LiquidGlass` widget with `BackdropFilter`)
   - Used on overlays where there IS content behind to frost (modal sheets, ephemeral overlays, *would-be* nav with proper z-stacking)
   - Subject to the bleed problem (see §11) when Scaffold paints body before chrome

2. **Tier 2 — solid surface with glass cues** (used by `LiquidAppBar` and the bottom nav)
   - Solid bgPrimary/bgSecondary fill — no BackdropFilter
   - Top-edge highlight gradient (~4% white in dark mode) suggesting glass-rim catching light
   - Accent-tinted bottom border (~50% surfaceCardBorder) for definition
   - **Reads as glass without producing artefacts**

Both tiers respect the same rules. Tier 2 is our pragmatic answer to a Flutter rendering reality.

---

## 10. The FitSmart implementation stack

### Primitives

| Primitive | File | What it is | Where to use |
|---|---|---|---|
| `LiquidGlass` | [liquid_glass.dart](fitsmart_app/lib/core/widgets/liquid_glass.dart) | True backdrop-blur surface (Tier 1) | Modal sheets, snackbars, overlays |
| `LiquidAppBar` | [liquid_glass.dart](fitsmart_app/lib/core/widgets/liquid_glass.dart) | Solid surface with glass cues (Tier 2) | Every screen's `appBar` |
| `LiquidGlassAppBar` | [liquid_glass.dart](fitsmart_app/lib/core/widgets/liquid_glass.dart) | Sliver variant | `CustomScrollView` screens (dashboard) |
| `showLiquidGlassSheet()` | [liquid_glass.dart](fitsmart_app/lib/core/widgets/liquid_glass.dart) | Modal sheet helper | Replace `showModalBottomSheet` |
| `AppGlass` (tokens) | [liquid_glass.dart](fitsmart_app/lib/core/widgets/liquid_glass.dart) | blur sigma, fill alpha, rim alpha | Single tweak point |
| `GlassIntensity` enum | [liquid_glass.dart](fitsmart_app/lib/core/widgets/liquid_glass.dart) | subtle / regular / strong | Per-tier opacity |
| `AppCard` (auto-glass) | [app_card.dart](fitsmart_app/lib/core/widgets/app_card.dart) | Glass card with spring scale-on-press | Every card surface; press scales to 0.97 with Apple spring |
| `AccentCard` | [app_card.dart](fitsmart_app/lib/core/widgets/app_card.dart) | Glass + left accent stripe | Quick callouts |
| `GlowCard` | [app_card.dart](fitsmart_app/lib/core/widgets/app_card.dart) | Glass + outer accent glow | Premium / paywall hero |
| **`GlassToggle`** | [glass_toggle.dart](fitsmart_app/lib/core/widgets/glass_toggle.dart) | iOS switch — track turns translucent on press, thumb stretches (squish), spring slide | Drop-in replacement for Material `Switch` |
| **`GlassSegment<T>`** | [glass_segment.dart](fitsmart_app/lib/core/widgets/glass_segment.dart) | Segmented control with sliding glass pill that springs between segments | Replace `TabBar` for short label sets (≤4) |
| `LiquidAppBar` etc. | (see above) | | |
| `AppMotion` (tokens) | [app_motion.dart](fitsmart_app/lib/core/theme/app_motion.dart) | Apple springs (`spring`, `springSoft`, `easeIO`, `easeOut`) + durations + `pressScale` | Use everywhere a glass surface animates |
| `motionGate(ctx, d)` | [app_motion.dart](fitsmart_app/lib/core/theme/app_motion.dart) | Returns `Duration.zero` when reduce-motion is on | Wrap every animation duration that targets glass |

### Tokens (in `AppGlass`)

```dart
blurSigma:    dark = 24, light = 18, web = 8 (Impeller perf cap)
fillAlpha:    dark { subtle .35, regular .55, strong .72 }
              light { subtle .55, regular .72, strong .85 }
rimHighlight: dark .12, light .60
rimShadow:    dark .30, light .06
accentRim:    .18      ← only when accentRim:true
accentInnerGlow: .05   ← only when accentInnerGlow:true
```

Light mode gets **higher fill alpha** (white needs more body to register as glass) and **lower highlight intensity** (white-on-white rim disappears otherwise).

### Theme integration

The accent rim and inner glow always pull from `context.colors.lime`, which is **the user's chosen accent** (lime by default, swappable in Settings → Accent Color). Macro colors (protein cyan, carbs lime, fat coral, fiber purple, calories amber) are **immutable** and never tinted by glass.

---

## 11. The bleed problem (and the rule that prevents it)

We hit this twice — bottom nav and top app bar both showed body content (lime FAB, lime CTAs) bleeding through the glass.

### Why it happens

Scaffold paints the **body before the appBar / bottomNavigationBar**. A `BackdropFilter` inside the chrome samples whatever's painted earlier in the same compositing layer — including body overflow, scroll overshoot, shadow extents.

### The rule

> **Use real `BackdropFilter` only on surfaces that genuinely overlay scrollable content** (modal sheets, snackbars, ephemeral overlays). For nav bars and app bars, use the **Tier 2 solid surface with glass cues** — bgPrimary fill + top highlight gradient + bottom rim border. No BackdropFilter, no bleed, same visual language.

### How `LiquidAppBar` does it (for reference)

```dart
return AppBar(
  backgroundColor: c.bgPrimary,           // solid
  surfaceTintColor: Colors.transparent,
  flexibleSpace: DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(           // top highlight = "glass rim"
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.04 : 0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6],
      ),
    ),
  ),
  shape: Border(                          // bottom hairline
    bottom: BorderSide(
      color: c.surfaceCardBorder.withValues(alpha: 0.5),
      width: 1,
    ),
  ),
);
```

This is the canonical pattern. Don't reinvent it elsewhere.

---

## 12. Apple SwiftUI ↔ FitSmart Flutter mapping

| Apple SwiftUI | FitSmart equivalent | Notes |
|---|---|---|
| `.glassEffect(.regular)` | `LiquidGlass(intensity: GlassIntensity.regular)` | true blur, for overlays |
| `.glassEffect(.clear)` | `LiquidGlass(intensity: GlassIntensity.subtle)` | lower fill alpha |
| `Glass.tint(color)` | `LiquidGlass(accentRim: true)` | rim only — never fill |
| `Glass.interactive()` | wrap in `InkWell` (lime splash already global) | lime ripple from theme |
| `.buttonStyle(.glass)` | `OutlinedButton` over `LiquidGlass` parent | rare in our app |
| `.buttonStyle(.glassProminent)` | `ElevatedButton(color: c.lime)` | solid lime CTA |
| `GlassEffectContainer` | a single `LiquidGlass` wrapping children | one paint pass |
| `.tabBarMinimizeBehavior(.onScrollDown)` | not implemented yet — see §15 | Phase 2 candidate |
| Reduce Transparency | not implemented yet — TODO | per Apple guidance |

---

## 13. Component-by-component implementation rules

### App bars (every screen)
- Use `LiquidAppBar` (Tier 2)
- **Never** set `extendBodyBehindAppBar: true` on tabbed screens (causes bleed)
- App bar bottom border at 50% surfaceCardBorder

### Bottom nav (the AppShell)
- Solid surface — no BackdropFilter (Tier 2 pattern, inline)
- Hairline top border (0.5px at 60% surfaceCardBorder)
- No top-highlight gradient (looked like 3D plastic shine — removed)
- AnimatedScale on active icon, AnimatedContainer on background pill

### Modal sheets
- Use `showLiquidGlassSheet()` — true backdrop blur (sheets float over content)
- 24pt top corner radius (concentricity with iPhone screen edge)
- `accentRim: true` allowed for premium moments (paywall confirmation)

### Snackbars / toasts
- **Solid surface — NOT glass** — transient text needs maximum contrast
- Drops down from above (NOT bottom — never hide the nav)
- Semantic-color left border (red/green/lime)
- Soft drop-shadow for elevation, no blur

### Cards (`AppCard`, `AccentCard`, `GlowCard`)
- Currently use `LiquidGlass` strong intensity — **acceptable** because they sit on bgPrimary, not over scrolling content
- In light mode, soft drop-shadow lifts them off the page wash
- For semantic-tinted cards (errorBg, successBg) → SOLID with the tint, never glass

### Buttons
- Primary CTAs: solid lime `ElevatedButton` — tap clarity > aesthetic
- Secondary: `OutlinedButton` with surfaceCardBorder
- Tertiary: `TextButton` with lime foreground
- Glass on a button surface: only when the button is itself a glass tile (rare)

### FAB
- Solid lime — primary action, must be unmistakable
- No glass tint, no border, just elevation + lime

### Empty states
- Mascot + 1-line copy + 1-line subtext on a solid surfaceCard, OR no surface (just centered)
- Glass card around an empty state is acceptable when it's chrome-like ("Snap a meal" placeholder uses solid surfaceCard)

---

## 14. Color discipline

The accent flows through the glass, not the other way around. Specifically:

- The user's accent color (`context.colors.lime`) is set via Settings
- It propagates to: rim borders, accent inner glow, active states, CTAs, focused inputs
- Macro colors are **fixed** — protein cyan, carbs lime, fat coral, fiber purple, calories amber — they never get tinted by glass
- Semantic colors (success / warning / error / info) are **fixed** — never accent-blended
- Glass tints never apply to text — text uses textPrimary/Secondary/Tertiary

**Rule:** if you find yourself tinting glass with a non-accent color, stop. Either use a solid semantic-tinted surface, or no tint at all.

---

## 15. Things we haven't built yet (and probably should)

These are real Apple Liquid Glass behaviors we lack. Listed in priority order:

### High value
1. **Reduce Transparency support** — when accessibility flag is on, swap all `LiquidGlass` instances to opaque-frosted (alpha → 0.95, no blur)
2. **Scroll-shrink for the bottom nav** — Apple's signature move; nav minimises as user scrolls into content
3. **Concentricity audit** — corner radii on nested glass should match device (currently we use AppRadius.lg = 14 everywhere)

### Medium value
4. **Specular highlight that follows scroll** — a soft white sheen that drifts slowly across pinned headers as user scrolls
5. **Vibrancy on text inside glass** — Apple's text "lifts" through glass with a slight luminosity boost
6. **Glass morphing between states** — Apple's `glassEffectID` + namespace pattern for "play → pause" type morphs

### Low value (cosmetic)
7. **Gyroscope-tracked specular** — would need a sensor plugin; impressive demo but limited UX impact
8. **Per-screen wallpaper-aware tinting** — adapts saturation to what's behind

---

## 16. Anti-patterns to never ship

| Anti-pattern | Why | Do this instead |
|---|---|---|
| Glass on glass | Apple-flagged; muddles hierarchy | Pick the higher layer; demote the lower |
| Glass over a solid bgPrimary background with nothing behind | Renders as just a translucent fill — pointless | Use solid surfaceCard with a border |
| BackdropFilter inside an AppBar | Bleeds body content (we hit this twice) | Tier 2 pattern: solid + highlight + rim |
| Tinting glass for decoration | Apple-flagged; dilutes the accent's meaning | Reserve accent tint for CTAs only |
| Glass on a chart background | Data legibility loss | Solid surfaceCard, period |
| Snackbar with glass surface over a busy screen | Text becomes unreadable | Solid surface with semantic rim |
| Sheet with `backgroundColor` set | Overrides the auto-glass that the helper provides | Pass `backgroundColor: Colors.transparent` and use `showLiquidGlassSheet` |
| Hardcoding accent color (`AppColors.lime`) instead of `context.colors.lime` | Breaks when user changes accent in settings | Always read through `context.colors` |
| Glass on a modal that doesn't truly overlay (e.g. inside a Container) | Nothing to frost; renders as a flat fill | Use a solid card |

---

## 17. Quick decision tree

When adding a new surface, ask:

```
1. Is this surface CHROME (nav, controls, sheet)?
   ├─ NO  → Solid AppCard / Container. Done.
   └─ YES → continue
2. Does it FLOAT OVER scrollable content?
   ├─ NO  → Tier 2: LiquidAppBar pattern (solid + highlight + rim)
   └─ YES → continue
3. Is it a TRANSIENT TEXT element (toast, error)?
   ├─ YES → Solid with semantic rim. Glass kills legibility here.
   └─ NO  → Tier 1: LiquidGlass with intensity per type
4. Is it a CTA?
   └─ YES → solid lime. Optionally accentRim on the parent surface.
```

---

## 18. Companion: the React reference DS (`liquid-glass-ds/`)

The repo ships a **complete Apple-faithful Liquid Glass implementation in React** at [`liquid-glass-ds/`](liquid-glass-ds/). It's the closest thing we have to a ground-truth spec — the tokens, motion, materials, and component compositions there are calibrated against real iOS 26 Control Center / macOS Tahoe menus. Treat it as the design source-of-truth; our Flutter side is the platform translation.

### Key files to read before designing a new surface

| File | What's in it |
|---|---|
| [`liquid-glass-ds/src/styles/tokens.css`](liquid-glass-ds/src/styles/tokens.css) | The complete token system — Apple system colors, glass-bg variants, blur scale, specular highlights, squircle radii, spring curves |
| [`liquid-glass-ds/src/components/Glass.css`](liquid-glass-ds/src/components/Glass.css) | Core surfaces — `.glass`, `.glass-card`, `.glass-btn`, with `:hover`/`:active` motion |
| [`liquid-glass-ds/src/components/Overlay.css`](liquid-glass-ds/src/components/Overlay.css) | Sheets, popovers, tooltips with detents |
| [`liquid-glass-ds/src/components/Picker.css`](liquid-glass-ds/src/components/Picker.css) | Date / time / color / option pickers (wheel + inline) |
| [`liquid-glass-ds/STRATEGY.md`](liquid-glass-ds/STRATEGY.md) | The 8-wave build plan that maps every iOS 26 component |

### What the React DS taught us — and what we should mirror

These are deltas between the React DS spec and our current Flutter `AppGlass` tokens. **High-priority mirrors** are worth porting; **medium** can wait; **low** is cosmetic.

| Apple spec (from React DS) | Our current Flutter | Priority | Action |
|---|---|---|---|
| `backdrop-filter: blur(48px) saturate(180%)` — saturation boost gives glass its colour richness, not just blur | We use only blur | **HIGH** | Stack `ColorFilter.matrix(saturationBoost)` over `BackdropFilter` |
| 3 thickness variants — `regular` / `thick` / `thin` (alpha .45 / .62 / .28 light) | We have `subtle / regular / strong` (close enough) | OK | Already aligned — rename if we ever import directly |
| `clear` glass uses **higher blur** (72px) AND **higher saturation** (200%) for use over media | We just lower the alpha | **MEDIUM** | Add a `clear` intensity tier with bumped sigma |
| Specular highlight as **inset box-shadow** (`inset 0 1px 0 rgba(255,255,255,0.55)`) — sharp bright top edge | We use a top LinearGradient from `Colors.white@.04` | **MEDIUM** | An `inset` border simulation using BorderSide on top would read sharper |
| Apple spring: `cubic-bezier(0.34, 1.56, 0.64, 1)` with subtle overshoot | We mostly use `Curves.easeOutCubic` | **HIGH** | Add `AppCurves.spring = Cubic(0.34, 1.56, 0.64, 1.0)` + use on glass interactions |
| Squircle radii scale: 8 / 12 / 16 / 22 / 28 / 36 / 9999 | Our `AppRadius`: 6 / 10 / 14 / 20 / 9999 | **MEDIUM** | Tune to match if we want concentricity with hardware (iPhone corner ≈ 22 inset) |
| Hover state: `translateY(-2px) scale(1.01)` + thicker shadow + brighter bg | We only do tap-down ripple | LOW | Not relevant on touch — only matters when adding mouse/keyboard support |
| Active state: `scale(0.97)` with faster transition (`motion-fast` 200ms) | We use Material default | **MEDIUM** | Wrap interactive `LiquidGlass` in a Listener that scales 0.97 on press |
| Dark glass uses `rgba(38, 38, 42, 0.55)` — slightly **warm-tinted** gray, not pure black | We use bgPrimary `#0A0A0C` (very dark) | LOW | Our OLED palette is intentionally darker — keep |
| `prefers-reduced-motion` collapses all spring/transition durations to 0 | We don't check `MediaQuery.disableAnimations` yet | **HIGH** | One global accessor; gate all glass animations |

### The Apple spec that's worth memorising

**The full glass formula (light mode)**
```css
background: rgba(255, 255, 255, 0.45);
backdrop-filter: blur(48px) saturate(180%);
border: 0.5px solid rgba(255, 255, 255, 0.45);
box-shadow:
  0 0 0 0.5px rgba(0,0,0,0.04),     /* outer hairline */
  0 2px 8px rgba(0,0,0,0.04),       /* close shadow */
  0 8px 24px rgba(0,0,0,0.06),      /* depth shadow */
  inset 0 1px 0 rgba(255,255,255,0.55),  /* specular top edge */
  inset 0 0 0 0.5px rgba(255,255,255,0.25); /* inner glow */
```

**The full glass formula (dark mode)**
```css
background: rgba(38, 38, 42, 0.55);
backdrop-filter: blur(48px) saturate(180%);
border: 0.5px solid rgba(255, 255, 255, 0.10);
box-shadow:
  0 0 0 0.5px rgba(0,0,0,0.20),
  0 2px 8px rgba(0,0,0,0.15),
  0 8px 24px rgba(0,0,0,0.20),
  inset 0 1px 0 rgba(255,255,255,0.08),
  inset 0 0 0 0.5px rgba(255,255,255,0.05);
```

**The spring**: `cubic-bezier(0.34, 1.56, 0.64, 1)` — this is THE Apple curve. Use it for any motion that should feel "iOS" (panel slide-ins, tab switches, mascot bounce).

**The motion durations**: fast 200ms · standard 300ms · slow 450ms.

### What's NOT in the React DS that Flutter needs to figure out

- **GLSL shader for true refraction** — even the React DS approximates with `backdrop-filter`. The actual iOS 26 lensing requires a custom shader. If we ever need it, it's a `FragmentShader` in Flutter — non-trivial.
- **Gyroscope-tracked specular** — would need a sensors plugin + animation controller fed by accelerometer
- **Glass morphing between states** (Apple's `glassEffectID`) — in Flutter we'd need a `Hero`-like coordinator with shared bounds + gradient interpolation

---

## 19. References

- **Apple HIG — Materials**: https://developer.apple.com/design/human-interface-guidelines/materials
- **Apple Newsroom — Liquid Glass announcement (Jun 2025)**: https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/
- **createwithswift — Hierarchy/Harmony/Consistency**: https://www.createwithswift.com/liquid-glass-redefining-design-through-hierarchy-harmony-and-consistency/
- **SwiftUI Liquid Glass technical reference**: https://medium.com/@madebyluddy/overview-37b3685227aa
- **Wikipedia — Liquid Glass**: https://en.wikipedia.org/wiki/Liquid_Glass
- **In-repo React reference DS**: [`liquid-glass-ds/`](liquid-glass-ds/) — calibrated against real iOS 26 / macOS Tahoe

---

## 20. Maintenance — when things change

When iOS updates the material spec or we tune our implementation:

1. Update the table in §10 if `AppGlass` token values change
2. Update §13 component rules if a new component type ships
3. Add to §15 when an Apple feature graduates from "haven't built" to shipped
4. Add to §16 anti-patterns when we hit a new gotcha worth recording
5. When porting a token / value from the React DS, update the table in §18

This document IS the spec for FitSmart's glass system. If implementation diverges from this doc, **the doc wins** — fix the code or, if the code is right, fix the doc with reasoning. The React DS at [`liquid-glass-ds/`](liquid-glass-ds/) is the design source-of-truth; this Flutter doc is the platform translation.
