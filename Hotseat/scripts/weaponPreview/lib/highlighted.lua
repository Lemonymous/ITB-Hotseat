
---------------------------------------------------------------------
-- Highlighted v1.1* - code library
--[[-----------------------------------------------------------------
	modified for Weapon preview library
]]
local path = mod_loader.mods[modApi.currentMod].scriptPath
local getModUtils = require(path .."weaponPreview/lib/getModUtils")
local this = {}

sdlext.addGameExitedHook(function()
	this.highlighted = nil
end)

function this:Get()
	return self.highlighted
end

function this:load()
	local modUtils = getModUtils()
	
	modUtils:addTileHighlightedHook(function(_, tile)
		self.highlighted = tile
	end)
	
	modUtils:addTileUnhighlightedHook(function()
		self.highlighted = nil
	end)
end

return this