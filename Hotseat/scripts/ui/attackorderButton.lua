
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local menu = require(path .."libs/menu")
local clip = require(path .."libs/clip")
local Ui2 = require(path .."ui/Ui2")
local DecoSurfaceButton = require(path .."ui/deco/decoSurfaceButton")
local this = Class.inherit(Ui2)
local surf_on = sdlext.surface("img/ui/combat/attackorder_on.png")
local surf_hl = sdlext.surface("img/ui/combat/attackorder_select.png")
local surf_off = surf_on
local text_on = sdlext.getSurface{
	path = mod.resourcePath .."img/attack_order.png",
	transformations = {{ outline = { border = 2, color = deco.colors.black }}}
}
local text_hl = sdlext.getSurface{
	path = mod.resourcePath .."img/attack_order_hl.png",
	transformations = {{ outline = { border = 2, color = deco.colors.black }}}
}
local text_off = text_on
local deco_attackorder_image = DecoSurfaceButton(surf_on, surf_hl, surf_off)
local deco_attackorder_text = DecoSurfaceButton(text_on, text_hl, text_off)

function this:new()
	Ui2.new(self)

	self:clip()
	self:widthpx(71):heightpx(84)
		:decorate{
			deco_attackorder_image,
			DecoAnchor(),
			DecoAlign(3, -3),
			deco_attackorder_text
		}
end

function this:update(screen)
	self:pospx(Buttons["combat_order"].pos.x, Buttons["combat_order"].pos.y)
	self.parent:relayout()
end

-- hack:
-- pass through any mousemove event in order
-- to let the vanilla ui object detect when
-- the cursor leaves the object
function this:mousemove()
	return false
end

function this:draw(screen)
	if sdlext.isEscapeMenuWindowVisible() or sdlext.isConsoleOpen() then
		return
	end

	Ui2.draw(self, screen)
end

return this
