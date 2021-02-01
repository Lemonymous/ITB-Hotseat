
---------------------------------------------------------------------
-- Highlighted v1.2 - code library
--[[-----------------------------------------------------------------
	needs to be loaded to function.
]]
local path = mod_loader.mods[modApi.currentMod].scriptPath
local modUtils = require(path .."modApiExt/modApiExt")
local this = {}

sdlext.addGameExitedHook(function()
	this.highlighted = nil
end)

function this:Get()
	return self.highlighted
end

function this:load()
	modUtils:addTileHighlightedHook(function(_, tile)
		self.highlighted = tile
	end)
	
	modUtils:addTileUnhighlightedHook(function()
		self.highlighted = nil
	end)
end

return this