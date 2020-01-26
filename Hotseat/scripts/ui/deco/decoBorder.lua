
local this = Class.inherit(UiDeco)

function this:new(color, borderwidth)
	self.color = color
	self.borderwidth = borderwidth
end

function this:draw(screen, widget)
	if not self.color or not widget.rect or not self.borderwidth then return end
	
	local r = widget.rect
	r = sdl.rect(r.x, r.y, r.w, r.h)
	
	if self.size then
		r.x = r.x - (self.size.w - r.w) / 2
		r.y = r.y - (self.size.h - r.h) / 2
		r.w = self.size.w
		r.h = self.size.h
	end
	
	drawborder(screen, self.color, r, self.borderwidth)
end

return this