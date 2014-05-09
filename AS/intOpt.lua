--[[**********************************************
**					intOpt						**
**					By 	Xiij					**
**********************************************--]]
--[[**********************************************
**												**
**	intOpt is a set of functions which			**
**	initialize interface options and tracks		**
**	changes made to the interface options.		**
**												**
**	Change Log:									**
**												**
**	Version 0.0.1:								**
**		-initial								**
**												**
**********************************************--]]
--[[**********************************************
**					Variables					**
**********************************************--]]

--Whether the addon is enabled or not
local ENABLE;
--Whether debug is enabled
local DBG_STS;
--What level of debug is enabled
local DBG_LVL;
--Whether recovered chosen tech are auto salvaged
local AS_RCT;
--Whether broken bandit gear are auto salvaged
local AS_BBG;
--Whether half digested modules are auto salvaged
local AS_HDM;
--Whether chosen tech are auto salvaged
local AS_CT;
--Whether damaged cycle plating are auto salvaged
local AS_DCP;
--Whether damaged drive circuit board are auto salvaged
local AS_DDCB;
--Whether damaged ignition drive system are auto salvaged
local AS_DIDS;
--Whether the display frame is on or not
local USE_FRAME;
--How long AS waits to clear the display frame
local FRAME_TIMER;

--[[**********************************************
**					Functions					**
**********************************************--]]
--Initializes interface options
function init_InterfaceOptions()
	InterfaceOptions.AddCheckBox({id="ENABLE_ADDON", label="Enable", tooltip="Enables AS", default=true})
	
	InterfaceOptions.StartGroup({id="FRAME", label="Display Frame Options", checkbox=true, default=false})
	InterfaceOptions.AddCheckBox({id="USE_FRAME", label="Use Display Frame", tooltip="Use Display Frame to show activity.", default=true})
	InterfaceOptions.AddSlider({id="FRAME_TIMER", label="Frame Display Time", tooltip="The amount of time before the display frame is cleared. 0 always shows the frame.", default=30, min=0, max=60, inc=1})
	InterfaceOptions.StopGroup()

	InterfaceOptions.StartGroup({id="AS", label="Auto Salvage", checkbox=true, default=false})
	InterfaceOptions.AddCheckBox({id="AS_RCT", label="Recovered Chosen Tech", tooltip="Whether or not Recovered Chosen Techs are auto-salvaged.", default=true})
	InterfaceOptions.AddCheckBox({id="AS_BBG", label="Broken Bandit Gear", tooltip="Whether or not Broken Bandit Gear are auto-salvaged.", default=true})
	InterfaceOptions.AddCheckBox({id="AS_HDM", label="Half Digested Modules", tooltip="Whether or not Half Digested Modules are auto-salvaged.", default=true})
	InterfaceOptions.AddCheckBox({id="AS_CT", label="Chosen Tech", tooltip="Whether or not Chosen Techs are auto-salvaged.", default=true})
	InterfaceOptions.AddCheckBox({id="AS_DCP", label="Damaged Cycle Plating", tooltip="Whether or not Damaged Cycle Platings are auto-salvaged.", default=true})
	InterfaceOptions.AddCheckBox({id="AS_DDCB", label="Damaged Drive Circuit Board", tooltip="Whether or not Damaged Drive Circuit Boards are auto-salvaged.", default=true})
	InterfaceOptions.AddCheckBox({id="AS_DIDS", label="Damaged Ignition Drive System", tooltip="Whether or not Damaged Ignition Drives are auto-salvaged.", default=true})
	InterfaceOptions.StopGroup()
	InterfaceOptions.StartGroup({id="DEBUG", label="Debug Options", checkbox=true, default=false})
		InterfaceOptions.AddSlider({id="DBG_STS_SLIDER", label="Debug Status", tooltip="This determines whether or not debugging is on.  0 is off, 1 is logs only, 2 is system messages and logs.", default=0, min=0, max=2, inc=1})
		InterfaceOptions.AddSlider({id="DBG_LVL_SLIDER", label="Debug Level", tooltip="This determines what level of debugging is on. 0 is error only, 1 is warn, 2 is trace, and 3 is fine.", default=0, min=0, max=3, inc=1})
	InterfaceOptions.StopGroup()
--Set the OnMessage function as a callback to handle any IO changes
	InterfaceOptions.SetCallbackFunc(function(id, val)
        OnMessage({type=id, data=val})
    end, "AS")
end

function OnMessage(args)
	Debug('F', "AS received OnMessage");
	Debug('F', tostring(args));
	
	if args.type == "ENABLE_ADDON" then
		ENABLE = args.data;
		Component.SaveSetting("ENABLE", ENABLE);
	elseif (ENABLE) then
		if args.type == "USE_FRAME" then
			USE_FRAME = args.data;
			if (USE_FRAME) then
				MAIN_FRAME:Show();
			else
				MAIN_FRAME:Hide();
			end
		elseif args.type == "FRAME_TIMER" then
			FRAME_TIMER = tonumber(args.data);
		elseif args.type == "AS_RCT" then
			AS_RCT = args.data;
		elseif args.type == "AS_BBG" then
			AS_BBG = args.data;
		elseif args.type == "AS_HDM" then
			AS_HDM = args.data;
		elseif args.type == "AS_CT" then
			AS_CT = args.data;
		elseif args.type == "AS_DCP" then
			AS_DCP = args.data;
		elseif args.type == "AS_DDCB" then
			AS_DDCB = args.data;
		elseif args.type == "AS_DIDS" then
			AS_DIDS = args.data;
		elseif args.type == "DBG_STS_SLIDER" then
			DBG_STS = args.data;
			init_Debug(DBG_STS, DBG_LVL);
		elseif args.type == "DBG_LVL_SLIDER" then
			DBG_LVL = args.data;
			init_Debug(DBG_STS, DBG_LVL);
		end
	end
	showOptions();
end

function showOptions()
	InterfaceOptions.DisableOption("AS", not ENABLE);
	InterfaceOptions.DisableOption("DEBUG", not ENABLE);
	InterfaceOptions.DisableOption("FRAME", not ENABLE);
	InterfaceOptions.DisableOption("DBG_LVL_SLIDER", (DBG_STS == 0));
	InterfaceOptions.DisableOption("FRAME_TIMER", not USE_FRAME);
end

function enabled()
	return ENABLE;
end

function AutoSalvageRCT()
	return AS_RCT;
end

function AutoSalvageBBG()
	return AS_BBG;
end

function AutoSalvageHDM()
	return AS_HDM;
end

function AutoSalvageCT()
	return AS_CT;
end

function AutoSalvageDCP()
	return AS_DCP;
end

function AutoSalvageDDCB()
	return AS_DDCB;
end

function AutoSalvageDIDS()
	return AS_DIDS;
end

function ShowFrame()
	return USE_FRAME;
end

function getFrameTimer()
	return FRAME_TIMER;
end
--[[**********************************************
**					Notes						**
**********************************************--]]