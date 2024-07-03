
local path = modApi:getCurrentMod().scriptPath
local tileToScreen = require(path .."libs/tileToScreen")
local UiPawn = require(path .."ui/pawn")
local Ui2 = require(path .."ui/Ui2")
local this = Class.inherit(UiPawn)

local paths = {
	"img/combat/deployment_arrow.png",
	"img/combat/deployment_swap.png",
	"img/combat/deployment_x.png",
	"",
}

local surface = {}
for i, v in ipairs(paths) do
	surface[i] = sdlext.surface(v)
end

local offset = {
	{x = -27, y = -21},
	{x = -32, y = 18.5},
	{x = -27, y = 19}
}

this.DEPLOY_VALID = 1
this.DEPLOY_SWAP = 2
this.DEPLOY_INVALID = 3

function this:new(...)
	UiPawn.new(self, ...)
	self.drawBelowChildren = true
	self.offset = Point(0,18)
	self.traslucent = true
	
	local uiArrow = Ui2()
		:decorate{ DecoSurface() }
		:setTranslucent()
		:addTo(self)
	
	function self:update(screen)
		if UiPawn.update(self, screen) then return true end
		uiArrow:update(screen)
	end
	
	local dec = uiArrow.decorations[1]
	function dec:update(screen, widget)
		widget.parent._tileCode = widget.parent:getTileCode()
		
		local scale = widget.parent:getScale()
		local color = widget.parent:getOutline()
		local colormap = color and {sdl.rgb(255,255,255), color}
		local tileCode = widget.parent._tileCode or 4
		
		self.surface = sdlext.getSurface{
			path = paths[tileCode],
			scale = scale,
			colormap = colormap
		}
	end
	
	function dec:draw(screen, widget)
		if not widget.parent:getTile() then return end
		if not widget.parent:getType() then return end
		
		DecoSurface.draw(self, screen, widget)
	end
	
	function uiArrow:getOffset()
		if not self.parent._tileCode then return {x = 0, y = 0} end
		
		return offset[self.parent._tileCode]
	end
	
	function uiArrow:canUpdate(screen)
		return
			self.parent:getTile()		and
			self.parent:getTileCode()	and
			self.decorations[1].surface
	end
	
	function uiArrow:update(screen)
		if self.parent._tileCode ~= self.parent:getTileCode() then
			self.decorations[1]:update(screen, self)
		end
		
		if not self:canUpdate(screen) then return true end
		
		local tile = self.parent:getTile()
		local surface = self.decorations[1].surface
		local coord = tileToScreen(tile)
		local offset = self:getOffset()
		coord.x = coord.x + offset.x
		coord.y = coord.y + offset.y
		self:widthpx(surface:w()):heightpx(surface:h())
		self:pospx(coord.x - self.parent.x, coord.y - self.parent.y)
		self.parent:relayout()
	end
end

function this:getTileCode()
	return self.DEPLOY_VALID
end

return this
