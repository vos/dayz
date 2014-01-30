// DayZ Epoch Helper Functions by Axe Cop

private ["_version","_skip"];
_version = 1.03;

// redefine functions only if this file is a newer version
_skip = false;
if (!isNil "AC_functions") then {
	if (AC_functions >= _version) then {
		diag_log format ["evaluation of ac_functions.sqf skipped, active version %1 is newer or equal than this file (version %2)", AC_functions, _version];
		_skip = true;
	};
};
if (_skip) exitWith {};

AC_functions = _version;
diag_log format ["AC_functions version %1", AC_functions];

// params: x:any
// return: bool
AC_fnc_isArray = {
	typeName _this == "ARRAY"
};

// params: [num:number, len:number]
// return: str:string
AC_fnc_num2str = {
	private ["_num","_len","_str","_numArr","_i"];
	_num = _this select 0;
	_len = _this select 1;
	_str = str _num;
	_numArr = toArray _str;
	for "_i" from (count _numArr) to (_len-1) do {
		_str = "0" + _str;
	};
	_str
};

// params: [object, [id], [classname]]
// return: object
AC_fnc_swapObject = {
	private ["_obj","_objectCharacterID","_objectID","_objectUID","_classname","_location","_dir","_object"];
	_obj = _this select 0;
	_objectCharacterID = if (count _this >= 2) then [{_this select 1}, {_obj getVariable ["CharacterID","0"]}];
	_objectID = _obj getVariable ["ObjectID","0"];
	_objectUID = _obj getVariable ["ObjectUID","0"];
	if (_objectID == "0" && _objectUID == "0") exitWith { nil };
	_classname = if (count _this >= 3) then [{_this select 2}, {typeOf _obj}];
	_location = _obj getVariable ["OEMPos",(getPosATL _obj)];
	_dir = getDir _obj;
	_object = createVehicle [_classname, [0,0,0], [], 0, "CAN_COLLIDE"];
	_object setDir _dir;
	_object setPosATL _location;
	PVDZE_obj_Swap = [_objectCharacterID,_object,[_dir,_location],_classname,_obj,player];
	publicVariableServer "PVDZE_obj_Swap";
	player reveal _object;
	_object
};

// params: tools:array
// return: bool
AC_fnc_hasTools = {
	private ["_tools","_items","_hasTools","_missing"];
	_tools = _this;
	_items = items player; // weapons player
	_hasTools = true;
	{
		if (!(_x in _items)) exitWith {
			_hasTools = false;
			_missing = getText (configFile >> "cfgWeapons" >> _x >> "displayName");
			cutText [format["Missing tool %1", _missing] , "PLAIN DOWN"];
		};
	} forEach _tools;
	_hasTools
};

// params: requirements:array
// return: bool
AC_fnc_checkRequirements = {
	private ["_items","_inventory","_hasItems","_itemIn","_countIn","_qty","_missing","_missingQty","_textMissing"];
	_items = _this;
	_inventory = magazines player;
	_hasItems = true;
	{
		_itemIn = "";
		_countIn = 1;
		if (typeName _x == "ARRAY") then {
			if (count _x > 0) then {
				_itemIn = _x select 0;
				if (count _x > 1) then {
					_countIn = _x select 1;
				};
			};
		} else {
			_itemIn = _x;
		};
		if (_itemIn != "") then {
			_qty = { (_x == _itemIn) || (configName(inheritsFrom(configFile >> "cfgMagazines" >> _x)) == _itemIn) } count _inventory;
		} else {
			_qty = _countIn;
		};
		if (_qty < _countIn) exitWith {
			_missing = _itemIn;
			_missingQty = (_countIn - _qty);
			_hasItems = false;
			_textMissing = getText(configFile >> "CfgMagazines" >> _missing >> "displayName");
			cutText [format["Missing %1 more of %2", _missingQty, _textMissing], "PLAIN DOWN"];
		};
	} forEach _items;
	_hasItems
};

// params: requirements:array
// return: bool
AC_fnc_removeRequirements = {
	private ["_items","_inventory","_temp_removed_array","_removed_total","_tobe_removed_total","_removed","_itemIn","_countIn","_num_removed"];
	_items = _this;
	_inventory = magazines player;
	_temp_removed_array = [];
	_removed_total = 0;
	_tobe_removed_total = 0;
	{
		_removed = 0;
		_itemIn = "";
		_countIn = 1;
		if (typeName _x == "ARRAY") then {
			if (count _x > 0) then {
				_itemIn = _x select 0;
				if (count _x > 1) then {
					_countIn = _x select 1;
				};
			};
		} else {
			_itemIn = _x;
		};
		if (_itemIn != "") then {
			_tobe_removed_total = _tobe_removed_total + _countIn;
			{
				if ((_removed < _countIn) && ((_x == _itemIn) || configName(inheritsFrom(configFile >> "cfgMagazines" >> _x)) == _itemIn)) then {
					_num_removed = ([player,_x] call BIS_fnc_invRemove);
					_removed = _removed + _num_removed;
					_removed_total = _removed_total + _num_removed;
					if (_num_removed >= 1) then {
						_temp_removed_array set [count _temp_removed_array, _x];
					};
				};
			} forEach _inventory;
		};
	} forEach _items;
	// all parts removed
	if (_tobe_removed_total == _removed_total) exitWith { true };
	// missing parts
	{ player addMagazine _x; } forEach _temp_removed_array;
	cutText [format["Missing Parts after first check Item: %1 / %2", _removed_total, _tobe_removed_total], "PLAIN DOWN"];
	false
};

// params: requirements:array
// return: bool
AC_fnc_checkAndRemoveRequirements = {
	private ["_requirements","_b"];
	_requirements = _this;
	_b = _requirements call AC_fnc_checkRequirements;
	if (_b) then {
		_b = _requirements call AC_fnc_removeRequirements;
	};
	_b
};

// params: [animation:string, range:number]
AC_fnc_doAnimationAndAlertZombies = {
	private ["_animation","_range"];
	_animation = _this select 0;
	_range = _this select 1;
	player playActionNow _animation;
	[player,_range,true,(getPosATL player)] spawn player_alertZombies;
};
