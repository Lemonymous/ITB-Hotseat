
local path = mod_loader.mods[modApi.currentMod].scriptPath
local clip = require(path .."libs/clip")
local phases = require(path .."phases")
local UiCover = require(path .."ui/cover")
local Ui2 = require(path .."ui/Ui2")
local UiFrameping = require(path .."ui/frameping")
local this = Class.inherit(Ui2)
local color = { red = sdl.rgb(255, 50, 50), gray = sdl.rgba(128, 128, 128, 64) }
local ping_width = 4
local ping_start = 2
local ping_end = ping_start + 10
local ping_end_large = ping_start + 20

local function toMins(frames)
	local mins = math.floor(frames / 3600)
	local secs = math.ceil(frames / 60 - mins * 60)
	
	mins = tostring(mins)
	secs = tostring(secs)
	
	while mins:len() < 2 do mins = "0".. mins end
	while secs:len() < 2 do secs = "0".. secs end
	
	return mins, secs
end

function this:new(time)
	Ui2().new(self)
	
	self:widthpx(80):heightpx(30)
		:decorate{
			DecoFrame(),
			DecoCAlignedText(),
		}
		:settooltip("Turn will end when timer reaches zero")
		:setTime(time)
		
	UiCover{ align = {x = -2, y = -2} }:addTo(self)
end

function this:setTime(time)
	local m = GetCurrentMission()
	if not m then return end
	
	m.lmn_hotseat = m.lmn_hotseat or {}
	m.lmn_hotseat.timer = (time or 0) * 60
	
	return self
end

function this:getTime()
	local m = GetCurrentMission()
	if m then
		m.lmn_hotseat = m.lmn_hotseat or {}
		m.lmn_hotseat.timer = m.lmn_hotseat.timer or 0
		local mins, secs = toMins(m.lmn_hotseat.timer)
		
		return mins ..":".. secs
	end
	
	return "00:00"
end

function this:isUpdate(screen)
	local suppress = Board:IsBusy() and not phases.isPhase("spawn")
	return not suppress and (Ui2.isUpdate(self, screen) or self._time ~= self:getTime())
end

function this:update(screen)
	self:pospx(screen:w() / 2 - self.w / 2, screen:h() / 20)
	self.parent:relayout()
	
	self._time = self:getTime()
	
	local mins = tonumber(self._time:match("^(.+):"))
	local secs = mins * 60 + tonumber(self._time:match(":(.+)$"))
	
	if not self.initialized then
		self.initialized = true
		Game:TriggerSound("ui/battle/select_unit")
		UiFrameping(deco.colors.white, 1000, ping_width, ping_start, ping_end_large, nil):addTo(self)
		
	elseif secs == 0 then
		Game:TriggerSound("ui/battle/withdraw")
		Game:TriggerSound("ui/battle/end_turn_notification")
		UiFrameping(color.red, 1000, ping_width + 2, ping_start + 2, ping_end_large + 10, nil):addTo(self)
		
	elseif secs <= 10 then
		Game:TriggerSound("ui/battle/radio_window_in")
		UiFrameping(color.red, 1000, ping_width, ping_start, ping_end_large, nil):addTo(self)
		
		if not IsColorEqual(self.decorations[2].textset.color, color.red) then
			self.decorations[1].bordercolor = color.red
			self.decorations[2].text = self._time
			self.decorations[2]:setcolor(color.red)
		end
		
	elseif secs <= 15 then
		Game:TriggerSound("ui/battle/radio_window_in")
		UiFrameping(color.gray, 500, ping_width, ping_start, ping_end, nil):addTo(self)
	end
	
	self.decorations[2]:setsurface(self._time)
	
	Ui2.update(self, screen)
end

function this:draw(screen)
	self.visible = self.initialized and not sdlext.isConsoleOpen()
	
	clip(Ui2, self, screen)
end

return this