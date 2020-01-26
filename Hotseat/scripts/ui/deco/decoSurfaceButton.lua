
local this = Class.inherit(DecoSurface)
function this:new(surface_on, surface_hl, surface_off)
	self.surface_on = surface_on
	self.surface_hl = surface_hl or surface_on
	self.surface_off = surface_off or surface_on
end

function this:draw(screen, widget)
	self.surface = self.surface_on
	
	if widget.hovered then
		self.surface = self.surface_hl
	end
	if widget.disabled then
		self.surface = self.surface_off
	end
	
	DecoSurface.draw(self, screen, widget)
end

return this