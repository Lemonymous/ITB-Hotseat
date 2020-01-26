
--[[
	returns true if there is a unit on the board
	providing the respective psion bonuses.
	
	functions
	---------
	psion.isHealth()
	psion.isArmor()
	psion.isRegen()
	psion.isExplode()
	psion.isLava()
	
	-- returns the buff of the last psion found.
	-- this is the buff that will be visible in the info overlay.
	-- returns nil if none are found.
	psion.getLast()
]]

local this = {}

local funcs = {
	isHealth = LEADER_HEALTH,
	isArmor = LEATHER_ARMOR,
	isRegen = LEADER_REGEN,
	isExplode = LEADER_EXPLODE,
	isLava = LEADER_TENTACLE,
	isBoss = LEADER_BOSS,
	
	-- alternate functions
	isSoldier = LEADER_HEALTH,
	isShell = LEATHER_ARMOR,
	isBlood = LEADER_REGEN,
	isBlast = LEADER_EXPLODE,
	isTyrant = LEADER_TENTACLE,
	
	isTentacle = LEADER_TENTACLE,
}

for fn, ability in pairs(funcs) do
	this[fn] = function()
		for _, id in ipairs(extract_table(Board:GetPawns(TEAM_ANY))) do
			local pawn = Board:GetPawn(id)
			local type = pawn:GetType()
			if _G[type].Leader == ability then
				return true
			end
		end
		
		return false
	end
end

function this:getLast()
	local ret
	for _, id in ipairs(extract_table(Board:GetPawns(TEAM_ANY))) do
		local pawn = Board:GetPawn(id)
		local type = pawn:GetType()
		local leader = _G[type].Leader
		if leader and leader ~= LEADER_NONE then
			ret = leader
		end
	end
	
	return ret
end

return this