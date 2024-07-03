
---------------------------------------------------------------------
-- Hotseat Phases
---------------------------------------------------------------------
-- a private library used internally by the Hotseat mod.
-- mods based on Hotseat can access phases via the global variable Hotseat.

--[[

global
	Hotseat

constants
	Hotseat.DEPLOY
	Hotseat.FIRE
	Hotseat.ENVIRONMENT
	Hotseat.RESOLVE_QUEUED
	Hotseat.AI
	Hotseat.SPAWN
	Hotseat.VEK_TURN
	Hotseat.MECH_TURN

functions
	Hotseat.logPhases()
	- writes out phase changes to console.
	
	Hotseat.getPhase()
	Hotseat.isPhase(phase)
	
	- where 'phase' is any of the constants above.
	
		---
	
	Hotseat.add .. StartHook(fn)
	Hotseat.add .. EndHook(fn)
	
	- where .. is
	
	Deploy,
	Fire, Environment,
	ResolveQueued, Ai,
	Spawn, VekTurn, MechTurn
	
		---
	
	(omitted functions are private and should not be used outside of this mod)

examples
	if Hotseat.isPhase(Hotseat.VEK_TURN) then
		LOG("Current phase is vek turn")
	end
	
	local phase = Hotseat.getPhase()
	LOG("Current phase is ".. phase)
	
	Hotseat.addVekTurnStartHook(function()
		LOG("vek turn phase started")
	end)
	
	Hotseat.addVekTurnEndHook(function()
		LOG("vek turn phase ended")
	end)
]]

local path = modApi:getCurrentMod().scriptPath
local hooks = require(path .."libs/hooks")
local this = {}
local index = 0

-- default order --
--[[---------------
	mech deploy (once)
	fire
	environment
	resolve enemy queued attacks
	resolve neutral queued attacks
-- next turn (enemy) --
	resolve queued spawns
	enemy move + attack
	neutral move + attack
	spawn
-- next turn (player) --
	player turn
-- end turn button --
]]

-- hotseat order --
--[[---------------
	deploy
	fire
	environment
	resolveQueued
-- next turn (enemy) --
	ai
	spawn
-- next turn (player) --
	vek turn
-- end turn (enemy) --
	mech turn
-- end turn (player) --
]]

local function firstCase(s)
	return s:gsub("^.", string.upper)
end

local function snakeCase(s)
	return s:gsub("%u", "_%0"):upper()
end

local names = {
	"deploy",			-- mech deployment at the start of mission.
	"fire",				-- fire damage.
	"environment",		-- environment effects.
	"resolveQueued",	-- resolve queued attacks.
	"ai",				-- resolve queued spawns and ai activates enemy/neutral units.
	"transitVek",		-- transition screen to vek player's turn.
	"vekTurn",			-- custom phase. first half of the player's turn.
	"spawn",			-- custom phase. plan spawns.
	"spawning",			-- custom phase. add spawns to board.
	"transitMech",		-- transition screen to mech player's turn.
	"mechTurn"			-- custom phase. second half of the player's turn.
	
	-- rewrite(?) to transitVek > vekTurn > spawn > transitMech > mechTurn
}

local function logPhase(name)
	LOG(name)
end

function this.logPhases()
	if this.logging then return end
	this.logging = true
	LOG("Hotseat logging enabled")
	
	for _, name in ipairs(names) do
		local Name = firstCase(name)
		local startHook = "add".. Name .."StartHook"
		local endHook = "add".. Name .."EndHook"
		
		this[startHook](function() LOG(name .."Start") end)
		this[endHook](function() LOG(name .."End") end)
	end
end

function this.getPhase()
	assert(GAME)
	GAME.lmn_hotseat = GAME.lmn_hotseat or {}
	return GAME.lmn_hotseat.phase
end

function this.isPhase(name)
	assert(GAME)
	GAME.lmn_hotseat = GAME.lmn_hotseat or {}
	return GAME.lmn_hotseat.phase == name
end

function this.setPhase(name, ...)
	assert(GAME)
	
	local m = GetCurrentMission()
	if m and m == Mission_Test then return end
	
	GAME.lmn_hotseat = GAME.lmn_hotseat or {}
	local prev = GAME.lmn_hotseat.phase
	GAME.lmn_hotseat.phase = name
	
	if prev ~= name then
		if prev then
			hooks["fire".. firstCase(prev) .."EndHooks"](hooks)
		end
		
		if name then
			hooks["fire".. firstCase(name) .."StartHooks"](hooks, ...)
		end
	end
end

for _, name in ipairs(names) do
	this[snakeCase(name)] = name
	hooks:new(name .."Start")
	hooks:new(name .."End")
	
	local Name = firstCase(name)
	local startHook = "add".. Name .."StartHook"
	local endHook = "add".. Name .."EndHook"
	
	this[startHook] = function(fn)
		hooks[startHook](hooks, fn)
	end
	
	this[endHook] = function(fn)
		hooks[endHook](hooks, fn)
	end
end

modApi.events.onMissionStart:subscribe(function()
	this.setPhase("deploy")
end)

modApi.events.onPreEnvironment:subscribe(function()
	if not this.isPhase("mechMove") then
		-- this triggers after fire phase has finished,
		-- but is included to ensure the phase fires every turn.
		this.setPhase("fire")
	end
	this.setPhase("environment")
end)

modApi.events.onPostEnvironment:subscribe(function()
	this.setPhase("resolveQueued")
end)

modApi.events.onNextTurn:subscribe(function()
	if Game:GetTeamTurn() == TEAM_ENEMY then
		this.setPhase("ai")
	end
end)

-- transitVek is handled in spawn.lua and transition.lua
-- spawn is handled in spawn.lua
-- vekTurn is handled in playerTurn.lua
-- transitMech is handled in playerTurn.lua and transition.lua
-- mechTurn is handled in playerTurn.lua

modApi.events.onMissionEnd:subscribe(function()
	this.setPhase()
end)

Hotseat = {}
setmetatable(Hotseat, this)
this.__index = this

return this