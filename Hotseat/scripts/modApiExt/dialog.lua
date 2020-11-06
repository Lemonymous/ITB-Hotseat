local dialog = {}

---------------------------------------------------------------
-- Ruled dialog internals

--[[
	Returns true if the pawn with the specified id already
	has a role in the specified cast, false otherwise.
--]]
function dialog:hasRuledDialogRole(pawnId, cast)
	for _, castId in pairs(cast) do
		if castId and pawnId == castId then
			return true
		end
	end

	return false
end

--[[
	Attempts to build a cast out of the specified list of pawn ids
	and cast rules. Returns the cast table, or nil if the cast could
	not be built with the specified pawns and given rules.

	Can optionally specify the protoCast parameter if a priori
	knowledge about the cast is available (eg. we know which pawn
	fired a weapon, so it gets the 'main' role). Cast rules will
	still be applied to validate the cast pawns.
--]]
function dialog:buildRuledDialogCast(pawnIds, castRules, protoCast)
	local cast = protoCast or {}
	local castCopy = nil

	for castRole, rule in pairs(castRules) do
		-- Create a shallow copy of the cast table, so that rules
		-- can't modify the cast, only read its contents
		castCopy = shallow_copy(cast)

		if cast[castRole] then
			-- we have a pawn from protoCast, check if it matches the rule
			if not rule(cast[castRole], castCopy) then
				-- if it doesn't, then return invalid cast
				return nil
			end
		else
			for i, id in ipairs(pawnIds) do
				local p = Game:GetPawn(id)
				if p then
					-- don't cast a pawn into more than one role
					local hasRole = self:hasRuledDialogRole(id, cast)

					if
						not hasRole     and
						not p:IsDead()  and
						rule(id, castCopy)
					then
						cast[castRole] = id
						break
					end
				end
			end
		end
	end

	-- check if we filled all roles in the cast
	for castRole, _ in pairs(castRules) do
		if not cast[castRole] then
			return nil
		end
	end

	return cast
end

--[[
	Adds voice popups for all roles in the specified dialog
	segment, using the specified cast to fill the roles.
--]]
function dialog:addRuledDialogVoicePopup(segment, cast)
	if not cast.main then cast.main = -1 end
	if not cast.target then cast.target = -1 end
	if not cast.other then cast.other = -1 end

	local count = 0
	for role, personalityDialog in pairs(segment) do
		-- Enforce a single role per dialog segment
		if count == 1 then
			error("A dialog segment may only define a dialog for a single role!")
		end
		count = count + 1

		-- Get the pawn that was cast in this role
		local actor = cast[role]

		-- Override CEO role
		if role == "ceo" then
			actor = PAWN_ID_CEO
		end

		-- Game expects missing roles to be marked by id -1
		if not actor then
			cast[role] = -1
			actor = -1
		end

		AddVoicePopup(personalityDialog, actor, cast)
	end
end

---------------------------------------------------------------
-- Ruled dialog API

--[[
	Triggers a ruled dialog event with the specified id.

	Can optionally specify the protoCast parameter when a priori
	knowledge about the cast is available (eg. we know which pawn
	fired a weapon, so it gets the 'main' role). Cast rules will
	still be applied to validate the cast pawns.

	Can optionally specify customOdds parameter to override each
	ruled dialog's default odds.
--]]
function dialog:triggerRuledDialog(dialogEvent, protoCast, customOdds)
	assert(type(dialogEvent) == "string")
	if protoCast then assert(type(protoCast) == "table") end
	if customOdds then
		assert(type(customOdds) == "number")
		assert(customOdds >= 0)
		assert(customOdds <= 100)
	end

	-- No dialogs registered for this event, so just ignore it.
	if not modApiExt_internal.ruledDialogs[dialogEvent] then
		return false
	end

	if not GAME.uniqueRuledDialogs then
		GAME.uniqueRuledDialogs = {}
	end

	local pawns = nil
	if Board then
		pawns = extract_table(Board:GetPawns(TEAM_ANY))
	else
		pawns = {0, 1, 2} -- hardcoded ids for mech pawns
	end

	local candidates = {}

	for _, eventInfo in ipairs(modApiExt_internal.ruledDialogs[dialogEvent]) do
		-- Don't consider empty dialogs
		local execute = #eventInfo > 0

		local odds = customOdds or eventInfo.Odds or 100

		-- Check odds first, easier to compute

		-- If there's a voice popup being played already, then
		-- only push through popups which have 100% odds, which
		-- means they're probably important.
		if execute and Game:IsVoicePopup() and odds ~= 100 then
			execute = false
		end
		if execute and odds < random_int(100) then
			execute = false
		end

		-- If it's a unique dialog, check if we've played it already
		if
			execute            and
			eventInfo.Unique   and
			list_contains(GAME.uniqueRuledDialogs, approximateHash(eventInfo))
		then
			execute = false
		end

		-- Check if we match dialog cast rules
		local cast = protoCast
		if execute and eventInfo.CastRules then
			-- Execute rules in a pcall to handle errors gracefully
			local ok, v = pcall(function()
				return self:buildRuledDialogCast(pawns, eventInfo.CastRules, protoCast)
			end)

			if ok then
				cast = v
			else
				execute = false
				LOG("Error in " .. dialogEvent .. " dialog cast rule: " .. v)
			end
		end

		execute = execute and cast ~= nil

		if execute then
			table.insert(candidates, { eventInfo = eventInfo, cast = cast })
		end
	end

	if #candidates > 0 then
		-- Pick a candidate at random (among registered ruled dialogs)
		local dialog = random_element(candidates)

		local eventInfo = dialog.eventInfo
		local cast = dialog.cast

		if cast.main and cast.target and not cast.other then
			cast.other = Game:GetAnotherVoice(cast.main, cast.target)
		end

		if eventInfo.Unique then
			table.insert(GAME.uniqueRuledDialogs, approximateHash(eventInfo))
		end

		-- Pick a random dialog set inside the ruled dialog
		local selectedDialog = random_element(eventInfo)

		if #selectedDialog == 0 then
			self:addRuledDialogVoicePopup(selectedDialog, cast)
		else
			for _, segment in ipairs(selectedDialog) do
				self:addRuledDialogVoicePopup(segment, cast)
			end
		end

		if eventInfo.Suppress == nil then
			return true
		else
			return eventInfo.Suppress
		end
	end

	return false
end

function dialog:addRuledDialog(dialogEvent, ruledDialog)
	assert(type(dialogEvent) == "string")
	assert(type(ruledDialog) == "table")
	assert(#ruledDialog > 0, "Attempted to add a ruled dialog for '"..dialogEvent.."', but it has no dialogs!")

	if not modApiExt_internal.ruledDialogs[dialogEvent] then
		modApiExt_internal.ruledDialogs[dialogEvent] = {}
	end

	table.insert(modApiExt_internal.ruledDialogs[dialogEvent], ruledDialog)
end

---------------------------------------------------------------
-- Rules

function PersonalityRule(personality)
	return function(pawnId, cast)
		return Game:GetPawn(pawnId):GetPersonality() == personality
	end
end

function WeaponRule(weaponId)
	return function(pawnId, cast)
		return list_contains(dialog.pawn:getWeapons(pawnId), weaponId)
	end
end

function MechRule(mechType)
	return function(pawnId, cast)
		return Game:GetPawn(pawnId):GetType() == mechType
	end
end

function MechClassRule(mechClass)
	return function(pawnId, cast)
		return _G[Game:GetPawn(pawnId):GetType()].Class == mechClass
	end
end

function HealthLowerRule(hp)
	return function(pawnId, cast)
		return Game:GetPawn(pawnId):GetHealth() < hp
	end
end

function HealthGreaterRule(hp)
	return function(pawnId, cast)
		return Game:GetPawn(pawnId):GetHealth() > hp
	end
end

function NotRule(rule)
	return function(pawnId, cast)
		return not rule(pawnId, cast)
	end
end

function AndRule(rule1, rule2)
	return function(pawnId, cast)
		return rule1(pawnId, cast) and rule2(pawnId, cast)
	end
end

function OrRule(rule1, rule2)
	return function(pawnId, cast)
		return rule1(pawnId, cast) or rule2(pawnId, cast)
	end
end

return dialog
