
-- adjusting a few mechanics to be more suitable for player controlled use.

local id = "lmn_bots_and_bugs"
local mod = mod_loader.mods[id]
if not mod or not mod.initialized then
	return
end

LOG("Hotseat: ".. id .." found. Running compatibility code.")

local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local path = resourcePath .."scripts/"
local getModUtils = require(path .."libs/getModUtils")
local weaponPreview = require(path .."weaponPreview/api")
local utils = require(path .."libs/utils")

local function iterateEffect(fx, fn)
	for i = 1, fx:size() do
		if fn(fx:index(i), i) then
			break
		end
	end
end

local old = lmn_RoachAtk1.GetSkillEffect
function lmn_RoachAtk1:GetSkillEffect(p1, p2)
	local ret = old(self, p1, p2, lmn_RoachAtk1)
	
	if Pawn and Pawn:GetTeam() == TEAM_PLAYER then
		local damageIndex = 0
		
		iterateEffect(ret.effect, function(d)
			if d.iAcid == 1 then
				d.bHidePath = true
				return true
			end
		end)
		
		local d = SpaceDamage(p2, self.Damage)
		d.iAcid = 1
		weaponPreview:AddDamage(d)
	end
	
	return ret
end

lmn_KnightBotAtk1.Icon = "weapons/prime_sword.png"

local old = lmn_ShieldBotAtk1.GetSkillEffect
function lmn_ShieldBotAtk1:GetSkillEffect(p1, p2)
	local ret = old(self, p1, p2, lmn_ShieldBotAtk1)
	
	if Pawn and Pawn:GetTeam() == TEAM_PLAYER then
		for i = DIR_START, DIR_END do
			local d = SpaceDamage(p1 + DIR_VECTORS[i], self.Damage, i)
			weaponPreview:AddDamage(d)
		end
	end
	
	return ret
end

if lmn_Garden_Atk then
	modApi:appendAsset("img/weapons/lmn_GardenAtk1.png", resourcePath .."img/compatibility/GardenAtk1.png")
	lmn_Garden_Atk.Icon = "weapons/lmn_GardenAtk1.png"
end
