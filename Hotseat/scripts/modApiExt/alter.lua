local modApiExtHooks = {}

function modApiExtHooks:setupTrackedData(pd, pawn)
	-- check each field separately, so that if there's a newer version
	-- checking after the data is created, it can append its own fields
	-- without overwriting the old ones.
	if pd.loc == nil then          pd.loc = pawn:GetSpace() end
	if pd.maxHealth == nil then    pd.maxHealth = _G[pawn:GetType()].Health end
	if pd.curHealth == nil then    pd.curHealth = pawn:GetHealth() end
	if pd.dead == nil then         pd.dead = (pawn:GetHealth() == 0) end
	if pd.selected == nil then     pd.selected = pawn:IsSelected() end
	if pd.undoPossible == nil then pd.undoPossible = pawn:IsUndoPossible() end
	if pd.isFire == nil then       pd.isFire = pawn:IsFire() end
	if pd.isAcid == nil then       pd.isAcid = pawn:IsAcid() end
	if pd.isFrozen == nil then     pd.isFrozen = pawn:IsFrozen() end
	if pd.isGrappled == nil then   pd.isGrappled = pawn:IsGrappled() end
	if pd.isShield == nil then     pd.isShield = pawn:IsShield() end
end

function modApiExtHooks:trackAndUpdatePawns(mission)
	if Board then
		if not GAME.trackedPawns then GAME.trackedPawns = {} end
		-- pawn userdata cannot be serialized, so store them in a separate
		-- table that is rebuilt at runtime.
		if not modApiExt_internal.pawns then modApiExt_internal.pawns = {} end

		local tbl = extract_table(Board:GetPawns(TEAM_ANY))

		-- Store information about pawns which should remain on the board,
		-- we can use this data later.
		local onBoard = {}

		-- If any of the tracked pawns were removed from the board, reinsert
		-- them into the table, to process them correctly.
		for id, pd in pairs(GAME.trackedPawns) do
			if not list_contains(tbl, id) then
				onBoard[id] = false
				table.insert(tbl, id)
			end
		end

		for i, id in pairs(tbl) do
			local pd = GAME.trackedPawns[id]
			local pawn = Board:GetPawn(id)

			if pawn and not modApiExt_internal.pawns[id] then
				-- regenerate pawn userdata table
				modApiExt_internal.pawns[id] = pawn
			elseif not pawn and modApiExt_internal.pawns[id] then
				pawn = modApiExt_internal.pawns[id]
			end

			-- Make sure we didn't get a pawn that was already deleted,
			-- in which case the userdata points to an invalid block of memory
			if pawn and pawn:GetId() == id then
				if not pd then
					-- Pawn is not tracked yet
					-- Create an empty table for its tracked fields
					pd = {}
					GAME.trackedPawns[id] = pd

					modApiExt_internal.firePawnTrackedHooks(mission, pawn)
				end

				self:setupTrackedData(pd, pawn)

				local p = pawn:GetSpace()
				local undo = pawn:IsUndoPossible()

				if pd.undoPossible ~= undo then
					-- Undo was possible in previous game update, but no longer is.
					-- Positions are different, which means that the undo was *not*
					-- disabled due to skill usage on a pawn -- swap skills
					-- are not instant, so we wouldn't register change in *both*
					-- undo state AND pawn position in a single update if that were
					-- the case. So it has to be the 'undo move' option.
					if pd.undoPossible and not undo and pd.loc ~= p then
						self.dialog:triggerRuledDialog("MoveUndo", { main = id })
						modApiExt_internal.firePawnUndoMoveHooks(mission, pawn, pd.loc)
					end

					pd.undoPossible = undo
				end

				if pd.loc ~= p then
					modApiExt_internal.firePawnPosChangedHooks(mission, pawn, pd.loc)

					pd.loc = p
				end

				local hp = pawn:GetHealth()
				if pd.curHealth ~= hp then
					local diff = hp - pd.curHealth

					if diff < 0 then
						-- took damage
						self.dialog:triggerRuledDialog("PawnDamaged", { target = id })
						modApiExt_internal.firePawnDamagedHooks(mission, pawn, -diff)
					else
						-- healed
						self.dialog:triggerRuledDialog("PawnHealed", { target = id })
						modApiExt_internal.firePawnHealedHooks(mission, pawn, diff)
					end

					pd.curHealth = hp
				end

				local isFire = pawn:IsFire()
				if pd.isFire ~= isFire then
					if isFire then
						self.dialog:triggerRuledDialog("PawnFire", { target = id })
					else
						self.dialog:triggerRuledDialog("PawnExtinguished", { target = id })
					end
					modApiExt_internal.firePawnIsFireHooks(mission, pawn, isFire)
					
					pd.isFire = isFire
				end

				local isAcid = pawn:IsAcid()
				if pd.isAcid ~= isAcid then
					if isAcid then
						self.dialog:triggerRuledDialog("PawnAcided", { target = id })
					else
						self.dialog:triggerRuledDialog("PawnUnacided", { target = id })
					end
					modApiExt_internal.firePawnIsAcidHooks(mission, pawn, isAcid)
					
					pd.isAcid = isAcid
				end

				local isFrozen = pawn:IsFrozen()
				if pd.isFrozen ~= isFrozen then
					if isFrozen then
						self.dialog:triggerRuledDialog("PawnFrozen", { target = id })
					else
						self.dialog:triggerRuledDialog("PawnUnfrozen", { target = id })
					end
					modApiExt_internal.firePawnIsFrozenHooks(mission, pawn, isFrozen)
					
					pd.isFrozen = isFrozen
				end

				local isGrappled = pawn:IsGrappled()
				if pd.isGrappled ~= isGrappled then
					if isGrappled then
						self.dialog:triggerRuledDialog("PawnGrappled", { target = id })
					else
						self.dialog:triggerRuledDialog("PawnUngrappled", { target = id })
					end
					modApiExt_internal.firePawnIsGrappledHooks(mission, pawn, isGrappled)
					
					pd.isGrappled = isGrappled
				end

				local isShield = pawn:IsShield()
				if pd.isShield ~= isShield then
					if isShield then
						self.dialog:triggerRuledDialog("PawnShielded", { target = id })
					else
						self.dialog:triggerRuledDialog("PawnUnshielded", { target = id })
					end
					modApiExt_internal.firePawnIsShieldedHooks(mission, pawn, isShield)
					
					pd.isShield = isShield
				end

				-- Deselection
				if pd.selected and not pawn:IsSelected() then
					self.dialog:triggerRuledDialog("PawnDeselected", { target = id })
					modApiExt_internal.firePawnDeselectedHooks(mission, pawn)

					pd.selected = false
				end

				if
					Pawn and Pawn:GetId() == id and
					Pawn:IsSelected() and not pd.selected and
					Pawn:IsActive() and
					Pawn:GetTeam() == TEAM_ENEMY and
					Game:GetTeamTurn() == TEAM_ENEMY
				then
					-- Vek movement detection
					if modApiExt_internal.scheduledMovePawns[id] == nil then
						modApiExt_internal.scheduledMovePawns[id] = Pawn:GetSpace()

						modApiExt_internal.fireVekMoveStartHooks(modApiExt_internal.mission, pawn)

						modApi:conditionalHook(
							function()
								return modApiExt_internal.scheduledMovePawns[id] and
								      (not Board:IsBusy() or not Pawn or Pawn:GetId() ~= id or not pd.selected)
									
							end,
							function()
								modApiExt_internal.fireVekMoveEndHooks(
									modApiExt_internal.mission, pawn,
									modApiExt_internal.scheduledMovePawns[id],
									pawn:GetSpace()
								)
								modApiExt_internal.scheduledMovePawns[id] = nil
							end
						)
					end
				end
			else
				-- pawn was nil or invalid, remove this entry
				GAME.trackedPawns[id] = nil
				modApiExt_internal.pawns[id] = nil
			end
		end

		for id, pd in pairs(GAME.trackedPawns) do
			local pawn = Board:GetPawn(id) or modApiExt_internal.pawns[id]

			if pawn then
				-- Process selection in separate loop, so that callbacks always go
				-- Deselection -> Selection, instead of relying on pawn order in table
				if not pd.selected and pawn:IsSelected() then
					pd.selected = true
					self.dialog:triggerRuledDialog("PawnSelected", { target = id })
					modApiExt_internal.firePawnSelectedHooks(mission, pawn)
				end

				if not pd.dead and pd.curHealth == 0 then
					pd.dead = true
					self.dialog:triggerRuledDialog("PawnKilled", { target = id })
					modApiExt_internal.firePawnKilledHooks(mission, pawn)
				end

				if pd.dead and pd.curHealth ~= 0 then
					pd.dead = false
					self.dialog:triggerRuledDialog("PawnRevived", { target = id })
					modApiExt_internal.firePawnRevivedHooks(mission, pawn)
				end

				-- Treat pawns not registered in the onBoard table as on board.
				local wasOnBoard = onBoard[id] or onBoard[id] == nil
				if not wasOnBoard then
					-- Dead non-player pawns are removed from the board, so we can
					-- just remove them from tracking since they're not going to
					-- come back to life.
					-- However, player pawns (mechs) stay on the board when
					-- dead. Don't remove them from the tracking table, since if we
					-- do that, they're going to get reinserted.
					GAME.trackedPawns[id] = nil
					modApiExt_internal.pawns[id] = nil

					modApiExt_internal.firePawnUntrackedHooks(mission, pawn)
				end
			end
		end
	end
end

function modApiExtHooks:trackAndUpdateBuildings(mission)
	if Board then
		if not GAME.trackedBuildings then GAME.trackedBuildings = {} end

		local tbl = extract_table(Board:GetBuildings())

		local w = Board:GetSize().x
		for i, point in pairs(tbl) do
			local idx = p2idx(point, w)
			if not GAME.trackedBuildings[idx] then
				-- Building not tracked yet
				GAME.trackedBuildings[idx] = {
					loc = point,
					destroyed = false,
					shield = false,
				}
			else
				-- Already tracked, update its data...
				-- ...if there were any
			end
		end

		for idx, bld in pairs(GAME.trackedBuildings) do
			if not bld.destroyed then
				if not Board:IsBuilding(bld.loc) then
					bld.destroyed = true

					self.dialog:triggerRuledDialog("BldgDestroyed")
					modApiExt_internal.fireBuildingDestroyedHooks(mission, bld)
				end
			end
		end
	end
end

function modApiExtHooks:updateTiles()
	if Board then
		if not GAME.trackedPods then GAME.trackedPods = {} end

		local mtile = mouseTile()
		if modApiExt_internal.currentTile ~= mtile then
			if modApiExt_internal.currentTile then -- could be nil
				modApiExt_internal.fireTileUnhighlightedHooks(mission, modApiExt_internal.currentTile)
			end

			modApiExt_internal.currentTile = mtile

			if modApiExt_internal.currentTile then -- could be nil
				modApiExt_internal.fireTileHighlightedHooks(mission, modApiExt_internal.currentTile)
			end
		end

		self:findAndTrackPods()

		for i, p in ipairs(GAME.trackedPods) do
			if
				not Board:IsPod(p) and
				Board:IsPawnSpace(p) and
				Board:GetPawn(p):GetTeam() ~= TEAM_PLAYER
			then
				table.remove(GAME.trackedPods, i)
				modApiExt_internal.firePodTrampledHooks(Board:GetPawn(p))
			elseif not Board:IsPod(p) then
				table.remove(GAME.trackedPods, i)
			end
		end
	end
end

function modApiExtHooks:findAndTrackPods()
	if Board and GAME.pendingPods and GAME.pendingPods > 0 then
		local size = Board:GetSize()
		for y = 0, size.y - 1 do
			for x = 0, size.x - 1 do
				local p = Point(x, y)
				if
					Board:IsPod(p) and
					not list_contains(GAME.trackedPods, p)
				then
					GAME.pendingPods = GAME.pendingPods - 1
					table.insert(GAME.trackedPods, p)
					modApiExt_internal.firePodLandedHooks(p)
				end
			end
		end
	end
end

--[[
	Fix for SpaceScript function causing the game to update the tile
	the damage occurs on. This causes some inconsistency with vanilla
	game behaviour, most notably self-pushing, self-harming damage
	instances (eg. Unstable Mech's weapon) setting forests on fire,
	and the update causing the fire to spread to the mech before it
	is pushed off the tile.
--]]
function GetClosestOffBoardLocation(loc)
	local minPoint = nil
	local minDistance = 100

	for y = -1, 8 do
		for x = -1, 8 do
			if x == -1 or x == 8 or y == -1 or y == 8 then
				local point = Point(x, y)
				local d = loc:Manhattan(point)

				if d < minDistance then
					minPoint = point
					minDistance = d
				end
			end
		end
	end

	return minPoint
end

function SpaceScript(loc, script)
	local d = SpaceDamage(loc)
	d.sScript = script

	-- Scripts with location set on the board, and added as queued
	-- damage put a gray stripe pattern on their tile. Setting these
	-- (or one of them?) to true prevents it from showing up.
	d.bHide = true
	d.bHidePath = true

	return d
end

local function modApiExtGetSkillEffect(self, p1, p2, parentSkill, ...)
	-- Dereference to weapon object
	if type(self) == "string" then
		self = _G[self]
	end

	local isValidSkillTable = parentSkill and type(parentSkill) == "table" and
	                          type(parentSkill.GetSkillEffect) == "function"
	local isPrimaryCall = not isValidSkillTable

	local skillFx = nil
	if isPrimaryCall then
		skillFx = modApiExt_internal.oldSkills[self.__Id](self, p1, p2, getmetatable(self), ...)
	else
		-- Defer to parent skill's GetSkillEffect.
		skillFx = modApiExt_internal.oldSkills[parentSkill.__Id](self, p1, p2, getmetatable(parentSkill), ...)
	end

	-- If it's a secondary call to the GetSkillEffect, then we don't
	-- want it to fire hooks (since the primary call already fired them).
	-- For vanilla skills, the additional argument will be ignored.
	if isPrimaryCall then
		if not Board.gameBoard then
			if Board:GetSize() == Point(6, 6) then
				-- Hacky AF solution to detect when tip image is visible
				local d = Board:GetPawn(Board:AddPawn("kf_ModApiExt_Dummy", Point(0, 0)))
				d:SetCustomAnim("kf_ModApiExt_TipMarker")
			else
				-- It seems that sometimes Board.gameBoard is not set,
				-- but I can't reproduce the bug.
				-- For now use a board size check and log the message to try
				-- to figure it out.
				--LOG("Was in game board, but Board.gameBoard was not set! " .. tostring(modApiExt_internal.version))
			end
		end

		if not Pawn then
			-- PAWN is missing, this happens when loading into a game
			-- in progress in combat. Attempt to fix this by getting the
			-- pawn at p1.
			-- This seems to be used only for constructing weapon previews
			-- for enemies, so even if this is wrong (it shouldn't), it
			-- should be pretty harmless.
			Pawn = Board:GetPawn(p1)
		end

		modApiExt_internal.fireSkillBuildHooks(
			modApiExt_internal.mission,
			Pawn, self.__Id, p1, p2, skillFx
		)

		if not skillFx.effect:empty() then
			local fx = SkillEffect()
			local effects = extract_table(skillFx.effect)

			fx:AddScript(
				"modApiExt_internal.fireSkillStartHooks("
				.."modApiExt_internal.mission, Pawn,"
				.."\""..self.__Id.."\","..p1:GetString()..","..p2:GetString()..")"
			)

			for _, e in pairs(effects) do
				fx.effect:push_back(e)
			end

			fx:AddScript(
				"modApiExt_internal.fireSkillEndHooks("
				.."modApiExt_internal.mission, Pawn,"
				.."\""..self.__Id.."\","..p1:GetString()..","..p2:GetString()..")"
			)

			if
				self == Prime_Punchmech    or
				self == Prime_Punchmech_A  or
				self == Prime_Punchmech_B  or
				self == Prime_Punchmech_AB
			then
				-- Add a dummy damage instance to fix Ramming Speed
				-- achievement being incorrectly granted
				fx:AddDamage(SpaceDamage(GetProjectileEnd(p1, p2)))
			end

			skillFx.effect = fx.effect
		end

		if not skillFx.q_effect:empty() then
			local fx = SkillEffect()
			local effects = extract_table(skillFx.q_effect)

			fx:AddScript(
				"modApiExt_internal.fireQueuedSkillStartHooks("
				.."modApiExt_internal.mission, Pawn,"
				.."\""..self.__Id.."\","..p1:GetString()..","..p2:GetString()..")"
			)

			for _, e in pairs(effects) do
				fx.effect:push_back(e)
			end

			fx:AddScript(
				"modApiExt_internal.fireQueuedSkillEndHooks("
				.."modApiExt_internal.mission, Pawn,"
				.."\""..self.__Id.."\","..p1:GetString()..","..p2:GetString()..")"
			)

			skillFx.q_effect = fx.effect
		end
	end

	return skillFx
end

function modApiExtHooks:overrideSkill(id, skill)
	assert(skill.GetSkillEffect)
	assert(_G[id] == skill) -- no fun allowed

	if modApiExt_internal.oldSkills[id] then
		error(id .. " is already overridden!")
	end

	modApiExt_internal.oldSkills[id] = skill.GetSkillEffect

	-- Make it possible to identify skills with no ambiguity
	skill.__Id = id
	skill.GetSkillEffect = modApiExtGetSkillEffect
end

function modApiExtHooks:overrideAllSkills()
	if not modApiExt_internal.oldSkills then
		modApiExt_internal.oldSkills = {}

		for k, v in pairs(_G) do
			if type(v) == "table" and v.GetSkillEffect then
				self:overrideSkill(k, v)
			end
		end
	end
end

function modApiExtHooks:reset()
	GAME.trackedBuildings = nil
	GAME.trackedPawns = nil
	GAME.trackedPods = nil
	GAME.pendingPods = nil
	modApiExt_internal.currentTile = nil
	modApiExt_internal.pawns = nil
	modApiExt_internal.mission = nil
	modApiExt_internal.runLaterQueue = nil
	GAME.elapsedTime = nil
	modApiExt_internal.elapsedTime = nil
end

---------------------------------------------

modApiExtHooks.missionStart = function(mission)
	modApiExtHooks:reset()
	if Board and not Board.gameBoard then
		Board.gameBoard = true 
	end
end

modApiExtHooks.missionEnd = function(mission, ret)
	modApiExtHooks:reset()
end

modApiExtHooks.missionUpdate = function(mission)
	-- Store the mission for use by other hooks which can't be called from
	-- the missionUpdate hook.
	-- Set it here, in case we load into a game in progress (missionStart
	-- is not executed then)
	if not modApiExt_internal.mission and mission then
		modApiExt_internal.mission = mission
	end
	if Board and not Board.gameBoard then
		Board.gameBoard = true
	end

	local t = modApi:elapsedTime()
	GAME.elapsedTime = t
	modApiExt_internal.elapsedTime = t

	modApiExtHooks:updateTiles()
	modApiExtHooks:trackAndUpdateBuildings(mission)
	modApiExtHooks:trackAndUpdatePawns(mission)
end

modApiExtHooks.voiceEvent = function(event, customOdds, suppress)
	if event.id == "PodDetected" then
		GAME.pendingPods = (GAME.pendingPods or 0) + 1
		modApiExt_internal.firePodDetectedHooks()
	elseif event.id == "PodDestroyed" then
		if event.pawn1 == -1 and Pawn and Pawn:IsSelected() then
			event.pawn1 = Pawn:GetId()
		end

		modApiExt_internal.firePodDestroyedHooks(Game:GetPawn(event.pawn1))
	elseif event.id == "PodCollected" then
		modApiExt_internal.firePodCollectedHooks(Game:GetPawn(event.pawn1))
	end

	if not suppress then
		-- use the voice event's cast data if it has any
		local cast = nil
		if event.pawn1 ~= -1 then
			cast = cast or {}
			cast.main = event.pawn1
		end
		if event.pawn2 ~= -1 then
			cast = cast or {}
			cast.target = event.pawn2
		end
		
		-- dialog already broadcasts the event to all registered extObjects
		-- via shared dialogs table
		return modApiExtHooks.dialog:triggerRuledDialog(event.id, cast, customOdds)
	end

	return false
end

return modApiExtHooks
