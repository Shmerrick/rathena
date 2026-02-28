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
| 2026-02-27 | SM_BASH | Bash | SP: 15 all levels. Damage: 220–400% (lv1→lv10, +20%/lv). 2nd class+: 2× damage and 2× SP. `db/re/skill_db.yml`, `src/map/skills/swordman/bash.cpp`, `src/map/battle.cpp`, `src/map/skill.cpp`. |
| 2026-02-27 | SM_ENDURE | Endure | Duration: 60s all levels. SP: 30 all levels. `db/re/skill_db.yml`. |
| 2026-02-27 | SM_MAGNUM | Magnum Break | Damage: 110–200% (lv1→lv10, +10%/lv). HP cost removed. 2nd class+: 2× damage and 2× SP. `db/re/skill_db.yml`, `src/map/skills/swordman/magnum.cpp`, `src/map/battle.cpp`, `src/map/skill.cpp`. |
| 2026-02-27 | MG_NAPALMBEAT | Napalm Beat | Element: Neutral. SP: 60 all levels. MATK: 50–500% (lv1→lv10, +50%/lv). VCT: 0.5s+(0.3×lv). AfterCastDelay: 1400ms. IgnoreMDEF. `db/re/skill_db.yml`, `src/map/skills/mage/napalmbeat.cpp`, `src/map/battle.cpp`. |
| 2026-02-27 | MG_SOULSTRIKE | Soul Strike | HitCount: 1/1/1/2/2/3/3/4/4/5 (lv1→lv10). SP: 20/20/30/30/40/40/50/50/60/60. MATK: 200% per hit. Undead bonus removed. `db/re/skill_db.yml`, `src/map/skills/mage/soulstrike.cpp`. |
| 2026-02-27 | MG_STONECURSE | Stone Curse | VCT: 1000ms all levels. SP: 30 all levels. Gemstone always consumed regardless of success/level. New success formula: cap_value(50 + skill_lv×50 − (caster_lv − target_lv), 0, 100). `db/re/skill_db.yml`, `src/map/skills/mage/stonecurse.cpp`. |
| 2026-02-27 | MG_FIREBALL | Fire Ball | SP: 60 all levels. MATK: 50–500% (lv1→lv10). VCT: 0.5s+(0.3×lv). AfterCastDelay: 1400ms. `db/re/skill_db.yml`, `src/map/skills/mage/fireball.cpp`. |
| 2026-02-27 | TF_SPRINKLESAND | Envenom | SP: 15 all levels. `db/re/skill_db.yml`. |
| 2026-02-27 | TF_STEAL | Steal | New success formula: cap_value((0.5 + skill_lv×0.5 − (DEX − targetDEX)) × 100, 0, 100). `src/map/pc.cpp`. |
| 2026-02-27 | AC_DOUBLE | Double Strafe | SP: 15 all levels. Damage: 55–100% (lv1→lv10). 2nd class+: 2× damage and 2× SP. `db/re/skill_db.yml`, `src/map/skills/archer/doublestrafe.cpp`, `src/map/battle.cpp`, `src/map/skill.cpp`. |
| 2026-02-27 | AC_SHOWER | Arrow Shower | SP: 30 all levels. Damage: 55–100% (lv1→lv10). Area: always 5×5. No knockback. 2nd class+: 2× damage and 2× SP. `db/re/skill_db.yml`, `conf/battle/skill.conf`, `src/map/skills/archer/arrowshower.cpp`, `src/map/battle.cpp`, `src/map/skill.cpp`. |
| 2026-02-27 | MC_MAMMONITE | Mammonite | SP: 15 all levels. Damage: 550–1000% (lv1→lv10). 2nd class+: 2× damage, 2× SP, 2× zeny cost. `db/re/skill_db.yml`, `src/map/skills/merchant/mammonite.cpp`, `src/map/battle.cpp`, `src/map/skill.cpp`. |
| 2026-02-27 | MC_CARTREVOLUTION | Cart Revolution | SP: 30 all levels. Damage: 200% flat (no weight scaling). 2nd class+: 2× damage and 2× SP. `db/re/skill_db.yml`, `src/map/skills/merchant/cartrevolution.cpp`, `src/map/battle.cpp`, `src/map/skill.cpp`. |
| 2026-02-27 | KN_PIERCE | Pierce | SP: 30 all levels. Damage: 220–400% (lv1→lv10). `db/re/skill_db.yml`, `src/map/skills/swordman/pierce.cpp`. |
| 2026-02-27 | KN_BRANDISHSPEAR | Brandish Spear | SP: 30 all levels. Damage: 250–700% (lv1→lv10, +50%/lv). No inner/outer split. `db/re/skill_db.yml`, `src/map/skills/swordman/brandishspear.cpp`. |
| 2026-02-27 | KN_SPEARSTAB | Spear Stab | SP: 30 all levels. Damage: 220–400% (lv1→lv10). `db/re/skill_db.yml`, `src/map/skills/swordman/spearstab.cpp`. |
| 2026-02-27 | KN_SPEARBOOMERANG | Spear Boomerang | SP: 15 all levels. Damage: 120–200% (lv1→lv5). `db/re/skill_db.yml`, `src/map/skills/swordman/spearboomerang.cpp`. |
| 2026-02-27 | KN_BOWLINGBASH | Bowling Bash | SP: 60 all levels. Damage: 220–400% (lv1→lv10). `db/re/skill_db.yml`, `src/map/skills/swordman/bowlingbash.cpp`. |
| 2026-02-27 | CR_HOLYCROSS | Holy Cross | SP: 15 all levels. Damage: 220–400% (lv1→lv10). Blind chance: 5–50% (lv1→lv10, +5%/lv). `db/re/skill_db.yml`, `src/map/skills/swordman/holycross.cpp`. |
| 2026-02-27 | CR_SHIELDCHARGE | Smite | Stun chance: 30–50% (lv1→lv5, +5%/lv). `src/map/skills/swordman/smite.cpp`. |
| 2026-02-27 | AL_DECAGI | Decrease AGI | New success formula: cap_value((0.5 + skill_lv×0.5 − (caster_lv − target_lv)) × 100, 0, 100). `src/map/skills/acolyte/decagi.cpp`. |
| 2026-02-27 | AL_CRUCIS | Signum Crucis | Now affects ALL enemies (not only demon/undead). Demon/undead get full DEF reduction (10+4×lv%), all others get half (5+2×lv%). New success formula: same pattern as Decrease AGI. SP: 100. On success: grants Divine Fury buff (SC_RESTART_DIVINE_FURY) to caster for 30s. Auto-cast: 5% chance per physical hit (100% vs demon/undead); 30s cooldown via Divine Fury buff presence. `src/map/skills/acolyte/crucis.cpp`, `src/map/status.cpp`, `src/map/battle.cpp`. |
| 2026-02-27 | WZ_WATERBALL | Water Ball | MaxLevel extended to 10 with extrapolated lv6–10 parameters. `db/re/skill_db.yml`. |
| 2026-02-27 | WZ_FIREPILLAR | Fire Pillar | Deals ×4 MATK (normal + 300%) when a Volcano land is active on the cell; Volcano is consumed. `src/map/skill.cpp`, `src/map/skills/mage/firepillar.cpp`. |
| 2026-02-27 | WZ_ESTIMATION | Sense | On successful use: applies 10% MDEF reduction debuff (SC_RESTART_SENSED) to target for 60s. `src/map/skills/mage/sense.cpp`, `src/map/status.cpp`, `src/map/status.hpp`. |
| 2026-02-27 | SA_FLAMELAUNCHER, SA_FROSTWEAPON, SA_LIGHTNINGLOADER, SA_SEISMICWEAPON | Endows | Material cost changed to 1 Red Gemstone (was various custom "Pts" items). `db/re/skill_db.yml`. |
| 2026-02-27 | SA_VOLCANO, SA_DELUGE, SA_VIOLENTGALE | Land Skills | Material cost changed to 1 Yellow Gemstone. Area: 9×9 (Unit.Layout 4). `db/re/skill_db.yml`. |
| 2026-02-27 | SA_LANDPROTECTOR | Magnetic Earth | Prerequisites changed to: Canyon lv5, Volcano lv5, Deluge lv5, Violent Gale lv5. `db/re/skill_tree.yml`. |
| 2026-02-27 | RESTART_STEADFASTCONVICTION (20020) | Steadfast Conviction | New passive skill. Acolyte/Priest/Monk: MaxLevel 10; Crusader: MaxLevel 5. Effect: +5×lv mastery ATK vs demon/undead, −1%×lv damage taken from demon/undead. Replaces AL_DEMONBANE prerequisite for Monk's MO_IRONHAND. `src/map/skill.hpp`, `src/map/status.cpp`, `src/map/battle.cpp`, `db/re/skill_db.yml`, `db/re/skill_tree.yml`. |
| 2026-02-27 | RESTART_CANYON (20021) | Canyon | New Sage land skill. MaxLevel 5. Earth element booster + DEF/MDEF buff for occupants. Prerequisite for SA_LANDPROTECTOR (Canyon lv5 required). Material: 1 Yellow Gemstone. First cast consumes gemstone; subsequent casts free while Land Mastery buff is active. `src/map/skill.hpp`, `src/map/status.hpp`, `db/re/skill_db.yml`, `db/re/skill_tree.yml`, `src/map/skill.cpp` (UNT_CANYON = 0xc5). |
| 2026-02-27 | KN_TWOHANDQUICKEN | Two-Handed Quicken | Reaching lv10 auto-grants KN_ONEHAND lv1. `src/map/pc.cpp`. |
| 2026-02-27 | MC_WEIGHTLIMIT | Enlarge Weight Limit | Reaching lv10 auto-grants MC_PUSHCART lv1. `src/map/pc.cpp`. |
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

| Date | ID | Name | Change |
|------|----|------|--------|
| 2026-02-27 | — | Priest / High Priest / Archbishop | Cannot equip knuckle weapons (W_KNUCKLE). Enforced in `pc_isequip`. `src/map/pc.cpp`. |
| 2026-02-27 | — | Taekwon / Ninja / Gunslinger / Doram | Job change into these class trees disabled server-wide. `pc_jobchange` returns false for MAPID_TAEKWON, MAPID_NINJA, MAPID_GUNSLINGER, MAPID_SUMMONER. `src/map/pc.cpp`. |
| 2026-02-27 | Acolyte | Acolyte Tree | Removed AL_DEMONBANE and PR_BENEDICTIO. Added RESTART_STEADFASTCONVICTION (MaxLevel 10). `db/re/skill_tree.yml`. |
| 2026-02-27 | Crusader | Crusader Tree | Removed AL_DEMONBANE. Added RESTART_STEADFASTCONVICTION (MaxLevel 5). AL_HEAL no longer requires AL_DEMONBANE. `db/re/skill_tree.yml`. |
| 2026-02-27 | Monk | Monk Tree | MO_IRONHAND prerequisite changed from AL_DEMONBANE lv10 to RESTART_STEADFASTCONVICTION lv10. `db/re/skill_tree.yml`. |
| 2026-02-27 | Merchant | Merchant Tree | Removed MC_VENDING and MC_IDENTIFY from tree. `db/re/skill_tree.yml`. |
| 2026-02-27 | Sage | Sage Tree | Added RESTART_CANYON (MaxLevel 5). SA_LANDPROTECTOR prerequisites updated to Canyon lv5 + Volcano lv5 + Deluge lv5 + ViolentGale lv5. `db/re/skill_tree.yml`. |

---

## Combat Mechanics

| Date | ID | Name | Change |
|------|----|------|--------|
| 2026-02-27 | — | Flee Cap | `min_hitrate` changed from 5 to 0. With 1–2 attackers, 100% dodge is now achievable. `conf/battle/battle.conf`. |
| 2026-02-27 | — | AGI Penalty | `agi_penalty_num` changed from 10 to 5. Each attacker past 2 reduces flee by 5% (not 10%). `conf/battle/battle.conf`. |
| 2026-02-27 | — | Elemental Chart | Replaced RE elemental table with pre-RE values in `db/re/attr_fix.yml`. `db/re/attr_fix.yml`. |
| 2026-02-27 | — | Perfect Hit / Perfect Dodge | Perfect hit now supersedes perfect dodge: if perfect hit is pre-rolled, lucky dodge check is skipped entirely. `src/map/battle.cpp` `battle_calc_weapon_attack`, `is_attack_hitting`. |
| 2026-02-27 | — | Fixed Cast Time | `default_fixed_castrate` changed from 20 to 0. All skills have zero fixed cast time. `conf/battle/skill.conf`. |
| 2026-02-27 | — | Natural HP/SP Regen While Moving | Players now regen HP, SP, and skill-based regen (HP/SP Recovery) while walking at the same rate as standing (4s tick). The ×2 interval penalty for walking is removed for BL_PC only. Mercenaries/Homunculi keep original walk-regen behavior. `src/map/status.cpp`. |
| 2026-02-27 | — | Natural Regen Intervals | `natural_healhp_interval`, `natural_healsp_interval`, and `natural_heal_skill_interval` all set to 4000ms. Sitting halves this to 2s (existing `multi += 1` mechanic). `conf/battle/player.conf`. |
| 2026-02-27 | — | Item Identification | All items are always identified when obtained. `itemdb_isidentified()` returns 1 unconditionally. `src/map/itemdb.cpp`. |
| 2026-02-27 | — | Free Skill Points on Job Change | +1 skill point granted when changing to 1st class (from Novice). +1 skill point granted when changing to 2nd class (from 1st class). `src/map/pc.cpp` `pc_jobchange`. |
| 2026-02-27 | — | 2nd Class Skill Damage/SP Doubling | When a 2nd class+ character uses SM_BASH, SM_MAGNUM, AC_DOUBLE, AC_SHOWER, MC_MAMMONITE, or MC_CARTREVOLUTION: damage ×2 and SP cost ×2. MC_MAMMONITE also has zeny cost ×2. `src/map/battle.cpp`, `src/map/skill.cpp`. |
| 2026-02-27 | — | Divine Fury (SC_RESTART_DIVINE_FURY, EFST 1693) | New status effect from Signum Crucis. Duration 30s. Grants +10% damage vs demon/undead, +5% vs all others. Applied on manual Signum Crucis cast (on success) and on auto-cast proc. `src/map/status.hpp`, `src/map/status.cpp`, `src/map/battle.cpp`. |
| 2026-02-27 | — | Weapon Mastery Rework Phase 2 | New skill **SR_BLADEMASTERY** (Blade Mastery, ID 20019) added — covers W_DAGGER + W_1HSWORD, available on Swordsman and Thief trees. SM_SWORD retired and removed from Swordsman and Rogue trees. SM_TWOHAND renamed "Sword Mastery", expanded to cover W_1HSWORD + W_2HSWORD, SM_SWORD requirement dropped. KN_SPEARMASTERY moved to Swordsman tree (now 1st class, MaxLevel 10); removed from Knight and Crusader trees. AM_AXEMASTERY moved to Merchant tree (now 1st class); removed from Alchemist tree. MO_IRONHAND and AS_KATAR reduced to MaxLevel 5 (+10/lv, +50 max). BA_MUSICALLESSON and DC_DANCINGLESSON gain W_DAGGER as second weapon. AS_KATAR gains W_1HAXE as second weapon. PR_MACEMASTERY covers W_MACE + W_BOOK (W_2HMACE dropped — no W_2HMACE items in DB). SA_ADVANCEDBOOK gains W_STAFF as second weapon. `src/map/status.cpp`, `src/map/skill.hpp`, `db/re/skill_db.yml`, `db/re/skill_tree.yml`. |
| 2026-02-27 | — | Weapon Mastery Rework | Mastery ATK moved from `battle_addmastery()` (post-calc flat) to `status_calc_pc_()` as `eatk` (pre-calc equip ATK). Mastery now shows in the ATK stat window and is scaled by all % damage multipliers. All weapon-type masteries normalized to +5/lv (max +50 at lv10). GN_TRAINING_SWORD and NC_TRAININGAXE remain +10/lv (max +50 at lv5). KN_SPEARMASTERY mounted bonus dropped (flat +5/lv). AM_AXEMASTERY no longer applies to 1H Sword. `src/map/status.cpp`, `src/map/battle.cpp`. |
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
| 2026-02-27 | SC_RESTART_DIVINE_FURY (1693) | Divine Fury | See Combat Mechanics above. |
| 2026-02-27 | SC_RESTART_CANYON (1694) | Canyon | New SC for Canyon land skill. Earth damage boost + DEF/MDEF buff for occupants. `src/map/status.hpp`, `src/map/status.cpp`. |
| 2026-02-27 | SC_RESTART_SENSED (1695) | Sensed | Applied by Sense (WZ_ESTIMATION). Reduces target MDEF by 10% for 60s. `src/map/status.hpp`, `src/map/status.cpp`. |
| 2026-02-27 | SC_RESTART_LANDMASTERY (1696) | Land Mastery | Applied to Sage when casting Volcano/Deluge/Violent Gale/Canyon. While active, the same land skill can be recast without consuming a gemstone. Duration 30 minutes. val1 = skill_id of last cast land. `src/map/status.hpp`, `src/map/status.cpp`, `src/map/skill.cpp`. |
| 2026-02-27 | — | Status Effects | Removed all stat-based SC resistance (VIT/INT/LUK/AGI/MDEF contributions to rate and duration reduction, including SC_CURSE LUK=0 immunity). Boss/MVP targets no longer fully immune — duration clamped to 1ms–1s. Normal targets clamped to 5s–10s. Buff-based resistance (SC_SCRESIST, SC_SIEGFRIED) and item resistance unchanged. `src/map/status.cpp`. |
| 2026-02-27 | — | Re-application Extension | Any non-immobilizing status effect can be re-applied to extend its current duration (remaining time + new tick), capped at server maximum (10s normal targets, 1s boss targets). Immobilizing SCs (SC_STUN, SC_SLEEP, SC_FREEZE, SC_STONE, SC_STONEWAIT, SC_STOP, SC_ANKLE, SC_DEEPSLUMBER, SC_BITE, SC_TINDER_BREAKER, SC_SPIDERWEB, SC_CRYSTALIZE, SC_STASIS, SC__MANHOLE, SC_THORNSTRAP) are excluded — re-application is ignored on these. Timer extended in-place with no stat recalc. `src/map/status.cpp` `status_change_start`. |
| 2026-02-27 | SC_BLIND | Blind | Cancels all mount/riding movement speed bonuses. Applies -5% movement speed penalty. If a movement speed buff SC is active while blind, the -5% speed penalty is negated (but hit/flee penalties of blind remain). `src/map/status.cpp` `status_calc_speed`. |
| 2026-02-27 | SC_STUN | Stun | Changed from full flee negation (auto-hit via OPT1) to flee -100 flat. Stunned targets can be missed. `src/map/battle.cpp` `is_attack_hitting`, `src/map/status.cpp` `status_calc_flee`. |
| 2026-02-27 | SC_SLEEP | Sleep | Physical and magic attacks on sleeping targets: 100% hit chance (OPT1_SLEEP auto-hit, unchanged); hard physical DEF and VIT DEF treated as 0; hard MDEF and soft MDEF treated as 0; damage ×200%; damage displays as blue critical (`isspdamage`). Sleeping target's ASPD reduced by 25% while asleep. `src/map/battle.cpp`, `src/map/status.cpp` `status_calc_aspd`. |

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

| Date | ID | Name | Change |
|------|----|------|--------|
| 2026-02-27 | 657 | Berserk Potion | Usable by all classes except Novice. Changed from explicit job whitelist to `Jobs: All: true, Novice: false`. `db/re/item_db_usable.yml`. |

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
