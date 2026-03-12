# FitSmart AI — Technical Documentation

> **Version:** 1.0.0 · **Platform:** Flutter 3.38.5 / Dart 3.10.4  
> **Architecture:** Offline-First · OLED Dark · Riverpod · Drift · Firebase · Multi-Tier AI (Gemini + Groq + On-Device Gemma + RAG/Templates)  
> **Bundle ID:** `com.fitsmart.fitsmart_app` · **Display Name:** FitSmart

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture](#2-architecture)
3. [Tech Stack](#3-tech-stack)
4. [Project Structure](#4-project-structure)
5. [Design System](#5-design-system)
6. [Features](#6-features)
7. [Database Schema](#7-database-schema)
8. [AI Integration — Multi-Tier Orchestration (Gemini + Groq + Gemma + RAG)](#8-ai-integration--multi-tier-orchestration-gemini--groq--gemma--rag)
9. [Authentication & Authorization](#9-authentication--authorization)
10. [State Management](#10-state-management)
11. [Navigation & Routing](#11-navigation--routing)
12. [Gamification System](#12-gamification-system)
13. [Nutrition Engine](#13-nutrition-engine)
14. [Widget Library](#14-widget-library)
15. [Data Assets](#15-data-assets)
16. [Security](#16-security)
17. [Setup & Development](#17-setup--development)
18. [Build & Deployment](#18-build--deployment)
19. [Environment Variables](#19-environment-variables)
20. [Firestore Rules](#20-firestore-rules)
21. [API Reference — Core AI Services](#21-api-reference--core-ai-services)
22. [API Reference — FoodKnowledgeService](#22-api-reference--foodknowledgeservice)
23. [Error Handling](#23-error-handling)
24. [Performance Considerations](#24-performance-considerations)
25. [Appendix](#25-appendix)

---

## 1. Project Overview

**FitSmart AI** is a comprehensive AI-powered fitness and nutrition companion built with Flutter. It combines local-first data storage (Drift/SQLite), cloud synchronization (Firebase), and a multi-tier AI orchestration stack (Gemini + Groq + on-device Gemma + local RAG/templates) to deliver personalized meal analysis, workout planning, and coaching—all wrapped in a meticulously designed OLED-dark interface.

### Core Value Propositions

| Capability | Description |
|---|---|
| **AI Meal Analysis** | Photograph or describe meals; structured AI returns itemized nutrition with health scores |
| **AI Coach** | Conversational coach with full access to the user's profile, history, and goals |
| **RAG-Grounded Responses** | Client-side Retrieval-Augmented Generation pipeline using a curated Indian food knowledge base |
| **Workout Tracking** | Log exercises, track sets/reps/weight, personal records (PRs), and AI-generated workout plans |
| **Progress Analytics** | Weight trend charts, strength progression, body measurements, and weekly summaries |
| **Gamification** | XP system with 8 levels, 10 badges, daily streaks, streak freezes, and milestone animations |
| **Offline-First** | Full functionality without internet; cloud sync when online via Firebase |

### Target Platforms

| Platform | Status | Notes |
|---|---|---|
| Android | ✅ Production | `minSdk` via Flutter defaults, Java 17, Kotlin |
| iOS | ✅ Production | Portrait orientation, ATS enforced |
| Web | ✅ Supported | WASM-compatible Drift, Firebase popup auth |
| macOS | 🔧 Development | Runner configured |

---

## 2. Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────┐
│                    UI Layer                          │
│  Screens · Widgets · Animations · Theme System       │
│  (Flutter Material 3 + flutter_animate)              │
├─────────────────────────────────────────────────────┤
│                State Management                      │
│  flutter_riverpod                                    │
│  StateNotifier · Provider · StreamProvider            │
│  FutureProvider                                      │
├─────────────────────────────────────────────────────┤
│                Service Layer                         │
│  AiOrchestratorService · GeminiClient · GroqClient    │
│  LocalLlmService · LocalAiFallbackService             │
│  FoodKnowledgeService · AuthService                   │
│  FirestoreService · SnackbarService                  │
├─────────────────────────────────────────────────────┤
│                Data Layer                            │
│  ┌─────────────┐    ┌──────────────┐                │
│  │ Drift/SQLite │    │   Firebase   │                │
│  │ (Primary DB) │◄──►│ (Cloud Sync) │                │
│  │ 10 tables    │    │ Firestore    │                │
│  │ Local-first  │    │ Auth         │                │
│  └─────────────┘    │ Analytics    │                │
│                      │ Crashlytics  │                │
│                      └──────────────┘                │
├─────────────────────────────────────────────────────┤
│                External APIs                         │
│  Google Gemini 2.5 Flash + Groq Llama 3.3 70B        │
│  On-device Gemma 2 2B (MediaPipe, Android/iOS)       │
│  Google Sign-In (authentication)                     │
└─────────────────────────────────────────────────────┘
```

### Design Principles

1. **Offline-First** — The local SQLite database (via Drift) is the source of truth. Firebase syncs in the background.
2. **Hierarchy Through Luminance** — OLED dark theme with layered backgrounds (0A→11→18→1F hex).
3. **Color is Functional** — Macros always use their designated colors (cyan/lime/coral/purple).
4. **Progressive Disclosure** — Complex features surface contextually; skeleton loaders for async states.
5. **Touch Targets ≥ 48dp** — All interactive elements meet Material accessibility guidelines.

---

## 3. Tech Stack

### Dependencies

| Category | Package | Version | Purpose |
|---|---|---|---|
| **State** | `flutter_riverpod` | ^2.6.1 | Reactive state management |
| **Navigation** | `go_router` | ^14.6.2 | Declarative routing with deep links |
| **Local DB** | `drift` | ^2.22.1 | Type-safe SQLite ORM |
| | `drift_flutter` | ^0.2.4 | Flutter-specific database factories |
| | `sqlite3_flutter_libs` | ^0.5.26 | Native SQLite binaries |
| **Firebase** | `firebase_core` | ^3.6.0 | Firebase initialization |
| | `firebase_auth` | ^5.3.0 | Authentication |
| | `cloud_firestore` | ^5.4.0 | Cloud document database |
| | `firebase_analytics` | ^11.3.0 | Usage analytics |
| | `firebase_crashlytics` | ^4.1.0 | Crash reporting |
| **AI** | `google_generative_ai` | ^0.4.6 | Gemini API client |
| | `flutter_mediapipe_chat` | ^1.0.0 | On-device Gemma inference (Android/iOS) |
| **Auth** | `google_sign_in` | ^6.2.2 | Google OAuth |
| **Network** | `connectivity_plus` | ^6.1.1 | Online/offline detection |
| | `http` | ^1.2.2 | Groq REST client + model download |
| **Image** | `image_picker` | ^1.1.2 | Camera/gallery access |
| | `flutter_image_compress` | ^2.3.0 | Image compression before AI analysis |
| **Animation** | `flutter_animate` | ^4.5.0 | Declarative animation chains |
| **Charts** | `fl_chart` | ^0.69.0 | Line, bar, and pie charts |
| **Utility** | `crypto` | ^3.0.7 | SHA-256 hashing (cache keys) |
| | `intl` | ^0.19.0 | Date/number formatting |
| | `path_provider` | ^2.1.5 | On-device model file storage path |
| | `shared_preferences` | ^2.3.4 | Key-value persistence |
| | `shimmer` | ^3.0.0 | Skeleton loading effects |

### Dev Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_lints` | ^5.0.0 | Lint rules |
| `drift_dev` | ^2.22.1 | Drift code generation |
| `build_runner` | ^2.4.13 | Code generation runner |

### Fonts

| Family | Weights | Usage |
|---|---|---|
| **Inter** | 400, 500, 600, 700, 800 | All UI text |
| **JetBrains Mono** | 500 | Monospaced data displays |
| **Noto Color Emoji** | — | Cross-platform emoji rendering |

---

## 4. Project Structure

```
fitsmart_app/
├── lib/
│   ├── main.dart                          # Entry point, Firebase init, error handling
│   ├── app.dart                           # MaterialApp.router, theme, system UI
│   ├── router.dart                        # GoRouter config, auth redirects
│   ├── firebase_options.dart              # Generated Firebase config
│   │
│   ├── core/                              # Shared foundations
│   │   ├── constants/
│   │   │   └── app_constants.dart         # XP values, Gemini limits, TDEE multipliers
│   │   ├── theme/
│   │   │   ├── app_colors.dart            # Complete color token system (76 lines)
│   │   │   ├── app_typography.dart         # 8 text styles (88 lines)
│   │   │   ├── app_spacing.dart           # Spacing scale + border radii
│   │   │   └── app_theme.dart             # ThemeData assembly (165 lines)
│   │   ├── utils/
│   │   │   └── tdee_calculator.dart       # Mifflin-St Jeor BMR + macro split
│   │   └── widgets/                       # Reusable UI components
│   │       ├── app_button.dart            # AppButton + PillButton
│   │       ├── app_card.dart              # AppCard + AccentCard + GlowCard
│   │       ├── app_shell.dart             # Bottom navigation shell (5 tabs)
│   │       ├── calorie_ring.dart          # Animated circular progress
│   │       ├── macro_bar.dart             # Horizontal progress bar + MacroChip
│   │       ├── skeleton_loader.dart       # Shimmer loading placeholders
│   │       └── xp_progress_bar.dart       # XP bar + XpGainToast
│   │
│   ├── data/
│   │   └── database/
│   │       ├── app_database.dart          # Drift DB: 10 tables, DAOs (307 lines)
│   │       └── database_provider.dart     # Singleton + Riverpod provider
│   │
│   ├── models/
│   │   ├── gamification.dart              # GamificationState + Badges
│   │   └── onboarding_data.dart           # 21-field onboarding model
│   │
│   ├── providers/
│   │   ├── auth_provider.dart             # authUserProvider, uidProvider
│   │   ├── connectivity_provider.dart     # Online/offline stream
│   │   ├── food_knowledge_provider.dart   # RAG knowledge base provider
│   │   ├── gemini_provider.dart           # GeminiClient DI via --dart-define
│   │   └── settings_provider.dart         # AppSettings + persistence
│   │
│   ├── services/
│   │   ├── auth_service.dart              # Firebase Auth facade (155 lines)
│   │   ├── database_seeder.dart           # First-launch exercise seeding
│   │   ├── firestore_service.dart         # Cloud sync: profiles, logs, insights
│   │   ├── food_knowledge_service.dart    # RAG retrieval engine (264 lines)
│   │   ├── gemini_client.dart             # Gemini API client + cache (597 lines)
│   │   └── snackbar_service.dart          # Global snackbar access
│   │
│   └── features/
│       ├── auth/
│       │   └── screens/
│       │       ├── login_screen.dart
│       │       ├── signup_screen.dart
│       │       └── forgot_password_screen.dart
│       │
│       ├── onboarding/
│       │   ├── screens/                   # 13 onboarding step screens
│       │   │   ├── onboarding_shell.dart
│       │   │   ├── goal_screen.dart
│       │   │   ├── gender_screen.dart
│       │   │   ├── age_screen.dart
│       │   │   ├── body_stats_screen.dart
│       │   │   ├── activity_level_screen.dart
│       │   │   ├── body_type_screen.dart
│       │   │   ├── target_weight_screen.dart
│       │   │   ├── sleep_screen.dart
│       │   │   ├── dietary_screen.dart
│       │   │   ├── location_screen.dart
│       │   │   ├── workout_days_screen.dart
│       │   │   └── summary_screen.dart
│       │   └── providers/
│       │       └── onboarding_provider.dart
│       │
│       ├── dashboard/
│       │   ├── screens/
│       │   │   └── dashboard_screen.dart  # Main hub (1147 lines)
│       │   └── providers/
│       │       └── dashboard_provider.dart
│       │
│       ├── nutrition/
│       │   └── screens/
│       │       └── log_meal_screen.dart   # Camera / Text / Search tabs
│       │
│       ├── ai_coach/
│       │   └── screens/
│       │       └── ai_coach_screen.dart   # Conversational AI (1093 lines)
│       │
│       ├── workouts/
│       │   └── screens/
│       │       ├── workouts_screen.dart   # Today / Plans / Library tabs (1113 lines)
│       │       └── active_workout_screen.dart
│       │
│       ├── progress/
│       │   └── screens/
│       │       └── progress_screen.dart   # Weight / Strength / Body / Stats (919 lines)
│       │
│       └── settings/
│           └── screens/
│               ├── settings_screen.dart
│               ├── edit_profile_screen.dart
│               ├── edit_goals_screen.dart
│               ├── edit_diet_screen.dart
│               ├── edit_sleep_screen.dart
│               ├── faq_screen.dart
│               └── privacy_screen.dart
│
├── assets/
│   ├── animations/                        # Lottie/Rive animation files
│   ├── data/
│   │   ├── exercises.json                 # Exercise library (~200+ entries)
│   │   ├── common_foods.json              # Common food nutrition data
│   │   ├── indian_foods.json              # 80 Indian dishes (RAG knowledge base)
│   │   └── taxonomy.csv                   # Food classification hierarchy
│   ├── fonts/                             # Inter, JetBrains Mono, Noto Color Emoji
│   └── images/                            # App imagery
│
├── android/                               # Android platform config
├── ios/                                   # iOS platform config
├── macos/                                 # macOS platform config
├── web/                                   # Web platform config
├── test/                                  # Unit & widget tests
├── pubspec.yaml                           # Dependencies & assets
├── analysis_options.yaml                  # Dart analyzer config
├── firestore.rules                        # Firebase security rules
└── README.md                              # Quick start guide
```

---

## 5. Design System

### 5.1 Color Tokens

All colors are defined in `lib/core/theme/app_colors.dart` as compile-time constants.

#### Brand Colors

| Token | Hex | Usage |
|---|---|---|
| `lime` | `#BDFF3A` | Primary CTA, active states, XP bar |
| `limeMuted` | `#9AD42A` | Gradient endpoints, secondary emphasis |
| `limeGlow` | `rgba(189,255,58,0.15)` | Glow backgrounds, active pill states |
| `coral` | `#FF6B6B` | Fat macro, danger accents |
| `cyan` | `#3ADFFF` | Protein macro, links |

#### Background Stack (OLED Dark)

| Token | Hex | Layer |
|---|---|---|
| `bgPrimary` | `#0A0A0C` | Scaffold background (true black) |
| `bgSecondary` | `#111114` | Bottom nav, input fills |
| `bgTertiary` | `#18181C` | Shimmer bases, tertiary surfaces |
| `bgElevated` | `#1F1F24` | Elevated panels, modals |
| `bgOverlay` | `#0A0A0C` @ 85% | Overlay scrims |

#### Surface Colors

| Token | Hex | Usage |
|---|---|---|
| `surfaceCard` | `#16161A` | Card backgrounds |
| `surfaceCardBorder` | `#2A2A30` | Card borders, dividers |
| `surfaceInput` | `#111114` | Text input fill |
| `surfaceInputFocus` | `#BDFF3A` | Focused input border |

#### Text Hierarchy

| Token | Hex | Usage |
|---|---|---|
| `textPrimary` | `#F0F0F2` | Headlines, body text |
| `textSecondary` | `#A0A0A8` | Labels, captions |
| `textTertiary` | `#6B6B75` | Hints, overlines |
| `textInverse` | `#0A0A0C` | Text on lime/CTA buttons |

#### Semantic Colors

| Token | Hex | Usage |
|---|---|---|
| `success` | `#34D399` | Positive feedback |
| `warning` | `#FBBF24` | Caution states, calorie macro |
| `error` | `#F87171` | Errors, over-limit indicators |
| `info` | `#60A5FA` | Informational highlights |

#### Macro Colors (Consistent Across All Charts)

| Macro | Color | Token |
|---|---|---|
| Protein | Cyan `#3ADFFF` | `macroProtein` |
| Carbs | Lime `#BDFF3A` | `macroCarbs` |
| Fat | Coral `#FF6B6B` | `macroFat` |
| Fiber | Purple `#A78BFA` | `macroFiber` |
| Calories | Amber `#FBBF24` | `macroCalories` |

### 5.2 Typography

Defined in `lib/core/theme/app_typography.dart`. Font family: **Inter**.

| Style | Size | Weight | Tracking | Line Height | Usage |
|---|---|---|---|---|---|
| `display` | 40sp | w800 | -1.5 | 1.1 | Hero numbers |
| `h1` | 32sp | w700 | -0.8 | 1.2 | Page titles |
| `h2` | 24sp | w700 | -0.5 | 1.25 | Section headers |
| `h3` | 20sp | w600 | -0.3 | 1.3 | Card titles |
| `body` | 15sp | w400 | — | 1.55 | Body text |
| `bodyMedium` | 15sp | w500 | — | 1.55 | Emphasized body |
| `caption` | 13sp | w500 | 0.2 | 1.4 | Labels, metadata |
| `overline` | 11sp | w700 | 1.5 | 1.3 | Uppercase labels |
| `mono` | 13sp | w500 (JetBrains Mono) | — | 1.5 | Data/code |

### 5.3 Spacing Scale

```
Index:  0   1   2   3   4   5   6   7   8   9  10  11  12  13
Value:  0   4   8  12  16  20  24  32  40  48  64  80  96 128
```

Named constants: `xs=4`, `sm=8`, `md=12`, `lg=16`, `xl=24`, `xxl=32`, `pagePadding=20`, `cardPadding=16`.

### 5.4 Border Radii

| Token | Value | Usage |
|---|---|---|
| `none` | 0 | — |
| `sm` | 6 | Chips, small elements |
| `md` | 10 | Inputs, buttons |
| `lg` | 14 | Cards, containers |
| `xl` | 20 | Modals, sheets |
| `full` | 9999 | Pills, avatars |

---

## 6. Features

### 6.1 Authentication (`features/auth/`)

Three screens: **Login**, **Sign Up**, **Forgot Password**.

- Anonymous sign-in for frictionless first launch
- Email/password registration and login
- Google Sign-In (native on mobile, popup on web)
- Anonymous-to-authenticated account linking (email or Google)
- Password reset via Firebase
- Display name management

### 6.2 Onboarding (`features/onboarding/`)

A 13-step guided flow collecting:

| Step | Screen | Data Collected |
|---|---|---|
| 1 | `goal_screen` | Primary fitness goal |
| 2 | `gender_screen` | Gender |
| 3 | `age_screen` | Age |
| 4 | `body_stats_screen` | Height, weight, body fat % |
| 5 | `activity_level_screen` | Activity level |
| 6 | `body_type_screen` | Target body type |
| 7 | `target_weight_screen` | Target weight, weight-change pace |
| 8 | `sleep_screen` | Bedtime, wake time |
| 9 | `dietary_screen` | Dietary restrictions, cuisine preferences, disliked ingredients |
| 10 | `location_screen` | Country, city |
| 11 | `workout_days_screen` | Training days per week |
| 12 | `summary_screen` | Review & confirm |
| 13 | — | TDEE calculation → dashboard |

Data model: `OnboardingData` (21 fields) with `isComplete` validation. Stored in SharedPreferences via Hive box.

### 6.3 Dashboard (`features/dashboard/`)

The main hub displaying:

- **Personalized greeting** with time-of-day awareness
- **Calorie ring** — animated circular progress (consumed vs. target)
- **Macro bars** — protein, carbs, fat with color-coded progress
- **Today's meals** — scrollable list of logged meals
- **Daily AI insight** — Gemini-generated motivational tip
- **XP progress bar** — level, XP, and streak display
- **Streak badge** — fire emoji for streaks > 2 days
- **Water tracker** — daily water intake with quick-add
- **Quick actions** — log meal, start workout

**Provider:** `dashboard_provider.dart` exposes `todaysMealsProvider`, `dailyNutritionProvider`, `gamificationProvider`.

### 6.4 Nutrition (`features/nutrition/`)

Three input methods via tabbed interface:

| Tab | Method | AI Integration |
|---|---|---|
| **📸 Camera** | Photograph meal | `analyzeMealPhoto()` with RAG grounding |
| **✏️ Text** | Natural language description | `analyzeMealText()` with RAG grounding |
| **🔍 Search** | Fuzzy search across knowledge base | `FoodKnowledgeService.search()` |

**RAG Integration:**
- Camera tab: Builds grounding with `buildGroundingContext('meal food Indian dish', maxResults: 12)`
- Text tab: Builds grounding from the user's exact input text
- Search tab: Client-side fuzzy search with veg/non-veg badges, descriptions, match-quality indicators

### 6.5 AI Coach (`features/ai_coach/`)

Full conversational interface with:

- **Complete user context** injected into every message (profile, goals, today's nutrition, meals, workouts, PRs, body measurements, weight history, gamification, active plans)
- **RAG grounding** — food knowledge base injected when discussing food/nutrition
- **Chat history** — last 10 messages maintained for context continuity
- **Image support** — users can attach photos to chat messages
- **Structured advice** — meal plans, workout plans, progress analysis
- **Personality** — encouraging, data-driven, emoji-sparse

### 6.6 Workouts (`features/workouts/`)

Three tabs:

| Tab | Content |
|---|---|
| **Today** | Scheduled workouts, quick-start options |
| **Plans** | AI-generated multi-week workout programs |
| **Library** | Exercise database (seeded from `exercises.json`), search & filter by muscle group |

**Active Workout Screen:** Real-time exercise logging with sets, reps, weight tracking. Automatic PR detection and XP rewards.

### 6.7 Progress (`features/progress/`)

Four analytical tabs:

| Tab | Visualizations |
|---|---|
| **Weight** | Line chart (fl_chart), trend analysis, goal progress |
| **Strength** | PR table, exercise-by-exercise progression |
| **Body** | Body measurements tracking (chest, waist, hips, bicep, thigh, etc.) |
| **Stats** | All-time totals, weekly summaries, streaks |

### 6.8 Settings (`features/settings/`)

| Sub-Screen | Functionality |
|---|---|
| **Profile** | Display name, email, photo, account linking |
| **Goals** | Edit primary goal, target weight, pace |
| **Diet** | Dietary restrictions, cuisine preferences, disliked ingredients |
| **Sleep** | Bedtime/wake time schedule |
| **FAQ** | Frequently asked questions |
| **Privacy** | Privacy policy display |

Additional settings: metric/imperial toggle, notification preferences, weekly reports, API key status, sign out, account deletion.

---

## 7. Database Schema

### Local Database — Drift (SQLite)

**Database name:** `fitsmart_db`  
**Schema version:** 2  
**File:** `lib/data/database/app_database.dart`

#### Tables

| Table | Columns | Purpose |
|---|---|---|
| `MealLogs` | id, mealType, items (JSON), totalCalories, totalProtein, totalCarbs, totalFat, totalFiber, healthScore, aiFeedback, imageHash, loggedAt | Meal entries |
| `WorkoutLogs` | id, name, exercises (JSON), durationMin, caloriesBurned, notes, loggedAt | Workout sessions |
| `WorkoutSets` | id, workoutLogId, exerciseName, setNumber, reps, weightKg, isWarmup, notes, loggedAt | Individual exercise sets |
| `Exercises` | id, name, muscleGroup, equipment, instructions, category, isCustom | Exercise library |
| `WorkoutPlans` | id, name, planJson, weeks, isActive, createdAt | AI-generated workout programs |
| `MealPlans` | id, name, planJson, days, isActive, createdAt | AI-generated meal programs |
| `BodyMeasurements` | id, chestCm, waistCm, hipsCm, bicepCm, thighCm, neckCm, shouldersCm, calfCm, measuredAt | Body tracking |
| `WeightLogs` | id, weightKg, bodyFatPct, notes, loggedAt | Weight history |
| `DailySummaries` | id, date (unique), totalCalories, totalProtein, totalCarbs, totalFat, totalFiber, waterMl, workoutCount, xpEarned | Daily aggregates |
| `AiInsights` | id, insight, icon, category, generatedAt | Cached AI insights |

#### Migration Strategy

```
v1 → v2:
  + WorkoutSets table
  + Exercises table
  + WorkoutPlans table
  + MealPlans table
  + BodyMeasurements table
  + DailySummaries.waterMl column
```

#### Inline DAOs

Each table has DAO methods defined directly in `AppDatabase`:

- **Meals:** `insertMeal`, `getMealsForDate`, `watchTodaysMeals`, `deleteMeal`, `getMealsByDateRange`
- **Workouts:** `insertWorkout`, `getRecentWorkouts`, `watchRecentWorkouts`, `deleteWorkout`
- **WorkoutSets:** `insertSets`, `getSetsForWorkout`, `getMaxWeightForExercise`, `getAllPrs`
- **Exercises:** `searchExercises`, `getExercisesByMuscle`, `getExerciseCount`, `insertExercises` (batch)
- **WeightLogs:** `insertWeight`, `getWeightHistory`, `watchWeightStream`
- **DailySummaries:** `upsertDailySummary`, `addWater`, `getSummariesForRange`

### Cloud Database — Firestore

**Document structure:**

```
users/{uid}/
  ├── profile: { ...onboarding data, tdee results }
  ├── gamification: { totalXp, streak, badges, ... }
  ├── meal_logs/{docId}: { ...meal data }
  ├── workout_logs/{docId}: { ...workout data }
  ├── weight_logs/{docId}: { ...weight data }
  └── ai_insights/{docId}: { ...insight data }
```

Features: cache-first reads on web, server timestamps, real-time stream watchers.

---

## 8. AI Integration — Multi-Tier Orchestration (Gemini + Groq + Gemma + RAG)

### 8.1 Production AI Architecture

FitSmart now uses a **4-tier resilient AI stack** via `AiOrchestratorService`:

| Tier | Engine | Purpose | Platforms |
|---|---|---|---|
| **Tier 1a** | Gemini 2.5 Flash (`GeminiClient`) | Primary cloud AI for all features | Android · iOS · Web · macOS |
| **Tier 1b** | Groq Llama 3.3 70B (`GroqClient`) | Secondary cloud AI when Gemini fails/rate-limits | Android · iOS · Web · macOS |
| **Tier 2** | Gemma 2 2B on-device (`LocalLlmService`) | Local open-ended chat/insight fallback | Android · iOS only |
| **Tier 3** | Rules + RAG templates (`LocalAiFallbackService`) | Deterministic final fallback with valid JSON shapes | All platforms |

### 8.2 Orchestration Flow

```
AI Feature Call
  │
  ▼
AiOrchestratorService
  │
  ├─ Tier 1a: Gemini (with circuit breaker + timeout)
  │     ├─ success → return
  │     └─ fail    → continue
  │
  ├─ Tier 1b: Groq (secondary cloud + timeout)
  │     ├─ success → return
  │     └─ fail    → continue
  │
  ├─ Tier 2: On-device Gemma (chat + daily insight only)
  │     ├─ model ready + success → return
  │     └─ otherwise             → continue
  │
  └─ Tier 3: Local templates/RAG (always available)
      └─ return guaranteed schema
```

### 8.3 Circuit Breaker (Gemini)

Configured in `app_constants.dart`:

- `circuitBreakerFailureThreshold = 2`
- `circuitBreakerOpenDurationSec = 120`
- `geminiRequestTimeoutSec = 15`

Behavior:

1. Two consecutive Gemini failures open the circuit.
2. While open, Gemini is skipped (saves latency).
3. After cool-down, one probe is allowed again.

### 8.4 RAG Pipeline (Grounding)

RAG remains fully active and is injected into **both cloud and on-device coach prompts**:

- Source assets: `assets/data/indian_foods.json` + `assets/data/common_foods.json`
- Retrieval: `FoodKnowledgeService.search()` (fuzzy + Levenshtein + ingredient/category scoring)
- Prompt injection: `groundingContext` is passed through orchestrator to:
  - `GeminiClient.chat()`
  - `GroqClient.chat()`
  - `LocalLlmService.buildCoachPrompt()`

### 8.5 Feature Routing by Capability

| Feature | Tier 1a | Tier 1b | Tier 2 | Tier 3 |
|---|---|---|---|---|
| `analyzeMealPhoto()` | Gemini | Groq | — | Templates (limited photo heuristic) |
| `analyzeMealText()` | Gemini | Groq | — | RAG grounded |
| `getMealFeedback()` | Gemini | Groq | — | Rules |
| `generateMealPlan()` | Gemini | Groq | — | Template plan |
| `generateWorkoutPlan()` | Gemini | Groq | — | Template program |
| `chat()` | Gemini | Groq | Gemma 2B | Pattern/RAG chat |
| `getDailyInsight()` | Gemini | Groq | Gemma 2B | Template insight |

### 8.6 Platform Support Notes

| Platform | Gemini | Groq | On-device Gemma | Final local fallback |
|---|---|---|---|---|
| Android | ✅ | ✅ | ✅ | ✅ |
| iOS | ✅ | ✅ | ✅ | ✅ |
| Web/Chrome | ✅ | ✅ | ❌ (native plugin unavailable) | ✅ |
| macOS | ✅ | ✅ | ❌ (native plugin unavailable) | ✅ |

### 8.7 Key Files

- `lib/services/ai_orchestrator_service.dart`
- `lib/services/gemini_client.dart`
- `lib/services/groq_client.dart`
- `lib/services/local_llm_service.dart`
- `lib/services/local_ai_fallback_service.dart`
- `lib/services/food_knowledge_service.dart`

### 8.8 Effective Cloud Limits (Free Tiers)

Approximate combined ceiling when both cloud providers are configured:

- Gemini: 15 RPM / 1,500 RPD
- Groq: 30 RPM / 14,400 RPD
- **Combined:** 45 RPM / 15,900 RPD (provider-dependent policies apply)

### 8.9 Gemini Client

**File:** `lib/services/gemini_client.dart` (597 lines)  
**Model:** Gemini 2.5 Flash (`gemini-2.5-flash`)  
**Provider:** `geminiClientProvider` (API key via `--dart-define`)

#### Two Model Configurations

| Model | Config | Usage |
|---|---|---|
| `_model` | `responseMimeType: 'application/json'`, temp 0.7 | Structured outputs (meal analysis, plans) |
| `_chatModel` | Freeform text, temp 0.8 | Coach conversations |

#### Rate Limits (Free Tier)

| Limit | Value |
|---|---|
| Requests/minute | 15 |
| Requests/day | 1,500 |
| Tokens/minute | 1,000,000 |

#### Caching Strategy

All structured responses are cached in-memory with configurable TTL:

| Response Type | Cache TTL | Cache Key Strategy |
|---|---|---|
| Meal photo analysis | Indefinite (0) | SHA-256 hash of image bytes (first 16 chars) |
| Meal text analysis | 24 hours | `hashCode` of description string |
| Meal feedback | 4 hours | `hashCode` of meal data JSON |
| Meal plan | 24 hours | Combined user context + days + overrides hash |
| Workout plan | 168 hours (7 days) | Combined user context + weeks hash |
| Daily insight | 16 hours | ISO date string (`YYYY-MM-DD`) |
| Chat | Not cached | — |

### 8.10 RAG Pipeline

The RAG (Retrieval-Augmented Generation) pipeline provides Gemini with verified nutritional data to ground its responses, improving accuracy for Indian cuisine recognition.

#### Architecture

```
User Input (photo/text/chat)
        │
        ▼
┌──────────────────────┐
│  FoodKnowledgeService │ ◄── assets/data/indian_foods.json (80 dishes)
│  Fuzzy Search Engine   │ ◄── assets/data/common_foods.json
│                        │
│  1. Tokenize query     │
│  2. Score all foods    │
│  3. Rank by relevance  │
│  4. Return top N       │
└──────────────────────┘
        │
        ▼ buildGroundingContext()
┌──────────────────────┐
│  Grounding Block      │  "=== FOOD KNOWLEDGE BASE ==="
│  (injected into       │  "• Biryani: 350 kcal, 12g P..."
│   Gemini prompt)      │  "• Chapati: 120 kcal, 3g P..."
└──────────────────────┘
        │
        ▼
┌──────────────────────┐
│  GeminiClient          │  User context + Grounding + Prompt
│  analyzeMealPhoto()    │  ────────────────────────────────►  Gemini 2.5 Flash
│  analyzeMealText()     │  ◄────────────────────────────────  Structured JSON
│  chat()                │
└──────────────────────┘
```

#### Search Scoring Algorithm

| Match Type | Score | Example |
|---|---|---|
| Exact name/alias match | 1.0 | Query "biryani" → entry "biryani" |
| Starts-with | 0.9 | Query "pane" → entry "paneer masala" |
| Substring | 0.75 | Query "tikka" → entry "paneer tikka" |
| Ingredient match | 0.5 | Query "potato" → entry "aloo gobi" (has "potato" in ingredients) |
| Category/dish match | 0.4–0.45 | Query "curry" → entries with category "curry" |
| Levenshtein similarity | 0.3–0.7 | Query "biryan" → entry "biryani" (edit distance 1) |

#### Grounding Injection Points

| Feature | Method | Max Results |
|---|---|---|
| Photo analysis | `buildGroundingContext('meal food Indian dish')` | 12 |
| Text analysis | `buildGroundingContext(userText)` | 8 (default) |
| AI Coach chat | `buildGroundingContext(userMessage)` | 8 |
| Search tab | Direct `search()` call (client-side only) | 10 |

### 8.11 Gemini Endpoints

| Method | Input | Output | JSON Schema |
|---|---|---|---|
| `analyzeMealPhoto()` | Image bytes + user context | Items, totals, health score, feedback | `{items[], totals, health_score, feedback, identified_items_summary}` |
| `analyzeMealText()` | Text description + user context | Items, totals, health score, feedback | `{items[], totals, health_score, feedback}` |
| `getMealFeedback()` | Meal data + user context | Personalized feedback, remaining macros | `{message, remaining_calories, remaining_protein_g, next_meal_suggestion, flag}` |
| `generateMealPlan()` | User context + days | Multi-day meal plan + grocery list | `{days[{meals[]}], grocery_list[]}` |
| `generateWorkoutPlan()` | User context + weeks | Multi-week program | `{program_name, weeks[{days[{exercises[]}]}]}` |
| `chat()` | Message + history + user context | Freeform text response | `{response, suggestions[]}` |
| `getDailyInsight()` | User context | Motivational insight | `{insight, icon, category}` |

---

## 9. Authentication & Authorization

### Auth Flow

```
App Launch
    │
    ├─── No user ───► Login Screen
    │                    ├── Email/Password Sign In
    │                    ├── Google Sign In
    │                    ├── Anonymous Sign In (Skip)
    │                    └── Sign Up → Onboarding
    │
    ├─── Anonymous user, no onboarding ───► Onboarding Flow
    │
    ├─── Anonymous user, onboarding complete ───► Dashboard
    │
    └─── Authenticated user, onboarding complete ───► Dashboard
```

### Auth Service Methods

| Method | Description |
|---|---|
| `signInAnonymously()` | Guest access, no credentials required |
| `signInWithEmail(email, password)` | Email/password authentication |
| `signUpWithEmail(email, password, name)` | New account creation |
| `signInWithGoogle()` | Native (mobile) or popup (web) OAuth |
| `linkWithEmail(email, password)` | Upgrade anonymous → email account |
| `linkWithGoogle()` | Upgrade anonymous → Google account |
| `sendPasswordReset(email)` | Password recovery email |
| `updateDisplayName(name)` | Profile name update |
| `signOut()` | Sign out + clear local state |
| `deleteAccount()` | Permanent account deletion |

### Firebase Security Rules

Per-user data isolation enforced server-side:

```javascript
function isOwner(userId) {
  return request.auth != null && request.auth.uid == userId;
}

// All reads/writes require ownership
match /users/{userId} {
  allow read, write: if isOwner(userId);
  match /{subcollection}/{docId} {
    allow read, write: if isOwner(userId);
  }
}

// Default deny
match /{document=**} { allow read, write: if false; }
```

Document size limit: ≤ 50 keys per document (enforced via `hasReasonableSize()`).

---

## 10. State Management

### Provider Architecture

FitSmart uses **flutter_riverpod** with the following provider types:

| Provider | Type | File | Purpose |
|---|---|---|---|
| `authUserProvider` | `StreamProvider<User?>` | `auth_provider.dart` | Firebase auth state stream |
| `uidProvider` | `Provider<String>` | `auth_provider.dart` | Current user UID |
| `isAuthReadyProvider` | `Provider<bool>` | `auth_provider.dart` | Auth initialization flag |
| `connectivityProvider` | `StreamProvider<bool>` | `connectivity_provider.dart` | Network status stream |
| `isOnlineProvider` | `Provider<bool>` | `connectivity_provider.dart` | Synchronous online check |
| `databaseProvider` | `Provider<AppDatabase>` | `database_provider.dart` | Drift DB singleton |
| `aiProvider` | `Provider<AiOrchestratorService>` | `gemini_provider.dart` | Unified AI entrypoint (all tiers) |
| `geminiClientProvider` | `Provider<GeminiClient>` | `gemini_provider.dart` | Gemini API client |
| `groqClientProvider` | `Provider<GroqClient?>` | `gemini_provider.dart` | Optional Groq fallback client |
| `localLlmProvider` | `Provider<LocalLlmService>` | `gemini_provider.dart` | On-device Gemma service |
| `foodKnowledgeProvider` | `Provider<FoodKnowledgeService>` | `food_knowledge_provider.dart` | RAG knowledge base |
| `foodKnowledgeLoadProvider` | `FutureProvider<void>` | `food_knowledge_provider.dart` | KB initialization |
| `settingsProvider` | `StateNotifierProvider` | `settings_provider.dart` | Persisted app settings |
| `todaysMealsProvider` | `StreamProvider` | `dashboard_provider.dart` | Today's meal stream |
| `dailyNutritionProvider` | `Provider` | `dashboard_provider.dart` | Computed daily totals |
| `gamificationProvider` | `Provider` | `dashboard_provider.dart` | Gamification state |

### Data Flow

```
User Action → Widget → ref.read(provider) → Service → Database/API
                                                  │
                              ref.watch(provider) ◄┘
                                      │
                              Widget rebuilds automatically
```

---

## 11. Navigation & Routing

### Router Configuration

**File:** `lib/router.dart`  
**Package:** `go_router` v14.6.2

### Route Map

```
/login                          → LoginScreen
/signup                         → SignupScreen
/forgot-password                → ForgotPasswordScreen
/onboarding                     → OnboardingShell (13 steps)
/                               → StatefulShellRoute (5-tab shell)
  ├── /dashboard                → DashboardScreen
  ├── /nutrition                → LogMealScreen
  │   └── /nutrition/log        → (sub-route)
  ├── /ai-coach                 → AiCoachScreen
  ├── /workouts                 → WorkoutsScreen
  │   └── /workouts/active      → ActiveWorkoutScreen
  └── /progress                 → ProgressScreen
/settings                       → SettingsScreen
  ├── /settings/edit-profile    → EditProfileScreen
  ├── /settings/edit-goals      → EditGoalsScreen
  ├── /settings/edit-diet       → EditDietScreen
  ├── /settings/edit-sleep      → EditSleepScreen
  ├── /settings/faq             → FaqScreen
  ├── /settings/privacy         → PrivacyScreen
  └── /settings/terms           → TermsScreen
```

### Navigation Shell

The main app uses `StatefulShellRoute.indexedStack` with 5 branches, preserving state across tab switches:

| Index | Tab | Icon | Route |
|---|---|---|---|
| 0 | Home | `home_rounded` | `/dashboard` |
| 1 | Nutrition | `restaurant_rounded` | `/nutrition` |
| 2 | AI Coach | `smart_toy_rounded` | `/ai-coach` |
| 3 | Workouts | `fitness_center_rounded` | `/workouts` |
| 4 | Progress | `show_chart_rounded` | `/progress` |

The AI Coach tab (index 2) features a **center CTA design** — an elevated circular button with a lime-to-green gradient and glow shadow.

### Redirect Logic

```dart
redirect: (context, state) {
  1. If no Firebase user → redirect to /login
  2. If anonymous + no onboarding → redirect to /onboarding
  3. If authenticated + no onboarding → redirect to /onboarding
  4. If onboarding complete + on auth route → redirect to /dashboard
}
```

---

## 12. Gamification System

### XP Awards

| Action | XP |
|---|---|
| Log a meal | 10 |
| AI meal analysis (photo/text) | 15 |
| Complete a workout | 25 |
| Hit all macro targets | 20 |
| Log water intake | 5 |
| New personal record (PR) | 50 |
| Daily streak (base) | 5 |

### Level Progression

| Level | Name | XP Threshold | Cumulative XP |
|---|---|---|---|
| 0 | Rookie | 0 | 0 |
| 1 | Grinder | 100 | 100 |
| 2 | Hustler | 300 | 300 |
| 3 | Achiever | 600 | 600 |
| 4 | Warrior | 1,000 | 1,000 |
| 5 | Beast | 1,500 | 1,500 |
| 6 | Legend | 2,200 | 2,200 |
| 7 | FitSmart | 3,000 | 3,000 |

### Badges (10 Available)

| Badge ID | Name | Description |
|---|---|---|
| `first_meal` | First Meal | Log your first meal |
| `first_workout` | First Workout | Complete your first workout |
| `streak_3` | On Fire | 3-day streak |
| `streak_7` | Week Warrior | 7-day streak |
| `streak_30` | Monthly Beast | 30-day streak |
| `meals_50` | Meal Master | Log 50 meals |
| `workouts_25` | Gym Rat | Complete 25 workouts |
| `perfect_day` | Perfect Day | Hit all macros in a day |
| `first_pr` | New Record | Set your first PR |
| `level_5` | Beast Mode | Reach level 5 |

### Streak System

- **Streak milestones** with fire animation: 3, 7, 14, 30, 60, 90 days
- **Streak freezes:** Max 2 stored, prevents streak loss on missed days
- **Last log date tracking** for streak continuation logic

### State Model

```dart
class GamificationState {
  int totalXp;
  int currentStreak;
  int longestStreak;
  int streakFreezesAvailable;
  List<String> unlockedBadges;
  String? lastLogDate;

  // Computed
  int get currentLevel;      // Derived from totalXp vs thresholds
  String get levelName;      // 'Rookie', 'Grinder', etc.
  double get levelProgress;  // 0.0–1.0 within current level
  int get xpToNextLevel;     // Remaining XP to next level
}
```

---

## 13. Nutrition Engine

### TDEE Calculator

**File:** `lib/core/utils/tdee_calculator.dart`  
**Formula:** Mifflin-St Jeor

```
BMR (male)   = (10 × weight_kg) + (6.25 × height_cm) - (5 × age) + 5
BMR (female) = (10 × weight_kg) + (6.25 × height_cm) - (5 × age) - 161

TDEE = BMR × Activity Multiplier
Target Calories = TDEE + Goal Adjustment (clamped 1200–6000)
```

### Activity Multipliers

| Level | Multiplier |
|---|---|
| Sedentary | 1.200 |
| Lightly Active | 1.375 |
| Moderately Active | 1.550 |
| Very Active | 1.725 |
| Extremely Active | 1.900 |

### Goal Caloric Adjustments

| Goal | Adjustment |
|---|---|
| Lose Fat | -500 kcal |
| Lose Fat (Slow) | -250 kcal |
| Maintain | 0 |
| Gain Muscle | +300 kcal |
| Gain Muscle (Aggressive) | +500 kcal |
| Recomposition | 0 |
| Athletic Performance | +200 kcal |

### Macro Split Logic

| Goal | Protein (g/kg) | Fat (% cal) | Carbs |
|---|---|---|---|
| Gain Muscle | 2.2 | 25% | Remainder |
| Lose Fat | 2.4 | 30% | Remainder |
| Recomp | 2.5 | 28% | Remainder |
| Athletic | 2.0 | 28% | Remainder |
| Maintain (default) | 1.8 | 30% | Remainder |

Carbs are clamped to a minimum of 50g.

### Output Model

```dart
class TdeeResult {
  final double bmr;
  final double tdee;
  final double targetCalories;
  final double proteinG;
  final double carbsG;
  final double fatG;
}
```

### Meal Types

Six supported meal slots: `Breakfast`, `Lunch`, `Dinner`, `Snack`, `Pre-Workout`, `Post-Workout`.

---

## 14. Widget Library

All reusable widgets are in `lib/core/widgets/`.

### AppButton

| Variant | Background | Text | Border |
|---|---|---|---|
| `primary` / `lime` | Lime `#BDFF3A` | Inverse (dark) | None |
| `secondary` | Card surface | Primary | Card border |
| `ghost` | Transparent | Lime | Lime outline |
| `danger` | Error bg | Error | Error outline |

Features: loading spinner, haptic feedback, disabled state (40% opacity), full-width toggle, custom height.

**PillButton:** Small pill-shaped toggle with animated scale feedback.

### AppCard

Three variants:
- **AppCard** — Standard card with optional tap, shadow, and custom border
- **AccentCard** — Left-colored accent stripe
- **GlowCard** — Colored border with outer glow shadow

### AppShell

The bottom navigation bar implementation with 5 tabs. Center tab (AI Coach) uses an elevated gradient circle button. Active states show lime-colored glow backgrounds.

### CalorieRing

Animated circular progress indicator using `CustomPainter`. Shows consumed/target with kcal labels. Color changes: lime (normal) → warning (>85%) → error (over target). 1200ms animation with `easeOutCubic` curve.

### MacroBar

Horizontal progress bar with color-coded fill. Includes glow shadow and over-limit error state.

**MacroChip:** Compact inline chip for displaying macros in meal cards.

### SkeletonLoader

Shimmer-based loading placeholders:
- **SkeletonBox** — Rectangular shimmer
- **SkeletonCard** — Card-shaped shimmer with border
- **DashboardSkeleton** — Full dashboard layout placeholder

### XpProgressBar

Two modes:
- **Full** — Level badge, name, progress bar, XP counter
- **Compact** — Inline horizontal layout

**XpGainToast** — Animated floating notification for XP rewards with elastic slide-in animation.

---

## 15. Data Assets

### `assets/data/exercises.json`

Pre-seeded exercise library loaded on first launch via `DatabaseSeeder`.

| Field | Type | Description |
|---|---|---|
| `name` | String | Exercise name |
| `muscleGroup` | String | Target muscle group |
| `equipment` | String | Required equipment (default: "bodyweight") |
| `instructions` | String | How to perform |
| `category` | String | "strength", "cardio", etc. |

### `assets/data/indian_foods.json`

80 Indian dishes with complete nutrition data. This is the primary RAG knowledge base.

| Field | Type | Description |
|---|---|---|
| `name` | String | Dish name |
| `category` | String | "Main Course", "Snack", "Dessert", etc. |
| `dish` | String | Sub-classification |
| `dietary` | String | "veg" or "non-veg" |
| `cal` | Number | Calories per serving |
| `p` | Number | Protein (grams) |
| `c` | Number | Carbs (grams) |
| `f` | Number | Fat (grams) |
| `fiber` | Number | Fiber (grams) |
| `serving` | String | Serving description |
| `serving_g` | Number | Serving weight in grams |
| `ingredients` | String[] | Key ingredients list |
| `aliases` | String[] | Alternative names |
| `description` | String | Brief description |

**Sample entry:**

```json
{
  "name": "Biryani",
  "category": "Main Course",
  "dish": "Rice Dish",
  "dietary": "non-veg",
  "cal": 350,
  "p": 12,
  "c": 45,
  "f": 14,
  "fiber": 2,
  "serving": "1 plate",
  "serving_g": 250,
  "ingredients": ["basmati rice", "chicken", "onion", "yogurt", "saffron", "ghee", "biryani masala"],
  "aliases": ["chicken biryani", "dum biryani"],
  "description": "Fragrant layered rice dish with marinated meat, aromatic spices, and saffron"
}
```

### `assets/data/common_foods.json`

General food items with basic nutrition data. Simpler schema: `name`, `cal`, `p`, `c`, `f`, `serving`.

### `assets/data/taxonomy.csv`

Hierarchical food classification used for training data organization:

```
Category → Sub-Category → Dish → Dietary Classification
```

---

## 16. Security

### API Key Management

| Practice | Implementation |
|---|---|
| **Never hardcoded** | API keys injected at build time via `--dart-define` |
| **Environment variables** | `GEMINI_API_KEY` + optional `GROQ_API_KEY` via `String.fromEnvironment()` |
| **Primary key required** | Gemini key required for Tier 1a startup |
| **Secondary key optional** | Groq key optional; Tier 1b auto-skips when absent |
| **Not in source control** | `.env` file is gitignored |

### Network Security

| Platform | Policy |
|---|---|
| **Android** | Cleartext HTTP disabled (default) |
| **iOS** | App Transport Security (ATS) enforced; `NSAllowsArbitraryLoads = false` |
| **All** | Gemini + Groq API calls over TLS (HTTPS only) |

### Data Security

| Aspect | Implementation |
|---|---|
| **Firebase Rules** | Per-user data isolation via `isOwner()` check |
| **Document size** | Max 50 keys per document enforced server-side |
| **Default deny** | `match /{document=**} { allow read, write: if false; }` |
| **Account deletion** | Full data purge on account deletion |

### Platform Config Files

Firebase platform configs (`google-services.json`, `GoogleService-Info.plist`) are gitignored and must be obtained from the Firebase Console.

---

## 17. Setup & Development

### Prerequisites

| Requirement | Version |
|---|---|
| Flutter SDK | 3.38.5+ |
| Dart SDK | 3.10.4+ |
| Xcode | Latest (for iOS) |
| Android Studio | Latest (for Android) |
| Firebase CLI | Latest |
| Gemini API Key | Free tier at [aistudio.google.com](https://aistudio.google.com/apikey) |

### Installation

```bash
# 1. Clone the repository
git clone <repo-url>
cd fitsmart2.0/fitsmart_app

# 2. Install Flutter dependencies
flutter pub get

# 3. Set up environment
cp .env.example .env
# Edit .env with your GEMINI_API_KEY
# Optionally add GROQ_API_KEY for secondary cloud fallback

# 4. Firebase setup (Android)
# Place google-services.json in android/app/

# 5. Firebase setup (iOS)
# Place GoogleService-Info.plist in ios/Runner/

# 6. Run the app
flutter run \
  --dart-define=GEMINI_API_KEY=your_key_here \
  --dart-define=GROQ_API_KEY=your_groq_key_here   # optional
```

### Code Generation (Drift)

If you modify database tables, regenerate the Drift code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Analysis

```bash
flutter analyze
```

---

## 18. Build & Deployment

### Debug Build

```bash
flutter run --dart-define=GEMINI_API_KEY=<key> --dart-define=GROQ_API_KEY=<key_optional>
```

### Release Build — Android

```bash
flutter build apk --release --dart-define=GEMINI_API_KEY=<key> --dart-define=GROQ_API_KEY=<key_optional>
# or for App Bundle:
flutter build appbundle --release --dart-define=GEMINI_API_KEY=<key> --dart-define=GROQ_API_KEY=<key_optional>
```

### Release Build — iOS

```bash
flutter build ios --release --dart-define=GEMINI_API_KEY=<key> --dart-define=GROQ_API_KEY=<key_optional>
```

### Release Build — Web

```bash
flutter build web --release --dart-define=GEMINI_API_KEY=<key> --dart-define=GROQ_API_KEY=<key_optional>
```

### Android Configuration

| Property | Value |
|---|---|
| Application ID | `com.fitsmart.fitsmart_app` |
| Compile SDK | Flutter default |
| Min SDK | Flutter default |
| Target SDK | Flutter default |
| Java Version | 17 |
| Kotlin | Enabled |

### iOS Configuration

| Property | Value |
|---|---|
| Bundle Name | `fitsmart_app` |
| Display Name | FitSmart |
| Orientations (iPhone) | Portrait, Landscape Left/Right |
| Orientations (iPad) | All four |
| ATS | Enforced |

---

## 19. Environment Variables

| Variable | Required | Source | Description |
|---|---|---|---|
| `GEMINI_API_KEY` | ✅ | `--dart-define` | Google Gemini API key |
| `GROQ_API_KEY` | ❌ | `--dart-define` | Groq API key (secondary cloud fallback) |

**Injection point:** `lib/providers/gemini_provider.dart`

```dart
const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
assert(apiKey.isNotEmpty, 'GEMINI_API_KEY must be provided via --dart-define');

const groqApiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
// Optional: if empty, Groq tier is disabled automatically.
```

---

## 20. Firestore Rules

**File:** `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() { return request.auth != null; }
    function isOwner(userId) { return isAuthenticated() && request.auth.uid == userId; }
    function hasReasonableSize() { return request.resource.data.keys().size() <= 50; }

    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isOwner(userId) && hasReasonableSize();
      allow update: if isOwner(userId) && hasReasonableSize();
      allow delete: if isOwner(userId);

      match /{subcollection}/{docId} {
        allow read: if isOwner(userId);
        allow create: if isOwner(userId) && hasReasonableSize();
        allow update: if isOwner(userId) && hasReasonableSize();
        allow delete: if isOwner(userId);
      }
    }

    match /{document=**} { allow read, write: if false; }
  }
}
```

---

## 21. API Reference — Core AI Services

### 21.1 AiOrchestratorService

**File:** `lib/services/ai_orchestrator_service.dart`

Primary app-facing AI gateway used by all screens via `aiProvider`.

**Public methods:**

- `analyzeMealPhoto()`
- `analyzeMealText()`
- `getMealFeedback()`
- `generateMealPlan()`
- `generateWorkoutPlan()`
- `chat()`
- `getDailyInsight()`

**Fallback chain:**

- Structured methods: Gemini → Groq → Local templates/RAG
- Chat/Insight: Gemini → Groq → On-device Gemma (if available) → Local templates/RAG

### 21.2 GeminiClient

### Constructor

```dart
factory GeminiClient({required String apiKey})
```

Singleton factory. Creates two `GenerativeModel` instances (structured JSON + freeform chat).

### Methods

#### `analyzeMealPhoto()`

```dart
Future<Map<String, dynamic>> analyzeMealPhoto({
  required Uint8List imageBytes,
  required Map<String, dynamic> userContext,
  String? mimeType,           // default: 'image/jpeg'
  String? groundingContext,   // RAG grounding block
})
```

Analyzes a meal photograph. Returns itemized nutrition, totals, health score (1–10), and personalized feedback.

#### `analyzeMealText()`

```dart
Future<Map<String, dynamic>> analyzeMealText({
  required String description,
  required Map<String, dynamic> userContext,
  String? groundingContext,
})
```

Parses a natural-language meal description into structured nutrition data.

### 21.3 GroqClient

**File:** `lib/services/groq_client.dart`

OpenAI-compatible REST client for Groq fallback cloud inference.

**Constructor:**

```dart
factory GroqClient({required String apiKey})
```

**Behavior:**

- Mirrors Gemini method surface for drop-in orchestration fallback.
- Uses `response_format: { type: 'json_object' }` for structured responses.
- Supports chat + vision-style input where model capabilities allow.

### 21.4 LocalLlmService

**File:** `lib/services/local_llm_service.dart`

Manages on-device Gemma 2 2B lifecycle:

- `checkModelStatus()`
- `downloadModel(url)`
- `loadModel()` / `unloadModel()`
- `generate(prompt)` / `generateStream(prompt)`

Used by orchestrator for `chat()` and `getDailyInsight()` fallback on Android/iOS.

### 21.5 LocalAiFallbackService

**File:** `lib/services/local_ai_fallback_service.dart`

Deterministic final fallback that guarantees valid response shapes when cloud/local-LLM tiers are unavailable.

Primary methods mirror orchestrator surfaces and return schema-compatible objects for all features.

### 21.6 Shared AI Method Signatures (Gemini/Groq)

The following signatures are implemented in cloud clients and consumed by the orchestrator.

#### `getMealFeedback()`

```dart
Future<Map<String, dynamic>> getMealFeedback({
  required Map<String, dynamic> mealData,
  required Map<String, dynamic> userContext,
})
```

Returns personalized post-logging feedback with remaining macros and next-meal suggestions.

#### `generateMealPlan()`

```dart
Future<Map<String, dynamic>> generateMealPlan({
  required Map<String, dynamic> userContext,
  required int days,
  String? overrides,
})
```

Generates a multi-day meal plan tailored to the user's targets, dietary restrictions, cuisine preferences, and budget.

#### `generateWorkoutPlan()`

```dart
Future<Map<String, dynamic>> generateWorkoutPlan({
  required Map<String, dynamic> userContext,
  required int weeks,
})
```

Creates a structured workout program with exercises, sets, reps, rest periods, and progression.

#### `chat()`

```dart
Future<Map<String, dynamic>> chat({
  required String message,
  required Map<String, dynamic> userContext,
  required List<Map<String, String>> history,
  Uint8List? imageBytes,
  String? mimeType,
  String? groundingContext,
})
```

Conversational AI coach with full user context injection. Supports image attachments and maintains chat history (last 10 messages).

**User Context Sections Injected:**
- Complete user profile (goal, gender, age, height, weight, body fat, target body type)
- Today's nutrition targets and progress (calories, protein, carbs, fat, water)
- Gamification status (level, XP, streak, badges)
- All-time stats (total meals, total workouts)
- Today's meals (if any logged)
- Recent workouts (last 10)
- Personal records (max weight per exercise)
- Latest body measurements
- Weight history
- Last 7 days summary
- Active workout and meal plans

#### `getDailyInsight()`

```dart
Future<Map<String, dynamic>> getDailyInsight({
  required Map<String, dynamic> userContext,
})
```

Generates a motivational daily insight with emoji icon and category classification.

#### `clearCache()`

```dart
void clearCache()
```

Purges all cached AI responses.

---

## 22. API Reference — FoodKnowledgeService

### Singleton Access

```dart
FoodKnowledgeService.instance
```

### Properties

| Property | Type | Description |
|---|---|---|
| `isLoaded` | `bool` | Whether the knowledge base has been loaded |
| `allFoods` | `List<FoodEntry>` | Combined Indian + common food entries |
| `indianFoods` | `List<FoodEntry>` | Indian food entries only (unmodifiable) |
| `commonFoods` | `List<FoodEntry>` | Common food entries only (unmodifiable) |

### Methods

#### `load()`

```dart
Future<void> load()
```

Loads `indian_foods.json` and `common_foods.json` from assets. Builds a search index mapping lowercased names, aliases, and ingredients to `FoodEntry` objects. Idempotent — multiple calls are no-ops after first load.

#### `search()`

```dart
List<FoodSearchResult> search(String query, {int limit = 10})
```

Fuzzy search over all foods. Returns results sorted by relevance score (1.0 = exact match). Uses Levenshtein edit distance for typo tolerance.

#### `buildGroundingContext()`

```dart
String buildGroundingContext(String query, {int maxResults = 8})
```

The core RAG retrieval-to-prompt method. Searches for relevant foods and formats them as a grounding block:

```
=== FOOD KNOWLEDGE BASE (use as grounding reference) ===
The following foods from our verified database may be relevant.
• Biryani: 350 kcal, 12g P, 45g C, 14g F per 1 plate [non-veg] — Fragrant layered rice...
• Chapati: 120 kcal, 3g P, 20g C, 3.5g F per 1 piece [veg] — Whole wheat flatbread...
Use the above data to improve accuracy. If the food matches one of these entries, prefer the listed nutritional values.
```

#### `buildGroundingForNames()`

```dart
String buildGroundingForNames(List<String> foodNames, {int perName = 3})
```

Builds grounding context from a list of specific food names (e.g., after Gemini identifies items in a photo). Deduplicates results.

### FoodEntry Model

```dart
class FoodEntry {
  final String name;
  final String? category;
  final String? dish;
  final String? dietary;     // "veg" | "non-veg"
  final double cal, protein, carbs, fat, fiber;
  final String serving;
  final int servingG;
  final List<String> ingredients;
  final List<String> aliases;
  final String? description;

  String toGroundingString();  // Concise one-liner for prompt injection
  Map<String, dynamic> toJson();
}
```

---

## 23. Error Handling

### Gemini Error Handling

The `GeminiClient` wraps all API errors into user-friendly `GeminiException` messages:

| Error Pattern | User Message | `isRateLimited` |
|---|---|---|
| `quota`, `rate`, `429`, `resource_exhausted` | "AI is taking a breather ☕ Too many requests..." | `true` |
| `api_key`, `permission`, `403` | "API key issue — please check your Gemini API key." | `false` |
| `timeout`, `deadline` | "Request timed out — check your internet and try again." | `false` |
| `network`, `socket`, `connection` | "No internet connection — please check your network." | `false` |
| All other | "Something went wrong. Please try again." | `false` |

### Crash Reporting

```dart
// Global Flutter error handler
FlutterError.onError = (details) {
  FlutterError.presentError(details);
  if (!kIsWeb) FirebaseCrashlytics.instance.recordFlutterFatalError(details);
};

// Platform dispatcher errors
PlatformDispatcher.instance.onError = (error, stack) {
  if (!kIsWeb) FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};

// Zone-level catch-all
runZonedGuarded(() { ... }, (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack);
});
```

Crashlytics collection is disabled in debug mode (`kDebugMode`) and on web (`kIsWeb`).

---

## 24. Performance Considerations

### Startup Optimization

| Step | Strategy |
|---|---|
| Firebase init | `await` — required before any Firebase operation |
| Database seeding | `await` — one-time on first launch |
| Food knowledge base | **Fire-and-forget** — `load()` called without await |
| UI rendering | Immediate — no blocking on optional services |

### Database Performance

- **Drift** generates type-safe queries compiled to native SQL
- **Watch queries** (`watchTodaysMeals`, `watchWeightStream`) use SQLite triggers for efficient reactivity
- **Batch inserts** for exercise seeding and workout sets
- **Schema version 2** migration runs only on existing databases

### AI Response Caching

In-memory cache with per-endpoint TTLs prevents redundant API calls:

- Same meal photo → cache hit (SHA-256 hash)
- Daily insight → max 1 API call per day
- Workout plans → cached for 7 days

### Image Handling

- `flutter_image_compress` reduces image size before AI analysis
- Image hash (first 16 chars of SHA-256) used as cache key

### State Management

- `StatefulShellRoute.indexedStack` preserves tab state across navigation
- `StreamProvider` for real-time data (meals, weight, auth)
- `StateNotifier` for persistent settings with SharedPreferences

---

## 25. Appendix

### A. System Prompt — Structured Model

```
You are FitSmart AI, a fitness and nutrition coach assistant.
Always respond with valid JSON matching the requested schema.
Be precise with nutritional data. Use evidence-based recommendations.
Be encouraging, practical, and personalized. Keep responses concise.
Never include markdown, prose wrappers, or explanations outside the JSON structure.
```

### B. System Prompt — Chat Model

The chat model receives an extensive system instruction defining FitSmart AI's personality, formatting rules, and data access scope. Key directives:

- Expert-level knowledge in exercise science, nutrition, sports psychology
- Friendly, motivating, knowledgeable — like a world-class personal trainer
- Use emojis sparingly (1–2 per response)
- Be direct and actionable — no filler
- Always back advice with actual user data
- Use **bold** for emphasis, bullet points (•) for lists
- Provide specific quantities, calories, and macros for meal/workout plans
- Reference PRs, streaks, badges, and level progress

### C. OnboardingData Model

21 fields collected during onboarding:

```dart
String? primaryGoal, gender, country, city, activityLevel,
        targetBodyType, weightChangePace;
int? age, bedtimeHour, bedtimeMin, wakeHour, wakeMin, workoutDaysPerWeek;
double? heightCm, weightKg, bodyFatPct, targetWeightKg, monthlyBudgetUsd;
List<String>? dietaryRestrictions, cuisinePreferences, dislikedIngredients;
```

Validation: `isComplete` requires `primaryGoal`, `gender`, `age`, `heightCm`, `weightKg`, `activityLevel`, and `targetWeightKg` to be non-null.

### D. AppSettings Model

```dart
class AppSettings {
  final bool isMetric;              // true = kg/cm, false = lbs/ft
  final bool notificationsEnabled;  // Push notifications toggle
  final bool weeklyReportEnabled;   // Weekly summary reports
  final String displayName;         // User display name
}
```

Persisted to SharedPreferences as JSON. Managed by `SettingsNotifier` (StateNotifier).

### E. File Size Reference

| File | Lines | Purpose |
|---|---|---|
| `dashboard_screen.dart` | 1,147 | Main hub with all dashboard widgets |
| `workouts_screen.dart` | 1,113 | Workout management (3 tabs) |
| `ai_coach_screen.dart` | 1,093 | Conversational AI interface |
| `progress_screen.dart` | 919 | Analytics and charts (4 tabs) |
| `gemini_client.dart` | 597 | Full Gemini API client with caching |
| `settings_screen.dart` | 523 | Settings with 7 sub-screens |
| `app_database.dart` | 307 | 10-table Drift database |
| `food_knowledge_service.dart` | 264 | RAG retrieval engine |
| `xp_progress_bar.dart` | 191 | XP visualization widgets |
| `app_button.dart` | 173 | Button component library |
| `app_theme.dart` | 165 | Complete ThemeData assembly |
| `gamification.dart` | 165 | Gamification state model |
| `calorie_ring.dart` | 160 | Animated calorie ring |
| `app_shell.dart` | 162 | Bottom navigation shell |
| `auth_service.dart` | 155 | Authentication facade |
| `macro_bar.dart` | 142 | Macro progress bars |
| `firestore_service.dart` | 138 | Cloud sync service |
| `app_card.dart` | 136 | Card component library |

---

*Documentation generated for FitSmart AI v1.0.0 · Flutter 3.38.5 · Dart 3.10.4*  
*Last updated: March 2026*
