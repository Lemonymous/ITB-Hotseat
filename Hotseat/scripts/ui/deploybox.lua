
local path = mod_loader.mods[modApi.currentMod].scriptPath
local font = sdlext.font("fonts/JustinFont11Bold.ttf", 24)
local menu = require(path .."libs/menu")
local clip = require(path .."libs/clip")
local Ui2 = require(path .."ui/Ui2")
local UiCover = require(path .."ui/cover")
local DecoSolid2 = require(path .."ui/deco/decoSolid2")
local UiPawn = require(path .."ui/pawn")
local this = Class.inherit(Ui2)
local pawnBox = {x = 84, y = 84}

function this:new(type)
	Ui2.new(self)
	
	self:decorate{
		DecoFrame(deco.colors.framebg, deco.colors.buttonborder, 2),
		DecoText(nil, font),
		DecoText(
			nil,
			deco.uifont.tooltipText.font,
			deco.uifont.tooltipText.set
		)
	}
	
	self.decorations[2].draw = function(self, screen, widget)
		if widget:getType() then
			widget.decorationx = 85
			widget.decorationy = -14
		else
			widget.decorationx = 5
			widget.decorationy = -14
		end
		DecoText.draw(self, screen, widget)
	end
	
	self.decorations[3].draw = function(self, screen, widget)
		if widget:getType() then
			widget.decorationx = 87
			widget.decorationy = 17
		else
			widget.decorationx = 6
			widget.decorationy = 17
		end
		DecoText.draw(self, screen, widget)
	end
	
	local uiPawn = UiPawn(type):addTo(self)
	uiPawn.outline = deco.colors.buttonborder
	
	function uiPawn:getCoord()
		if not self:getType() then return nil end
		if not self.decorations[1].surface then return nil end
		
		local surface = self.decorations[1].surface
		local scale = self:getScale()
		local data = _G[self:getType()]
		local anim = ANIMS[data.Image]
		local w = math.floor(surface:w() / (anim.NumFrames or 1))
		local h = math.floor(surface:h() / (anim.Height or 1))
		
		return {
			x = self.parent.x + pawnBox.x / 2 - anim.PosX * scale - w / 2,
			y = self.parent.y + pawnBox.y / 2 - anim.PosY * scale - h / 2
		}
	end
	
	function uiPawn:getType(uiPawn)
		return self.parent:getType()
	end
	
	UiCover(
		{
			align = {x = -2, y = -2},
			size = {w = 3, h = 0}
		}
	):addTo(self)
end

function this:getType()
	return self.type or self._type
end

function this:isUpdate(screen)
	local ret = Ui2.isUpdate(self, screen)
	return ret or self._type ~= self:getType()
end

function this:canUpdate(screen)
	return
		self.decorations[2].surface and
		self.decorations[3].surface
end

function this:update(screen)
	if self._type ~= self:getType() then
		self._type = self:getType()
		
		if self._type then
			assert(_G[self._type])
			self.decorations[2]:setsurface("Spawning ".. (_G[self._type].Name or "Mech"))
			self.decorations[3]:setsurface("Select a location in the yellow Spawn Zone")
		else
			self.decorations[2]:setsurface("Spawning Complete")
			self.decorations[3]:setsurface("You may change your placements before confirming")
		end
	end
	
	if not self:canUpdate(screen) then return end
	
	local title = self.decorations[2]
	local desc = self.decorations[3]
	local offsetx = self._type and pawnBox.x or 18
	self
		:pospx(Boxes["deploy_box"].x, Boxes["deploy_box"].y)
		:widthpx(offsetx + math.max(title.surface:w(), desc.surface:w() + 10))
		:heightpx(Boxes["deploy_box"].h)
		
	self.parent:relayout()
end

function this:draw(screen)
	self.visible = not sdlext.isConsoleOpen()
	
	clip(Ui2, self, screen)
end

return this