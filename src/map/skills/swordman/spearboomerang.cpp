// Copyright (c) rAthena Dev Teams - Licensed under GNU GPL
// For more information, see LICENCE in the main folder

#include "spearboomerang.hpp"

SkillSpearBoomerang::SkillSpearBoomerang() : WeaponSkillImpl(KN_SPEARBOOMERANG) {
}

void SkillSpearBoomerang::calculateSkillRatio(const Damage* wd, const block_list* src, const block_list* target, uint16 skill_lv, int32& base_skillratio, int32 mflag) const {
	// [RESTART] lv1=120% ... lv5=200% (step 20%/level)
	base_skillratio += 20 * skill_lv;
}
