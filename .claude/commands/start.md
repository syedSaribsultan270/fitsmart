# Session Start — Load Context & Set Mode

You are opening a work session. $ARGUMENTS describes the planned work (may be empty).

Execute these steps in order:

## 1. Load relevant memory
Read MEMORY.md at `/Users/vyro/.claude/projects/-Users-vyro-Downloads-fitsmart2-0/memory/MEMORY.md`.
Then read whichever topic files are relevant to the planned work area. Common ones:
- `ai_services.md` — for AI/ML work
- `architecture.md` — for routing, state, nav changes
- `database_tables.md` — for Drift/Hive schema work
- `design_system.md` — for UI work
- `gotchas_feedback.md` — always worth checking

## 2. Classify the work type
Based on $ARGUMENTS (or ask if empty), assign one of:

| Type | What it means |
|---|---|
| **Debug** | Fixing a broken thing — read → diagnose → patch → verify |
| **Build** | New feature or screen — memory → plan → confirm → execute → verify |
| **Explore** | Understanding something — subagent, no code changes |
| **Audit** | Quality sweep — `/health-check` skill |
| **Creative** | Open-ended design — propose first, execute after |
| **Sensitive** | Auth / Firestore / AI orchestrator — Plan mode, no surprises |

## 3. Surface relevant context
Print a brief (~5 bullet) context brief:
- What memory was loaded
- Which files are likely in scope
- Any gotchas relevant to this area (from memory)
- The mode that will be used
- Multi-role flags: any immediate signals from engineer / designer / PM / founder perspective

## 4. Proceed
If $ARGUMENTS is a Build or Creative task → run Discovery (3–5 questions from multiple role lenses) before any planning.
If $ARGUMENTS is Debug/Explore/Audit → begin immediately in the classified mode.
If $ARGUMENTS is vague or empty → ask: "What's the first thing?"
