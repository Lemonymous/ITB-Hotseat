local modApiExt = {}

--[[
	Load the ext API's modules through this function to ensure that they can
	access other modules via self keyword.
--]]
function modApiExt:loadModule(path)
	local m = require(path)
	setmetatable(m, self)
	return m
end

function modApiExt:clearHooks()
	-- too lazy to update this function with new hooks every time
	for k, v in pairs(self) do
		if type(v) == "table" and modApi:stringEndsWith(k, "Hooks") then
			self[k] = {}
		end
	end
end

--[[
	Returns true if this instance of modApiExt is the most recent one
	out of all registered instances.
--]]
function modApiExt:isMostRecent()
	assert(modApiExt_internal)
	assert(modApiExt_internal.extObjects)

	local v = self.version
	for _, extObj in ipairs(modApiExt_internal.extObjects) do
		if v ~= extObj.version and modApi:isVersion(v, extObj.version) then
			return false
		end
	end

	return true
end

--[[
	Returns the most recent registered instance of modApiExt.
--]]
function modApiExt:getMostRecent()
	assert(modApiExt_internal)
	return modApiExt_internal:getMostRecent()
end

function modApiExt:forkMostRecent(mod, options, version)
	if not modApiExt_internal.mostRecent then
		error("Most recent version of modApiExt has not been resolved yet!")
	end

	local proxy = setmetatable({}, modApiExt_internal.mostRecent)
	proxy.__index = proxy
	proxy.modulesDir = self.modulesDir
	proxy.version = self.version
	proxy.isProxy = true
	proxy.owner = self.owner
	proxy.loaded = false
	proxy.load = modApiExt.load

	local hooks = require(self.modulesDir.."hooks")
	for k, v in pairs(hooks) do
		proxy[k] = v
	end
	proxy:load(mod, options, version)

	-- Transplant already-registered hooks over to the proxy
	for k, v in pairs(self) do
		if type(v) == "table" and modApi:stringEndsWith(k, "Hooks") then
			for _, hook in ipairs(v) do
				table.insert(proxy[k], hook)
			end
		end
	end

	self:clearHooks()

	local index = list_indexof(modApiExt_internal.extObjects, self)
	modApiExt_internal.extObjects[index] = proxy

	return proxy
end

--[[
	Initializes the modApiExt object by loading available modules and setting
	up hooks.

	modulesDir - path to the directory containing all modules, with a forward
	             slash (/) at the end
--]]
function modApiExt:init(modulesDir)
	self.__index = self
	self.modulesDir = modulesDir or self.modulesDir
	self.version = require(self.modulesDir.."init").version
	self.isProxy = false

	local minv = "2.3.0"
	if not modApi:isVersion(minv) then
		error("modApiExt could not be loaded because version of the mod loader is out of date. "
			..string.format("Installed version: %s, required: %s", modApi.version, minv))
	end

	self.compat = self:loadModule(self.modulesDir.."compat"):init(self)

	require(self.modulesDir.."internal"):init(self)
	table.insert(modApiExt_internal.extObjects, self)

	require(self.modulesDir.."global")

	local hooks = require(self.modulesDir.."hooks")
	for k, v in pairs(hooks) do
		self[k] = v
	end

	self.vector =   self:loadModule(self.modulesDir.."vector")
	self.string =   self:loadModule(self.modulesDir.."string")
	self.board =    self:loadModule(self.modulesDir.."board")
	self.weapon =   self:loadModule(self.modulesDir.."weapon")
	self.pawn =     self:loadModule(self.modulesDir.."pawn")
	self.dialog =   self:loadModule(self.modulesDir.."dialog")

	return self
end

function modApiExt:load(mod, options, version)
	-- We're already loaded. Bail.
	if self.loaded then return end

	self.owner = {
		id = mod.id,
		name = mod.name,
		version = mod.version
	}

	-- clear out previously registered hooks, since we're reloading.
	self:clearHooks()

	self.hooks = self:loadModule(self.modulesDir.."alter")

	if not self.isProxy then
		--self.board:__init()
		self.compat:load(self, mod, options, version)
	end

	modApi:addPostLoadGameHook(function()
		if self:getMostRecent() == self and not self.isProxy then
			if Board then
				Board.gameBoard = true
			end

			if modApiExt_internal.mission then
				-- modApiExt_internal.mission is only updated in missionUpdateHook,
				-- and reset back to nil when we're not in-game.
				-- So if it's available, we must be loading from inside of a mission,
				-- which only happens when the player uses reset turn.
				modApiExt_internal.fireResetTurnHooks(modApiExt_internal.mission)
			else
				modApiExt_internal.fireGameLoadedHooks(GetCurrentMission())
				self.dialog:triggerRuledDialog("GameLoad")
			end
		end
	end)

	modApi:addModsLoadedHook(function()
		self.loaded = false

		if self:getMostRecent() == self and not self.isProxy then
			modApi:addMissionStartHook(self.hooks.missionStart)
			modApi:addTestMechEnteredHook(self.hooks.missionStart)
			modApi:addMissionEndHook(self.hooks.missionEnd)
			modApi:addTestMechExitedHook(self.hooks.missionEnd)
			modApi:addMissionUpdateHook(self.hooks.missionUpdate)

			--self.board:__load()

			if self.hooks.overrideAllSkills then
				-- Make sure the most recent version overwrites all others
				dofile(self.modulesDir.."global.lua")
				self.hooks:overrideAllSkills()

				self.compat:registerMoveHooks(self)
			end

			modApi:addVoiceEventHook(self.hooks.voiceEvent)

			if not modApiExt_internal.mostRecent then
				modApiExt_internal.mostRecent = self
				modApiExt_internal.fireMostRecentResolvedHooks()
			end
		end
	end)

	self.loaded = true
end

modApiExt.modulesDir = GetParentPath(...)

return modApiExt
