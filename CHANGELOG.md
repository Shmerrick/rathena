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

| Date | ID | Name | Change |
|------|----|------|--------|
| 2026-02-27 | HT_BLITZBEAT | Blitz Beat | Auto-trigger rate changed from LUK/3 to LUK/2. Removed bow-only restriction — any physical auto-attack with a falcon active can trigger. Hit-check and crit behavior unchanged (already correct). `src/map/skill.cpp`. |
| 2026-02-27 | MO_TRIPLEATTACK | Triple Attack | Auto-trigger rate changed to 7×skill_lv (RE) / 5×skill_lv (pre-RE), matching TF_DOUBLE scaling. Aftercast delay removed. Combo window replaced with 5-second visual buff (SC_RESTART_COMBO1). Proc restricted to bare fists (W_FIST) or knuckle weapons (W_KNUCKLE) — applies to plagiarism copies. `src/map/battle.cpp`, `src/map/skill.cpp`. |
| 2026-02-27 | MO_CHAINCOMBO | Chain Combo (Raging Quadruple Blow) | Aftercast delay removed. Combo window replaced with 5-second visual buff (SC_RESTART_COMBO2). Weapon restricted to bare fists/knuckles. `src/map/skill.cpp`, `db/re/skill_db.yml`, `db/pre-re/skill_db.yml`. |
| 2026-02-27 | MO_COMBOFINISH | Combo Finish (Raging Thrust) | Aftercast delay removed. Combo window replaced with 5-second visual buff (SC_RESTART_COMBO3). Weapon restricted to bare fists/knuckles. `src/map/skill.cpp`, `db/re/skill_db.yml`, `db/pre-re/skill_db.yml`. |
| 2026-02-27 | MO_EXTREMITYFIST | Asura Strike | Manual standalone cast removed. Can only be used via combo chain (after MO_COMBOFINISH or CH_CHAINCRUSH) or via Root (SC_BLADESTOP active). Fury (SC_EXPLOSIONSPIRITS) is always a required prerequisite (enforced by DB Status requirement) but is not itself a cast path. Weapon restricted to bare fists/knuckles. `src/map/skill.cpp`, `db/re/skill_db.yml`, `db/pre-re/skill_db.yml`. |
| 2026-02-27 | MO_EXPLOSIONSPIRITS | Fury | Reduced to MaxLevel 1 (old level-5 values: +200 crit, 180s duration, 15 SP, 5 spirit balls). Combo skills (MO_CHAINCOMBO, MO_COMBOFINISH, CH_TIGERFIST, CH_CHAINCRUSH) cost 0 SP while Fury is active. `db/re/skill_db.yml`, `db/pre-re/skill_db.yml`, `src/map/status.cpp`, `src/map/skill.cpp`. |
| 2026-02-27 | MO_STEELBODY | Mental Strength | Reduced to MaxLevel 1 (old level-5 values: 150s duration, 200 SP, 5 spirit balls). Can be recast while already active to refresh duration. `db/re/skill_db.yml`, `db/pre-re/skill_db.yml`, `src/map/status.cpp`. |
| 2026-02-27 | TF_DOUBLE, MO_TRIPLEATTACK, MO_CHAINCOMBO, MO_COMBOFINISH | Double/Triple/Chain/Combo Finish | Added `DamageFlags: Critical: true` — these skills can now critically hit. `db/re/skill_db.yml`, `db/pre-re/skill_db.yml`. |

---

## Classes / Jobs

_No changes yet._

---

## Combat Mechanics

| Date | ID | Name | Change |
|------|----|------|--------|
| 2026-02-27 | — | Size Modifiers — Knuckle | Removed all size penalties for knuckle weapons. Pre-RE was Medium:75 Large:50; RE was Large:75. Now 100/100/100 for all sizes. `db/pre-re/size_fix.yml`, `db/re/size_fix.yml`. Bare fists (Fist) were already 100/100/100. |
| 2026-02-27 | — | Boss Protocol — Walk Speed | Boss protocol mobs with MD_CANMOVE move at 100ms/cell (very fast). Immovable bosses (no MD_CANMOVE) unaffected. `src/map/status.cpp` status_calc_speed. |
| 2026-02-27 | — | Boss Protocol — Reflect Shield | New SC_RESTART_BOSS_REFLECT (EFST 1692). Active when no alive player is within 5 cells. Reflects 100% of incoming physical and magical damage back to the attacker; boss takes 0 damage. Removed when any alive player is within ≤5 cells, restored when all players move beyond 5 cells. Toggled each mob AI tick via `mob_ai_sub_hard`. Physical intercept in `battle_calc_return_damage`; magic intercept in `skill_magic_reflect` (type 4, no Renewal recalculation). |
| 2026-02-27 | — | Boss Protocol — Reset on Inactivity | If a boss has taken player damage (HP < 100%) and receives no player damage for 30 seconds, it fully resets: full HP heal, warps to spawn position, kills all slaves, clears target, and triggers MSC_SPAWN to respawn adds. Condition tracks per-boss `last_player_damage_tick` set in `mob_log_damage`. Self-damage and non-player sources do not refresh the timer. `src/map/mob.cpp`, `src/map/mob.hpp`. |

---

## Monsters

_No changes yet._

---

## Maps & Areas

_No changes yet._

---

## Status Effects

| Date | ID | Name | Change |
|------|----|------|--------|
| 2026-02-27 | — | Status Effects | Removed all stat-based SC resistance (VIT/INT/LUK/AGI/MDEF contributions to rate and duration reduction, including SC_CURSE LUK=0 immunity). Boss/MVP targets no longer fully immune — duration clamped to 1ms–1s. Normal targets clamped to 5s–10s. Buff-based resistance (SC_SCRESIST, SC_SIEGFRIED) and item resistance unchanged. `src/map/status.cpp`. |

---

## Stat System

| Date | ID | Name | Change |
|------|----|------|--------|
| 2026-02-26 | — | Stat System | Added pre-RE stat increment bonus additively on Renewal. STR: +floor(STR/10)^2 ATK. INT: +floor(INT/7)^2 MATK min, +floor(INT/5)^2 MATK max. BL_PC only. `src/map/status.cpp`. |

---

## Crafting

| Date | ID | Name | Change |
|------|----|------|--------|
| 2026-02-26 | — | Crafting | Removed DEX/LUK/INT contributions from BS and AM crafting success rates. Replaced with +1% per job level (job_level*100 internal). Affects BS smelting, BS weapon forging (JOBL_THIRD flat bonus also removed), and AM_PHARMACY/TWILIGHT1-3. `src/map/skill.cpp`. |

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
| 2026-02-27 | Build | Fixed C1128 `/bigobj` MSVC compile failure in `skill.cpp` (TASK-0002). Applied via `set_source_files_properties` in `src/map/CMakeLists.txt` under `if(MSVC)` guard — per-file only, no impact on other TUs. |
| 2026-02-27 | Compile | Fixed duplicate `MO_CHAINCOMBO` case in `battle.cpp` `initialize_weapon_data` switch — moved `DMG_MULTI_HIT` assignment into the existing `#ifdef RENEWAL` case. |
| 2026-02-27 | Compile | Fixed `MD_BOSS` (non-existent enum value) used in `status.cpp` and `mob.cpp` — replaced with `md->status.class_ == CLASS_BOSS` (the correct rAthena boss check). |
| 2026-02-27 | Compile | Fixed `&md->bl` in `mob.cpp` boss reset — `mob_data` inherits `block_list` directly, corrected to `md`. |

---

## How to Add Entries

1. Add a row to the appropriate table above.
2. Include the date, affected ID (if applicable), and a plain-English description of what changed and why.
3. Reference the task ID (e.g., `TASK-0002`) if the change came from the agent workflow.
4. Commit alongside the data file change — one commit per logical change.
