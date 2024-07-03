
local path = modApi:getCurrentMod().scriptPath
local clip = require(path .."libs/clip")
local Ui2 = require(path .."ui/Ui2")
local UiCover = require(path .."ui/cover")
local DecoButton2 = require(path .."ui/deco/decoButton2")
local font = sdlext.font("fonts/JustinFont11Bold.ttf", 24)
local this = Class.inherit(Ui2)
local colors = {
	button_flash = sdl.rgb(150, 140, 100)
}

function this:new()
	Ui2.new(self)
	
	self:widthpx(181):heightpx(60)
	self:decorate{
		DecoButton2(),
		DecoAlign(-5,4),
		DecoCAlignedText("CONFIRM", font, deco.uifont.title.set)
	}
	
	-- 100% -> reverse anim.
	local anim = UiAnim(self, 500, function(anim, widget, percent)
		
		widget.decorations[1].color = InterpolateColor(
			deco.colors.button,
			colors.button_flash,
			anim.reverse and 1 - percent or percent
		)
		
		if percent == 1 then
			anim.reverse = not anim.reverse
			anim:start()
		end
	end)
	
	function anim:isDone()
		return false
	end

	self.animations.flash = anim
	self.animations.flash:start()
	
	UiCover(
		{
			align = {x = -5, y = -5}
		}
	):addTo(self)
end

function this:update(screen)
	self:pospx(Buttons["deployment_done"].pos.x, Buttons["deployment_done"].pos.y)
	self.parent:relayout()
end

function this:draw(screen)
	clip(Ui2, self, screen)
end

return this