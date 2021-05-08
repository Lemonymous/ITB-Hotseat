
local path = mod_loader.mods[modApi.currentMod].scriptPath
local getModUtils = require(path .."libs/getModUtils")
local tileToScreen = require(path .."libs/tileToScreen")
local selected = require(path .."libs/selected")
local moveUtils = require(path .."libs/moveUtils")
local isNeutral = require(path .."libs/isNeutral")
local isPowered = require(path .."libs/isPowered")
local hotkey = require(path .."libs/hotkey")
local menu = require(path .."libs/menu")
local deselect = require(path .."libs/deselect")
local pawnTeam = require(path .."libs/pawnTeam")
local utils = require(path .."libs/utils")
local psion = require(path .."libs/psion")
local phases = require(path .."phases")
local Ui2 = require(path .."ui/Ui2")
local UiEndTurn = require(path .."ui/endturn")
local UiEndHidden = require(path .."ui/endturn_hidden")
local UiTurnbar = require(path .."ui/turnbar")
local UiAttackOrderButton = require(path .."ui/attackorderButton")
local UiAttackOrder = require(path .."ui/attackorder")
local UiNumber = require(path .."ui/number")
local UiHealth = require(path .."ui/health")
local UiIcon = require(path .."ui/icon")
local uiEndTurn, uiEndHidden, uiEndMechTurn, uiOverlay, uiOrder, uiButton
local a = ANIMS
local this = {}

icons = {
	fire = "img/combat/icons/icon_fire_glow.png",
	electric = "img/combat/icons/icon_electric_smoke_glow.png",
	blood = "img/combat/icons/icon_regen_glow.png",
	tyrant = "img/combat/icons/icon_tentacle_glow.png",
	emerge = "img/combat/icons/icon_emerge_glow.png",
}

buffs = {
	[LEADER_HEALTH] = "img/combat/icons/icon_hp_glow.png",
	[LEADER_ARMOR] = "img/combat/icons/icon_armor_leader_glow.png",
	[LEADER_REGEN] = "img/combat/icons/icon_regen_glow.png",
	[LEADER_EXPLODE] = "img/combat/icons/icon_explode_glow.png",
	[LEADER_TENTACLE] = "img/combat/icons/icon_tentacle_glow.png",
	[LEADER_BOSS] = "img/combat/icons/icon_psionboss_glow.png",
}

Global_Texts.Order_Actions = "Vek Actions"
Global_Texts.Order_Emerge = "Vek Emerge"
Global_Texts.Alert_Attacking = "Vek"

-- returns whether a table is empty or not.
local function list_isEmpty(list)
	return not next(list)
end

local function endMechTurn(self)
	if
		not phases.isPhase("mechTurn") or
		menu.isOpen()
	then
		return false
	end
	
	phases.setPhase("fire")
end

local function flashPlayerPawns(r, g ,b)
	local pawns = extract_table(Board:GetPawns(TEAM_PLAYER))
	for _, id in ipairs(pawns) do
		local pawn = Board:GetPawn(id)
		
		if pawn:IsActive()and not isNeutral(id) then
			Board:Ping(pawn:GetSpace(), GL_Color(r, g, b))
		end
	end
end

local function destroyMechUi()
	hotkey:remKeyDownHook(hotkey.END_TURN, endMechTurn)
	if uiEndMechTurn then
		uiEndMechTurn:detach()
		uiEndMechTurn = nil
	end
end

local function createMechUi()
	destroyMechUi()
	
	local uiRoot = sdlext.getUiRoot()
	uiEndMechTurn = UiEndHidden():addTo(uiRoot)
	uiEndMechTurn.visible = true
	
	hotkey:addKeyDownHook(hotkey.END_TURN, endMechTurn, uiEndMechTurn)
	
	function uiEndMechTurn:draw(screen)
		Ui2.draw(self, screen)
	end
	
	function uiEndMechTurn:mousedown(x, y, button)
		if button == 1 then
			endMechTurn(self)
		end
		
		return false
	end
	
	function uiEndMechTurn:mouseup(x, y, button)
		return false
	end
end

local function hideVekOrderOverlay(force)
	local enabled = uiButton and (uiButton.hovered or hotkey.isKeyDown(hotkey.ATTACK_ORDER_OVERLAY))
	
	if not enabled or force then
		if uiButton then
			uiButton.decorations[1].surface_on = uiButton.decorations[1].surface_off
		end
		if uiOverlay then
			uiOverlay:detach()
			uiOverlay = nil
		end
	end
end

local function showVekOrderOverlay()
	if uiOverlay then return end
	
	local uiRoot = sdlext.getUiRoot()
	uiOverlay = Ui2()
		:width(1):height(1)
		:addTo(uiRoot)
	uiOverlay.translucent = true
	uiUnits = Ui2():addTo(uiOverlay)
	uiOrder = UiAttackOrder():addTo(uiOverlay)
	
	Game:TriggerSound("ui/battle/turnorder_mouseover")
	
	local m = GetCurrentMission()
	local isFire, isLightning
	local texts = {}
	local count, count_vek, count_npc, count_emerge = 1, 0, 0, 0
	local leaderBuff = psion.getLast()
	
	function uiOverlay:draw(screen)
		self.visible = not sdlext.isConsoleOpen()
		
		Ui2.draw(self, screen)
	end
	
	function uiUnits:draw(screen)
		self.visible = menu.isClosed()
		
		Ui2.draw(self, screen)
	end
	
	-- button --
	------------
	if uiButton then
		uiButton.decorations[1].surface_on = uiButton.decorations[1].surface_hl
	end
	
	-- effects --
	-------------
	if IsPassiveSkill("Electric_Smoke") then
		isLightning = 0
	end
	
	local pawns = extract_table(Board:GetPawns(TEAM_ANY))
	for _, id in ipairs(pawns) do
		local pawn = Board:GetPawn(id)
		if pawn:IsFire() then
			isFire = true
			break
		end
	end
	
	texts[#texts+1] = {count = 1, text = "Mech Actions"}
	texts[#texts+1] = {count = isFire and 1 or 0, text = "Fire Damage", icon = {path = icons.fire, scale = 2}}
	if isFire then
		count = count + 1
	end
	if isLightning then
		texts[#texts+1] = {count = isLightning, text = "Storm Smoke", icon = {path = icons.electric, scale = 2}}
		count = count + isLightning
	end
	if psion.isTyrant() then
		texts[#texts+1] = {count = 1, text = "Psion Tentacle", icon = {path = icons.tyrant, scale = 2}}
		count = count + 1
	end
	if psion.isBlood() then
		texts[#texts+1] = {count = 1, text = "Psion Regenerate", icon = {path = icons.blood, scale = 2}}
		count = count + 1
	end
	if m and not list_isEmpty(m.LiveEnvironment) then
		texts[#texts+1] = {count = 1, text = "Environment", icon = {path = "img/".. m.LiveEnvironment.CombatIcon, color = sdl.rgb(255,255,100)}}
		count = count + 1
	end
	
	-- units --
	-----------
	local pawns = extract_table(Board:GetPawns(TEAM_PLAYER))
	for _, id in ipairs(pawns) do
		local pawn = Board:GetPawn(id)
		if not isNeutral(id) and isPowered(id) then
			count_vek = count_vek + 1
			
			local loc = tileToScreen(pawn:GetSpace())
			local pawnTable = _G[pawn:GetType()]
			UiNumber(loc, count + count_vek, 2, sdl.rgb(255,50,50)):addTo(uiUnits)
			
			if leaderBuff then
				if not pawnTable.Leader or pawnTable.Leader == LEADER_NONE then
					loc.y = loc.y + 30
					UiIcon(loc, buffs[leaderBuff], 2):addTo(uiUnits)
				end
			end
		end
		
		if isLightning and Board:IsSmoke(pawn:GetSpace()) then
			isLightning = 1
		end
	end
	
	local pawns = extract_table(Board:GetPawns(TEAM_ANY))
	for _, id in ipairs(pawns) do
		local pawn = Board:GetPawn(id)
		local hp_max = pawn:GetMaxHealth()
		local hp = pawn:GetHealth()
		local loc = tileToScreen(pawn:GetSpace())
		
		if isNeutral(id) and isPowered(id) then
			count_npc = count_npc + 1
			
			UiNumber(loc, count + count_vek + count_npc, 2, sdl.rgb(255,50,50)):addTo(uiUnits)
		end
		
		UiHealth(loc, hp_max, hp):addTo(uiUnits)
	end
	
	texts[#texts+1] = {count = count_vek, text = "Vek Actions"}
	texts[#texts+1] = {count = count_npc, text = "NPC Actions"}
	
	-- emerge --
	------------
	local board = utils.getBoard()
	for _, p in ipairs(board) do
		if Board:IsSpawning(p) then
			count_emerge = 1
			break
		end
	end
	
	texts[#texts+1] = {count = count_emerge, text = "Vek Emerge", icon = {path = icons.emerge, scale = 2}}
	
	function uiOrder:getTexts()
		return texts
	end
end

local function endVekTurn(self)
	if not phases.isPhase("vekTurn") then return false end
	
	local selected = selected:Get()
	if selected and selected:IsActive() and selected:GetTeam() == TEAM_PLAYER then
		deselect:pawn(selected)
	end
	
	if not self.inactive then
		self.disabled = true
		self.destroy = true
		
		Game:TriggerSound("ui/battle/end_turn")
		
		return true
	end
	
	return menu:isClosed()
end

local function destroyVekUi()
	hotkey:unsuppress(hotkey.END_TURN)
	hotkey:remKeyDownHook(hotkey.END_TURN, endVekTurn)
	hotkey:unsuppress(hotkey.ATTACK_ORDER_OVERLAY)
	hotkey:remKeyDownHook(hotkey.ATTACK_ORDER_OVERLAY, showVekOrderOverlay)
	hotkey:remKeyUpHook(hotkey.ATTACK_ORDER_OVERLAY, hideVekOrderOverlay)
	hideVekOrderOverlay(true)
	
	if uiEndTurn then
		uiEndTurn:detach()
		uiEndTurn = nil
	end
	if uiEndHidden then
		uiEndHidden:detach()
		uiEndHidden = nil
	end
	if uiButton then
		uiButton:detach()
		uiButton = nil
	end
end

local function createVekUi()
	destroyVekUi()
	
	local uiRoot = sdlext.getUiRoot()
	uiEndTurn = UiEndTurn():addTo(uiRoot)
	uiEndHidden = UiEndHidden():addTo(uiRoot)
	uiButton = UiAttackOrderButton():addTo(uiRoot)
	
	hotkey:suppress(hotkey.END_TURN)
	hotkey:addKeyDownHook(hotkey.END_TURN, endVekTurn, uiEndTurn)
	hotkey:suppress(hotkey.ATTACK_ORDER_OVERLAY)
	hotkey:addKeyDownHook(hotkey.ATTACK_ORDER_OVERLAY, showVekOrderOverlay)
	hotkey:addKeyUpHook(hotkey.ATTACK_ORDER_OVERLAY, hideVekOrderOverlay)
	
	function uiEndTurn:mousedown(x, y, button)
		if button == 1 then
			return endVekTurn(self)
		end
		
		return false
	end
	
	function uiEndTurn:draw(screen)
		self.visible = not sdlext.isConsoleOpen()
		self.inactive = self.destroy or menu.isOpen()
		
		UiEndTurn.draw(self, screen)
		
		if self.destroy and not Board:IsBusy() then
			for _, id in ipairs(extract_table(Board:GetPawns(TEAM_PLAYER))) do
				Board:GetPawn(id):SetActive(false)
			end
			
			destroyVekUi()
			phases.setPhase("spawn")
		end
	end
	
	function uiEndTurn:mousemove(...)
		UiEndTurn.mousemove(self, ...)
		
		return false
	end
	
	function uiButton:onUpdate(screen)
		if self.hovered then
			showVekOrderOverlay()
		else
			hideVekOrderOverlay()
		end
	end
end

phases.addVekTurnStartHook(function()
	pawnTeam:swapAll()
	createVekUi()
	flashPlayerPawns(255, 50, 100)
end)

phases.addMechTurnStartHook(function()
	pawnTeam:resetAll()
	createMechUi()
	flashPlayerPawns(50, 255, 50)
end)

sdlext.addGameExitedHook(function()
	destroyVekUi()
	destroyMechUi()
end)

function this:load()
	local modUtils = getModUtils()
	
	modApi:addMissionStartHook(function()
		destroyVekUi()
		destroyMechUi()
	end)
	
	modApi:addMissionNextPhaseCreatedHook(function()
		destroyVekUi()
		destroyMechUi()
	end)
	
	modApi:addMissionEndHook(function()
		pawnTeam.resetAll()
		destroyVekUi()
		destroyMechUi()
	end)
	
	modApi:addMissionUpdateHook(function()
		if Game:GetTeamTurn() == TEAM_ENEMY then return end
		if not uiEndTurn then return end
		GAME.lmn_hotseat = GAME.lmn_hotseat or {}
		
		local flash = true
		for _, id in ipairs(extract_table(Board:GetPawns(TEAM_PLAYER))) do
			local pawn = Board:GetPawn(id)
			local active = pawn:IsActive() and #_G[pawn:GetType()].SkillList > 0
			active = active or pawn:IsActive() and not moveUtils:HasMoved(pawn)
			
			if active then
				flash = false
				break
			end
		end
		
		GAME.lmn_hotseat.endturn_flash = flash
		
		if GAME.lmn_hotseat.endturn_flash then
			if uiEndTurn.animations.flash:isStopped() then
				uiEndTurn.animations.flash:start()
			end
		else
			if uiEndTurn.animations.flash:isStarted() then
				uiEndTurn.animations.flash:stop()
			end
		end
	end)
	
	local function reset()
		destroyVekUi()
		destroyMechUi()
		local phase = phases.getPhase()
		if phase == "vekTurn" then
			modApi:runLater(createVekUi)
			modApi:conditionalHook(
				function()
					return not Game or not GAME or (Board and not Board:IsBusy())
				end,
				function()
					if not Game or not GAME or not Board then return end
					
					flashPlayerPawns(255, 0, 50)
				end
			)
		elseif phase == "mechTurn" then
			modApi:runLater(createMechUi)
			modApi:conditionalHook(
				function()
					return not Game or not GAME or (Board and not Board:IsBusy())
				end,
				function()
					if not Game or not GAME or not Board then return end
					
					flashPlayerPawns(50, 255, 50)
				end
			)
		end
	end
	
	modUtils:addResetTurnHook(reset)
	modUtils:addGameLoadedHook(reset)
	
	-- hard coded exceptions. Not the greatest solution.
	local exceptions = {
		"WebbEgg1"
	}
	
	modUtils:addPawnTrackedHook(function(mission, pawn)
		if phases.isPhase("vekTurn") then
			pawnTeam:save(mission, pawn:GetId())
			if not list_contains(exceptions, pawn:GetType()) then
				pawnTeam:swap(pawn:GetId(), true)
			end
		end
	end)
end

return this