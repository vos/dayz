// Array extensions tests and examples by Axe Cop

private ["_data","_fnc","_dataFiltered","_dataMapped","_dataReduced","_dataApplied"];

_data = [1,2,3,4,5,6,7,8,9];

// filter
_fnc = { _this >= 5 };
_dataFiltered = [_data, _fnc] call AEX_filter;
diag_log ["AEX_filter #1", _data, _dataFiltered]; // ["AEX_filter #1",[1,2,3,4,5,6,7,8,9],[5,6,7,8,9]]

_dataFiltered = [_data, { _this < 4 }] call AEX_filter; // ["AEX_filter #2",[1,2,3,4,5,6,7,8,9],[1,2,3]]
diag_log ["AEX_filter #2", _data, _dataFiltered];

_dataFiltered = [_data, { _this > 2 and _this < 8 }] call AEX_filter;
diag_log ["AEX_filter #3", _data, _dataFiltered]; // ["AEX_filter #3",[1,2,3,4,5,6,7,8,9],[3,4,5,6,7]]

_dataFiltered = [_data, { _this mod 2 == 0 }] call AEX_filter;
diag_log ["AEX_filter #4", _data, _dataFiltered]; // ["AEX_filter #4",[1,2,3,4,5,6,7,8,9],[2,4,6,8]]

// map
_dataMapped = [_data, { _this * 2 }] call AEX_map;
diag_log ["AEX_map #1", _data, _dataMapped]; // ["AEX_map #1",[1,2,3,4,5,6,7,8,9],[2,4,6,8,10,12,14,16,18]]

_dataMapped = [_data, { str _this }] call AEX_map;
diag_log ["AEX_map #2", _data, _dataMapped]; // ["AEX_map #2",[1,2,3,4,5,6,7,8,9],["1","2","3","4","5","6","7","8","9"]]

// reduce
_dataReduced = [_data, { (_this select 0) + (_this select 1) }] call AEX_reduce;
diag_log ["AEX_reduce #1", _data, _dataReduced]; // ["AEX_reduce #1",[1,2,3,4,5,6,7,8,9],45]

_dataReduced = [_data, { (_this select 0) + (_this select 1) }, 0] call AEX_reduce;
diag_log ["AEX_reduce #2", _data, _dataReduced]; // ["AEX_reduce #2",[1,2,3,4,5,6,7,8,9],45]

_dataReduced = [[_data, { _this <= 5 }] call AEX_filter, { (_this select 0) * (_this select 1) }] call AEX_reduce;
diag_log ["AEX_reduce #3", _data, _dataReduced]; // ["AEX_reduce #3",[1,2,3,4,5,6,7,8,9],120]

_dataReduced = [[_data, { _this <= 5 }] call AEX_filter, { (_this select 0) * (_this select 1) }, 10] call AEX_reduce;
diag_log ["AEX_reduce #4", _data, _dataReduced]; // ["AEX_reduce #4",[1,2,3,4,5,6,7,8,9],1200]

// apply
_dataApplied = [_data, { _this * 2 }] call AEX_apply;
diag_log ["AEX_apply #1", _data, _dataApplied]; // ["AEX_apply #1",[2,4,6,8,10,12,14,16,18],[2,4,6,8,10,12,14,16,18]]

_dataApplied = [_data, { _this * 2 }] call AEX_apply;
diag_log ["AEX_apply #2", _data, _dataApplied]; // ["AEX_apply #2",[4,8,12,16,20,24,28,32,36],[4,8,12,16,20,24,28,32,36]]


// real examples
private ["_vehicles","_vehicleData","_nearEntities","_players","_playerData","_damage"];

// vehicles with at least 10% damage are mapped to an data array like [vehicle type, position, damage]
_vehicles = [vehicles, { damage _this > .1 }] call AEX_filter;
_vehicleData = [_vehicles, { [typeOf _this, position _this, damage _this] }] call AEX_map;
diag_log ["AEX damaged vehicles", _vehicles, _vehicleData];
// ["AEX damaged vehicles",[209f6080# 1056396: ah6x.p3d REMOTE,248de080# 1055939: hmmwv.p3d REMOTE,256ab040# 1055991: gnt_c185.p3d REMOTE],[["AH6X_DZ",[10473.1,8864.83,0.0306244],0.334646],["HMMWV_DZ",[11219.5,12499.5,-0.0309296],0.204724],["GNT_C185U",[12776.4,5338.54,0.13018],0.649606]]]

// list of player names and distance within 100m of the player who own a toolbox
_nearEntities = player nearEntities 100;
_players = [_nearEntities, { isPlayer _this and "ItemToolbox" in items _this }] call AEX_filter;
_playerData = [_players, { [name _this, player distance _this] }] call AEX_map;
diag_log ["AEX near players with toolbox", _players, _playerData];
// ["AEX near players with toolbox",[B 1-1-B:1 (Axe Cop), C 1-2-C:3 (Player 2)],[["Axe Cop",0],["Axe Cop",0],["Player 2",13.565]]]

// overall damage of all units
_damage = [allUnits, { (_this select 0) + damage (_this select 1) }, 0] call AEX_reduce;
diag_log ["AEX overall damage of all units", _damage];
// ["AEX overall damage of all units",2.457]
