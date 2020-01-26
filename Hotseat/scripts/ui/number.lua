
local path = mod_loader.mods[modApi.currentMod].scriptPath
local clip = require(path .."libs/clip")
local Ui2 = require(path .."ui/Ui2")
local DecoNumber = require(path .."ui/deco/decoNumber")
local this = Class.inherit(Ui2)

function this:new(loc, number, scale, color)
	Ui2.new(self)
	self.translucent = true
	
	number = number or nil
	scale = scale or 2
	color = color or nil
	
	self:pospx(loc.x, loc.y)
		:decorate{
			DecoAlign(-18, 37),
			DecoNumber(number, scale, color)
		}
end

function this:draw(screen)
	clip(Ui2, self, screen)
end

return this