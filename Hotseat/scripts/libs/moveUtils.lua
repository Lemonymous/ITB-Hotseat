
---------------------------------------------------------------------
-- MoveUtils v1.0* - code library
---------------------------------------------------------------------
-- attempts at useful functions related to the 'Move' skill
--
-- needs to be loaded with the function 'load' before use.
-- *modified for hotseat

local path = modApi:getCurrentMod().scriptPath
local teamTurn = require(path .."libs/teamTurn")
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

modapiext.events.onPawnMoveStart:subscribe(function(mission, pawn)
	mission.lmn_hasMoved = mission.lmn_hasMoved or {}
	mission.lmn_hasMoved[pawn:GetId()] = Game:GetTurnCount()
end)

modapiext.events.onPawnUndoMove:subscribe(function(mission, pawn)
	mission.lmn_hasMoved = mission.lmn_hasMoved or {}
	mission.lmn_hasMoved[pawn:GetId()] = nil
end)

modapiext.events.onPawnSelected:subscribe(function(mission, pawn)
	if not teamTurn.IsPlayerTurn() or this:HasMoved(pawn) then return end
	
	this.activePawn = pawn
end)

modapiext.events.onPawnDeselected:subscribe(function(mission, pawn)
	if not teamTurn.IsPlayerTurn() or this:HasMoved(pawn) then return end
	
	this.activePawn = nil
end)

return this