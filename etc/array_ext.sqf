// Array extensions by Axe Cop

// Tests whether the given argument is an array or not.
// param: any
// returns: true if argument is an array; false otherwise
AEX_isArray = {
	typeName _this == "ARRAY"
};

// Tests whether the array is empty.
// param: array
// returns: true if array is empty; false otherwise
AEX_isEmpty = {
	count _this == 0
};

// Tests whether an array contains a given value as an element.
// param 0: array
// param 1: element to test
// returns: true if array contains the element; false otherwise
AEX_contains = {
	private ["_a","_e","_r"];
	_a = _this select 0;
	_e = _this select 1;
	_r = false;
	{
		if (_x == _e) exitWith {
			_r = true;
		};
	} forEach _a;
	_r
};

// Counts all elements of an array which satisfy a predicate.
// param 0: array to count
// param 1: function to count the elements, is passed the current element of the array as "_x" and should return a boolean (true to count the element)
// returns: count of matching elements
AEX_count = {
	private ["_a","_f"];
	_a = _this select 0;
	_f = _this select 1;
	{ _x call _f } count _a
};

// Tests whether a predicate holds for some elements of the array.
// param 0: array to test
// param 1: function to test the elements, is passed the current element of the array as "_x" and should return a boolean (true if the element matches)
// returns: true if at least one element matches the predicate; false otherwise
AEX_any = {
	private ["_a","_f","_any"];
	_a = _this select 0;
	_f = _this select 1;
	_any = false;
	{
		if (_x call _f) exitWith {
			_any = true;
		};
	} forEach _a;
	_any
};

// Tests whether a predicate holds for all elements of the array.
// param 0: array to test
// param 1: function to test the elements, is passed the current element of the array as "_x" and should return a boolean (true if the element matches)
// returns: true if all elements matches the predicate; false otherwise
AEX_all = {
	private ["_a","_f","_all"];
	_a = _this select 0;
	_f = _this select 1;
	_all = true;
	{
		if !(_x call _f) exitWith {
			_all = false;
		};
	} forEach _a;
	_all
};

// Returns all elements of an array which satisfy a predicate.
// param 0: array to filter
// param 1: function to filter the elements, is passed the current element of the array as "_x" and should return a boolean (true to keep the element and false to omit it)
// returns: array containing the filtered elements
AEX_filter = {
	private ["_a","_f","_ao"];
	_a = _this select 0;
	_f = _this select 1;
	_ao = [];
	{
		if (_x call _f) then {
			_ao set [count _ao, _x];
		};
	} forEach _a;
	_ao
};

// Returns the first n elements of an array matching a predicate.
// param 0: array to filter
// param 1: function to filter the elements, is passed the current element of the array as "_x" and should return a boolean (true to keep the element and false to omit it)
// param 2: maximum number of matching elements
// returns: array containing the filtered elements
AEX_filterFirst = {
	private ["_a","_f","_n","_ao"];
	_a = _this select 0;
	_f = _this select 1;
	_n = _this select 2;
	_ao = [];
	{
		if (count _ao == _n) exitWith {};
		if (_x call _f) then {
			_ao set [count _ao, _x];
		};
	} forEach _a;
	_ao
};

// Returns the last n elements of an array matching a predicate.
// param 0: array to filter
// param 1: function to filter the elements, is passed the current element of the array as "_x" and should return a boolean (true to keep the element and false to omit it)
// param 2: maximum number of matching elements
// returns: array containing the filtered elements
AEX_filterLast = {
	private ["_a","_f","_n","_ao","_x"];
	_a = _this select 0;
	_f = _this select 1;
	_n = _this select 2;
	_ao = [];
	for "_i" from ((count _a) - 1) to 0 step -1 do {
		if (count _ao == _n) exitWith {};
		_x = _a select _i;
		if (_x call _f) then {
			_ao = [_x] + _ao; // prepend element
		};
	};
	_ao
};

// Removes all elements of an array which satisfy a predicate.
// param 0: array to filter
// param 1: function to filter the elements, is passed the current element of the array as "_x" and should return a boolean (true to remove the element and false to keep it)
// returns: array containing the remaining elements
AEX_remove = {
	private ["_a","_f","_ao"];
	_a = _this select 0;
	_f = _this select 1;
	_ao = [];
	{
		if !(_x call _f) then {
			_ao set [count _ao, _x];
		};
	} forEach _a;
	_ao
};

// Applies a function to all elements of an array.
// param 0: array to apply the function to
// param 1: function to apply to each element, is passed the current element of the array as "_x" and should return the new value
// param 2: (optional): map to original array (true) or create a new array (false, default)
// returns: the changed or new array
AEX_map = {
	private ["_a","_f","_ao","_x"];
	_a = _this select 0;
	_f = _this select 1;
	_ao = [];
	if ((_this select 2) && (count _this > 2)) then {
		_ao = _a;
	} else {
		_ao resize (count _a);
	};
	for "_i" from 0 to ((count _a) - 1) do {
		_x = _a select _i;
		_ao set [_i, _x call _f];
	};
	_ao
};

// Reduces an array to a single value (a scalar usually).
// param 0: array to apply the function to, should at least contain 2 elements for this function to work
// param 1: function to reduce the array elements, is passed 2 arguments, "_r" as the current reduced value and "_x" is the current element of the array, the return value should be the new reduced value
// param 2 (optional): start value, if omitted the first two array elements will be used as arguments for the first function call
// returns: the final value of the last function call or "nil" if the array contains less than 2 elements
AEX_reduce = {
	private ["_a","_f","_s","_r","_x"];
	_a = _this select 0;
	if (count _a < 2) exitWith { nil };
	_f = _this select 1;
	_s = 0;
	_r = if (count _this > 2) then {
			_this select 2
		} else {
			_s = 2;
			_r = _a select 0;
			_x = _a select 1;
			[_r, _x] call _f
		};
	for "_i" from _s to ((count _a) - 1) do {
		_x = _a select _i;
		_r = [_r, _x] call _f;
	};
	_r
};

// Returns the first or last n elements of an array.
// param 0: maximum number of elements to take, if negative starting from the right (can be larger than the element count)
// param 1: offset, can be negative if starting from the right
// returns: new array containing at most n elements (can be less if no more elements) or "nil" if the offset is out of range
AEX_take = {
	private ["_a","_n","_o","_c","_ao"];
	_a = _this select 0;
	_n = _this select 1;
	_o = if (count _this > 2) then { _this select 2 } else { 0 };
	_c = count _a;
	if (_n < 0) then {
		// take from the right
		_n = -_n;
		_o = _c - _n + _o;
		if (_o < 0) then { _o = 0; };
	};
	if (_o < 0 || _o > _c - 1) exitWith { nil };
	if (_o + _n > _c) then { _n = _c - _o; };
	_ao = [];
	_ao resize _n;
	for "_i" from 0 to (_n - 1) do {
		_ao set [_i, _a select (_i + _o)];
	};
	_ao
};

// Returns new array with elements in reversed order.
// param: array
// returns: array in reversed order
AEX_reverse = {
	private ["_a","_n","_ao"];
	_a = _this;
	_n = count _a;
	_ao = [];
	_ao resize _n;
	_n = _n - 1; // max index
	for "_i" from 0 to _n do {
		_ao set [_n - _i, _a select _i];
	};
	_ao
};

// Compares two arrays.
// param 0: first array
// param 1: second array
// returns: true if both arrays are of the same size and all elements match; false otherwise
// TODO use equality function?
AEX_equals = {
	private ["_a","_b","_c","_e"];
	_a = _this select 0;
	_b = _this select 1;
	_c = count _a;
	if (_c != count _b) exitWith { false };
	_e = true;
	for "_i" from 0 to (_c - 1) do {
		if ((_a select _i) != (_b select _i)) exitWith { _e = false; };
	};
	_e
};

// Builds a new array without any duplicate elements.
// param: array
// returns: array with only distinct elements
// TODO optimize?
AEX_distinct = {
	private ["_a","_ao"];
	_a = _this;
	_ao = [];
	{
		if !([_ao, _x] call AEX_contains) then {
			_ao set [count _ao, _x];
		}
	} forEach _a;
	_ao
};

// private call doesn't work
AEX_quicksort = {
	private ["_ar","_of","_mf","_lo","_hi","_i","_j","_x","_b","_a","_h"];
	_ar = _this select 0;
	_of = _this select 1;
	_mf = _this select 2;
	_lo = _this select 3;
	_hi = _this select 4;
	_i = _lo;
	_j = _hi;
	_x = _ar select ((_lo + _hi) / 2);
	_b = _x call _mf;
	while {_i <= _j} do {
		while {true} do {
			_x = _ar select _i;
			_a = _x call _mf;
			if (([_a, _b] call _of) >= 0) exitWith {};
			_i = _i + 1;
		};
		while {true} do {
			_x = _ar select _j;
			_a = _x call _mf;
			if (([_a, _b] call _of) <= 0) exitWith {};
			_j = _j - 1;
		};
		if (_i <= _j) then {
			_h = _ar select _i;
			_ar set [_i, _ar select _j];
			_ar set [_j, _h];
			_i = _i + 1;
			_j = _j - 1;
		};
	};
	if (_lo < _j) then { [_ar, _of, _mf, _lo, _j] call AEX_quicksort; };
	if (_i < _hi) then { [_ar, _of, _mf, _i, _hi] call AEX_quicksort; };
};

// Sorts an array according to an ordering function.
// param 0: array
// param 1 (optional): ordering function, is passed two arguments "_a" and "_b" (returns a negative number, zero, or a positive number as "_a" is less than, equal to, or greater than "_b"), default function is AEX_order_asc
// param 2 (optional): mapping function, is passed "_x" as an element of the array and should return a numeric value (default: returns the element itself)
// returns: sorted array
AEX_sort = {
	private ["_a","_of","_mf"];
	_a = _this select 0;
	if (count _a < 2) exitWith { _a };
	_of = if (count _this > 1) then { _this select 1 } else { AEX_order_asc };
	_mf = if (count _this > 2) then { _this select 2 } else { { _x } };
	[_a, _of, _mf, 0, (count _a) - 1] call AEX_quicksort;
	_a
};

// Ordering function for ascending order.
AEX_order_asc = { _a - _b };

// Ordering function for descending order.
AEX_order_desc = { _b - _a };
