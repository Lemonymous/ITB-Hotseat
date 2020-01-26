
-- modified Ui element with additional update functions
-- intended to make updating dimentions and decorations
-- on screen changes and other custom events easier.

local this = Class.inherit(Ui)

function this:new()
	Ui.new(self)
end

function this:isUpdate(screen)
	if self.lastscreenx ~= screen:w() or self.lastscreeny ~= screen:h() then
		self.lastscreenx = screen:w()
		self.lastscreeny = screen:h()
		return true
	end
	return false
end

function this:width(w)
	self._wPercent = w
	
	return Ui.width(self, w)
end

function this:height(h)
	self._hPercent = h
	
	return Ui.height(self, h)
end

function this:widthpx(w)
	self.wPercent = nil
	self._wPercent = nil
	
	return Ui.widthpx(self, w)
end

function this:heightpx(h)
	self.hPercent = nil
	self._hPercent = nil
	
	return Ui.heightpx(self, h)
end

function this:pos(x, y)
	self._xPercent = x
	self._yPercent = y
	
	return Ui.pos(self, x, y)
end

function this:pospx(x, y)
	self.xPercent = nil
	self.yPercent = nil
	self._xPercent = nil
	self._yPercent = nil
	
	return Ui.pospx(self, x, y)
end

function this:setxpx(x)
	self.xPercent = nil
	self._xPercent = nil
	
	return Ui.setxpx(self, x)
end

function this:setypx(y)
	self._xPercent = nil
	self._yPercent = nil
	
	return Ui.setypx(self, y)
end

function this:update(screen)
	self.wPercent = self._wPercent
	self.hPercent = self._hPercent
	self.xPercent = self._xPercent
	self.yPercent = self._yPercent
end

local function reversedDraw(self, screen)
	if not self.visible then return end
	
	if self.animations then
		for _, anim in pairs(self.animations) do
			anim:update(modApi:deltaTime())
		end
	end
	
	self.decorationx = 0
	self.decorationy = 0
	for i=#self.children,1,-1 do
		local child = self.children[i]
		child:draw(screen)
	end
	
	self.decorationx = 0
	self.decorationy = 0
	for i=1,#self.decorations do
		local decoration = self.decorations[i]
		decoration:draw(screen, self)
	end
end

function this:draw(screen)
	self._isUpdate = self._isUpdate or self:isUpdate(screen)
	
	if self._isUpdate then
		-- if update returns true, retry update next frame.
		self._isUpdate = self:update(screen)
	end
	
	if self.drawBelowChildren then
		reversedDraw(self, screen)
	else
		Ui.draw(self, screen)
	end
end

return this