--[[**********************************************
**				Auto Salvager (AS)				**
**					By 	Xiij					**
**********************************************--]]
--[[**********************************************
**												**
**	Auto Salvager (AS) automatically salvages	**
**	certain loots intended for salvaging.		**
**												**
**	Change Log:									**
**												**
**	Version 0.0.3:								**
**		-Added new salvage items				**
**												**
**	Version 0.0.2:								**
**		-fixed an issue where salvaging would	**
**			trigger AS display frame			**
**		-fixed an issue where AS display frame	**
**			would clear quicker than intended.	**
**												**
**	Version 0.0.1a:								**
**		-fixed bug where salvage wouldn't		**
**			complete							**
**												**
**	Version 0.0.1:								**
**		-initial								**
**												**
**********************************************--]]

--[[**********************************************
**					Includes					**
**********************************************--]]

require "string";
require "table";
require "math";
require "lib/lib_InterfaceOptions";
require "lib/lib_Slash";
require "lib/lib_Items";
require "lib/lib_Callback2";
require "./intOpt";
require "./lib/util";

MAIN_FRAME = Component.GetFrame("AS_MAIN");
MAIN_HUD = Component.GetWidget("AS_MAIN_TXT");
InterfaceOptions.AddMovableFrame({
	frame = MAIN_FRAME,
	label = "AS",
	scalable = true,
})

--[[**********************************************
**					Variables					**
**********************************************--]]
local frameTxt;
local currItm;
local cb_salvage;
local cb_clear;
local salvageRequested;

--[[**********************************************
**					Events						**
**********************************************--]]
function OnComponentLoad(args)
	init();
end

function OnPlayerReady(args)
	if (not enabled()) then return end
	if (ShowFrame()) then
		MAIN_FRAME:Show();
	end
end

function OnSalvageResponse(args)
	if (not enabled()) then return end
	Debug('F', "AS received OnSalvageResponse");
	if (not salvageRequested) then return end
	if (#args > 0) then
		Debug('T', "Salvage success, claiming rewards");
		claim();
		for _, loot in ipairs(args) do
			lootInfo = Game.GetItemInfoByType(loot.item_sdb_id)
			updateInfo(lootInfo.name.." : "..loot.quantity);
		end
	end
end

function OnLootCollected(args)
	if (not enabled()) then return end
	if (tonumber(args.lootedToId) ~= tonumber(Player.GetCharacterId())) then return end
	Debug('F', "AS received OnLootCollected");
	if ((tonumber(args.itemTypeId) == 52206) and (AutoSalvageRCT()))then --was recovered chosen tech
		Debug('T', "RCT collected");
		salvage(args.itemTypeId);
	elseif ((tonumber(args.itemTypeId) == 30408) and (AutoSalvageBBG())) then --was broken bandit gear
		Debug('T', "BBG collected");
		salvage(args.itemTypeId);
	elseif ((tonumber(args.itemTypeId) == 86398) and (AutoSalvageHDM())) then --was half digested module
		Debug('T', "HDM collected");
		salvage(args.itemTypeId);
	elseif ((tonumber(args.itemTypeId) == 86404) and (AutoSalvageCT())) then --was chosen tech
		Debug('T', "CT collected");
		salvage(args.itemTypeId);
	elseif ((tonumber(args.itemTypeId) == 77418) and (AutoSalvageDCP())) then --was damaged cycle plating
		Debug('T', "DCP collected");
		salvage(args.itemTypeId);
	elseif ((tonumber(args.itemTypeId) == 77419) and (AutoSalvageDDCB())) then --was damaged drive circuit board
		Debug('T', "DDCB collected");
		salvage(args.itemTypeId);
	elseif ((tonumber(args.itemTypeId) == 77420) and (AutoSalvageDIDS())) then --was damaged ignition drive system
		Debug('T', "DIDS collected");
		salvage(args.itemTypeId);
	end
end
--[[**********************************************
**					Functions					**
**********************************************--]]
--Initializes variables
function init()
	init_InterfaceOptions();
	frameTxt = "";
	currItm = nil;
	cb_salvage = nil;
	cb_clear = nil;
	salvageRequested = false;
end

function updateFrame()
	MAIN_HUD:SetText(frameTxt);
end

function updateInfo(update)
	if (not ShowFrame()) then return end
	if (frameTxt ~= "") then
		frameTxt = frameTxt.."\n"..update;
	else
		frameTxt = update;
	end
	timer = tonumber(getFrameTimer());
	if (timer > 0) then
		if (cb_clear == nil) then
			cb_clear = callback(clearInfo, nil, timer);
		else
			cancel_callback(cb_clear);
			cb_clear = callback(clearInfo, nil, timer);
		end
	end
	updateFrame();
end

function clearInfo()
	if (not ShowFrame()) then return end
	frameTxt = "";
	if (cb_clear ~= nil) then
		cancel_callback(cb_clear);
		cb_clear = nil;
	end
	updateFrame();
end

function salvage(id)
	currItm = id;
	Player.RequestSalvageResource(id, 1, 0);
	if (cb_salvage == nil) then
		clearInfo();
		updateInfo("Salvaging: "..Game.GetItemInfoByType(id).name);
		cb_salvage = callback(salvage, id, 1);
		salvageRequested = true;
	end
end

function claim()
	if (currItm ~=nil) then
		Debug('T', "Claiming "..tostring(currItem));
		cancel_callback(cb_salvage);
		cb_salvage = nil;
		Player.ClaimSalvageResourceRewards(currItm, 1, 0)
		clearInfo();
		updateInfo("Rewards from: "..Game.GetItemInfoByType(currItm).name);
		currItm = nil;
		salvageRequested = false;
	end
end
--[[**********************************************
**					Notes						**
**********************************************--]]