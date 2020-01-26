
--[[
	Provides a function to get a pawn's current queued up attack.
]]

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local getPawnSavedata = require(path .."weaponPreview/lib/getPawnSavedata")

return function(id)
	if not Board or GetCurrentMission() == nil then
		return
	end
	
	local pawn = Game:GetPawn(id)
	if not pawn then return end
	
	data = getPawnSavedata(id)
	if data and data.iQueuedSkill ~= -1 then
		return {
			piOrigin = data.piOrigin,
			piTarget = data.piTarget,
			piQueuedShot = data.piQueueShot,
			iQueuedSkill = data.iQueuedSkill,
		}
	end
	
	return nil
end