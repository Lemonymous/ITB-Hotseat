
--[[
	untestable by automatic tests:
	ClearUndoMove
	SetUndoLoc
	GetUndoLoc
	IsHighlighted
	PawnIsPlayerControlled
	MarkHpLoss
	GetMoveSkill
	SetMoveSkill
	SetRepairSkill
]]

local tests = LApi.Tests

tests:AddTests{
	"PawnGetOwner",
	"PawnSetOwner",
	"PawnSetFire",
	"PawnGetImpactMaterial",
	"PawnSetImpactMaterial",
	"PawnGetColor",
	"PawnSetColor",
	"PawnIsMassive",
	"PawnSetMassive",
	--IsMovementAvailable
	--SetMovementAvailable
	"PawnSetFlying",
	"PawnSetTeleporter",
	"PawnSetJumper",
	"PawnGetMaxHealth",
	"PawnGetBaseMaxHealth",
	"PawnSetHealth",
	"PawnSetMaxHealth",
	"PawnSetBaseMaxHealth",
	"PawnGetWeaponCount",
	"PawnGetWeaponType",
	--"PawnGetWeaponClass",
	"PawnRemoveWeapon",
	--GetPilot
	--SetMech
	--IsTeleporter
	--IsJumper
}

LApi_TEST_WEAPON = Prime_Punchmech:new{}
LApi_TEST_MECH = PunchMech:new{}

function tests:PawnGetOwner()
	local loc = Point(0,0)
	local target = Point(1,0)
	Board:ClearSpace(loc)
	Board:ClearSpace(target)
	
	LApi_TEST_MECH = PunchMech:new{ SkillList = {"LApi_TEST_WEAPON"} }
	LApi_TEST_WEAPON = Skill:new{
		GetSkillEffect = function(self, p1, p2)
			local ret = SkillEffect()
			local damage = SpaceDamage(p2)
			damage.sPawn = "LApi_TEST_MECH"
			ret:AddDamage(damage)
			return ret
		end
	}
	
	local parent = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	Board:AddPawn(parent, loc)
	parent:FireWeapon(target, 1)
	
	local child = Board:GetPawn(target)
	local ownerIsParent = child:GetOwner() == parent:GetId()
	
	Board:ClearSpace(loc)
	Board:ClearSpace(target)
	
	return ownerIsParent
end

function tests:PawnSetOwner()
	local loc = Point(0,0)
	local target = Point(1,0)
	Board:ClearSpace(loc)
	Board:ClearSpace(target)
	
	LApi_TEST_MECH = PunchMech:new{}
	
	local parent = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local child = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
	Board:AddPawn(parent, loc)
	Board:AddPawn(child, target)
	
									local hasNoParent = child:GetOwner() == -1
	child:SetOwner(parent:GetId()); local hasParent = child:GetOwner() == parent:GetId()
	
	Board:ClearSpace(loc)
	Board:ClearSpace(target)
	
	return hasNoParent, hasParent
end

function tests:PawnSetFire()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
	LApi_TEST_MECH = PunchMech:new{}
	
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	Board:AddPawn(pawn, loc)
	
						local notOnFire = pawn:IsFire() == false
	pawn:SetFire(true); local onFire = pawn:IsFire() == true
	
	Board:ClearSpace(loc)
	
	return notOnFire, onFire
end

function tests:PawnGetImpactMaterial()
	LApi_TEST_MECH = PunchMech:new{ ImpactMaterial = IMPACT_INSECT }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local insect = pawn:GetImpactMaterial() == IMPACT_INSECT
	
	LApi_TEST_MECH = PunchMech:new{ ImpactMaterial = IMPACT_BLOB }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local blob = pawn:GetImpactMaterial() == IMPACT_BLOB
	
	return insecct, blob
end

function tests:PawnSetImpactMaterial()
	LApi_TEST_MECH = PunchMech:new{ ImpactMaterial = IMPACT_INSECT }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
											local insect = pawn:GetImpactMaterial() == IMPACT_INSECT
	pawn:SetImpactMaterial(IMPACT_BLOB);	local blob = pawn:GetImpactMaterial() == IMPACT_BLOB
	
	return insect, blob
end

function tests:PawnGetColor()
	LApi_TEST_MECH = PunchMech:new{ ImageOffset = 0 }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local color0 = pawn:GetColor() == 0
	
	LApi_TEST_MECH = PunchMech:new{ ImageOffset = 1 }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local color1 = pawn:GetColor() == 1
	
	return color0, color1
end

function tests:PawnSetColor()
	LApi_TEST_MECH = PunchMech:new{ ImageOffset = 0 }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
						local color0 = pawn:GetColor() == 0
	pawn:SetColor(1);	local color1 = pawn:GetColor() == 1
	
	return color0, color1
end

function tests:PawnIsMassive()
	LApi_TEST_MECH = PunchMech:new{ Massive = true }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local massive = pawn:IsMassive() == true
	
	LApi_TEST_MECH = PunchMech:new{ Massive = false }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local notMassive = pawn:IsMassive() == false
	
	return massive, notMassive
end

function tests:PawnSetMassive()
	LApi_TEST_MECH = PunchMech:new{ Massive = true }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
							local massive = pawn:IsMassive() == true
	pawn:SetMassive(false);	local notMassive = pawn:IsMassive() == false
	
	return massive, notMassive
end

function tests:PawnSetFlying()
	LApi_TEST_MECH = PunchMech:new{ Flying = true }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
							local flying = pawn:IsFlying() == true
	pawn:SetFlying(false);	local notFlying = pawn:IsFlying() == false
	
	return flying, notFlying
end

function tests:PawnSetTeleporter()
	LApi_TEST_MECH = PunchMech:new{ Teleporter = true }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
								local teleporter = pawn:IsTeleporter() == true
	pawn:SetTeleporter(false);	local notTeleporter = pawn:IsTeleporter() == false
	
	return teleporter, notTeleporter
end

function tests:PawnSetJumper()
	LApi_TEST_MECH = PunchMech:new{ Jumper = true }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
							local jumper = pawn:IsJumper() == true
	pawn:SetJumper(false);	local notJumper = pawn:IsJumper() == false
	
	return jumper, notJumper
end

-- fails if there are units on the field altering health.
function tests:PawnGetMaxHealth()
	LApi_TEST_MECH = PunchMech:new{ Health = 5 }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local maxHealth5 = pawn:GetMaxHealth() == 5
	
	LApi_TEST_MECH = PunchMech:new{ Health = 6 }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local maxHealth6 = pawn:GetMaxHealth() == 6
	
	return maxHealth5, maxHealth6
end

function tests:PawnGetBaseMaxHealth()
	local loc = Point(0,0)
	local locJelly = Point(1,0)
	Board:ClearSpace(loc)
	Board:ClearSpace(locJelly)
	
	local jelly = PAWN_FACTORY:CreatePawn("Jelly_Health1"); Board:AddPawn(jelly, locJelly)
	
	LApi_TEST_MECH = PunchMech:new{ Health = 5, SkillList = { "Passive_Psions" } }
	
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH"); Board:AddPawn(pawn, loc)
	local baseMaxHealth5 = pawn:GetBaseMaxHealth() == 5
	
	Board:ClearSpace(loc)
	Board:ClearSpace(locJelly)
	
	return baseMaxHealth5
end

function tests:PawnSetHealth()
	LApi_TEST_MECH = PunchMech:new{ Health = 5 }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
						local health5 = pawn:GetHealth() == 5
	pawn:SetHealth(7);	local health5Max = pawn:GetHealth() == 5
	pawn:SetHealth(2);	local health2 = pawn:GetHealth() == 2
	
	return health5, health5Max, health2
end

function tests:PawnSetMaxHealth()
	LApi_TEST_MECH = PunchMech:new{ Health = 5 }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
							local maxHealth5 = pawn:GetMaxHealth() == 5
	pawn:SetMaxHealth(7);	local maxHealth7 = pawn:GetMaxHealth() == 7
	
	return maxHealth5, maxHealth7
end

function tests:PawnSetBaseMaxHealth()
	LApi_TEST_MECH = PunchMech:new{ Health = 5 }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	
								local baseMaxHealth5 = pawn:GetBaseMaxHealth() == 5
	pawn:SetBaseMaxHealth(7);	local baseMaxHealth7 = pawn:GetBaseMaxHealth() == 7
	
	return baseMaxHealth5, baseMaxHealth7
end

function tests:PawnGetWeaponCount()
	LApi_TEST_MECH = PunchMech:new{ SkillList = { "Prime_Punchmech" } }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local weaponCount1 = pawn:GetWeaponCount() == 1
	
	LApi_TEST_MECH = PunchMech:new{ SkillList = { "Prime_Punchmech", "Brute_Tankmech" } }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local weaponCount2 = pawn:GetWeaponCount() == 2
	
	return weaponCount1, weaponCount2
end

function tests:PawnGetWeaponType()
	LApi_TEST_MECH = PunchMech:new{ SkillList = { "Prime_Punchmech", "Brute_Tankmech" } }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local weaponType1 = pawn:GetWeaponType(1) == "Prime_Punchmech"
	local weaponType2 = pawn:GetWeaponType(2) == "Brute_Tankmech"
	
	return weaponType1, weaponType2
end

function tests:PawnGetWeaponClass()
	LApi_TEST_MECH = PunchMech:new{ SkillList = { "Prime_Punchmech", "Brute_Tankmech" } }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local weaponClass1 = pawn:GetWeaponClass(1) == _G["Prime_Punchmech"].Class
	local weaponClass2 = pawn:GetWeaponClass(2) == _G["Brute_Tankmech"].Class
	
	return weaponClass1, weaponClass2
end

function tests:PawnRemoveWeapon()
	LApi_TEST_MECH = PunchMech:new{ SkillList = { "Prime_Punchmech", "Brute_Tankmech" } }
	local pawn = PAWN_FACTORY:CreatePawn("LApi_TEST_MECH")
	local weaponCount2 = pawn:GetWeaponCount() == 2
	
	pawn:RemoveWeapon(1)
	local weaponCount1 = pawn:GetWeaponCount() == 1
	
	return weaponCount2, weaponCount1
end
