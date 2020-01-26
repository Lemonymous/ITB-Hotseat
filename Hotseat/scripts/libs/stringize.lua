
local this = {}

function this.color(c)
	assert(type(c) == 'userdata')
	
	return c.r ..",".. c.g ..",".. c.b ..",".. c.a ..","
end

function this.colormap(colormap)
	assert(type(colormap) == 'table')
	
	local ret = ""
	for _, c in ipairs(colormap) do
		ret = ret .. c.r ..",".. c.g ..",".. c.b ..",".. c.a ..","
	end
	
	return ret
end

return this