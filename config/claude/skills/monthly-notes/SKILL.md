---
name: monthly-notes
description: "Generate an Obsidian monthly summary from weekly notes and any daily notes needed to fill gaps, saved to ~/obsidian-vault/monthly/YYYY-MM.md. Use when the user asks for monthly notes, a monthly review, or a monthly Obsidian summary."
---

# Monthly Notes Skill

Generate a monthly summary note from Obsidian weekly notes and daily notes.

## Invocation

- Claude Code: `/monthly-notes`
- Codex: `$monthly-notes`

## Instructions

You are generating a monthly notes summary from the user's Obsidian vault weekly and daily notes.

### Vault Info
- Vault path: `~/obsidian-vault`
- Daily notes folder: `~/obsidian-vault/daily/`
- Daily note format: `YYYY-MM-DD.md`
- Weekly notes folder: `~/obsidian-vault/weekly/`
- Weekly note format: `YYYY-WXX.md`
- Monthly notes output folder: `~/obsidian-vault/monthly/`

### Steps

1. **Determine the target month**: If the user specifies a month, use that. Otherwise default to the most recently completed month. Use the current date to calculate this.

2. **Read weekly notes**: Read all weekly notes (`YYYY-WXX.md`) from `~/obsidian-vault/weekly/` whose weeks overlap with the target month. If weekly notes are missing, fall back to reading daily notes directly from `~/obsidian-vault/daily/` for those periods.

3. **Read daily notes as needed**: If any weekly notes are missing, read the individual daily notes (`YYYY-MM-DD.md`) for those gaps to ensure full month coverage.

4. **Generate the monthly note** at `~/obsidian-vault/monthly/YYYY-MM.md` where `YYYY-MM` is the year and month. Use the following format:

```markdown
---
id: "YYYY-MM"
aliases: []
tags:
  - monthly-notes
---

# Monthly Notes: YYYY-MM (Month Name YYYY)

## Morning Routine Summary
<!-- Aggregate completed vs total for each routine item across the entire month -->
| Habit | Completed | Total | Rate |
|-------|-----------|-------|------|
| Work out | X | Y | Z% |
| Read the Bible | X | Y | Z% |
| Read a book | X | Y | Z% |
| Study for 30 minutes | X | Y | Z% |
| Write in daily journal | X | Y | Z% |

## Goals
<!-- Consolidate all goals from the month's weekly/daily notes. Group by status: achieved, in-progress, dropped/deferred. -->
### Achieved
### In Progress
### Dropped / Deferred

## Tasks Overview
<!-- High-level summary of tasks across the month -->
- Completed: N tasks
- In Progress: N tasks
- Incomplete: N tasks

### Key Completed Tasks
<!-- List the most significant completed tasks -->

### Carried Over
<!-- Tasks still in progress or incomplete that carry into next month -->

## Notes
<!-- Combine and organize all notes from the month, grouped by topic where possible -->

## What I Learned
<!-- Combine all learnings from the month -->

## Journal Summary
<!-- Write a cohesive summary of the month's journal entries, preserving the language used in the original entries (Korean or English). Highlight recurring themes, mood patterns, and significant events. -->

## Monthly Reflection
<!-- Based on all the weekly/daily notes, provide a thorough reflection:
- What were the biggest wins this month?
- What were the biggest challenges?
- What patterns or trends emerged across weeks?
- How did habits and routines evolve over the month?
- What should be the focus for next month? -->
```

5. **Important rules**:
   - Prefer weekly notes as the primary source; use daily notes to fill gaps.
   - If a daily or weekly note is missing, skip it — don't assume anything.
   - Preserve the original language of journal entries (Korean/English).
   - For the Journal Summary section, synthesize — don't just concatenate entries.
   - For the Monthly Reflection, provide genuine insight based on patterns across weeks.
   - Include completion rate percentages in the Morning Routine Summary.
   - Create the `monthly/` directory if it doesn't exist.
   - If the monthly note already exists, ask the user before overwriting.
