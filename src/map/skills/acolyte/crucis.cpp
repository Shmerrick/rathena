// Copyright (c) rAthena Dev Teams - Licensed under GNU GPL
// For more information, see LICENCE in the main folder

#include "crucis.hpp"

#include <common/utils.hpp>

#include "../../battle.hpp"
#include "../../clif.hpp"
#include "../../map.hpp"
#include "../../pc.hpp"
#include "../../status.hpp"

SkillCrucis::SkillCrucis() : SkillImpl(AL_CRUCIS)
{
}

void SkillCrucis::castendNoDamageId(block_list *src, block_list *bl, uint16 skill_lv, t_tick tick, int32& flag) const
{
	sc_type type = skill_get_sc(getSkillId());

	if (flag & 1)
	{
		int32 caster_lv = status_get_lv(src);
		int32 target_lv = status_get_lv(bl);

		// [RESTART] Success formula: same pattern as Decrease AGI/Steal
		int32 rate = cap_value((int32)((0.5 + skill_lv * 0.5 - (caster_lv - target_lv)) * 100), 0, 100);

		// [RESTART] All enemies can receive Signum Crucis; demon/undead get full DEF reduction,
		// others get half. val2 encodes the DEF reduction % so status.cpp uses it directly.
		status_data *tst = status_get_status_data(*bl);
		bool full_effect = (battle_check_undead(tst->race, tst->def_ele) || tst->race == RC_DEMON);
		int32 def_reduction = full_effect ? (10 + 4 * skill_lv) : (5 + 2 * skill_lv);

		if (sc_start2(src, bl, type, rate, skill_lv, def_reduction, skill_get_time(getSkillId(), skill_lv)))
		{
			// [RESTART] Grant Divine Fury buff to caster on successful application
			sc_start(src, src, SC_RESTART_DIVINE_FURY, 100, skill_lv, 30000);
		}
	}
	else
	{
		map_foreachinallrange(skill_area_sub, src, skill_get_splash(getSkillId(), skill_lv), BL_CHAR, src, getSkillId(), skill_lv, tick, flag | BCT_ENEMY | 1, skill_castend_nodamage_id);
		clif_skill_nodamage(src, *bl, getSkillId(), skill_lv);
	}
}
