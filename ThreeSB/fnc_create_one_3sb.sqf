// Based on task_patrol.sqf by nkenny

/*
[ 
 "CUP_C_TK_Man_04", 
 [getPos player, [0, 100, 0]] call BIS_fnc_vectorAdd, 
 20,
 "CUP_C_Volha_Gray_TKCIV",
 true,
 1000,
 true,
 civilian,
 true,
 true,
 "Bo_GBU12_LGB",
 5,
 false
] execVM "ThreeSB\fnc_create_one_3sb.sqf";
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

[
	_classname,
	_position,
	_detonation_radius,
	_vehicle,
	_debug,
	_targeting_radius,
	_deadman_switch,
	_side,
	_audio,
	_add_gear,
	_explosion_type,
	_interval,
	_isfemale
] spawn {

	params [
		"_classname",
		"_position",
		"_detonation_radius",
		"_vehicle",
		"_debug",
		"_targeting_radius",
		"_deadman_switch",
		"_side",
		"_audio",
		"_add_gear",
		"_explosion_type",
		"_interval",
		"_isfemale"
	];

	_male_audio   = [
		["malescream1", 3],
		["malescream2", 2],
		["malescream3", 3]
	];

	_female_audio = [
		["femalescream1", 2],
		["femalescream2", 1]	
	];

	_alreadydetonated = false;
	_group = createGroup _side;

	_unit  = _group createUnit [_classname, _position, [], 0, "NONE"]; 
	if (_debug) then {systemChat format ["[3SB] Unit Spawned: %1", _unit]};

	if (typeName _vehicle == "STRING") then {
		_vehicle = _vehicle createVehicle _position;
		_unit moveInDriver _vehicle;
		if (_debug) then {systemChat format ["[3SB] Vehicle Spawned: %1", _vehicle]};
	};

	if (_add_gear) then {
		// Todo: check for RHS/CUP compatibility: https://community.bistudio.com/wiki/activatedAddons
		_unit addGoggles "G_Balaclava_blk";
		_unit addVest    "V_TacVest_oli";
	};

	// functions ---
	_fn_findTarget = {
		params["_our_unit"];
		// https://forums.bohemia.net/forums/topic/222709-get-closest-player-to-marker/
		// Modified version of "get closest player to marker" - Answer by Dedmen.
		private _playerList = allPlayers apply {[(getPos _our_unit) distanceSqr _x, _x]};
		_playerList sort true;
		private _closestPlayer = (_playerList select 0) param [1, objNull];
		_closestPlayer
	};
	// functions end ---

	// sort grp
	if (!local _group) exitWith {};
	if (_group isEqualType objNull) then {_group = group _group;};

	// orders
	_group setbehaviour "COMBAT";
	_group setSpeedMode "FULL";
	_group allowFleeing 0;

	// Hunting loop
	while {{alive _x} count units _group > 0} do {

		// WAIT FOR IT!
		sleep (_interval - 1);

		// performance
		waitUntil {sleep 1;simulationenabled leader _group};


		// W.I.P.
		/*
		// settings - immersion
		private _fleeing = fleeing (leader _group);
		//_combat = behaviour leader _group isEqualTo "COMBAT";
		_onFoot = (isNull objectParent (leader _group));

		// Set behaviour based on stimuli.
		if (_fleeing && _onFoot) then {
			// Go prone in fear if on foot and in combat mode.
			_unit switchMove "amovppnemstpsraswrfldnon";
			// ["c7a_bravoTOerc_idle8", "c7a_bravo_dovadeni1", "c7a_bravoTleskani_idle5", "c7a_bravo_dovadeni3"] call BIS_fnc_selectRandom;
			if (_debug) then {systemChat format ["[3SB] Combat Response: Going Prone..."]};
		} else {
			if (_fleeing && {!_onFoot}) then {
				// Do combat reaction in vehicle
				if (_debug) then {systemChat format ["[3SB] Combat Response (vehicle): Reacting..."]};
			};
		};
		*/

		// find
		_target = [leader _group] call _fn_findTarget;

		// orders
		if (!isNull _target) then {
			
			_group move (_target getPos [random 100,random 360]);
			_group setFormDir (leader _group getDir _target);
			_group setSpeedMode "FULL";
			
			if (_debug) then {systemChat format ["[3SB] %1, Tracking target %2 @ %3...", getPos leader _group, name _target, getPos _target]};
			
			_lastpos = getpos leader _group;
			if (leader _group distance2D _target <= _detonation_radius) then {
				if !(getPos (leader _group) isEqualTo [0, 0, 0]) then {
					
					_unit setRandomLip true; // Move Mouth
					_unit setFaceAnimation 0.9; // Open eyes wide

					private _vocalType = if (_isfemale) then { _female_audio } else { _male_audio };
					private _audio     = selectRandom _vocalType;
					_unit say [_audio select 0, 100];
					systemChat format["Playing: %1", _audio];

					sleep (_audio select 1);
					
					null = _explosion_type createVehicle (getPos leader _group);
					_unit setDamage 1;
					_alreadydetonated = true;               
					if (_debug) then {systemChat format ["[3SB] Detonation: Proximity"]};
				};
			}
		};
	};

	if !(_alreadydetonated) then {
		private _ssb = leader _group;
		if !(getPos _ssb isEqualTo [0, 0, 0]) then {
			null = _explosion_type createVehicle (getPos leader _group);       
			if (_debug) then {systemChat format ["[3SB] Detonation: Deadman's Switch"]};
		};
	};

    if (_debug) then {systemChat format ["[3SB] exiting thread..."]};
};


