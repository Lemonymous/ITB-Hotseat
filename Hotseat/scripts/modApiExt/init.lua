-- Standalone support.

local debug = false

local function createDebugUi(screen)
	local color = sdl.rgb(255, 0, 255)
	local rect = sdl.rect(0,0,1,1)

	local dpane = Ui()
		:width(1):height(1)

	dpane.translucent = true

	dpane.draw = function(self, screen)
		if not Board or not dpane.visible then
			return
		end

		local uiScale = GetUiScale()
		local tw = 28 * uiScale
		local th = 21 * uiScale

		local scale = GetBoardScale()
		local tws = tw * scale
		local ths = th * scale

		local tile00, lineX, lineY = modApiExt_internal.getScreenRefs(screen, scale)

		local bsize = Board:GetSize()
		for tileY = bsize.y, 0, -1 do
			for tileX = bsize.x, 0, -1 do
				local x = tile00.x + tws * (tileX - tileY)
				local y = tile00.y + ths * (tileX + tileY)

				for i = 0, tws, 1 do
					rect.y = y - lineY(i)

					rect.x = x + i
					screen:drawrect(color, rect)

					rect.x = x - i
					screen:drawrect(color, rect)
				end
			end
		end
	end

	return dpane
end

local function init(self)
	if modApiExt then
		error("`modApiExt` object is already defined! A mod loaded before this "
			.. "one is not following API protocol correctly.")
	else
		modApiExt = require(self.scriptPath.."modApiExt"):init()

		if debug then
			sdlext.addUiRootCreatedHook(function(screen, root)
				createDebugUi(screen):addTo(root)
			end)
		end
	end
end

local function load(self, options, version)
	if modApiExt then
		modApiExt:load(self, options, version)
	else
		-- can happen if the mod was disabled, then enabled via Mod Config
		-- in that case, the mod loader does not execute the init function.
		LOG("ModApiExt: ERROR - Failed to load because modApiExt was not initialized. "
			.. "Restart the game to fix.")
	end
end

return {
	id = "kf_ModUtils",
	name = "Modding Utilities",
	version = "1.12.256", -- mid release version. 255 total commits
	requirements = {},
	init = init,
	load = load
}
