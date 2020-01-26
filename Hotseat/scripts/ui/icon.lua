
local path = mod_loader.mods[modApi.currentMod].resourcePath
local scripts = path .."scripts/"
local cache = require(scripts .."libs/cacheSurface")
local menu = require(scripts .."libs/menu")
local clip = require(scripts .."libs/clip")
local Ui2 = require(scripts .."ui/Ui2")
local this = Class.inherit(Ui2)

function this:new(loc, icon, scale)
	assert(type(loc) == 'table')
	assert(type(loc.x) == 'number')
	assert(type(loc.y) == 'number')
	assert(type(icon) == 'string')
	
	Ui2.new(self)
	self.translucent = true
	
	local surface = cache.getSurface{
		path = icon,
		scale = scale
	}
	
	self:pospx(loc.x, loc.y)
		:decorate{ DecoSurface(surface) }
end

function this:draw(screen)
	clip(Ui2, self, screen)
end

return this