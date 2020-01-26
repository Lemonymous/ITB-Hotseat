
--[[
	this library can be used to add code that needs to run after all mods have been initialized.
	
		---
	
	finalize order will be the same as when mods are initilized,
	so if you need some code to run sequentially after another specific mod,
	a better approach is to initialize after that mod.
	
	order:
	------
	init all mods
	finalize
	load all mods
]]

local this = {}
local funcs = {}

function this:addFunc(fn, ...)
	assert(funcs, "game has already been finalized")
	
	funcs[#funcs+1] = {fn = fn, data = {...}}
end

local old = modApi.finalize
function modApi.finalize(...)
	for _, v in ipairs(funcs) do
		v.fn(unpack(v.data))
	end
	
	funcs = nil
	old(...)
end

return this