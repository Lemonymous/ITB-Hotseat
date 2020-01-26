
--[[
	small library to easily set up custom hooks.
	
	example:
	
	-- set up a new hook.
	----------------------
	hooks:new("ThingHappened")
	
	
	-- (un)register a function to hook.
	------------------------------------
	hooks:addThingHappenedHook(function(data1, data2, etc)
		LOG("a thing happened")
	end)
	
	or
	
	-- using a function with a reference to will allow you to remove it later.
	local function AThingHappened(data1, data2, etc)
		LOG("a thing happened")
	end
	
	hooks:addThingHappenedHook(AThingHappened)
	hooks:remThingHappenedHook(AThinkHappened)
	
	
	-- fire all functions registered to a hook.
	--------------------------------------------
	local data1, data2, etc = 1, 2, 3
	fireThingHappenedHooks(data1, data2, etc)
]]

local this = {}

function this:new(name)
	local Name = name:gsub("^.", string.upper) -- capitalize first letter
	self[name .."Hooks"] = {}
	
	self["add".. Name .."Hook"] = function(self, fn)
		assert(type(fn) == 'function')
		table.insert(self[name .."Hooks"], fn)
	end
	
	self["rem".. Name .."Hook"] = function(self, fn)
		remove_element(fn, self[name .."Hooks"])
	end
	
	self["fire".. Name .."Hooks"] = function(self, ...)
		for _, fn in ipairs(self[name .."Hooks"]) do
			fn(...)
		end
	end
end

return this