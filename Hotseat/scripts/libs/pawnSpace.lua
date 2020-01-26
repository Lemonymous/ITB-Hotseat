
---------------------------------------------------
-- pawnSpace - lib
---------------------------------------------------
-- provides functions for moving pawns around
-- during a skill effect, in order to force
-- a particular board preview.
--
-- valid sequences are [clear - rewind] or [filter - rewind]
-- and there should be NO_DELAY between them, or there will be bugs.

local this = {}
local displaced = {}
lmn_displaced = {}

local function filterSpace(fx, p, pawnId, queued)
	assert(type(fx) == 'userdata')
	assert(type(p) == 'userdata')
	assert(type(p.x) == 'number')
	assert(type(p.y) == 'number')
	assert(type(pawnId) == 'number')
	
	queued = queued or ""
	fx["Add".. queued .."Script"](fx, string.format([[
		lmn_displaced = {};
		local p = %s;
		repeat
			local pawn = Board:GetPawn(p);
			local id = pawn:GetId();
			if not pawn or id == %s then
				break;
			end
			pawn:SetSpace(Point(-1, -1));
			lmn_displaced[id] = p;
		until false;
	]], p:GetString(), pawnId))
end

local function clearSpace(fx, p, queued)
	assert(type(fx) == 'userdata')
	assert(type(p) == 'userdata')
	assert(type(p.x) == 'number')
	assert(type(p.y) == 'number')
	queued = queued or ""
	fx["Add".. queued .."Script"](fx, string.format([[
		lmn_displaced = {};
		local p = %s;
		repeat
			local pawn = Board:GetPawn(p);
			if not pawn then
				break;
			end
			pawn:SetSpace(Point(-1, -1));
			lmn_displaced[pawn:GetId()] = p;
		until false;
	]], p:GetString()))
end

local function rewind(fx, queued)
	assert(type(fx) == 'userdata')
	queued = queued or ""
	fx["Add".. queued .."Script"](fx, [[
		for id, p in pairs(lmn_displaced) do
			Board:GetPawn(id):SetSpace(p);
		end;
	]])
end

local function filterSpaceInstant(p, pawnId)
	assert(type(pawnId) == 'number')
	displaced = {}
	repeat
		local pawn = Board:GetPawn(p)
		local id = pawn:GetId()
		if not pawn or id == pawnId then
			break
		end
		pawn:SetSpace(Point(-1, -1))
		displaced[id] = p
	until false
end

local function clearSpaceInstant(p)
	displaced = {}
	repeat
		local pawn = Board:GetPawn(p)
		if not pawn then
			break
		end
		pawn:SetSpace(Point(-1, -1))
		displaced[pawn:GetId()] = p
	until false
end

local function rewindInstant()
	for id, p in pairs(displaced) do
		Board:GetPawn(id):SetSpace(p)
	end
end

-- filters a tile, effecively moving all other
-- pawns away from it, until we can grab it with
-- Board:GetPawn(p)
-- usage: damage on tile will now be done to this pawn.
-- trying to move from tile will pick this pawn.
-- can be useful if multiple pawns will be on this tile
-- during a moment in a skill effect.
function this.FilterSpace(fx, p, pawnId)
	if
		type(fx) == 'userdata' and
		type(fx.x) == 'number' and
		type(fx.y) == 'number'
	then
		filterSpaceInstant(fx, p)
		return
	end
	
	filterSpace(fx, p, pawnId)
end

-- queued version of FilterSpace.
function this.QueuedFilterSpace(fx, p, pawnId)
	filterSpace(fx, p, pawnId, "Queued")
end

-- clears a tile of all pawns.
-- can be useful to apply skill effects to a tile
-- to enable a skill preview, but when it comes to
-- carrying out the action, the pawn is not there.
function this.ClearSpace(fx, p)
	if
		type(fx) == 'userdata' and
		type(fx.x) == 'number' and
		type(fx.y) == 'number'
	then
		clearSpaceInstant(fx)
		return
	end
	
	clearSpace(fx, p)
end

-- queued version of ClearSpace.
function this.QueuedClearSpace(fx, p)
	
	clearSpace(fx, p, "Queued")
end

-- reverts actions done by clear and filter.
function this.Rewind(fx)
	if not fx then
		rewindInstant()
		return
	end
	
	rewind(fx)
end

-- queued version of Rewind.
function this.QueuedRewind(fx)
	rewind(fx, "Queued")
end

return this