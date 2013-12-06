// elevator functions

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
	_idStr = [_id, 3] call AC_fnc_num2str;
	_eid = "6976" + _idStr + "0";
	diag_log format ["ELE_fnc_generateElevatorId elevator id generated: %1", _eid];
	_eid
};

// params: elevator:object, stopDiff:number 
// params: stop:object
ELE_fnc_getNextStop = {
	private ["_elevator","_stopDiff","_id","_currentStopId","_nextStopId","_maxRange","_stop","_xid"];
	_elevator = _this select 0;
	_stopDiff = _this select 1;
	_maxStopId = 9;
	_id = _elevator getVariable ["ElevatorID", 0];
	_currentStopId = _elevator getVariable ["ElevatorCurrentStop", 0];
	_nextStopId = _currentStopId + _stopDiff;
	if (_nextStopId < 0 || _nextStopId > _maxStopId) exitWith {
		diag_log format ["ELE_fnc_getNextStop next stop id %1 is out of range", _nextStopId];
		nil
	};
	_maxRange = ELE_MaxRange * (abs _stopDiff);
	_stop = nil;
	{
		_xid = [_x] call ELE_fnc_getElevatorId;
		if ((_xid select 0) == _id && (_xid select 1) == _nextStopId) exitWith {
			// next stop found
			_stop = _x;
		};
	} forEach ((getPos _elevator) nearObjects [ELE_StopClass, _maxRange]);
	_stop
};

// params: elevator:object
// return: bool
ELE_fnc_hasNextStop = {
	private ["_elevator","_stop","_b"];
	_elevator = _this select 0;
	_stop = [_elevator, +1] call ELE_fnc_getNextStop;
	_b = !isNil "_stop";
	_b
};

// params: elevator:object
// return: bool
ELE_fnc_hasPreviousStop = {
	private ["_elevator","_stop","_b"];
	_elevator = _this select 0;
	_stop = [_elevator, -1] call ELE_fnc_getNextStop;
	_b = !isNil "_stop";
	_b
};

// params: elevator:object
// return: stop_id:string
ELE_fnc_getNextStopId = {
	private ["_elevator","_maxStopId","_id","_nextStopId","_idStr","_eid"];
	_elevator = _this select 0;
	_maxStopId = 9;
	_id = _elevator getVariable ["ElevatorID", 0];
	_nextStopId = (_elevator getVariable ["ElevatorCurrentStop", 0]) + 1;
	if (_nextStopId > _maxStopId) exitWith {
		diag_log format ["ELE_fnc_getNextStopId stop %1 > max stop %2", _nextStopId, _maxStopId];
		""
	};
	if ([_elevator] call ELE_fnc_hasNextStop) exitWith {
		diag_log format ["ELE_fnc_getNextStopId stop %1 already exists", _nextStopId];
		""
	};
	_idStr = [_id, 3] call AC_fnc_num2str;
	_eid = "6976" + _idStr + (str _nextStopId);
	diag_log format ["ELE_fnc_getNextStopId next stop id: %1", _eid];
	_eid
};

// params: elevator:object, stopDiff:number 
ELE_fnc_activateElevator = {
	private ["_elevator","_stopDiff","_id","_currentStopId","_firstActivation","_nextStopId","_nextStop","_dest","_pos","_dir","_stop","_dist","_attachments","_updateInterval","_distLast"];
	_elevator = _this select 0;
	_stopDiff = _this select 1;
	if (_elevator getVariable ["ElevatorActive", false]) exitWith {
		cutText ["this elevator is already active", "PLAIN DOWN"];
	};
	_id = _elevator getVariable ["ElevatorID", 0];
	_currentStopId = _elevator getVariable ["ElevatorCurrentStop", -1];
	_firstActivation = false;
	if (_currentStopId == -1) then {
		_firstActivation = true;
		_currentStopId = 0;
	};
	// find next elevator stop
	_nextStopId = _currentStopId + _stopDiff;
	_nextStop = [_elevator, _stopDiff] call ELE_fnc_getNextStop;
	if (isNil "_nextStop") exitWith {
		cutText ["next elevator stop not found", "PLAIN DOWN"];
	};
	_dest = getPosATL _nextStop;
	_dest set [2, (_dest select 2) + 0.05]; // elevate a little to separate elevator and stop point
	_pos = getPosATL _elevator;
	// check here again, if there is no elevator stop no elevator will be created
	if (_firstActivation) then {
		// spawn elevator in and replace original with stop point
		_dir = getDir _elevator;
		deleteVehicle _elevator; // delete original
		// create new elevator
		_elevator = createVehicle [ELE_PlatformClass, [0,0,0], [], 0, "CAN_COLLIDE"];
		// _elevator = ELE_PlatformClass createVehicleLocal _pos;
		_elevator setDir _dir;
		_elevator setPosATL _pos;
		_elevator setVariable ["ElevatorID", _id, true];
		_elevator setVariable ["ElevatorStopID", 0, true];
		player reveal _elevator;
		// create stop point
		_stop = createVehicle [ELE_StopClass, [0,0,0], [], 0, "CAN_COLLIDE"];
		_stop setDir _dir;
		_stop setPosATL _pos;
		_stop setVariable ["ElevatorID", _id, true];
		_stop setVariable ["ElevatorStopID", 0, true];
		player reveal _stop;
		diag_log format ["ELE_fnc_activateElevator first elevator activation: id = %1", _id];
	} else {
		// make the elevator local to the player who activated it
		if (!local _elevator) then {
			// use setOwner on the server instead?
			_dir = getDir _elevator;
			deleteVehicle _elevator; // delete original
			// create new elevator
			_elevator = createVehicle [ELE_PlatformClass, [0,0,0], [], 0, "CAN_COLLIDE"];
			_elevator setDir _dir;
			_elevator setPosATL _pos;
			_elevator setVariable ["ElevatorID", _id, true];
			_elevator setVariable ["ElevatorStopID", 0, true];
			player reveal _elevator;
			diag_log format ["ELE_fnc_activateElevator locality of elevator changed to player %1", name player];
		};
	};
	// select this elevator
	ELE_elevator = _elevator;
	_dist = _pos distance _dest;
	_elevator setVariable ["ElevatorActive", true, true];
	// attach near entities to the elevator platform
	_attachments = [];
	{ _x attachTo [_elevator]; _attachments set [count _attachments, _x]; } forEach (_elevator nearEntities ELE_Size);
	// animate to the next stop
	cutText [format["moving to the next elevator stop (%1, %2 m away) ...", _nextStopId, _dist], "PLAIN DOWN"];
	_updateInterval = 1 / ELE_UpdatesPerSecond;
	// direction pos -> dest
	_dir = [_dest, _pos] call VEC_fnc_sub;
	// normalize dir vector to the elevator speed
	_dir = _dir call VEC_fnc_unit;
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
	_elevator setVariable ["ElevatorCurrentStop", _nextStopId, true];
	_elevator setVariable ["ElevatorActive", false, true];
	cutText ["... elevator stop reached", "PLAIN DOWN"];
};

// params: elevatorStop:object
ELE_fnc_callElevator = {
	private ["_elevatorStop","_id","_elevatorId","_stopId","_elevator","_xid","_currentStopId","_stopDiff"];
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
	_currentStopId = _elevator getVariable ["ElevatorCurrentStop", 0];
	_stopDiff = if (_stopId > _currentStopId) then [{+1},{-1}];
	while {_currentStopId != _stopId} do {
		[_elevator, _stopDiff] call ELE_fnc_activateElevator;
		_currentStopId = _currentStopId + _stopDiff;
		// wait at each stop
		if (ELE_StopWaitTime > 0) then {
			sleep ELE_StopWaitTime;
		};
	};
	cutText ["elevator arrived", "PLAIN DOWN"];
};
