// ThreeSB - By Grom - https://github.com/hostinfodev
// Based on fn_taskHunt.sqf by nk3nny - https://github.com/nk3nny 

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
		["malescream2", 2]
	];

	_female_audio = [
		["femalescream1", 2],
		["femalescream2", 1]	
	];

	_alreadydetonated = false;
	_group = createGroup _side;

	// Spawn Unit
	_unit  = _group createUnit [_classname, _position, [], 0, "NONE"]; 
	if (_debug) then {[format ["[3SB] Unit Spawned: %1", _unit]] call fn_sc};

	// Spawn Vehicle
	if (typeName _vehicle == "STRING") then {
		_vehicleObj = _vehicle createVehicle _position;
		_unit moveInDriver _vehicleObj;
		if (_debug) then {[format ["[3SB] Vehicle Spawned: %1", _vehicle]] call fn_sc};
	};

	// Add gear
	if (_add_gear) then {
		// Todo: check for RHS/CUP compatibility: https://community.bistudio.com/wiki/activatedAddons
		_unit addGoggles "G_Balaclava_blk";
		_unit addVest    "V_TacVest_oli";
		if (_debug) then {["[3SB] Added Gear To Unit"] call fn_sc};
	};

	// Global Sidechat function
	fn_sc = {
		params["_message"];
		[_message] remoteExec ["systemChat", -2];
	};

	// Find a target
	getTarget = {
		params["_our_unit"];
		// https://forums.bohemia.net/forums/topic/222709-get-closest-player-to-marker/
		// Modified version of "get closest player to marker" - Answer by Dedmen.
		private _playerList = allPlayers apply {[(getPos _our_unit) distanceSqr _x, _x]};
		_playerList sort true;
		private _closestPlayer = (_playerList select 0) param [1, objNull];
		_closestPlayer
	};

	// Redundant
	if (!local _group) exitWith {};
	if (_group isEqualType objNull) then {_group = group _group;};

	// Behaviour
	_group setbehaviour "COMBAT";
	_group setSpeedMode "FULL";
	_group allowFleeing 0;

	// Hunting loop
	while {{alive _x} count units _group > 0} do {

		sleep (_interval - 1);
		waitUntil {sleep 1;simulationenabled leader _group};

		_target = [leader _group] call getTarget;
		if (!isNull _target) then {
			
			_group move (_target getPos [random 100,random 360]);
			_group setSpeedMode "FULL";
			_group setFormDir (leader _group getDir _target);
			
			if (_debug) then {[format ["[3SB] Target: %1, Distance: %2, Location: %3", name _target, _unit distance2D _target, mapGridPosition  _target]] call fn_sc};
			
			_lastpos = getpos leader _group;
			if (leader _group distance2D _target <= _detonation_radius) then
			{
				if !(getPos (leader _group) isEqualTo [0, 0, 0]) then
				{
					[_unit, true] remoteExec ["setRandomLip", -2];// Move Mouth
					[_unit, 0.9] remoteExec ["setFaceAnimation", -2];// Open eyes wide

					// https://forums.bohemia.net/forums/topic/162014-animation-list-most-of-them/
					private _preemptive_animation = selectRandom [
						"AcinPercMrunSnonWnonDf_death", 
						"AmovPercMstpSsurWnonDnon", 
						"Acts_TreatingWounded_loop", 
						"0", "0", "0", "0", "0", "0"];
					
					// "0" is no animation (faster and more dangerous)
					if (_preemptive_animation != "0" && (_vehicle == false)) then {
						[_unit, _preemptive_animation] remoteExec ["switchMove", -2];
					};

					private _vocalType = if (_isfemale) then { _female_audio } else { _male_audio };
					private _audio     = selectRandom _vocalType;
					[_unit, [_audio select 0, 100]] remoteExec ["say"];
					if (_debug) then {[format["[3SB] Saying: %1", _audio]] call fn_sc};
					
					sleep (_audio select 1);
				
					null = _explosion_type createVehicle (getPos leader _group);
					_unit setDamage 1;
					_alreadydetonated = true;               
					if (_debug) then {["[3SB] Detonation: Proximity"] call fn_sc};
				};
			}
		};
	};

	// Deadman's switch
	if !(_alreadydetonated && _deadman_switch) then {
		private _ssb = leader _group;
		if !(getPos _ssb isEqualTo [0, 0, 0]) then {
			null = _explosion_type createVehicle (getPos leader _group);       
			if (_debug) then {["[3SB] Detonation: Deadman's Switch"] call fn_sc};
		};
	};

	// Cleanup
	if !(isNil "_vehicleObj") then {deleteVehicle _vehicleObj};
	deleteVehicle _unit;
	deleteGroup  _group;

    if (_debug) then {["[3SB] exiting thread..."] call fn_sc};
};


