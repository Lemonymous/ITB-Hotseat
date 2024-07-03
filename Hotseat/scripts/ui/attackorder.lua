
local path = modApi:getCurrentMod().scriptPath
local font = sdlext.font("fonts/JustinFont11Bold.ttf", 24)
local menu = require(path .."libs/menu")
local clip = require(path .."libs/clip")
local Ui2 = require(path .."ui/Ui2")
local UiCover = require(path .."ui/cover")
local DecoSolid2 = require(path .."ui/deco/decoSolid2")
local DecoNumber = require(path .."ui/deco/decoNumber")
local DecoSet = require(path .."ui/deco/decoSet")
local UiCover = require(path .."ui/cover")
local tileToScreen = require(path .."libs/tileToScreen")
local this = Class.inherit(Ui2)
local textDim = {t = 11, b = 19, h = 40}

function this:new()
	Ui2.new(self)
	
	self:decorate{ DecoFrame(deco.colors.framebg, deco.colors.white, 3) }
	local cover = UiCover{ align = {x = -3, y = -3} }:addTo(self)
	self.uiTexts = Ui2():addTo(self)
	self._texts = {}
	
	if menu.isOpen() then
		cover.animations.fade:setInitialPercent(100)
		cover.decorations[2].color = cover.color
	end
end

function this:hasChanged()
	local texts = self:getTexts()
	for i, v in ipairs(texts) do
		local cached = self._texts[i]
		if
			#texts ~= #self._texts	or
			not cached				or
			cached.count ~= v.count	or
			cached.text ~= v.text	or
			cached.icon ~= v.icon
		then
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

function this:getTexts()
	return {}
end

function this:update(screen)
	if self:hasChanged() then
		local texts = self:getTexts()
		for i = #texts + 1, #self._texts do
			local child = self.uiTexts.children[i]
			if child then child:detach() end
		end
		self._texts = shallow_copy(texts)
		local widget = self.uiTexts
		local dec = {DecoAlign(7, 28)}
		local order = 1
		
		for i, v in ipairs(self._texts) do
			local color_text, color_num
			
			if v.count > 0 then
				color_text = sdl.rgb(255,255,255)
				color_num = sdl.rgb(255,50,50)
			else
				color_text = sdl.rgb(128,128,128)
				color_num = sdl.rgb(128,128,128)
			end
			
			dec[#dec+1] = DecoSet(7, nil)
			if not v.count or v.count <= 0 then
				dec[#dec+1] = DecoNumber(0, 2, color_num)
			elseif v.count == 1 then
				dec[#dec+1] = DecoNumber(order, 2, color_num)
			else
				dec[#dec+1] = DecoNumber(order, 2, color_num)
				dec[#dec+1] = DecoAlign(-10, 0)
				dec[#dec+1] = DecoNumber("dash_small", 2, color_num)
				dec[#dec+1] = DecoAlign(-7, 0)
				dec[#dec+1] = DecoNumber(order + v.count - 1, 2, color_num)
			end
			dec[#dec+1] = DecoText(v.text, deco.uifont.tooltipTextLarge.font, deco.textset(color_text, nil, nil, true))
			
			if v.icon then
				local icon, color, surface = v.icon
				if type(v.icon) == 'table' then
					icon = v.icon.path
					color = v.icon.color
					scale = v.icon.scale
				end
				
				surface = sdlext.surface(icon)
				
				if scale then
					surface = sdl.scaled(scale, surface)
				end
				
				if color then
					local colormap = {sdl.rgb(255,255,255), color}
					surface = sdl.colormapped(surface, colormap)
				end
				
				dec[#dec+1] = DecoSurface(surface)
			end
			dec[#dec+1] = DecoAlign(0, textDim.h)
			
			order = order + v.count
		end
		
		self.uiTexts:decorate(dec)
	end
	
	self
		:pospx(Boxes["objective_turncount"].x, Boxes["objective_turncount"].y)
		:widthpx(Boxes["objective_turncount"].w)
		:heightpx(textDim.t + textDim.b + #self._texts * textDim.h)
		
	self.parent:relayout()
end

function this:draw(screen)
	self.visible = not sdlext.isConsoleOpen()
	
	clip(Ui2, self, screen)
end

return this