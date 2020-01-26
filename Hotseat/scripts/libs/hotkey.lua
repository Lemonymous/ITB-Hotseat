
local this = {
	keys = {},
	suppressed = {},
	hooks_down = {},
	hooks_up = {}
}

this.MUTE = 1
this.UNDO_MOVE = 2
this.RESET_TURN = 3
this.SELECT_MECH1 = 4
this.SELECT_MECH2 = 5
this.SELECT_MECH3 = 6
this.SELECT_DEPLOYED1 = 7
this.SELECT_DEPLOYED2 = 8
this.SELECT_DEPLOYED3 = 9
this.SELECT_MISSION_UNIT1 = 13
this.SELECT_MISSION_UNIT2 = 14
this.CYCLE_UNITS = 15
this.DESELECT_WEAPON = 16
this.INFO_OVERLAY = 17
this.ATTACK_ORDER_OVERLAY = 18
this.WEAPON1 = 19
this.WEAPON2 = 20
this.REPAIR = 21
this.END_TURN = 22
this.TOGGLE_FULLSCREEN = 23

local keystatus = {}

local settings = modApi:loadSettings()
this.keys = settings.hotkeys

sdlext.addSettingsChangedHook(function(old, new)
	this.keys = new.hotkeys
end)

sdlext.addPostKeyDownHook(function(keycode)
	local index = list_indexof(this.keys, keycode)
	if sdlext.isConsoleOpen() then return false end
	if index == -1 then return false end
	
	if this.hooks_down[index] then
		for _, v in ipairs(this.hooks_down[index]) do
			v.fn(unpack(v.params))
		end
	end
	
	keystatus[index] = true
	
	if this.suppressed[index] then
		return true
	end
	
    return false
end)

sdlext.addPostKeyUpHook(function(keycode)
	local index = list_indexof(this.keys, keycode)
	if sdlext.isConsoleOpen() then return false end
	if index == -1 then return false end
	
	if this.hooks_up[index] then
		for _, v in ipairs(this.hooks_up[index]) do
			v.fn(unpack(v.params))
		end
	end
	
	keystatus[index] = nil
	
	--if this.suppressed[index] then
	--	return true
	--end
	
	return false
end)

function this:suppress(keyIndex, flag)
	flag = flag ~= false
	if flag then
		if keyIndex then
			self.suppressed[keyIndex] = true
		else
			for i = 1, 23 do
				self.suppressed[i] = true
				keystatus[i] = false -- release key
			end
		end
	else
		if keyIndex then
			self.suppressed[keyIndex] = nil
		else
			self.suppressed = {}
		end
	end
end

function this:unsuppress(keyIndex)
	self:suppress(keyIndex, false)
end

function this:addKeyDownHook(keyIndex, fn, ...)
	assert(type(fn) == 'function')
	
	self.hooks_down[keyIndex] = self.hooks_down[keyIndex] or {}
	table.insert(self.hooks_down[keyIndex], {fn = fn, params = {...}})
end

function this:addKeyUpHook(keyIndex, fn, ...)
	assert(type(fn) == 'function')
	
	self.hooks_up[keyIndex] = self.hooks_up[keyIndex] or {}
	table.insert(self.hooks_up[keyIndex], {fn = fn, params = {...}})
end

function this:remKeyDownHook(keyIndex, fn)
	assert(type(fn) == 'function')
	
	local hooks = self.hooks_down[keyIndex]
	if hooks then
		for i, v in ipairs(hooks) do
			if v.fn == fn then
				table.remove(hooks, i)
				break
			end
		end
	end
end

function this:remKeyUpHook(keyIndex, fn)
	assert(type(fn) == 'function')
	
	local hooks = self.hooks_up[keyIndex]
	if hooks then
		for i, v in ipairs(hooks) do
			if v.fn == fn then
				table.remove(hooks, i)
				break
			end
		end
	end
end

function this.isKeyDown(keyIndex)
	return keystatus[keyIndex]
end

function this.isKeyUp(keyIndex)
	return not keystatus[keyIndex]
end

return this