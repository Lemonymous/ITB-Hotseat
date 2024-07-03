
local path = modApi:getCurrentMod().resourcePath
local scripts = path .."scripts/"
local clip = require(scripts .."libs/clip")
local DecoSet = require(scripts .."ui/deco/decoSet")
local DecoFrame2 = require(scripts .."ui/deco/decoFrame2")
local DecoSolid2 = require(scripts .."ui/deco/decoSolid2")
local Ui2 = require(scripts .."ui/Ui2")
local this = Class.inherit(Ui2)
local color_hp = sdl.rgb(50, 255, 50)

hpSize = {
	32, 38, 42, 46, 46, 42, 48, 38, 42, 46,
	50, 54
}

function this:new(loc, hpMax, hp)
	assert(type(loc) == 'table')
	assert(type(loc.x) == 'number')
	assert(type(loc.y) == 'number')
	assert(type(hpMax) == 'number')
	assert(type(hp) == 'number')
	
	Ui2.new(self)
	self.translucent = true
	
	local w = hpSize[hpMax] or 60
	local slot_w = (w - 6) / hpMax - 2
	local d = {}
	
	self:pospx(loc.x, loc.y)
		:widthpx(w):heightpx(18)
		
	d[#d+1] = DecoSet(-22, -26)
	d[#d+1] = DecoFrame2(deco.colors.framebg, deco.colors.white, 2)
	d[#d+1] = DecoSet(-18, -22)
	for i = 1, hp do
		d[#d+1] = DecoSolid2(color_hp, {w = slot_w, h = 10})
		d[#d+1] = DecoAlign(slot_w + 2, 0)
	end
	
	self:decorate(d)
end

function this:draw(screen)
	clip(Ui2, self, screen)
end

return this