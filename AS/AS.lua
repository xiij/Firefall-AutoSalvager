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
**	Version 0.0.5:								**
**		-fixed bug where all equipment was		**
**			being salvaged if all equipment		**
**			based options were disabled.		**
**												**
**	Version 0.0.4:								**
**		-Added session tracker					**
**		-Added AS by quality					**
**		-Added AS by prestige					**
**		-Added AS by frame						**
**		-Added added a logic operator to		**
**			control how multiple AS work		**
**			with one another.					**
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
SES_FRAME = Component.GetFrame("AS_SES");
SES_HUD = Component.GetWidget("AS_SES_TXT");
InterfaceOptions.AddMovableFrame({
	frame = SES_FRAME,
	label = "AS Session",
	scalable = true,
})

--[[**********************************************
**					Variables					**
**********************************************--]]
local frameTxt;
local currItm;
local nextItms;
local cb_salvage;
local cb_clear;
local cb_queue;
local cb_util;
local salvageRequested;
local sesRewards;
local Items;

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
	if (ShowSessionFrame()) then
		SES_FRAME:Show();
	end
end

function OnSalvageResponse(args)
	if (not enabled()) then return end
	if (not salvageRequested) then return end
	if (#args > 1) then
		claim();
		for _, loot in ipairs(args) do
			lootInfo = Game.GetItemInfoByType(loot.item_sdb_id)
			updateInfo(lootInfo.name.." : "..loot.quantity);
			found = false;
			for id,item in pairs(sesRewards) do
				if (tostring(id) == tostring(loot.item_sdb_id)) then
					found = true;
					sesRewards[id].qty = tonumber(sesRewards[id].qty) + tonumber(loot.quantity);
				end
			end
			if (not found) then
				reward = {
					name = lootInfo.name, 
					qty = tonumber(loot.quantity)
					};
				sesRewards[tostring(loot.item_sdb_id)] = reward;
			end
			updateSesFrame();
		end
	end
end

function OnEncounterReward(args)
	if (not enabled()) then return end
	for _,loot in ipairs(args.rewards) do
		if ((isNotJunk(loot.itemTypeId)) and (loot.boosted == 0)) then
			for i = 1, tonumber(loot.quantity), 1 do
				processLoot(loot);
			end
		end
	end
end

function OnLootCollected(args)
	if (not enabled()) then return end
	if (tonumber(args.lootedToId) ~= tonumber(Player.GetCharacterId())) then return end
	if (isNotJunk(args.itemTypeId)) then
		processLoot(args);
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
	nextItms = {};
	cb_salvage = nil;
	cb_clear = nil;
	cb_queue = nil;
	cb_util = {};
	cb_util_helper = {};
	salvageRequested = false;
	sesRewards = {};
end

function updateFrame()
	MAIN_HUD:SetText(frameTxt);
end

function updateSesFrame()
	text = "";
	for _,reward in pairs(sesRewards) do
		text = text..tostring(reward.name)..":"..tostring(reward.qty).."\n";
	end
	SES_HUD:SetText(text);
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

function salvageTrash(id)
	if (id == nil) then return end
	if (currItm == nil) then
		currItm = id;
		isTrash = true;
		Player.RequestSalvageResource(id, 1, 0);
		if (cb_salvage == nil) then
			clearInfo();
			updateInfo("Salvaging: "..Game.GetItemInfoByType(id).name);
			cb_salvage = callback(salvageTrash, id, 3);
			salvageRequested = true;
		end
	else
		info = {id = id, type = "trash"};
		table.insert(nextItms, info);
		if (cb_queue == nil) then
			cb_queue = callback(handleQueue, nil, 2);
		end
	end
end

function salvageItem(id)
	if (id == nil) then return end
	if (currItm == nil) then
		currItm = id;
		isTrash = false;
		Player.RequestSalvageItem(currItm);
		if (cb_salvage == nil) then
			clearInfo();
			updateInfo("Salvaging: "..Player.GetItemInfo(id).name);
			cb_salvage = callback(salvageItem, id, 3);
			salvageRequested = true;
		end
	else
		info = {id = id, type = "item"};
		table.insert(nextItms, info);
		if (cb_queue == nil) then
			cb_queue = callback(handleQueue, nil, 2);
		end
	end
end

function handleQueue()
	cancel_callback(cb_queue);
	cb_queue = nil;
	if (currItm == nil) then
		if (#nextItms == 0) then return end
		if (nextItms[1].type == "trash") then
			salvageTrash(nextItms[1].id);
		else
			salvageItem(nextItms[1].id);
		end
		table.remove(nextItms, 1);
		if ((#nextItms > 0) and (cb_queue == nil)) then
			cb_queue = callback(handleQueue, nil, 2);
		end
	else
		cb_queue = callback(handleQueue, nil, 2);
	end
end

function claim()
	if (currItm ~=nil) then
		localItm = currItm
		currItm = nil;
		if (localItm == nil) then return end
		cancel_callback(cb_salvage);
		cb_salvage = nil;
		clearInfo();
		if (isTrash) then
			Player.ClaimSalvageResourceRewards(localItm, 1, 0)
			updateInfo("Rewards from: "..Game.GetItemInfoByType(localItm).name);
		else
			Player.ClaimSalvageItemRewards(localItm)
			updateInfo("Rewards from: "..Player.GetItemInfo(localItm).name);
		end
		salvageRequested = false;
	end
end

function salvageTrashEnabled(id)
	if ((tonumber(id) == 52206) and (AutoSalvageRCT())) --was recovered chosen tech
		or ((tonumber(id) == 30408) and (AutoSalvageBBG()))  --was broken bandit gear
		or ((tonumber(id) == 86398) and (AutoSalvageHDM()))  --was half digested module
		or ((tonumber(id) == 86404) and (AutoSalvageCT()))  --was chosen tech
		or ((tonumber(id) == 77418) and (AutoSalvageDCP()))  --was damaged cycle plating
		or ((tonumber(id) == 77419) and (AutoSalvageDDCB()))  --was damaged drive circuit board
		or ((tonumber(id) == 77420) and (AutoSalvageDIDS())) then --was damaged ignition drive system
		return true;
	else
		return false;
	end
end

function isSalvageTrash(id)
	if (tonumber(id) == 52206) or (tonumber(id) == 30408)
		or (tonumber(id) == 86398) or (tonumber(id) == 86404)
		or (tonumber(id) == 77418) or (tonumber(id) == 77419)
		or (tonumber(id) == 77420) then
		return true;
	else
		return false;
	end
end

function isNotJunk(id)
	if ((tonumber(id) ~= 10) and (tonumber(id) ~= 30412)
		and (tonumber(id) ~= 86221) and (tonumber(id) ~= 80404)
		and (tonumber(id) ~= 30294) and (tonumber(id) ~= 30286)
		and (tonumber(id) ~= 33816) and (tonumber(id) ~= 33815)
		and (tonumber(id) ~= 86471) and (tonumber(id) ~= 86373)) then
		return true;
	else
		return false;
	end
end

function isTrashInInventory(id)
	found = false;
	Items, Resources = Player.GetInventory();
	localItems = Items;
	for _,item in ipairs(localItems) do
		if ((tonumber(item.item_sdb_id) == tonumber(id)) and (item.flags.is_salvageable == true))then
			found = true;
		end
	end
	return found;
end

function isItemInInventory(id, quality)
	found = false;
	itemInfo = Game.GetItemInfoByType(id);
	if ((itemInfo.flags.resource == nil) or (itemInfo.flags.resource == false)) then
		Items, Resources = Player.GetInventory()
		localItems = Items;
		for _,item in ipairs(localItems) do
			if ((tonumber(item.item_sdb_id) == tonumber(id))
				and (item.flags.is_equipped == false) and (item.flags.is_salvageable == true)
				and ((tonumber(quality) == tonumber(item.quality)) or ((quality == nil) and (item.quality == nil))))then
				found = true;
			end
		end
	end
	return found;
end

function salvageItemIfEnabled(id, quality)
	for _,item in ipairs(Items) do
		if ((tonumber(item.item_sdb_id) == tonumber(id))
			and (item.flags.is_equipped == false) and (item.flags.is_salvageable == true)
			and ((tonumber(quality) == tonumber(item.quality)) or ((quality == nil) and (item.quality == nil))))then
				quality, prestige, frame = false, false, false;
				if (item.quality) then
					if (tonumber(AutoSalvageQuality()) >= item.quality) then
						quality = true;
					end
				elseif (tonumber(AutoSalvageQuality()) >= 0) then
					quality = true;
				end
				if (tonumber(AutoSalvagePrestige()) >= item.prestige.prestige_level) then
					prestige = true;
				end
				if (salvageThisFrame(item.requirements)) then
					frame = true;
				end
				if (salvageOperation(frame, quality, presige)) then
					salvageItem(item.item_id);
				end
		end
	end
end

function processLoot(args)
	if (#cb_util ~= 0) then
		for _,cb in ipairs(cb_util) do
			if (cb_util_helper[_] == args) then
				cancel_callback(cb_util[_])
				cb_util[_] = nil;
				cb_util_helper[_] = nil;
			end
		end
	end
	id = args.itemTypeId;
	if (isSalvageTrash(id)) then
		if (salvageTrashEnabled(id)) then
			if (isTrashInInventory(id)) then
				salvageTrash(id);
			else
				if (#cb_util == 0) then
					cb_util[1] = callback(processLoot, args, 5);
					cb_util_helper[1] = args;
				else
					for _,cb in ipairs(cb_util) do
						if (cb == nil) then
							cb_util[_] = callback(processLoot, args, 5);
							cb_util_helper[_] = args;
						end
					end
				end
			end
		else
			return;
		end
	else
		if (args.quality) then
			qual = args.quality
		else
			qual = nil;
		end
		if (isItemInInventory(id, qual)) then
			salvageItemIfEnabled(id, qual)
		else
			if (#cb_util == 0) then
				cb_util[1] = callback(processLoot, args, 5);
				cb_util_helper[1] = args;
			else
				for _,cb in ipairs(cb_util) do
					if (cb == nil) then
						cb_util[_] = callback(processLoot, args, 5);
						cb_util_helper[_] = args;
					end
				end
			end
		end
	end
end

function salvageThisFrame(frame)
	if (#frame == 0) then
		return AutoSalvageCommonFrame();
	elseif (tonumber(frame[1].id) == 732) then
		return AutoSalvageAssault();
	elseif (tonumber(frame[1].id) == 733) then
		return AutoSalvageFirecat();
	elseif (tonumber(frame[1].id) == 734) then
		return AutoSalvageTigerclaw();
	elseif (tonumber(frame[1].id) == 735) then
		return AutoSalvageEngineer();
	elseif (tonumber(frame[1].id) == 736) then
		return AutoSalvageElectron();
	elseif (tonumber(frame[1].id) == 737) then
		return AutoSalvageBastion();
	elseif (tonumber(frame[1].id) == 738) then
		return AutoSalvageBiotech();
	elseif (tonumber(frame[1].id) == 739) then
		return AutoSalvageDragonfly();
	elseif (tonumber(frame[1].id) == 740) then
		return AutoSalvageRecluse();
	elseif ((tonumber(frame[1].id) == 741) or (tonumber(frame[1].id) == 1377)) then
		return AutoSalvageDreadnaught();
	elseif (tonumber(frame[1].id) == 742) then
		return AutoSalvageMammoth();
	elseif (tonumber(frame[1].id) == 743) then
		return AutoSalvageRhino();
	elseif (tonumber(frame[1].id) == 744) then
		return AutoSalvageRecon();
	elseif (tonumber(frame[1].id) == 745) then
		return AutoSalvageNighthawk();
	elseif (tonumber(frame[1].id) == 746) then
		return AutoSalvageRaptor();
	elseif (tonumber(frame[1].id) == 748) then
		return AutoSalvageArsenal();
	end
end

function salvageOperation(frame, quality, prestige)
	logic = AutoSalvageLogic();
	if ((not AutoSalvageFrame()) and
		(tonumber(AutoSalvageQuality()) < 0) and (tonumber(AutoSalvagePrestige()) < 0)) then
		return false;
	end
	if (logic == "or") then
		retval = false;
		if (AutoSalvageFrame()) then
			retval = retval or frame;
		end
		if (tonumber(AutoSalvageQuality()) >= 0) then
			retval = retval or quality;
		end
		if (tonumber(AutoSalvagePrestige()) >= 0) then
			retval = retval or prestige;
		end
		return retval;
	elseif (logic == "and") then
		retval = true;
		if (AutoSalvageFrame()) then
			retval = retval and frame;
		end
		if (tonumber(AutoSalvageQuality()) >= 0) then
			retval = retval and quality;
		end
		if (tonumber(AutoSalvagePrestige()) >= 0) then
			retval = retval and prestige;
		end
		return retval;
	else
		Debug('E', "Logic Operator is an unexpected value: "..logic);
		return false
	end
end

--[[**********************************************
**					Notes						**
**********************************************--]]
--[[
Items, Resources = Player.getInventory()
for _,item in ipairs(Items) do
	item.requirement.id shows what classes can equp an item
end
732 is Assault
733 is Firecat
734 is Tigerclaw
735 is Engineer
736 is Electron
737 is Bastion
738 is Biotech
739 is Dragonfly
740 is Recluse
741 is Dreadnaught
742 is Mammoth
743 is Rhino
744 is Recon
745 is Nighthawk
746 is Raptor
748 is Arsenal
1377 is Accord Dreadnaught
--]]