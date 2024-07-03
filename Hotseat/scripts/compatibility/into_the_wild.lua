
-- adjusting a few meridia mechanics to be more suitable for player controlled use.

local id = "lmn_into_the_wild"
local mod = mod_loader.mods[id]
if not mod or not mod.initialized then
	return
end

--LOG("Hotseat: ".. id .." found. Running compatibility code.")
LOG("Hotseat: ".. id .." found. Compatibility code incomplete. Removing incompatible enemies from pool.")

local getModUtils = require(path .."libs/getModUtils")
local weaponPreview = require(path .."weaponPreview/api")
local path = modApi:getCurrentMod().scriptPath
local pawnSpace = require(path .."libs/pawnSpace")
local corpMissions = require(path .."libs/corpMissions")
local utils = require(path .."libs/utils")

if mod.enemies.Core then
	remove_element("lmn_Sunflower", mod.enemies.Core)
	remove_element("lmn_Beanstalker", mod.enemies.Unique)
	remove_element("Mission_lmn_SpringseedBoss", mod.enemies.Boss)
	remove_element("Mission_lmn_SunflowerBossBoss", mod.enemies.Boss)
end

local function iterateEffect(fx, fn)
	for i = 1, fx:size() do
		if fn(fx:index(i), i) then
			break
		end
	end
end

local function getPawnSpace(pawn)
	assert(pawn)
	
	local id = pawn:GetId()
	if GAME and GAME.trackedPawns and GAME.trackedPawns[id] and GAME.trackedPawns[id].loc then
		if GAME.trackedPawns[id].loc then
			return GAME.trackedPawns[id].loc
		end
	end
	
	return pawn:GetSpace()
end

local old = lmn_ChomperAtk1.GetSkillEffect
function lmn_ChomperAtk1:GetSkillEffect(p1, p2)
	local shooter = Board:GetPawn(p1)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local adjacent = p1 + DIR_VECTORS[dir]
	local target = utils.GetProjectileEnd(p1, p2, self.Range)
	local pawn = Board:GetPawn(target)
	if pawn then
		if shooter and shooter:IsWeaponArmed() then
			target = getPawnSpace(pawn)
		end
	end
	local distance = p1:Manhattan(target)
	local d = SpaceDamage(adjacent)
	local pullPawn = pawn and not pawn:IsGuarding() and distance > 1
	
	d.sSound = self.SoundBase .."/attack"
	
	if not pullPawn then
		if Board:IsBlocked(target, PATH_PROJECTILE) then
			ret:AddQueuedCharge(Board:GetSimplePath(p1, target - DIR_VECTORS[dir]), FULL_DELAY)
			d.sSound = "/weapons/charge_impact"
			d.loc = target
		end
		d.iDamage = self.Damage
		d.sAnimation = self.Anim_Impact .. dir
	end
	
	ret:AddQueuedMelee(d.loc - DIR_VECTORS[dir], d, NO_DELAY)
	
	if pullPawn then
		-- charge pawn towards chomper.
		ret:AddQueuedDelay(0.25)
		ret:AddQueuedCharge(Board:GetSimplePath(target, adjacent), FULL_DELAY)
		
		local d = SpaceDamage(adjacent, self.Damage)
		d.sSound = "/weapons/charge_impact"
		d.sAnimation = self.Anim_Impact .. dir
		ret:AddQueuedMelee(p1, d, NO_DELAY)
	end
	
	return ret
end

local old = lmn_BeanstalkerAtk1.GetSkillEffect
function lmn_BeanstalkerAtk1:GetSkillEffect(p1, p2)
	local ret = old(self, p1, p2, lmn_BeanstalkerAtk1)
	
	if Pawn and Pawn:GetTeam() == TEAM_PLAYER then
		-- TODO figure out why this fails when charging against buildings.
		--[[for i = 1, ret.q_effect:size() do
			local d = ret.q_effect:index(i)
			
			if Board:IsValid(d.loc) and d.iPush ~= DIR_NONE and not d.bHide then
				weaponPreview:AddDamage(d)
			end
		end]]
		
		local dir = GetDirection(p2 - p1)
		local target = utils.GetProjectileEnd(p1, p2, self.Range, PATH_GROUND)
		if Board:IsBlocked(target, PATH_PROJECTILE) then
			target = target - DIR_VECTORS[dir]
		end
		pawnSpace.ClearSpace(ret, p1)
		ret:AddCharge(Board:GetSimplePath(p1, target), NO_DELAY)
		pawnSpace.Rewind(ret)
	end
	
	return ret
end

local old = lmn_PufferAtk1.GetSkillEffect
function lmn_PufferAtk1:GetSkillEffect(p1, p2)
	local ret = old(self, p1, p2, lmn_PufferAtk1)
	
	if Pawn and Pawn:GetTeam() == TEAM_PLAYER then
		local d = SpaceDamage(p2, self.Damage)
		d.iSmoke = 1
		weaponPreview:AddDamage(d)
		
		if self.AoE then
			for i = DIR_START, DIR_END do
				local curr = p1 + DIR_VECTORS[i]
				if curr ~= p2 then
					weaponPreview:AddDamage(SpaceDamage(curr, self.Damage))
				end
			end
		end
	end
	
	return ret
end

local old = lmn_SpringseedAtk1.GetSkillEffect
function lmn_SpringseedAtk1:GetSkillEffect(p1, p2)
	local ret = old(self, p1, p2, lmn_SpringseedAtk1)
	
	if Pawn and Pawn:GetTeam() == TEAM_PLAYER then
		if not Board:IsBlocked(p2, PATH_PROJECTILE) then
			local dir = GetDirection(p2 - p1)
			local curr = p1 + DIR_VECTORS[dir]
			local d = SpaceDamage(curr, self.Damage)
			d.iAcid = 1
			weaponPreview:AddDamage(d)
			
			local leap = PointList()
			leap:push_back(p1)
			leap:push_back(p2)
			pawnSpace.ClearSpace(ret, p1)
			ret:AddLeap(leap, 0)
			pawnSpace.Rewind(ret)
		end
	end
	
	return ret
end

local old = lmn_SproutAtk1.GetSkillEffect
function lmn_SproutAtk1:GetSkillEffect(p1, p2)
	local ret = old(self, p1, p2, lmn_SproutAtk1)
	
	if Pawn and Pawn:GetTeam() == TEAM_PLAYER then
		if p2 == p1 then
			ret:AddScript(string.format("local p = %s; Board:GetPawn(p):FireWeapon(p, 1)", p1:GetString()))
			ret:AddDelay(0.017)
			ret:AddScript(string.format("Board:GetPawn(%s):SetActive(false)", p1:GetString()))
		end
	end
	
	return ret
end