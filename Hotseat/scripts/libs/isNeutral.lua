
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local getPawnSavedata = require(path .."libs/getPawnSavedata")

return function(id)
	assert(Game)
	local pawn = Game:GetPawn(id)
	if not pawn then return end
	
	savedata = getPawnSavedata(id)
	if savedata and savedata.bNeutral ~= nil then
		return savedata.bNeutral
	end
	
	return _G[pawn:GetType()].Neutral
end