// ThreeSB - By Grom - https://github.com/hostinfodev
// Based on fn_taskHunt.sqf by nk3nny - https://github.com/nk3nny 

/*
	File:	
		3sb\server\fnc_create_one_3sb.sqf
	
	Description:
		This function spawns a new 3SB pawn.
*/

/*
# Paramters:
	> 0: classname - string
	> 1: position - array
	> 2: detonation radius - number
	> 3: vehicle - bool or string
	> 4: debug - bool
	> 5: targeting radius - number
	> 6: deadman switch - bool
	> 7: side - side
	> 8: audio - bool
	> 9: add gear - bool
	> 10: explosion type - string
	> 11: interval - number
	> 12: isfemale - bool
*/

params[
	"_classname",
	"_position",
	"_detonation_radius",
	["_vehicle", false],
	["_debug", true],
	["_targeting_radius", 1000],
	["_deadman_switch", true],
	["_side", civilian],
	["_audio", true],
	["_add_gear", true],
	["_explosion_type", "Bo_GBU12_LGB"],
	["_interval", 5],
	["_isfemale", false]
];

// Global Sidechat function
fn_sc = {
	params["_message"];
	[_message] remoteExec ["systemChat"];
};

// Create a new group
_group = createGroup _side;

_positionSafe = [
	_position select 0,
	_position select 1,
	getTerrainHeightASL _position
];

// Spawn Unit
_unit  = _group createUnit [_classname, _positionSafe, [], 0, "NONE"]; 
_unit allowDamage false;
_unit setVectorUp surfaceNormal (getposATL _unit);

if (_debug) then {[format ["[3SB] Unit Spawned: %1", _unit]] call fn_sc};

// Spawn Vehicle
if (typeName _vehicle == "STRING") then {
	_vehicleObj = _vehicle createVehicle _position;
	_unit moveInDriver _vehicleObj;
	if (_debug) then {[format ["[3SB] Vehicle Spawned & Manned: %1", _vehicle]] call fn_sc};
};

// Add to all curators
{
	_x addCuratorEditableObjects [units _group,false]
} count allCurators;

_unit allowDamage true;

// Send to the manager
[[
	_group,
	_detonation_radius,
	_debug, 
	_targeting_radius, 
	_deadman_switch, 
	_audio, 
	_add_gear, 
	_explosion_type, 
	_interval, 
	_isfemale
], "3sb\server\fnc_3sb_manager.sqf"] remoteExec ["execVM", 2];





