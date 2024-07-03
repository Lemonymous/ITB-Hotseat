
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local getModUtils = require(path .."libs/getModUtils")
local deselect = require(path .."libs/deselect")
local isNeutral = require(path .."libs/isNeutral")
local menu = require(path .."libs/menu")
local hooks = require(path .."libs/hooks")
local UiTimer = require(path .."ui/timer")
local Ui2 = require(path .."ui/Ui2")
local phases = require(path .."phases")
local this = {}
local mechTime, vekTime
local uiHolder, uiTimer

sdlext.addUiRootCreatedHook(function(screen, uiRoot)
	uiHolder = Ui2():width(1):height(1):addTo(uiRoot)
	uiHolder.translucent = true
end)

hooks:new("TimerEnded")

local function endTurn()
	for _, id in ipairs(extract_table(Board:GetPawns(TEAM_PLAYER))) do
		local pawn = Board:GetPawn(id)
		if not isNeutral(id) then
			local selected = Board:GetSelectedPawn()
			if selected and selected:IsActive() and selected:GetTeam() == TEAM_PLAYER then
				deselect:pawn(selected)
			end
			
			pawn:SetActive(false)
			pawn:ClearUndoMove()
		end
	end
end

hooks:addTimerEndedHook(function()
	endTurn()
end)

local function destroyUi()
	if uiTimer then
		uiTimer:detach()
		uiTimer = nil
	end
end

local function createUi(time)
	destroyUi()
	
	uiTimer = UiTimer(time):addTo(uiHolder)
end

phases.addVekTurnStartHook(function()
	if vekTime then
		createUi(vekTime * Board:GetPawnCount(TEAM_PLAYER))
	elseif mechTime then
		createUi(mechTime)
	end
end)

phases.addMechTurnStartHook(function()
	if mechTime then
		createUi(mechTime)
	end
end)

phases.addVekTurnEndHook(destroyUi)
phases.addMechTurnEndHook(destroyUi)
sdlext.addGameExitedHook(destroyUi)

phases.addVekTurnStartHook(function()
	local m = GetCurrentMission()
	
	m.lmn_hotseat = m.lmn_hotseat or {}
	local timer = m.lmn_hotseat.timer
	
	if timer and timer == 0 then
		modApi:runLater(endTurn)
	end
end)

local function restore()
	destroyUi()
	
	local phase = phases.getPhase()
	if phase == "vekTurn" or phase == "mechTurn" then
		modApi:runLater(function(m)
			m.lmn_hotseat = m.lmn_hotseat or {}
			
			-- only restore timer if timer is on.
			if m.lmn_hotseat.timer then
				createUi(m.lmn_hotseat.timer / 60)
			end
		end)
	end
end

function this:load()
	local modUtils = getModUtils()
	
	mechTime = options["option_hotseat_timeattack_mech"].value
	vekTime = options["option_hotseat_timeattack_vek"].value
	mechTime = type(mechTime) == 'number' and mechTime or nil
	vekTime = type(vekTime) == 'number' and vekTime or nil
local options = modApi:getModOptions(mod.id)
	
	modUtils:addResetTurnHook(restore)
	modUtils:addGameLoadedHook(restore)
	
	modApi:addMissionStartHook(destroyUi)
	modApi:addMissionNextPhaseCreatedHook(destroyUi)
	modApi:addMissionEndHook(destroyUi)
	modApi:addMissionUpdateHook(function(m)
		if not uiTimer or menu.isOpen() then return end
		if Board:IsBusy() then return end
		
		m.lmn_hotseat = m.lmn_hotseat or {}
		m.lmn_hotseat.timer = m.lmn_hotseat.timer or 0
		m.lmn_hotseat.timer = math.max(0, m.lmn_hotseat.timer - 1)
		
		if not uiTimer.ended and m.lmn_hotseat.timer == 0 then
			uiTimer.ended = true
			hooks:fireTimerEndedHooks()
		end
	end)
end

return this