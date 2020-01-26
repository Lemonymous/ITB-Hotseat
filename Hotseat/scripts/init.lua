
local mod = {
	id = "lmn_hotseat",
	name = "Hotseat",
	version = "0.3.1",
	modApiVersion = "2.3.5",
	icon = "img/mod_icon.png",
	-- initialize mods that adds enemies first.
	requirements = {
		"lmn_into_the_wild",
		"lmn_bots_and_bugs",
		"lmn_more_bosses",
		"Wolf_EvolvedVek",
		"VekHiveAssault",
	}
}

local modUtils

function mod:metadata()
	modApi:addGenerationOption("option_hotseat_timeattack_mech", "Turn timer", "Available seconds during each player's turn.\n(Timer is paused while actions play out)", {values = {"Disabled",60,90,120,180}})
	modApi:addGenerationOption("option_hotseat_timeattack_vek", "Dynamic Vek timer", "Available seconds per Vek unit.", {values = {"Disabled",10,15,20,30,40}})
	modApi:addGenerationOption("option_hotseat_power_extra", "Power Extra", "Additional power after every mission", {values = {"Disabled",1,2,3,4,5}})
	modApi:addGenerationOption("option_hotseat_power_multi", "x Power", "Multiplies power gained from missions, rewards and store", {values = {"Disabled",2}})
	modApi:addGenerationOption("option_hotseat_power_add", "+ Power", "Additional power gained from missions, rewards and store", {values = {"Disabled",1,2}})
	modApi:addGenerationOption("option_hotseat_rep_add", "+ Rep", "Additional reputation gained from missions.\n(causes display error on some failed objectives)", {values = {"Disabled",1,2}})
	modApi:addGenerationOption("option_hotseat_core_add", "+ Core", "Additional cores gained from missions and pods", {values = {"Disabled",1,2}})
end

function mod:init()
	modUtils = require(self.scriptPath .."modApiExt/modApiExt")
	modUtils:init()
	
	tarmeans_dll_hotseat = require(self.scriptPath .."libs/CUtils")
	
	for _, v in ipairs{
		"libs/hotkey",
		"libs/bonusMission",
		"libs/bonusStore",
		"suppressEnemyTurn",
		"phases",
		"phases/spawn",
		"phases/playerturn",
		"phases/transition",
		"portraits",
		"resetTurn",
		"compatibility/vanilla_units",
		"compatibility/vanilla_missions",
		"compatibility/into_the_wild",
		"compatibility/bots_and_bugs",
		"compatibility/evolved_vek",
		"compatibility/vek_hive_assault",
		"compatibility/more_bosses",
	} do
		require(self.scriptPath .. v)
	end
end

function mod:load(options, version)
	modUtils:load(self, options, version)
	
	for _,v in ipairs{
		"libs/missionExt",
		"libs/teamTurn",
		"libs/moveUtils",
		"libs/selected",
		"libs/highlighted",
		"libs/scheduledMissionHook",
		"libs/menu",
		"phases",
		"phases/spawn",
		"phases/playerturn",
		"phases/transition",
		"suppressEnemyTurn",
		"weaponPreview/api",
		"timeAttack",
		"resetTurn",
		"rewardRebalance",
		"compatibility/evolved_vek",
		"compatibility/more_bosses",
	} do
		require(self.scriptPath .. v):load()
	end
end

return mod