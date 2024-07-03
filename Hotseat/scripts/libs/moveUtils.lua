
---------------------------------------------------------------------
-- MoveUtils v1.0* - code library
---------------------------------------------------------------------
-- attempts at useful functions related to the 'Move' skill
--
-- needs to be loaded with the function 'load' before use.
-- *modified for hotseat

local path = modApi:getCurrentMod().scriptPath
local teamTurn = require(path .."libs/teamTurn")
local getModUtils = require(path .."libs/getModUtils")
local this = {}

-- returns true if pawn is being moved.
-- if pawn is nil; returns true if ANY pawn is being moved.
function this:IsMoveActive(pawn)
	if pawn then
		return self.activePawn == pawn
	end
	
	return self.activePawn ~= nil
end

-- returns true if a pawn has spent it's movement this turn.
function this:HasMoved(pawn)
	local mission = GetCurrentMission()
	if not mission then return false end
	
	mission.lmn_hasMoved = mission.lmn_hasMoved or {}
	return mission.lmn_hasMoved[pawn:GetId()] == Game:GetTurnCount()
end

function this:load()
	local modUtils = getModUtils()
	
	modUtils:addPawnMoveStartHook(function(mission, pawn)
		mission.lmn_hasMoved = mission.lmn_hasMoved or {}
		mission.lmn_hasMoved[pawn:GetId()] = Game:GetTurnCount()
	end)
	
	modUtils:addPawnUndoMoveHook(function(mission, pawn)
		mission.lmn_hasMoved = mission.lmn_hasMoved or {}
		mission.lmn_hasMoved[pawn:GetId()] = nil
	end)
	
	modUtils:addPawnSelectedHook(function(mission, pawn)
		if not teamTurn.IsPlayerTurn() or self:HasMoved(pawn) then return end
		
		self.activePawn = pawn
	end)
	
	modUtils:addPawnDeselectedHook(function(mission, pawn)
		if not teamTurn.IsPlayerTurn() or self:HasMoved(pawn) then return end
		
		self.activePawn = nil
	end)
end

return this