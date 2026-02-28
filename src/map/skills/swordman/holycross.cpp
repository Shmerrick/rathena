// Copyright (c) rAthena Dev Teams - Licensed under GNU GPL
// For more information, see LICENCE in the main folder

#include "holycross.hpp"

#include <config/core.hpp>

#include "map/pc.hpp"
#include "map/status.hpp"

SkillHolyCross::SkillHolyCross() : WeaponSkillImpl(CR_HOLYCROSS) {
}

void SkillHolyCross::calculateSkillRatio(const Damage* wd, const block_list* src, const block_list* target, uint16 skill_lv, int32& base_skillratio, int32 mflag) const {
	// [RESTART] lv1=220% ... lv10=400% (step 20%/level)
	base_skillratio += 100 + 20 * skill_lv;
}

void SkillHolyCross::applyAdditionalEffects(block_list* src, block_list* target, uint16 skill_lv, t_tick tick, int32 attack_type, enum damage_lv dmg_lv) const {
	// [RESTART] Blind chance: lv1=5% ... lv10=50% (step 5%/level)
	sc_start(src, target, SC_BLIND, 5 * skill_lv, skill_lv, skill_get_time2(getSkillId(), skill_lv));
}
