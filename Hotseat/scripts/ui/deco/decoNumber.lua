
local mod = modApi:getCurrentMod()
local path = "img/combat/icons/damage_"

modApi:appendAsset("img/combat/icons/damage_dash_small.png", mod.resourcePath .."img/dash.png")

local extra = {
	"dash",
	"dash_small",
}

local this = Class.inherit(DecoSurface)
function this:new(number, scale, color)
	local surface = nil
	
	if list_contains(extra, number) or number <= 18 then
		local path = path .. number ..".png"
		local colormap = color and {sdl.rgb(255,255,255), color}
		
		surface = sdlext.getSurface{
			path = path,
			scale = scale,
			colormap = colormap
		}
	end
	
	DecoSurface.new(self, surface)
end

return this