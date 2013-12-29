class RscDebug
{
	idc = -1;
	type = 0;
	style = 0;
	x = 0;
	y = 0;
	w = 1;
	h = 1;
	sizeEx = 0.03921;
	font = "Zeppelin32";
	colorText[] = {1,1,1,1};
	colorBackground[] = {0,0,0,0};
	text = "";
	shadow = 0;
};

class RscDebugBackground : RscDebug
{
	colorBackground[] = {0,0,0,0.7};
	fixedWidth = 0;
};

class RscDebugText : RscDebug
{
	w = 0.3;
	h = 0.037;
	shadow = 2;
	fixedWidth = 0;
};

class RscDebugEdit : RscDebug
{
	type = 2;
	style = "0x00 + 0x08 + 16 + 64";
	w = 0.3;
	h = 0.037;
	font = "TahomaB";
	autocomplete = "scripting";
	lineSpacing = 1;
	colorSelection[] = {1,1,1,0.25};
};

class RscDebugButton : RscDebug
{
	type = 16;
	x = 0.1;
	y = 0.1;
	w = 0.183825;
	h = 0.104575;
	class HitZone
	{
		left = 0.004;
		top = 0.029;
		right = 0.004;
		bottom = 0.029;
	};
	class ShortcutPos
	{
		left = 0.0145;
		top = 0.026;
		w = 0.0392157;
		h = 0.0522876;
	};
	class TextPos
	{
		left = 0.05;
		top = 0.034;
		right = 0.005;
		bottom = 0.005;
	};
	shortcuts[] = {};
	textureNoShortcut = "#(argb,8,8,3)color(0,0,0,0)";
	color[] = {0.8784,0.8471,0.651,1};
	color2[] = {0.95,0.95,0.95,1};
	colorDisabled[] = {1,1,1,0.25};
	colorBackground[] = {1,1,1,1};
	colorBackground2[] = {1,1,1,0.4};
	class Attributes
	{
		font = "Zeppelin32";
		color = "#E5E5E5";
		align = "left";
		shadow = "true";
	};
	default = 0;
	shadow = 2;
	periodFocus = 1.2;
	periodOver = 0.8;
	animTextureNormal = "\ca\ui\data\ui_button_normal_ca.paa";
	animTextureDisabled = "\ca\ui\data\ui_button_disabled_ca.paa";
	animTextureOver = "\ca\ui\data\ui_button_over_ca.paa";
	animTextureFocused = "\ca\ui\data\ui_button_focus_ca.paa";
	animTexturePressed = "\ca\ui\data\ui_button_down_ca.paa";
	animTextureDefault = "\ca\ui\data\ui_button_default_ca.paa";
	period = 0.4;
	size = 0.03921;
	soundEnter[] = {"\ca\ui\data\sound\onover",0.09,1};
	soundPush[] = {"\ca\ui\data\sound\new1",0,0};
	soundClick[] = {"\ca\ui\data\sound\onclick",0.07,1};
	soundEscape[] = {"\ca\ui\data\sound\onescape",0.09,1};
	action = "";
	class AttributesImage
	{
		font = "Zeppelin32";
		color = "#E5E5E5";
		align = "left";
	};
};

class RscDebugDialog
{
	idd = -1;
	movingEnable = 1;
	
	onLoad = "uiNamespace setVariable ['DebugDialog', _this select 0];";

	class ControlsBackground
	{
		class DebugBackground: RscDebugBackground
		{
			moving = 1;
			x = 0.19 * safezoneW + safezoneX;
			y = 0.535 * safezoneH + safezoneY;
			w = 0.52 * safezoneW;
			h = 0.4 * safezoneH;
		};
	};
	
	class Controls
	{
		class ScriptEdit: RscDebugEdit
		{
			idc = 7851;
			x = 0.2 * safezoneW + safezoneX;
			y = 0.55 * safezoneH + safezoneY;
			w = safezoneW * 0.5;
			h = 0.3 * safezoneH;
			text = "";
		};
		class ExecButton: RscDebugButton
		{
			x = 0.2 * safezoneW + safezoneX;
			y = 0.85 * safezoneH + safezoneY;
			w = 0.16;
			text = "Exec";
			action = "call DT_fnc_exec;";
		};
		class RemoteExecButton: RscDebugButton
		{
			x = 0.26 * safezoneW + safezoneX;
			y = 0.85 * safezoneH + safezoneY;
			w = 0.24;
			text = "Remote Exec";
			action = "call DT_fnc_remoteExec;";
		};
		class ScriptResultText: RscDebugText
		{
			idc = 7852;
			x = 0.2 * safezoneW + safezoneX;
			y = 0.9 * safezoneH + safezoneY;
			w = safezoneW * 0.5;
			colorBackground[] = {0,0,0,0.4};
			text = "";
		};
	};
};
