if (isNil "BD_vehicles") then {BD_vehicles = true;};
BaseDestructionMenu = 
[
	["Base Destruction",true],
		["Set Center", [2], "", -5, [["expression", '["center"] execVM "basedestruction.sqf"']], "1", "1"],
		["Set Radius", [3], "", -5, [["expression", '["radius"] execVM "basedestruction.sqf"']], "1", "1"],
		["Show Dome", [4], "", -5, [["expression", '["dome"] execVM "basedestruction.sqf"']], "1", "1"],
		[format["Include Vehicles (%1)",BD_vehicles], [5], "", -5, [["expression", "BD_vehicles = !BD_vehicles;"]], "1", "1"],
		["DESTROY ALL INSIDE DOME", [6], "", -5, [["expression", '["destroy"] execVM "basedestruction.sqf"']], "1", "1"],
		["", [-1], "", -5, [["expression", ""]], "1", "0"],
			["Exit", [13], "", -3, [["expression", ""]], "1", "1"]
];

//["Base Destruction", [5], "#USER:BaseDestructionMenu", -5, [["expression", ""]], "1", "1"],
showCommandingMenu "#USER:BaseDestructionMenu";
