
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local utils = require(path .."libs/utils")
local menu = require(path .."libs/menu")
local UiAnim2 = require(path .."ui/anim/uiAnim2")
local UiCover = require(path .."ui/cover")
local Ui2 = require(path .."ui/Ui2")
local this = Class.inherit(UiCover)

function this:new(adjust, color, duration_in, duration_out)
	UiCover.new(self, adjust, color, duration)
	
	self:width(1):height(1)
	
	self.animations.fade = nil
	self.animations.fadeout = UiAnim2(self, duration_out or 100, function(anim, widget, percent)
		widget.fadein = false
		widget.fadeout = percent
	end)
	
	self.animations.fadein = UiAnim2(self, duration_in or 100, function(anim, widget, percent)
		widget.fadein = percent
		widget.fadeout = false
	end)
	
	function self.animations.fadein:update(dt)
		local widget = self.widget
		local currentAnim = widget.currentAnim
		
		if menu.isOpen() or sdlext.isConsoleOpen() or widget.isDestroy then
			if currentAnim.anim == self then
				widget.isFade = false
				self:stop()
				widget.animations.fadeout:start((1 - currentAnim.percent) * widget.animations.fadeout.msTimeTotal)
			end
		elseif currentAnim.anim == widget.animations.fadeout then
			widget.animations.fadeout:stop()
			self:start((1 - currentAnim.percent) * self.msTimeTotal)
		end
		
		UiAnim2.update(self, dt)
	end
	
	self.animations.fadein.onStarted = function(anim, widget)
		widget.isFade = false
	end
	
	self.animations.fadein.onFinished = function(anim, widget)
		widget.isFade = true
	end
	
	self.animations.fadeout.onStarted = function(anim, widget)
		widget.isFade = false
	end
	
	self.animations.fadeout.onFinished = function(anim, widget)
		widget.isFade = false
		if widget.isDestroy then
			widget.onDestroy()
		end
	end
	
	self.animations.fadein:start()
end

function this:isUpdate(screen)
	return
		self._fadein ~= self.fadein or
		self._fadeout ~= self.fadeout or
		Ui2.isUpdate(self, screen)
end

function this:update(screen)
	self._fadein = self.fadein
	self._fadeout = self.fadeout
	
	if self.fadeout then
		local percent = utils.interpolate(self.fadeout, 0, 1, 1, 1)
		self.decorations[2].color = InterpolateColor(
			self.color,
			self.colorTransparent,
			percent
		)
	elseif self.fadein then
		local percent = utils.interpolate(self.fadein, 1, 1, 1, 0)
		self.decorations[2].color = InterpolateColor(
			self.color,
			self.colorTransparent,
			percent
		)
	end
	
	Ui2.update(self, screen)
end

-- opens the ui and destroys itself after calling back function fn.
function this:destroy(fn)
	assert(type(fn) == 'function')
	
	self.isDestroy = true
	self.onDestroy = fn
end

function this:draw(screen)
	Ui2.draw(self, screen)
end

return this