
local this = Class.inherit(UiDeco)

function this:new(fn, ...)
	self.fn = fn
	self.data = {...}
end

function this:draw(screen, widget)
	self.fn(screen, widget, unpack(self.data))
end

return this