// Vehicle Service Point by Axe Cop

private ["_folder","_servicePointClasses","_maxDistance","_actionTitleFormat","_actionCostsFormat","_costsFree","_message","_messageShown","_refuel_enable","_refuel_costs","_refuel_updateInterval","_refuel_amount","_repair_enable","_repair_costs","_repair_repairTime","_rearm_enable","_rearm_costs","_rearm_magazineCount","_lastVehicle","_lastRole","_fnc_removeActions","_fnc_getCosts","_fnc_actionTitle","_fnc_isArmed","_fnc_getWeapons"];

// ---------------- CONFIG START ----------------

// general settings
_folder = "service_point\"; // folder where the service point scripts are saved, relative to the mission file
_servicePointClasses = dayz_fuelpumparray; // service point classes (can be house, vehicle and unit classes)
_maxDistance = 10; // maximum distance from a service point for the options to be shown
_actionTitleFormat = "%1 (%2)"; // text of the vehicle menu, %1 = action name (Refuel, Repair, Rearm), %2 = costs (see format below)
_actionCostsFormat = "%2 %1"; // %1 = item name, %2 = item count
_costsFree = "free"; // text for no costs
_message = "Vehicle Service Point nearby"; // message to be shown when in range of a service point (set to "" to disable)

// refuel settings
_refuel_enable = true; // enable or disable the refuel option
_refuel_costs = []; // free for all vehicles (equal to [["AllVehicles",[]]])
_refuel_updateInterval = 1; // update interval (in seconds)
_refuel_amount = 0.05; // amount of fuel to add with every update (in percent)

// repair settings
_repair_enable = true; // enable or disable the repair option
_repair_costs = [
	["Air",["ItemGoldBar",5]], // 5 Gold for helicopters and planes
	["AllVehicles",["ItemGoldBar",2]] // 2 Gold for all other vehicles
];
_repair_repairTime = 2; // time needed to repair each damaged part (in seconds)

// rearm settings
_rearm_enable = true; // enable or disable the rearm option
_rearm_costs = [
	["ArmoredSUV_PMC_DZE",["ItemGoldBar10oz",2]], // special costs for a single vehicle type
	["Air",["ItemGoldBar10oz",2]], // 2 10oz Gold for helicopters and planes
	["AllVehicles",["ItemGoldBar10oz",1]] // 1 10oz Gold for all other vehicles
];
_rearm_magazineCount = 3; // amount of magazines to be added to the vehicle weapon

// ----------------- CONFIG END -----------------

_lastVehicle = objNull;
_lastRole = [];

SP_refuel_action = -1;
SP_repair_action = -1;
SP_rearm_actions = [];

_messageShown = false;

_fnc_removeActions = {
	if (isNull _lastVehicle) exitWith {};
	_lastVehicle removeAction SP_refuel_action;
	SP_refuel_action = -1;
	_lastVehicle removeAction SP_repair_action;
	SP_repair_action = -1;
	{
		_lastVehicle removeAction _x;
	} forEach SP_rearm_actions;
	SP_rearm_actions = [];
	_lastVehicle = objNull;
	_lastRole = [];
};

_fnc_getCosts = {
	private ["_vehicle","_costs","_cost"];
	_vehicle = _this select 0;
	_costs = _this select 1;
	_cost = [];
	{
		private "_typeName";
		_typeName = _x select 0;
		if (_vehicle isKindOf _typeName) exitWith {
			_cost = _x select 1;
		};
	} forEach _costs;
	_cost
};

_fnc_actionTitle = {
	private ["_actionName","_costs","_costsText","_actionTitle"];
	_actionName = _this select 0;
	_costs = _this select 1;
	_costsText = _costsFree;
	if (count _costs == 2) then {
		private ["_itemName","_itemCount","_displayName"];
		_itemName = _costs select 0;
		_itemCount = _costs select 1;
		_displayName = getText (configFile >> "CfgMagazines" >> _itemName >> "displayName");
		_costsText = format [_actionCostsFormat, _displayName, _itemCount];
	};
	_actionTitle = format [_actionTitleFormat, _actionName, _costsText];
	_actionTitle
};

_fnc_isArmed = {
	private ["_role","_armed"];
	_role = _this;
	_armed = count _role > 1;
	_armed
};

_fnc_getWeapons = {
	private ["_vehicle","_role","_weapons"];
	_vehicle = _this select 0;
	_role = _this select 1;
	_weapons = [];
	if (count _role > 1) then {
		private ["_turret","_weaponsTurret"];
		_turret = _role select 1;
		_weaponsTurret = _vehicle weaponsTurret _turret;
		{
			private "_weaponName";
			_weaponName = getText (configFile >> "CfgWeapons" >> _x >> "displayName");
			_weapons set [count _weapons, [_x, _weaponName, _turret]];
		} forEach _weaponsTurret;
	};
	_weapons
};

while {true} do {
	private ["_vehicle","_inVehicle"];
	_vehicle = vehicle player;
	_inVehicle = _vehicle != player;
	if (local _vehicle && _inVehicle) then {
		private ["_pos","_servicePoints","_inRange"];
		_pos = getPosATL _vehicle;
		_servicePoints = (nearestObjects [_pos, _servicePointClasses, _maxDistance]) - [_vehicle];
		_inRange = count _servicePoints > 0;
		if (_inRange) then {
			private ["_servicePoint","_role","_actionCondition","_costs","_actionTitle"];
			_servicePoint = _servicePoints select 0;
			if (assignedDriver _vehicle == player) then {
				_role = ["Driver", [-1]];
			} else {
				_role = assignedVehicleRole player;
			};
			if (((str _role) != (str _lastRole)) || (_vehicle != _lastVehicle)) then {
				// vehicle or seat changed
				call _fnc_removeActions;
			};
			_lastVehicle = _vehicle;
			_lastRole = _role;
			_actionCondition = "vehicle _this == _target && local _target";
			if (SP_refuel_action < 0 && _refuel_enable) then {
				_costs = [_vehicle, _refuel_costs] call _fnc_getCosts;
				_actionTitle = ["Refuel", _costs] call _fnc_actionTitle;
				SP_refuel_action = _vehicle addAction [_actionTitle, _folder + "service_point_refuel.sqf", [_servicePoint, _costs, _refuel_updateInterval, _refuel_amount], -1, false, true, "", _actionCondition];
			};
			if (SP_repair_action < 0 && _repair_enable) then {
				_costs = [_vehicle, _repair_costs] call _fnc_getCosts;
				_actionTitle = ["Repair", _costs] call _fnc_actionTitle;
				SP_repair_action = _vehicle addAction [_actionTitle, _folder + "service_point_repair.sqf", [_servicePoint, _costs, _repair_repairTime], -1, false, true, "", _actionCondition];
			};
			if ((_role call _fnc_isArmed) && (count SP_rearm_actions == 0) && _rearm_enable) then {
				private ["_weapons"];
				_costs = [_vehicle, _rearm_costs] call _fnc_getCosts;
				_weapons = [_vehicle, _role] call _fnc_getWeapons;
				{
					private "_weaponName";
					_weaponName = _x select 1;
					_actionTitle = [format["Rearm %1", _weaponName], _costs] call _fnc_actionTitle;
					SP_rearm_action = _vehicle addAction [_actionTitle, _folder + "service_point_rearm.sqf", [_servicePoint, _costs, _rearm_magazineCount, _x], -1, false, true, "", _actionCondition];
					SP_rearm_actions set [count SP_rearm_actions, SP_rearm_action];
				} forEach _weapons;
			};
			if (!_messageShown && _message != "") then {
				_messageShown = true;
				_vehicle vehicleChat _message;
			};
		} else {
			call _fnc_removeActions;
			_messageShown = false;
		};
	} else {
		call _fnc_removeActions;
		_messageShown = false;
	};
	sleep 2;
};
