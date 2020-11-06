
BoardPawn.ClearUndoMove = function(self)
	Tests.AssertEquals("userdata", type(self), "Argument #0")
	
	CUtils.PawnClearUndoMove(self)
end

BoardPawn.SetUndoLoc = function(self, loc)
	LApi.AssertSignature{
		ret = "void",
		func = "SetUndoLoc",
		params = { self, loc },
		{ "userdata|BoardPawn&", "userdata|Point" },
	}
	
	CUtils.SetPawnUndoLoc(self, loc)
end

BoardPawn.GetUndoLoc = function(self)
	LApi.AssertSignature{
		ret = "Point",
		func = "GetUndoLoc",
		params = { self },
		{ "userdata|BoardPawn&" },
	}
	
	return CUtils.GetPawnUndoLoc(self)
end

BoardPawn.GetOwner = function(self)
	LApi.AssertSignature{
		ret = "int",
		func = "GetOwner",
		params = { self },
		{ "userdata|BoardPawn&" }
	}
	
	return CUtils.GetPawnOwner(self)
end

BoardPawn.SetOwner = function(self, iOwner)
	LApi.AssertSignature{
		ret = "void",
		func = "SetOwner",
		params = { self, iOwner },
		{ "userdata|BoardPawn&", "number|int" }
	}
	
	if self:IsMech() or self:GetId() == iOwner then
		return
	end
	
	local pawn = Board:GetPawn(iOwner)
	
	if not pawn then
		return
	end
	
	return CUtils.SetPawnOwner(self, iOwner)
end

BoardPawn.SetFire = function(self, fire)
	LApi.AssertSignature{
		ret = "void",
		func = "SetFire",
		params = { self, fire },
		{ "userdata|BoardPawn&", "boolean|bool" }
	}
	
	if fire == nil then
		fire = true
	end
	
	CUtils.SetPawnFire(self, fire)
end

BoardPawn.IsHighlighted = function(self)
	LApi.AssertSignature{
		ret = "Point",
		func = "IsHighlighted",
		params = { self },
		{ "userdata|BoardPawn&" }
	}
	
	return Board:IsHighlighted(self:GetSpace())
end

BoardPawn.GetImpactMaterial = function(self)
	LApi.AssertSignature{
		ret = "int",
		func = "GetImpactMaterial",
		params = { self, impactMaterial },
		{ "userdata|BoardPawn&" }
	}
	
	return CUtils.GetPawnImpactMaterial(self)
end

BoardPawn.SetImpactMaterial = function(self, impactMaterial)
	LApi.AssertSignature{
		ret = "void",
		func = "SetImpactMaterial",
		params = { self, impactMaterial },
		{ "userdata|BoardPawn&", "number|int" }
	}
	
	CUtils.SetPawnImpactMaterial(self, impactMaterial)
end

BoardPawn.GetColor = function(self)
	LApi.AssertSignature{
		ret = "int",
		func = "GetColor",
		params = { self },
		{ "userdata|BoardPawn&" }
	}
	
	return CUtils.GetPawnColor(self)
end

BoardPawn.SetColor = function(self, iColor)
	LApi.AssertSignature{
		ret = "void",
		func = "SetColor",
		params = { self, iColor },
		{ "userdata|BoardPawn&", "number|int" }
	}
	
	iColor = math.max(0, math.min(iColor, GetColorCount() - 1))
	
	CUtils.SetPawnColor(self, iColor)
end

BoardPawn.IsPlayerControlled = function(self)
	LApi.AssertSignature{
		ret = "bool",
		func = "IsPlayerControlled",
		params = { self },
		{ "userdata|BoardPawn&" }
	}
	
	return CUtils.IsPawnPlayerControlled(self)
end

BoardPawn.IsMassive = function(self)
	LApi.AssertSignature{
		ret = "bool",
		func = "IsMassive",
		params = { self },
		{ "userdata|BoardPawn&" }
	}
	
	return CUtils.IsPawnMassive(self)
end

BoardPawn.SetMassive = function(self, massive)
	LApi.AssertSignature{
		ret = "void",
		func = "SetMassive",
		params = { self, massive },
		{ "userdata|BoardPawn&", "boolean|bool" },
		{ "userdata|BoardPawn&" }
	}
	
	if massive == nil then
		massive = true
	end
	
	CUtils.SetPawnMassive(self, massive)
end

BoardPawn.IsMovementAvailable = function(self)
	LApi.AssertSignature{
		ret = "bool",
		func = "IsMovementAvailable",
		params = { self },
		{ "userdata|BoardPawn&" }
	}
	
	return not CUtils.IsPawnMovementSpent(self)
end

BoardPawn.SetMovementAvailable = function(self, movementAvailable)
	LApi.AssertSignature{
		ret = "void",
		func = "SetMovementAvailable",
		params = { self, movementAvailable },
		{ "userdata|BoardPawn&", "boolean|bool" },
		{ "userdata|BoardPawn&" }
	}
	
	if movementAvailable == nil then
		movementAvailable = true
	end
	
	CUtils.SetPawnMovementSpent(self, not movementAvailable)
end

BoardPawn.SetFlying = function(self, flying)
	LApi.AssertSignature{
		ret = "void",
		func = "SetFlying",
		params = { self, flying },
		{ "userdata|BoardPawn&", "boolean|bool" },
		{ "userdata|BoardPawn&" }
	}
	
	if flag == nil then
		flag = true
	end
	
	CUtils.SetPawnFlying(self, flying)
end

BoardPawn.SetTeleporter = function(self, teleporter)
	LApi.AssertSignature{
		ret = "void",
		func = "SetTeleporter",
		params = { self, teleporter },
		{ "userdata|BoardPawn&", "boolean|bool" },
		{ "userdata|BoardPawn&" }
	}
	
	if teleporter == nil then
		teleporter = true
	end
	
	CUtils.SetPawnTeleporter(self, teleporter)
end

BoardPawn.SetJumper = function(self, jumper)
	LApi.AssertSignature{
		ret = "void",
		func = "SetJumper",
		params = { self, jumper },
		{ "userdata|BoardPawn&", "boolean|bool" },
		{ "userdata|BoardPawn&" }
	}
	
	if jumper == nil then
		jumper = true
	end
	
	CUtils.SetPawnJumper(self, jumper)
end

BoardPawn.GetMaxHealth = function(self)
	LApi.AssertSignature{
		ret = "int",
		func = "GetMaxHealth",
		params = { self },
		{ "userdata|BoardPawn&" }
	}
	
	return CUtils.GetPawnMaxHealth(self)
end

BoardPawn.GetBaseMaxHealth = function(self)
	LApi.AssertSignature{
		ret = "int",
		func = "GetBaseMaxHealth",
		params = { self },
		{ "userdata|BoardPawn&" }
	}
	
	return CUtils.GetPawnBaseMaxHealth(self)
end

BoardPawn.SetHealth = function(self, hp)
	LApi.AssertSignature{
		ret = "void",
		func = "SetHealth",
		params = { self, hp },
		{ "userdata|BoardPawn&", "number|int" }
	}
	
	local hp_max = self:GetMaxHealth()
	hp = math.max(0, math.min(hp, hp_max))
	
	CUtils.SetPawnHealth(self, hp)
end

BoardPawn.SetMaxHealth = function(self, hp_max)
	LApi.AssertSignature{
		ret = "void",
		func = "SetMaxHealth",
		params = { self, hp_max },
		{ "userdata|BoardPawn&", "number|int" }
	}
	
	CUtils.SetPawnMaxHealth(self, hp_max)
end

BoardPawn.SetBaseMaxHealth = function(self, hp_max_base)
	LApi.AssertSignature{
		ret = "void",
		func = "SetBaseMaxHealth",
		params = { self, hp_max_base },
		{ "userdata|BoardPawn&", "number|int" }
	}
	
	CUtils.SetPawnBaseMaxHealth(self, hp_max_base)
end


BoardPawn.MarkHpLoss = function(self, hp_loss)
	CUtils.PawnMarkHpLoss(self, hp_loss)
end


BoardPawn.GetWeaponCount = function(self)
	return CUtils.PawnGetWeaponCount(self)
end

BoardPawn.GetWeaponType = function(self, index)
	return CUtils.PawnGetWeaponType(self, index)
end

BoardPawn.GetWeaponClass = function(self, index)
	return CUtils.PawnGetWeaponClass(self, index)
end

BoardPawn.GetMoveSkill = function(self)
	return CUtils.PawnGetMoveSkill(self)
end


BoardPawn.RemoveWeapon = function(self, index)
	return CUtils.PawnRemoveWeapon(self, index)
end

BoardPawn.SetMoveSkill = function(self, skill)
	CUtils.PawnSetMoveSkill(self, skill)
end

BoardPawn.SetRepairSkill = function(self, skill)
	CUtils.PawnSetRepairSkill(self, skill)
end

BoardPawn.GetPilot = function(self)
	return CUtils.PawnGetPilot(self)
end

local modloaderInitializeBoardPawn = InitializeBoardPawn
function InitializeBoardPawn()
	modloaderInitializeBoardPawn()
	
	local pawn = PAWN_FACTORY:CreatePawn("PunchMech")
	
	local function getMechCount()
		if not Board then
			return 0
		end
		
		local pawns = Board:GetPawns(TEAM_ANY)
		local count = 0
		
		for i = 1, pawns:size() do
			if Board:GetPawn(pawns:index(i)):IsMech() then
				count = count + 1
			end
		end
		
		return count
	end
	
	-- this is a very dangerous function to work with.
	-- loading a game with less than 3 mechs will crash the game.
	-- having more than 3 mechs at any point will crash the game.
	-- not sure if it is possible to use this in any safe way,
	-- but leaving it here because the ability to swap out mechs
	-- could potentially lead to some very cool mods.
	local oldSetMech = pawn.SetMech
	BoardPawn.SetMech = function(self, isMech)
		LApi.AssertSignature{
			ret = "void",
			func = "SetMech",
			params = { self, isMech },
			{ "userdata|BoardPawn&", "boolean|bool" },
			{ "userdata|BoardPawn&" }
		}
		
		if isMech == false then
			CUtils.SetPawnMech(self, isMech)
		elseif getMechCount() < 3 then
			oldSetMech(self)
		end
	end
	
	-- vanilla function only looks in pawn type table.
	BoardPawn.IsTeleporter = function(self)
		LApi.AssertSignature{
			ret = "bool",
			func = "IsTeleporter",
			params = { self },
			{ "userdata|BoardPawn&" }
		}
		
		return CUtils.IsPawnTeleporter(self)
	end
	
	-- vanilla function only looks in pawn type table.
	BoardPawn.IsJumper = function(self)
		LApi.AssertSignature{
			ret = "bool",
			func = "IsJumper",
			params = { self },
			{ "userdata|BoardPawn&" }
		}
		
		return CUtils.IsPawnJumper(self)
	end
	
	-- extend vanilla function to apply status without animation
	local oldSetFrozen = pawn.SetFrozen
	BoardPawn.SetFrozen = function(self, frozen, no_animation)
		if no_animation then
			return CUtils.SetPawnFrozen(self, frozen)
		end
		
		return oldSetFrozen(self, frozen)
	end
	
	-- extend vanilla function to apply status without animation
	local oldSetShield = pawn.SetShield
	BoardPawn.SetShield = function(self, shield, no_animation)
		if no_animation then
			return CUtils.SetPawnShield(self, shield)
		end
		
		return oldSetShield(self, shield)
	end
	
	-- extend vanilla function to apply status without animation
	local oldSetAcid = pawn.SetAcid
	BoardPawn.SetAcid = function(self, acid, no_animation)
		if no_animation then
			return CUtils.SetPawnAcid(self, acid)
		end
		
		return oldSetAcid(self, acid)
	end
	
	-- modified and improved version of vanilla Pawn.AddWeapon
	BoardPawn.AddWeaponEx = function(self, weapon)
		CUtils.PawnAddWeapon(self, weapon)
	end
end
