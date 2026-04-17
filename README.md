# FitSmart AI

AI-powered fitness and nutrition companion. Flutter app with Firebase backend, multi-tier AI stack (Gemini → Groq → on-device Gemma → templates), and iOS 26 Liquid Glass UI.

## Repo Layout

| Path | Purpose |
|---|---|
| [`fitsmart_app/`](fitsmart_app/) | The Flutter project — app source, platform runners, tests |
| [`docs/`](docs/) | All markdown references (data map, flows, auth, Liquid Glass spec) |
| [`docs/diagrams/`](docs/diagrams/) | Excalidraw + chart exports |
| [`design/liquid-glass-ds/`](design/liquid-glass-ds/) | React reference design system (iOS 26 calibrated tokens, motion, components) |
| [`ml/gemma3-1b-it-int4.task`](ml/) | On-device Gemma 3 1B int4 model (downloaded at runtime, cached here) |
| [`ml/training_data/`](ml/training_data/) | Food-image training set (khana) + taxonomy |
| [`scripts/`](scripts/) | Repo health + maintenance shell scripts |

## Product Aspects

1. **Auth & Onboarding** — Firebase anonymous, profile, goal config
2. **Dashboard & Home** — daily rings, macros, water, weekly review
3. **Nutrition** — meal logging, macro tracking, AI meal analysis
4. **Fitness / Workouts** — quick logs, workout plans, PR tracking
5. **Progress** — weight, measurements, trend charts
6. **AI Coach** — chat + tool-use (log via AI, read context) with quota enforcement
7. **Platform / Infrastructure** — Drift schema, Firestore sync + rules, analytics, quota service
8. **Design System & UI** — Liquid Glass, Spark mascot, motion, shared widgets

## Getting Started

```bash
cd fitsmart_app
flutter pub get
flutter run --dart-define=GEMINI_API_KEY=<key>
```

See [`fitsmart_app/README.md`](fitsmart_app/README.md) for the full dev setup, and [`CLAUDE.md`](CLAUDE.md) for project rules.
