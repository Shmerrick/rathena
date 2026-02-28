// Copyright (c) rAthena Dev Teams - Licensed under GNU GPL
// For more information, see LICENCE in the main folder

#include "mammonite.hpp"

SkillMammonite::SkillMammonite() : WeaponSkillImpl(MC_MAMMONITE) {
}

void SkillMammonite::calculateSkillRatio(const Damage* wd, const block_list* src, const block_list* target, uint16 skill_lv, int32& base_skillratio, int32 mflag) const {
	// [RESTART] lv1=550% ... lv10=1000% (step 50%/level). Formula: 450 + 50*lv on top of base 100.
	base_skillratio += 450 + 50 * skill_lv;
}
