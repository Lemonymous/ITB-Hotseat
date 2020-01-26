local mstring = {}

--[[
	Returns true if this string starts with the prefix string
--]]
function mstring:startsWith(str, prefix)
	return modApi:stringStartsWith(str, prefix)
end

--[[
	Returns true if this string ends with the suffix string
--]]
function mstring:endsWith(str, suffix)
	return modApi:stringEndsWith(str, suffix)
end

--[[
	Trims leading and trailing whitespace from the string.

	trim11 from: http://lua-users.org/wiki/StringTrim
--]]
function mstring:trim(str)
	return modApi:trimString(str)
end

return mstring