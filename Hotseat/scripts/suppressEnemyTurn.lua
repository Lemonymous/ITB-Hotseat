
local getModUtils = require(path .."libs/getModUtils")
local path = modApi:getCurrentMod().scriptPath
local phases = require(path .."phases")
local this = {}

local function init()
	for i, v in pairs(_G) do
		if type(v) == 'table' then
			if type(v.GetTargetScore) == 'function' then
				local old = v.GetTargetScore
				v.GetTargetScore = function(self, p1, ...)
					
					if phases.isPhase("ai") then
						local pawn = Board:GetPawn(p1)
						
						if not pawn then
							pawn = Pawn
						end
						
						if pawn and pawn:IsEnemy() then
							return -100
						end
					end
					
					return old(self, p1, ...)
				end
			end
		end
	end
end

local function isBurrowerOffBoard(pawn)
	return _G[pawn:GetType()].Burrows and not Board:IsValid(pawn:GetSpace())
end

-- run init after all mods init,
-- but before all mods load.
local old = modApi.finalize
function modApi.finalize(...)
	init()
	old(...)
end

function this.suppressPawn(m, pawn, flag)
	if not pawn then return end
	
	local id = pawn:GetId()
	flag = flag ~= false
	m.lmn_hotseat = m.lmn_hotseat or {}
	m.lmn_hotseat.speed = m.lmn_hotseat.speed or {}
	tbl = m.lmn_hotseat.speed
	
	if flag then
		tbl[id] = tbl[id] or true
		if not isBurrowerOffBoard(pawn) then
			pawn:SetMoveSpeed(-99)
		end
	elseif tbl[id] then
		pawn:SetMoveSpeed(_G[pawn:GetType()].MoveSpeed)
		tbl[id] = nil
	end
end

local function suppressPawns(m, flag)
	flag = flag ~= false
	if flag then
		for _, id in ipairs(extract_table(Board:GetPawns(TEAM_ENEMY))) do
			local pawn = Board:GetPawn(id)
			if pawn then
				this.suppressPawn(m, pawn, flag)
			end
		end
	else
		m.lmn_hotseat = m.lmn_hotseat or {}
		m.lmn_hotseat.speed = m.lmn_hotseat.speed or {}
		
		for id, speed in pairs(m.lmn_hotseat.speed) do
			this.suppressPawn(m, Board:GetPawn(id), false)
		end
	end
end

phases.addVekTurnStartHook(function()
	suppressPawns(GetCurrentMission(), false)
end)

phases.addAiStartHook(function()
	suppressPawns(GetCurrentMission(), true)
end)

function this:load()
	local modUtils = getModUtils()
	
	modUtils:addPawnTrackedHook(function(self, pawn)
		if phases.isPhase("ai") then
			this.suppressPawn(self, pawn)
		end
	end)
end

return this