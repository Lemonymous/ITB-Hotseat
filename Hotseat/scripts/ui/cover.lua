
local path = mod_loader.mods[modApi.currentMod].scriptPath
local menu = require(path .."libs/menu")
local Ui2 = require(path .."ui/Ui2")
local DecoSolid2 = require(path .."ui/deco/decoSolid2")

local this = Class.inherit(Ui2)

function this:new(adjust, color, duration)
	Ui2.new(self)
	
	adjust = copy_table(adjust) or {}
	adjust.align = adjust.align or {}
	adjust.size = adjust.size or {}
	self.align = adjust.align or {}
	self.size = adjust.size or {}
	self.align.x = adjust.align.x or 0
	self.align.y = adjust.align.y or 0
	self.size.w = adjust.size.w or 0
	self.size.h = adjust.size.h or 0
	
	self.colorTransparent = deco.colors.transparent
	self.color = color or sdl.rgba(0, 0, 0, 220)
	self.translucent = true
	self.ignoreMouse = true
	
	self:decorate{
		DecoAlign(self.align.x, self.align.y),
		DecoSolid2(deco.colors.transparent)
	}
	
	self.animations.fade = UiAnim(self, duration or 100, function(anim, widget, percent)
		widget.decorations[2].color = InterpolateColor(
			widget.colorTransparent,
			widget.color,
			percent
		)
	end)
	
	function self.animations.fade:isDone()
		return false
	end
end

function this:update(screen)
	self:widthpx(self.parent.w + self.size.w)
		:heightpx(self.parent.h + self.size.h)
		
	self.parent:relayout()
	
	Ui2.update(self, screen)
end

function this:draw(screen)
	local anim = self.animations.fade
	if menu.isClosed() then
		anim:stop()
		self.decorations[2].color = self.colorTransparent
	elseif anim:isStopped() then
		anim:start()
	end
	
	self.decorationx = 0
	self.decorationy = 0
	Ui2.draw(self, screen)
end

return this