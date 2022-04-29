// ThreeSB - By Grom - https://github.com/hostinfodev
// Based on fn_taskHunt.sqf by nk3nny - https://github.com/nk3nny 

/*
	File:	
		3sb\server\fnc_make_unit_3sb.sqf
	
	Description:
		This function makes an existing unit a 3SB pawn.
*/

/*
	params[
		"_group",
		"_detonation_radius",
		"_debug", 
		"_targeting_radius", 
		"_deadman_switch", 
		"_use_audio", 
		"_add_gear", 
		"_explosion_type", 
		"_interval", 
		"_is_female"
	];
*/

// Send to the manager
[_this, "3sb\server\fnc_3sb_manager.sqf"] remoteExec ["execVM", 2];


