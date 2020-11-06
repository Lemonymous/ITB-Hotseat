
local path = mod_loader.mods[modApi.currentMod].scriptPath
local Ui2 = require(path .."ui/Ui2")
local DecoButton2 = require(path .."ui/deco/decoButton2")
local this = Class.inherit(Ui2)
local c = deco.colors.transparent

function this:new()
	Ui2.new(self)
	
	self:widthpx(225):heightpx(60)
	self:decorate{DecoButton2(c,c,c,c)}
end

function this:update(screen)
	self:pospx(Location["action_end"].x, Location["action_end"].y)
	self.parent:relayout()
end

-- block mouse clicks if console is up.
function this:draw(screen)
	self.visible = sdlext.isConsoleOpen()
	Ui2.draw(self, screen)
end

-- let mouse hover pass through element.
function this:mousemove(...)
	Ui2.mousemove(self, ...)
	
	return false
end

return this