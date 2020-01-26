
--[[
	small library providing functions to check when the menu is open and closed.
	menu is considered open outside of missions.
	
	must be loaded.
]]

local this = {}

local closed, nextClosed = false, false
sdlext.addFrameDrawnHook(function()
	closed = nextClosed
	nextClosed = false
end)

function this:load()
    modApi:addMissionUpdateHook(function()
		nextClosed = true
    end)
end

function this.isOpen()
	return not closed
end

function this.isClosed()
	return closed
end

return this