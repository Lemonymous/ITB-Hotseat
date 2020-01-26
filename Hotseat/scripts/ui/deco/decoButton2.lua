
local this = Class.inherit(DecoButton)

function this:new(...)
	DecoButton.new(self, ...)
	self.edgecolor = self.color
	self.disablededgecolor = self.disabledcolor
end

function this:draw(screen, widget)
	local r = widget.rect
	
	local basecolor = self.color
	local edgecolor = self.edgecolor
	local bordercolor = self.bordercolor
	
	if widget.hovered then
		basecolor = self.hlcolor
		bordercolor = self.borderhlcolor
	end
	if widget.disabled then
		basecolor = self.disabledcolor
		edgecolor = self.disablededgecolor
	end
	
	self.rect.x = r.x
	self.rect.y = r.y
	self.rect.w = r.w
	self.rect.h = r.h
	screen:drawrect(bordercolor, self.rect)
	
	self.rect.x = r.x + 1
	self.rect.y = r.y + 1
	self.rect.w = r.w - 2
	self.rect.h = r.h - 2
	screen:drawrect(edgecolor, self.rect)
	
	if not widget.disabled then
		self.rect.x = r.x + 2
		self.rect.y = r.y + 2
		self.rect.w = r.w - 4
		self.rect.h = r.h - 4
		screen:drawrect(bordercolor, self.rect)

		self.rect.x = r.x + 4
		self.rect.y = r.y + 4
		self.rect.w = r.w - 8
		self.rect.h = r.h - 8
		screen:drawrect(edgecolor, self.rect)
		
		self.rect.x = r.x + 5
		self.rect.y = r.y + 5
		self.rect.w = r.w - 10
		self.rect.h = r.h - 10
		screen:drawrect(basecolor, self.rect)
	end
	
	widget.decorationx = widget.decorationx + 8
end

return this