#!/usr/bin/env zsh
# FitSmart repo health & quality check
# Usage: ./healthcheck.sh
# Run from: /Users/vyro/Downloads/fitsmart2.0

export PATH="$PATH:/Users/vyro/development/flutter/bin"
APP="fitsmart_app"
LIB="$APP/lib"
FEATURES="$APP/lib/features"

PASS=0; FAIL=0; WARN=0
SEP="─────────────────────────────────────────────"

_ok()   { echo "  ✅  $1"; ((PASS++)); }
_fail() { echo "  ❌  $1"; ((FAIL++)); }
_warn() { echo "  ⚠️   $1"; ((WARN++)); }
_head() { echo "\n$SEP\n  $1\n$SEP"; }

# ── 1. Flutter Analyze ─────────────────────────────────────────────────────
_head "1 · Flutter Analyze"
ANALYZE=$(cd $APP && flutter analyze 2>&1)
ERRORS=$(echo "$ANALYZE" | grep -c "error •" || true)
WARNINGS=$(echo "$ANALYZE" | grep -c "warning •" || true)
INFOS=$(echo "$ANALYZE" | grep -c "info •" || true)
if echo "$ANALYZE" | grep -q "No issues found"; then
  _ok "No issues found"
elif [ "$ERRORS" -gt 0 ]; then
  _fail "$ERRORS error(s), $WARNINGS warning(s), $INFOS info(s)"
  echo "$ANALYZE" | grep "error •" | sed 's/^/       /'
else
  _warn "$WARNINGS warning(s), $INFOS info(s) — no errors"
  echo "$ANALYZE" | grep "warning •" | sed 's/^/       /'
fi

# ── 2. Bare print() calls ──────────────────────────────────────────────────
_head "2 · Bare print() calls (should use debugPrint)"
PRINTS=$(grep -rn "^\s*print(" $LIB --include="*.dart" \
  --exclude="*.g.dart" --exclude="*.freezed.dart" 2>/dev/null || true)
if [ -z "$PRINTS" ]; then
  _ok "No bare print() calls"
else
  _fail "Found bare print() calls:"
  echo "$PRINTS" | sed 's/^/       /'
fi

# ── 3. TODO / FIXME / HACK / PLACEHOLDER markers ──────────────────────────
_head "3 · TODO / FIXME / HACK / PLACEHOLDER markers"
TODOS=$(grep -rn "TODO\|FIXME\|HACK\|XXX\|BUG\|PLACEHOLDER" $LIB \
  --include="*.dart" --exclude="*.g.dart" 2>/dev/null || true)
if [ -z "$TODOS" ]; then
  _ok "No TODO/FIXME/HACK/PLACEHOLDER markers"
else
  COUNT=$(echo "$TODOS" | wc -l | tr -d ' ')
  _warn "$COUNT marker(s) found:"
  echo "$TODOS" | sed 's/^/       /'
fi

# ── 4. Hardcoded API keys / secrets ───────────────────────────────────────
_head "4 · Hardcoded secrets check"
SECRETS=$(grep -rn "AIzaSy\|sk-\|Bearer \|api_key\s*=\s*['\"]" $LIB \
  --include="*.dart" --exclude="*.g.dart" \
  --exclude="firebase_options.dart" 2>/dev/null || true)
if [ -z "$SECRETS" ]; then
  _ok "No hardcoded secrets found (firebase_options excluded by design)"
else
  _fail "Potential secrets found:"
  echo "$SECRETS" | sed 's/^/       /'
fi

# ── 5. Debug UI not behind kDebugMode ────────────────────────────────────
_head "5 · Debug/reset UI exposed to production"
DEBUG_UI=$(grep -rn -i "reset\|re-run onboarding\|dev mode" $FEATURES \
  --include="*.dart" 2>/dev/null | grep -v "kDebugMode" || true)
if [ -z "$DEBUG_UI" ]; then
  _ok "All debug UI is behind kDebugMode"
else
  _fail "Debug UI exposed to production:"
  echo "$DEBUG_UI" | sed 's/^/       /'
fi

# ── 6. Firestore rules safety ─────────────────────────────────────────────
_head "6 · Firestore security rules"
RULES="$APP/firestore.rules"
if grep -q 'allow read, write: if false' $RULES 2>/dev/null; then
  _ok "Catch-all deny rule present"
else
  _fail "Missing catch-all deny rule in firestore.rules"
fi
if grep -q "request.auth != null" $RULES 2>/dev/null; then
  _ok "Auth checks present in rules"
else
  _warn "No auth checks found in firestore.rules — verify manually"
fi

# ── 7. Large screen files (> 600 lines) ───────────────────────────────────
_head "7 · Large screen files (> 600 lines)"
LARGE=$(find $FEATURES -name "*_screen.dart" -exec wc -l {} \; 2>/dev/null \
  | awk '$1 > 600 {print $1" lines  "$2}' | sort -rn)
if [ -z "$LARGE" ]; then
  _ok "All screen files are under 600 lines"
else
  _warn "Large files (consider extracting widgets):"
  echo "$LARGE" | sed 's/^/       /'
fi

# ── 8. Missing widget tests for screens ───────────────────────────────────
_head "8 · Test coverage (screen files vs test files)"
SCREENS=$(find $FEATURES -name "*_screen.dart" | wc -l | tr -d ' ')
TESTS=$(find $APP/test -name "*_test.dart" 2>/dev/null | wc -l | tr -d ' ')
if [ "$TESTS" -ge "$SCREENS" ]; then
  _ok "$TESTS test file(s) for $SCREENS screen(s)"
else
  _warn "$TESTS test file(s) for $SCREENS screen(s) — consider adding more tests"
fi

# ── 9. flutter test ───────────────────────────────────────────────────────
_head "9 · flutter test"
TEST_OUT=$(cd $APP && flutter test 2>&1)
if echo "$TEST_OUT" | grep -q "All tests passed"; then
  PASSED=$(echo "$TEST_OUT" | grep -o "[0-9]* passed" | tail -1)
  _ok "All tests passed ($PASSED)"
elif echo "$TEST_OUT" | grep -q "Some tests failed"; then
  FAILED=$(echo "$TEST_OUT" | grep -o "[0-9]* failed" | tail -1)
  _fail "Tests failed ($FAILED)"
  echo "$TEST_OUT" | grep "FAILED\|ERROR" | head -10 | sed 's/^/       /'
else
  _warn "Could not determine test result — check output manually"
fi

# ── 10. pubspec dependency check ─────────────────────────────────────────
_head "10 · Outdated dependencies"
OUTDATED=$(cd $APP && flutter pub outdated 2>&1 | grep -v "^$\|No dependencies" | head -20 || true)
if echo "$OUTDATED" | grep -q "No dependencies"; then
  _ok "All dependencies up to date"
else
  _warn "Some dependencies may be outdated (run: flutter pub outdated)"
fi

# ── Summary ───────────────────────────────────────────────────────────────
echo "\n$SEP"
echo "  HEALTH CHECK SUMMARY"
echo "$SEP"
echo "  ✅  Passed:   $PASS"
echo "  ⚠️   Warnings: $WARN"
echo "  ❌  Failed:   $FAIL"
echo "$SEP\n"

if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  exit 0
fi
