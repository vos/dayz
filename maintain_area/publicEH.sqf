"maintainArea_log"		addPublicVariableEventHandler {
	_val = _this select 1;
	_player = _val select 0;
	_playerName = name _player;
	_playerID = getPlayerUID _player;
	_target = _val select 1;
	_position = position _target;
	_count = _val select 2;
	diag_log format["MAINTAIN_AREA: Player %1 (%2) has maintained %3 building parts at position %4", _playerName, _playerID, _count, _position];
};
