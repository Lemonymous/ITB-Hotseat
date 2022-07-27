
--[[
	replacement for old library.
	call mod loader functions to check whether the escape menu is open or closed.
]]

return {
	isOpen = function()
		return sdlext.isEscapeMenuWindowVisible()
	end,
	isClosed = function()
		return not sdlext.isEscapeMenuWindowVisible()
	end
}
