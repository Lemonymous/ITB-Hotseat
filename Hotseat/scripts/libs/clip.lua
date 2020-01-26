
--[[
	provides a function to automatically clip a ui element in relation to sdlext.CurrentWindowRect
	
	call clip in place of ui.draw.
]]

local rect = {
	l = sdl.rect(0,0,0,0),
	t = sdl.rect(0,0,0,0),
	r = sdl.rect(0,0,0,0),
	b = sdl.rect(0,0,0,0)
}
local function this(base, widget, screen)
	local menu = sdlext.CurrentWindowRect
	local res = { w = screen:w(), h = screen:h() }
	rect.l.w = math.max(0, menu.x)
	rect.l.h = res.h
	rect.t.w = res.w
	rect.t.h = math.max(0, menu.y)
	rect.r.x = math.min(menu.x + menu.w, res.w)
	rect.r.w = res.w - rect.r.x
	rect.r.h = res.h
	rect.b.y = math.min(menu.y + menu.h, res.h)
	rect.b.w = res.w
	rect.b.h = res.h - rect.r.y
	
	local tmp = modApi.msDeltaTime
	local updated
	
	for _, r in pairs(rect) do
 		screen:clip(r)
		if updated then
			modApi.msDeltaTime = 0
		end
		updated = true
		base.draw(widget, screen)
 		screen:unclip()
	end
	
	modApi.msDeltaTime = tmp
end

return this
