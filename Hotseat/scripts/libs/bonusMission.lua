
local objs = {}

local add = {
	[REWARD_POWER] = 0,
	[REWARD_TECH] = 0,
	[REWARD_REP] = 0
}

local multiply = {
	[REWARD_POWER] = 0,
	[REWARD_TECH] = 0,
	[REWARD_REP] = 0
}

local power_extra = 0

local function copyObj(obj)
	local ret = {}
	
	ret.rep = obj.rep
	ret.potential = obj.potential
	
	return ret
end

local function change(obj)
	if not obj.hotseat then
		objs[#objs+1] = {bak = copyObj(obj), curr = obj}
		obj.hotseat = true
		
		local multiply = multiply[obj.category]
		if multiply and multiply > 0 then
			obj.rep = obj.rep * multiply
			obj.potential = obj.potential * multiply
		end
		
		local add = add[obj.category]
		if add and add > 0 then
			local ratio = obj.rep / obj.potential
			
			obj.rep = obj.rep + math.ceil(add * ratio)
			obj.potential = obj.potential + add
		end
	end
end

local old = Mission.GetObjectiveList
function Mission:GetObjectiveList(...)
	local ret = old(self, ...)
	
	for _, obj in ipairs(ret) do
		change(obj)
	end
	
	return ret
end

local old = Mission.BaseCompletedObjectives
function Mission:BaseCompletedObjectives(...)
	local ret = old(self, ...)
	
	for _, obj in ipairs(ret) do
		change(obj)
	end
	
	if power_extra > 0 then
		ret = add_arrays(ret, { PowerObjective("Hotseat Extra", power_extra) })
	end
	
	return ret
end

local oldAddObjective
local function AddObjective(...)
	local ret = {...}
	
	if #ret < 3 then
		ret[3] = OBJ_STANDARD
	end
	
	if #ret < 4 then
		ret[4] = REWARD_REP
		ret[5] = 1
	end
	
	local multiply = multiply[ret[4]]
	if multiply and multiply > 0 then
		ret[5] = ret[5] * multiply
	end
	
	local add = add[ret[4]]
	if add and add > 0 then
		ret[5] = ret[5] + add
	end
	
	return oldAddObjective(unpack(ret))
end

-- temporary solution in an attempt to increase all power rewards.
modApi.events.onFrameDrawn:subscribe(function()
	if Game and Game.AddObjective ~= AddObjective then
		oldAddObjective = Game.AddObjective
		Game.AddObjective = AddObjective
	end
end)

local this = {}

function this.reset()
	-- reset objectives to backup values.
	for _, v in ipairs(objs) do
		local curr, bak = v.curr, v.bak
		
		curr.hotseat = nil
		for i, v in pairs(bak) do
			curr[i] = v
		end
	end
	
	objs = {}
	add = {}
	multiply = {}
	power_extra = 0
end

function this.add(reward_type, value)
	assert(type(reward_type) == 'number')
	assert(type(value) == 'number')
	
	add[reward_type] = value
end

function this.multiply(reward_type, factor)
	assert(type(reward_type) == 'number')
	assert(type(factor) == 'number')
	
	multiply[reward_type] = factor
end

function this.setPowerExtra(value)
	assert(type(value) == 'number')
	
	power_extra = value
end

return this