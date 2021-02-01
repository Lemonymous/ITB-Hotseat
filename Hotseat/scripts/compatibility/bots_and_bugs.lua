
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
local worldConstants = require(path .."libs/worldConstants")
local utils = require(path .."libs/utils")

local function iterateEffect(fx, fn)
	for i = 1, fx:size() do
		if fn(fx:index(i), i) then
			break
		end
	end
end

--	_______
--	 Units
--	‾‾‾‾‾‾‾

local id_wyrm = "lmn_Wyrm"
local id_wyrm_boss = "lmn_WyrmBoss"
local id_wyrm_mission = "Mission_WyrmBoss"
local options_botsnbugs = mod_loader.mod_options.lmn_bots_and_bugs.options
if options_botsnbugs then
	for i, option in ipairs(options_botsnbugs) do
		if option.id == "option_wyrm" then
			option.values = {"Disabled"}
			option.value = "N/A"
			break
		end
	end
end

for _, list in pairs(EnemyLists) do
	if list_contains(list, id_wyrm) then
		remove_element(id_wyrm, list)
		break
	end
end
remove_element(id_wyrm, FinalEnemyList)
remove_element(id_wyrm_mission, Corp_Default.Bosses)
remove_element(id_wyrm_boss, Mission_Final.BossList)
remove_element(id_wyrm_boss, Mission_Final_Cave.BossList)

--	___________
--	 Portraits
--	‾‾‾‾‾‾‾‾‾‾‾

utils.appendAssets{
	writePath = "img/",
	readPath = resourcePath .."img/",
	{"portraits/enemy/Colony1.png", "portraits/Colony1.png"},
	{"portraits/enemy/Colony2.png", "portraits/Colony2.png"},
	{"portraits/enemy/ColonyB.png", "portraits/ColonyB.png"},
}

lmn_Colony1.Portrait = "enemy/Colony1"
lmn_Colony2.Portrait = "enemy/Colony2"
lmn_ColonyBoss.Portrait = "enemy/ColonyB"
lmn_Colony1.IsPortrait = true
lmn_Colony2.IsPortrait = true
lmn_ColonyBoss.IsPortrait = true

--	_________
--	 Weapons
--	‾‾‾‾‾‾‾‾‾

utils.appendAssets{
	writePath = "img/",
	readPath = resourcePath .."img/",
	{"weapons/FloaterAtk1.png", "weapons/FloaterAtk1.png"},
	{"weapons/FloaterAtk2.png", "weapons/FloaterAtk2.png"},
	{"weapons/FloaterAtkB.png", "weapons/FloaterAtkB.png"},
	{"weapons/ColonyAtk1.png", "weapons/ColonyAtk1.png"},
	{"weapons/ColonyAtk2.png", "weapons/ColonyAtk2.png"},
	{"weapons/ColonyAtkB.png", "weapons/ColonyAtkB.png"},
}

lmn_KnightBotAtk1.Icon = "weapons/prime_sword.png"
lmn_FloaterAtk1.Icon = "weapons/FloaterAtk1.png"
lmn_FloaterAtk2.Icon = "weapons/FloaterAtk2.png"
lmn_FloaterAtkB.Icon = "weapons/FloaterAtkB.png"
lmn_ColonyAtk1.Icon = "weapons/ColonyAtk1.png"
lmn_ColonyAtk2.Icon = "weapons/ColonyAtk2.png"
lmn_ColonyAtkB.Icon = "weapons/ColonyAtkB.png"
lmn_BlobberlingAtk2.Icon = "weapons/enemy_blob2.png"

function lmn_FloaterAtk1:GetTargetArea(p)
	local ret = PointList()
	
	for i = DIR_START, DIR_END do
		local curr = p + DIR_VECTORS[i]
		
		if not Board:IsBlocked(curr, PATH_GROUND) then
			ret:push_back(curr)
		end
	end
	
	return ret
end

lmn_FloaterAtk2.GetTargetArea = lmn_FloaterAtk1.GetTargetArea
lmn_FloaterAtkB.GetTargetArea = lmn_FloaterAtk1.GetTargetArea

-- returns true if the tile has creep.
local function isCreep(p)
	assert(GAME)
	assert(Board)
	return GAME.lmn_creep[p2idx(p)]
end

function lmn_FloaterAtk1:GetSkillEffect(p1, p2)
	ret = SkillEffect()
	
	ret:AddBounce(p1, -2)
	ret:AddSound("enemy/shared/crawl_out")
	
	if not isCreep(p1) then
		ret:AddScript(string.format("lmn_ColonyAtk1:AddCreep(%s, 0)", p1:GetString()))
	end
	
	ret:AddDelay(1)
	ret:AddMove(Board:GetPath(p1, p2, Pawn:GetPathProf()), NO_DELAY)
	
	local d = SpaceDamage(p1)
	d.sPawn = self.Spawn
	ret:AddBounce(p1, -3)
	ret:AddDamage(d)
	ret:AddDelay(1)
	ret:AddScript(string.format("local p = %s; Board:GetPawn(p):FireWeapon(p, 1)", p1:GetString()))
	
	return ret
end

lmn_FloaterAtk2.GetSkillEffect = lmn_FloaterAtk1.GetSkillEffect
lmn_FloaterAtkB.GetSkillEffect = lmn_FloaterAtk1.GetSkillEffect

local old = lmn_SpitterAtk1.GetSkillEffect
function lmn_SpitterAtk1:GetSkillEffect(...)
	local ret = old(self, ...)
	
	ret.effect = SkillEffect().effect
	
	return ret
end

lmn_SpitterAtk2.GetSkillEffect = lmn_SpitterAtk1.GetSkillEffect
lmn_SpitterAtkB.GetSkillEffect = lmn_SpitterAtk1.GetSkillEffect

local old_lmn_RoachAtk1_GetSkillEffect = lmn_RoachAtk1.GetSkillEffect
function lmn_RoachAtk1:GetSkillEffect(p1, p2, parentSkill, ...)
	local ret = old_lmn_RoachAtk1_GetSkillEffect(self, p1, p2, lmn_RoachAtk1, ...)
	
	if Pawn and Pawn:GetTeam() == TEAM_PLAYER then
		
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

function lmn_RoachAtkB:GetSkillEffect(p1, p2, parentSkill, ...)
	local ret = old_lmn_RoachAtk1_GetSkillEffect(self, p1, p2, lmn_RoachAtkB, ...)
	local target = utils.GetProjectileEnd(p1, p2, self.Range, PATH_PROJECTILE)
	
	if Pawn and Pawn:GetTeam() == TEAM_PLAYER then
		
		for i = 1, ret.effect:size() do
			ret.effect:index(i).bHide = true
			ret.effect:index(i).bHidePath = true
		end
		
		worldConstants.SetSpeed(ret, 999)
		ret:AddProjectile(p1, SpaceDamage(target), "", NO_DELAY)
		worldConstants.ResetSpeed(ret)
		
		local d = SpaceDamage(target, self.Damage)
		d.iAcid = 1
		weaponPreview:AddDamage(d)
	end
	
	return ret
end

local oldBlobberlingAtk_GetSkillEffect = lmn_BlobberlingAtk1.GetSkillEffect
function lmn_BlobberlingAtk1:GetSkillEffect(p1, p2, parentSkill, ...)
	local ret = oldBlobberlingAtk_GetSkillEffect(self, p1, p2, lmn_BlobberlingAtk1, ...)
	
	for i = DIR_START, DIR_END do
		local curr = p2 + DIR_VECTORS[i]
		weaponPreview:AddDamage(SpaceDamage(curr, self.Damage))
	end
	
	return ret
end

local old = lmn_ShieldBotAtk1.GetSkillEffect
function lmn_ShieldBotAtk1:GetSkillEffect(p1, p2, parentSkill, ...)
	local ret = old(self, p1, p2, lmn_ShieldBotAtk1, ...)
	
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
