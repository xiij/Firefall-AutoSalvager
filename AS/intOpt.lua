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
--Whether auto salvage by quality is enabled
local AS_QUAL_ENABLE;
--The thresh below a certain quality are auto salvaged
local AS_QUAL;
--Whether auto salvage by prestige is enabled
local AS_PRES_ENABLE;
--Whether items below a certain prestige are auto salvaged
local AS_PRES;
--Whether the display frame is on or not
local USE_FRAME;
--How long AS waits to clear the display frame
local FRAME_TIMER;
--Whether the session frame is on or not
local USE_SES_FRAME;
--Whether auto salvage by frame type is enabled
local AS_FRAME_ENABLE;
--Whether common frame items are auto salvaged
local AS_FRAME_CMN;
--Whether Assault items are auto salvaged
local AS_FRAME_AA;
--Whether Firecat items are auto salvaged
local AS_FRAME_FC;
--Whether Tigerclaw items are auto salvaged
local AS_FRAME_TC;
--Whether Engineer items are auto salvaged
local AS_FRAME_AE;
--Whether Electron items are auto salvaged
local AS_FRAME_EL;
--Whether Bastion items are auto salvaged
local AS_FRAME_BA;
--Whether Biotech items are auto salvaged
local AS_FRAME_AB;
--Whether Dragonfly items are auto salvaged
local AS_FRAME_DF;
--Whether Recluse items are auto salvaged
local AS_FRAME_RE;
--Whether Dreadnaught items are auto salvaged
local AS_FRAME_AD;
--Whether Mammoth items are auto salvaged
local AS_FRAME_MM;
--Whether Rhino items are auto salvaged
local AS_FRAME_RN;
--Whether Arsenal items are auto salvaged
local AS_FRAME_ARS;
--Whether Recon items are auto salvaged
local AS_FRAME_AR;
--Whether Nighthawk items are auto salvaged
local AS_FRAME_NH;
--Whether Raptor items are auto salvaged
local AS_FRAME_RA;
--Whether auto salvager uses AND or OR to determine if equipment should be auto salvaged
local AS_LOGIC;

--[[**********************************************
**					Functions					**
**********************************************--]]
--Initializes interface options
function init_InterfaceOptions()
	InterfaceOptions.AddCheckBox({id="ENABLE_ADDON", label="Enable", tooltip="Enables AS", default=true})
	InterfaceOptions.AddChoiceMenu({id="AS_LOGIC", label="Equipment Auto Salvage Logic Operator", default="and", tooltip="Whether equipment auto salvage rules should be logically AND'd or OR'd when deciding to auto salvage battleframe equipment."})
	InterfaceOptions.AddChoiceEntry({menuId="AS_LOGIC", val="and", label="AND"})
	InterfaceOptions.AddChoiceEntry({menuId="AS_LOGIC", val="or", label="OR"})
	
	InterfaceOptions.StartGroup({id="FRAME", label="Frame Options", checkbox=true, default=false})
	InterfaceOptions.AddCheckBox({id="USE_FRAME", label="Use Display Frame", tooltip="Use Display Frame to show activity.", default=true})
	InterfaceOptions.AddSlider({id="FRAME_TIMER", label="Frame Display Time", tooltip="The amount of time before the display frame is cleared. 0 always shows the frame.", default=30, min=0, max=60, inc=1})
	InterfaceOptions.AddCheckBox({id="USE_SES_FRAME", label="Use Session Frame", tooltip="Use Session Frame to show session activity.", default=true})
	InterfaceOptions.StopGroup()

	InterfaceOptions.StartGroup({id="AS_SALV_MENU", label="Salvage Auto Salvage Options", checkbox=true, default=false})
	InterfaceOptions.AddCheckBox({id="AS_RCT", label="Recovered Chosen Tech", tooltip="Whether or not Recovered Chosen Techs are auto-salvaged.", default=true})
	InterfaceOptions.AddCheckBox({id="AS_BBG", label="Broken Bandit Gear", tooltip="Whether or not Broken Bandit Gear are auto-salvaged.", default=true})
	InterfaceOptions.AddCheckBox({id="AS_HDM", label="Half Digested Modules", tooltip="Whether or not Half Digested Modules are auto-salvaged.", default=true})
	InterfaceOptions.AddCheckBox({id="AS_CT", label="Chosen Tech", tooltip="Whether or not Chosen Techs are auto-salvaged.", default=true})
	InterfaceOptions.AddCheckBox({id="AS_DCP", label="Damaged Cycle Plating", tooltip="Whether or not Damaged Cycle Platings are auto-salvaged.", default=true})
	InterfaceOptions.AddCheckBox({id="AS_DDCB", label="Damaged Drive Circuit Board", tooltip="Whether or not Damaged Drive Circuit Boards are auto-salvaged.", default=true})
	InterfaceOptions.AddCheckBox({id="AS_DIDS", label="Damaged Ignition Drive System", tooltip="Whether or not Damaged Ignition Drives are auto-salvaged.", default=true})
	InterfaceOptions.StopGroup()
	
	InterfaceOptions.StartGroup({id="AS_QUAL_MENU", label="Quality Auto Salvage Options", checkbox=true, default=false})
	InterfaceOptions.AddCheckBox({id="AS_QUAL_ENABLE", label="Enable Quality Auto Salvage", tooltip="Whether or not items below the quality threshold auto-salvaged.", default=false})
	InterfaceOptions.AddSlider({id="AS_QUAL", label="Quality Threshold", tooltip="This determines what the quality threshold for auto salvaging is.  Items less than or equal to the threshold will be salvaged.", default=0, min=0, max=1000, inc=1})
	InterfaceOptions.StopGroup()
	
	InterfaceOptions.StartGroup({id="AS_PRES_MENU", label="Prestige Auto Salvage Options", checkbox=true, default=false})
	InterfaceOptions.AddCheckBox({id="AS_PRES_ENABLE", label="Enable Prestige Auto Salvage", tooltip="Whether or not items below the prestige threshold auto-salvaged.", default=false})
	InterfaceOptions.AddSlider({id="AS_PRES", label="Prestige Threshold", tooltip="This determines what the prestige threshold for auto salvaging is.  Items less than or equal to the threshold will be salvaged.", default=0, min=0, max=14, inc=1})
	InterfaceOptions.StopGroup()
	
	InterfaceOptions.StartGroup({id="AS_FRAME_MENU", label="Frame Auto Salvage Options", checkbox=true, default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_ENABLE", label="Enable Frame Auto Salvage", tooltip="Whether or not items of a certain frame are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_CMN", label="Common", tooltip="Whether or not common items are auto-salvaged. This includes secondary weapons, servos, and jumpjets.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_AA", label="Accord Assault", tooltip="Whether or not Accord Assault items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_FC", label="Firecat", tooltip="Whether or not Firecat items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_TC", label="Tigerclaw", tooltip="Whether or not Tigerclaw items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_AE", label="Accord Engineer", tooltip="Whether or not Accord Engineer items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_EL", label="Electron", tooltip="Whether or not Electron items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_BA", label="Bastion", tooltip="Whether or not Bastion items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_AB", label="Accord Biotech", tooltip="Whether or not Accord Biotech items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_DF", label="Dragonfly", tooltip="Whether or not Dragonfly items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_RE", label="Recluse", tooltip="Whether or not Recluse items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_AD", label="Accord Dreadnaught", tooltip="Whether or not Accord Dreadnaught items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_MM", label="Mammoth", tooltip="Whether or not Mammoth items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_RN", label="Rhino", tooltip="Whether or not Rhino items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_ARS", label="Arsenal", tooltip="Whether or not Arsenal items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_AR", label="Accord Recon", tooltip="Whether or not Accord Recon items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_NH", label="Nighthawk", tooltip="Whether or not Nighthawk items are auto-salvaged.", default=false})
	InterfaceOptions.AddCheckBox({id="AS_FRAME_RA", label="Raptor", tooltip="Whether or not Raptor items are auto-salvaged.", default=false})
	InterfaceOptions.StopGroup()
	
	InterfaceOptions.StartGroup({id="DEBUG", label="Debug Options", checkbox=true, default=false})
		InterfaceOptions.AddSlider({id="DBG_STS_SLIDER", label="Debug Status", tooltip="This determines whether or not debugging is on.  0 is off, 1 is logs only, 2 is system messages and logs.", default=0, min=0, max=2, inc=1})
		InterfaceOptions.AddSlider({id="DBG_LVL_SLIDER", label="Debug Level", tooltip="This determines what level of debugging is on. 0 is error only, 1 is warn, 2 is trace, and 3 is fine.", default=0, min=0, max=3, inc=1})
	InterfaceOptions.StopGroup()
--Set the OnMessage function as a callback to handle any IO changes
	InterfaceOptions.SetCallbackFunc(function(id, val)
        OnMessage({type=id, data=val})
    end, "Auto Salvage")
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
		elseif args.type == "USE_SES_FRAME" then
			USE_SES_FRAME = args.data;
			if (USE_SES_FRAME) then
				SES_FRAME:Show();
			else
				SES_FRAME:Hide();
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
		elseif args.type == "AS_QUAL_ENABLE" then
			AS_QUAL_ENABLE = args.data;
		elseif args.type == "AS_QUAL" then
			AS_QUAL = args.data;
		elseif args.type == "AS_PRES_ENABLE" then
			AS_PRES_ENABLE = args.data;
		elseif args.type == "AS_PRES" then
			AS_PRES = args.data;
		elseif args.type == "AS_FRAME_ENABLE" then
			AS_FRAME_ENABLE = args.data;
		elseif args.type == "AS_FRAME_CMN" then
			AS_FRAME_CMN = args.data;
		elseif args.type == "AS_FRAME_AA" then
			AS_FRAME_AA = args.data;
		elseif args.type == "AS_FRAME_FC" then
			AS_FRAME_FC = args.data;
		elseif args.type == "AS_FRAME_TC" then
			AS_FRAME_TC = args.data;
		elseif args.type == "AS_FRAME_AE" then
			AS_FRAME_AE = args.data;
		elseif args.type == "AS_FRAME_EL" then
			AS_FRAME_EL = args.data;
		elseif args.type == "AS_FRAME_BA" then
			AS_FRAME_BA = args.data;
		elseif args.type == "AS_FRAME_AB" then
			AS_FRAME_AB = args.data;
		elseif args.type == "AS_FRAME_DF" then
			AS_FRAME_DF = args.data;
		elseif args.type == "AS_FRAME_RE" then
			AS_FRAME_RE = args.data;
		elseif args.type == "AS_FRAME_AD" then
			AS_FRAME_AD = args.data;
		elseif args.type == "AS_FRAME_MM" then
			AS_FRAME_MM = args.data;
		elseif args.type == "AS_FRAME_RN" then
			AS_FRAME_RN = args.data;
		elseif args.type == "AS_FRAME_ARS" then
			AS_FRAME_ARS = args.data;
		elseif args.type == "AS_FRAME_AR" then
			AS_FRAME_AR = args.data;
		elseif args.type == "AS_FRAME_NH" then
			AS_FRAME_NH = args.data;
		elseif args.type == "AS_FRAME_RA" then
			AS_FRAME_RA = args.data;
		elseif args.type == "AS_LOGIC" then
			AS_LOGIC = args.data;
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
	InterfaceOptions.DisableOption("AS_SALV_MENU", not ENABLE);
	InterfaceOptions.DisableOption("AS_QUAL_MENU", not ENABLE);
	InterfaceOptions.DisableOption("AS_PRES_MENU", not ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_MENU", not ENABLE);
	InterfaceOptions.DisableOption("DEBUG", not ENABLE);
	InterfaceOptions.DisableOption("FRAME", not ENABLE);
	InterfaceOptions.DisableOption("DBG_LVL_SLIDER", (DBG_STS == 0));
	InterfaceOptions.DisableOption("FRAME_TIMER", not USE_FRAME);
	InterfaceOptions.DisableOption("AS_QUAL", not AS_QUAL_ENABLE);
	InterfaceOptions.DisableOption("AS_PRES", not AS_PRES_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_CMN", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_AA", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_FC", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_TC", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_AE", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_EL", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_BA", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_AB", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_DF", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_RE", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_AD", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_MM", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_RN", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_ARS", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_AR", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_NH", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_FRAME_RA", not AS_FRAME_ENABLE);
	InterfaceOptions.DisableOption("AS_LOGIC", ((not AS_FRAME_ENABLE) and (not AS_QUAL_ENABLE) and (not AS_PRES_ENABLE)));
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

function AutoSalvageQuality()
	if (AS_QUAL_ENABLE) then
		return AS_QUAL;
	else
		return -1;
	end
end

function AutoSalvagePrestige()
	if (AS_PRES_ENABLE) then
		return AS_PRES;
	else
		return -1;
	end
end

function AutoSalvageFrame()
	return AS_FRAME_ENABLE;
end

function AutoSalvageCommonFrame()
	return AS_FRAME_CMN;
end

function AutoSalvageAssault()
	return AS_FRAME_AA;
end

function AutoSalvageFirecat()
	return AS_FRAME_FC;
end

function AutoSalvageTigerclaw()
	return AS_FRAME_TC;
end

function AutoSalvageEngineer()
	return AS_FRAME_AE;
end

function AutoSalvageElectron()
	return AS_FRAME_EL;
end

function AutoSalvageBastion()
	return AS_FRAME_BA;
end

function AutoSalvageBiotech()
	return AS_FRAME_AB;
end

function AutoSalvageDragonfly()
	return AS_FRAME_DF;
end

function AutoSalvageRecluse()
	return AS_FRAME_RE;
end

function AutoSalvageDreadnaught()
	return AS_FRAME_AD;
end

function AutoSalvageMammoth()
	return AS_FRAME_MM;
end

function AutoSalvageRhino()
	return AS_FRAME_RN;
end

function AutoSalvageArsenal()
	return AS_FRAME_ARS;
end

function AutoSalvageRecon()
	return AS_FRAME_AR;
end

function AutoSalvageNighthawk()
	return AS_FRAME_NH;
end

function AutoSalvageRaptor()
	return AS_FRAME_RA;
end

function AutoSalvageLogic()
	return AS_LOGIC;
end

function ShowFrame()
	return USE_FRAME;
end

function getFrameTimer()
	return FRAME_TIMER;
end

function ShowSessionFrame()
	return USE_SES_FRAME;
end
--[[**********************************************
**					Notes						**
**********************************************--]]