
-- returns the top corner of an in-game tile in screen coordinates.
local function tileToScreen(p)
	assert(type(p) == 'userdata')
	assert(type(p.x) == 'number')
	assert(type(p.y) == 'number')
	
	local scale = GetBoardScale()
	local uiScale = GetUiScale()
	local screen = sdl.screen()

	--if not Board then return nil end
	
	local tile_width = 28 * uiScale
	local tile_height = 21 * uiScale
	
	-- Top corner of the (0, 0) tile
	local tile00 = {
		x = screen:w() / 2,
		y = screen:h() / 2 - 8 * tile_height * scale
	}
	
	if scale == 2 then
		tile00.y = tile00.y + 5 * scale * uiScale + 0.5
	end
	
	return {
		x = tile00.x + (tile_width * (p.x - p.y))  * scale,
		y = tile00.y + (tile_height * (p.x + p.y)) * scale
	}
end

return tileToScreen