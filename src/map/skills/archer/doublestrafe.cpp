// Copyright (c) rAthena Dev Teams - Licensed under GNU GPL
// For more information, see LICENCE in the main folder

#include "doublestrafe.hpp"

SkillDoubleStrafe::SkillDoubleStrafe() : WeaponSkillImpl(AC_DOUBLE) {
}

void SkillDoubleStrafe::calculateSkillRatio(const Damage* wd, const block_list* src, const block_list* target, uint16 skill_lv, int32& base_skillratio, int32 mflag) const {
	// [RESTART] lv1=55% ... lv10=100% (step 5%/level). Formula: -45 + 5*lv subtracted from base 100.
	base_skillratio += -45 + 5 * skill_lv;
}
