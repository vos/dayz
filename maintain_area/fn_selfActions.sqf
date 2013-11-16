// ---------------------------------------Maintain Area Start------------------------------------
if (_canDo && (speed player <= 1) && (cursorTarget isKindOf "Plastic_Pole_EP1_DZ")) then {
	if (s_player_maintain_area < 0) then {
		s_player_maintain_area = player addAction ["<t color=""#ffffff"">Maintain Area</t>", "scripts\maintain_area.sqf", "maintain", 5, false];
		s_player_maintain_area_preview = player addAction ["<t color=""#ccffffff"">Maintain Area Preview</t>", "scripts\maintain_area.sqf", "preview", 5, false];
	};
} else {
	player removeAction s_player_maintain_area;
	s_player_maintain_area = -1;
	player removeAction s_player_maintain_area_preview;
	s_player_maintain_area_preview = -1;
};
// ---------------------------------------Maintain Area End------------------------------------
