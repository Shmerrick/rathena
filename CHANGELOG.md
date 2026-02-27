# Changelog

Tracks all intentional changes to game mechanics in this server relative to upstream rAthena defaults.
Organized by category. Entries include the affected ID, a description, and the date of change.

---

## Items

| Date | Item ID | Item Name | Change |
|------|---------|-----------|--------|
| 2026-02-26 | 19163 | Catherina Von Blood | Corrected script and trade restrictions (upstream fix — not a local customization). |

---

## Skills

_No changes yet._

---

## Classes / Jobs

_No changes yet._

---

## Monsters

_No changes yet._

---

## Maps & Areas

_No changes yet._

---

## Economy & Systems

_No changes yet._

---

## NPC / Quests

_No changes yet._

---

## Bug Fixes

| Date | Category | Description |
|------|----------|-------------|
| 2026-02-26 | Build | Identified pre-existing C1128 `/bigobj` MSVC compile failure in `skill.cpp`. Tracked as TASK-0002. Not yet fixed. |

---

## How to Add Entries

1. Add a row to the appropriate table above.
2. Include the date, affected ID (if applicable), and a plain-English description of what changed and why.
3. Reference the task ID (e.g., `TASK-0002`) if the change came from the agent workflow.
4. Commit alongside the data file change — one commit per logical change.
