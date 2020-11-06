
local path = GetParentPath(...)

local scripts = {
	"assert",
	"pawn",
	"board",
}

for _, file in ipairs(scripts) do
	require(path .. file)
end
