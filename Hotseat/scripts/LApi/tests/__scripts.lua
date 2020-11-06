
local path = GetParentPath(...)

local scripts = {
	"main",
	"board",
	"pawn",
}

for _, file in ipairs(scripts) do
	require(path .. file)
end
