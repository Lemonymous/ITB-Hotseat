
local this = Class.inherit(DecoFrame)

function this:new(...)
	DecoFrame.new(self, ...)
end

function this:draw(screen, widget)
	local r = widget.rect

	self.rect.x = r.x + widget.decorationx
	self.rect.y = r.y + widget.decorationy
	self.rect.w = r.w
	self.rect.h = r.h

	screen:drawrect(self.color, self.rect)

	local c = self.bordercolor
	if widget.dragResizing then
		c = deco.colors.focus
	elseif widget.canDragResize then
		c = deco.colors.buttonborderhl
	end

	drawborder(screen, c, self.rect, self.bordersize)

	widget.decorationx = widget.decorationx + self.bordersize
	widget.decorationy = widget.decorationy + self.bordersize
end

return this