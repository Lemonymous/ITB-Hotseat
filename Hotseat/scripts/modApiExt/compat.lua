--[[
	Deprecated functions, kept around for compatibility
--]]

local compat = {}

function compat:init(modApiExt)
	function modApiExt:getParentPath(path)
		return GetParentPath(path)
	end

	function modApiExt:scheduleHook(msTime, fn)
		modApi:scheduleHook(msTime, fn)
	end

	function modApiExt:runLater(f)
		modApi:runLater(f)
	end

	return compat
end

function compat:load(modApiExt, mod, options, version)
end

function compat:registerMoveHooks(modApiExt)
	modApiExt:addSkillStartHook(function(mission, pawn, skill, p1, p2)
		if skill == "Move" then
			modApiExt.dialog:triggerRuledDialog("MoveStart", { main = pawn:GetId() })
			modApiExt_internal.fireMoveStartHooks(mission, pawn, p1, p2)
		end
	end)
	modApiExt:addSkillEndHook(function(mission, pawn, skill, p1, p2)
		if skill == "Move" then
			modApiExt.dialog:triggerRuledDialog("MoveEnd", { main = pawn:GetId() })
			modApiExt_internal.fireMoveEndHooks(mission, pawn, p1, p2)
		end
	end)
end

return compat
