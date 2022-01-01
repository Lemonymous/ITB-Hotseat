
local mod = {
	id = "lmn_hotseat",
	name = "Hotseat",
	version = "0.7.0-beta",
	modApiVersion = "2.5.4",
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

local components = {
	"modApiExt/modApiExt",
	"LApi/LApi",
	"libs/hotkey",
	"libs/bonusMission",
	"libs/bonusStore",
	"portraits",
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
	"compatibility/SpiderAtkB",
	"compatibility/vanilla_units",
	"compatibility/vanilla_missions",
	"compatibility/into_the_wild",
	"compatibility/bots_and_bugs",
	"compatibility/vek_hive_assault",
	"compatibility/evolved_vek",
	"compatibility/more_bosses",
}

function mod:init()
	
	-- initialize components
	for _, subpath in ipairs(components) do
		local name = self.scriptPath .. subpath
		local comp = require(name)
		
		if type(comp) == 'table' and comp.init then
			comp:init()
		end
	end
end

function mod:load(options, version)
	
	-- load components
	for _, subpath in ipairs(components) do
		local name = self.scriptPath .. subpath
		local comp = require(name)
		
		if type(comp) == 'table' and comp.load then
			comp:load(self, options, version)
		end
	end
end

return mod