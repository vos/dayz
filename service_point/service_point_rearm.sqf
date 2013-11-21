// Vehicle Service Point (Rearm) by Axe Cop

private ["_vehicle","_args","_costs","_magazineCount","_weapon","_type","_name","_weaponType","_weaponName","_turret","_magazines","_ammo"];

_vehicle = _this select 0;
if (!local _vehicle) exitWith { diag_log format["Error: called service_point_rearm.sqf with non-local vehicle: %1", _vehicle] };

_args = _this select 3;
_costs = _args select 0;
_magazineCount = _args select 1;
_weapon = _args select 2;

if !([_costs] call AC_fnc_checkAndRemoveRequirements) exitWith {};

_type = typeOf _vehicle;
_name = getText(configFile >> "cfgVehicles" >> _type >> "displayName");

_weaponType = _weapon select 0;
_weaponName = _weapon select 1;
_turret = _weapon select 2;

_magazines = getArray (configFile >> "CfgWeapons" >> _weaponType >> "magazines");
_ammo = _magazines select 0; // rearm with the first magazine

// remove all magazines
_magazines = _vehicle magazinesTurret _turret;
{
	_vehicle removeMagazineTurret [_x, _turret];
} forEach _magazines;

// add magazines
for "_i" from 1 to _magazineCount do {
	_vehicle addMagazineTurret [_ammo, _turret];
};

titleText [format["%1 of %2 Rearmed", _weaponName, _name], "PLAIN DOWN"];
