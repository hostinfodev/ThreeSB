// SERVER ONLY !!!

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

[
	_group,
	_detonation_radius,
	_debug, 
	_targeting_radius, 
	_deadman_switch, 
	_use_audio, 
	_add_gear, 
	_explosion_type, 
	_interval, 
	_is_female
] spawn {

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

	// Global Sidechat function
	fn_sc = {
		params["_message"];
		[_message] remoteExec ["systemChat"];
	};	

	if (_debug) then {[format ["[3SB] Manager Params: %1", _this]] call fn_sc};

	_male_audio   = [
		["malescream1", 3],
		["malescream2", 2]
	];

	_female_audio = [
		["femalescream1", 2],
		["femalescream2", 1]	
	];

	// Has-deto'd flag
	_alreadydetonated = false;

	// Find a target
	fn_getTarget = {
		params["_our_unit"];
		// https://forums.bohemia.net/forums/topic/222709-get-closest-player-to-marker/
		// Modified version of "get closest player to marker" - Answer by Dedmen.
		private _playerList = allPlayers apply {[(getPos _our_unit) distanceSqr _x, _x]};
		_playerList sort true;
		private _closestPlayer = (_playerList select 0) param [1, objNull];
		_closestPlayer
	};	

	// Add gear if needed
	if (_add_gear) then {
		// Todo: check for RHS/CUP compatibility: https://community.bistudio.com/wiki/activatedAddons
		{
			_x addGoggles "G_Balaclava_blk";
			_x addVest    "V_TacVest_oli";
		} forEach units _group;
		if (_debug) then {["[3SB] Added Gear To Unit"] call fn_sc};
	};

	// Redundant - but just in case
	if (!local _group) exitWith {};
	if (_group isEqualType objNull) then {_group = group _group;};

	// Behaviour
	_group setbehaviour "COMBAT";
	_group setSpeedMode "FULL";
	_group allowFleeing 0;

	{
		_x setDamage 0;
		_x allowDamage true;
	} forEach units _group;

	// Targeting Loop
	while {{alive _x} count units _group > 0} do {

		sleep (_interval - 1);
		waitUntil {sleep 1;simulationenabled leader _group};

		_target = [leader _group] call fn_getTarget;
		if (!isNull _target) then {
			
			_group move (_target getPos [random 100,random 360]);
			_group setSpeedMode "FULL";
			_group setFormDir (leader _group getDir _target);
			
			if (_debug) then {[format ["[3SB] Target: %1, Distance: %2, Location: %3", name _target, (leader _group) distance2D _target, mapGridPosition  _target]] call fn_sc};
			
			_lastpos       = getpos leader _group;
			_group_vehicle = vehicle (leader _group); 

			if (leader _group distance2D _target <= _detonation_radius) then
			{
				if !(getPos (leader _group) isEqualTo [0, 0, 0]) then
				{

					// If our unit is not in car and our target is and we are close enough then try to get in, detonate either way.
					// 15meters is the max distance to get in.
					if ( !(isNull objectParent _target) && (isNull objectParent (leader _group)) && ((leader _group) distance2D _target <= 15) ) then {
						
						if (_debug) then {[format ["[3SB] %1 attempting to board %2's vehicle---", name _group, name (vehicle _target)]] call fn_sc};
						
						_group setFormDir (leader _group getDir _target);
						_group setSpeedMode "FULL";
						{
							_x assignAsCargo (vehicle _target);
							[_x] orderGetIn true;
							[_x] allowGetIn true;
						} forEach units _group;

						if !(isNull objectParent (leader _group)) then {
							if (_debug) then {[format ["[3SB] %1 jumped into in %2's vehicle!!!", name _group, name (vehicle _target)]] call fn_sc};
						};

						sleep (selectRandom[5, 8, 10]);
					};

					[leader _group, true] remoteExec ["setRandomLip"];// Move Mouth
					[leader _group, 0.9] remoteExec ["setFaceAnimation"];// Open eyes wide

					// https://forums.bohemia.net/forums/topic/162014-animation-list-most-of-them/
					private _preemptive_animation = selectRandom [
						"AcinPercMrunSnonWnonDf_death", 
						"AmovPercMstpSsurWnonDnon", 
						"Acts_TreatingWounded_loop", 
						"0", "0", "0", "0", "0", "0"
					];
					
					// "0" is no animation (faster and FAR MORE DANGEROUS!) - ensure unit is not in car
					if (_preemptive_animation != "0" && (isNull objectParent (leader _group))) then {
						[leader _group, _preemptive_animation] remoteExec ["switchMove"];
					};

					if (_use_audio) then {
						private _vocalType = if (_is_female) then { _female_audio } else { _male_audio };
						private _audio     = selectRandom _vocalType;
						[leader _group, [_audio select 0, 100]] remoteExec ["say"];
						if (_debug) then {[format["[3SB] Saying: %1", _audio]] call fn_sc};
						sleep (_audio select 1);
					};
				
					private _e = _explosion_type createVehicle (getPos leader _group);
					_e setDamage 1; // Experimental*
					{_x setDamage 1} forEach units _group;
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
			null = _explosion_type createVehicle (getPos _ssb);       
			if (_debug) then {["[3SB] Detonation: Deadman's Switch"] call fn_sc};
		};
	};

	// Cleanup
	if !(isNil "_group_vehicle") then {deleteVehicle _group_vehicle};
	{deleteVehicle _x } forEach units _group;
	deleteGroup _group;

    if (_debug) then {["[3SB] Exiting manager, goodbye!"] call fn_sc};	
};