
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local cache = require(path .."libs/cacheSurface")
local this = {}

local function setAdjust(self, adjust)
	adjust = copy_table(adjust) or {}
	adjust.align = adjust.align or {}
	adjust.size = adjust.size or {}
	self.align = adjust.align or {}
	self.size = adjust.size or {}
	self.align.x = adjust.align.x or 0
	self.align.y = adjust.align.y or 0
	self.size.w = adjust.size.w or 0
	self.size.h = adjust.size.h or 0
end

local function draw(self, screen, widget, horizontal)
	if self.surface == nil then return end
	local r = widget.rect

	local x = math.floor(r.x + widget.decorationx + self.size.w / 2 + self.align.x)
	local y = math.floor(r.y + widget.decorationy + self.size.h / 2 + self.align.y)

	screen:blit(self.surface, nil, x, y)
	
	if horizontal then
		widget.decorationx = widget.decorationx + self.surface:w() + self.size.w
	else
		widget.decorationy = widget.decorationy + self.surface:h() + self.size.h
	end
end

for i, name in ipairs{"Horizontal", "Vertical"} do
	this[name] = Class.inherit(DecoSurface)
	
	this[name].new = function(self, tbl, adjust)
		assert(type(tbl) == 'table')
		self:setsurface(tbl.path, tbl.icon, tbl.outline, tbl.colormap)
		
		setAdjust(self, adjust)
	end
	
	this[name].setsurface = function(self, path, icon, outline, colormap)
		self.surface = cache.getSurface{
			path = path,
			icon = icon,
			outline = outline,
			colormap = colormap
		}
	end
	
	local horizontal = i == 1
	this[name].draw = function(self, screen, widget)
		draw(self, screen, widget, horizontal)
	end
end

for i, name in ipairs{"TextHorizontal", "TextVertical"} do
	this[name] = Class.inherit(DecoText)
	
	this[name].new = function(self, text, font, textset, adjust)
		DecoText.new(self, text, font, textset)
		
		setAdjust(self, adjust)
	end
	
	local horizontal = i == 1
	this[name].draw = function(self, screen, widget)
		draw(self, screen, widget, horizontal)
	end
end

return this