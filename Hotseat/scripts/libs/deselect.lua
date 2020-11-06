
-- bad functions to use on mechs since they change weapons during a run.
-- the code here is very simple and just checks the base pawn for weapons.
local this = {}

function this:pawn(pawn)
	if pawn:IsMech() then return end -- prevent mechs from running this code.
	
	local data = _G[pawn:GetType()]
	local weapons = #data.SkillList
	pawn:AddWeapon("lmn_Hotseat_SkillEmpty")
	pawn:FireWeapon(pawn:GetSpace(), weapons + 1)
	Pawn:RemoveWeapon(weapons + 1)
end

lmn_Hotseat_SkillEmpty = Skill:new{LaunchSound = ""}
function lmn_Hotseat_SkillEmpty:GetTargetArea(p)
	local ret = PointList()
	ret:push_back(p)
	return ret
end

function lmn_Hotseat_SkillEmpty:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	ret:AddScript("")
	return ret
end

return this