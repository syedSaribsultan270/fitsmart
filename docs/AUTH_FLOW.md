# FitSmart Auth Flow — Complete Map

## Entry Points

```
App start → /splash → SplashScreen._navigate()
```

SplashScreen does its own routing logic (duplicates the router redirect):
- No Firebase user → `/login`
- Local onboarding done → `/dashboard`
- Firestore recovery succeeds → `/dashboard`
- Otherwise → `/onboarding`

GoRouter also has a `redirect` that re-runs on every auth state change (via `_GoRouterRefreshStream`).

---

## All User States

| State | `user` | `isAnonymous` | `onboardingDone` |
|-------|--------|---------------|-----------------|
| Not signed in | null | — | — |
| Anonymous / guest | non-null | true | false → true after onboarding |
| Email/Google user | non-null | false | false → true after onboarding |

---

## Router Redirect Logic (router.dart)

```
user == null
  └─ on auth/splash route → stay (null)
  └─ anywhere else → /login

user != null, isAnonymous
  ├─ onboardingDone
  │   ├─ on auth route (/login, /signup, /forgot-password) → /dashboard  ← BUG #1
  │   └─ anywhere else → stay (null)
  └─ NOT onboardingDone
      ├─ try Firestore recovery → if recovered → /dashboard
      └─ on auth/onboarding route → stay
         elsewhere → /onboarding

user != null, NOT anonymous
  ├─ onboardingDone
  │   ├─ on auth/onboarding route → /dashboard
  │   └─ anywhere else → stay (null)
  └─ NOT onboardingDone
      ├─ try Firestore recovery → if recovered → /dashboard
      └─ on onboarding route → stay
         elsewhere → /onboarding
```

---

## Flow 1 — New user, email signup (happy path)

```
/login → tap "Sign Up" → context.push('/signup')
  → SignupScreen
  → signUpWithEmail() → Firebase creates user
  → context.go('/onboarding')
  → auth state changes → redirect fires
     user is real, onboardingDone=false → stays on /onboarding ✓
  → completes onboarding → notifier.saveToPrefs() → context.go('/dashboard') ✓
```

**Issue:** `context.push('/signup')` from login screen adds to nav stack, meaning signup has a back button (good, intentional — user can go back to login).

---

## Flow 2 — Existing email/Google user, second launch

```
/splash → AuthService.currentUser != null
  → isOnboardingCompleteLocal() → true
  → context.go('/dashboard') ✓
```

Redirect also fires on auth state restoration and confirms: real user, onboardingDone → stays on dashboard ✓

---

## Flow 3 — Anonymous / guest user

```
/login → "Continue as Guest"
  → signInAnonymously()
  → context.go('/onboarding')   [explicit in _continueAsGuest()]
  → redirect fires: anonymous, onboardingDone=false → /onboarding ✓
  → completes onboarding → /dashboard ✓
```

---

## Flow 4 — Anonymous user upgrading account ← BROKEN (BUG #1)

```
/dashboard (anonymous, onboarding done)
  → taps "Sign Up" in UpgradePromptBanner
  → context.push('/signup')
  → redirect fires: anonymous user, onboardingDone=true, loc='/signup'
     isAuthRoute=true → return '/dashboard'   ← REDIRECT BLOCKS UPGRADE
  → GoRouter redirects to /dashboard instead of showing signup
  → BUT because push was used, dashboard appears with a back button
  → back → back to dashboard (the push origin) ← confusing loop
```

**Fix:** Don't redirect anonymous users away from `/signup`. Only block `/login` 
(and `/forgot-password`) for anonymous users who have completed onboarding.

---

## Flow 5 — Anonymous → Google upgrade on signup screen

```
/signup (from anonymous user via UpgradePromptBanner)
  → "Sign up with Google" 
  → wasAnonymous=true
  → signInWithGoogle() → linkWithPopup OR credential-already-in-use fallback
  → if mounted: check isOnboardingCompleteLocal() → true → context.go('/dashboard')
  → redirect fires: real user, onboardingDone=true → stays on /dashboard ✓
```

Works correctly after BUG #1 fix.

---

## Flow 6 — Anonymous → email upgrade on signup screen

```
/signup (from anonymous user)
  → "Create Account"
  → wasAnonymous=true → linkWithEmail()
  → context.go('/dashboard')   [because wasAnonymous=true]
  → redirect fires: real user (UID preserved), onboardingDone=true → /dashboard ✓
```

Works correctly after BUG #1 fix.

---

## Flow 7 — Reinstall / new device (Firestore recovery)

```
/splash → Firebase user exists (auth persists)
  → isOnboardingCompleteLocal() → false (new device, no SharedPrefs)
  → tryRestoreFromFirestore(uid)
    → reads users/{uid} from Firestore
    → BEFORE RULES FIX: "Missing or insufficient permissions" (hasReasonableSize on read)
    → AFTER RULES FIX: reads profile, checks data.isComplete, restores to SharedPrefs
  → if recovered → /dashboard ✓
  → if not (no Firestore profile) → /onboarding
```

Firestore rules fix already deployed.

---

## Flow 8 — Fresh Google sign-in, user has profile in Firestore

```
/login → "Continue with Google"
  → signInWithGoogle() → Firebase signs in
  → auth state changes → redirect fires
  → real user, isOnboardingCompleteLocal() → false (web/new device)
  → tryRestoreFromFirestore(uid) → returns profile → restored ✓
  → redirect returns null → stays on current route OR /dashboard
```

---

## Bugs Found

### BUG #1 — CRITICAL: Redirect blocks anonymous users from reaching /signup

**File:** `router.dart:77`
**Symptom:** Tapping "Sign Up" from dashboard sends user back to dashboard with a back button.
**Cause:** The redirect rule for `(anonymous && onboardingDone)` treats `/signup` as an auth route and redirects to `/dashboard` — but `/signup` is the upgrade path for anonymous users.
**Fix:** Only redirect anonymous users away from `/login` and `/forgot-password`, not from `/signup`.

```dart
// BEFORE (wrong):
if (isAuthRoute || isOnboardingRoute) return '/dashboard';

// AFTER (correct):
if (loc == '/login' || loc == '/forgot-password' || isOnboardingRoute) return '/dashboard';
```

### BUG #2 — MINOR: SignupScreen is a StatefulWidget, not ConsumerStatefulWidget

**File:** `signup_screen.dart:12`
**Issue:** Cannot read Riverpod providers (e.g., settingsProvider for theme toggle) — not blocking functionality but inconsistent with the rest of the codebase. Not affecting the described bug, low priority.

### BUG #3 — RESOLVED: Firestore rules blocked profile reads

`hasReasonableSize()` referenced `request.resource.data` on read operations → all profile reads failed → Firestore recovery always failed → users sent to onboarding on reinstall/new device.
**Status:** Fixed and deployed.

---

## Auth Routes Reference

| Route | Type | Accessible by |
|-------|------|---------------|
| `/login` | auth | unauthenticated only (redirect away if authed) |
| `/signup` | auth | unauthenticated + anonymous (upgrade path) |
| `/forgot-password` | auth | unauthenticated only |
| `/onboarding` | onboarding | any user who hasn't completed it |
| `/dashboard` | main | any authenticated + onboarded user |

---

## Execution Plan

1. Fix `router.dart`: allow anonymous users to visit `/signup`
2. Verify all 8 flows above work correctly after the fix
3. Run `flutter analyze`
