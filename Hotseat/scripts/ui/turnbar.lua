
local path = mod_loader.mods[modApi.currentMod].resourcePath
local Ui2 = require(path .."scripts/ui/Ui2")
local DecoSet = require(path .."scripts/ui/deco/decoSet")
local font36 = sdlext.font("fonts/JustinFont11Bold.ttf", 36)
local font13 = sdlext.font("fonts/Justin15.ttf", 14)
local this = Class.inherit(Ui2)

--"fonts/JustinFontXX.ttf" XX = 7, 8, 10, 11, 12
--"fonts/JustinFontXXBold.ttf" XX = 11, 12
--"fonts/JustinXX.ttf" XX = 13, 15

local surf
modApi:appendAsset("img/ui/combat/lmn_turn_boxl.png", path .."img/turn_boxl.png")
modApi:appendAsset("img/ui/combat/lmn_turn_boxc.png", path .."img/turn_boxc.png")
modApi:appendAsset("img/ui/combat/lmn_turn_boxr.png", path .."img/turn_boxr.png")

-- erase the turn box.
modApi:appendAsset("img/ui/combat/turn_box.png", path .."img/empty.png")
Texts["turn_box"] = Text("", Point(INT_MAX, INT_MAX), 0)
Texts["sub_turn_box"] = Text("", Point(INT_MAX, INT_MAX), 0)

function this:new(text, duration)
	text = text or {}
	local title = text.title or "PLAYER TURN"
	local desc = text.desc or "X Turns Remaining"
	
	Ui2.new(self)
	
	self.uiText = Ui2()
		:decorate{
			DecoAlign(5,-14),
			DecoCAlignedText(title, font36),
			DecoSet(0, 0),
			DecoAlign(-4,16),
			DecoCAlignedText(desc, font13)
		}
		:addTo(self)
	
	function self.uiText:update(screen)
		self:widthpx(self.parent.w):heightpx(self.parent.h)
		self.parent:relayout()
	end
	
	if duration then
		self.animations.fadeOut = UiAnim(self, duration * 1000, function() end)
		self.animations.fadeOut.onFinished = function(self, widget) widget:detach() end
		self.animations.fadeOut:start()
	end
end

function this:update(screen)
	if not surf then
		surf = {
			l = sdlext.surface("img/ui/combat/lmn_turn_boxl.png"),
			c = sdlext.surface("img/ui/combat/lmn_turn_boxc.png"),
			r = sdlext.surface("img/ui/combat/lmn_turn_boxr.png")
		}
	end
	
	local d = {}
	d[#d+1] = DecoSurface(surf.l)
	for i = 1, screen:w() - surf.l:w() - surf.r:w() do
		d[#d+1] = DecoSurface(surf.c)
	end
	d[#d+1] = DecoSurface(surf.r)
	
	self:widthpx(screen:w()):heightpx(surf.c:h())
	self:pospx(0, screen:h()/2 - 40)
	self:decorate(d)
	self.parent:relayout()
	self.uiText:update(screen)
end

return this