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
	if (currItem == nil) then return end
	Debug('F', "AS received OnSalvageResponse");
	if (#args > 0) then
		Debug('T', "Salvage success, claiming rewards");
		claim();
		for _, loot in ipairs(args) do
			lootInfo = Game.GetItemInfoByType(loot.item_sdb_id)
			updateInfo(lootInfo.name.." : "..loot.quantity);
		end
	else
		Debug('W', "Salvage failed, retrying");
		salvage(currItm);
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
		cb_clear = callback(clearInfo, nil, timer);
	end
	updateFrame();
end

function clearInfo()
	if (not ShowFrame()) then return end
	frameTxt = "";
	if (cb_clear ~= nil) then
		cancel_callback(cb_clear);
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
	end
end
--[[**********************************************
**					Notes						**
**********************************************--]]