
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local getModUtils = require(path .."weaponPreview/lib/getModUtils")

return function(id)
	assert(Game)
	modUtils = getModUtils()
	
	local pawn = Game:GetPawn(id)
	if not pawn then return end
	
	return modUtils.pawn:getSavedataTable(id)
end