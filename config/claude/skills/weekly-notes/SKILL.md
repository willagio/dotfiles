---
name: weekly-notes
description: "Generate a weekly Obsidian summary from daily notes, saved to ~/obsidian-vault/weekly/YYYY-WXX.md. Use when the user asks for weekly notes, a weekly review, or a weekly Obsidian summary."
---

# Weekly Notes Skill

Generate a weekly summary note from Obsidian daily notes.

## Invocation

- Claude Code: `/weekly-notes`
- Codex: `$weekly-notes`

## Instructions

You are generating a weekly notes summary from the user's Obsidian vault daily notes.

### Vault Info
- Vault path: `~/obsidian-vault`
- Daily notes folder: `~/obsidian-vault/daily/`
- Daily note format: `YYYY-MM-DD.md`
- Weekly notes output folder: `~/obsidian-vault/weekly/`

### Steps

1. **Determine the target week**: If the user specifies a date or week, use that. Otherwise default to the most recently completed week (Monday through Sunday). Use the current date to calculate this.

2. **Read daily notes**: Read all daily notes (`YYYY-MM-DD.md`) from `~/obsidian-vault/daily/` that fall within the target week (Monday to Sunday).

3. **Generate the weekly note** at `~/obsidian-vault/weekly/YYYY-WXX.md` where `YYYY` is the year and `XX` is the ISO week number. Use the following format:

```markdown
---
id: "YYYY-WXX"
aliases: []
tags:
  - weekly-notes
---

# Weekly Notes: YYYY-WXX (Mon DD - Sun DD)

## Morning Routine Summary
<!-- Tally completed vs total for each routine item across the week -->
| Habit | Completed | Total |
|-------|-----------|-------|
| Work out | X | Y |
| Read the Bible | X | Y |
| Read a book | X | Y |
| Study for 30 minutes | X | Y |
| Write in daily journal | X | Y |

## Goals
<!-- List all goals from the week's daily notes -->

## Tasks
<!-- List all tasks, grouped by status: completed [x], in-progress [>], incomplete [ ] -->
### Completed
### In Progress
### Incomplete

## Notes
<!-- Combine all notes from the week -->

## What I Learned
<!-- Combine all learnings from the week -->

## Journal Summary
<!-- Write a cohesive summary of all journal entries from the week, preserving the language used in the original entries (Korean or English). Highlight recurring themes or patterns. -->

## Weekly Reflection
<!-- Based on all the daily notes, provide a brief reflection:
- What went well this week?
- What could be improved?
- Any patterns noticed? -->
```

4. **Important rules**:
   - If a daily note is missing for a day, skip it — don't assume anything.
   - Preserve the original language of journal entries (Korean/English).
   - For the Journal Summary section, synthesize — don't just concatenate entries.
   - For the Weekly Reflection, provide genuine insight based on patterns in the data.
   - Create the `weekly/` directory if it doesn't exist.
   - If the weekly note already exists, ask the user before overwriting.
