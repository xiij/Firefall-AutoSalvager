--[[**********************************************
**					Util						**
**					By 	Xiij					**
**********************************************--]]
--[[**********************************************
**												**
**	Util is a set of utilities functions.		**
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

--[[
	Debug status:
	0 - Debug Off
	1 - User Debug On (User Debug creates a log file)
	2 - Admin Debug On (Admin Debug creates a log file and displays a system message)
--]]
local dbg_sts = nil;
--[[
	Debug level:
	0 - E
	1 - W and E
	2 - T, W, and E
	3 - All (F, T, W, and E)
--]]
local dbg_lvl = nil;

--[[**********************************************
**					Functions					**
**********************************************--]]

--Sets the debug status and level
function init_Debug(sts, lvl)
	dbg_sts = sts;
	dbg_lvl = lvl;
end

--Displays a System Message to the user
function Sys_Msg(msg)
	Msg(msg,'system');
end

--Displays a Notification Message to the user
function Notify_Msg(msg)
	Msg(msg,'notification');
end

--Displays a Message to the user
function Msg(msg, chan)
	Component.GenerateEvent("MY_SYSTEM_MESSAGE", {text=tostring(msg), channel=chan});
end

--Generates a Debug Log or displays a debug statement to the user
function Debug (level, msg)
--Check Debug Status and Level
--If Debug Status is not nil and not turned off
--and Debug Level is set to the level of the message
--For the Debug Level check, always show 'E', show 'W' if Level is 1 or 2,
--and only show 'T' if Level is 2
	if (not enabled()) then
		return;
	end
	if ((dbg_sts ~= nil) and (dbg_sts ~= 0) and (dbg_lvl ~= nil)
		and ((level == 'E')
			or ((level == 'W') and ((dbg_lvl >= 1) and (dbg_lvl < 4)))
			or ((level == 'T') and ((dbg_lvl >= 2) and (dbg_lvl < 4)))
			or ((level == 'F') and ((dbg_lvl >= 3) and (dbg_lvl < 4))))) then
		local dbgMsg = level.." "..msg;
		log (dbgMsg);
		if (dbg_sts == 2) then
			Sys_Msg(dbgMsg);
		end
	end
end

--[[**********************************************
**					Notes						**
**********************************************--]]