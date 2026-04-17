# Build Strategy — Liquid Glass Design System

From 32% to 100%. Eight waves, each self-contained and shippable.
Every wave adds new pages, new shared components, and enriches existing pages.

---

## Architecture Principle

```
src/
  components/        ← shared Liquid Glass primitives (reused everywhere)
    Glass.jsx/.css   ← core surfaces, buttons, toggles, inputs, lists, ...
    Picker.jsx/.css  ← new: date, time, color, option pickers
    Overlay.jsx/.css ← new: popovers, tooltips, sheets, modals
    Media.jsx/.css   ← new: image views, galleries, video, activity rings
    Data.jsx/.css    ← new: charts, gauges, rating, progress, token fields
    Nav.jsx/.css     ← new: tab views, path control, status bar, toolbar
  pages/             ← one page per sidebar link (route)
  styles/            ← tokens + global reset
```

Every new component is a React export from a shared file — pages only compose them.
All components get the same spring motion (`--spring`, `--spring-soft`, `--ease-io`) and
glass-on-interact treatment. Every glass surface uses `backdrop-filter: blur() saturate()`.

---

## Wave 1 — Foundations Completion
**Goal:** Fill the three missing foundation pages so every other wave has a solid base.
**Duration:** 1 session

### New Pages
| Page | Route | Content |
|------|-------|---------|
| Layout System | `/layout` | Safe areas, adaptive margins, column grids (4/8/12), keyboard guide, RTL |
| Elevation & Depth | `/elevation` | Z-index scale, material layers, scroll edge effects (soft/hard blur) |

### Enrich Existing
| Page | What to Add |
|------|-------------|
| Iconography | App icon grid & keyline, SF Symbols browser (searchable), variable color, symbol effects (bounce, pulse, wiggle), custom symbol guide |
| Spacing | Add layout margins section, alignment grid visual |

### New Shared Components
- none (uses existing GlassPanel, SpecTable, Preview)

### Sidebar Update
```
Foundations
  Overview
  Typography
  Colors
  Spacing & Layout   ← rename from "Spacing"
  Layout System       ← NEW
  Elevation & Depth   ← NEW
  Iconography         ← enriched
```

---

## Wave 2 — Missing Core Components (Part 1)
**Goal:** The most-used missing components — pickers, text views, popovers, tab views.
**Duration:** 1–2 sessions

### New Component Files
| File | Exports |
|------|---------|
| `Picker.jsx/.css` | `GlassDatePicker`, `GlassTimePicker`, `GlassColorPicker`, `GlassOptionPicker` |
| `Overlay.jsx/.css` | `GlassPopover`, `GlassTooltip`, `GlassSheet` (with detents) |

### New Pages
| Page | Route | Content |
|------|-------|---------|
| Pickers | `/pickers` | Date (inline calendar, compact, wheels), Time (wheels, digital), Color (spectrum, sliders, swatches), Option (wheel, menu, inline) |
| Text Views | `/text-views` | Multi-line editor, attributed text, markdown render, placeholder |
| Popovers | `/popovers` | Standard (4 arrow dirs), tip/discovery, adaptive (sheet on compact) |
| Tab Views | `/tab-views` | Top tabs (segmented, scrollable), page-style (swipeable + dots), sidebar+detail |

### Enrich Existing
| Page | What to Add |
|------|-------------|
| Feedback > Sheets | Add detents (half/full/custom), scrollable sheet, form sheet |

### Sidebar Update
```
Components
  Buttons
  Inputs
  Pickers             ← NEW
  Text Views           ← NEW
  Navigation
  Tab Views            ← NEW
  Popovers             ← NEW
  Feedback
  Content
  Menus
```

---

## Wave 3 — Missing Core Components (Part 2)
**Goal:** Token fields, combo boxes, rating, tooltips, breadcrumbs, image views.
**Duration:** 1–2 sessions

### New Component Files
| File | Exports |
|------|---------|
| `Data.jsx/.css` | `GlassRating`, `GlassTokenField`, `GlassActivityRings` |
| `Media.jsx/.css` | `GlassImage`, `GlassGallery`, `GlassImageWell` |
| `Nav.jsx/.css` | `GlassPathControl`, `GlassStatusBar` |
| (add to `Overlay.jsx`) | `GlassTooltip` |

### New Pages
| Page | Route | Content |
|------|-------|---------|
| Token Fields | `/token-fields` | Tag input, pill styles, removable tokens, overflow (wrap/scroll/+N) |
| Combo Box | `/combo-box` | Text+dropdown, autocomplete, multi-select combo |
| Rating | `/rating` | Star rating (0–5, half, interactive), compact, custom glyphs |
| Image Views | `/image-views` | Content modes, corner masking, placeholder/skeleton, async loading, gallery |
| Tooltips | `/tooltips` | Standard, rich (title+desc+shortcut), arrow directions, hover delay |
| Breadcrumbs | `/breadcrumbs` | Path control (standard, pop-up style, truncation) |

### Enrich Existing
| Page | What to Add |
|------|-------------|
| Content | Activity rings, image views section |

### Sidebar Update
```
Components
  ...existing...
  Token Fields         ← NEW
  Combo Box            ← NEW
  Rating               ← NEW
  Image Views          ← NEW
  Tooltips             ← NEW
  Breadcrumbs          ← NEW
```

---

## Wave 4 — Variant Expansion
**Goal:** Enrich every existing component page with all missing variants.
**Duration:** 1–2 sessions

### No New Pages — Only Enriching Existing

| Page | Variants to Add |
|------|-----------------|
| **Buttons** | Toggle button, close/dismiss (circle-x), floating action, button menu (long-press), accessibility sizes |
| **Inputs > Toggles** | Checkbox (macOS, indeterminate), radio buttons, mini switch (watchOS) |
| **Inputs > Sliders** | Discrete (tick marks), range (dual thumb), vertical, value label |
| **Inputs > Text Fields** | Secure field (password reveal), numeric (formatted), multi-line (auto-expand), inline validation, leading/trailing icon, clear button |
| **Inputs > Search** | Scope bar, suggestions, search tokens, voice search mic |
| **Content > Lists** | Swipe actions (leading/trailing), reorderable (drag handles), expandable/accordion, selection modes (single/multi), pull to refresh, infinite scroll, empty state |
| **Feedback > Alerts** | Text input alert, destructive confirmation (type to confirm), inline banner alert |
| **Feedback > Sheets** | Detents (half/full/custom), scrollable, form sheet, confirmation sheet |
| **Navigation > Nav Bar** | Search in nav, segmented in nav, custom title view, transparent/scroll-hide |

### New Shared Components
- `GlassCheckbox`, `GlassRadio` → add to `Glass.jsx`
- `GlassRangeSlider` → add to `Glass.jsx`
- `GlassSwipeAction` → add to `Glass.jsx`

---

## Wave 5 — Core UX Patterns
**Goal:** The interaction patterns every app needs — states, flows, and behaviors.
**Duration:** 1–2 sessions

### New Pages
| Page | Route | Content |
|------|-------|---------|
| Empty States | `/empty-states` | First use, no results, error, offline — with illustrations, messages, action buttons |
| Loading States | `/loading-states` | Skeleton screens (shimmer), placeholder content, spinner variants, progress + toast |
| Error Handling | `/error-handling` | Inline field errors, error pages (404/500), retry, offline banner, toast errors |
| Drag & Drop | `/drag-drop` | Source preview, drop target, spring-loaded folders, reorder, cross-app |
| Undo & Redo | `/undo-redo` | Shake to undo, toast with undo action, edit history, 3-finger gestures |
| Keyboard Shortcuts | `/keyboard-shortcuts` | Discoverability overlay (hold ⌘), modifier keys, command palette |
| Haptic Patterns | `/haptics` | When to use which haptic, custom patterns, platform matrix |

### Enrich Existing
| Page | What to Add |
|------|-------------|
| Patterns | Add links to all new pattern pages, remove inline duplicates |

### Sidebar Update
```
Patterns
  Overview (existing Patterns page, now an index)
  Empty States         ← NEW
  Loading States       ← NEW
  Error Handling       ← NEW
  Drag & Drop          ← NEW
  Undo & Redo          ← NEW
  Keyboard Shortcuts   ← NEW
  Haptic Patterns      ← NEW
```

---

## Wave 6 — Authentication & Data Patterns
**Goal:** Sign-in flows, data management, forms.
**Duration:** 1 session

### New Pages
| Page | Route | Content |
|------|-------|---------|
| Authentication | `/auth` | Sign in with Apple (button styles, flow), passkeys, password autofill, 2FA code input |
| Forms & Validation | `/forms` | Layout (labels above), grouped sections, inline validation (live), error summary, disabled states, submit flow |
| Data Management | `/data` | File browser, iCloud sync indicators, conflict resolution, export/share, clipboard |
| Onboarding | `/onboarding` | Welcome screen, feature highlights, permission priming, progressive disclosure, skip affordance |

### Sidebar Update
```
Patterns
  ...existing...
  Authentication       ← NEW
  Forms & Validation   ← NEW
  Data Management      ← NEW
  Onboarding           ← NEW
```

---

## Wave 7 — Platform & System Integration
**Goal:** Widgets, Live Activities, notifications, media, maps, and platform-specific.
**Duration:** 1–2 sessions

### New Pages
| Page | Route | Content |
|------|-------|---------|
| Widgets | `/widgets` | Small/medium/large/extra-large, lock screen, StandBy, design grid, interactivity |
| Live Activities | `/live-activities` | Dynamic Island (compact/expanded/minimal), lock screen, StandBy |
| Notifications | `/notifications` | Banner, alert, time-sensitive, grouping, actions, summary, rich media |
| Media Playback | `/media` | Now Playing controls, PiP, AirPlay picker, audio routes, video player chrome |
| Maps & Location | `/maps` | Embedded map, annotations, directions, permission flow, accuracy |
| Platform Specifics | `/platforms` | watchOS (Digital Crown, complications, glanceable), tvOS (focus engine, remote), visionOS (ornaments, volumes, spatial), CarPlay |

### Sidebar Update
```
Platform
  Widgets              ← NEW
  Live Activities      ← NEW
  Notifications        ← NEW
  Media Playback       ← NEW
  Maps & Location      ← NEW
  Platform Specifics   ← NEW
```

---

## Wave 8 — Guidelines Completion
**Goal:** Fill every missing guideline section.
**Duration:** 1 session

### New Pages
| Page | Route | Content |
|------|-------|---------|
| Internationalization | `/i18n` | RTL layout (mirrored demos), date/time/number formatting, pluralization, text expansion (30–40% longer for DE/FI) |
| Privacy | `/privacy` | Permission request timing, purpose strings, ATT prompt, data minimization, nutrition labels |
| Performance | `/performance` | 60fps scrolling, launch time budget (400ms), image downsampling, memory, battery |
| Writing & Tone | `/writing` | UI copy rules, Apple terminology (tap not click), capitalization (title vs sentence), punctuation, error message templates |

### Enrich Existing
| Page | What to Add |
|------|-------------|
| Accessibility | Caption/subtitle standards, audio description, motor accessibility deep-dive |
| Motion | Choreography (sequenced animations), matched geometry, hero transitions |

### Sidebar Update
```
Guidelines
  Motion & Animation
  Visual Principles
  Accessibility
  Patterns
  Internationalization ← NEW
  Privacy              ← NEW
  Performance          ← NEW
  Writing & Tone       ← NEW
```

---

## Final Sidebar Structure (all 8 waves complete)

```
Foundations
  Overview
  Typography
  Colors
  Spacing & Layout
  Layout System
  Elevation & Depth
  Iconography

Components
  Buttons
  Inputs
  Pickers
  Text Views
  Token Fields
  Combo Box
  Rating
  Image Views
  Navigation
  Tab Views
  Tooltips
  Breadcrumbs
  Popovers
  Feedback
  Content
  Menus

Patterns
  Overview
  Empty States
  Loading States
  Error Handling
  Forms & Validation
  Authentication
  Onboarding
  Drag & Drop
  Undo & Redo
  Keyboard Shortcuts
  Haptic Patterns
  Data Management

Platform
  Widgets
  Live Activities
  Notifications
  Media Playback
  Maps & Location
  Platform Specifics

Guidelines
  Motion & Animation
  Visual Principles
  Accessibility
  Internationalization
  Privacy
  Performance
  Writing & Tone
```

**Total: 42 pages, ~220 components, ~150 variants**
**Coverage: ~95% of Apple HIG**

---

## Execution Rules

1. **Component-first** — build the shared component in `Glass.jsx` (or a new file) BEFORE building the page that uses it. Every component gets glass material, spring motion, and dark mode.

2. **Glass-on-interact everywhere** — any control that is tapped/dragged (toggles, sliders, pickers, steppers) gets Liquid Glass material on its active state (backdrop-filter kicks in, specular highlight appears).

3. **Spring motion everywhere** — `--spring` for interactive snaps, `--spring-soft` for layout transitions, `--ease-io` for color/opacity fades. No linear transitions. No ease-in-only.

4. **Grainy B&W preview backgrounds** — all `<Preview gradient>` containers use the dark grainy gradient. No colorful gradients.

5. **One source of truth** — tokens live in `tokens.css`, never hardcode a color/radius/shadow in a component. Use `var(--*)` always.

6. **Support files as context** — before building any page, read the corresponding `design-system-extraction/final/*.md` file and the `support/*.md` spec to get Apple's exact values and guidelines.

7. **Test after every wave** — `npm run build` must pass. Open in browser, verify dark mode, verify spring motion, verify glass effects on gradient backgrounds.
