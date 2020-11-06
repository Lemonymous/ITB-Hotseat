
--[[
	untestable by automatic tests:
	GetHighlighted
	IsHighlighted - failed
	MarkGridLoss
	IsGameBoard
	IsMissionBoard
	IsTipImage
]]

local tests = LApi.Tests

tests:AddTests{
	"BoardSetFire",
	"BoardIsForest",
	"BoardIsForestFire",
	"BoardIsShield",
	"BoardSetShield",
	"BoardGetHealth",
	"BoardGetMaxHealth",
	"BoardSetMaxHealth",
	"BoardSetBuilding",
	"BoardSetMountain",
	"BoardSetIce",
	"BoardSetRubble",
	"BoardSetUniqueBuilding",
	"BoardGetUniqueBuilding",
	"BoardRemoveUniqueBuilding",
	"BoardGetItemName",
	"BoardRemoveItem",
}

function tests:BoardSetFire()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
	Board:SetFire(loc, true)
	local fire = Board:IsFire(loc) == true
	
	Board:SetFire(loc, false)
	local notFire = Board:IsFire(loc) == false
	
	return fire, notFire
end

function tests:BoardIsForest()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
											local notForest = Board:IsForest(loc) == false
	Board:SetTerrain(loc, TERRAIN_FOREST);	local forest = Board:IsForest(loc) == true
	Board:SetFire(loc, true);				local forestFire =  Board:IsForest(loc) == true
	Board:SetFire(loc, false);				local extinguishedForestFire =  Board:IsForest(loc) == true
	
	return notForest, forest, forestFire, extinguishedForestFire
end

function tests:BoardIsForestFire()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
											local notForest = Board:IsForestFire(loc) == false
	Board:SetTerrain(loc, TERRAIN_FOREST);	local forest = Board:IsForestFire(loc) == false
	Board:SetFire(loc, true);				local forestFire = Board:IsForestFire(loc) == true
	Board:SetFire(loc, false);				local isExtinguishedForestFire = Board:IsForest(loc) == false
	
	return notForest, forest, forestFire, extinguishedForestFire
end

function tests:BoardIsShield()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	local createShield = SpaceDamage(loc)
	local removeShield = SpaceDamage(loc)
	createShield.iShield = 1
	removeShield.iShield = -1
	
										local notShield = Board:IsShield(loc) == false
	Board:DamageSpace(createShield);	local createShield = Board:IsShield(loc) == true
	Board:DamageSpace(removeShield);	local removeShield = Board:IsShield(loc) == false
	
	return notShield, createShield, removeShield
end

function tests:BoardSetShield()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	
									local notShield = Board:IsShield(loc) == false
	Board:SetShield(loc, true);		local createShield = Board:IsShield(loc) == true
	Board:SetShield(loc, false);	local removeShield = Board:IsShield(loc) == false
	
	return notShield, createShield, removeShield
end

function tests:BoardGetHealth()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	local damage = SpaceDamage(loc, 1)
	
												local hp2 = Board:GetHealth(loc) == 2
	Board:DamageSpace(damage);					local hp1 = Board:GetHealth(loc) == 1
	Board:DamageSpace(damage);					local hp0 = Board:GetHealth(loc) == 0
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN);	local refresh = Board:GetHealth(loc) == 2
	
	return hp2, hp1, hp0, refresh
end

function tests:BoardGetMaxHealth()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	
	local maxHp2 = Board:GetMaxHealth(loc) == 2
	
	return maxHp2
end

function tests:BoardSetMaxHealth()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	Board:SetTerrain(loc, TERRAIN_BUILDING)
	
												local maxHp2 = Board:GetMaxHealth(loc) == 2
	Board:SetMaxHealth(loc, 5);					local maxHp4 = Board:GetMaxHealth(loc) == 4
	Board:SetMaxHealth(loc, -1);				local maxHp1 = Board:GetMaxHealth(loc) == 1
	Board:SetMaxHealth(loc, 3);					local maxHp3 = Board:GetMaxHealth(loc) == 3
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN);	local maxHpReset = Board:GetMaxHealth(loc) == 2
	
	return maxHp2, maxHp4, maxHp1, maxHp3, maxHpReset
end

function tests:BoardSetBuilding()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
									local road = Board:IsBuilding(loc) == false
	Board:SetBuilding(loc, 4, 4);	local building = Board:IsBuilding(loc) == true
									local hp4 = Board:GetHealth(loc) == 4
									local maxHp4 = Board:GetMaxHealth(loc) == 4
	Board:SetBuilding(loc, 1, 3);	local hp1 = Board:GetHealth(loc) == 1
									local maxHp3 = Board:GetMaxHealth(loc) == 3
	
	return road, building, hp4, maxHp4, hp1, maxHp3
end

function tests:BoardSetMountain()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
	Board:SetMountain(loc, 2);	local mountain = Board:IsTerrain(loc, TERRAIN_MOUNTAIN) == true
								local maxHp2 = Board:GetMaxHealth(loc) == 2
								local hp2 = Board:GetHealth(loc) == 2
	Board:SetMountain(loc, 1);	local hp1 = Board:GetHealth(loc) == 1
	Board:SetMountain(loc, 0);	local rubble = Board:IsTerrain(loc, TERRAIN_RUBBLE) == true
								local hp0 = Board:GetHealth(loc) == 0
	
	return mountain, maxHp2, hp2, hp1, rubble, hp0
end

function tests:BoardSetIce()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
	Board:SetIce(loc, 2);	local ice = Board:IsTerrain(loc, TERRAIN_ICE) == true
							local maxHp2 = Board:GetMaxHealth(loc) == 2
							local hp2 = Board:GetHealth(loc) == 2
	Board:SetIce(loc, 1);	local hp1 = Board:GetHealth(loc) == 1
	Board:SetIce(loc, 0);	local water = Board:IsTerrain(loc, TERRAIN_WATER) == true
	
	return ice, maxHp2, hp2, hp1, water
end

function tests:BoardSetRubble()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_MOUNTAIN)
	local damage = SpaceDamage(loc, DAMAGE_DEATH)
	
	Board:SetRubble(loc, true);					local rubble = Board:IsTerrain(loc, TERRAIN_RUBBLE) == true
	Board:SetRubble(loc, false);				local mountain = Board:IsTerrain(loc, TERRAIN_MOUNTAIN) == true
	Board:SetTerrain(loc, TERRAIN_BUILDING);
	Board:DamageSpace(damage);
	Board:SetRubble(loc, false);				local building = Board:IsBuilding(loc) == true
	
	return rubble, mountain, building
end

function tests:BoardSetUniqueBuilding()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_BUILDING)
	
	Board:SetUniqueBuilding(loc, "str_bar1");	local uniqueBuilding = Board:IsUniqueBuilding(loc) == true
	
	return uniqueBuilding
end

function tests:BoardGetUniqueBuilding()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_BUILDING)
	
	Board:SetUniqueBuilding(loc, "str_bar1");	local uniqueBuilding = Board:GetUniqueBuilding(loc) == "str_bar1"
	
	return uniqueBuilding
end

function tests:BoardRemoveUniqueBuilding()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	Board:SetTerrain(loc, TERRAIN_BUILDING)
	
	Board:SetUniqueBuilding(loc, "str_bar1")
	Board:RemoveUniqueBuilding(loc);			local removedUniqueBuilding = Board:GetUniqueBuilding(loc) == ""
	
	return uniqueBuilding
end

function tests:BoardGetItemName()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
	Board:SetItem(loc, "Item_Mine");	local mine = Board:GetItemName(loc) == "Item_Mine"
	
	return mine
end

function tests:BoardRemoveItem()
	local loc = Point(0,0)
	Board:ClearSpace(loc)
	
	Board:SetItem(loc, "Item_Mine");
	Board:RemoveItem(loc);				local noMine = Board:GetItemName(loc) == nil
	
	return noMine
end




