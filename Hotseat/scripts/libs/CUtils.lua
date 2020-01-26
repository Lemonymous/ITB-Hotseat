
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath .."libs/utils.dll"

local old = package.loaded["test"]

package.loaded["test"] = nil
test = nil

assert(package.loadlib(path, "luaopen_utils"), "cannot find C-Utils dll")()
local ret = test

package.loaded["test"] = old
test = old

return ret
