# FitSmart AI — Complete User Flow Map & Quality Audit

> **Generated:** 2026-04-13  
> **Flutter version:** 3.38.5 / Dart 3.10.4  
> **App package:** `fitsmart_app` | Firebase: `fitsmart-9c7da`

---

## TABLE OF CONTENTS

1. [Navigation Architecture](#1-navigation-architecture)
2. [All Screens & What They Do](#2-all-screens--what-they-do)
3. [User Journeys — New Users](#3-user-journeys--new-users)
4. [User Journeys — Returning Users](#4-user-journeys--returning-users)
5. [User Journeys — Feature Flows](#5-user-journeys--feature-flows)
6. [Edge Cases & Special Situations](#6-edge-cases--special-situations)
7. [State & Data Flow](#7-state--data-flow)
8. [AI Tier Routing](#8-ai-tier-routing)
9. [Analytics Event Map](#9-analytics-event-map)
10. [Quality Audit](#10-quality-audit)

---

## 1. NAVIGATION ARCHITECTURE

### Route Tree

```
Root (GoRouter)
│
├── /splash                          SplashScreen (crossword animation ~4.2s)
│
├── /login                           LoginScreen
├── /signup                          SignupScreen
├── /forgot-password                 ForgotPasswordScreen
│
├── /onboarding                      OnboardingFlow (12 steps)
│
├── AppShell — IndexedStack (5 tabs, state preserved across tab switches)
│   ├── [0] /dashboard               DashboardScreen
│   ├── [1] /nutrition               NutritionScreen
│   │         └── /nutrition/log     LogMealScreen
│   ├── [2] /coach                   AiCoachScreen (center CTA tab)
│   ├── [3] /workouts                WorkoutsScreen
│   │         └── /workouts/active   ActiveWorkoutScreen
│   └── [4] /progress                ProgressScreen
│
├── /settings                        SettingsScreen
│   ├── /settings/edit-profile       EditProfileScreen
│   ├── /settings/edit-goals         EditGoalsScreen
│   ├── /settings/edit-diet          EditDietScreen
│   ├── /settings/edit-sleep         EditSleepScreen
│   ├── /settings/faq                FaqScreen
│   ├── /settings/export             ExportDataScreen
│   ├── /settings/privacy            LegalScreen (privacy policy)
│   └── /settings/terms              LegalScreen (terms of service)
│
└── /paywall                         PaywallScreen (pushable from anywhere)
```

### Global Redirect Logic (runs on every auth state change)

```
redirect(state, ref):
  ├── No Firebase user?
  │     └── Force → /login  (unless already on auth route)
  │
  ├── User exists:
  │     ├── isOnboardingCompleteLocal()?
  │     │     ├── YES → If on auth route → /dashboard; else stay
  │     │     └── NO  → tryRestoreFromFirestore(uid)?
  │     │               ├── RESTORED → /dashboard
  │     │               └── FAILED  → /onboarding
  │     │
  │     └── Special: _skip_cloud_recovery flag set?
  │                  └── Skip Firestore attempt (prevents re-trigger on reset)
  │
  └── Already on /onboarding? → stay (never re-redirect away mid-flow)
```

**Onboarding Completion Check (layered):**
```
1. SharedPreferences['onboarding_complete'] == true
     AND SharedPreferences['onboarding_uid'] == currentUser.uid
     → COMPLETE (fast, local)

2. Firestore users/{uid}.profile['isComplete'] == true
     → COMPLETE (recovery path, cross-device)

3. Firestore profile exists AND all 7 required fields non-null
     → COMPLETE (legacy support, pre-v2 profiles)

4. None of the above → INCOMPLETE → /onboarding
```

---

## 2. ALL SCREENS & WHAT THEY DO

### 2.1 SplashScreen
**Route:** `/splash`  
**Purpose:** App entry point; determines where the user goes.

| Feature | Detail |
|---------|--------|
| Animation | 22×26 crossword grid of fitness words (STAMINA, PROTEIN, CARDIO, etc.) |
| Duration | ~4.2 seconds total; letters reveal staggered over ~2.8s |
| Effects | Letter-by-letter reveal, pulsing glow (1.8s loop), shimmer sweep (2s loop) |
| Skip | Skip button appears after 0.3s, opacity grows as grid fills |
| Decision | After animation: routes based on auth + onboarding state (see §3) |

---

### 2.2 LoginScreen
**Route:** `/login`

| Action | Outcome |
|--------|---------|
| Email + Password sign-in | Firebase Auth → redirect guard routes user |
| Google Sign-In | Firebase Auth OAuth flow → redirect guard routes user |
| Continue as Guest | Creates Firebase anonymous user → /onboarding |
| Forgot password link | → /forgot-password |
| Sign up link | → /signup |
| Theme toggle | Light ↔ Dark (top-right) |

**Error codes handled:** `user-not-found`, `wrong-password`, `invalid-email`, `too-many-requests`, `invalid-credential`

---

### 2.3 SignupScreen
**Route:** `/signup`

| Action | Outcome |
|--------|---------|
| Email + Name + Password form | Creates new Firebase account OR links to anonymous UID |
| Google Sign-Up | OAuth + link-or-create logic |
| Already has account? Sign in | context.pop() → back to login |

**Linking logic:**  
- If current session is anonymous → link new credentials to that UID (preserves onboarding data)  
- If anonymous + already onboarded → routes to /dashboard  
- If fresh account → routes to /onboarding

---

### 2.4 ForgotPasswordScreen
**Route:** `/forgot-password`

| Action | Outcome |
|--------|---------|
| Enter email → Send | Firebase sends password reset email |
| Success state | Confirmation message shown |
| Back | pop() |

---

### 2.5 OnboardingFlow
**Route:** `/onboarding`  
**Steps (12 total):**

| Step | Screen File | Data Collected |
|------|-------------|----------------|
| 0 | step_welcome.dart | — (greeting) |
| 1 | step_mission.dart | `primaryGoal` (lose fat / build muscle / maintain / improve fitness) |
| 2 | step_bio.dart | `displayName`, `gender`, `age` |
| 3 | step_body_stats.dart | `heightCm`, `weightKg`, `bodyFatPct` (optional) |
| 4 | step_location.dart | `country`, `city` |
| 5 | step_activity.dart | `activityLevel` (sedentary / lightly / moderately / very / extra active) |
| 6 | step_dream_body.dart | `targetBodyType` (lean / athletic / muscular / etc.) |
| 7 | step_sleep.dart | `bedtimeHour`, `bedtimeMin`, `wakeHour`, `wakeMin` |
| 8 | step_diet.dart | `dietaryRestrictions`, `cuisinePreferences`, `dislikedIngredients` |
| 9 | step_budget.dart | `monthlyBudgetUsd` |
| 10 | step_targets.dart | `targetWeightKg`, `weightChangePace`, `workoutDaysPerWeek` |
| 11 | step_ai_setup.dart | — (confirmation, triggers completion) |

**UI Controls per step:**
- Progress bar (hidden on step 0 and step 11)
- Back button (steps 1–10)
- Skip button (steps 1–10) — jumps directly to completion
- Next / Complete button

**On completion (`_complete()`):**
```
1. Save OnboardingData → SharedPreferences['onboarding_data']
2. Set SharedPreferences['onboarding_complete'] = true
3. Set SharedPreferences['onboarding_uid'] = uid
4. profileData['isComplete'] = true
5. await FirestoreService.saveProfile(uid, profileData)  [8s timeout]
6. Set Firebase Analytics user properties
7. Track time spent (onboarding_completed event)
8. GoRouter redirect fires → /dashboard
```

---

### 2.6 DashboardScreen
**Route:** `/dashboard` (Tab 0)

| Section | Description |
|---------|-------------|
| Header | Time-based greeting + first name + streak badge + settings button |
| XP Progress Bar | Current level name, XP to next level, animated fill |
| Calorie Ring | Daily calories consumed vs. target; 4 macro bars (protein/carbs/fat/fiber) |
| Today's Workout card | Workout from active plan; tap → starts workout |
| Streak card | Current consecutive active days with fire icon |
| Daily Challenge | Gamification challenge (e.g., "Log 3 meals today") |
| AI Insight card | Generated daily insight from user's recent data |
| Water tracking | Hydration log (glasses per day) |
| Upgrade banner | Shown only for anonymous/free users |

**Providers consumed:**
- `todaysMealsProvider`, `dailyNutritionProvider`, `gamificationProvider`, `todaysPlannedWorkoutProvider`

---

### 2.7 NutritionScreen
**Route:** `/nutrition` (Tab 1)

**Tab 1: TODAY**
| Feature | Detail |
|---------|--------|
| Calorie summary ring | Today's calories vs. target |
| Macro bars | Protein (cyan) / Carbs (lime) / Fat (coral) / Fiber (purple) |
| Meal list | All logged meals today, each showing name + macros |
| Meal card actions | Expand for details, delete |
| Add Meal button | → /nutrition/log |

**Tab 2: MEAL PLAN**
| Feature | Detail |
|---------|--------|
| AI-generated weekly plan | Based on user goals, diet preferences, budget |
| Refresh plan | Regenerate with Gemini |

---

### 2.8 LogMealScreen
**Route:** `/nutrition/log`

| Input Method | Flow |
|-------------|------|
| Text description | "chicken breast 200g rice 100g" → AI parses macros |
| Photo | Camera / gallery → Gemini Vision analyzes food in image |
| Barcode scan | Lookup in food database |

**On save:**  
→ Drift DB insert → `todaysMealsProvider` refresh → dashboard ring updates → analytics `meal_logged`

---

### 2.9 AiCoachScreen
**Route:** `/coach` (Tab 2, center CTA)

**Conversation system:**
- Multiple independent conversations, switchable via bottom sheet
- Each conversation auto-titled from first user message
- Persisted: SharedPreferences (L1 cache) + Firestore `ai_conversations/{id}` (cross-device)

| Feature | Detail |
|---------|--------|
| Text input | Send button with 3-second cooldown between messages |
| Image attachment | Gallery picker, compressed to 1024×1024 @ 80% quality |
| Message list | User right / AI left; date separators; scroll-to-bottom button |
| Typing indicator | Animated dots while AI is responding |
| Suggestion chips | 6 prewritten prompts shown when conversation is new/short |
| Retry | Failed messages show retry button |
| Conversation sheet | List all conversations; switch or delete; create new |
| Clear chat | Clears messages in current conversation |
| Rich formatting | AI responses render markdown (bold, bullets, headers) |
| Free tier gate | On limit hit: removes message + pushes /paywall |

**AI pipeline for chat:**
```
User sends message
  → Build user context (UserContextService):
      last 30d meals, workouts, weight logs, goals, TDEE
  → Load food knowledge grounding (FoodKnowledgeService)
  → AiOrchestratorService.chat(message, history, imageBytes?)
      → Tier 1: Gemini 2.5 Flash
      → Tier 2: Groq Llama 3.3 70B (text-only, no image bytes)
      → Tier 3: On-device Gemma 3 1B (if model downloaded)
      → Tier 4: Local template fallback
  → Display response
  → Save to SharedPrefs + Firestore
```

---

### 2.10 WorkoutsScreen
**Route:** `/workouts` (Tab 3)

**Tab 1: TODAY**
| Feature | Detail |
|---------|--------|
| Planned workout | From active workout plan; shows name, muscle focus, exercise list |
| Start Workout | → /workouts/active |
| No plan state | Prompt to select or create a plan |

**Tab 2: PLANS**
| Feature | Detail |
|---------|--------|
| Available plans | Pre-built and custom plans |
| Set active | Makes a plan the "today" source |
| Create new | Custom plan builder |

**Tab 3: LIBRARY**
| Feature | Detail |
|---------|--------|
| Exercise database | Searchable, seeded from `DatabaseSeeder` on first launch |
| Filters | By muscle group, equipment type |
| Browse workouts | Pre-built routine cards |

---

### 2.11 ActiveWorkoutScreen
**Route:** `/workouts/active`

| Feature | Detail |
|---------|--------|
| Stopwatch | Total elapsed time |
| Exercise queue | All exercises in the workout, one at a time |
| Set tracker | Tap to log each set (reps × weight) |
| Rest timer | Auto-starts between sets (configurable duration) |
| Form demo | Image/video reference for each exercise |
| Complete | Saves workout log → XP earned → streak incremented |

---

### 2.12 ProgressScreen
**Route:** `/progress` (Tab 4)

| Sub-tab | Content |
|---------|---------|
| WEIGHT | Line chart (7d / 30d / all-time), moving average, log new weigh-in |
| STRENGTH | PRs by exercise, strength progression chart, log new lift |
| BODY | Measurement tracking (chest, waist, hips, arms, thighs) over time |
| STATS | Avg daily calories, macro split %, weekly workout frequency, avg duration |
| PHOTOS | Side-by-side comparison view, date-range picker, upload new photo |

---

### 2.13 SettingsScreen
**Route:** `/settings`

| Section | Items |
|---------|-------|
| Profile card | Name, email, level, XP bar; guest users see "Sign in to sync" |
| Premium | Upgrade banner → /paywall |
| Preferences | Theme mode, unit system (metric/imperial), notifications toggle |
| Profile editing | → /settings/edit-profile, /edit-goals, /edit-diet, /edit-sleep |
| Health sync | Apple Health (iOS) / Google Fit (Android) toggle + permission request |
| Support | → /settings/faq |
| Data & Legal | → /settings/export, /settings/privacy, /settings/terms |
| Sign out | Firebase Auth sign-out → /login |

---

### 2.14 PaywallScreen
**Route:** `/paywall`  
**Pushed from:** AI coach limit, premium settings sections, upgrade banner

| Feature | Detail |
|---------|--------|
| Subscription tiers | Monthly / Annual; shown via RevenueCat `activeOfferings` |
| Feature comparison | What's included in free vs. premium |
| Purchase | RevenueCat purchase flow |
| Restore | Checks prior purchase on new device |
| Close | pop() → returns to previous screen |

---

## 3. USER JOURNEYS — NEW USERS

### 3A. New User via Email

```
App launch → Splash (4.2s)
  → No Firebase user → /login
    → "Sign Up" → /signup
      → Fill: name, email, password
      → Firebase creates account
      → Router redirect: no onboarding → /onboarding
        → 12-step flow (~5 mins)
          → Complete → saves to SharedPrefs + Firestore
            → Router redirect: onboarding complete → /dashboard
              → All 5 tabs accessible
```

---

### 3B. New User via Google

```
App launch → Splash → /login
  → "Sign in with Google"
    → Google OAuth sheet (system UI)
      → Firebase Auth credential
        → New Google user? → Router → /onboarding
        → Existing Google user (returning) → Router → /dashboard
```

---

### 3C. New User as Guest (Anonymous)

```
App launch → Splash → /login
  → "Continue as Guest"
    → Firebase anonymous account created
      → Router → /onboarding
        → 12-step flow
          → Complete → saves with anonymous UID
            → Router → /dashboard
              → Guest banner visible on dashboard
              → Settings shows "Sign in to sync" prompt
```

---

### 3D. Guest User Upgrades to Real Account

```
Dashboard → Settings
  → "Sign in to sync" card (or upgrade banner)
    → /signup
      → Email/Google
        → Firebase links credentials to anonymous UID
          → Onboarding data already exists for this UID
            → Router: isOnboardingComplete → /dashboard
              → Account now permanent, data preserved
```

---

## 4. USER JOURNEYS — RETURNING USERS

### 4A. Same Device, Same Account (typical return)

```
App launch → Splash
  → Firebase user already signed in (persisted token)
    → SharedPrefs['onboarding_complete'] = true, UID matches
      → Router: COMPLETE → /dashboard
        (fastest path, no network calls)
```

---

### 4B. New Device / Reinstall (Firestore recovery)

```
App launch → Splash
  → Firebase user signed in (auto from Google/Firebase token)
    → SharedPrefs empty (new device / fresh install)
      → Router: tryRestoreFromFirestore(uid)
        → Reads users/{uid}.profile from Firestore
          → profile['isComplete'] == true?
            → YES: restore to SharedPrefs → /dashboard
            → NO:  → /onboarding (user re-onboards)
```

---

### 4C. New Device, Web Browser (cold start)

```
Browser opens app
  → No IndexedDB cache yet
    → Firebase Auth checks token → signed in
      → SharedPrefs equivalent (localStorage) empty
        → Firestore (with persistence=true) hits server
          → Profile found → restore → /dashboard
          → Profile not found → /onboarding
```

---

### 4D. Signed-Out User Returns

```
App launch → Splash
  → No Firebase user (was explicitly signed out)
    → Router → /login
      → Signs in → Router redirect checks onboarding
        → Complete (same UID, Firestore) → /dashboard
```

---

### 4E. Password Reset Flow

```
/login → "Forgot password?"
  → /forgot-password
    → Enter email → Firebase sends reset email
      → User opens email → resets password on Firebase console page
        → Returns to app → /login
          → Signs in with new password → /dashboard
```

---

## 5. USER JOURNEYS — FEATURE FLOWS

### 5A. Log a Meal (text)

```
Dashboard or Nutrition tab
  → "Add Meal" button → /nutrition/log
    → Type: "grilled chicken 200g, rice 150g"
      → AI parses (Gemini / fallback)
        → Shows nutritional breakdown (calories, P/C/F)
          → Confirm & Save
            → Drift DB insert
              → Nutrition tab refreshes (live stream)
              → Dashboard calorie ring updates
              → XP earned (gamification)
                → analytics: meal_logged
```

---

### 5B. Log a Meal (photo)

```
/nutrition/log
  → Camera icon → take photo or pick from gallery
    → Image sent to AiOrchestratorService.analyzeMealPhoto()
      → Tier 1: Gemini Vision analyzes image
      → Tier 2: Local RAG (if Gemini fails) — no Groq (image-unsupported)
        → Returns: food name + macros estimate
          → User can edit values
            → Save → same as text flow above
```

---

### 5C. Start & Complete a Workout

```
Workouts tab → TODAY
  → Shows workout from active plan
    → "Start Workout" → /workouts/active
      → Stopwatch starts
        → Exercise 1:
            → Log Set 1: 8 reps × 60kg ✓
            → Rest timer auto-starts (e.g., 60s)
            → Log Set 2 … Set 3 …
          → "Next Exercise" → Exercise 2 …
        → All exercises done → "Complete Workout"
          → Saves to Drift (workout_logs table)
          → XP earned, streak incremented
          → Gamification updated → Firestore sync
          → analytics: workout_completed
      → Returns to Workouts tab
```

---

### 5D. Chat with AI Coach

```
Tab 2 (center glowing button) → AiCoachScreen
  → Existing or new conversation
    → Type: "Why am I not seeing muscle gains?"
      → Send (3s cooldown starts)
        → Typing indicator appears
          → UserContextService builds context:
              last 30d meal logs, workout history, weight trend, goals
            → FoodKnowledgeService loads grounding
              → AiOrchestratorService.chat(...)
                → Response received (5-15s)
                  → Message appears left-aligned with rich formatting
                    → Saved: SharedPrefs (local) + Firestore (cloud)
                      → User can:
                          ↳ Ask follow-up
                          ↳ Attach image (form check, meal photo)
                          ↳ Tap suggestion chip
                          ↳ Switch/start new conversation
```

---

### 5E. Hit Free Tier Limit

```
AI Coach → Send message
  → Tier limit exceeded (FreeTierLimitException)
    → User's message removed from UI
      → context.push('/paywall', extra: 'unlimited_ai')
        → PaywallScreen
            → Purchase → RevenueCat processes
              → isPremiumProvider updates
                → pop() → return to coach
                  → Can now send unlimited messages
            → Close without purchasing → pop() → back to coach
```

---

### 5F. View Progress & Compare Photos

```
Progress tab → PHOTOS sub-tab
  → PhotoComparisonView
    → Pick "3 months ago" vs. "Today"
      → Side-by-side display
        → Pinch to zoom, swipe to compare
          → "Add photo" → gallery picker → upload
            → Stored: Drift (progress_photos) + Firebase Storage metadata
              → analytics: photo_viewed
```

---

### 5G. Adjust Settings

```
Dashboard → Settings icon (top-right) → /settings
  ├── Theme: Light / Dark / System  →  settingsProvider.setThemeMode()
  │                                     → SharedPrefs + Firestore sync
  ├── Units: Metric / Imperial       →  settingsProvider.setMetric()
  ├── Notifications on/off           →  NotificationService.toggle()
  │
  ├── Edit Profile → /settings/edit-profile
  │     → Change display name → settingsProvider.setDisplayName()
  │     → Change profile photo → Firebase Storage upload
  │
  ├── Edit Goals → /settings/edit-goals
  │     → Update primaryGoal, targetWeight, pace
  │       → save to SharedPrefs['onboarding_data'] + Firestore
  │
  └── Sign Out → FirebaseAuth.signOut()
               → Router redirect → /login
```

---

### 5H. Download & Use On-Device AI Model

```
Settings → "On-Device AI" section
  → Shows current model: Gemma 3 1B int4 (~529 MB)
  → "Download" button
    → local_llm_service.dart downloads .task file via HTTP
      → Progress indicator shown
      → File saved to app documents directory
        → Model validated (>100 MB size check)
          → FlutterMediapipeChat initializes
            → On next AI request: Tier 3 available (no network needed)
```

---

### 5I. Health App Integration

```
Settings → Health Integration
  → "Connect Apple Health" (iOS) / "Connect Google Fit" (Android)
    → Permission request (HealthService.requestPermissions())
      → User grants → health data synced
        → Dashboard shows steps, active calories
          → AI Coach has richer context for advice
```

---

## 6. EDGE CASES & SPECIAL SITUATIONS

### 6A. Skip Button During Onboarding

```
User presses "Skip" on any step (1–10)
  → _complete() called immediately
  → profileData built from whatever was collected so far
  → profileData['isComplete'] = true (always set)
  → Saved to SharedPrefs + Firestore
  → → /dashboard (missing optional fields handled gracefully)
```

---

### 6B. Onboarding Reset (Debug)

```
Settings → [kDebugMode only] "Re-run onboarding"
  → Clears SharedPrefs onboarding keys
  → Sets _skip_cloud_recovery = true (prevents Firestore restore)
  → Signs out → /login
    → User goes through onboarding again
      → New profile overwrites Firestore
```

---

### 6C. Offline Usage

```
No network connection:
  → Firestore: offline persistence serves cached data
  → AI Coach: falls to on-device Gemma (if downloaded) → template fallback
  → Meal logging: saves locally to Drift (queued for sync when online)
  → Dashboard: loads from Drift cache (instant)
  → SyncService: retries with exponential backoff when online
  → OfflineBanner widget: shown when network unavailable
```

---

### 6D. Anonymous Account Conflict (Google link fails)

```
Guest user → Signup with Google
  → credential-already-in-use error
    → That Google account already has data
      → App shows error: "This Google account already exists. Sign in instead."
        → user must sign in normally (loses anonymous session data)
```

---

### 6E. App in Background → Foreground

```
App returns to foreground
  → GoRouter re-evaluates redirect (authStateChanges fires)
    → If token expired: Firebase Auth refreshes token silently
    → If user deleted: → /login
    → Otherwise: stays on current screen
```

---

### 6F. FCM Push Notification Received

```
Background notification (e.g., "workout reminder"):
  → _onFcmBackground handler fires (top-level isolate)
  → Firebase re-initialized in background isolate
  → Notification shown in system tray

Foreground notification:
  → NotificationService.onForeground handler
  → In-app banner (or custom UI)

Tap on notification:
  → Deep link extracted
  → DeepLinkService routes to correct screen
```

---

### 6G. Subscription Restored on New Device

```
App install on new device (premium user)
  → /paywall or Settings → "Restore Purchases"
    → RevenueCat checks purchase receipt
      → Active entitlement found → isPremiumProvider = true
        → Premium features unlocked
        → Paywall dismiss
```

---

### 6H. AI Response Failure

```
User sends message → all AI tiers fail:
  → Tier 1 Gemini: network/quota error
  → Tier 2 Groq: API error
  → Tier 3 On-device: model not downloaded
  → Tier 4 Template: always succeeds (canned response based on intent)

Message shows error state with retry button
analytics: ai_chat_error tracked with tier info
```

---

### 6I. Image in AI Chat (Session Behavior)

```
User attaches image in conversation:
  → Image bytes sent to Gemini (if available)
  → Image NOT persisted to JSON/SharedPrefs (ephemeral)
  → Conversation saved without image bytes
  → On next session: conversation history loads text only
  → No image re-displayed from past sessions
```

---

## 7. STATE & DATA FLOW

### Storage Layers

| Data | Primary Store | Sync Target | Notes |
|------|--------------|-------------|-------|
| Onboarding profile | SharedPreferences | Firestore `users/{uid}.profile` | awaited write, 8s timeout |
| App settings | SharedPreferences | Firestore `users/{uid}.settings` | fire-and-forget sync |
| AI conversations | SharedPreferences | Firestore `users/{uid}/ai_conversations/{id}` | fire-and-forget per conv |
| Meal logs | Drift SQLite | Firestore `users/{uid}/meal_logs/{id}` | SyncService (mobile) |
| Workout logs | Drift SQLite | Firestore `users/{uid}/workout_logs/{id}` | SyncService (mobile) |
| Weight logs | Drift SQLite | Firestore `users/{uid}/weight_logs/{id}` | SyncService (mobile) |
| Progress photos | Drift (metadata) | Firebase Storage | URL stored in Drift |
| Gamification | Drift / Hive | Firestore `users/{uid}.gamification` | on XP change |
| Auth session | Firebase Auth | Firebase Auth (built-in persistence) | auto |

### Cross-Device Sync Guarantee

```
Device A (saves):
  SharedPrefs write → Firestore write (fire-and-forget)

Device B (loads):
  SharedPrefs empty?
    → Firestore cache (IndexedDB on web, Firestore SDK on mobile)
      → Server if cache miss (5s timeout)
        → Restore to SharedPrefs
          → All providers initialized from local cache
```

---

## 8. AI TIER ROUTING

### Chat Messages

```
AiOrchestratorService.chat(message, history, imageBytes?)
  │
  ├─ imageBytes != null?
  │     → Tier 1: Gemini (sends image)
  │         ✓ → return response
  │         ✗ → Tier 2: Groq (text-only, imageBytes stripped)
  │               ✓ → return response
  │               ✗ → Tier 3: On-device Gemma (text-only)
  │                     ✓ → return response
  │                     ✗ → Tier 4: Template
  │
  └─ text-only
        → Tier 1: Gemini
            ✓ → return
            ✗ → Tier 2: Groq
                  ✓ → return
                  ✗ → Tier 3: On-device
                        ✓ → return
                        ✗ → Tier 4: Template
```

### Meal Photo Analysis

```
AiOrchestratorService.analyzeMealPhoto(imageBytes)
  │
  ├─ Tier 1: Gemini Vision
  │     ✓ → structured nutrition response
  │     ✗ → skip Groq (Groq is text-only, useless for photo analysis)
  │
  └─ Tier 2: Local RAG (FoodKnowledgeService)
        → pattern match on visual metadata
          → return estimated macros
```

### Circuit Breaker (per tier)

```
If tier fails N times within window:
  → Circuit OPEN: skip that tier for cooldown period
  → Try next tier directly (avoids repeated latency hits)
  → Circuit HALF-OPEN after cooldown: try once
    → Success → CLOSED again
    → Fail → OPEN again
```

---

## 9. ANALYTICS EVENT MAP

### Events Fired

| Event | When | Key Properties |
|-------|------|---------------|
| `app_open` | Every launch | platform, is_web |
| `splash_viewed` | Splash shown | — |
| `onboarding_step_viewed` | Each step | step_num, step_name |
| `onboarding_completed` | _complete() | total_steps, time_spent_s |
| `onboarding_skipped` | Skip pressed | step_skipped_at |
| `auth_sign_in` | Login success | method (email/google/guest) |
| `auth_sign_up` | Signup success | method, account_linked |
| `auth_error` | Login/signup fail | method, error_code |
| `auth_sign_out` | Sign-out | — |
| `bottom_nav_home` etc | Tab tap | from_tab, to_tab |
| `ai_chat_sent` | Message sent | has_image, msg_len, history_len |
| `ai_chat_received` | Response back | ai_source, duration_ms, resp_len |
| `ai_chat_error` | AI failure | error_type, duration_ms |
| `meal_logged` | Meal saved | calories, protein_g, carbs_g, fat_g |
| `workout_completed` | Workout done | exercises, duration_mins, calories_burned |
| `weight_logged` | Weigh-in saved | value_kg |
| `photo_viewed` | Progress photo viewed | — |
| `paywall_shown` | Paywall pushed | trigger |
| `paywall_dismissed` | Paywall closed without purchase | trigger |
| `purchase_completed` | RevenueCat purchase | product_id, trigger |

### User Properties Set (post-onboarding)

| Property | Values |
|----------|--------|
| `goal_type` | lose_fat / build_muscle / maintain / improve_fitness |
| `activity_level` | sedentary / lightly_active / moderately_active / very_active / extra_active |
| `diet_type` | vegan / vegetarian / keto / halal / omnivore |
| `age_group` | 18-24 / 25-34 / 35-44 / 45-54 / 55+ |
| `gender` | male / female / other |

---

## 10. QUALITY AUDIT

### Audit Run: 2026-04-13

---

### 10.1 Static Analysis

| Result | Detail |
|--------|--------|
| Status | **PASS** |
| Issues | 0 errors, 0 warnings, 0 infos |
| Command | `flutter analyze` (6.0s) |

---

### 10.2 Test Suite

| Result | Detail |
|--------|--------|
| Status | **PASS — 233/233 tests** |
| Test files | 17 |
| Duration | ~3 seconds |

**Test coverage breakdown:**

| Area | Test File | Tests |
|------|-----------|-------|
| LocalAI fallback | `local_ai_fallback_test.dart` | 60+ (intent matching, insights, meal/workout plans) |
| AI orchestrator | `ai_orchestrator_test.dart` | 15 (circuit breaker, routing, fallbacks) |
| Food knowledge | `food_knowledge_service_test.dart` | 9 (Indian + common foods, JSON round-trip) |
| User context | `user_context_service_test.dart` | Various |
| AI cache | `ai_cache_test.dart` | Various |
| Database | `app_database_test.dart` | Schema, CRUD |
| Gamification | `gamification_notifier_test.dart`, `gamification_test.dart` | XP, levels, streaks |
| Onboarding model | `onboarding_data_test.dart` | isComplete logic, fromJson |
| Core widgets | `calorie_ring_test.dart`, `macro_bar_test.dart`, `xp_progress_bar_test.dart`, `app_button_test.dart` | Render, layout |
| Utilities | `tdee_calculator_test.dart`, `meal_utils_test.dart`, `mime_utils_test.dart` | Calorie math, emoji mapping, MIME detection |

---

### 10.3 Code Quality

| Check | Result | Notes |
|-------|--------|-------|
| Bare `print()` calls | **PASS** | 0 found; 410 proper `debugPrint()` usages |
| TODO/FIXME markers | **PASS** | 0 found |
| Hardcoded colors | **PASS** | All use `AppColors.*` |
| `Navigator.push` usage | **PASS** | 0 found; GoRouter used throughout |
| Dead imports | **PASS** | 0 unused imports |
| Business logic in widgets | **PASS** | Riverpod providers hold all state logic |
| Analysis ignores | **INFO** | 2 legitimate `// ignore: unused_field` in analytics_service.dart |

---

### 10.4 Security

| Check | Result | Notes |
|-------|--------|-------|
| Hardcoded API keys | **PASS** | 0 found; all via `--dart-define` |
| Debug UI guarded | **PASS** | Debug/reset actions behind `kDebugMode` |
| Firestore rules — catch-all deny | **PASS** | `match /{document=**} { allow read, write: if false; }` present |
| Firestore rules — auth checks | **PASS** | All 9 paths require `isOwner(userId)` |
| Firestore rules — size guard | **PASS** | `hasReasonableSize()` on writes only (correct) |
| Firestore rules — immutability | **PASS** | meal/workout/weight logs: `allow update: if false` |
| Firestore rules — field-level update | **PASS** | ai_insights: only `dismissed` field updateable |
| HTTP for model download | **INFO** | Acceptable for non-sensitive binary; no credentials transmitted |

---

### 10.5 Architecture Compliance

| Rule | Result |
|------|--------|
| State via Riverpod only | **PASS** |
| Navigation via GoRouter only | **PASS** |
| Relational data via Drift | **PASS** |
| Key-value via Hive/SharedPrefs | **PASS** |
| Auth via Firebase anonymous | **PASS** |
| Firestore path `users/{uid}/...` | **PASS** |
| AI 4-tier fallback | **PASS** |
| Design tokens via `AppColors.*` etc. | **PASS** |
| Touch targets ≥ 48dp | **PASS** (visual inspection) |
| Debug UI behind `kDebugMode` | **PASS** |
| API keys via `--dart-define` only | **PASS** |

---

### 10.6 Large File Refactoring Candidates

These screens are functional but would benefit from widget extraction for long-term maintainability:

| File | Lines | Priority |
|------|-------|----------|
| `ai_coach/screens/ai_coach_screen.dart` | 1,571 | HIGH — extract message bubble, typing indicator, conversation sheet, suggestion chips |
| `nutrition/screens/log_meal_screen.dart` | 1,521 | HIGH — extract macro editor, AI result card, barcode section |
| `dashboard/screens/dashboard_screen.dart` | 1,207 | MEDIUM — extract insight card, calorie ring section, challenge card |
| `workouts/screens/workouts_screen.dart` | 1,094 | MEDIUM — extract plan card, library browser |
| `progress/screens/progress_screen.dart` | 1,001 | MEDIUM — each sub-tab is a refactor candidate |
| `workouts/screens/active_workout_screen.dart` | 954 | MEDIUM |
| `settings/screens/settings_screen.dart` | 951 | LOW |
| `nutrition/screens/nutrition_screen.dart` | 844 | LOW |

---

### 10.7 Dependencies

All dependencies are current and maintained. No deprecated or unmaintained packages detected.

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.6.1 | State management |
| `go_router` | ^14.6.2 | Navigation |
| `drift` | ^2.22.1 | SQLite ORM |
| `firebase_core` | 3.6.0 | Firebase foundation |
| `firebase_auth` | 5.3.0 | Authentication |
| `cloud_firestore` | 5.4.0 | Cloud database |
| `firebase_crashlytics` | — | Crash reporting |
| `firebase_messaging` | — | Push notifications |
| `google_generative_ai` | ^0.4.6 | Gemini AI |
| `flutter_mediapipe_chat` | ^1.0.0 | On-device LLM |
| `purchases_flutter` | — | RevenueCat subscriptions |
| `flutter_animate` | — | Micro-animations |
| `rive` | — | Mascot/character animation |
| `lottie` | — | Celebration animations |

---

### 10.8 Overall Findings Summary

| # | Severity | Category | Finding |
|---|----------|----------|---------|
| 1 | INFO | File Size | 8 screen files >800 lines — refactoring candidates |
| 2 | INFO | HTTP | local_llm_service uses plain HTTP for model download (acceptable) |
| 3 | INFO | Analysis | 2 `// ignore: unused_field` in analytics_service (intentional) |

**No CRITICAL, HIGH, or MEDIUM severity issues found.**

---

### 10.9 Overall Grade

```
Static Analysis:    A+ (0 issues)
Test Coverage:      A  (233/233 passing, 17 files)
Security:           A+ (no vulnerabilities, rules hardened)
Architecture:       A+ (all rules followed)
Code Quality:       A  (clean, consistent patterns)
Maintainability:    B+ (8 large files could be extracted)

Overall:            A  (Production-ready)
```

---

*This document was generated from a full codebase exploration and automated audit on 2026-04-13.*
