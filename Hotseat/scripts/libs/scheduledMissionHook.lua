
-- scheduled hooks which get erased when exiting the game or mission ends.
-- no important game logic should be added using this,
-- or additional code needs to be provided to reschedule hooks at game load/reset.
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local getModUtils = require(path .."libs/getModUtils")
local this = {}
local hooks = {}

local function reset()
	hooks = {}
end

sdlext.addGameExitedHook(reset)

function this:load()
	local modUtils = getModUtils()
	
	modUtils:addResetTurnHook(reset)
	modUtils:addGameLoadedHook(reset)
	modApi:addMissionEndHook(reset)
end

function this:add(msdelay, fn)
	if not GAME or not Game or not Board or not GetCurrentMission() then return end
	
	modApi:scheduleHook(msdelay, fn)
end

return this