// Vehicle Service Point (Repair) by Axe Cop

private ["_vehicle","_args","_costs","_type","_name","_hitpoints"];

_vehicle = _this select 0;
if (!local _vehicle) exitWith { diag_log format["Error: called service_point_repair.sqf with non-local vehicle: %1", _vehicle] };

_args = _this select 3;
_costs = _args select 0;

if !([_costs] call AC_fnc_checkAndRemoveRequirements) exitWith {};

_type = typeOf _vehicle;
_name = getText(configFile >> "cfgVehicles" >> _type >> "displayName");

_vehicle engineOn false;
[_vehicle,"repair",0,false] call dayz_zombieSpeak;

_hitpoints = _vehicle call vehicle_getHitpoints;
{
	private ["_damage","_selection"];
	_damage = [_vehicle,_x] call object_getHit;
	if (_damage > 0) then {
		_selection = getText(configFile >> "cfgVehicles" >> _type >> "HitPoints" >> _x >> "name");
		[_vehicle,_selection,0] call object_setFixServer;
	};
} forEach _hitpoints;

_vehicle setDamage 0;
_vehicle setVelocity [0,0,1];

titleText [format["%1 Repaired", _name], "PLAIN DOWN"];
