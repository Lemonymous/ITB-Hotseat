
--[[ provides functions to suspend a mission until a set condition is met.
	
]]

local mod = modApi:getCurrentMod()
local missionExt = require(mod.scriptPath .."libs/missionExt")
local name = mod.id .."_SuspendLoop"
local this = { funcs = {} }
_G[name] = this

-- silly solution, but it should work.
local function getUniqueIndex()
	local index = 0
	
	for _, v in ipairs(this.funcs) do
		if v.index >= index then
			index = v.index + 1
		end
	end
	
	return index
end

local function getFn(index)
	for _, v in ipairs(this.funcs) do
		if v.index == index then
			return v.fn
		end
	end
end

local function rem(index)
	for i, v in ipairs(this.funcs) do
		if v.index == index then
			table.remove(this.funcs, i)
			break
		end
	end
end

-- assumption: game does not save when the board is busy.
-- this loop causes the board to be busy, so anything happening during the loop will not be saved.
-- the game can have saved as the effect is starting,
-- so suspend.start will need to be called manually after loading/resetting if the game saved at that point.

function this.effect(i)
	local ret = SkillEffect()
	local fn = getFn(i)
	
	-- end effect if not in a mission anymore or current mission had ended.
	if missionExt.isMission() and not missionExt.hasEnded() and fn and fn() then
		ret:AddScript(string.format("Board:AddEffect(_G[%q].effect(%s))", name, i))
	else
		rem(i)
	end
	
	return ret
end

modApi.events.onGameExited:subscribe(function()
	this.funcs = {}
end)

-- suspends the game until function fn returns false.
function this.start(fn)
	local m = GetCurrentMission()
	assert(type(fn) == 'function')
	assert(type(m) == 'table', "trying to suspend mission loop outside of a mission")
	
	local entry = {fn = fn, index = getUniqueIndex()}
	table.insert(this.funcs, entry)
	
	Board:AddEffect(_G[name].effect(entry.index))
end

return this