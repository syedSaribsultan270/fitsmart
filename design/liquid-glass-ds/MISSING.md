# Missing from the Design System

Gap analysis against Apple's complete HIG.
Current coverage: ~35% of components, ~15% of patterns.

---

## Foundations

### Layout System
- **Safe Areas** — top, bottom, leading, trailing insets per platform
- **Layout Margins** — adaptive margins (compact / regular / large)
- **Alignment Grids** — column grids (4-col compact, 8-col regular, 12-col large)
- **Keyboard Layout Guide** — adaptive layout when keyboard is visible
- **Reading Direction** — LTR / RTL / vertical support

### Icons & SF Symbols (dedicated page)
- **App Icon Design** — grid, keyline shapes, layered icons, sizes per platform
- **SF Symbols Browser** — searchable grid of all symbol categories
- **Rendering Modes** — monochrome, hierarchical, palette, multicolor (interactive demos)
- **Variable Color** — animated percentage-based fills
- **Symbol Effects** — appear, disappear, bounce, scale, pulse, replace, wiggle
- **Custom Symbols** — template creation, alignment, weight matching

### Elevation & Depth
- **Z-Index Scale** — content, sticky, overlay, popover, modal, toast
- **Material Layers** — content layer vs control layer (Liquid Glass rule)
- **Scroll Edge Effects** — soft edge, hard edge, variable blur

---

## Components — Missing Entirely

### Pickers
- **Date Picker** — inline calendar, compact date, wheels
- **Time Picker** — wheels, digital input
- **Color Picker / Color Well** — spectrum, sliders, swatches, custom palette
- **Option Picker** — wheel picker (iOS), menu picker, inline picker

### Text Views
- **Multi-line Text Editor** — scrollable, with placeholder
- **Attributed Text** — bold, italic, links, lists inline
- **Markdown / Rich Text** — rendered rich content

### Popovers
- **Standard Popover** — arrow directions (top, bottom, leading, trailing)
- **Tip Popover** — feature discovery callout
- **Adaptive Popover** — becomes sheet on compact width

### Tab Views
- **Top Tabs** — segmented style, scrollable
- **Page-style Tabs** — swipeable pages with dots
- **Sidebar + Detail** — master-detail tab on iPad

### Combo Box
- **Text + Dropdown** — filterable dropdown suggestions
- **Autocomplete** — inline completion
- **Multi-select Combo** — tag input with suggestions

### Token Field
- **Tag Input** — add/remove tokens via typing
- **Token Styles** — rounded pill, removable (x), colored
- **Overflow** — wrap vs scroll vs "+N more"

### Rating Indicator
- **Star Rating** — 0–5, half-star, read-only, interactive
- **Compact Rating** — single number + star glyph
- **Custom Glyphs** — hearts, thumbs, custom icons

### Image Views
- **Content Modes** — aspect fill, aspect fit, scale to fill, center
- **Corner Masking** — rounded rect, circle, squircle, custom path
- **Placeholder** — skeleton loading, blur hash, solid color
- **Async Loading** — progressive JPEG, fade-in transition
- **Gallery** — horizontal scroll, zoom, page indicator

### Image Well (macOS)
- **Drop Zone** — drag-and-drop image target
- **Preview Thumbnail** — shows current selection

### Path Control (Breadcrumb)
- **Standard** — clickable segments with separators
- **Pop-up Style** — each segment opens a dropdown
- **Truncation** — middle ellipsis for long paths

### Tooltip / Hover Hint
- **Standard Tooltip** — appears after hover delay
- **Rich Tooltip** — title + description + shortcut
- **Arrow Direction** — top, bottom, left, right

### Status Bar
- **iOS Status Bar** — light / dark content, hidden, animated transitions
- **Large Title Collapse** — scroll-to-collapse behavior

### Web View
- **Embedded Browser** — in-app web content
- **Reader Mode** — simplified reading view
- **SafariViewController** — system browser sheet

### Ornaments (visionOS)
- **Toolbar Ornament** — floating toolbar near window edge
- **Tab Bar Ornament** — glass tab bar floating in space
- **Bottom Ornament** — anchored to bottom of volume

### Activity Rings
- **Ring Display** — single / triple concentric progress rings
- **Size Variants** — small (complication), medium, large (detail)
- **Color Coding** — move (red), exercise (green), stand (blue)

### Dock Menu (macOS)
- **Static Items** — fixed menu items
- **Dynamic Items** — app-state-based items
- **Separator Groups** — grouped sections

---

## Components — Partially Covered, Need More

### Buttons — missing variants
- **Toggle Button** — pressed/unpressed state (like bold in toolbar)
- **Close / Dismiss Button** — circle-x glass button
- **Floating Action Button** — visionOS / iPadOS style
- **Button Menu** — button that opens a menu on long-press
- **Accessibility Sizes** — large content size button scaling

### Toggles — missing variants
- **Checkbox** (macOS) — square check, indeterminate state
- **Radio Button** (macOS) — grouped exclusive selection
- **Switch Sizes** — mini (watchOS 31x19), standard (51x31)

### Sliders — missing variants
- **Discrete Slider** — snaps to steps, with tick marks
- **Range Slider** — dual-thumb min/max selection
- **Vertical Slider** — volume-style vertical
- **Slider with Value Label** — floating label showing current value

### Text Fields — missing variants
- **Secure Field** — password with reveal toggle
- **Numeric Field** — number pad, formatted (currency, phone)
- **Multi-line Field** — auto-expanding textarea
- **Field with Inline Validation** — green check / red x states
- **Field with Leading/Trailing Icon** — icon inside the field
- **Clear Button** — x button to clear content

### Search — missing variants
- **Scope Bar** — filter tabs below search (All, Images, Videos)
- **Search Suggestions** — recent, trending, type-ahead
- **Search Tokens** — filter pills inside search field
- **Voice Search** — microphone button

### Lists — missing variants
- **Swipe Actions** — leading (pin, flag) and trailing (delete, archive)
- **Reorderable List** — drag handles, reorder animation
- **Expandable / Accordion** — collapsible sections
- **Selection Modes** — single select, multi-select with checkmarks
- **Pull to Refresh** — loading spinner on overscroll
- **Load More / Infinite Scroll** — pagination at bottom
- **Empty State** — illustration + message when no items

### Alerts — missing variants
- **Text Input Alert** — alert with a text field inside
- **Destructive Confirmation** — require typing to confirm
- **Inline Alert / Banner** — non-modal alert bar at top

### Sheets — missing variants
- **Sheet Detents** — medium (half), large (full), custom height
- **Scrollable Sheet** — content scrolls within sheet
- **Form Sheet** — sheet with form fields and submit
- **Confirmation Sheet** — action sheet with message

### Navigation Bar — missing variants
- **Search in Nav Bar** — integrated search field
- **Segmented in Nav Bar** — scope switcher in nav
- **Custom Title View** — logo or segmented control as title
- **Transparent / Scroll-hide** — fades out on scroll

---

## Patterns — Missing Entirely

### Core UX Patterns
- **Onboarding** — welcome flow, permission priming, feature discovery
- **Empty States** — first use, no results, error, offline
- **Loading States** — skeleton screens, shimmer, placeholder content
- **Error Handling** — inline errors, error pages, retry actions, offline banner
- **Undo / Redo** — shake to undo, toast with undo action, edit history
- **Drag and Drop** — source preview, drop target highlight, spring-loaded folders
- **Pull to Refresh** — spinner, custom animation, content update
- **Pagination** — infinite scroll, page numbers, load more button
- **Haptic Patterns** — when to use which haptic, custom patterns
- **Keyboard Shortcuts** — discoverability, modifier keys, command palette

### Authentication
- **Sign in with Apple** — button styles, flow, name/email sharing
- **Passkeys** — biometric authentication UI
- **Password Autofill** — field association, strong password suggestion
- **Two-Factor** — code input field (6-digit), auto-fill from SMS

### Data Management
- **File Management** — document browser, file provider, recent files
- **iCloud Sync** — sync status indicators, conflict resolution
- **Data Export** — share sheet, export formats
- **Clipboard** — paste permissions, universal clipboard

### Platform-Specific Patterns
- **Widgets** — small, medium, large, extra-large, lock screen
- **Live Activities** — Dynamic Island, lock screen, StandBy
- **App Clips** — card, launch, full app upsell
- **Spotlight / App Intents** — search results, shortcuts, Siri integration
- **SharePlay** — shared context, group activities
- **StoreKit** — in-app purchase, subscription, paywall design

### System Integration
- **Notifications** — banner, alert, time-sensitive, summary, grouping, actions
- **Camera Access** — photo picker, camera capture, video recording
- **Location** — permission request, accuracy levels, background tracking
- **Contacts** — contact picker, access patterns
- **Calendar** — event creation, date selection
- **Health Data** — HealthKit charts, permissions, sharing
- **Maps** — embedded map, annotations, directions
- **Media Playback** — now playing, controls, picture-in-picture
- **Printing** — print dialog, page layout, preview

---

## Guidelines — Missing

### Internationalization
- **RTL Layout** — mirrored UI, bidirectional text
- **Date / Time Formatting** — locale-aware, relative dates
- **Number Formatting** — decimal separators, currency
- **Pluralization** — string interpolation rules
- **Text Expansion** — German/Finnish text is 30–40% longer than English

### Privacy
- **Permission Requests** — timing, purpose strings, progressive disclosure
- **Tracking Transparency** — ATT prompt best practices
- **Data Minimization** — collect only what's needed
- **Privacy Nutrition Labels** — App Store requirements

### Performance
- **60fps Scrolling** — offscreen rendering, cell reuse
- **Launch Time** — cold start budget (400ms), splash screens
- **Memory** — image downsampling, cache management
- **Battery** — background activity, location accuracy, networking

### Writing & Tone
- **UI Copy** — button labels, error messages, empty states
- **Terminology** — Apple-specific terms (tap not click, swipe not drag)
- **Capitalization** — title case for buttons, sentence case for labels
- **Punctuation** — no periods on labels, ellipsis for truncation

---

## Summary

| Category | Covered | Missing | Coverage |
|----------|---------|---------|----------|
| Foundations | 4 | 3 | 57% |
| Components | 16 | 28 | 36% |
| Component Variants | ~40 | ~70 | 36% |
| Patterns | 7 | 44 | 14% |
| Guidelines | 4 | 4 | 50% |
| **Total** | **~71** | **~149** | **~32%** |
