local internal = {}

--[[
	Creates a broadcast function for the specified hooks field, allowing
	to trigger the hook callbacks on all registered modApiExt objects.

	The second argument is a function that provides arguments the hooks
	will be invoked with, used only if the broadcast function was invoked
	without any arguments. Can be nil to invoke argument-less hooks.
--]]
function internal:buildBroadcastFunc(hooksField, argsFunc)
	local errfunc = function(e)
		return string.format(
			"A '%s' callback has failed:\n%s",
			hooksField, e
		)
	end

	return function(...)
		local args = {...}

		if #args == 0 then
			-- We didn't receive arguments directly. Fall back to
			-- the argument function.
			-- Make sure that all hooks receive the same arguments.
			args = argsFunc and {argsFunc()} or nil
		end

		for i, extObj in ipairs(modApiExt_internal.extObjects) do
			if extObj[hooksField] then
				for j, hook in ipairs(extObj[hooksField]) do
					-- invoke the hook in a xpcall, since errors in SkillEffect
					-- scripts fail silently, making debugging a nightmare.
					local ok, err = xpcall(
						args
							and function() hook(unpack(args)) end
							or  function() hook() end,
						errfunc
					)

					if not ok then
						local owner = extObj.owner and extObj.owner.id or "<unknown>"
						LOG("In mod id '" .. owner .. "', ", err)
					end
				end
			end
		end
	end
end

function internal:createIfMissing(object, name)
	object[name] = object[name] or {}
end

function internal:initBroadcastHooks(tbl)
	tbl.fireMostRecentResolvedHooks = self:buildBroadcastFunc("mostRecentResolvedHooks")

	tbl.firePawnTrackedHooks =       self:buildBroadcastFunc("pawnTrackedHooks")
	tbl.firePawnUntrackedHooks =     self:buildBroadcastFunc("pawnUntrackedHooks")
	tbl.firePawnUndoMoveHooks =      self:buildBroadcastFunc("pawnUndoMoveHooks")
	tbl.firePawnPosChangedHooks =    self:buildBroadcastFunc("pawnPositionChangedHooks")
	tbl.firePawnDamagedHooks =       self:buildBroadcastFunc("pawnDamagedHooks")
	tbl.firePawnHealedHooks =        self:buildBroadcastFunc("pawnHealedHooks")
	tbl.firePawnKilledHooks =        self:buildBroadcastFunc("pawnKilledHooks")
	tbl.firePawnRevivedHooks =       self:buildBroadcastFunc("pawnRevivedHooks")
	tbl.firePawnIsFireHooks =        self:buildBroadcastFunc("pawnIsFireHooks")
	tbl.firePawnIsAcidHooks =        self:buildBroadcastFunc("pawnIsAcidHooks")
	tbl.firePawnIsFrozenHooks =      self:buildBroadcastFunc("pawnIsFrozenHooks")
	tbl.firePawnIsGrappledHooks =    self:buildBroadcastFunc("pawnIsGrappledHooks")
	tbl.firePawnIsShieldedHooks =    self:buildBroadcastFunc("pawnIsShieldedHooks")
	tbl.firePawnSelectedHooks =      self:buildBroadcastFunc("pawnSelectedHooks")
	tbl.firePawnDeselectedHooks =    self:buildBroadcastFunc("pawnDeselectedHooks")

	tbl.fireTileHighlightedHooks =   self:buildBroadcastFunc("tileHighlightedHooks")
	tbl.fireTileUnhighlightedHooks = self:buildBroadcastFunc("tileUnhighlightedHooks")

	tbl.fireBuildingDamagedHooks =   self:buildBroadcastFunc("buildingDamagedHooks")
	tbl.fireBuildingResistHooks =    self:buildBroadcastFunc("buildingResistHooks")
	tbl.fireBuildingDestroyedHooks = self:buildBroadcastFunc("buildingDestroyedHooks")
	tbl.fireBuildingShieldHooks =    self:buildBroadcastFunc("buildingShieldHooks")

	tbl.fireMoveStartHooks =         self:buildBroadcastFunc("pawnMoveStartHooks")
	tbl.fireMoveEndHooks =           self:buildBroadcastFunc("pawnMoveEndHooks")
	tbl.fireVekMoveStartHooks =      self:buildBroadcastFunc("vekMoveStartHooks")
	tbl.fireVekMoveEndHooks =        self:buildBroadcastFunc("vekMoveEndHooks")

	tbl.fireSkillStartHooks =        self:buildBroadcastFunc("skillStartHooks")
	tbl.fireSkillEndHooks =          self:buildBroadcastFunc("skillEndHooks")
	tbl.fireQueuedSkillStartHooks =  self:buildBroadcastFunc("queuedSkillStartHooks")
	tbl.fireQueuedSkillEndHooks =    self:buildBroadcastFunc("queuedSkillEndHooks")
	tbl.fireSkillBuildHooks =        self:buildBroadcastFunc("skillBuildHooks")

	tbl.fireResetTurnHooks =         self:buildBroadcastFunc("resetTurnHooks")
	tbl.fireGameLoadedHooks =        self:buildBroadcastFunc("gameLoadedHooks")

	tbl.fireTipImageShownHooks =     self:buildBroadcastFunc("tipImageShownHooks")
	tbl.fireTipImageHiddenHooks =    self:buildBroadcastFunc("tipImageHiddenHooks")

	tbl.firePodDetectedHooks =       self:buildBroadcastFunc("podDetectedHooks")
	tbl.firePodLandedHooks =         self:buildBroadcastFunc("podLandedHooks")
	tbl.firePodTrampledHooks =       self:buildBroadcastFunc("podTrampledHooks")
	tbl.firePodDestroyedHooks =      self:buildBroadcastFunc("podDestroyedHooks")
	tbl.firePodCollectedHooks =      self:buildBroadcastFunc("podCollectedHooks")
end

function internal:createDialogTables(tbl)
	--[[
	TODO:

	local table = {
		"VekKilled", ...
	}

	for i, ve in ipairs(table) do
		self:createIfMissing(tbl.ruledDialogs, ve)
	end
	
	--]]

	-- default voiced (dialog) events
	self:createIfMissing(tbl.ruledDialogs, "VekKilled")
	self:createIfMissing(tbl.ruledDialogs, "BotKilled")
	self:createIfMissing(tbl.ruledDialogs, "VekKilled_Enemy")
	self:createIfMissing(tbl.ruledDialogs, "BotKilled_Enemy")
	self:createIfMissing(tbl.ruledDialogs, "DoubleVekKill")
	self:createIfMissing(tbl.ruledDialogs, "DoubleVekKill_Enemy")
	self:createIfMissing(tbl.ruledDialogs, "Vek_Drown")
	self:createIfMissing(tbl.ruledDialogs, "Vek_Fall")
	self:createIfMissing(tbl.ruledDialogs, "Vek_Smoke")
	self:createIfMissing(tbl.ruledDialogs, "Vek_Frozen")
	self:createIfMissing(tbl.ruledDialogs, "Emerge_Detected")
	self:createIfMissing(tbl.ruledDialogs, "Emerge_FailedMech")
	self:createIfMissing(tbl.ruledDialogs, "Emerge_FailedVek")
	self:createIfMissing(tbl.ruledDialogs, "Emerge_Success")
	self:createIfMissing(tbl.ruledDialogs, "BldgDestroyed")
	self:createIfMissing(tbl.ruledDialogs, "BldgDamaged")
	self:createIfMissing(tbl.ruledDialogs, "BldgDamaged_Enemy")
	self:createIfMissing(tbl.ruledDialogs, "Bldg_Resisted")
	self:createIfMissing(tbl.ruledDialogs, "MntDestroyed")
	self:createIfMissing(tbl.ruledDialogs, "MntDestroyed_Enemy")
	self:createIfMissing(tbl.ruledDialogs, "PowerCritical")
	self:createIfMissing(tbl.ruledDialogs, "Mech_WebBlocked")
	self:createIfMissing(tbl.ruledDialogs, "Mech_Webbed")
	self:createIfMissing(tbl.ruledDialogs, "Mech_Shielded")
	self:createIfMissing(tbl.ruledDialogs, "Mech_Repaired")
	self:createIfMissing(tbl.ruledDialogs, "Mech_ShieldDown")
	self:createIfMissing(tbl.ruledDialogs, "Mech_LowHealth")
	self:createIfMissing(tbl.ruledDialogs, "Pilot_Selected")
	self:createIfMissing(tbl.ruledDialogs, "Pilot_Undo")
	self:createIfMissing(tbl.ruledDialogs, "Pilot_Moved")
	self:createIfMissing(tbl.ruledDialogs, "Pilot_Level")
	self:createIfMissing(tbl.ruledDialogs, "PilotDeath")
	self:createIfMissing(tbl.ruledDialogs, "PilotDeath_Hospital")
	self:createIfMissing(tbl.ruledDialogs, "PilotDeath_AI")
	self:createIfMissing(tbl.ruledDialogs, "Upgrade_PowerGeneric")
	self:createIfMissing(tbl.ruledDialogs, "Upgrade_PowerWeapon")
	self:createIfMissing(tbl.ruledDialogs, "Gamestart")
	self:createIfMissing(tbl.ruledDialogs, "Gamestart_Alien")
	self:createIfMissing(tbl.ruledDialogs, "Gameover")
	self:createIfMissing(tbl.ruledDialogs, "TimeTravel_Win")

	self:createIfMissing(tbl.ruledDialogs, "Secret_DeviceSeen_Ice")
	self:createIfMissing(tbl.ruledDialogs, "Secret_DeviceSeen_Mountain")
	self:createIfMissing(tbl.ruledDialogs, "Secret_DeviceUsed")
	self:createIfMissing(tbl.ruledDialogs, "Secret_Arriving")
	self:createIfMissing(tbl.ruledDialogs, "FTL_Found")

	self:createIfMissing(tbl.ruledDialogs, "PodDetected")
	self:createIfMissing(tbl.ruledDialogs, "PodDestroyed")
	self:createIfMissing(tbl.ruledDialogs, "PodCollected")

	self:createIfMissing(tbl.ruledDialogs, "MissionStart")
	self:createIfMissing(tbl.ruledDialogs, "Mission_ResetTurn")
	self:createIfMissing(tbl.ruledDialogs, "MissionEnd_Retreat")
	self:createIfMissing(tbl.ruledDialogs, "MissionEnd_Dead")

	self:createIfMissing(tbl.ruledDialogs, "MissionFinal_Start")
	self:createIfMissing(tbl.ruledDialogs, "MissionFinal_StartResponse")
	self:createIfMissing(tbl.ruledDialogs, "MissionFinal_Pylons")
	self:createIfMissing(tbl.ruledDialogs, "MissionFinal_Bomb")
	self:createIfMissing(tbl.ruledDialogs, "MissionFinal_BombResponse")
	self:createIfMissing(tbl.ruledDialogs, "MissionFinal_BombDestroyed")
	self:createIfMissing(tbl.ruledDialogs, "MissionFinal_BombArmed")
	self:createIfMissing(tbl.ruledDialogs, "MissionFinal_CaveStart")
	self:createIfMissing(tbl.ruledDialogs, "MissionFinal_FallStart")
	self:createIfMissing(tbl.ruledDialogs, "MissionFinal_FallResponse")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Block_Reminder")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Freeze_Mines_Vek")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Mines_Vek")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Dam_Destroyed")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Satellite_Imminent")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Satellite_Launch")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Solar_Destroyed")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Tanks_Activated")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Tanks_PartialActivated")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Cataclysm_Falling")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Terraform_Attacks")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Airstrike_Incoming")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Lightning_Strike_Vek")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Power_Destroyed")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Factory_Spawning")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Factory_Destroyed")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Reactivation_Thawed")
	self:createIfMissing(tbl.ruledDialogs, "Mission_SnowStorm_FrozenVek")
	self:createIfMissing(tbl.ruledDialogs, "Mission_SnowStorm_FrozenMech")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Disposal_Activated")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Barrels_Destroyed")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Teleporter_Mech")
	self:createIfMissing(tbl.ruledDialogs, "Mission_Belt_Mech")

	-- modApiExt dialog events
	self:createIfMissing(tbl.ruledDialogs, "GameLoad")
	self:createIfMissing(tbl.ruledDialogs, "MoveStart")
	self:createIfMissing(tbl.ruledDialogs, "MoveEnd")
	self:createIfMissing(tbl.ruledDialogs, "MoveUndo")
	self:createIfMissing(tbl.ruledDialogs, "PawnDamaged")
	self:createIfMissing(tbl.ruledDialogs, "PawnHealed")
	self:createIfMissing(tbl.ruledDialogs, "PawnKilled")
	self:createIfMissing(tbl.ruledDialogs, "PawnRevived")
	self:createIfMissing(tbl.ruledDialogs, "PawnFire")
	self:createIfMissing(tbl.ruledDialogs, "PawnExtinguished")
	self:createIfMissing(tbl.ruledDialogs, "PawnAcided")
	self:createIfMissing(tbl.ruledDialogs, "PawnUnacided")
	self:createIfMissing(tbl.ruledDialogs, "PawnFrozen")
	self:createIfMissing(tbl.ruledDialogs, "PawnUnfrozen")
	self:createIfMissing(tbl.ruledDialogs, "PawnGrappled")
	self:createIfMissing(tbl.ruledDialogs, "PawnUngrappled")
	self:createIfMissing(tbl.ruledDialogs, "PawnShielded")
	self:createIfMissing(tbl.ruledDialogs, "PawnUnshielded")
	self:createIfMissing(tbl.ruledDialogs, "PawnSelected")
	self:createIfMissing(tbl.ruledDialogs, "PawnDeselected")
end

function internal:initCompat(tbl)
	tbl.timer = modApi.timer
end

--[[
	Initializes globals used by all instances of modApiExt.
--]]
function internal:init(extObj)
	if not modApiExt_internal then modApiExt_internal = {} end

	-- either initialize (if no version was previously defined),
	-- or overwrite if we're more recent. Either way, we want to
	-- keep old fields around in case the older version needs them.
	local v = modApiExt_internal.version
	if not v or (v ~= extObj.version and modApi:isVersion(v, extObj.version)) then
		local m = modApiExt_internal -- for convenience and readability

		m.version = extObj.version
		-- list of all modApiExt instances
		-- make sure we remember the ones that have registered thus far
		m.extObjects = m.extObjects or {}

		-- Returns the most recent registered instance of modApiExt.
		m.getMostRecent = function()
			assert(modApiExt_internal.extObjects)

			local result = nil
			for _, extObj in ipairs(modApiExt_internal.extObjects) do
				result = result or extObj
				if
					result.version ~= extObj.version and 
					modApi:isVersion(result.version, extObj.version)
				then
					result = extObj
				end
			end

			return result
		end

		-- Hacky AF solution to detect when tip image is visible.
		-- Need something that will absolutely not get drawn during gameplay,
		-- and apparently we can't insert our own sprite, it doesn't work...
		local s = "strategy/hangar_stencil.png"
		m.tipMarkerVisible = false
		m.tipMarker = sdlext.surface("img/"..s)
		ANIMS.kf_ModApiExt_TipMarker = ANIMS.Animation:new({
			Image = s,
			PosY = 1000, -- make sure it's outside of the viewport
			Loop = true
		})

		-- current mission, for passing as arg to hooks
		m.mission = nil
		m.isTestMech = false
		-- table of pawn userdata, kept only at runtime to help
		-- with pawn hooks
		m.pawns = nil
		m.scheduledMovePawns = {}

		m.elapsedTime = nil

		m.tipBoards = {}

		self:initBroadcastHooks(m)

		m.drawHook = sdl.drawHook(function(screen)
			if not Game then
				modApiExt_internal.elapsedTime = nil
				modApiExt_internal.mission = nil
			end

			if modApiExt_internal.tipMarkerVisible ~= modApiExt_internal.tipMarker:wasDrawn() then
				if modApiExt_internal.tipMarkerVisible then
					modApiExt_internal.fireTipImageHiddenHooks()
				else
					modApiExt_internal.fireTipImageShownHooks()
				end
			end
			modApiExt_internal.tipMarkerVisible = modApiExt_internal.tipMarker:wasDrawn()
		end)

		-- dialogs
		m.ruledDialogs = m.ruledDialogs or {}
		self:createDialogTables(m)

		-- backwards compatibility
		self:initCompat(m)
	end
end

return internal
