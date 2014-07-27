// Vehicle Service Point (Repair) by Axe Cop

private ["_vehicle","_args","_servicePoint","_costs","_repairTime","_type","_name","_hitpoints","_allRepaired","_textMissing"];

_vehicle = _this select 0;
if (!local _vehicle) exitWith { diag_log format["Error: called service_point_repair.sqf with non-local vehicle: %1", _vehicle] };

_args = _this select 3;
_servicePoint = _args select 0;
_costs = _args select 1;
_repairTime = _args select 2;

//if !([_costs] call player_checkAndRemoveItems) exitWith {};
if !([[[_costs select 0, _costs select 1]],0] call epoch_returnChange) then {
	_textMissing = getText(configFile >> "CfgMagazines" >> _costs select 0 >> "displayName");
	cutText [format[(localize "STR_EPOCH_ACTIONS_12"), _costs select 1, _textMissing], "PLAIN DOWN"];
} else {

	_type = typeOf _vehicle;
	_name = getText(configFile >> "cfgVehicles" >> _type >> "displayName");
	
	_vehicle engineOn false;
	[_vehicle,"repair",0,false] call dayz_zombieSpeak;
	
	_hitpoints = _vehicle call vehicle_getHitpoints;
	_allRepaired = true;
	{
		private ["_damage","_selection"];
		if ((vehicle player != _vehicle) || (!local _vehicle) || ([0,0,0] distance (velocity _vehicle) > 1)) exitWith {
			_allRepaired = false;
			titleText [format["Repairing of %1 stopped", _name], "PLAIN DOWN"];
		};
		_damage = [_vehicle,_x] call object_getHit;
		if (_damage > 0) then {
			if (_repairTime > 0) then {
				private "_partName";
				//change "HitPart" to " - Part" rather than complicated string replace
				_partName = toArray _x;
				_partName set [0,20];
				_partName set [1,45];
				_partName set [2,20];
				_partName = toString _partName;
				titleText [format["Repairing%1 ...", _partName], "PLAIN DOWN", _repairTime];
				sleep _repairTime;
			};
			_selection = getText(configFile >> "cfgVehicles" >> _type >> "HitPoints" >> _x >> "name");
			[_vehicle,_selection,0] call object_setFixServer;
		};
	} forEach _hitpoints;
	
	if (_allRepaired) then {
		_vehicle setDamage 0;
		_vehicle setVelocity [0,0,1];
		titleText [format["%1 Repaired", _name], "PLAIN DOWN"];
	};
};
