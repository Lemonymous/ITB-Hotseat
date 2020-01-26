
local this = Class.inherit(UiDeco)

function this:new(x, y)
	UiDeco.new(self)
	self.decosetx = x or nil
	self.decosety = y or nil
end

function this:draw(screen, widget)
	if self.decosetx then
		widget.decorationx = self.decosetx
	end
	
	if self.decosety then
		widget.decorationy = self.decosety
	end
end

return this