local hooks = {}

hooks.resetTurnHooks = {}
function hooks:addResetTurnHook(fn)
	assert(type(fn) == "function")
	table.insert(self.resetTurnHooks,fn)
end

hooks.gameLoadedHooks = {}
function hooks:addGameLoadedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.gameLoadedHooks,fn)
end

hooks.tileDirectionChangedHooks = {}
function hooks:addTileDirectionChangedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.tileDirectionChangedHooks,fn)
end

hooks.tileHighlightedHooks = {}
function hooks:addTileHighlightedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.tileHighlightedHooks,fn)
end

hooks.tileUnhighlightedHooks = {}
function hooks:addTileUnhighlightedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.tileUnhighlightedHooks,fn)
end

hooks.pawnTrackedHooks = {}
function hooks:addPawnTrackedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnTrackedHooks,fn)
end

hooks.pawnUntrackedHooks = {}
function hooks:addPawnUntrackedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnUntrackedHooks,fn)
end

hooks.pawnMoveStartHooks = {}
function hooks:addPawnMoveStartHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnMoveStartHooks,fn)
end

hooks.pawnMoveEndHooks = {}
function hooks:addPawnMoveEndHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnMoveEndHooks,fn)
end

hooks.vekMoveStartHooks = {}
function hooks:addVekMoveStartHook(fn)
	assert(type(fn) == "function")
	table.insert(self.vekMoveStartHooks,fn)
end

hooks.vekMoveEndHooks = {}
function hooks:addVekMoveEndHook(fn)
	assert(type(fn) == "function")
	table.insert(self.vekMoveEndHooks,fn)
end

hooks.pawnPositionChangedHooks = {}
function hooks:addPawnPositionChangedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnPositionChangedHooks,fn)
end

hooks.pawnUndoMoveHooks = {}
function hooks:addPawnUndoMoveHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnUndoMoveHooks,fn)
end

hooks.pawnSelectedHooks = {}
function hooks:addPawnSelectedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnSelectedHooks,fn)
end

hooks.pawnDeselectedHooks = {}
function hooks:addPawnDeselectedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnDeselectedHooks,fn)
end

hooks.pawnDamagedHooks = {}
function hooks:addPawnDamagedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnDamagedHooks,fn)
end

hooks.pawnHealedHooks = {}
function hooks:addPawnHealedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnHealedHooks,fn)
end

hooks.pawnKilledHooks = {}
function hooks:addPawnKilledHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnKilledHooks,fn)
end

hooks.pawnRevivedHooks = {}
function hooks:addPawnRevivedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnRevivedHooks,fn)
end

hooks.pawnIsFireHooks = {}
function hooks:addPawnIsFireHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnIsFireHooks, fn)
end

hooks.pawnIsAcidHooks = {}
function hooks:addPawnIsAcidHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnIsAcidHooks, fn)
end

hooks.pawnIsFrozenHooks = {}
function hooks:addPawnIsFrozenHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnIsFrozenHooks, fn)
end

hooks.pawnIsGrappledHooks = {}
function hooks:addPawnIsGrappledHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnIsGrappledHooks, fn)
end

hooks.pawnIsShieldedHooks = {}
function hooks:addPawnIsShieldedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnIsShieldedHooks, fn)
end

hooks.buildingDamagedHooks = {}
function hooks:addBuildingDamagedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.buildingDamagedHooks,fn)
end

hooks.buildingResistHooks = {}
function hooks:addBuildingResistHook(fn)
	assert(type(fn) == "function")
	table.insert(self.buildingResistHooks,fn)
end

hooks.buildingDestroyedHooks = {}
function hooks:addBuildingDestroyedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.buildingDestroyedHooks,fn)
end

hooks.buildingShieldHooks = {}
function hooks:addBuildingShieldHook(fn)
	assert(type(fn) == "function")
	table.insert(self.buildingShieldHooks,fn)
end

hooks.skillStartHooks = {}
function hooks:addSkillStartHook(fn)
	assert(type(fn) == "function")
	table.insert(self.skillStartHooks,fn)
end

hooks.skillEndHooks = {}
function hooks:addSkillEndHook(fn)
	assert(type(fn) == "function")
	table.insert(self.skillEndHooks,fn)
end

hooks.queuedSkillStartHooks = {}
function hooks:addQueuedSkillStartHook(fn)
	assert(type(fn) == "function")
	table.insert(self.queuedSkillStartHooks,fn)
end

hooks.queuedSkillEndHooks = {}
function hooks:addQueuedSkillEndHook(fn)
	assert(type(fn) == "function")
	table.insert(self.queuedSkillEndHooks,fn)
end

hooks.skillBuildHooks = {}
function hooks:addSkillBuildHook(fn)
	assert(type(fn) == "function")
	table.insert(self.skillBuildHooks,fn)
end

hooks.tipImageShownHooks = {}
function hooks:addTipImageShownHook(fn)
	assert(type(fn) == "function")
	table.insert(self.tipImageShownHooks,fn)
end

hooks.tipImageHiddenHooks = {}
function hooks:addTipImageHiddenHook(fn)
	assert(type(fn) == "function")
	table.insert(self.tipImageHiddenHooks,fn)
end

hooks.podDetectedHooks = {}
function hooks:addPodDetectedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.podDetectedHooks,fn)
end

hooks.podLandedHooks = {}
function hooks:addPodLandedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.podLandedHooks,fn)
end

hooks.podTrampledHooks = {}
function hooks:addPodTrampledHook(fn)
	assert(type(fn) == "function")
	table.insert(self.podTrampledHooks,fn)
end

hooks.podDestroyedHooks = {}
function hooks:addPodDestroyedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.podDestroyedHooks,fn)
end

hooks.podCollectedHooks = {}
function hooks:addPodCollectedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.podCollectedHooks,fn)
end

hooks.mostRecentResolvedHooks = {}
function hooks:addMostRecentResolvedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.mostRecentResolvedHooks,fn)
end

return hooks
