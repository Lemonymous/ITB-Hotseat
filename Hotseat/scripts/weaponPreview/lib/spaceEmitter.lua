
-- returns a SpaceDamage object creating an emitter
return function(loc, emitter)
	local fx = SkillEffect()
	fx:AddEmitter(loc, emitter)
	return fx.effect:index(1)
end