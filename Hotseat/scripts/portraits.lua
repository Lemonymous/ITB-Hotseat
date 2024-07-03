
local mod = modApi:getCurrentMod()
local path = mod.scriptPath

local function init()
	for i,v in pairs(_G) do
		if type(v) == 'table' then
			if v.DefaultTeam == TEAM_ENEMY then
				if not v.IsPortrait or not v.Portrait then
					v.IsPortrait = true
					v.Portrait = "enemy/".. i
				end
			end
		end
	end
end

-- run init after all mods init,
-- but before all mods load.
local old = modApi.finalize
function modApi.finalize(...)
	init()
	old(...)
end