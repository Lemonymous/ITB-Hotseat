
-- adjusting a few mechanics to be more suitable for player controlled use.

local id = "VekHiveAssault"
local mod = mod_loader.mods[id]
if not mod or not mod.initialized then
	return
end

LOG("Hotseat: ".. id .." found. Running compatibility code.")

local path = mod_loader.mods[modApi.currentMod].scriptPath
local getModUtils = require(path .."libs/getModUtils")
local weaponPreview = require(path .."weaponPreview/api")
local utils = require(path .."libs/utils")

RockBeetleAtk1.Portrait = "enemy/Beetle1"
RockBeetleAtk2.Portrait = "enemy/Beetle2"
RockBeetleAtk2.Icon = "weapons/enemy_rocker2.png"

local old = RockBeetleAtk1.GetSkillEffect
function RockBeetleAtk1:GetSkillEffect(p1, p2)
	local ret = old(self, p1, p2, RockBeetleAtk1)
	local dir = GetDirection(p2 - p1)
	
	if Pawn and Pawn:GetTeam() == TEAM_PLAYER then
		local d = SpaceDamage(p2, self.Damage, dir)
		
		if
			not Board:IsBlocked(p2, PATH_PROJECTILE)	and
			Board:GetTerrain(p2) ~= TERRAIN_WATER		and
			not Board:IsFire(p2)						and
			not Board:IsPod(p2)
		then
			d.sPawn = "Wall"
			weaponPreview:AddDamage(d)
		end
	end
	
	return ret
end