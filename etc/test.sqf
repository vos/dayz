// simple test framework by Axe Cop

private ["_fnc_assertTrue","_fnc_assertFalse","_fnc_assertNil","_fnc_assertNotNil","_fnc_assertEqual"];

_fnc_assertTrue = {
	private ["_text","_value"];
	_text = _this select 0;
	_value = _this select 1;
	diag_log ("TEST (assertTrue) " + _text + " " + (if (_value) then {"successful"} else {"failed"}));
};

_fnc_assertFalse = {
	private ["_text","_value"];
	_text = _this select 0;
	_value = _this select 1;
	diag_log ("TEST (assertFalse) " + _text + " " + (if (!_value) then {"successful"} else {"failed"}));
};

_fnc_assertNil = {
	private ["_text","_value"];
	_text = _this select 0;
	_value = _this select 1;
	diag_log ("TEST (assertNil) " + _text + " " + (if (isNil "_value") then {"successful"} else {"failed"}));
};

_fnc_assertNotNil = {
	private ["_text","_value"];
	_text = _this select 0;
	_value = _this select 1;
	diag_log ("TEST (assertNotNil) " + _text + " " + (if (!isNil "_value") then {"successful"} else {"failed"}));
};

_fnc_assertEqual = {
	private ["_text","_expected","_actual","_equal"];
	_text = _this select 0;
	_expected = _this select 1;
	_actual = _this select 2;
	_equal = if ((_expected call AEX_isArray) && (_actual call AEX_isArray)) then {
			[_expected, _actual] call AEX_equals
		} else {
			_expected == _actual
		};
	diag_log ("TEST (assertEqual) " + _text + " " + (if (_equal) then {"successful"} else {"failed"}) + ": (expected = " + (str _expected) + ", actual = " + (str _actual) + ")");
};
