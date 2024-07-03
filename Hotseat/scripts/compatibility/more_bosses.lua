
-- adjusting a few mechanics to be more suitable for player controlled use.

local id = "lmn_more_bosses"
local mod = mod_loader.mods[id]
if not mod or not mod.initialized then
	return {load = function() end}
end

--LOG("Hotseat: ".. id .." found. Running compatibility code.")
LOG("Hotseat: ".. id .." found. Compatibility code incomplete. Removing incompatible enemies from pool.")

local getModUtils = require(path .."libs/getModUtils")
local weaponPreview = require(path .."weaponPreview/api")
local path = modApi:getCurrentMod().scriptPath
local utils = require(path .."libs/utils")
local this = {}

function this:load()
	local enemies = {
		"DiggerBoss",
		"ScarabBoss",
		"BlobberBoss",
	}
	
	for _, enemy in ipairs(enemies) do
		remove_element("Mission_".. enemy, Corp_Default.Bosses)
		remove_element(enemy, Mission_Final.BossList)
		remove_element(enemy, Mission_Final_Cave.BossList)
	end
end

return this