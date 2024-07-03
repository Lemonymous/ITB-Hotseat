
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local bonusMission = require(path .."libs/bonusMission")
local bonusStore = require(path .."libs/bonusStore")
local this = {}

function this:load()
	local options = mod_loader.currentModContent[mod.id].options
	
	bonusMission.reset()
	bonusStore.reset()
	
	local power_multi, power_add, rep_add, core_add
	local power_store, power_perf, core_pod = 1, 2, 1
	
	power_multi = options["option_hotseat_power_multi"].value
	power_add = options["option_hotseat_power_add"].value
	rep_add = options["option_hotseat_rep_add"].value
	core_add = options["option_hotseat_core_add"].value
	power_extra = options["option_hotseat_power_extra"].value
	
	power_multi = type(power_multi) == 'number' and power_multi or 1
	power_add = type(power_add) == 'number' and power_add or 0
	rep_add = type(rep_add) == 'number' and rep_add or 0
	core_add = type(core_add) == 'number' and core_add or 0
	power_extra = type(power_extra) == 'number' and power_extra or 0
	
	power_perf = power_perf * power_multi
	power_perf = power_perf * power_add
	power_store = power_store * power_multi
	power_store = power_store + power_add
	core_pod = core_pod + core_add
	
	bonusMission.multiply(REWARD_POWER, power_multi)
	bonusMission.add(REWARD_POWER, power_add)
	bonusMission.add(REWARD_REP, rep_add)
	bonusMission.add(REWARD_TECH, core_add)
	bonusMission.setPowerExtra(power_extra)
	
	bonusStore.setStorePower(power_store)
	bonusStore.setPerfPower(power_perf)
	bonusStore.setPodCores(core_pod)
end

return this