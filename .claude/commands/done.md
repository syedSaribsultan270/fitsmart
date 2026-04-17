# Session End — Wrap Up

You are closing out a work session. Run these steps in sequence:

## 1. Audit open work
List every task that was started or mentioned this session.
For each, state one of: ✅ Complete | 🔄 In progress | ⚠️ Blocked | 🗑️ Dropped.
If anything is in progress or blocked, explain what's left and why.

## 2. Verify the last changes
If any Dart files were modified, run:
```bash
export PATH="$PATH:/Users/vyro/development/flutter/bin" && cd /Users/vyro/Downloads/fitsmart2.0/fitsmart_app && flutter analyze --no-pub 2>&1
```
Report: pass (0 issues) or list any errors/warnings.

## 3. Save discoveries to memory
Check `/Users/vyro/.claude/projects/-Users-vyro-Downloads-fitsmart2-0/memory/MEMORY.md` and the relevant topic files.
Save anything learned this session that is:
- Non-obvious (not derivable from just reading the code)
- Likely to matter in a future session
- Not already recorded

Do NOT save: ephemeral task details, what files were read, obvious things.

## 4. Print the session summary table

| Item | Status | Notes |
|---|---|---|
| [what was built/fixed] | ✅ | [file changed] |
| [what was pending] | 🔄 | [what's left] |

## 5. Close
Ask: "Anything else, or good to go?"
