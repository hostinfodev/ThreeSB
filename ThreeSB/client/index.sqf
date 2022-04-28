// https://zen-mod.github.io/ZEN/#/frameworks/dynamic_dialog

private _m = "3SB";

// ADD NEW UNITS BELOW
ThreeSB_ssbs = [
	["[Vanilla] Beggar", "C_man_p_beggar_F"]
];

// ADD NEW VEHICLES BELOW
ThreeSB_vics = [
	["[None] On Foot", "0"],
	["[Vanilla] White Hatchback", "C_Hatchback_01_F"]
];

// ADD EXPLOSIVE VEHICLE CLASSES - EXPLOSION TYPE
ThreeSB_exp = [
	["[Vanilla] GBU-12", "Bo_GBU12_LGB"],
	["[Vanilla] Detonation Charge", "DemoCharge_Remote_Ammo_Scripted"]
];
///////////////////////////////////////////////////////////////

if ("cup_vehicles_core" in activatedAddons) then {
	ThreeSB_vics = ThreeSB_vics + [
		["[CUP] Sedan", "CUP_C_Octavia_CIV"],
		["[CUP] SUV", "CUP_C_SUV_CIV"],
		["[CUP] Truck", "CUP_C_Truck_02_covered_CIV"],
		["[CUP] VW Golf (Black)", "CUP_C_Golf4_black_Civ"],
		["[CUP] Datsun Truck", "CUP_C_Datsun"],
		["[CUP] Pickup Truck", "CUP_C_Pickup_unarmed_CIV"]
	];
};

if ("cup_characters2_data" in activatedAddons) then {
	ThreeSB_ssbs = ThreeSB_ssbs + [
		["[CUP] ME - Male 0", "CUP_C_TK_Man_04_Waist"],
		["[CUP] ME - Male 1", "CUP_C_TK_Man_04_Jack"],
		["[CUP] ME - Male 2", "CUP_C_TK_Man_05_Jack"],
		["[CUP] ME - Male 3", "CUP_C_TK_Man_02_Waist"],
		["[CUP] ME - Male 4", "CUP_C_TK_Man_01_Coat"],
		["[CUP] ME - Male 5", "CUP_C_TK_Man_03_Jack"],
		["[CUP] ME - Male 6", "CUP_C_R_Citizen_01"],
		["[CUP] ME - Male 7", "CUP_C_R_Bully_02"]
	];
};

if ("zephik_female_base" in activatedAddons) then {
	ThreeSB_ssbs = ThreeSB_ssbs + [
		["[ZEPHIK] ME - Female 0", "ZEPHIK_Female_Civ_12"]
	];	
};

// Zeus Enhanced: Make Unit An SSB // Drag Module onto AI unit, AI group or AI-manned vehicle.
if !([_m, "Make Unit SSB", {

	_pos        = _this select 0;
	_zen_target = _this select 1;

	if (isNull _zen_target) exitWith {
		hint "Place On A Unit Or Group";
	};
	
	private _d_radius   = 25;
	private _debug      = true; 
	private _t_radius   = 1000;
	private _deadman    = true;
	private _audible    = true;
	private _gear       = true;
	private _explo_class= "Bo_GBU12_LGB";
	private _interval   = 5;
	private _is_fem     = false;
	
	[
		[
			group _zen_target,
			_d_radius,
			_debug,
			_t_radius,
			_deadman,
			_audible,
			_gear,
			_explo_class,
			_interval,
			_is_fem
		], "ThreeSB\server\fnc_make_unit_3sb.sqf"
	] remoteExec ["execVM", 2];
}] call zen_custom_modules_fnc_register) then {
	systemChat "[3SB] Failed to add module feature: Make Unit SSB";
};

// Zeus Enhanced: Make A New SSB // Drag Module to spawn-point
if !([_m, "Create New SSB", {

	_zen_pos    = _this select 0;
	_zen_target = _this select 1;

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
/*

*/
	_threeSB_ssbs_unit_descriptions = [];
	_threeSB_ssbs_unit_classes      = [];
	{
		_threeSB_ssbs_unit_descriptions pushBack (_x select 0);
		_threeSB_ssbs_unit_classes      pushBack (_x select 1);
	} forEach ThreeSB_ssbs;

	_threeSB_vehicles_descriptions = [];
	_threeSB_vehicles_classes      = [];
	{
		_threeSB_vehicles_descriptions pushBack (_x select 0);
		_threeSB_vehicles_classes      pushBack (_x select 1);
	} forEach ThreeSB_vics;

	_threeSB_explosion_descriptions= [];
	_threeSB_explosion_classes     = [];
	{
		_threeSB_explosion_descriptions pushBack (_x select 0);
		_threeSB_explosion_classes      pushBack (_x select 1);
	} forEach ThreeSB_exp;	

	if !([
		"3SB: Create New SSB",
		[
			[ // 0
				"COMBO",
				["Unit", "Unit class to use as the SSB."],
				[
					_threeSB_ssbs_unit_classes,
					_threeSB_ssbs_unit_descriptions,
					0
				],
				false
			],
			[ // 1
				"COMBO",
				["Vehicle", "Vehicle for the SSB to drive. (VBIED)"],
				[
					_threeSB_vehicles_classes,
					_threeSB_vehicles_descriptions,
					0
				],
				false					
			],		
			[ // 2
				"COMBO",
				["Explosion Type", "Explosive vehicle to use as detonation."],
				[
					_threeSB_explosion_classes,
					_threeSB_explosion_descriptions,
					0
				],
				false
			],				
			[ // 3
				"SIDES",
				["Faction", "Side that the SSB will belong to."],
				civilian,
				false
			],
			[ // 4
				"SLIDER:RADIUS",
				["Detonation Radius", "Range (meters) from the target at which the SSB will detonate."],
				[
					1,
					100,
					25,
					0,
					_zen_pos,
					[1, 1, 1, 1]
				],
				false
			],
			[ // 5
				"SLIDER:RADIUS",
				["Targeting Radius", "Range (meters) that SSB will search for nearest target in."],
				[
					100,
					2000,
					1000,
					0,
					_zen_pos,
					[1, 1, 1, 1]
				],
				false
			],
			[ // 6
				"SLIDER",
				["Reassessment Interval", "Time (seconds) between intervals in which the AI reassess it's environment and updates target aquisition efforts."],
				[
					1,
					20,
					5,
					0,
					_zen_pos,
					[1, 1, 1, 1]
				],
				false				
			],
			[ // 7
				"CHECKBOX",
				["Deadman's Switch", "SSB will explode when dead if SSB did not detonate due to proximity."],
				[true],
				false
			],	
			[ // 8
				"CHECKBOX",
				["Is Female", "Uses female audio and animations. Does nothing to the unit's appearance."],
				[false],
				false
			],	
			[ // 9
				"CHECKBOX",
				["Add Gear", "Adds vanilla Balaclava and vest to SSB unit/s."],
				[true],
				false
			],			
			[ // 10
				"CHECKBOX",
				["Audio", "Enables Audio. Pre-detonation sounds and some other ambient sounds."],
				[true],
				false
			],
			[ // 11
				"CHECKBOX",
				["Debug", "Enable debug mode."],
				[false],
				false
			]
		],
		{
			// On Accept //

			// User-Provided Settings
			private _user_set = _this select 0;

			// Args
			private _args      = _this select 1;
			private _targetObj = _args select 1; // Not used in this scope - creating new object here.

			// Default Values //
			private _classname  = _user_set select 0;
			private _position   = _args select 0;
			private _d_radius   = round(_user_set select 4);
			private _vehicle    = _user_set select 1;
			if (_vehicle == "0") then {_vehicle = false};
			private _debug      = _user_set select 11; 
			private _t_radius   = _user_set select 5;
			private _deadman    = _user_set select 7;
			private _side       = _user_set select 3;	
			private _audible    = _user_set select 10;
			private _gear       = _user_set select 9;
			private _explo_class= _user_set select 2;
			private _interval   = _user_set select 6; // 5 seconds
			private _is_fem     = _user_set select 8;

			systemChat format["Test: %1", _this];

			[
				[
					_classname,
					_position,
					_d_radius,
					_vehicle,
					_debug,
					_t_radius,
					_deadman,
					_side,
					_audible,
					_gear,
					_explo_class,
					_interval,
					_is_fem
				], "ThreeSB\server\fnc_create_one_3sb.sqf"
			] remoteExec ["execVM", 2];
			
		},
		{hint "3SB: Action Canceled"},
		[_this select 0, _this select 1]
	] call zen_dialog_fnc_create) then {hint "3SB: Failed To Create New SSB"};	
}] call zen_custom_modules_fnc_register) then {
	systemChat "[3SB] Failed to add module feature: Make New SSB";
};