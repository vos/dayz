private ["_option","_location","_object","_objects","_objectClasses","_i","_dir","_objectID","_objectUID"];

// global vars
//if (isNil "BD_center") then { BD_center = [0,0,0]; };
if (isNil "BD_radius") then { BD_radius = 10; };

_option = _this select 0;
switch (_option) do {
	case "center": {
		BD_center = getPos player;
		cutText [format["center set to %1", BD_center], "PLAIN DOWN"];
	};
	case "radius": {
		if (isNil "BD_center") then {
			cutText ["center not set", "PLAIN DOWN"];
		} else {
			BD_radius = player distance BD_center;
			cutText [format["radius set to %1 m", BD_radius], "PLAIN DOWN"];
		};
	};
	case "dome": {
		if (isNil "BD_center") then {
			cutText ["center not set", "PLAIN DOWN"];
		} else {
			_objects = [];
			// center
			_object = createVehicle ["Plastic_Pole_EP1_DZ", BD_center, [], 0, "CAN_COLLIDE"];
			_objects set [0, _object];
			// circle
			for "_i" from 0 to 360 step (270 / BD_radius) do {
				_location = [(BD_center select 0) + ((cos _i) * BD_radius), (BD_center select 1) + ((sin _i) * BD_radius), BD_center select 2];
				_object = createVehicle ["WoodLargeWall_Preview_DZ", _location, [], 0, "CAN_COLLIDE"];
				_dir = ((BD_center select 0) - (_location select 0)) atan2 ((BD_center select 1) - (_location select 1)); 
				_object setDir _dir;
				_objects set [count _objects, _object];
			};
			// top
			_location = [BD_center select 0, BD_center select 1, (BD_center select 2) + BD_radius];
			_object = createVehicle ["WoodFloor_Preview_DZ", _location, [], 0, "CAN_COLLIDE"];
			_objects set [count _objects, _object];
			sleep 30;
			{
				deleteVehicle _x;
			} forEach _objects;
		};
	};
	case "destroy": {
		if (isNil "BD_center") then {
			cutText ["center not set", "PLAIN DOWN"];
		} else {
			if (BD_radius > 100) then {
				cutText [format["area is to large for base destruction (radius %1 > 100)", BD_radius], "PLAIN DOWN"];
			} else {
				_objectClasses = ["TentStorage","TentStorageDomed","TentStorageDomed2","Hedgehog_DZ","Sandbag1_DZ","TrapBear","Fort_RazorWire","WoodGate_DZ","Land_HBarrier1_DZ","Land_HBarrier3_DZ","Fence_corrugated_DZ","M240Nest_DZ","CanvasHut_DZ","ParkBench_DZ","MetalGate_DZ","OutHouse_DZ","Wooden_shed_DZ","WoodShack_DZ","StorageShed_DZ","Plastic_Pole_EP1_DZ","Generator_DZ","StickFence_DZ","LightPole_DZ","FuelPump_DZ","DesertCamoNet_DZ","ForestCamoNet_DZ","DesertLargeCamoNet_DZ","ForestLargeCamoNet_DZ","SandNest_DZ","DeerStand_DZ","MetalPanel_DZ","WorkBench_DZ","WoodFloor_DZ","WoodLargeWall_DZ","WoodLargeWallDoor_DZ","WoodLargeWallWin_DZ","WoodSmallWall_DZ","WoodSmallWallWin_DZ","WoodSmallWallDoor_DZ","WoodFloorHalf_DZ","WoodFloorQuarter_DZ","WoodStairs_DZ","WoodStairsSans_DZ","WoodSmallWallThird_DZ","WoodLadder_DZ","Land_DZE_GarageWoodDoor","Land_DZE_LargeWoodDoor","Land_DZE_WoodDoor","Land_DZE_GarageWoodDoorLocked","Land_DZE_LargeWoodDoorLocked","Land_DZE_WoodDoorLocked","CinderWallHalf_DZ","CinderWall_DZ","CinderWallDoorway_DZ","CinderWallDoor_DZ","CinderWallDoorLocked_DZ","CinderWallSmallDoorway_DZ","CinderWallDoorSmall_DZ","CinderWallDoorSmallLocked_DZ","MetalFloor_DZ","WoodRamp_DZ"];
				if (BD_vehicles) then {
					_objectClasses = _objectClasses + ["LandVehicle","Helicopter","Plane","Ship"];
				};
				_objects = nearestObjects [BD_center, _objectClasses, BD_radius];
				_i = 0;
				{
					if (alive _x) then {
						_x setDamage 1;
						deleteVehicle _x;
						//_objectID = _x getVariable ["ObjectID", "0"];
						//_objectUID = _x getVariable ["ObjectUID", "0"];
						//PVDZE_obj_Delete = [_objectID, _objectUID, player];
						//publicVariableServer "PVDZE_obj_Delete";
						_i = _i + 1;
					};
				} forEach _objects;
				cutText [format["%1 of %2 objects destroyed and deleted", _i, count _objects], "PLAIN DOWN"];
			};
		};
	};
};
