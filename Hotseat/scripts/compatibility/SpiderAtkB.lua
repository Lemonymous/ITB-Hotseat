
SpiderAtkB = Skill:new{
	Name = "Plenty Offsprings",
	Description = "Throw many eggs that hatches into a Spiderlings.",
}

local selectedPawnId
local armedWeaponId
local targets = {}
local targets_max = 3
local Range = 2

local function resetTargets()
	if #targets > 0 then
		targets = {}
	end
end

local function resetAll()
	selectedPawnId = nil
	armedWeaponId = nil
	resetTargets()
end

local function getTargetArea(p)
	local plist = PointList()
	local traversed = {}
	local nodes = {{p = p, range = 0}}
	traversed[p2idx(p)] = true
	
	while #nodes > 0 do
		local node = nodes[#nodes]
		local center = node.p
		local range = node.range
		table.remove(nodes, #nodes)
		
		for i = DIR_START, DIR_END do
			local adjacent = center + DIR_VECTORS[i]
			
			if not traversed[p2idx(adjacent)] then
				traversed[p2idx(adjacent)] = true
				if range < Range then
					table.insert(nodes, {p = adjacent, range = range + 1})
				end
				
				if not Board:IsBlocked(adjacent, PATH_GROUND) then
					plist:push_back(adjacent)
				end
			end
		end
	end
	
	return plist
end

function SpiderAtkB:GetTargetArea(p)
	return getTargetArea(p)
end

function SpiderAtkB:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local possible = {}
	
	-- remove target if present
	for i = 1, #targets do 
		if targets[i] == p2 then
			table.remove(targets, i)
			break
		end
	end
	-- insert our target
	table.insert(targets, 1, p2)
	
	-- prune targets above targets_max
	for i = #targets, targets_max + 1, -1 do
		table.remove(targets, i)
	end
	
	-- add missing targets if below targets_max
	if #targets < targets_max then
		local plist = getTargetArea(p1)
		local i = 1
		while #targets < targets_max and plist:size() >= i do
			local target = plist:index(i)
			if not list_contains(targets, target) then
				table.insert(targets, target)
			end
			i = i + 1
		end
	end
	
	-- throw spider eggs from old to new targets
	for i = #targets, 1, -1 do
		local p = targets[i]
		ret:AddDamage(SoundEffect(p1, "/enemy/spider_boss_1/attack_egg_launch"))
		local damage = SpaceDamage(p)
		damage.sPawn = "SpiderlingEgg1"
		ret.impact_sound = "enemy/spider_boss_1/attack_egg_land"
		ret:AddArtillery(p1, damage, "effects/shotup_spider.png", FULL_DELAY)
	end
	
	ret:AddDelay(0.1)
	
	-- queue eggs to hatch into spiders
	for i = #targets, 1, -1 do
		local p = targets[i]
		ret:AddScript(string.format([[
			local p = %s;
			local pawn = Board:GetPawn(p);
			if pawn then
				pawn:FireWeapon(p, 1);
			end
		]], p:GetString()))
	end
	
	return ret
end

return {
	load = function(self)
		modApi:addMissionUpdateHook(function(mission)
			local pawnId = Board:GetSelectedPawnId()
			
			if pawnId then
				local pawn = Board:GetPawn(pawnId)
				
				if pawn then
					if pawnId ~= selectedPawnId then
						resetTargets()
					end
					selectedPawnId = pawnId
					
					armedId = pawn:GetArmedWeaponId()
					if armedId ~= armedWeaponId then
						resetTargets()
					end
					armedWeaponId = armedId
					
				else
					resetAll()
				end
			else
				resetAll()
			end
		end)
	end
}
