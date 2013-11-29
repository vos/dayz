// Array extensions tests and examples by Axe Cop

private ["_data"];

#include "test.sqf"

_data = [1,2,3,4,5,6,7,8,9];

["AEX_count #1", count _data, [_data, { true }] call AEX_count] call _fnc_assertEqual;
["AEX_count #2", 0, [_data, { false }] call AEX_count] call _fnc_assertEqual;
["AEX_count #3", 3, [_data, { _x <= 3 }] call AEX_count] call _fnc_assertEqual;
["AEX_count #4", 4, [_data, { _x mod 2 == 0 }] call AEX_count] call _fnc_assertEqual;

["AEX_any #1", [_data, { _x > 10 }] call AEX_any] call _fnc_assertFalse;
["AEX_any #2", [_data, { _x < 10 }] call AEX_any] call _fnc_assertTrue;
["AEX_any #3", [_data, { _x mod 2 == 0 }] call AEX_any] call _fnc_assertTrue;

["AEX_all #1", [_data, { _x mod 2 == 0 }] call AEX_all] call _fnc_assertFalse;
["AEX_all #2", [_data, { _x < 10 }] call AEX_all] call _fnc_assertTrue;
["AEX_all #3", [_data, { _x == round _x }] call AEX_all] call _fnc_assertTrue;

["AEX_filter #1", _data, [_data, { true }] call AEX_filter] call _fnc_assertEqual;
["AEX_filter #2", [], [_data, { false }] call AEX_filter] call _fnc_assertEqual;
["AEX_filter #3", [5,6,7,8,9], [_data, { _x >= 5 }] call AEX_filter] call _fnc_assertEqual;
["AEX_filter #4", [1,2,3], [_data, { _x < 4 }] call AEX_filter] call _fnc_assertEqual;
["AEX_filter #5", [3,4,5,6,7], [_data, { _x > 2 and _x < 8 }] call AEX_filter] call _fnc_assertEqual;
["AEX_filter #6", [2,4,6,8], [_data, { _x mod 2 == 0 }] call AEX_filter] call _fnc_assertEqual;
["AEX_filter #7", [], [_data, { _x > 100 }] call AEX_filter] call _fnc_assertEqual;

["AEX_filterFirst #1", [1,2,3], [_data, { true }, 3] call AEX_filterFirst] call _fnc_assertEqual;
["AEX_filterFirst #2", _data, [_data, { true }, count _data] call AEX_filterFirst] call _fnc_assertEqual;
["AEX_filterFirst #3", _data, [_data, { true }, 100] call AEX_filterFirst] call _fnc_assertEqual;
["AEX_filterFirst #4", [], [_data, { _x < 4 }, 0] call AEX_filterFirst] call _fnc_assertEqual;
["AEX_filterFirst #5", [2,4], [_data, { _x mod 2 == 0 }, 2] call AEX_filterFirst] call _fnc_assertEqual;
["AEX_filterFirst #6", [], [_data, { _x > 100 }, 5] call AEX_filterFirst] call _fnc_assertEqual;

["AEX_filterLast #1", [7,8,9], [_data, { true }, 3] call AEX_filterLast] call _fnc_assertEqual;
["AEX_filterLast #2", _data, [_data, { true }, count _data] call AEX_filterLast] call _fnc_assertEqual;
["AEX_filterLast #3", _data, [_data, { true }, 100] call AEX_filterLast] call _fnc_assertEqual;
["AEX_filterLast #4", [], [_data, { _x < 4 }, 0] call AEX_filterLast] call _fnc_assertEqual;
["AEX_filterLast #5", [6,8], [_data, { _x mod 2 == 0 }, 2] call AEX_filterLast] call _fnc_assertEqual;
["AEX_filterLast #6", [], [_data, { _x > 100 }, 5] call AEX_filterLast] call _fnc_assertEqual;

["AEX_remove #1", [], [_data, { true }] call AEX_remove] call _fnc_assertEqual;
["AEX_remove #2", _data, [_data, { false }] call AEX_remove] call _fnc_assertEqual;
["AEX_remove #3", [1,2,3,4], [_data, { _x >= 5 }] call AEX_remove] call _fnc_assertEqual;
["AEX_remove #4", [4,5,6,7,8,9], [_data, { _x < 4 }] call AEX_remove] call _fnc_assertEqual;
["AEX_remove #5", [1,2,8,9], [_data, { _x > 2 and _x < 8 }] call AEX_remove] call _fnc_assertEqual;
["AEX_remove #6", [1,3,5,7,9], [_data, { _x mod 2 == 0 }] call AEX_remove] call _fnc_assertEqual;
["AEX_remove #7", _data, [_data, { _x > 100 }] call AEX_remove] call _fnc_assertEqual;

["AEX_map #1", _data, [_data, { _x }] call AEX_map] call _fnc_assertEqual;
["AEX_map #2", [0,0,0,0,0,0,0,0,0], [_data, { 0 }] call AEX_map] call _fnc_assertEqual;
["AEX_map #3", [2,4,6,8,10,12,14,16,18], [_data, { _x * 2 }] call AEX_map] call _fnc_assertEqual;
["AEX_map #4", ["1","2","3","4","5","6","7","8","9"], [_data, { str _x }] call AEX_map] call _fnc_assertEqual;
["AEX_map #5", [-4,-3,-2,-1,0,1,2,3,4], [_data, { _x - 5 }, false] call AEX_map] call _fnc_assertEqual;
["AEX_map #6", [1,3,5,7,9,11,13,15,17], [[1,2,3,4,5,6,7,8,9], { _x * 2 - 1 }, true] call AEX_map] call _fnc_assertEqual; // changes data

["AEX_reduce #1", 45, [_data, { _r + _x }] call AEX_reduce] call _fnc_assertEqual;
["AEX_reduce #2", 45, [_data, { _r + _x }, 0] call AEX_reduce] call _fnc_assertEqual;
["AEX_reduce #3", 600, [[1,2,3,4,5], { _r * _x }, 5] call AEX_reduce] call _fnc_assertEqual;
["AEX_reduce #4", 1, [_data, { _r min _x }] call AEX_reduce] call _fnc_assertEqual;
["AEX_reduce #5", 9, [_data, { _r max _x }] call AEX_reduce] call _fnc_assertEqual;

["AEX_take #1", [1,2,3], [_data, 3] call AEX_take] call _fnc_assertEqual;
["AEX_take #2", [3,4,5], [_data, 3, 2] call AEX_take] call _fnc_assertEqual;
["AEX_take #3", _data, [_data, 100] call AEX_take] call _fnc_assertEqual;
["AEX_take #4", [5,6,7], [_data, -3, -2] call AEX_take] call _fnc_assertEqual;
["AEX_take #5", _data, [_data, -100] call AEX_take] call _fnc_assertEqual;
["AEX_take #6", [6,7,8,9], [_data, 10, 5] call AEX_take] call _fnc_assertEqual;
["AEX_take #7", [_data, 5, -1] call AEX_take] call _fnc_assertNil;

["AEX_reverse #1", [], [] call AEX_reverse] call _fnc_assertEqual;
["AEX_reverse #2", [9,8,7,6,5,4,3,2,1], _data call AEX_reverse] call _fnc_assertEqual;
["AEX_reverse #3", [1,2,3], [3,2,1] call AEX_reverse] call _fnc_assertEqual;

["AEX_contains #1", [_data, 123] call AEX_contains] call _fnc_assertFalse;
["AEX_contains #2", [_data, 5] call AEX_contains] call _fnc_assertTrue;
["AEX_contains #3", [_data, 1] call AEX_contains] call _fnc_assertTrue;
["AEX_contains #4", [_data, 9] call AEX_contains] call _fnc_assertTrue;
["AEX_contains #5", [[1,2,3], "2", { _a == parseNumber _b }] call AEX_contains] call _fnc_assertTrue;
["AEX_contains #6", [[1,2,3], "5", { _a == parseNumber _b }] call AEX_contains] call _fnc_assertFalse;

["AEX_equals #1", [[], []] call AEX_equals] call _fnc_assertTrue;
["AEX_equals #2", [_data, _data] call AEX_equals] call _fnc_assertTrue;
["AEX_equals #3", [[1,2,3], [1,2,3]] call AEX_equals] call _fnc_assertTrue;
["AEX_equals #4", [[1,2,3], [3,2,1]] call AEX_equals] call _fnc_assertFalse;
["AEX_equals #5", [[1,2,3], ["1","2","3"], { _a == parseNumber _b }] call AEX_equals] call _fnc_assertTrue;
["AEX_equals #6", [[], [], AEX_equal_deep] call AEX_equals] call _fnc_assertTrue;
["AEX_equals #7", [_data, _data, AEX_equal_deep] call AEX_equals] call _fnc_assertTrue;
["AEX_equals #8", [[[1,2,3]], [[1,2,3]], AEX_equal_deep] call AEX_equals] call _fnc_assertTrue;
["AEX_equals #9", [[[1,2],[3,4,5],[6],[]], [[1,2],[3,4,5],[6],[]], AEX_equal_deep] call AEX_equals] call _fnc_assertTrue;
["AEX_equals #10", [[[1,2],[5,4,3]], [[1,2],[3,4,5]], AEX_equal_deep] call AEX_equals] call _fnc_assertFalse;
["AEX_equals #11", [[[1,2],[5,4,3]], [[1,2],[3,4]], AEX_equal_deep] call AEX_equals] call _fnc_assertFalse;

["AEX_distinct #1", [], [[]] call AEX_distinct] call _fnc_assertEqual;
["AEX_distinct #2", _data, [_data] call AEX_distinct] call _fnc_assertEqual;
["AEX_distinct #3", _data, [_data + _data] call AEX_distinct] call _fnc_assertEqual;
["AEX_distinct #4", [1,2,3,5,4,6], [[1,2,2,1,3,5,4,6,4]] call AEX_distinct] call _fnc_assertEqual;
["AEX_distinct #5", ["a","b","c"], [["a","b","c","b","a"]] call AEX_distinct] call _fnc_assertEqual;

["AEX_sort #1", [], [[]] call AEX_sort] call _fnc_assertEqual;
["AEX_sort #2", [5], [[5]] call AEX_sort] call _fnc_assertEqual;
["AEX_sort #3", [1,2,3,4,5,6,7,8,9], [[1,2,3,4,5,6,7,8,9]] call AEX_sort] call _fnc_assertEqual;
["AEX_sort #4", [1,2,3], [[3,2,1]] call AEX_sort] call _fnc_assertEqual;
["AEX_sort #5", [1,2,3,4,5,6,7,8,9], [[5,7,9,2,6,1,3,8,4]] call AEX_sort] call _fnc_assertEqual;
["AEX_sort #6", [9,8,7,6,5,4,3,2,1], [[9,8,7,6,5,4,3,2,1], AEX_order_desc] call AEX_sort] call _fnc_assertEqual;
["AEX_sort #7", [9,8,7,6,5,4,3,2,1], [[1,2,3,4,5,6,7,8,9], AEX_order_desc] call AEX_sort] call _fnc_assertEqual;
["AEX_sort #8", [9,8,7,6,5,4,3,2,1], [[5,7,9,2,6,1,3,8,4], AEX_order_desc] call AEX_sort] call _fnc_assertEqual;
["AEX_sort #9", ["1","2","3","4","5"], [["3","5","1","4","2"], AEX_order_asc, { parseNumber _x }] call AEX_sort] call _fnc_assertEqual;

// real examples
private ["_vehicles","_vehicleData","_nearEntities","_players","_playerData","_damage"];

// vehicles with at least 10% damage are mapped to an data array like [vehicle type, position, damage]
_vehicles = [vehicles, { damage _x > .1 }] call AEX_filter;
_vehicleData = [_vehicles, { [typeOf _x, position _x, damage _x] }] call AEX_map;
diag_log ["AEX damaged vehicles", _vehicles, _vehicleData];
// ["AEX damaged vehicles",[209f6080# 1056396: ah6x.p3d REMOTE,248de080# 1055939: hmmwv.p3d REMOTE,256ab040# 1055991: gnt_c185.p3d REMOTE],[["AH6X_DZ",[10473.1,8864.83,0.0306244],0.334646],["HMMWV_DZ",[11219.5,12499.5,-0.0309296],0.204724],["GNT_C185U",[12776.4,5338.54,0.13018],0.649606]]]

// list of player names and distance within 100m of the player who own a toolbox
_nearEntities = player nearEntities 100;
_players = [_nearEntities, { isPlayer _x and "ItemToolbox" in items _x }] call AEX_filter;
_playerData = [_players, { [name _x, player distance _x] }] call AEX_map;
diag_log ["AEX near players with toolbox", _players, _playerData];
// ["AEX near players with toolbox",[B 1-1-B:1 (Axe Cop), C 1-2-C:3 (Player 2)],[["Axe Cop",0],["Axe Cop",0],["Player 2",13.565]]]

// overall damage of all units
_damage = [allUnits, { _r + damage _x }, 0] call AEX_reduce;
diag_log ["AEX overall damage of all units", _damage];
// ["AEX overall damage of all units",2.457]
