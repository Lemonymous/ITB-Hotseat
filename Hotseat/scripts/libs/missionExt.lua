
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local id = mod.id
local this = {}

local function init(m)
	m[id] = m[id] or {}
end

function this:isMission(m)
	m = m or GetCurrentMission()
	return Game and GAME and Board and m
end

function this:hasEnded(m)
	m = m or GetCurrentMission()
	return not m or m[id].hasEnded
end

modApi.events.onMissionStart:subscribe(init)
modApi.events.onMissionNextPhaseCreated:subscribe(function(_, m) init(m) end)
modapiext.events.onResetTurn:subscribe(function() modApi:runLater(init) end)
modapiext.events.onGameLoaded:subscribe(function() modApi:runLater(init) end)

modApi.events.onMissionEnd:subscribe(function(m)
	m[id].hasEnded = true
end)

return this