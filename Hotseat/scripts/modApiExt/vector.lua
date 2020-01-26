local vector = {}

-- diagonal vectors
vector.VEC_DOWN_RIGHT = Point( 1,  1)
vector.VEC_DOWN_LEFT  = Point(-1,  1)
vector.VEC_UP_RIGHT   = Point( 1, -1)
vector.VEC_UP_LEFT    = Point(-1, -1)

-- shorthands
vector.VEC_DR = vector.VEC_DOWN_RIGHT
vector.VEC_DL = vector.VEC_DOWN_LEFT
vector.VEC_UR = vector.VEC_UP_RIGHT
vector.VEC_UL = vector.VEC_UP_LEFT

vector.DIR_VECTORS_8 =
{
	vector.VEC_UP,
	vector.VEC_UP_RIGHT,
	vector.VEC_RIGHT,
	vector.VEC_DOWN_RIGHT,
	vector.VEC_DOWN,
	vector.VEC_DOWN_LEFT,
	vector.VEC_LEFT,
	vector.VEC_UP_LEFT
}

vector.AXIS_X   = 0
vector.AXIS_Y   = 1
vector.AXIS_ANY = 2

--------------------------------------------------------------------------

--[[
	Tests whether two points form a line colinear to the specified axis
	(ie. have the same value for that axis' coordinate)
--]]
function vector:isColinear(refPoint, testPoint, axis)
	axis = axis or self.AXIS_ANY

	if axis == self.AXIS_X then
		return refPoint.x == testPoint.x
	elseif axis == self.AXIS_Y then
		return refPoint.y == testPoint.y
	elseif axis == self.AXIS_ANY then
		return refPoint.x == testPoint.x or refPoint.y == testPoint.y
	end

	return nil
end

--[[
	Returns a vector normal to the one provided in argument.
	Normal in this context means perpendicular.
--]]
function vector:normal(vec)
	return Point(-vec.y, vec.x)
end

--[[
	Returns length of the vector.
--]]
function vector:length(vec)
	return math.sqrt(vec.x * vec.x + vec.y * vec.y)
end

--[[
	Returns a unit vector constructed from the vector provided in argument.
	Unit vector is a vector with length of 1.
	HOWEVER in ItB, the Point class can only hold integers, and by default
	rounds fractional values to nearest integers. 0.5 is rounded to 1, -0.5
	is rounded to -1, etc.

	For fractional values, use UnitF(), which returns a custom table
	with x and y fields.
--]]
function vector:unitI(vec)
	local l = self:length(vec)
	if l == 0 then return Point(0, 0) end
	return Point(vec.x / l, vec.y / l)
end

--[[
	Returns a unit vector constructed from the vector provided in argument.
	Unit vector is a vector with length of 1.

	Note that other functions in the vector module use Point internally,
	so values held by the table returned by this function will be rounded.
--]]
function vector:unitF(vec)
	local l = self:length(vec)

	local t = {}
	if l == 0 then t.x = 0 else t.x = vec.x / l end
	if l == 0 then t.y = 0 else t.y = vec.y / l end
	return t
end

--[[
	Returns axis represented by this vector.

	Returns nil if Point(0, 0) is provided.
	Returns AXIS_X if this vector has Y = 0.
	Returns AXIS_Y if this vector has X = 0.
	Returns nil otherwise.
--]]
function vector:toAxis(vec)
	if vec == Point(0, 0) then return nil end

	if vec.y == 0 then
		return self.AXIS_X
	elseif vec.x == 0 then
		return self.AXIS_Y
	end

	return nil
end

--[[
	Returns index of the direction vector built from the specified 
	vector in the DIR_VECTORS_8 table
--]]
function vector:getDirection8(vec)
	return list_indexof(self.DIR_VECTORS_8, self:unitI(vec))
end

return vector