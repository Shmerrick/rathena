// Copyright (c) rAthena Dev Teams - Licensed under GNU GPL
// For more information, see LICENCE in the main folder

#include "decagi.hpp"

#include <common/utils.hpp>

#include "../../clif.hpp"
#include "../../status.hpp"

SkillDecreaseAgi::SkillDecreaseAgi() : SkillImpl(AL_DECAGI)
{
}

void SkillDecreaseAgi::castendNoDamageId(block_list *src, block_list *bl, uint16 skill_lv, t_tick tick, int32& flag) const
{
	sc_type type = skill_get_sc(getSkillId());

	// [RESTART] Success formula: .5 + (SkillLevel*.5 - (CasterLevel - TargetLevel))
	int32 caster_lv = status_get_lv(src);
	int32 target_lv = status_get_lv(bl);
	int32 rate = cap_value((int32)((0.5 + skill_lv * 0.5 - (caster_lv - target_lv)) * 100), 0, 100);

	clif_skill_nodamage(src, *bl, getSkillId(), skill_lv, sc_start(src, bl, type, rate, skill_lv, skill_get_time(getSkillId(), skill_lv)));
}
