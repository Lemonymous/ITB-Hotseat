
-- a very messy list of some functions with varied usefulness.

local this = {}

-- returns a list of all locations on the board.
-- if optional parameter fn is used, add only points affirming the function.
function this.getBoard(fn)
	local ret = {}
	
	local size = Board:GetSize()
	for x = 0, size.x - 1 do
		for y = 0, size.y - 1 do
			local p = Point(x,y)
			if not fn or fn(p) then
				table.insert(ret, Point(x,y))
			end
		end
	end
	
	return ret
end

-- returns a point on the board satisfying the conditions of predicate.
-- returns nil if no points satisfies the conditions.
function this.getSpace(predicate)
	assert(type(predicate) == "function")
	
	local size = Board:GetSize()
	for y = 0, size.y - 1 do
		for x = 0, size.x - 1 do
			local p = Point(x, y)
			if predicate(p) then
				return p
			end
		end
	end
	
	return nil
end

-- scrambles an array.
function this.shuffle(tbl)
	
    for i = #tbl, 2, -1 do
        local j = math.random(1, i)
		
		-- neat way to swap two variables.
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

function this.GetProjectileEnd(p1, p2, range, pathing)
	range = range or INT_MAX
	pathing = pathing or PATH_PROJECTILE
	local dir = GetDirection(p2 - p1)
	local target = p1
	
	for k = 1, range do
		local curr = p1 + DIR_VECTORS[dir] * k
		
		if not Board:IsValid(curr) then
			break
		end
		
		target = curr
		
		if Board:IsBlocked(target, pathing) then
			break
		end
	end
	
	return target
end

-- returns if a tile is a pit.
function this.IsPit(p)
	local terrain = Board:GetTerrain(p)
	return terrain == TERRAIN_WATER or terrain == TERRAIN_HOLE -- lava and acid water counts as water here.
end

-- returns if a tile has a building connected to the grid.
function this.IsBuilding(p)
	return Board:IsBuilding(p) and Board:IsPowered(p)
end

-- returns the tile on the edge of the board from p1 to p2.
-- if p1 is not aligned with p2, nil is returned.
function this.BoardEdge(p1, p2)
	assert(type(p1) == 'userdata')
	assert(type(p2) == 'userdata')
	
	local diff = p2 - p1
	local dirY = diff.x == 0
	
	-- not aligned
	if not dirY and diff.y ~= 0 then
		return nil
	end
	
	local size = Board:GetSize()
	if dirY then
		local y = (diff.y > 0) and (size.y - 1) or 0
		return Point(p1.x, y)
	else
		local x = (diff.x > 0) and (size.x - 1) or 0
		return Point(x, p1.y)
	end
end

-- returns the first point point in a PointList matching a predicate.
function this.PointListFind(pointList, predicate)
	for i, loc in ipairs(extract_table(pointList)) do
		if predicate(loc, i) then
			return loc
		end
	end
	
	return nil
end

function this.IsPushable(loc)
	if not Board:IsValid(loc) then return false end
	
	local pawn = Board:GetPawn(loc)
	if pawn and not pawn:IsGuarding() then
		return true
	end
end

function this.IsStableTile(loc)
	return Board:IsBlocked(loc, PATH_PROJECTILE) and not this.IsPushable(loc)
end

function this.IsValidLoc(loc, pathing)
	return Board:IsValid(loc) and not Board:IsBlocked(loc, pathing)
end

function this.IsTipImage()
	return Board:GetSize() == Point(6,6)
end

function this.appendAssets(assets)
	assert(type(assets) == 'table')
	assert(type(assets.writePath) == 'string', "none or incorrect writePath")
	assert(type(assets.readPath) == 'string', "none or incorrect readPath")
	
	for _, v in ipairs(assets) do
		modApi:appendAsset(assets.writePath .. v[1], assets.readPath .. v[2])
	end
end

function this.copyAssets(assets)
	assert(type(assets) == 'table')
	assert(type(assets.writePath) == 'string', "none or incorrect writePath")
	assert(type(assets.readPath) == 'string', "none or incorrect readPath")
	
	for _, v in ipairs(assets) do
		modApi:copyAsset( assets.readPath .. v[2], assets.writePath .. v[1])
	end
end

-- returns whether a table is empty or not.
function this.list_isEmpty(list)
	return not next(list)
end

local function bezier_linear(t, p0, p1)
	-- clamp 0 <= t <= 1
	t = t > 0 and t or 0
	t = t < 1 and t or 1
	
	return (1 - t) * p0 + t * p1
end

local function bezier_quadratic(t, p0, p1, p2)
	-- clamp 0 <= t <= 1
	t = t > 0 and t or 0
	t = t < 1 and t or 1
	
	return (1 - t) * ((1 - t) * p0 + t * p1) + t * ((1 - t) * p1 + t * p2)
end

local function bezier_cubic(t, p0, p1, p2, p3)
	-- clamp 0 <= t <= 1
	t = t > 0 and t or 0
	t = t < 1 and t or 1
	
	return (1 - t)^3 * p0 + 3 * (1 - t)^2 * t * p1 + 3 * (1 - t) * t^2 * p2 + t^3 * p3
end

-- interpolates a value between first and last value.
-- 0 <= t <= 1
function this.interpolate(t, p0, p1, p2, p3)
	assert(type(t) == 'number')
	assert(type(p0) == 'number')
	assert(type(p1) == 'number')
	
	if type(p2) == 'number' then
		if type(p3) == 'number' then
			return bezier_cubic(t, p0, p1, p2, p3)
		end
		return bezier_quadratic(t, p0, p1, p2)
	end
	return bezier_linear(t, p0, p1)
end

return this