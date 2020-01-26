
local this = Class.inherit(DecoSolid)

function this:new(color, size)
	DecoSolid.new(self, color)
	self.size = size
end

function this:draw(screen, widget)
	if self.color ~= nil and widget.rect ~= nil then
		local r = widget.rect
		r = sdl.rect(r.x, r.y, r.w, r.h)
		
		if self.size then
			r.w = self.size.w
			r.h = self.size.h
		end
		
		r.x = r.x + widget.decorationx
		r.y = r.y + widget.decorationy
		
		screen:drawrect(self.color, r)
	end
end

return this