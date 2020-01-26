
local path = mod_loader.mods[modApi.currentMod].scriptPath
local menu = require(path .."libs/menu")
local clip = require(path .."libs/clip")
local Ui2 = require(path .."ui/Ui2")
local DecoSurfaceButton = require(path .."ui/deco/decoSurfaceButton")
local this = Class.inherit(Ui2)
local surf_on = sdlext.surface("img/ui/combat/attackorder_on.png")
local surf_hl = sdlext.surface("img/ui/combat/attackorder_select.png")
local surf_off = surf_on

function this:new()
	Ui2.new(self)
	
	self:widthpx(71):heightpx(84)
		:decorate{ DecoSurfaceButton(surf_on, surf_hl, surf_off) }
end

function this:isUpdate(screen)
	return Ui2.isUpdate(self, screen) or (self._menuOpen ~= (menu.isOpen() or sdlext.isConsoleOpen()))
end

function this:update(screen)
	self._menuOpen = menu.isOpen() or sdlext.isConsoleOpen()
	if self._menuOpen then
		self:decorate{ DecoSurfaceButton() }
	else
		-- good enough.
		self:decorate{ DecoSurfaceButton(surf_on, surf_hl, surf_off) }
	end
	
	self:pospx(Buttons["combat_order"].pos.x, Buttons["combat_order"].pos.y)
	self.parent:relayout()
end

function this:draw(screen)
	clip(Ui2, self, screen)
end

return this