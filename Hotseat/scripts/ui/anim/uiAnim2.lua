
local this = Class.inherit(UiAnim)

function this:new(widget, msTimeTotal, animFunc)
	widget.currentAnim = widget.currentAnim or {}
	
	local animFunc = function(anim, widget, percent, ...)
		widget.currentAnim = {anim = anim, percent = percent}
		
		return animFunc(anim, widget, percent, ...)
	end
	
	UiAnim.new(self, widget, msTimeTotal, animFunc)
end

function this:update(msDeltaTime)
	msDeltaTime = msDeltaTime or 0

	if self:isStarted() then
		self:setTime(self.msTimeCurrent + msDeltaTime)
	end
end

return this