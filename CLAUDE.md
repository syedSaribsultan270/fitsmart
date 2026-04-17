# FitSmart AI — Project Rules

## Identity
- **App:** FitSmart AI · **Package:** `fitsmart_app` · **Firebase:** `fitsmart-9c7da`
- **Flutter 3.38.5 / Dart 3.10.4** · App root: `fitsmart_app/` (not `fitgenius_app`)

## Reference Docs (read before big changes, don't re-derive)
- `docs/SYSTEM_DATA_MAP.md` — every field across Firestore / Drift / SharedPreferences
- `docs/APP_FLOWS.md` — user-facing screen flows
- `docs/AUTH_FLOW.md` — auth state machine + Firestore recovery
- **`docs/liquid-glass.md`** — Apple iOS 26 Liquid Glass spec + our Flutter implementation rules. **Read before any UI surface work.**
- **`design/liquid-glass-ds/`** — companion React reference DS calibrated against real iOS 26 (tokens, motion, components). Design source-of-truth.
- `docs/diagrams/` — Excalidraw flow + chart exports
- `MEMORY.md` — always in context; check index BEFORE spawning Explore

## Commands
Always prefix with: `export PATH="$PATH:/Users/vyro/development/flutter/bin" && cd fitsmart_app &&`

```bash
flutter analyze                                            # required before commit (hook auto-runs on edits)
dart run build_runner build --delete-conflicting-outputs   # after schema/provider/annotation changes
flutter test                                               # when touched area has tests
flutter run --dart-define=GEMINI_API_KEY=<key>             # local run
```

## Design System — Non-Negotiable
Use `AppColors.*`, `AppSpacing.*`, `AppTypography.*` from `lib/core/theme/`. **Never hardcode values.**

- **lime** `#BDFF3A` — primary CTA, active states
- **coral** `#FF6B6B` — fat, errors, destructive
- **cyan** `#3ADFFF` — protein, links, info
- **OLED backgrounds:** `#0A0A0C` → `#111114` → `#18181C` → `#1F1F24`
- **Macro colors (immutable):** protein=cyan, carbs=lime, fat=coral, fiber=purple `#A78BFA`, calories=amber `#FBBF24`

Touch targets ≥ 48dp. Progressive disclosure (summary → detail). Skeleton loaders, never full-screen spinners.

## Architecture
- **State:** Riverpod only — no business logic in StatefulWidget
- **Nav:** GoRouter (`router.dart`) — no `Navigator.push`
- **Persistence:** Drift (SQLite) for relational · SharedPreferences for key-value · **no Hive** (removed)
- **Auth:** Firebase anonymous (`uidProvider`) · Firestore path: `users/{uid}/...`
- **AI fallback chain:** Gemini 2.5 Flash → Groq Llama 3.3 70B → on-device Gemma 3 1B int4 → template

## Animation
- Transitions / micro-interactions → `flutter_animate`
- Mascots / character → Rive
- Celebrations (confetti, fire, level-up) → Lottie
- **Apple-native spring** for "iOS feel" motion: `Cubic(0.34, 1.56, 0.64, 1.0)` (per Liquid Glass spec)

## Liquid Glass — iOS 26 (READ THE FULL SPEC)

We follow Apple's iOS 26 Liquid Glass design language. **The complete rules + Flutter implementation are in [`docs/liquid-glass.md`](docs/liquid-glass.md).** The React companion DS at [`design/liquid-glass-ds/`](design/liquid-glass-ds/) is the calibrated design source-of-truth.

**The non-negotiables** (full reasoning in the doc):

- **Three-layer model** — glass lives ONLY on the **navigation layer** (nav bars, tab bars, sheets, popovers, controls). Content (cards, lists, charts, text) is solid. Never glass-on-glass.
- **Two glass tiers in our stack:**
  - **Tier 1 — true backdrop blur** (`LiquidGlass` widget) → modal sheets, snackbars, overlays that genuinely float above scrollable content
  - **Tier 2 — solid surface with glass cues** (`LiquidAppBar` pattern) → app bars, bottom nav. Solid bgPrimary fill + top-edge highlight gradient + accent rim border. **No `BackdropFilter` here** — it samples body pixels and bleeds.
- **Tinting is semantic only** — accent rim/glow on CTAs (paywall hero, upgrade banner). Decorative tinting is forbidden.
- **Macro colors are immutable** — protein cyan, carbs lime, fat coral, fiber purple, calories amber. Never accent-tinted.
- **Accent flows through glass** — read `context.colors.lime` (user's chosen accent), never hardcode `AppColors.lime` on themed surfaces.
- **Snackbars are SOLID** — transient text needs maximum contrast; drops down from above, never bottom.
- **Apple-faithful values** (per [`design/liquid-glass-ds/src/styles/tokens.css`](design/liquid-glass-ds/src/styles/tokens.css)): blur 48px + saturate(180%), spring `cubic-bezier(0.34, 1.56, 0.64, 1)`, motion 200/300/450ms.

When in doubt, open `docs/liquid-glass.md` and walk the §17 decision tree.

## Dart Gotchas
- `clamp()` returns `num` → `.toDouble()`
- `Switch` → `activeThumbColor` (not `activeColor`)
- Dart records: `.name` not `['name']`
- Gemini images: `Uint8List` + `dart:typed_data`, not `List<int>`
- Widget tests: add `splashFactory: NoSplash.splashFactory` to theme (avoids `ink_sparkle.frag`)

## Security
- Debug UI behind `if (kDebugMode)` from `package:flutter/foundation.dart`
- API keys via `--dart-define=` only — never hardcoded, never committed
- Firestore rules must end with catch-all: `match /{document=**} { allow read, write: if false; }`

---

## Multi-Role Lens
Every response filters through: **10x Engineer** (simplest solution, no debt) · **Designer** (premium feel, intentional interactions) · **PM/Growth** (does it move retention/activation/revenue?) · **Marketer** (shareable wow moment?) · **Analyst** (measurable in 2 weeks?) · **Founder** (right thing, right now?).

Surface the most relevant lens. **Push back on scope that doesn't earn its complexity.**

## Session Protocol

**Classify every prompt first** — don't skip to tools.

| Signals | Type | Approach |
|---|---|---|
| error pasted · "fix" · "broken" · "not working" | **Debug** | Read target → diagnose → patch → analyze |
| "add" · "build" · "implement" · "create" | **Build** | Discovery → plan → confirm → execute → analyze |
| "what" · "how" · "show" · "explain" · "map" · "find" | **Explore** | Explore subagent (never flood main context) |
| "check" · "audit" · "review" · "QA" · "health" | **Audit** | `/health-check` skill |
| "design" · "suggest" · "whatever you think" | **Creative** | Discovery → propose via multi-role lens → await direction |
| auth · Firestore rules · AI orchestrator | **Sensitive** | Plan mode regardless of type |

### Discovery (Build + Creative only)
Ask **3–5** questions from the menu below — pick the axes with the most uncertainty. Skip entirely for scoped asks ("fix typo on line 42"). Do NOT ask what's inferable from context.

- **Founder:** real pain or nice-to-have?
- **PM:** which user — new/power/returning, free/premium?
- **Growth:** which metric — retention, activation, revenue?
- **Designer:** what emotion? premium vs. functional?
- **Engineer:** 80/20 MVP? offline / perf constraints?
- **Analyst:** how do we know in 2 weeks it worked?
- **Marketer:** shareable moment? screenshot-worthy?

Then: propose plan → await approval → implement.

### Before touching code
1. Check **MEMORY.md index** first (already in context — costs nothing).
2. Read target files — **never cold-edit**.
3. 3+ file explorations → **Explore subagent**, don't burn main context.

### After every code change
- `flutter analyze --no-pub` (hook runs automatically — surface errors/warnings only).
- Run nearby test file if it exists.

### Task done
- State: what changed, which files, what passed.
- Save **non-obvious discoveries** to memory (don't duplicate existing entries).
- Ask if anything else before wrapping.

## Efficiency Defaults
- **Parallelize independent tool calls** — multiple reads, greps, globs in one turn.
- **Prefer dedicated tools:** Edit/Grep/Glob/Read over Bash (`cat`, `find`, `grep`, `sed`).
- **Reuse reference docs** (`docs/SYSTEM_DATA_MAP.md` etc.) instead of re-greping the repo.
- **Terse updates:** one sentence per status tick, not paragraphs.
- **No preamble, no trailing summary** when the diff already speaks.
