
-- scheduled hooks which get erased when exiting the game or mission ends.
-- no important game logic should be added using this,
-- or additional code needs to be provided to reschedule hooks at game load/reset.
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local this = {}
local hooks = {}

local function reset()
	hooks = {}
end

modApi.events.onGameExited:subscribe(reset)
modapiext.events.onResetTurn:subscribe(reset)
modapiext.events.onGameLoaded:subscribe(reset)
modApi.events.onMissionEnd:subscribe(reset)

function this:add(msdelay, fn)
	if not GAME or not Game or not Board or not GetCurrentMission() then return end
	
	modApi:scheduleHook(msdelay, fn)
end

return this