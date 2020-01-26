
--[[
	Nullsafe shorthand for point:GetString(), cause I'm lazy
--]]
function p2s(point)
	return point and point:GetString() or "nil"
end

--[[
	Converts a point to an index, given Board width
--]]
function p2idx(p, w)
	if not w then w = Board:GetSize().x end
	return p.y * w + p.x
end

--[[
	Converts index to a point on the Board, given Board width
--]]
function idx2p(idx, w)
	if not w then w = Board:GetSize().x end
	return Point(idx % w, math.floor(idx / w))
end

--[[
	Returns index of the specified element in the list, or -1 if not found.
--]]
function list_indexof(list, element)
	for i, v in ipairs(list) do
		if element == v then return i end
	end
	
	return -1
end

if not GetUiScale then
	GetUiScale = function() return 1 end
end

---------------------------------------------------------------
-- Screenpoint to tile conversion

--[[
	Returns currently highlighted board tile, or nil.
--]]
function mouseTile()
	-- Use custom table instead of the existing Point class, since Point
	-- can only hold integer values and automatically rounds them.
	return screenPointToTile({ x = sdl.mouse.x(), y = sdl.mouse.y() })
end

function modApiExt_internal.getScreenRefs(screen, scale)
	scale = scale or GetBoardScale()
	local uiScale = GetUiScale()

	local tw = 28 * uiScale
	local th = 21 * uiScale

	-- Top corner of the (0, 0) tile
	local tile00 = {
		x = screen:w() / 2,
		y = screen:h() / 2 - 8 * th * scale
	}

	if scale == 2 then
		tile00.y = tile00.y + 5 * scale * uiScale + 0.5
	end

	local lineX = function(x) return x * th/tw end
	local lineY = function(x) return -lineX(x) end

	return tile00, lineX, lineY
end

--[[
	Returns a board tile at the specified point on the screen, or nil.
--]]
function screenPointToTile(screenPoint)
	if not Board then return nil end

	local screen = sdl.screen()
	local scale = GetBoardScale()
	local uiScale = GetUiScale()

	local tw = 28 * uiScale
	local th = 21 * uiScale

	local tile00, lineX, lineY = modApiExt_internal.getScreenRefs(screen, scale)

	-- Change screenPoint to be relative to the (0, 0) tile
	-- and move to unscaled space.
	local relPoint = {}
	relPoint.x = (screenPoint.x - tile00.x) / scale
	relPoint.y = (screenPoint.y - tile00.y) / scale

	local isPointAboveLine = function(point, lineFn)
		return point.y >= lineFn(point.x)
	end

	local tileContains = function(tilex, tiley, point)
		local np = {
			x = point.x - tw * (tilex - tiley),
			y = point.y - th * (tilex + tiley)
		}
		return isPointAboveLine(np, lineX)
			and isPointAboveLine(np, lineY)
	end

	-- Start at the end of the board and move backwards.
	-- That way we only need to check 2 lines instead of 4 on each tile.
	-- The tradeoff is that we need to check an additional row and column
	-- of tiles outside of the board.
	local bsize = Board:GetSize()
	for tileY = bsize.y, 0, -1 do
		for tileX = bsize.x, 0, -1 do
			if tileContains(tileX, tileY, relPoint) then
				if tileY == bsize.y or tileX == bsize.x then
					-- outside of the board
					return nil
				end
				return Point(tileX, tileY)
			end
		end
	end

	return nil
end

---------------------------------------------------------------
-- Hashing functions

function is_prime(n)
	if (n > 2 and n % 2 == 0) or n == 1 then
		return false
	end

	local div = 3
	local sqrt = math.sqrt(n)

	while div <= sqrt do
		if n % div == 0 then
			return false
		end

		div = div + 2
	end

	return true
end

function next_prime(n)
	while not is_prime(n) do
		n = n + 1
	end

	return n
end

local function hash_table(tbl)
	local hash = 79
	local salt = 43

	for k, v in pairs(tbl) do
		hash = salt * hash + hash_o(k)
		if v ~= tbl.__index then
			hash = salt * hash + hash_o(v)
		else
			hash = salt * hash
		end
	end

	return hash
end

local function hash_string(str)
	local hash = 127
	local salt = 29

	local l = string.len(str)
	for i = 1, l do
		hash = salt * hash + string.byte(str, i)
	end

	return hash
end

function hash_o(o)
	local hash = 89
	local salt = 31
	local nullCode = 13

	if type(o) == "table" then
		hash = salt * hash + hash_table(o)
	elseif type(o) == "userdata" then
		hash = salt * hash + 8137
	elseif type(o) == "function" then
		hash = salt * hash + 7993
	elseif type(o) == "thread" then
		hash = salt * hash + 7681
	elseif type(o) == "number" then
		hash = salt * hash + o
	elseif type(o) == "string" then
		hash = salt * hash + hash_string(o)
	elseif type(o) == "boolean" then
		hash = salt * hash + (o and 23 or 17)
	elseif type(o) == "nil" then
		hash = salt * hash + nullCode
	end

	return hash
end

---------------------------------------------------------------
-- Deque list object (queue/stack)

--[[
	Double-ended queue implementation via www.lua.org/pil/11.4.html
	Modified to use the class system from ItB mod loader.

	To use like a queue: use either pushleft() and popright() OR
	pushright() and popleft()

	To use like a stack: use either pushleft() and popleft() OR
	pushright() and popright()
--]]
List = Class.new()
function List:new(tbl)
	self.first = 0
	self.last = -1

	if tbl then
		for _, v in ipairs(tbl) do
			self:pushRight(v)
		end
	end
end

--[[
	Pushes the element onto the left side of the dequeue (start)
--]]
function List:pushLeft(value)
	local first = self.first - 1
	self.first = first
	self[first] = value
end

--[[
	Pushes the element onto the right side of the dequeue (end)
--]]
function List:pushRight(value)
	local last = self.last + 1
	self.last = last
	self[last] = value
end

--[[
	Removes and returns an element from the left side of the dequeue (start)
--]]
function List:popLeft()
	local first = self.first
	if first > self.last then error("list is empty") end
	local value = self[first]
	self[first] = nil -- to allow garbage collection
	self.first = first + 1
	return value
end

--[[
	Removes and returns an element from the right side of the dequeue (end)
--]]
function List:popRight()
	local last = self.last
	if self.first > last then error("list is empty") end
	local value = self[last]
	self[last] = nil -- to allow garbage collection
	self.last = last - 1
	return value
end

--[[
	Returns an element from the left side of the dequeue (start) without removing it
--]]
function List:peekLeft()
	if self.first > self.last then error("list is empty") end
	return self[self.first]
end

--[[
	Returns an element from the right side of the dequeue (end) without removing it
--]]
function List:peekRight()
	if self.first > self.last then error("list is empty") end
	return self[self.last]
end

--[[
	Returns true if this dequeue is empty
--]]
function List:isEmpty()
	return self.first > self.last
end

--[[
	Returns size of the dequeue
--]]
function List:size()
	if self:isEmpty() then
		return 0
	else
		return self.last - self.first + 1
	end
end
