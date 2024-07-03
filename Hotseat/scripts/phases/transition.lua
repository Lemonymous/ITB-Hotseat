
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local getModUtils = require(path .."libs/getModUtils")
local phases = require(path .."phases")
local menu = require(path .."libs/menu")
local suspendLoop = require(path .."libs/suspendLoop")
local UiTurnbar = require(path .."ui/turnbar")
local UiObscure = require(path .."ui/obscure")
local Ui2 = require(path .."ui/Ui2")
local uiTransition

local this = {}

local function destroyUi()
	if uiTransition then
		uiTransition:detach()
		uiTransition = nil
	end
end

local function createUi(team)
	destroyUi()
	
	assert(team == "Mech" or team == "Vek")
	local uiRoot = sdlext.getUiRoot()
	local text = {}
	
	if team == "Mech" then
		text.title = "Mech Player Turn"
		text.desc = "click to continue"
	else
		text.title = "Vek Player Turn"
		text.desc = "click to continue"
	end
	
	Game:TriggerSound("ui/battle/enemy_turn")
	
	uiTransition = Ui2()
		:width(1):height(1)
		:addTo(uiRoot)
	
	local uiTurnBar = UiTurnbar(text):addTo(uiTransition)
	local uiObscure = UiObscure({}, sdl.rgba(0,0,0,240), 750, 750):addTo(uiTransition)
	
	uiTransition.translucent = true
	uiTurnBar.translucent = true
	uiTurnBar.uiText.translucent = true
	
	function uiTurnBar:draw(screen)
		self.visible =
			menu.isClosed()            and
			not sdlext.isConsoleOpen() and
			not uiObscure.isDestroy
		
		UiTurnbar.draw(self, screen)
	end
	
	function uiTransition:destroy(fn)
		uiObscure:destroy(fn)
	end
	
	function uiTransition:mousedown(mx, my, button)
		if uiTurnBar.visible and button == 1 and not uiObscure.isDestroy then
			Game:TriggerSound("/ui/map/map_flyin")
			
			self:destroy(function()
				phases.setPhase()
			end)
			
			return true
		end
		
		return false
	end
end

local function startTransitVek()
	createUi("Vek")
	suspendLoop.start(function()
		if phases.isPhase("transitVek") then
			return true
		end
		
		phases.setPhase("vekTurn")
	end)
end

local function startTransitMech()
	createUi("Mech")
	suspendLoop.start(function()
		if phases.isPhase("transitMech") then
			return true
		end
		
		phases.setPhase("mechTurn")
	end)
end

phases.addTransitVekStartHook(startTransitVek)
phases.addTransitMechStartHook(startTransitMech)
phases.addTransitVekEndHook(destroyUi)
phases.addTransitMechEndHook(destroyUi)
sdlext.addGameExitedHook(destroyUi)

function this:load()
	local modUtils = getModUtils()
	
	local function restore()
		if phases.isPhase("transitVek") then
			modApi:runLater(startTransitVek)
		elseif phases.isPhase("transitMech") then
			modApi:runLater(startTransitMech)
		end
	end
	
	modUtils:addResetTurnHook(restore)
	modUtils:addGameLoadedHook(restore)
end

return this