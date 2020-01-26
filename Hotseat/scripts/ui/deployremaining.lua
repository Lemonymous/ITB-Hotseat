
local path = mod_loader.mods[modApi.currentMod].scriptPath
local clip = require(path .."libs/clip")
local Ui2 = require(path .."ui/Ui2")
local UiCover = require(path .."ui/cover")
local UiPawn = require(path .."ui/pawn")
local this = Class.inherit(Ui2)
local pawnBox = {x = 36, y = 36}

function this:new(type)
	Ui2.new(self)
	
	self:decorate{
		DecoFrame(deco.colors.framebg, deco.colors.buttonborder, 2),
		DecoAlign(0, -2),
		DecoText(
			"Remaining units:",
			deco.uifont.tooltipText.font,
			deco.uifont.tooltipText.set
		)
	}
	self.uiRemaining = Ui2():addTo(self)
	self._types = {}
	
	UiCover(
		{
			align = {x = -2, y = -2}
		}
	):addTo(self)
end

local function getCoord(self)
	local parent = self.parent.parent
	if not self:getType() then return nil end
	if not self.decorations[1].surface then return nil end
	if not parent.decorations[3].surface then return nil end
	
	local surface = self.decorations[1].surface
	local scale = self:getScale()
	local data = _G[self:getType()]
	local anim = ANIMS[data.Image]
	local w = math.floor(surface:w() / (anim.NumFrames or 1))
	local h = math.floor(surface:h() / (anim.Height or 1))
	
	return {
		x = parent.x + parent.decorations[3].surface:w() + self.order * pawnBox.x + pawnBox.x / 2 - anim.PosX * scale - w / 2,
		y = parent.y + Boxes["deploy_remaining"].h / 2 - anim.PosY * scale - h / 2
	}
end

function this:getTypes()
	return {}
end

function this:hasChanged()
	for i, v in ipairs(self:getTypes()) do
		if self._types[i] ~= v then
			return true
		end
	end
	return false
end

function this:isUpdate(screen)
	return
		Ui2.isUpdate(self, screen) or
		self:hasChanged()
end

function this:update(screen)
	
	if self:hasChanged() then
		for i = #self:getTypes() + 1, #self._types do
			local child = self.uiRemaining.children[i]
			if child then child:detach() end
		end
		self._types = shallow_copy(self:getTypes())
		
		for i, type in ipairs(self._types) do
			local child = self.uiRemaining.children[i]
			if not child then
				child = UiPawn(type):addTo(self.uiRemaining)
				child.outline = deco.colors.buttonborder
				child.scale = 1
				child.order = i - 1
				child.getCoord = getCoord
			else
				child.type = type
			end
		end
	end
	
	self
		:pospx(Boxes["deploy_remaining"].x, Boxes["deploy_remaining"].y)
		:widthpx(150 + #self._types * pawnBox.x):heightpx(22)
		
	self.parent:relayout()
end

function this:draw(screen)
	self.visible =
		not sdlext.isConsoleOpen() and
		#self:getTypes() > 0
	
	clip(Ui2, self, screen)
end

return this