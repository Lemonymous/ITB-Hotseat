
local path = GetParentPath(...)

assert(package.loadlib(path .."Cutils.dll", "luaopen_utils"), "cannot find C-Utils dll")()
