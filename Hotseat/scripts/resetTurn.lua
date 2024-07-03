
local path = modApi:getCurrentMod().scriptPath
local hotkey = require(path .."libs/hotkey")
local this = {}

-- Reset Turn will reset both Vek and Mech actions.
-- Let's just hide and suppress it to simplify everything.
sdlext.addFrameDrawnHook(function(screen)
	Location.undo_turn = Point(INT_MAX, INT_MAX)
end)

hotkey:suppress(hotkey.RESET_TURN)

local function suppress()
	hotkey:suppress(hotkey.RESET_TURN)
end

local function unsuppress()
	hotkey:unsuppress(hotkey.RESET_TURN)
end

sdlext.addGameExitedHook(function()
	unsuppress()
end)

modApi.events.onMissionStart:subscribe(suppress)
modApi.events.onMissionNextPhaseCreated:subscribe(suppress)
modApi.events.onMissionEnd:subscribe(unsuppress)
modapiext.events.onGameLoaded:subscribe(suppress)

return this