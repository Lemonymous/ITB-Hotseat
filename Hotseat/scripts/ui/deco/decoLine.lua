
local this = Class.inherit(UiDeco)

function this:new(color, borderwidth, adjust, vertical)
	adjust = adjust or {}
	self.align = adjust.align or {x = 0, y = 0}
	self.size = adjust.size or {w = 0, h = 0}
	self.color = color
	self.borderwidth = borderwidth
	self.vertical = vertical
end

function this:draw(screen, widget)
	if not self.color or not widget.rect or not self.borderwidth then return end
	
	local r = widget.rect
	if self.vertical then
		r = sdl.rect(r.x, r.y, self.borderwidth, r.h)
	else
		r = sdl.rect(r.x, r.y, r.w, self.borderwidth)
	end
	
	r.w = r.w + self.size.w
	r.h = r.h + self.size.h
	r.x = r.x - self.size.w / 2
	r.y = r.y - self.size.h / 2
	
	r.x = r.x + self.align.x
	r.y = r.y + self.align.y
	
	r.x = r.x + widget.decorationx
	r.y = r.y + widget.decorationy
	
	if self.vertical then
		widget.decorationx = math.floor(widget.decorationx + (self.borderwidth + self.size.w) / 2)
	else
		widget.decorationy = math.floor(widget.decorationy + (self.borderwidth + self.size.h) / 2)
	end
	
	screen:drawrect(self.color, r)
end

return this