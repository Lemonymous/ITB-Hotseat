
local path = modApi:getCurrentMod().scriptPath
local clip = require(path .."libs/clip")
local utils = require(path .."libs/utils")
local Ui2 = require(path .."ui/Ui2")
local DecoSet = require(path .."ui/deco/decoSet")
local DecoBorder = require(path .."ui/deco/decoBorder")
local this = Class.inherit(Ui2)

-- pingpx = how many pixels to ping in each direction.
function this:new(color, duration, borderwidth, ping_start, ping_end, align)
	Ui2.new(self)
	
	self.color = color or deco.colors.white
	borderwidth = borderwidth or 2
	self.ping_start = ping_start * 2 or 0
	self.ping_end = ping_end * 2 or 0
	align = align or {x = 0, y = 0}
	
	self:pospx(0, 0)
		:width(1):height(1)
		:decorate{
			DecoSet(align.x, align.y),
			DecoBorder(self.color, borderwidth),
		}
	
	self.decorations[2].size = {w = 1, h = 1}
	self.animations.ping = UiAnim(self, duration or 100, function(anim, widget, percent)
		widget.decorations[2].size.w = utils.interpolate(percent, widget.rect.w + widget.ping_start, widget.rect.w + widget.ping_end)
		widget.decorations[2].size.h = utils.interpolate(percent, widget.rect.h + widget.ping_start, widget.rect.h + widget.ping_end)
		widget.decorations[2].color = InterpolateColor(
			widget.color,
			deco.colors.transparent,
			percent
		)
	end)
	
	self.animations.ping.onFinished = function(anim, widget)
		widget:detach()
	end
	
	self.animations.ping:start()
end

--function this:isUpdate(screen)
--	return Ui2.isUpdate(self, screen) or self.animations.ping:isStarted()
--end

function this:update(screen)
	Ui2.update(self, screen)
	self.parent:relayout()
end

function this:draw(screen)
	clip(Ui2, self, screen)
end

return this