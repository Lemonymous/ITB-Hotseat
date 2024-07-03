
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local data = mod.id .."_pawnTeam"
local isNeutral = require(path .."libs/isNeutral")
local this = {}

-- stores the current team of a unit.
function this:save(m, id)
	m[data] = m[data] or {}
	local data = m[data]
	data.vek = data.vek or {}
	data.mech = data.mech or {}
	local pawn = Board:GetPawn(id)
	
	if pawn then
		local team = pawn:GetTeam()
		if team == TEAM_ENEMY then
			table.insert(data.vek, id)
		elseif team == TEAM_PLAYER then
			table.insert(data.mech, id)
		end
	end
end

-- makes every non-neutral enemy a player controlled unit.
-- makes every player controlled unit a non-enemy, non-player unit.
function this:swap(id, setActivity)
	local pawn = Board:GetPawn(id)
	
	if pawn then
		local team = pawn:GetTeam()
		if team == TEAM_ENEMY then
			pawn:SetTeam(TEAM_PLAYER)
			if setActivity then
				pawn:SetActive(true)
			end
		elseif team == TEAM_PLAYER then
			pawn:SetTeam(TEAM_ANY)
		end
	end
end

-- stores all current unit teams, and swaps control of them.
function this:swapAll()
	local m = GetCurrentMission()
	assert(m)
	
	if m[data] then return end
	m[data] = { vek = {}, mech = {} }
	
	for _, id in ipairs(extract_table(Board:GetPawns(TEAM_ANY))) do
		self:save(m, id)
		self:swap(id, true)
	end
end

-- resets unit teams back to stored teams.
function this:resetAll()
	local m = GetCurrentMission()
	assert(m)
	
	m[data] = m[data] or { vek = {}, mech = {} }
	
	for _, id in ipairs(m[data].vek) do
		local pawn = Board:GetPawn(id)
		
		if pawn then
			pawn:SetTeam(TEAM_ENEMY)
			pawn:SetActive(false)
		end
	end
	
	for _, id in ipairs(m[data].mech) do
		local pawn = Board:GetPawn(id)
		
		if pawn then
			pawn:SetTeam(TEAM_PLAYER)
			pawn:SetActive(true)
		end
	end
	
	m[data] = nil
end

return this