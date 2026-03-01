# FitGenius AI — Master Build Plan
> Flutter · Dart · Gemini API (Free Tier) · Local-First Architecture
> Design System: `design_system.jsx` | App Spec: `fitgenius_app_design.docx`

---

## 0. Flutter Path
```
export PATH="$PATH:/Users/vyro/development/flutter/bin"
```
Always prefix flutter/dart commands with the above PATH export.

---

## 1. Project Identity

| Field | Value |
|---|---|
| App Name | FitGenius AI |
| Bundle ID | com.fitgenius.ai |
| Flutter | 3.38.5 (stable) |
| Dart | 3.10.4 |
| Project Root | `/Users/vyro/Downloads/fitsmart2.0/fitgenius_app/` |

---

## 2. Design System (Non-Negotiable)

### Color Tokens
```dart
// Brand
lime       = #BDFF3A  (primary CTA, active states, brand)
limeMuted  = #9AD42A  (hover, pressed states)
limeGlow   = rgba(189,255,58,0.15)
coral      = #FF6B6B  (fat, error, destructive)
cyan       = #3ADFFF  (protein, links, info)

// Backgrounds (OLED dark stack)
bg.primary    = #0A0A0C  (root background)
bg.secondary  = #111114
bg.tertiary   = #18181C
bg.elevated   = #1F1F24

// Surfaces
surface.card       = #16161A
surface.cardBorder = #2A2A30
surface.input      = #111114
surface.inputFocus = #BDFF3A  (lime on focus)

// Text
text.primary   = #F0F0F2
text.secondary = #A0A0A8
text.tertiary  = #6B6B75
text.inverse   = #0A0A0C
text.link      = #3ADFFF

// Semantic
success = #34D399 | successBg = rgba(52,211,153,0.12)
warning = #FBBF24 | warningBg = rgba(251,191,36,0.12)
error   = #F87171 | errorBg   = rgba(248,113,113,0.12)
info    = #60A5FA | infoBg    = rgba(96,165,250,0.12)

// Macros (consistent across ALL charts/badges)
protein  = #3ADFFF (cyan)
carbs    = #BDFF3A (lime)
fat      = #FF6B6B (coral)
fiber    = #A78BFA (purple)
calories = #FBBF24 (amber)
```

### Typography
```
display:    40sp / w800 / tracking -1.5
h1:         32sp / w700 / tracking -0.8
h2:         24sp / w700 / tracking -0.5
h3:         20sp / w600 / tracking -0.3
body:       15sp / w400 / height 1.55
bodyMedium: 15sp / w500 / height 1.55
caption:    13sp / w500 / tracking 0.2
overline:   11sp / w700 / tracking 1.5 / UPPERCASE
mono:       13sp / w500 / JetBrains Mono
```

### Spacing Scale
`[0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96, 128]`

### Border Radii
`none=0, sm=6, md=10, lg=14, xl=20, full=9999`

### Principles
1. Hierarchy through luminance (darker = less important)
2. Color is functional: macros always use macro colors
3. Touch targets ≥ 48dp always
4. Progressive disclosure: summary → detail → raw data
5. Offline-first visual: skeleton loaders, optimistic updates

---

## 3. Tech Stack

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.6.2

  # Local Database
  drift: ^2.22.1            # SQLite ORM
  drift_flutter: ^0.2.4
  sqlite3_flutter_libs: ^0.5.26

  # Key-Value Storage
  hive_flutter: ^1.1.0
  hive: ^2.2.3

  # AI / Networking
  google_generative_ai: ^0.4.6
  http: ^1.2.2
  connectivity_plus: ^6.1.1

  # Image Handling
  image_picker: ^1.1.2
  flutter_image_compress: ^2.3.0
  cached_network_image: ^3.4.1

  # Animations
  flutter_animate: ^4.5.0
  lottie: ^3.1.3
  rive: ^0.13.14

  # Charts / Visualization
  fl_chart: ^0.69.0

  # Utilities
  intl: ^0.19.0
  uuid: ^4.5.1
  path_provider: ^2.1.5
  shared_preferences: ^2.3.4
  permission_handler: ^11.3.1
  device_info_plus: ^10.1.2

  # UI Extras
  shimmer: ^3.0.0
  flutter_svg: ^2.0.17
  dotted_border: ^2.1.0

dev_dependencies:
  drift_dev: ^2.22.1
  build_runner: ^2.4.13
  riverpod_generator: ^2.4.3
  flutter_gen_runner: ^5.7.0
```

---

## 4. Project Structure

```
fitgenius_app/
├── lib/
│   ├── main.dart
│   ├── app.dart                    # MaterialApp + theme
│   ├── router.dart                 # go_router config
│   │
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart     # All color tokens
│   │   │   ├── app_typography.dart # TextStyle tokens
│   │   │   ├── app_spacing.dart    # Spacing/radius
│   │   │   └── app_theme.dart      # ThemeData
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── gemini_constants.dart
│   │   ├── utils/
│   │   │   ├── tdee_calculator.dart
│   │   │   ├── macro_calculator.dart
│   │   │   ├── date_utils.dart
│   │   │   └── validators.dart
│   │   └── widgets/                # Shared design system components
│   │       ├── app_button.dart
│   │       ├── app_card.dart
│   │       ├── app_text_field.dart
│   │       ├── macro_bar.dart
│   │       ├── calorie_ring.dart
│   │       ├── streak_badge.dart
│   │       ├── xp_progress_bar.dart
│   │       ├── skeleton_loader.dart
│   │       ├── bottom_nav.dart
│   │       └── ai_insight_card.dart
│   │
│   ├── features/
│   │   ├── onboarding/
│   │   │   ├── screens/
│   │   │   │   ├── onboarding_flow.dart    # Parent controller
│   │   │   │   ├── step_welcome.dart       # Step 0: Splash
│   │   │   │   ├── step_mission.dart       # Step 1: Goal selection
│   │   │   │   ├── step_bio.dart           # Step 2: Age/gender
│   │   │   │   ├── step_body_stats.dart    # Step 3: Height/weight
│   │   │   │   ├── step_location.dart      # Step 4: City/country
│   │   │   │   ├── step_activity.dart      # Step 5: Activity level
│   │   │   │   ├── step_dream_body.dart    # Step 6: Target body type
│   │   │   │   ├── step_sleep.dart         # Step 7: Sleep schedule
│   │   │   │   ├── step_diet.dart          # Step 8: Meal preferences
│   │   │   │   ├── step_budget.dart        # Step 9: Monthly budget
│   │   │   │   ├── step_targets.dart       # Step 10: Target weight
│   │   │   │   └── step_ai_setup.dart      # Step 11: AI profile gen
│   │   │   ├── widgets/
│   │   │   │   ├── onboarding_progress.dart
│   │   │   │   ├── goal_card.dart
│   │   │   │   ├── body_type_card.dart
│   │   │   │   └── diet_type_chip.dart
│   │   │   └── providers/
│   │   │       └── onboarding_provider.dart
│   │   │
│   │   ├── dashboard/
│   │   │   ├── screens/
│   │   │   │   └── dashboard_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── calorie_ring_card.dart
│   │   │   │   ├── macro_summary_card.dart
│   │   │   │   ├── meal_timeline.dart
│   │   │   │   ├── workout_today_card.dart
│   │   │   │   ├── streak_card.dart
│   │   │   │   └── quick_log_fab.dart
│   │   │   └── providers/
│   │   │       └── dashboard_provider.dart
│   │   │
│   │   ├── nutrition/
│   │   │   ├── screens/
│   │   │   │   ├── nutrition_screen.dart
│   │   │   │   ├── log_meal_screen.dart
│   │   │   │   ├── camera_capture_screen.dart
│   │   │   │   ├── meal_detail_screen.dart
│   │   │   │   └── meal_plan_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── meal_log_card.dart
│   │   │   │   ├── food_item_tile.dart
│   │   │   │   ├── macro_donut_chart.dart
│   │   │   │   └── ai_analysis_panel.dart
│   │   │   ├── models/
│   │   │   │   ├── meal_log.dart
│   │   │   │   ├── food_item.dart
│   │   │   │   └── meal_plan.dart
│   │   │   └── providers/
│   │   │       └── nutrition_provider.dart
│   │   │
│   │   ├── workouts/
│   │   │   ├── screens/
│   │   │   │   ├── workouts_screen.dart
│   │   │   │   ├── active_workout_screen.dart
│   │   │   │   ├── exercise_detail_screen.dart
│   │   │   │   └── workout_plan_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── exercise_card.dart
│   │   │   │   ├── set_logger.dart
│   │   │   │   ├── rest_timer.dart
│   │   │   │   └── volume_chart.dart
│   │   │   ├── models/
│   │   │   │   ├── exercise.dart
│   │   │   │   ├── workout_log.dart
│   │   │   │   └── workout_plan.dart
│   │   │   └── providers/
│   │   │       └── workout_provider.dart
│   │   │
│   │   ├── progress/
│   │   │   ├── screens/
│   │   │   │   └── progress_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── weight_chart.dart
│   │   │   │   ├── measurement_radar.dart
│   │   │   │   ├── progress_photo_card.dart
│   │   │   │   ├── adherence_stats.dart
│   │   │   │   └── pr_badge.dart
│   │   │   └── providers/
│   │   │       └── progress_provider.dart
│   │   │
│   │   ├── ai_coach/
│   │   │   ├── screens/
│   │   │   │   └── ai_coach_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── chat_bubble.dart
│   │   │   │   ├── typing_indicator.dart
│   │   │   │   └── suggested_prompts.dart
│   │   │   └── providers/
│   │   │       └── ai_coach_provider.dart
│   │   │
│   │   └── settings/
│   │       ├── screens/
│   │       │   └── settings_screen.dart
│   │       └── providers/
│   │           └── settings_provider.dart
│   │
│   ├── services/
│   │   ├── gemini_client.dart      # Core AI service + rate limiting
│   │   ├── meal_analysis_service.dart
│   │   ├── plan_generation_service.dart
│   │   ├── nutrition_service.dart
│   │   ├── workout_service.dart
│   │   └── progress_service.dart
│   │
│   ├── database/
│   │   ├── app_database.dart       # Drift database definition
│   │   ├── tables/
│   │   │   ├── user_tables.dart
│   │   │   ├── nutrition_tables.dart
│   │   │   ├── workout_tables.dart
│   │   │   └── progress_tables.dart
│   │   └── daos/
│   │       ├── user_dao.dart
│   │       ├── nutrition_dao.dart
│   │       ├── workout_dao.dart
│   │       └── progress_dao.dart
│   │
│   └── models/
│       ├── user_profile.dart
│       ├── user_goals.dart
│       ├── onboarding_data.dart
│       └── gamification.dart
│
├── assets/
│   ├── animations/     # Lottie/Rive files
│   ├── images/
│   └── fonts/
│
├── pubspec.yaml
└── CLAUDE.md
```

---

## 5. Gamification System

### XP & Levels
- Log a meal: +10 XP
- AI meal analysis: +15 XP
- Complete workout: +25 XP
- Hit all macros: +20 XP
- Log water: +5 XP
- Daily streak bonus: +5 XP × streak day
- New PR: +50 XP + badge

### Level Thresholds
```
Level 1  "Rookie"        0 – 100 XP
Level 2  "Grinder"       100 – 300 XP
Level 3  "Hustler"       300 – 600 XP
Level 4  "Achiever"      600 – 1000 XP
Level 5  "Warrior"       1000 – 1500 XP
Level 6  "Beast"         1500 – 2200 XP
Level 7  "Legend"        2200 – 3000 XP
Level 8  "FitGenius"     3000+ XP
```

### Streak System
- Daily logging streak (meals + workout)
- Visual fire animation at 3, 7, 14, 30, 60, 90 days
- Streak freeze available (1/week earned, 2 max saved)

### Badges / Achievements
- First Log, 7-Day Streak, 30-Day Streak, 100-Day Streak
- Protein King (hit protein 7 days straight)
- Macro Master (hit all macros 3 days straight)
- PR Crusher (5 PRs in a month)
- AI Foodie (100 AI meal analyses)
- Planner (complete a full weekly plan)
- Gym Rat (20 workouts in a month)

### Daily Challenges (rotating)
- "Hit 150g protein today" → +30 XP
- "Log all 3 meals" → +20 XP
- "Complete today's workout" → +25 XP
- "Stay within 50 cal of target" → +25 XP

---

## 6. Onboarding Flow (Creative & Gamified)

### Philosophy
- Feels like a game character creation, not a form
- Each step has a distinct visual personality
- Animated transitions between steps
- Micro-feedback on every selection
- Progress shown as a dotted path (not a boring %)

### Step 0: Welcome Splash
- Full-screen animated Lottie (muscles + lightning bolt)
- "FitGenius AI" title with lime glow effect
- "Your AI fitness coach is waiting" subtitle
- "Begin Your Journey" CTA (lime button)
- No data collected

### Step 1: The Mission (Goal)
- Header: "Choose Your Mission, Warrior"
- 6 large cards with icons + gradient borders:
  - 🔥 Burn Fat — "Lean & mean"
  - 💪 Build Muscle — "Get swole"
  - ⚡ Do Both — "Recomp"
  - 🏆 Athletic Performance — "Get fast & strong"
  - ❤️ Just Stay Healthy — "Feel amazing"
  - 🎯 Maintain Weight — "Stay perfect"
- Selected card gets lime glow border + scale animation
- Tapping plays a satisfying haptic

### Step 2: About You (Bio)
- Header: "Tell Us About Yourself"
- Gender: Large animated buttons (Male/Female/Non-binary/Prefer not to say)
  - Each has a fun character silhouette
- Age: Custom drum-roll picker (not a boring text field)
  - Highlights age with a lime glow ring

### Step 3: Body Stats
- Header: "Your Current Stats"
- Height: Animated vertical ruler with sliding thumb
  - Shows cm/ft toggle
  - Ruler animates as you scroll
- Weight: Circular dial-style picker
  - Shows kg/lbs toggle
  - Subtle number crunch animation

### Step 4: Location
- Header: "Where Are You Based?"
- Country: Searchable list with flag emojis
- City: Text field with auto-complete
- Purpose shown: "We use this for weather-aware suggestions"

### Step 5: Activity Level
- Header: "How Active Are You? (Be Honest 😅)"
- 5 animated cards on a horizontal scroll:
  - 🛋️ Couch Potato — "Desk job, minimal exercise"
  - 🚶 Lightly Active — "1-3 workouts/week"
  - 🏃 Moderately Active — "3-5 workouts/week"
  - 🔥 Very Active — "6-7 workouts/week"
  - ⚡ Athlete Mode — "2x/day training"
- Card grows + glows on select

### Step 6: Dream Body
- Header: "What's Your Dream Physique?"
- Visual body type selector with illustrated figures
- Body fat % range shown per type
- 3 options per gender (lean/athletic/bulk)
- Swipe to compare

### Step 7: Sleep Goals
- Header: "When Do You Rest, Warrior?"
- Moon/sun time picker for bedtime + wake time
- Shows calculated sleep duration
- Night sky animation in background
- "Sleep = gains" micro-copy

### Step 8: Meal Preferences
- Header: "What Fuels Your Engine?"
- Horizontal scroll of diet type chips:
  - Everything, Vegetarian, Vegan, Pescatarian,
    Keto, Paleo, Halal, Kosher, Gluten-Free, Dairy-Free
- Multi-select with lime fill animation
- Cuisine preference (multi-select): Indian, Mediterranean,
  Asian, American, Mexican, Italian, Middle Eastern, etc.
- Disliked ingredients text field

### Step 9: Monthly Budget
- Header: "How Much Can You Invest in Your Nutrition?"
- Animated slider with tiers:
  - 💸 Under $100 — "Budget-friendly meals"
  - 🥗 $100–$250 — "Balanced meal preps"
  - 🥩 $250–$500 — "Premium ingredients"
  - 👑 $500+ — "No limits"
- Slider thumb shows animated dollar emoji

### Step 10: Your Targets
- Header: "Where Are You Headed?"
- Target weight: Same dial picker as Step 3
- Timeline: "How fast?" — 4 pace options
  - 🐢 Slow & Steady (0.25 kg/week) — "Sustainable"
  - 🏃 Steady Pace (0.5 kg/week) — "Recommended"
  - 🔥 Aggressive (0.75 kg/week) — "Challenging"
  - ⚡ Maximum (1 kg/week) — "Extreme, consult doctor"
- Target bed/wake time confirmation (from step 7)
- Workout days per week picker (1-7, visual day chips)

### Step 11: AI Profile Analysis
- Header: "Analyzing Your Profile..."
- Animated AI "thinking" visualization (particle effect)
- Sequentially reveals computed stats:
  - TDEE: 2,847 kcal
  - Daily Target: 2,347 kcal
  - Protein: 180g
  - Carbs: 240g
  - Fat: 65g
- Each stat animates in with a number counter
- "Your personalized plan is ready!" with confetti burst
- "Unlock Your Dashboard" CTA

### Transition Mechanic
- Each step slides in from right with spring physics
- Progress: Animated dotted path across top (like a map route)
- "You're X% through your setup" sublabel
- Back arrow always visible (no trapping)
- "Skip" available for optional steps only

---

## 7. Screen Navigation Map

```
Shell (BottomNavBar - 5 tabs)
├── Tab 0: Dashboard (Home)
│   ├── Calorie Ring Card
│   ├── Macro Summary
│   ├── Meal Timeline
│   ├── Today's Workout Card
│   ├── Streak + XP Cards
│   ├── Daily Challenge Card
│   ├── AI Insight Card
│   └── FAB → Quick Log Sheet
│
├── Tab 1: Nutrition
│   ├── Daily Macro Overview
│   ├── Meal Log List (by meal)
│   ├── + Log Meal → Log Meal Screen
│   │   ├── Camera Capture → AI Analysis
│   │   ├── Text Description
│   │   └── Search Food DB
│   └── Meal Plans Tab
│       └── Weekly Plan View
│
├── Tab 2: Workouts
│   ├── Today's Plan Card
│   ├── Exercise Library
│   ├── Active Workout Screen (full-screen)
│   │   ├── Set Logger
│   │   └── Rest Timer
│   └── Workout Plans
│
├── Tab 3: Progress
│   ├── Weight Chart (line + moving avg)
│   ├── Body Measurements
│   ├── Progress Photos
│   ├── Strength Progress
│   └── Adherence Stats
│
└── Tab 4: AI Coach
    ├── Chat Interface
    ├── Suggested Prompts
    └── Context Summary (what AI knows)

Additional Routes:
├── /onboarding         (no nav bar)
├── /settings
└── /camera
```

---

## 8. Gemini API Integration

### Model & Config
- Model: `gemini-1.5-flash` (free tier: 15 RPM, 1M TPM, 1500 RPD)
- All responses use JSON mode with strict schemas
- System instruction reused across calls (implicit caching)

### Request Types & Token Budgets
| Request | Input Tokens | Output Tokens |
|---|---|---|
| Meal photo analysis | ~800 (512px img + context) | ~300 |
| Meal text parsing | ~400 | ~200 |
| AI meal feedback | ~500 | ~150 |
| Weekly meal plan | ~600 | ~2000 |
| Workout plan gen | ~500 | ~1500 |
| AI coaching reply | ~700 | ~400 |
| Daily insight | ~300 | ~150 |

### Caching
- Meal analysis: cache by photo hash indefinitely
- Meal plans: cache 24h
- Daily insight: cache until next day
- Workout plans: cache 7 days

### Rate Limit Handling
- Token bucket: track RPM locally
- Low-priority queue for insights/plans
- Offline queue with retry on reconnect
- Subtle "AI Busy" indicator in UI

### Fallback Strategy
- Meal analysis → local FTS food search
- Plan gen → template plans (5 meal, 8 workout templates)
- Chat → cached FAQ answers

---

## 9. Database Schema (Drift)

### Core Tables
```sql
-- user_profiles (time-series snapshots)
id, created_at, weight_kg, body_fat_pct

-- user_goals
primary_goal, target_weight_kg, pace_kg_per_week,
daily_calories, protein_g, carbs_g, fat_g

-- user_preferences
gender, age, height_cm, activity_level,
dietary_restrictions (JSON), cuisine_prefs (JSON),
monthly_budget_usd, city, country

-- sleep_schedule
bedtime_hour, bedtime_min, wake_hour, wake_min

-- meal_logs
id, date, meal_type (breakfast/lunch/dinner/snack),
total_calories, protein_g, carbs_g, fat_g, fiber_g,
notes, photo_path, ai_analysis_json

-- meal_log_items
id, meal_log_id, food_item_id, quantity_g,
calories, protein_g, carbs_g, fat_g

-- food_items (seeded USDA + user custom)
id, name, brand, calories_per_100g,
protein_per_100g, carbs_per_100g, fat_per_100g,
fiber_per_100g, is_custom

-- meal_plans (AI generated)
id, created_at, start_date, end_date,
ai_generated, plan_json

-- workout_logs
id, date, plan_id, duration_min,
total_volume_kg, notes, completed

-- workout_sets
id, workout_log_id, exercise_id,
set_number, reps, weight_kg, rpe,
is_warmup, is_pr

-- exercises (seeded 500+)
id, name, category, primary_muscles (JSON),
secondary_muscles (JSON), equipment (JSON),
difficulty, instructions, is_custom

-- workout_plans
id, created_at, goal, duration_weeks,
plan_json, is_active

-- body_measurements
id, date, weight_kg, chest_cm, waist_cm,
hips_cm, left_arm_cm, right_arm_cm,
left_thigh_cm, right_thigh_cm, body_fat_pct

-- gamification
total_xp, current_level, current_streak,
longest_streak, streak_freezes_available,
badges_json, last_log_date

-- daily_challenges
id, date, challenge_type, target_value,
completed, xp_reward

-- ai_cache
request_hash, response_json, created_at, ttl_hours
```

---

## 10. Build Order

### Phase 1 — Foundation (Core Setup)
1. Create Flutter project
2. Install all dependencies
3. Configure `pubspec.yaml`
4. Implement `core/theme/` (all design tokens)
5. Implement shared widgets (AppButton, AppCard, AppTextField)
6. Set up Drift database with all tables
7. Configure Riverpod + go_router

### Phase 2 — Onboarding
8. Build onboarding flow controller
9. Implement all 12 onboarding steps with animations
10. Wire onboarding state to Hive preferences
11. TDEE/macro computation on completion
12. AI profile generation animation screen

### Phase 3 — Dashboard
13. Calorie ring (custom painter)
14. Macro bars
15. Meal timeline
16. Streak + XP display
17. Daily challenge card
18. AI insight card (Gemini integration)
19. Quick log FAB

### Phase 4 — Nutrition
20. Meal log list view
21. Manual food search + log
22. Camera capture screen
23. Gemini meal analysis (photo + text)
24. AI feedback card
25. Meal plan view

### Phase 5 — Workouts
26. Exercise library (search + filter)
27. Active workout screen
28. Set logger + rest timer
29. PR detection + celebration
30. AI workout plan generation

### Phase 6 — Progress
31. Weight chart (fl_chart)
32. Body measurements input
33. Progress photos (side-by-side compare)
34. Strength progression chart
35. Adherence stats

### Phase 7 — AI Coach
36. Chat UI (bubbles, typing indicator)
37. Context assembly from all providers
38. Gemini chat with full user context
39. Suggested prompts

### Phase 8 — Gamification
40. XP award system
41. Level-up animation
42. Badge unlock notifications
43. Streak fire animations
44. Daily challenge refresh

---

## 11. Key Implementation Notes

### Animations
- Use `flutter_animate` for most transitions
- Rive for complex character/mascot animations (onboarding)
- Lottie for confetti, fire, celebrations
- All page transitions: slide + fade with spring curve

### Custom Painters
- Calorie ring: `CustomPainter` with arc drawing
- Macro donut: `CustomPainter` with multiple arcs
- Weight chart: `fl_chart` LineChart with moving average

### Gemini Client Architecture
```dart
// Singleton with rate limiting
class GeminiClient {
  final _cache = LruCache<String, String>(maxSize: 100);
  final _tokenBucket = TokenBucket(rpm: 15, rpd: 1500);

  Future<T> request<T>({
    required String prompt,
    required String cacheKey,
    required T Function(Map) parser,
    int ttlHours = 24,
    Priority priority = Priority.normal,
  })
}
```

### Context Compression for AI
```json
{
  "u": {"age": 28, "gender": "m", "goal": "muscle", "kcal": 2800},
  "today": {"logged_kcal": 1850, "p": 120, "c": 180, "f": 45},
  "week_avg": {"kcal": 2650, "adherence": 0.78},
  "streak": 12,
  "last_workout": "2024-01-15"
}
```

### Offline First Pattern
1. All data written to SQLite immediately (optimistic)
2. Gemini calls queued if offline
3. UI never blocks on AI response
4. Skeleton → real data swap, never full loading screens

---

## 12. Assets Required

### Lottie Animations (to source or create)
- `onboarding_welcome.json` — fitness character animation
- `ai_thinking.json` — particle/brain analysis animation
- `confetti_burst.json` — celebration effect
- `fire_streak.json` — streak flame
- `level_up.json` — level-up burst
- `pr_badge.json` — PR achievement
- `checkmark_success.json` — completion check

### Fonts
- Inter (primary) — weights 400, 500, 600, 700, 800
- JetBrains Mono (numbers/code)

---

## 13. Environment Config

```dart
// lib/core/constants/env.dart
class Env {
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
}
```

Run with: `flutter run --dart-define=GEMINI_API_KEY=your_key_here`

---

## 14. Memory Notes (Persistent)
- Flutter at `/Users/vyro/development/flutter/bin/flutter`
- Always use PATH: `export PATH="$PATH:/Users/vyro/development/flutter/bin"`
- Project inside: `/Users/vyro/Downloads/fitsmart2.0/fitgenius_app/`
- Gemini model: `gemini-1.5-flash` (free tier)
- Design tokens strictly from `design_system.jsx`
- All colors are OLED dark with lime/coral/cyan accents
