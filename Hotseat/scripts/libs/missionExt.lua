
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local getModUtils = require(path .."libs/getModUtils")
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

function this:load()
	modUtils = getModUtils()
	
	modApi:addMissionStartHook(init)
	modApi:addMissionNextPhaseCreatedHook(function(_, m) init(m) end)
	modUtils:addResetTurnHook(function() modApi:runLater(init) end)
	modUtils:addGameLoadedHook(function() modApi:runLater(init) end)
	
	modApi:addMissionEndHook(function(m)
		m[id].hasEnded = true
	end)
end

return this