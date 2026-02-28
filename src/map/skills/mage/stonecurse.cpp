// Copyright (c) rAthena Dev Teams - Licensed under GNU GPL
// For more information, see LICENCE in the main folder

#include "stonecurse.hpp"

#include <common/utils.hpp>

#include "map/clif.hpp"
#include "map/pc.hpp"
#include "map/status.hpp"

SkillStoneCurse::SkillStoneCurse() : SkillImpl(MG_STONECURSE) {
}

void SkillStoneCurse::castendNoDamageId(block_list *src, block_list *target, uint16 skill_lv, t_tick tick, int32 &flag) const {
	map_session_data *sd = BL_CAST(BL_PC, src);
	status_data *tstatus = status_get_status_data(*target);
	status_change *tsc = status_get_sc(&*target);
	sc_type type = skill_get_sc(getSkillId());

	if (status_has_mode(tstatus, MD_STATUSIMMUNE)) {
		if (sd)
			clif_skill_fail(*sd, getSkillId());
		return;
	}

	if (status_isimmune(target) || !tsc)
		return;

	int32 brate = 0;

	if (sd && sd->sc.getSCE(SC_PETROLOGY_OPTION))
		brate = sd->sc.getSCE(SC_PETROLOGY_OPTION)->val3;

	// [RESTART] Success formula: 50 + (SkillLevel*50) - (CasterLevel - TargetLevel)
	// Clamped 0-100. Red gemstone ALWAYS consumed regardless of outcome or level.
	int32 caster_lv = status_get_lv(src);
	int32 target_lv = status_get_lv(target);
	int32 restart_rate = cap_value(50 + (skill_lv * 50) - (caster_lv - target_lv), 0, 100) + brate;

	// Except for players, the skill animation shows even if the status change doesn't start
	// Players get a skill has failed message instead
	if (sc_start2(src, target, type, restart_rate, skill_lv, src->id, skill_get_time2(getSkillId(), skill_lv), skill_get_time(getSkillId(), skill_lv)) || sd == nullptr)
		clif_skill_nodamage(src, *target, getSkillId(), skill_lv);
	else {
		clif_skill_fail( *sd, getSkillId() );
		// [RESTART] Gemstone is always consumed — removed the old SKILL_NOCONSUME_REQ block
	}
}
