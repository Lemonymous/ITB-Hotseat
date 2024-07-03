
local path = modApi:getCurrentMod().scriptPath
local tileToScreen = require(path .."libs/tileToScreen")
local Ui2 = require(path .."ui/Ui2")
local this = Class.inherit(Ui2)

local get = {
	"type",
	"outline",
	"tile"
}

function this:new(type)
	Ui2.new(self)
	
	self:width(1):height(1)
	self.type = type
	self.outline = sdl.rgb(255, 255, 0)
	self.cliprect = sdl.rect(0, 0, 0, 0)
	self.translucent = true
	self:decorate{ DecoSurface() }
	local dec = self.decorations[1]
	
	function dec.draw(self, screen, widget)
		if not widget:getCoord() then return end
		if not widget:getType() then return end
		if self.surface == nil then return end
		
		local clip = widget.cliprect
		local r = widget.rect
		local pr = widget.parent.rect
		clip = sdl.rect(clip.x - pr.x, clip.y - pr.y, clip.w, clip.h)
		screen:clip(clip)
		
		screen:blit(
			self.surface,
			nil,
			r.x - pr.x,
			r.y - pr.y
		)
		screen:unclip()
	end
	
	function dec.update(self, screen, widget)
		widget._type = widget:getType()
		widget._scale = widget:getScale()
		widget._outline = widget:getOutline()
		
		local path = ""
		if widget._type then
			assert(_G[widget._type])
			path = "img/".. ANIMS[_G[widget._type].Image].Image
		end
		
		self.surface = sdlext.getSurface{
			path = path,
			scale = widget._scale or 2,
			outline = { border = widget._scale or 2, color = widget._outline or deco.colors.buttonborder }
		}
	end
end

-- add base get functions
for _, v in ipairs(get) do
	local V = v:gsub("^.", string.upper) -- capitalize first letter
	this["get".. V] = function(self) return self[v] or self["_".. v] end
end

function this:getCoord()
	if self.coord then return self.coord end
	
	local tile = self:getTile()
	return tile and tileToScreen(tile) or nil
end

function this:getScale()
	return self.scale or GetBoardScale() * GetUiScale()
end

function this:isUpdate(screen)
	local ret = Ui2.isUpdate(self, screen)
	
	ret =
		ret or
		self._coord ~= self:getCoord() or
		self._scale ~= self:getScale()
		
	return ret
end

function this:canUpdate(screen)
	return
		self:getType()				and
		self:getCoord()				and
		self:getScale()				and
		self.decorations[1].surface and
		self.cliprect
end

function this:update(screen)
	if
		self._type ~= self:getType()       or
		self._scale ~= self:getScale()     or
		self._outline ~= self:getOutline()
	then
		if self:getType() then
			self.decorations[1]:update(screen, self)
		end
	end
	
	if not self:canUpdate(screen) then return true end
	
	self._coord = self:getCoord()
	self._scale = self:getScale()
	
	local coord = self._coord
	local scale = self._scale or 1
	local surface = self.decorations[1].surface
	local data = _G[self:getType()]
	local anim = ANIMS[data.Image]
	
	self:widthpx(surface:w())
		:heightpx(surface:h())
		:pospx(coord.x, coord.y)
	local w = math.floor(surface:w() / (anim.NumFrames or 1))
	local h = math.floor(surface:h() / (anim.Height or 1))
	local offset = self.offset or Point(0,0)
	self.x = self.x + (anim.PosX + offset.x) * scale
	self.y = self.y - h * data.ImageOffset + (anim.PosY - offset.y) * scale
	self.parent:relayout()
	self.cliprect = sdl.rect(self.screenx, self.screeny + h * data.ImageOffset, w, h)
end

return this