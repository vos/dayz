// elevator functions

// params: object, [id], [classname]
// return: object
ELE_fnc_swapObject = {
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
	PVDZE_obj_Swap = [_objectCharacterID,_object,[_dir,_location],_classname,_obj,_objectID,_objectUID];
	publicVariableServer "PVDZE_obj_Swap";
	player reveal _object;
	_object
};

// params: num:number, len:number
// return: str:string
ELE_fnc_num2str = {
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

// params: obj:object
// return: [elevator_id:number, stop_id:number]
ELE_fnc_getElevatorId = {
	private ["_obj","_id","_cid","_cidArr","_ele","_i","_stopId"];
	_obj = _this select 0;
	_id = _obj getVariable ["ElevatorID", 0];
	_stopId = _obj getVariable ["ElevatorStopID", -1];
	if (_id > 0 && _stopId >= 0) exitWith {[_id,_stopId]};
	// id not cached yet, decode it
	_cid = _obj getVariable ["CharacterID", "0"];
	// ID 8 digits: EL-ID-STID = 6976-###-#
	_cidArr = toArray _cid;
	if (count _cidArr != 8) exitWith {[0,0]};
	_ele = "";
	for "_i" from 0 to 3 do {
		_ele = _ele + (toString [_cidArr select _i]);
	};
	if (_ele != "6976") exitWith {[0,0]};
	_id = (((_cidArr select 4)-48)*100) + (((_cidArr select 5)-48)*10) + ((_cidArr select 6)-48);
	_stopId = (_cidArr select 7)-48;
	// should be an elevator or elevator stop
	_obj setVariable ["ElevatorID", _id, true];
	_obj setVariable ["ElevatorStopID", _stopId, true];
	[_id, _stopId]
};

// params: obj:object
// return: bool
ELE_fnc_isElevator = {
	private ["_obj","_id","_b"];
	_obj = _this select 0;
	if ((typeOf _obj) != ELE_PlatformClass) exitWith { false };
	_id = [_obj] call ELE_fnc_getElevatorId;
	_b = (_id select 0) > 0 && (_id select 1) == 0;
	_b
};

// params: obj:object
// return: bool
ELE_fnc_isElevatorStop = {
	private ["_obj","_id","_b"];
	_obj = _this select 0;
	if ((typeOf _obj) != ELE_StopClass) exitWith { false };
	_id = [_obj] call ELE_fnc_getElevatorId;
	_b = (_id select 0) > 0;
	_b
};

// params: obj:object
// return: id:string
ELE_fnc_generateElevatorId = {
	private ["_obj","_maxElevatorId","_maxDistance","_id","_eid","_idTemp","_idStr"];
	_obj = _this select 0;
	_maxElevatorId = 999;
	// generate random id instead?
	_maxDistance = 500;
	_id = 1;
	{
		if (alive _x) then {
			_idTemp = ([_x] call ELE_fnc_getElevatorId) select 0;
			if (_idTemp > 0) then {
				diag_log format ["ELE_fnc_generateElevatorId elevator found: %1, id = %2", _x, _idTemp];
			};
			if (_idTemp >= _id) then {
				_id = _idTemp + 1;
			};
		};
	} forEach ((getPos _obj) nearObjects [ELE_PlatformClass, _maxDistance]);
	if (_id > _maxElevatorId) exitWith { "" };
	_idStr = [_id, 3] call ELE_fnc_num2str;
	_eid = "6976" + _idStr + "0";
	diag_log format ["ELE_fnc_generateElevatorId elevator id generated: %1", _eid];
	_eid
};

// params: elevator:object
// return: stop_id:string
ELE_fnc_getNextStopId = {
	private ["_elevator","_maxStopId","_id","_nextStopId","_found","_xid","_idStr","_eid"];
	_elevator = _this select 0;
	_maxStopId = 9;
	_id = _elevator getVariable ["ElevatorID", 0];
	_nextStopId = (_elevator getVariable ["ElevatorCurrentStop", 0]) + 1;
	if (_nextStopId > _maxStopId) exitWith { "" };
	// check if there is already a stop with that id
	_found = false;
	{
		_xid = [_x] call ELE_fnc_getElevatorId;
		if ((_xid select 0) == _id && (_xid select 1) == _nextStopId) exitWith {
			_found = true;
			diag_log format ["ELE_fnc_getNextStopId stop %1 already exists", _nextStopId];
		};
	} forEach ((getPos _elevator) nearObjects [ELE_StopClass, ELE_MaxRange]);
	if (_found) exitWith { "" };
	_idStr = [_id, 3] call ELE_fnc_num2str;
	_eid = "6976" + _idStr + (str _nextStopId);
	diag_log format ["ELE_fnc_getNextStopId next stop id: %1", _eid];
	_eid
};

// params: elevator:object, stopDiff:number 
ELE_fnc_activateElevator = {
	private ["_elevator","_stopDiff","_id","_currentStop","_firstActivation","_nextStop","_dest","_xid","_pos","_stopPoint","_dist","_attachments","_dir","_updateInterval","_distLast"];
	_elevator = _this select 0;
	_stopDiff = _this select 1;
	if (_elevator getVariable ["ElevatorActive", false]) exitWith {
		cutText ["this elevator is already active", "PLAIN DOWN"];
	};
	_id = _elevator getVariable ["ElevatorID", 0];
	_currentStop = _elevator getVariable ["ElevatorCurrentStop", -1];
	_firstActivation = false;
	if (_currentStop == -1) then {
		_firstActivation = true;
		_currentStop = 0;
	};
	// find next elevator stop
	_nextStop = _currentStop + _stopDiff;
	_dest = nil;
	{
		_xid = [_x] call ELE_fnc_getElevatorId;
		if ((_xid select 0) == _id && (_xid select 1) == _nextStop) exitWith {
			// next stop found
			_dest = getPosATL _x;
		};
	} forEach ((getPos _elevator) nearObjects [ELE_StopClass, ELE_MaxRange]);
	if (isNil "_dest") exitWith {
		cutText ["next elevator stop not found", "PLAIN DOWN"];
	};
	_pos = getPosATL _elevator;
	// check here again, if there is no elevator stop no elevator will be created
	if (_firstActivation) then {
		// spawn elevator in and replace original with stop point
		_dir = getDir _elevator;
		deleteVehicle _elevator; // delete original
		// create new elevator
		_elevator = createVehicle [ELE_PlatformClass, [0,0,0], [], 0, "CAN_COLLIDE"];
		_elevator setDir _dir;
		_elevator setPosATL _pos;
		player reveal _elevator;
		_elevator setVariable ["ElevatorID", _id, true];
		_elevator setVariable ["ElevatorStopID", 0, true];
		// select this elevator
		ELE_elevator = _elevator;
		// create stop point
		_stopPoint = createVehicle [ELE_StopClass, [0,0,0], [], 0, "CAN_COLLIDE"];
		_stopPoint setDir _dir;
		_stopPoint setPosATL _pos;
		player reveal _stopPoint;
		_stopPoint setVariable ["ElevatorID", _id, true];
		_stopPoint setVariable ["ElevatorStopID", 0, true];
		diag_log format ["ELE_fnc_activateElevator first elevator activation: id = %1", _id];
	};
	_dist = _pos distance _dest;
	_elevator setVariable ["ElevatorActive", true, true];
	// attach near entities to the elevator platform
	_attachments = [];
	{ _x attachTo [_elevator]; _attachments set [count _attachments, _x]; } forEach (_elevator nearEntities ELE_Size);
	// animate to the next stop
	cutText [format["moving to the next elevator stop (%1, %2 m away) ...", _nextStop, _dist], "PLAIN DOWN"];
	_updateInterval = 1 / ELE_UpdatesPerSecond;
	// direction pos -> dest
	_dir = [_dest, _pos] call VEC_fnc_sub;
	// normalize dir vector to the elevator speed
	_dir = [_dir] call VEC_fnc_unit;
	_dir = [_dir, ELE_Speed * _updateInterval] call VEC_fnc_mul;
	_distLast = _dist;
	// if the distance is greater than last iteration we have reached the destination (went past it actually)
	while {_dist <= _distLast} do {
		_pos = [_pos, _dir] call VEC_fnc_add;
		_elevator setPosATL _pos;
		_distLast = _dist;
		_dist = _pos distance _dest;
		sleep _updateInterval;
	};
	_elevator setPosATL _dest; // just in case it went to far
	// detach entities again
	{ detach _x; } forEach _attachments;
	_elevator setVariable ["ElevatorCurrentStop", _nextStop, true];
	_elevator setVariable ["ElevatorActive", false, true];
	cutText ["... elevator stop reached", "PLAIN DOWN"];
};

// params: elevatorStop:object 
ELE_fnc_callElevator = {
	private ["_elevatorStop","_id","_elevatorId","_stopId","_elevator","_xid","_currentStop","_stopDiff"];
	_elevatorStop = _this select 0;
	_id = [_elevatorStop] call ELE_fnc_getElevatorId;
	_elevatorId = _id select 0;
	_stopId = _id select 1;
	// find elevator
	_elevator = nil;
	{
		_xid = [_x] call ELE_fnc_getElevatorId;
		if ((_xid select 0) == _elevatorId) exitWith {
			// elevator found
			_elevator = _x;
		};
	} forEach (nearestObjects [_elevatorStop, [ELE_PlatformClass], ELE_MaxRange * 10]); // max 10 times the range because 10 possible stops
	if (isNil "_elevator") exitWith {
		cutText ["elevator not found", "PLAIN DOWN"];
	};
	if (_elevator getVariable ["ElevatorActive", false]) exitWith {
		cutText ["this elevator is already active", "PLAIN DOWN"];
	};
	// get the elevator to this stop point
	_currentStop = _elevator getVariable ["ElevatorCurrentStop", 0];
	_stopDiff = if (_stopId > _currentStop) then [{+1},{-1}];
	while {_currentStop != _stopId} do {
		[_elevator, _stopDiff] call ELE_fnc_activateElevator;
		_currentStop = _currentStop + _stopDiff;
		// wait at each stop
		if (ELE_StopWaitTime > 0) then {
			sleep ELE_StopWaitTime;
		};
	};
	cutText ["elevator arrived", "PLAIN DOWN"];
};
