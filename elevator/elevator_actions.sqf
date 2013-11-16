private ["_args","_option","_elevator","_id","_elevatorStop"];

player removeAction s_player_elevator_next;
s_player_elevator_next = -1;
player removeAction s_player_elevator_previous;
s_player_elevator_previous = -1;
player removeAction s_player_elevator_select;
s_player_elevator_select = -1;
player removeAction s_player_elevator_call;
s_player_elevator_call = -1;
player removeAction s_player_elevator_id;
s_player_elevator_id = -1;

_args = _this select 3;
_option = _args select 0;
switch (_option) do {
	case "next": {
		_elevator = _args select 1;
		[_elevator, +1] call ELE_fnc_activateElevator;
	};
	case "previous": {
		_elevator = _args select 1;
		[_elevator, -1] call ELE_fnc_activateElevator;
	};
	case "select": {
		ELE_elevator = _args select 1;
		_id = [ELE_elevator] call ELE_fnc_getElevatorId;
		cutText [format["Elevator %1 selected", (_id select 0)], "PLAIN DOWN"];
	};
	case "call": {
		_elevatorStop = _args select 1;
		[_elevatorStop] call ELE_fnc_callElevator;
	};
	case "id": {
		_elevator = _args select 1;
		_id = [_elevator] call ELE_fnc_getElevatorId;
		cutText [format["Elevator ID = %1", _id], "PLAIN DOWN"];
	};
};
