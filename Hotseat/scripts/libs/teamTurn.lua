
local getModUtils = require(path .."libs/getModUtils")
local path = modApi:getCurrentMod().scriptPath
local this = {}

function this.IsVekTurn()
	local mission = GetCurrentMission()
	if not mission then return nil end
	
	return (mission.lmn_VekTurnCount or 0) == Game:GetTurnCount()
end

function this.IsVekMovePhase()
	local mission = GetCurrentMission()
	if not mission then return nil end
	
	return (mission.lmn_VekMovePhase or -1) == Game:GetTurnCount()
end

function this.IsPlayerTurn()
	local mission = GetCurrentMission()
	if not mission then return nil end

	return (mission.lmn_VekTurnCount or 0) < Game:GetTurnCount()
end

local applyEnvironmentEffect = Mission.ApplyEnvironmentEffect
function Mission:ApplyEnvironmentEffect(...)
	local ret = applyEnvironmentEffect(self, ...)
	
	self.lmn_VekTurnCount = Game:GetTurnCount()
	
	return ret
end

function this:load()
	local modUtils = getModUtils()
	
	modUtils:addVekMoveStartHook(function(mission)
		mission.lmn_VekMovePhase = Game:GetTurnCount()
	end)
end

return this