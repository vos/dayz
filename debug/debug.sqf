// client
if (!isDedicated) then {
	DT_openKey = 0x4A; // - on numeric keypad
	
	DT_fnc_log = {
		DT_logMessage = format ["%1", _this];
		publicVariableServer "DT_logMessage";
	};
	
	DT_fnc_openDialog = {
		createDialog "RscDebugDialog";
		if (!isNil "DT_scriptText") then {
			ctrlSetText [7851, DT_scriptText];
		};
	};
	
	DT_fnc_displayResult = {
		private "_res";
		_res = _this;
		if (!dialog) then {
			call DT_fnc_openDialog;
		};
		ctrlSetText [7852, format ["%1", _res]];
	};
	
	DT_fnc_exec = {
		private ["_code","_res"];
		DT_scriptText = ctrlText 7851;
		_code = compile DT_scriptText;
		_res = call _code;
		_res call DT_fnc_displayResult;
	};
	
	DT_fnc_remoteExec = {
		DT_scriptText = ctrlText 7851;
		DT_remoteExec = [DT_scriptText, player];
		publicVariableServer "DT_remoteExec";
	};
	
	"DT_execResult" addPublicVariableEventHandler { (_this select 1) spawn DT_fnc_displayResult; };
	
	[] spawn {
		waitUntil { !isNull (findDisplay 46) };
		(findDisplay 46) displayAddEventHandler ["KeyDown", "if ((_this select 1) == DT_openKey) then { call DT_fnc_openDialog; };"];
	};
};

// server
if (isServer) then {
	DT_fnc_log = {
		"jni" callExtension format ["LOG:%1", _this];
	};
	
	DT_fnc_exec = {
		private ["_scriptText","_player","_code"];
		_scriptText = _this select 0;
		_player = _this select 1;
		_code = compile _scriptText;
		DT_execResult = call _code;
		(owner _player) publicVariableClient "DT_execResult";
	};
	
	"DT_logMessage" addPublicVariableEventHandler { (_this select 1) spawn DT_fnc_log; };
	"DT_remoteExec" addPublicVariableEventHandler { (_this select 1) spawn DT_fnc_exec; };
};

diag_log "debug tools loaded";
