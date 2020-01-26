
-----------------------------------------------------------------------------
-- Weapon Preview v2.1 - code library
--[[-------------------------------------------------------------------------
	API for
	 - enhancing preview of weapons/move/repair skills with
		- damage marks
		- colored tiles
		- tile descriptions
		- tile images
		- animations
		- emitters
	
	
	 request api:
	==============
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	local previewer = require(path .."weaponPreview/api")
	
	library must be requested at init at least once and it will automatically initialize.
	
	
	 load library: (required)
	===============
	require(self.scriptPath .."weaponPreview/api"):load()
	
	place in load function in init.lua
	
	
	-----------------
	   Method List
	-----------------
	all methods except 'load' are meant to be used in either GetTargetArea or GetSkillEffect, whichever makes the most sense.
	GetTargetArea can display marks as soon as a weapon is selected.
	GetSkillEffect can display marks only after a tile is highlighted, and should be used if mark is dependent of target location.
	
	
	previewer:load()
	================
	loads library. (required)
	
	
	previewer:AddDelay(duration)
	============================
	adds a delay before next preview;
	essentially animating the preview data, and looping it.
	
	field    | type  | description
	---------+-------+------------------
	duration | float | delay in seconds
	---------+-------+------------------
	
	
	previewer:SetLooping(flag)
	==========================
	previews loop by default.
	if looping is set to false, preview data will be displayed
	until there are no more calls to AddDelay.
	after the last AddDelay, any preview data added after it will display continuously.
	
	field | type    | description
	------+---------+-----------------------------
	flag  | boolean | sets looping if true or nil
	------+---------+-----------------------------
	
	
	previewer:AddDamage(damage)
	===========================
	marks the board with a SpaceDamage object.
	
	field  | type        | description
	-------+-------------+-------------------
	damage | SpaceDamage | object to preview
	-------+-------------+-------------------
	
	
	previewer:AddColor(tile, gl_color)
	==================================
	colors a tile. different color marks can combine to show both.
	
	field    | type     | description
	---------+----------+-------------
	tile     | Point    | location
	gl_color | GL_Color | tile color
	---------+----------+-------------
	
	
	previewer:AddSimpleColor(tile, gl_color)
	========================================
	colors a tile. simple color does not combine colors with other color marks.
	
	field    | type     | description
	---------+----------+-------------
	tile     | Point    | location
	gl_color | GL_Color | tile color
	---------+----------+-------------
	
	
	previewer:AddImage(tile, imagePath, gl_color)
	=============================================
	adds an image to a tile.
	
	field     | type     | description
	----------+----------+--------------------
	tile      | Point    | location
	imagePath | string   | file path to image
	gl_color  | GL_Color | image color
	----------+----------+--------------------
	
	
	previewer:AddDesc(tile, desc, flag)
	===================================
	adds a description to a tile.
	
	field | type    | description
	------+---------+------------------
	tile  | Point   | location
	desc  | string  | tile description
	flag  | boolean | ?
	------+---------+------------------
	
	
	previewer:AddFlashing(tile, flag)
	=================================
	causes a building to flash.
	
	field | type    | description
	------+---------+-------------
	tile  | Point   | location
	flag  | boolean | ?
	------+---------+-------------
	
	
	previewer:AddAnimation(tile, anim)
	==================================
	plays an animation at a tile.
	
	field | type    | description
	------+---------+-----------------
	tile  | Point   | location
	anim  | string  | id of animation
	------+---------+-----------------
	
	
	previewer:AddEmitter(tile, emitter)		(not implemented)
	===================================
	plays an animation at a tile.
	
	field   | type    | description
	--------+---------+---------------
	tile    | Point   | location
	emitter | string  | id of emitter
	--------+---------+---------------
	
	
]]---------------------------------------------------------------------------


local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local getModUtils = require(path .."weaponPreview/lib/getModUtils")
local isTipImage = require(path .."weaponPreview/lib/isTipImage")
local selected = require(path .."weaponPreview/lib/selected")
local highlighted = require(path .."weaponPreview/lib/highlighted")
local spaceEmitter = require(path .."weaponPreview/lib/spaceEmitter")
local getQueued = require(path .."weaponPreview/lib/getQueued")

local this = {}
local loaded
local marker = {area = {weapon = {start = 0}}, effect = {weapon = {start = 0}}}
local marks = marker.area
local frame = -1
local isQueued
local a = ANIMS
local ignoreCall

local function isMarkIgnored()
	return isQueued or ignoreCall or isTipImage() or not selected:Get()
end

local function isMarkUnavailable()
	return isMarkIgnored() or frame ~= marks.weapon.start
end

local function clearMarks()
	marker.area = {weapon = {start = 0}}
	marker.effect = {weapon = {start = 0}}
end

local function updateIsQueued(p)
	local pawn = Board:GetPawn(p)
	
	isQueued = not Pawn or not pawn
	if pawn then
		isQueued = getQueued(pawn:GetId()) or not pawn:IsActive()
	end
end

function this:AddDamage(d, duration)
	if isMarkUnavailable() then return end
	
	assert(type(d) == 'userdata' or type(d) == 'table')
	assert(type(d.loc) == 'userdata')
	assert(type(d.loc.x) == 'number')
	assert(type(d.loc.y) == 'number')
	assert(duration == nil or type(duration) == 'number')
	
	table.insert(marks, {
		fn = 'MarkSpaceDamage',
		data = {shallow_copy(d)},
		duration = duration
	})
end

function this:AddImage(p, path, gl_color, duration)
	if isMarkUnavailable() then return end
	
	assert(type(p) == 'userdata')
	assert(type(p.x) == 'number')
	assert(type(p.y) == 'number')
	assert(type(path) == 'string')
	assert(type(gl_color) == 'userdata')
	assert(type(gl_color.r) == 'number')
	assert(type(gl_color.g) == 'number')
	assert(type(gl_color.b) == 'number')
	assert(type(gl_color.a) == 'number')
	assert(duration == nil or type(duration) == 'number')
	
	table.insert(marks, {
		fn = 'MarkSpaceImage',
		data = {p, path, gl_color},
		duration = duration
	})
end

function this:AddDesc(p, desc, flag, duration)
	if isMarkUnavailable() then return end
	
	assert(type(p) == 'userdata')
	assert(type(p.x) == 'number')
	assert(type(p.y) == 'number')
	assert(type(desc) == 'string')
	assert(duration == nil or type(duration) == 'number')
	
	flag = flag ~= false
	
	table.insert(marks, {
		fn = 'MarkSpaceDesc',
		data = {p, desc, flag},
		duration = duration
	})
end

function this:AddColor(p, gl_color, duration)
	if isMarkUnavailable() then return end
	
	assert(type(p) == 'userdata')
	assert(type(p.x) == 'number')
	assert(type(p.y) == 'number')
	assert(type(gl_color) == 'userdata')
	assert(type(gl_color.r) == 'number')
	assert(type(gl_color.g) == 'number')
	assert(type(gl_color.b) == 'number')
	assert(type(gl_color.a) == 'number')
	assert(duration == nil or type(duration) == 'number')
	
	table.insert(marks, {
		fn = 'MarkSpaceColor',
		data = {p, gl_color},
		duration = duration
	})
end

function this:AddSimpleColor(p, gl_color, duration)
	if isMarkUnavailable() then return end
	
	assert(type(p) == 'userdata')
	assert(type(p.x) == 'number')
	assert(type(p.y) == 'number')
	assert(type(gl_color) == 'userdata')
	assert(type(gl_color.r) == 'number')
	assert(type(gl_color.g) == 'number')
	assert(type(gl_color.b) == 'number')
	assert(type(gl_color.a) == 'number')
	assert(duration == nil or type(duration) == 'number')
	
	table.insert(marks, {
		fn = 'MarkSpaceSimpleColor',
		data = {p, gl_color},
		duration = duration
	})
end

function this:AddFlashing(p, flag, duration)
	if isMarkUnavailable() then return end
	
	assert(type(p) == 'userdata')
	assert(type(p.x) == 'number')
	assert(type(p.y) == 'number')
	assert(duration == nil or type(duration) == 'number')
	
	flag = flag ~= false
	
	table.insert(marks, {
		fn = 'MarkFlashing',
		data = {p, flag},
		duration = duration
	})
end

function this:AddAnimation(p, anim)
	if isMarkUnavailable() then return end
	
	assert(type(p) == 'userdata')
	assert(type(p.x) == 'number')
	assert(type(p.y) == 'number')
	assert(type(anim) == 'string')
	assert(a[anim])
	
	table.insert(marks, {
		fn = 'AddAnimation',
		anim = anim,
		data = {p, anim, ANIM_NO_DELAY},
		duration = a[anim].Time * a[anim].NumFrames
	})
end

function this:AddEmitter(p, emitter, duration)
	if isMarkUnavailable() then return end
	
	assert(type(p) == 'userdata')
	assert(type(p.x) == 'number')
	assert(type(p.y) == 'number')
	assert(type(emitter) == 'string')
	local base = _G[emitter]
	
	assert(base)
	assert(duration == nil or type(duration) == 'number')
	
	if not _G[emitter .. mod.id] then
		_G[emitter .. mod.id] = base:new{
			timer = .017,
			birth_rate = base.birth_rate,
			burst_count = base.burst_count
		}
	end
	
	table.insert(marks, {
		fn = 'DamageSpace',
		emitter = emitter,
		data = {spaceEmitter(p, emitter .. mod.id)},
		duration = duration
	})
end

function this:AddDelay(duration)
	if isMarkUnavailable() then return end
	
	assert(type(duration) == 'number')
	duration = duration * 60 -- fps

	table.insert(marks, {
		delay = duration
	})
	
	marks.length = marks.length or 0
	marks.length = marks.length + duration
end

function this:SetLooping(flag)
	if isMarkUnavailable() then return end
	
	marks.loop = flag
end

local function init()
	-- inject code into all GetTargetArea and GetSkillEffect functions
	for i, v in pairs(_G) do
		if type(v) == 'table' then
			
			local function addFunc(fn, markType)
				local function addWeapon(root)
					local mark = marker[markType]
					
					-- reset weapon if at root and time mismatch.
					if (not root or list_contains(root, i)) and marks.weapon.start ~= frame then
						marker[markType] = {p1 = p1, p2 = p2, weapon = {root = i, start = frame}}
					end
					
					-- only add weapon if the root skill matches armed weapon id.
					if (not root or list_contains(root, marks.weapon.root)) and marker[markType].weapon.start == frame then
						table.insert(marker[markType].weapon, i)
					end
				end
				
				local old = v[fn]
				v[fn] = function(self, p, ...)
					
					updateIsQueued(p)
					
					local selected = selected:Get()
					if not isMarkIgnored() and selected:GetSpace() == p then
						marks = marker[markType]
						local armedId = selected:GetArmedWeaponId()
						
						if armedId == 0 then
							addWeapon{'Move'}
						elseif armedId == 50 then
							-- not sure if Skill_Repair_A is ever called.
							addWeapon{'Skill_Repair', 'Skill_Repair_A', 'Skill_Repair_Power', 'Skill_Repair_Punch'}
						else
							addWeapon()
						end
						
						marks = marker[markType]
					end
					
					return old(self, p, ...)
				end
			end
			
			if type(v.GetTargetArea) == 'function' then
				addFunc('GetTargetArea', 'area')
			end
			
			if type(v.GetSkillEffect) == 'function' then
				addFunc('GetSkillEffect', 'effect')
			end
		end
	end
end

-- init after all mods have been initialized.
local modApiFinalize = modApi.finalize
function modApi.finalize(...)
	init()
	
	modApiFinalize(...)
end

local function createAnim(anim)
	local base = a[anim]
	-- create animations if they don't exist.
	if not a[anim .. mod.id .."1"] then
		-- TODO? make work with Frames and Lengths.
		assert(base.Frames == nil, "Weapon Preview library does not support animations with .Frames")
		assert(base.Lengths == nil, "Weapon Preview library does not support animations with .Lengths")
		
		-- chop up animation to single frame units.
		for i = 1, base.NumFrames do
			a[anim .. mod.id .. i] = base:new{
				Frames = {i-1},
				Loop = false,
				Time = 0
			}
		end
	end
end

local function nextFrame()
	frame = frame + 1
end

function this:load()
	if loaded then return end
	loaded = true
	
	selected:load()
	highlighted:load()
	
	local modUtils = getModUtils()
	modApi:addModsLoadedHook(function() loaded = nil end)
	modApi:addMissionStartHook(clearMarks)
	modApi:addMissionNextPhaseCreatedHook(clearMarks)
	modApi:addTestMechEnteredHook(clearMarks)
	modApi:addPreLoadGameHook(clearMarks)
	modUtils:addPawnDeselectedHook(clearMarks)
	
	modApi:addMissionUpdateHook(function()
		
		local selected = selected:Get()
		if not selected then clearMarks(); nextFrame(); return end
		if selected:GetArmedWeaponId() == -1 then clearMarks(); nextFrame(); return end
		
		for _, markType in ipairs{'area', 'effect'} do
			local marker = marker[markType]
			marker.loop = marker.loop ~= false
			
			local t = 0
			local t1 = frame - marker.weapon.start -- time since start
			if marker.loop then
				t1 = marker.length and frame % marker.length or 0
			end
			
			for _, mark in ipairs(marker) do
				ignoreCall = true
				
				if markType == 'area' or list_contains(extract_table(_G[marker.weapon.root]:GetTargetArea(selected:GetSpace())), highlighted:Get()) then
					if mark.fn then
						local duration = mark.duration and mark.duration * 60 or INT_MAX - t
						if t <= t1 and t1 <= t + duration then
							if mark.anim then
								createAnim(mark.anim)
								
								local start = marker.loop and frame or t1
								local f = 1 + math.floor((start % duration) * a[mark.anim].NumFrames / duration)
								mark.data[2] = mark.anim .. mod.id .. f
							end
							
							if not mark.emitter or (t1 - t) % 5 < 1 then
								Board[mark.fn](Board, unpack(mark.data))
							end
						end
					end
					
					t = t + (mark.delay or 0)
				end
				
				ignoreCall = nil
			end
		end
		
		nextFrame()
	end)
end

return this