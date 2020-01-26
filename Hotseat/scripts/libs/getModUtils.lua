
local mod = mod_loader.mods[modApi.currentMod]

-- returns the modUtils object added by this mod.
-- only available when mod has been loaded, but 
-- also only useful at that time to register hooks to the correct modUtils.
-- at init modApiExt_internal.getMostRecent will be sufficent.
return function()
	local m = modApiExt_internal
	assert(m, mod.id .." - found no modApiExt.")
	
	for _, modUtils in ipairs(m.extObjects) do
		if modUtils.owner and modUtils.owner.id == mod.id then
			return modUtils
		end
	end
	
	assert(false, mod.id .." - found no modApiExt or modApiExt is out of date.")
end