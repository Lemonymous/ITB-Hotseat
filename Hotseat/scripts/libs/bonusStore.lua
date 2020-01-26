
local STORE_CORE = 1
local STORE_POWER = 2
local STORE_WEAPON = 3
local POD = 4
local PERF_PILOT = 5
local PERF_WEAPON = 6
local PERF_POWER = 7
local UNKNOWN = 8

local changes = {}

--[[ fields:
number		data.rewtype
string		data.pilot
number		data.cores
number		data.money
number		data.power
number		data.stock
string		data.weapon
]]

local old = CreateEffect
function CreateEffect(data, ...)
	
	--[[
		check the effect before
		changing it
	--]]
	local reward_type
	if data.rewtype then
		reward_type = data.rewtype
	else
		if data.stock then
			if data.cores then
				reward_type = STORE_CORE
			elseif data.power then
				reward_type = STORE_POWER
			end
		elseif data.money then
			reward_type = STORE_WEAPON
		elseif data.cores then
			reward_type = POD
		elseif data.pilot then
			reward_type = PERF_PILOT
		elseif data.weapon then
			reward_type = PERF_WEAPON
		elseif data.power then
			reward_type = PERF_POWER
		else
			reward_type = UNKNOWN
		end
		data.rewtype = reward_type
	end
	
	-- change store costs and rewards
	local changes = changes[reward_type]
	if changes then
		for i, v in pairs(changes) do
			data[i] = v
		end
	end
	
	return old(data, ...)
end

local this = {}

function this.reset()
	changes = {}
end

function this.setPodCores(cores)
	changes[POD] = { cores = cores }
end

function this.setStorePower(power, cost)
	changes[STORE_POWER] = { power = power, cost = cost }
end

function this.setPerfPower(power)
	changes[PERF_POWER] = { power = power }
end

return this