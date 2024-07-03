
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local utils = require(path .."libs/utils")
local highlighted = require(path .."libs/highlighted")
local tileToScreen = require(path .."libs/tileToScreen")
local suspendLoop = require(path .."libs/suspendLoop")
local scheduledMissionHook = require(path .."libs/scheduledMissionHook")
local getModUtils = require(path .."libs/getModUtils")
local finalize = require(path .."libs/finalize")
local menu = require(path .."libs/menu")
local Ui2 = require(path .."ui/Ui2")
local UiPawn = require(path .."ui/pawn_deploy")
local UiConfirm = require(path .."ui/confirm")
local UiTurnbar = require(path .."ui/turnbar")
local UiDeployBox = require(path .."ui/deploybox")
local UiDeployRemaining = require(path .."ui/deployremaining")
local phases = require(path .."phases")
local this = {}
local hidden = {
	"action_end",
	"undo_loc",
	"mech_box",
	"environment_info",
	"pawn_list",
	"options_battle",
	"combat_morale_bar"
}
local uiMain, uiArea, uiCursor, uiConfirm, uiDeployed, uiBox
local a = ANIMS
local colors = {
	outline_valid = sdl.rgb(255, 255, 0),
	outline_invalid = sdl.rgb(255, 170, 140),
	zone = GL_Color(255, 255, 150),
	deploy = GL_Color(255, 255, 0),
	invalid = GL_Color(255, 150, 150),
}
modApi:appendAsset("img/combat/icons/warn_enemy_activity.png", mod.resourcePath .."img/empty.png")

-- returns whether a table is empty or not.
local function list_isEmpty(list)
	return not next(list)
end

local function isValidTile(p)
	return
		not Board:IsBlocked(p, PATH_GROUND)		and
		not Board:IsEnvironmentDanger(p)		and
		not Board:IsDangerousItem(p)			and
		not Board:IsDangerous(p)				and
		not Board:IsSpawning(p)					and
		not Board:IsPod(p)						and
		not Board:IsTerrain(p, TERRAIN_FOREST)	and
		not Board:IsTerrain(p, TERRAIN_ICE)		and
		Board:GetCustomTile(p) == ""
end

local function UnspawnPawn()
	local m = GetCurrentMission()
	if not m then return end
	
	local spawns = GAME.lmn_hotseat.spawns
	local spawn = spawns[#spawns]
	
	-- match pawn names ending in 1 or 2, or 'Boss'
	local name = spawn:match("(.+)[12]$") or spawn:match("(.+)Boss$")
	if name then
		m:GetSpawner():ModifyCount(name, -1)
	end
	
	table.remove(spawns, #spawns)
	GAME.lmn_hotseat.spawnCount = #spawns
end

local function updateDeployZone()
	if not GAME.lmn_hotseat.deploy_zone_update then return end
	
	local scouted = {}
	local explored = {}
	local ret = {}
	local zone = Board:GetZone("enemy")
	
	local function scout(p)
		for i = DIR_START, DIR_END do
			local curr = p + DIR_VECTORS[i]
			if Board:IsValid(curr) then
				local pid = p2idx(curr)
				if not scouted[pid] and not explored[pid] then
					scouted[pid] = {valid = isValidTile(curr)}
				end
			end
		end
	end
	
	for i = 1, zone:size() do
		local p = zone:index(i)
		local pid = p2idx(p)
		explored[pid] = {valid = isValidTile(p)}
		
		-- add valid tiles to final zone.
		if explored[pid].valid then
			ret[#ret+1] = p
		end
		
		-- scout tiles around to see if we can expand.
		scout(p)
	end
	
	-- while deployment zone is too small to room all spawns, increase it in every direction.
	while #ret < (GAME.lmn_hotseat.spawnCount or 0) and not list_isEmpty(scouted) do
		local unexplored = scouted
		scouted = {}
		while not list_isEmpty(unexplored) do
			local pid, v = next(unexplored)	
			unexplored[pid] = nil
			
			if not explored[pid] then
				local p = idx2p(pid)
				-- expand into scouted tile.
				explored[pid] = v
				
				-- add valid tiles to final zone.
				if v.valid then
					ret[#ret+1] = p
				end
				-- scout ahead further.
				scout(p)
			end
		end
	end
	
	-- if we run out of board, and still cannot spawn everything,
	-- remove pawns from spawn queue.
	while #ret < (GAME.lmn_hotseat.spawnCount or 0) do
		UnspawnPawn()
	end
	
	-- save deployment zone.
	GAME.lmn_hotseat.deploy_zone = ret
	GAME.lmn_hotseat.deploy_zone_update = nil
end

local function getDeployZone()
	local m = GetCurrentMission()
	if not m then return end
	
	return GAME.lmn_hotseat.deploy_zone or {}
end

local function Deploy(loc)
	if #GAME.lmn_hotseat.spawns <= 0 then return end
	
	local ui = UiPawn(GAME.lmn_hotseat.spawns[1])
		:addTo(uiArea)
	ui.tile = loc
	ui.outline = colors.outline_valid
	ui.translucent = true
	
	table.sort(uiArea.children, function(a,b)
		if a.tile and not b.tile then
			return true
		elseif not a.tile and b.tile then
			return false
		elseif not a.tile and not b.tile then
			return true
		end
		
		return p2idx(a.tile) > p2idx(b.tile)
	end)
	
	function ui:getTileCode()
		local loc = highlighted:Get()
		if loc == self.tile and #GAME.lmn_hotseat.spawns > 0 then return nil end
		
		return self.DEPLOY_VALID
	end
	
	function ui:draw(screen)
		self.visible = menu.isClosed() and not sdlext.isConsoleOpen()
		
		UiPawn.draw(self, screen)
	end
	
	-- update data.
	local pid = p2idx(loc)
	local data = GAME.lmn_hotseat
	uiDeployed[pid] = ui
	data.deployed[pid] = data.spawns[1]
	table.remove(data.spawns, 1)
end

local function Undeploy(loc, i)
	local pid = p2idx(loc)
	local data = GAME.lmn_hotseat
	if not data.deployed[pid] then return end
	
	table.insert(data.spawns, i or 1, data.deployed[pid])
	uiDeployed[pid]:detach()
	data.deployed[pid] = nil
end

local function Swap(loc)
	Undeploy(loc, 2)
	Deploy(loc)
end

local function destroyUi()
	if uiMain then
		uiMain:detach()
		uiMain = nil
	end
	
	-- reset hidden away Locations
	for _, v in ipairs(hidden) do
		if hidden[v] then
			Location[v] = hidden[v]
		end
	end
end

local function createUi()
	local uiRoot = sdlext.getUiRoot()
	
	uiMain = Ui2():width(1):height(1)
	uiArea = Ui2()
	uiConfirm = UiConfirm()
	uiCursor = UiPawn()
	uiDeployBox = UiDeployBox()
	uiRemaining = UiDeployRemaining()
	uiDeployed = {}
	
	uiMain.translucent = true
	uiDeployBox.translucent = true
	uiRemaining.translucent = true
	uiArea.translucent = true
	
	uiMain:addTo(uiRoot)
	uiDeployBox:addTo(uiMain)
	uiRemaining:addTo(uiMain)
	uiConfirm:addTo(uiMain)
	uiCursor:addTo(uiMain)
	uiArea:addTo(uiMain)
	
	local notification
	
	-- this function handles deployment input.
	function uiMain:mousedown(x, y, button)
		local m = GetCurrentMission()
		if not m then return false end
		if not phases.isPhase("spawn") or menu.isOpen() then return false end
		
		local zone = getDeployZone()
		local loc = highlighted:Get()
		local data = GAME.lmn_hotseat
		
		if button == 1 and loc and list_contains(zone, loc) then
			if #data.spawns > 0 then
				Game:TriggerSound("ui/battle/preplan_place_mech")
				if data.deployed[p2idx(loc)] then
					Swap(loc)
				else
					Deploy(loc)
				end
			elseif data.deployed[p2idx(loc)] then
				Undeploy(loc)
			end
			
			if #data.spawns == 0 and not notification then
				notification = true
				
				Game:TriggerSound("ui/battle/end_turn_notification")
			end
			
			return true
		end
		
		return Ui2.mousedown(self, x, y, button)
	end
	
	function uiCursor:getType()
		return GAME.lmn_hotseat.spawns[1]
	end
	
	function uiCursor:getTile()
		return highlighted:Get()
	end
	
	function uiCursor:getOutline()
		local zone = getDeployZone()
		return list_contains(zone, highlighted:Get()) and colors.outline_valid or colors.outline_invalid
	end
	
	function uiCursor:getTileCode()
		local loc = highlighted:Get()
		if loc and GAME.lmn_hotseat.deployed[p2idx(loc)] then return self.DEPLOY_SWAP end
		
		local zone = getDeployZone()
		if list_contains(zone, loc) then return self.DEPLOY_VALID end
		
		return self.DEPLOY_INVALID
	end
	
	function uiCursor:draw(screen)
		self.visible = menu.isClosed() and not sdlext.isConsoleOpen()
		
		UiPawn.draw(self, screen)
	end
	
	function uiConfirm:draw(screen)
		self.visible = #GAME.lmn_hotseat.spawns == 0 and not sdlext.isConsoleOpen()
		
		UiConfirm.draw(self, screen)
	end
	
	function uiConfirm:mousedown(x, y, button)
		if button == 1 then
			if menu.isClosed() then
				Game:TriggerSound("ui/battle/end_turn")
				phases.setPhase("spawning")
				
				modApi:conditionalHook(
					function()
						return not Board or not Board:IsBusy()
					end,
					function()
						if not Board then
							return
						end
						phases.setPhase("transitMech")
					end
				)
			end
			
			return menu:isClosed()
		end
		
		return false
	end
	
	function uiDeployBox:getType()
		return #GAME.lmn_hotseat.spawns > 0 and GAME.lmn_hotseat.spawns[1] or nil
	end
	
	function uiRemaining:getTypes()
		local types = {}
		for i = 2, #GAME.lmn_hotseat.spawns do
			types[#types+1] = GAME.lmn_hotseat.spawns[i]
		end
		return types
	end
	
	-- hide away Locations
	for _, v in ipairs(hidden) do
		hidden[v] = Location[v]
		Location[v] = Point(INT_MAX, INT_MAX)
	end
end

finalize:addFunc(function()
	for _, m in pairs(_G) do
		if type(m) == 'table' and type(m.UpdateSpawning) == 'function' then
			local meta = getmetatable(m)
			if not meta or meta.UpdateSpawning ~= m.UpdateSpawning then
				m.RealUpdateSpawning = m.UpdateSpawning
				m.UpdateSpawning = function(self)
					self.lmn_hotseat = self.lmn_hotseat or {}
					self.lmn_hotseat.spawnCount = self:GetSpawnCount(true)
					
					-- let the game have control for one frame in order to save current state.
					modApi:runLater(function()
						phases.setPhase("transitVek")
					end)
				end
			end
		end
	end
end)

-- we spawn units one turn later than vanilla.
local old = Mission.IsFinalTurn
function Mission:IsFinalTurn()
	if phases.isPhase("spawn") then
		return Game:GetTurnCount() == self.TurnLimit
	end
	
	return old(self)
end

-- Vek units will not be enemies in our custom spawn phase.
-- store spawnCount from vanilla spawn phase.
local old = Mission.GetSpawnCount
function Mission:GetSpawnCount(hotseatCall)
	if hotseatCall then
		return old(self)
	else
		self.lmn_hotseat = self.lmn_hotseat or {}
		return self.lmn_hotseat.spawnCount
	end
end

local old = Mission.SpawnPawns
function Mission:SpawnPawns(count, ...)
	if self ~= Mission_Test and self.Initialized then
		
		local spawns = {}
		for i = 1, count or -1 do
			local pawn = self:NextPawn()
			spawns[#spawns+1] = pawn:GetType()
		end
		
		GAME.lmn_hotseat = GAME.lmn_hotseat or {}
		GAME.lmn_hotseat.spawnCount = count
		GAME.lmn_hotseat.spawns = spawns
		
		return
	end
	
	old(self, count, ...)
end

local function startSpawn()
	createUi()
	suspendLoop.start(function()
		if phases.isPhase("spawn") then
			local loc = highlighted:Get()
			local zone = getDeployZone()
			
			for _, p in ipairs(zone) do
				if p ~= loc then
					Board:MarkSpaceColor(p, colors.zone)
				end
			end
			
			if loc then
				if list_contains(zone, loc) then
					-- uiCursor in deployment zone.
					Board:MarkSpaceColor(loc, colors.deploy)
				else
					-- uiCursor outside of deployment zone.
					Board:MarkSpaceColor(loc, colors.invalid)
				end
			end
			
			return true
		end
	end)
end

phases.addSpawnStartHook(function()
	local m = GetCurrentMission()
	m:RealUpdateSpawning()
	
	GAME.lmn_hotseat = GAME.lmn_hotseat or {}
	local data = GAME.lmn_hotseat
	data.spawnCount = data.spawnCount or 0
	
	if data.spawnCount > 0 then
		data.spawns = data.spawns or {}
		data.deploy_zone = {}
		data.deploy_zone_update = true
		data.deployed = {}
		
		startSpawn()
	else
		modApi:runLater(function()
			phases.setPhase("transitMech")
		end)
	end
end)

phases.addSpawningStartHook(function()
	-- add planned spawn points to the board.
	for pid, spawn in pairs(GAME.lmn_hotseat.deployed) do
		Board:SpawnPawn(spawn, idx2p(pid))
	end
	
	destroyUi()
end)

sdlext.addGameExitedHook(destroyUi)

function this:load()
	local modUtils = getModUtils()
	modApi:addMissionStartHook(destroyUi)
	modApi:addMissionNextPhaseCreatedHook(destroyUi)
	modApi:addMissionEndHook(destroyUi)
	modApi:addMissionUpdateHook(function()
		if phases.isPhase("spawn") then
			updateDeployZone()
		end
	end)
	
	local function reset()
		destroyUi()
		if phases.isPhase("spawn") then
			modApi:runLater(startSpawn)
		end
		if phases.isPhase("spawning") then
			modApi:runLater(function()
				phases.setPhase("transitMech")
			end)
		end
	end
	
	modUtils:addResetTurnHook(reset)
	modUtils:addGameLoadedHook(reset)
end

return this