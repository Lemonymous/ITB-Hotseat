
-- adjusting a few vanilla mechanics to be more suitable for player controlled use.

local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local path = resourcePath .."scripts/"
local weaponPreview = require(path .."weaponPreview/api")
local getModUtils = require(path .."libs/getModUtils")
local utils = require(path .."libs/utils")
local phases = require(path .."phases")
local color_invalid = GL_Color(255,150,150)
local this = {}

-- combatibility code not done.
remove_element("Mission_SpiderBoss", Corp_Default.Bosses)

utils.appendAssets{
	writePath = "img/",
	readPath = resourcePath .."img/",
	{"portraits/enemy/lmn_Webegg1.png", "compatibility/Webegg1.png"},
	{"portraits/enemy/lmn_WebeggBoss.png", "compatibility/WebeggBoss.png"},
	{"weapons/lmn_SpiderAtk1.png", "compatibility/SpiderAtk1.png"},
	{"weapons/lmn_SpiderlingAtk1.png", "compatibility/SpiderlingAtk1.png"},
	{"weapons/lmn_WebeggAtk1.png", "compatibility/WebeggAtk1.png"},
	{"weapons/lmn_BurrowerAtk1.png", "compatibility/BurrowerAtk1.png"},
	{"weapons/lmn_BurrowerAtk2.png", "compatibility/BurrowerAtk2.png"},
	{"weapons/lmn_SnowLaser1.png", "compatibility/snowlaser1.png"},
	{"weapons/lmn_SnowLaser2.png", "compatibility/snowlaser2.png"},
	{"weapons/lmn_SnowTank1.png", "compatibility/snowtank1.png"},
	{"weapons/lmn_SnowTank2.png", "compatibility/snowtank2.png"},
	{"weapons/lmn_SnowArt1.png", "compatibility/snowart1.png"},
	{"weapons/lmn_SnowArt2.png", "compatibility/snowart2.png"},
	{"weapons/lmn_BlobBoss.png", "compatibility/blobboss.png"},
	{"weapons/lmn_SnowBossShield.png", "compatibility/snowbossshield.png"},
}

WebbEgg1.Portrait = "enemy/lmn_Webegg1"
WebbEgg1.IsPortrait = true
SpiderlingEgg1.Portrait = "enemy/lmn_WebeggBoss"
SpiderlingEgg1.IsPortrait = true
SpiderAtk1.Icon = "weapons/lmn_SpiderAtk1.png"
SpiderlingAtk1.Icon = "weapons/lmn_SpiderlingAtk1.png"
WebeggHatch1.Icon = "weapons/lmn_WebeggAtk1.png"
SpiderlingHatch1.Icon = "weapons/lmn_WebeggAtk1.png"
Burrower_Atk.Icon = "weapons/lmn_BurrowerAtk1.png"
Burrower_Atk2.Icon = "weapons/lmn_BurrowerAtk2.png"
SnowlaserAtk1.Icon = "weapons/lmn_SnowLaser1.png"
SnowlaserAtk2.Icon = "weapons/lmn_SnowLaser2.png"
SnowtankAtk1.Icon = "weapons/lmn_SnowTank1.png"
SnowtankAtk2.Icon = "weapons/lmn_SnowTank2.png"
SnowartAtk1.Icon = "weapons/lmn_SnowArt1.png"
SnowartAtk2.Icon = "weapons/lmn_SnowArt2.png"
BlobBossAtk.Icon = "weapons/lmn_BlobBoss.png"
SnowBossAtk.Icon = "weapons/lmn_SnowArt1.png"
BossHeal.Icon = "weapons/lmn_SnowBossShield.png"


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

local function isBurrower(pawn)
	return _G[pawn:GetType()].Burrows
end

local old = Move.GetTargetArea
function Move:GetTargetArea(p, ...)
	local ret = old(self, p, ...)
	if phases.isPhase("vekTurn") then
		for i = 1, ret:size() do
			local curr = ret:index(i)
			if Board:IsPod(curr) then
				weaponPreview:AddColor(curr, color_invalid)
				ret:erase(i)
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