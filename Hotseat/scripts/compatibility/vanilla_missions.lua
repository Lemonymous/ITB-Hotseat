
-- adjusting a few vanilla missions to be more suitable for hotseat.

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
--local getModUtils = require(path .."libs/getModUtils")
--local utils = require(path .."libs/utils")
local phases = require(path .."phases")
local this = {}

local old_Mission_Tanks_NextTurn = Mission_Tanks.NextTurn
function Mission_Tanks:NextTurn()
	Mission.NextTurn(self)
end

phases.addMechTurnStartHook(function()
	local m = GetCurrentMission()
	if not m or m.ID ~= "Mission_Tanks" then return end
	
	old_Mission_Tanks_NextTurn(m)
	
	for _, id in ipairs(m.Tanks) do
		local pawn = Board:GetPawn(id)
		if Board:IsPawnAlive(id) then
			pawn:SetActive(true)
		end
	end
end)

return this