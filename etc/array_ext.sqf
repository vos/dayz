// Array extensions by Axe Cop

// filters elements of an array
// param 0 array to filter
// param 1 function to filter the elements, is passed the current element of the array as "_this" and should return a boolean (true to keep the element and false to omit it)
// returns array containing the filtered elements
AEX_filter = {
	private ["_a","_f","_af"];
	_a = _this select 0;
	_f = _this select 1;
	_af = [];
	{
		if (_x call _f) then {
			_af set [count _af, _x];
		};
	} forEach _a;
	_af
};

// applies a function to all elements in the array (changes the original array)
// param 0 array to apply the function to
// param 1 function to apply to each element of the array, is passed the current element of the array as "_this" and should return the new value
// returns the changed array
AEX_apply = {
	private ["_a","_f"];
	_a = _this select 0;
	_f = _this select 1;
	for "_i" from 0 to count _a -1 do {
		_a set [_i, (_a select _i) call _f];
	};
	_a
};

// applies a function to all elements in a copy of the array (does not change the original array)
// param 0 array to apply the function to
// param 1 function to apply to each element of the array, is passed the current element of the array as "_this" and should return the new value
// returns the changed array
AEX_map = {
	private ["_a","_f","_am"];
	_a = _this select 0;
	_f = _this select 1;
	_am = [];
	_am resize (count _a);
	for "_i" from 0 to count _a -1 do {
		_am set [_i, (_a select _i) call _f];
	};
	_am
};

// reduces the array to a single value (scalar usually)
// param 0 array to apply the function to, should at least contain 2 elements for this function to work
// param 1 function to reduce the array elements, is passed 2 parameters, (_this select 0) as the current reduced value and (_this select 1) is the current element of the array, the return value should be the new reduced value
// param 2 (optional) start value, if omitted the first two array elements will be used as parameters for the first function call
// returns the final value of the last function call or "nil" if the array contains less than 2 elements
AEX_reduce = {
	private ["_a","_f","_s","_v"];
	_a = _this select 0;
	if (count _a < 2) exitWith { nil };
	_f = _this select 1;
	_s = 0;
	_v = if (count _this > 2) then {
			_this select 2
		} else {
			_s = 2;
			[_a select 0, _a select 1] call _f
		};
	for "_i" from _s to count _a -1 do {
		_v = [_v, _a select _i] call _f;
	};
	_v
};
