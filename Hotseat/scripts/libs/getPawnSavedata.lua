
local mod = modApi:getCurrentMod()
local path = mod.scriptPath

return function(id)
	assert(Game)
	
	local pawn = Game:GetPawn(id)
	if not pawn then return end
	
	return modapiext.pawn:getSavedataTable(id)
end