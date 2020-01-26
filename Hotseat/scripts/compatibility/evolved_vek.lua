
-- adjusting a few mechanics to be more suitable for player controlled use.

local id = "Wolf_EvolvedVek"
local mod = mod_loader.mods[id]
if not mod or not mod.initialized then
	return {load = function() end}
end

--LOG("Hotseat: ".. id .." found. Running compatibility code.")
LOG("Hotseat: ".. id .." found. Compatibility code incomplete. Removing incompatible enemies from pool.")

local path = mod_loader.mods[modApi.currentMod].scriptPath
local getModUtils = require(path .."libs/getModUtils")
local weaponPreview = require(path .."weaponPreview/api")
local utils = require(path .."libs/utils")
local this = {}

--[[
	these enemies are proving very difficult to make compatible with hotseat, and will probably not be viable unless Wolf wants to help add them in.
	Viper pulls instantly, so some limitations would have to be added to avoid pulling into holes.
	Cobra has an instant attack that would have to be suppressed somehow. Doable, but unsure of the most seamless method.
	The bigger problem is reflexive fire which will fire during the Vek Player's turn at your own units.
	Termite should be viable, but it does not want to be suppressed in the enemy attack phase for some reason.
]]

function this:load()
	remove_element("Viper", EnemyLists.Unique)
	remove_element("Cobra", EnemyLists.Unique)
	remove_element("Termite", EnemyLists.Unique)
end

return this