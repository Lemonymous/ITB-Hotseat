
-- adjusting a few vanilla mechanics to be more suitable for player controlled use.

local resourcePath = modApi:getCurrentMod().resourcePath
local path = resourcePath .."scripts/"
local weaponPreview = require(path .."weaponPreview/api")
local getModUtils = require(path .."libs/getModUtils")
local utils = require(path .."libs/utils")
local phases = require(path .."phases")
local color_invalid = GL_Color(255,150,150)
local this = {}

--	__________
--	 Missions
--	‾‾‾‾‾‾‾‾‾‾

Mission_SpiderBoss.UpdateSpawning = Mission.UpdateSpawning

function Mission_SpiderBoss:StartMission()
	self:StartBoss()
	self:GetSpawner():BlockPawns("Blobber")
	self:GetSpawner():BlockPawns("Spider")
	
	local eggs = {}
	for i = 1,2 do
		eggs[i] = PAWN_FACTORY:CreatePawn("SpiderlingEgg1")
		Board:AddPawn(eggs[i])
	end
	
	for i = 1,2 do
		local p = eggs[i]:GetSpace()
		local fx = SpiderlingHatch1:GetSkillEffect(p, p)
		fx.effect = fx.q_effect
		fx.q_effect = SkillEffect().q_effect
		Board:AddEffect(fx)
	end
end

local old_SpiderlingHatch1_GetSkillEffect = SpiderlingHatch1.GetSkillEffect
function SpiderlingHatch1:GetSkillEffect(p1, p2, parentSkill, ...)
	local ret = old_SpiderlingHatch1_GetSkillEffect(self, p1, p2, SpiderlingHatch1, ...)
	
	ret.q_effect = ret.effect
	ret.effect = SkillEffect().effect
	
	return ret
end

--	_______
--	 Units
--	‾‾‾‾‾‾‾

SpiderBoss.Tooltip = ""
SpiderBoss.SkillList = { "SpiderAtkB" }

--	___________
--	 Portraits
--	‾‾‾‾‾‾‾‾‾‾‾

utils.appendAssets{
	writePath = "img/",
	readPath = resourcePath .."img/",
	{"portraits/enemy/Spiderling2.png", "portraits/Spiderling2.png"},
	{"portraits/enemy/AcidFirefly1.png", "portraits/AcidFirefly1.png"},
	{"portraits/enemy/AcidHornet1.png", "portraits/AcidHornet1.png"},
	{"portraits/enemy/AcidScorpion1.png", "portraits/AcidScorpion1.png"},
	{"portraits/enemy/Webegg1.png", "portraits/Webegg.png"},
	{"portraits/enemy/WebeggBoss.png", "portraits/Webegg.png"},
}

WebbEgg1.Portrait = "enemy/Webegg1"
WebbEgg1.IsPortrait = true
SpiderlingEgg1.Portrait = "enemy/WebeggBoss"
SpiderlingEgg1.IsPortrait = true

Spiderling1.Portrait = "enemy/spiderling1"
Spiderling2.Portrait = "enemy/Spiderling2"
Firefly1.Portrait = "enemy/Firefly1"
Firefly2.Portrait = "enemy/Firefly2"
Scarab1.Portrait = "enemy/Scarab1"
Scarab2.Portrait = "enemy/Scarab2"
Leaper1.Portrait = "enemy/Leaper1"
Leaper2.Portrait = "enemy/Leaper2"
Scorpion1.Portrait = "enemy/Scorpion1"
Scorpion2.Portrait = "enemy/Scorpion2"
Hornet1.Portrait = "enemy/Hornet1"
Hornet2.Portrait = "enemy/Hornet2"
Beetle1.Portrait = "enemy/Beetle1"
Beetle2.Portrait = "enemy/Beetle2"
Digger1.Portrait = "enemy/Digger1"
Digger2.Portrait = "enemy/Digger2"
Crab1.Portrait = "enemy/Crab1"
Crab2.Portrait = "enemy/Crab2"
Centipede1.Portrait = "enemy/Centipede1"
Centipede2.Portrait = "enemy/Centipede2"
Burrower1.Portrait = "enemy/Burrower1"
Burrower2.Portrait = "enemy/Burrower2"
Spider1.Portrait = "enemy/Spider1"
Spider2.Portrait = "enemy/Spider2"
Blobber1.Portrait = "enemy/Blobber1"
Blobber2.Portrait = "enemy/Blobber2"
Blob1.Portrait = "enemy/Blob1"
Blob2.Portrait = "enemy/Blob2"
Jelly_Health1.Portrait = "enemy/Jelly_Health1"
Jelly_Regen1.Portrait = "enemy/Jelly_Regen1"
Jelly_Armor1.Portrait = "enemy/Jelly_Armor1"
Jelly_Explode1.Portrait = "enemy/Jelly_Explode1"
Jelly_Lava1.Portrait = "enemy/Jelly_Lava1"
Snowlaser1.Portrait = "enemy/Snowlaser1"
Snowlaser2.Portrait = "enemy/Snowlaser2"
Snowart1.Portrait = "enemy/Snowart1"
Snowart2.Portrait = "enemy/Snowart2"
Snowtank1.Portrait = "enemy/Snowtank1"
Snowtank2.Portrait = "enemy/Snowtank2"
Firefly_Acid.Portrait = "enemy/AcidFirefly1"
Hornet_Acid.Portrait = "enemy/AcidHornet1"
Scorpion_Acid.Portrait = "enemy/AcidScorpion1"


--	_________
--	 Weapons
--	‾‾‾‾‾‾‾‾‾

local old = ScorpionAtk1.GetSkillEffect
function ScorpionAtk1:GetSkillEffect(p1, p2, ...)
	local tbl = {...}
	tbl[1] = ScorpionAtkB
	local ret = old(self, p1, p2, unpack(tbl))
	
	if not Pawn then return ret end
	
	if not utils.IsTipImage() then
		ret:AddScript(string.format("Board:GetPawn(%s):SetTeam(TEAM_ENEMY)", p1:GetString()))
		ret:AddScript(string.format([[
			local id = %s;
			local m = GetCurrentMission();
			if not m then return end;
			m.lmn_hotseat = m.lmn_hotseat or {};
			m.lmn_hotseat.vek = m.lmn_hotseat.vek or {};
			remove_element(id, m.lmn_hotseat.vek);
		]], Pawn:GetId()))
	end
	
	if Pawn and Pawn:GetTeam() == TEAM_PLAYER then
		weaponPreview:AddDamage(SpaceDamage(p2, self.Damage))
	end
	
	return ret
end

local old = ScorpionAtkB.GetSkillEffect
function ScorpionAtkB:GetSkillEffect(p1, p2, ...)
	local tbl = {...}
	tbl[1] = ScorpionAtkB
	local ret = old(self, p1, p2, unpack(tbl))
	
	if not Pawn then return ret end
	
	if not utils.IsTipImage() then
		ret:AddScript(string.format("Board:GetPawn(%s):SetTeam(TEAM_ENEMY)", p1:GetString()))
		ret:AddScript(string.format([[
			local id = %s;
			local m = GetCurrentMission();
			if not m then return end;
			m.lmn_hotseat = m.lmn_hotseat or {};
			m.lmn_hotseat.vek = m.lmn_hotseat.vek or {};
			remove_element(id, m.lmn_hotseat.vek);
		]], Pawn:GetId()))
	end
	
	if Pawn and Pawn:GetTeam() == TEAM_PLAYER then
		for i = DIR_START, DIR_END do
			weaponPreview:AddDamage(SpaceDamage(p2 + DIR_VECTORS[i], self.Damage))
		end
	end
	
	return ret
end

local old = SpiderAtk1.GetTargetArea
function SpiderAtk1:GetTargetArea(p, ...)
	local ret = old(self, p, ...)
	for i = 1, ret:size() do
		if Board:IsPod(ret:index(i)) then
			ret:erase(i)
		end
	end
	return ret
end

local old = SpiderAtk1.GetSkillEffect
function SpiderAtk1:GetSkillEffect(p1, p2)
	local ret = old(self, p1, p2, SpiderAtk1)
	ret:AddScript(string.format("local p = %s; Board:GetPawn(p):FireWeapon(p, 1)", p2:GetString()))
	ret:AddDelay(0.017)
	ret:AddScript(string.format("Board:GetPawn(%s):SetActive(false)", p2:GetString()))
	return ret
end

local old = BlobberAtk1.GetTargetArea
function BlobberAtk1:GetTargetArea(...)
	local ret = old(self, ...)
	for i = 1, ret:size() do
		if Board:IsPod(ret:index(i)) then
			ret:erase(i)
		end
	end
	return ret
end

local old = BlobberAtk1.GetSkillEffect
function BlobberAtk1:GetSkillEffect(p1, p2)
	local ret = old(self, p1, p2, BlobberAtk1)
	ret:AddScript(string.format("local p = %s; Board:GetPawn(p):FireWeapon(p, 1)", p2:GetString()))
	ret:AddDelay(0.017)
	ret:AddScript(string.format("Board:GetPawn(%s):SetActive(false)", p2:GetString()))
	return ret
end



utils.appendAssets{
	writePath = "img/",
	readPath = resourcePath .."img/",
	{"weapons/SpiderlingAtk1.png", "weapons/SpiderlingAtk1.png"},
	{"weapons/SpiderlingAtk2.png", "weapons/SpiderlingAtk2.png"},
	{"weapons/BurrowerAtk1.png", "weapons/BurrowerAtk1.png"},
	{"weapons/BurrowerAtk2.png", "weapons/BurrowerAtk2.png"},
	{"weapons/BurrowerAtkBoss.png", "weapons/BurrowerAtkBoss.png"},
	{"weapons/FireflyAtkBoss.png", "weapons/FireflyAtkBoss.png"},
	{"weapons/ScorpionAtkBoss.png", "weapons/ScorpionAtkBoss.png"},
	{"weapons/HornetAtkBoss.png", "weapons/HornetAtkBoss.png"},
	{"weapons/ScarabAtkBoss.png", "weapons/ScarabAtkBoss.png"},
	{"weapons/CrabAtkBoss.png", "weapons/CrabAtkBoss.png"},
	{"weapons/BlobberAtkBoss.png", "weapons/BlobberAtkBoss.png"},
	{"weapons/BlobAtkBoss.png", "weapons/BlobAtkBoss.png"},
	{"weapons/lmn_WebeggAtk1.png", "weapons/WebeggAtk1.png"},
	
	{"weapons/lmn_SnowLaser1.png", "weapons/snowlaser1.png"},
	{"weapons/lmn_SnowLaser2.png", "weapons/snowlaser2.png"},
	{"weapons/lmn_SnowTank1.png", "weapons/snowtank1.png"},
	{"weapons/lmn_SnowTank2.png", "weapons/snowtank2.png"},
	{"weapons/lmn_SnowArt1.png", "weapons/snowart1.png"},
	{"weapons/lmn_SnowArt2.png", "weapons/snowart2.png"},
	
	{"weapons/lmn_BlobBoss.png", "weapons/blobboss.png"},
	{"weapons/lmn_SnowBossShield.png", "weapons/snowbossshield.png"},
}

SpiderAtk1.Icon = "weapons/enemy_spider2.png"
SpiderAtk2.Icon = "weapons/enemy_spider2.png"
SpiderAtkB.Icon = "weapons/enemy_spider2.png"
SpiderlingAtk1.Icon = "weapons/SpiderlingAtk1.png"
SpiderlingAtk2.Icon = "weapons/SpiderlingAtk2.png"
BeetleAtk1.Icon = "weapons/vek_beetle.png"
BeetleAtk2.Icon = "weapons/vek_beetle.png"
WebeggHatch1.Icon = "weapons/lmn_WebeggAtk1.png"
SpiderlingHatch1.Icon = "weapons/lmn_WebeggAtk1.png"
DiggerAtk1.Icon = "weapons/enemy_rocker1.png"
DiggerAtk2.Icon = "weapons/enemy_rocker2.png"
LeaperAtk2.Icon = "weapons/enemy_leaper2.png"
FireflyAtkB.Icon = "weapons/FireflyAtkBoss.png"
HornetAtkB.Icon = "weapons/HornetAtkBoss.png"
ScorpionAtkB.Icon = "weapons/ScorpionAtkBoss.png"
Burrower_Atk.Icon = "weapons/BurrowerAtk1.png"
Burrower_Atk2.Icon = "weapons/BurrowerAtk2.png"
SnowlaserAtk1.Icon = "weapons/lmn_SnowLaser1.png"
SnowlaserAtk2.Icon = "weapons/lmn_SnowLaser2.png"
SnowtankAtk1.Icon = "weapons/lmn_SnowTank1.png"
SnowtankAtk2.Icon = "weapons/lmn_SnowTank2.png"
SnowartAtk1.Icon = "weapons/lmn_SnowArt1.png"
SnowartAtk2.Icon = "weapons/lmn_SnowArt2.png"
BlobBossAtk.Icon = "weapons/lmn_BlobBoss.png"
SnowBossAtk.Icon = "weapons/lmn_SnowArt1.png"
BossHeal.Icon = "weapons/lmn_SnowBossShield.png"

--	____________
--	 Additional
--	‾‾‾‾‾‾‾‾‾‾‾‾

local function isBurrower(pawn)
	return _G[pawn:GetType()].Burrows
end

local PATH_JUMPS = 6
local PATH_BURROWS = 7

local old = Move.GetTargetArea
function Move:GetTargetArea(p, ...)
	local ret = old(self, p, ...)
	if phases.isPhase("vekTurn") then
		for i = ret:size(), 1, -1 do
			local curr = ret:index(i)
			if Board:IsPod(curr) then
				weaponPreview:AddColor(curr, color_invalid)
				ret:erase(i)
			elseif Board:GetTerrain(curr) == TERRAIN_WATER then
				if
					Pawn:GetPathProf() % 16 == PATH_JUMPS   or
					Pawn:GetPathProf() % 16 == PATH_BURROWS
				then
					ret:erase(i)
				end
			end
		end
	end
	return ret
end

local old = Move.GetSkillEffect
function Move:GetSkillEffect(p1, p2, ...)
	local ret = SkillEffect()
	
	if Pawn:IsJumper() then
		local data = _G[Pawn:GetType()]
		ret:AddSound(data.SoundLocation .."move")
		local move = PointList()
		move:push_back(p1)
		move:push_back(p2)
		ret:AddLeap(move, FULL_DELAY)
		ret:AddSound(data.SoundLocation .."land")
		
		return ret
	elseif isBurrower(Pawn) then
		local pawnId = Pawn:GetId()
		ret:AddScript(string.format("Board:GetPawn(%s):SetSpace(Point(-1, -1))", pawnId))
		ret:AddMove(Board:GetPath(p1, p2, Pawn:GetPathProf()), NO_DELAY)
		ret:AddScript(string.format("Board:GetPawn(%s):SetSpace(%s)", pawnId, p1:GetString()))
		ret:AddScript(string.format("Board:GetPawn(%s):Move(%s)", pawnId, p2:GetString()))
		local data = _G[Pawn:GetType()]
		local anim = ANIMS[data.Image .."e"] or {Time = .15}
		ret:AddDelay(8 * anim.Time)
		local path = extract_table(Board:GetPath(p1, p2, Pawn:GetPathProf()))
		local dist = #path - 1
		for i = 1, #path do
			local p = path[i]
			if i < #path then
				local dir = GetDirection(path[i+1] - p)
				ret:AddBurst(p, "Emitter_$tile", dir)
			else
				ret:AddBurst(p, "Emitter_Burst_$tile", DIR_NONE)
			end
			
			ret:AddBounce(p, -2)
			ret:AddDelay(4 * anim.Time / dist)
		end
		
		return ret
	end
	
	-- TODO: Write custom pathfinder for Vek units.
	-- blocked by npc units
	-- not blocked by Vek turned enemy due to webbing.
	
	return old(self, p1, p2, ...)
end

return this
