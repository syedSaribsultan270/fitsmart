# Flutter Repo Health Check

Run a comprehensive health, quality, and security audit of the FitSmart Flutter repo at
`/Users/vyro/Downloads/fitsmart2.0/fitsmart_app/`. Work through each step below in order,
collect all findings, then print a single summary table and offer to fix any auto-fixable issues.

---

## Step 1 — Static Analysis

Run flutter analyze and capture all output:

```bash
export PATH="$PATH:/Users/vyro/development/flutter/bin"
cd /Users/vyro/Downloads/fitsmart2.0/fitsmart_app
flutter analyze 2>&1
```

Record: issue count, severity (error / warning / info), file + line for each.

---

## Step 2 — Forbidden `print()` Calls

Search for bare `print(` in all production Dart files (lib/ only, exclude generated files):

```bash
grep -rn "^\s*print(" /Users/vyro/Downloads/fitsmart2.0/fitsmart_app/lib \
  --include="*.dart" \
  --exclude="*.g.dart" \
  --exclude="*.freezed.dart"
```

Expected: zero results. Any hit should use `debugPrint()` instead.

---

## Step 3 — TODO / FIXME / HACK / PLACEHOLDER Markers

```bash
grep -rn "TODO\|FIXME\|HACK\|XXX\|BUG\|PLACEHOLDER" \
  /Users/vyro/Downloads/fitsmart2.0/fitsmart_app/lib \
  --include="*.dart" \
  --exclude="*.g.dart"
```

Record each match with file + line.

---

## Step 4 — Magic Numbers in Business Logic

Check for raw numeric literals in calorie/TDEE formulas and timeout values (things that should
be named constants in AppConstants):

```bash
grep -rn "\* 0\.\|> [0-9]\+\b\|inMinutes \* [0-9]" \
  /Users/vyro/Downloads/fitsmart2.0/fitsmart_app/lib/features \
  --include="*.dart" \
  --exclude="*.g.dart"
```

Flag any formula literal not referencing `AppConstants.*`.

---

## Step 5 — Firestore Security Rules

Read `/Users/vyro/Downloads/fitsmart2.0/fitsmart_app/firestore.rules` and verify all of:

- [ ] A catch-all deny rule exists: `match /{document=**} { allow read, write: if false; }` at
      the root level (outside `match /users`)
- [ ] A document-size guard function (`hasReasonableSize()` or equivalent) is present
- [ ] No paths are left open without explicit `request.auth != null` checks

---

## Step 6 — Debug-Only UI Behind `kDebugMode`

```bash
grep -rn -i "reset\|debug\|dev mode\|re-run onboarding" \
  /Users/vyro/Downloads/fitsmart2.0/fitsmart_app/lib/features \
  --include="*.dart" | grep -v "kDebugMode"
```

Any UI text that exposes a debug/reset action to production users is a finding.

---

## Step 7 — Large Screen Files (Widget-Extraction Candidates)

```bash
find /Users/vyro/Downloads/fitsmart2.0/fitsmart_app/lib/features \
  -name "*_screen.dart" | while read f; do
  wc -l "$f"
done | sort -rn | head -15
```

Files > 800 lines are candidates for extracting widgets into the feature's `widgets/` subdirectory.

---

## Step 8 — Tests

```bash
export PATH="$PATH:/Users/vyro/development/flutter/bin"
cd /Users/vyro/Downloads/fitsmart2.0/fitsmart_app
flutter test 2>&1
```

Record: pass / fail count, any failing test names.

---

## Step 9 — Firestore Rules Deployment Check (optional)

If Firebase CLI is available, verify rules are deployed:

```bash
firebase firestore:rules:get --project fitsmart-9c7da 2>&1 | head -30
```

---

## Step 10 — Summary & Fix Offer

After running all steps, print a single findings table:

| # | Severity | Category | File | Line | Issue |
|---|----------|----------|------|------|-------|
| … | CRITICAL / HIGH / MEDIUM / LOW / INFO | … | … | … | … |

Then ask the user:
> "Found N issues. Would you like me to auto-fix all of them now? (yes / no, or list issue numbers to fix selectively)"

Auto-fixable issues include:
- Replacing bare `print()` with `debugPrint()`
- Wrapping debug/reset UI in `if (kDebugMode)`
- Moving magic numbers to `AppConstants`
- Restoring Firestore security helpers
- Removing underscore prefixes from local variable names flagged by the linter

Non-auto-fixable (require user action):
- Firebase `PLACEHOLDER` app IDs (need google-services.json from Firebase Console)
- Adding more unit/widget tests
- Splitting large screen files into widget components
