-----------------------------------------------------------------------------
--- Elemental Pairs, Vim
-- this is a mess sorry I'll get around to cleaning it up someday
-----------------------------------------------------------------------------

local tMarkerSprites = {
	"IconSprites:Icon_Windows_UI_CRB_Marker_Bomb",
	"IconSprites:Icon_Windows_UI_CRB_Marker_Chicken",
	"IconSprites:Icon_Windows_UI_CRB_Marker_Ghost",
	"IconSprites:Icon_Windows_UI_CRB_Marker_Mask",
	"IconSprites:Icon_Windows_UI_CRB_Marker_Octopus",
	"IconSprites:Icon_Windows_UI_CRB_Marker_Pig",
	"IconSprites:Icon_Windows_UI_CRB_Marker_Toaster",
	"IconSprites:Icon_Windows_UI_CRB_Marker_UFO",
	"IconSprites:Icon_Windows_UI_CRB_Explorer",
	"IconSprites:Icon_Windows_UI_CRB_Colonist",
	"IconSprites:Icon_Windows_UI_CRB_Soldier",
	"IconSprites:Icon_Windows_UI_CRB_Scientist",
	"IconSprites:Icon_ItemWeapon_2H_Sword_01",
	"IconSprites:Icon_ItemMisc_UI_Item_Crystal",
}

local function EarthLogicInit() end
local function EarthAirInit() end
local function LifeLogicInit()
	local function LifeOrbs() ReStrat:createAlert("Next: Life Orbs", 2.5, nil, ReStrat.color.blue) end
	local function BlindingLight() ReStrat:createAlert("Next: Blinding Light", 9, nil, ReStrat.color.blue) end

	ReStrat:createCastAlert("Visceralus", "Blinding Light", nil, nil, ReStrat.color.blue, LifeOrbs)
	ReStrat:createCastAlert("Visceralus", "Life Orbs", nil, nil, ReStrat.color.blue, BlindingLight)

	ReStrat:createUnitTrigger("Wild Brambles", function()
		if not ReStrat.tEncounterVariables.WildBrambles then 
			ReStrat.tEncounterVariables.WildBrambles = true
			ReStrat:repeatAlert({strLabel = "Thorns", fRepeat = 30, strColor = ReStrat.color.red})
		end
	end)
	
	ReStrat:createUnitTrigger("Essence of Logic", function()
		ReStrat:destroyAlert("Thorns")
		ReStrat.tEncounterVariables.WildBrambles = false
	end)
end

-- Visceralus & Aileron 24/02/2015
local function LifeAirInit()
	
	-- Roots every 15s, twirls every other root

	local function ThornTrigger()
		if ReStrat.tEncounterVariables.fThorns then
			ReStrat.tEncounterVariables.fThorns()
			ReStrat.tEncounterVariables.fThorns = nil
		end	
	end
	
	local Twirls, Thorns
	Twirls = function() ReStrat:createAlert("Thorns & Twirls", 15, nil, ReStrat.color.red, Thorns) end
	Thorns = function() ReStrat:createAlert("Thorns"         , 15, nil, ReStrat.color.red, Twirls) end
	
	ReStrat.tEncounterVariables.fThorns = Twirls
	ReStrat:createUnitTrigger("Wild Brambles", ThornTrigger)
	
	-- Midphase every 90s, lasts 35s, need to reactivate root timer before midphase is over
	
	local MidPhase, DpsPhase
	DpsPhase = function()
		ReStrat.tEncounterVariables.fThorns = Twirls
		ReStrat:createAlert("Midphase", 90.5, "Icon_SkillStalker_Maelstrom", ReStrat.color.purple, MidPhase)
	end
	MidPhase = function()
		ReStrat:destroyAllAlerts()
		ReStrat.tEncounterVariables.fThorns = nil
		ReStrat:createAlert("Midphase", 34.5, "Icon_SkillStalker_Maelstrom", ReStrat.color.purple, DpsPhase)
	end
		
	ReStrat:createAlert("Midphase", 90, "Icon_SkillStalker_Maelstrom", ReStrat.color.purple, MidPhase)
			
	-- not sure about life orbs/discoball cooldowns, alternating casts every 12s is a rough approximation
	
	local function LifeOrbs() ReStrat:createAlert("Next: Life Orbs", 2.5, nil, ReStrat.color.blue) end
	local function BlindingLight() ReStrat:createAlert("Next: Blinding Light", 9, nil, ReStrat.color.blue) end
	ReStrat:createCastAlert("Visceralus", "Blinding Light", nil, nil, ReStrat.color.blue, LifeOrbs)
	ReStrat:createCastAlert("Visceralus", "Life Orbs", nil, nil, ReStrat.color.blue, BlindingLight)
	
	-- Tree lines
	
	ReStrat:createUnitTrigger("Lifekeeper", function(unit) ReStrat.DrawLib:UnitLine(GameLib.GetPlayerUnit(), unit) end)
	
	ReStrat:createPinFromAura("Lightning Strike", "abilities:sprAbility_CapEnd3")
	
	--ReStrat:createAlert("Enrage", 420, nil, ReStrat.color.red, nil)
end

local function EarthFireInit() 
	local function MidPhase()
		ReStrat:createAlert("Midphase", 90, "Icon_SkillStalker_Maelstrom", ReStrat.color.blue)
	end
	
	ReStrat:OnDatachron("The lava begins to rise through the floor!", function()
		ReStrat:createAlert("Midphase", 30, "Icon_SkillStalker_Maelstrom", ReStrat.color.red, MidPhase)
	end)
	
	MidPhase()
	ReStrat:createAlert("Enrage", 420, nil, ReStrat.color.red, nil)
end

-- Hydroflux & Mnemesis 15/02/2015
local function WaterLogicInit() 
	local function MidPhase(timer)
		ReStrat:createAlert("Midphase", timer, "Icon_SkillStalker_Maelstrom", ReStrat.color.blue, nil)
	end
	
	ReStrat:createPinFromAura("Data Disruptor")
	
	MidPhase(75)
	ReStrat:createCastAlert("Mnemesis", "Circuit Breaker", nil, nil, ReStrat.color.green, function() MidPhase(83) end)
	
	--ReStrat:createAlert("Enrage", 420, nil, ReStrat.color.red, nil)
end

-- Hydroflux & Aileron 05/01/2015, 31/01/2015
local function WaterAirInit() 
	--local function IceTombs(timer)
	--	ReStrat:createAlert("Ice Tombs", timer, "Icon_SkillIce_UI_srcr_iceshrds", ReStrat.color.blue, function()
	--		ReStrat.tEncounterVariables.IceTombs = false
	--		ReStrat:createAlert("Ice Tombs", 30, "Icon_SkillIce_UI_srcr_iceshrds", ReStrat.color.blue, nil)
	--	end)
	--	ReStrat.tEncounterVariables.IceTombs = true
	--end

	--ReStrat.tEncounterVariables.nMidPhases = 0
	ReStrat:createCastAlert("Hydroflux", "Glacial Icestorm", nil, "Icon_SkillStalker_Maelstrom", ReStrat.color.green, function()
		ReStrat:createAlert("Midphase (approx)", 65, "Icon_SkillStalker_Maelstrom", ReStrat.color.blue, nil)
		--IceTombs(2)
	end)
	
	--ReStrat:createCastTrigger("Hydroflux", "Sinkhole", function()
	--	if ReStrat.tEncounterVariables.IceTombs then
	--		ReStrat:destroyAlert("Ice Tombs")
	--		IceTombs(10)
	--	end
	--end)
	
	ReStrat:createAlert("Midphase", 60, "Icon_SkillStalker_Maelstrom", ReStrat.color.blue, nil)
	--ReStrat:createAlert("Ice Tombs", 30, "Icon_SkillIce_UI_srcr_iceshrds", ReStrat.color.blue, nil)
	ReStrat:createAlert("Enrage", 420, nil, ReStrat.color.red, nil)
end

-- Hydroflux & Pyrobane 18/12/2014, 24/02/2015
local function WaterFireInit() 
	local tDebuffTimeout = true
	local function WaterFireDebuff()
		if tDebuffTimeout then
			tDebuffTimeout = false
			ReStrat:createPop("GTFO GTFO GTFO GTFO GTFO GTFO\nGTFO GTFO GTFO GTFO GTFO GTFO", nil, "Sound\\quack.wav")
			ReStrat:createAlert("Heat Stroke / Hypothermia", 10, nil, ReStrat.color.green, function()
				tDebuffTimeout = true
			end)
			ReStrat:createAlert("Next swap (approx)", 30, nil, ReStrat.color.blue, nil)
		end
	end
	
	ReStrat:createPinFromAura("Heat Stroke", "Crafting_RunecraftingSprites:sprRunecrafting_Fire_Colored")
	ReStrat:createPinFromAura("Hypothermia", "Crafting_RunecraftingSprites:sprRunecrafting_Water_Colored")
	
	ReStrat:createAuraAlert(nil, "Heat Stroke", 0, nil, WaterFireDebuff) 
	ReStrat:createAuraAlert(nil, "Hypothermia", 0, nil, WaterFireDebuff) 

	ReStrat:createAlert("Swap (approx)", 30, nil, ReStrat.color.blue, nil)
	ReStrat:createAlert("Enrage", 510, nil, ReStrat.color.red, nil)
end

-- Visceralus & Pyrobane, 22/01/2014
local function LifeFireInit()

	ReStrat.tEncounterVariables.tWavesParams = {
		strLabel = "Wave 1", fRepeat = 10, strColor = ReStrat.color.red,
		fCallback = function(nWaves) ReStrat.tEncounterVariables.tWavesParams.strLabel = "Wave "..nWaves end}
	local function Midphase() 
		ReStrat:repeatAlert({strLabel = "Circles", fDelay = 5, fRepeat = 10, strColor = ReStrat.color.blue})
		ReStrat:repeatAlert(ReStrat.tEncounterVariables.tWavesParams)
	end
	
	local function MidphaseEndCheck()
		for id, tUnit in ReStrat.tUnits do --FIXME no longer tracking all units
			if tUnit:IsValid() and tUnit.strName == "Essence of Life" and tUnit.bActive == true then
				return -- still one orb up, no midphase end
			end
		end
		-- If we reach this, all orbs are dead, clean up and start another midphase timer
		ReStrat:destroyAlert("Circles")
		ReStrat:destroyAlert(tWavesParams.strName)
		ReStrat:createAlert("Midphase", 90, nil, ReStrat.color.green, Midphase)
	end

	
	ReStrat:createAlert("Midphase", 90, nil, ReStrat.color.green, Midphase)
	--ReStrat:createUnitTrigger("Essence of Life", nil, MidphaseEndCheck)
	ReStrat:createPinFromAura("Primal Entanglement")
end

---

ReStrat.tEncounters["Megalith"] = {
	fInitFunction = function()
		ReStrat:OnDatachron("The ground shudders beneath Megalith!", function() 
			ReStrat:createPop("JUMP JUMP JUMP JUMP JUMP JUMP\nJUMP JUMP JUMP JUMP JUMP JUMP", nil, "Sound\\quack.wav")
		end)
		ReStrat:createCastAlert("Megalith", "Rockfall", nil, "Icon_SkillPhysical_UI_wr_smsh", ReStrat.color.red, nil)
		
		ReStrat.tEncounterVariables.Megalith = true
		if ReStrat.tEncounterVariables.Mnemesis then EarthLogicInit() end
		if ReStrat.tEncounterVariables.Aileron  then EarthAirInit() end
		if ReStrat.tEncounterVariables.Pyrobane then EarthFireInit() end
	end,
	strCategory = "Datascape",
	trackHealth = ReStrat.color.orange,
	tModules = {
		["Rockfall"] = {
			strLabel = "Rockfall",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Hydroflux"] = {
	fInitFunction = function()
		ReStrat.tEncounterVariables.Hydroflux = true
		if ReStrat.tEncounterVariables.Mnemesis then WaterLogicInit() end
		if ReStrat.tEncounterVariables.Aileron  then WaterAirInit() end
		if ReStrat.tEncounterVariables.Pyrobane then WaterFireInit() end
	end,
	strCategory = "Datascape",
	trackHealth = ReStrat.color.purple,
	tModules = {
		["Glacial Icestorm"] = {
			strLabel = "Glacial Icestorm",
			bEnabled = true,
		},
		["Sinkhole"] = {
			strLabel = "Sinkhole",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Visceralus"] = {
	fInitFunction = function()
		ReStrat.tEncounterVariables.Visceralus = true
		if ReStrat.tEncounterVariables.Mnemesis then LifeLogicInit() end
		if ReStrat.tEncounterVariables.Aileron  then LifeAirInit() end
		if ReStrat.tEncounterVariables.Pyrobane then LifeFireInit() end
	end,
	strCategory = "Datascape",
	trackHealth = ReStrat.color.green,
	tModules = {
		["Primal Entanglement"] = {
			strLabel = "Primal Entanglement",
			bEnabled = true,
		},
		["Annihilate!"] = {
			strLabel = "Annihilate!",
			bEnabled = true,
		},
		["Blinding Light"] = {
			strLabel = "Blinding Light",
			bEnabled = true,
		},
		["Life Orbs"] = {
			strLabel = "Life Orbs",
			bEnabled = true,
		},
	},
}

ReStrat.tEncounters["Mnemesis"] = {
	fInitFunction = function()
		ReStrat:createCastAlert("Mnemesis", "Defragment", nil, "Icon_SkillMind_UI_espr_rpls", ReStrat.color.green, nil)
		ReStrat:createPinFromAura("Snake Logic")
		ReStrat:createPinFromAura("Snake Snack")
		
		ReStrat.tEncounterVariables.Mnemesis = true
		if ReStrat.tEncounterVariables.Megalith   then EarthLogicInit() end
		if ReStrat.tEncounterVariables.Hydroflux  then WaterLogicInit() end
		if ReStrat.tEncounterVariables.Visceralus then LifeLogicInit() end
	end,
	strCategory = "Datascape",
	trackHealth = ReStrat.color.green,
	tModules = {
		["Defragment"] = {
			strLabel = "Defragment",
			bEnabled = true,
		},
		["Circuit Breaker"] = {
			strLabel = "Circuit Breaker",
			bEnabled = true,
		},
	}
}

-- Aileron 27/10/2014
ReStrat.tEncounters["Aileron"] = {
	fInitFunction = function()
		ReStrat:createCastAlert("Aileron", "Walls of Wind", nil, "Icon_SkillNature_UI_srcr_dstdvl", ReStrat.color.blue, function()
			ReStrat:createAlert("[Aileron] Wind Shield", 22, "Icon_SkillNature_UI_srcr_dstdvl", ReStrat.color.blue, nil)
		end)
		
		ReStrat:createPinFromAura("Twirl", nil, "BK3:UI_BK3_StoryPanelAlert_Icon")
		
		ReStrat.tEncounterVariables.Aileron = true
		if ReStrat.tEncounterVariables.Megalith   then EarthAirInit() end
		if ReStrat.tEncounterVariables.Hydroflux  then WaterAirInit() end
		if ReStrat.tEncounterVariables.Visceralus then LifeAirInit() end
	end,
	strCategory = "Datascape",
	trackHealth = ReStrat.color.blue,
	tModules = {
		["Walls of Wind"] = {
			strLabel = "Walls of Wind",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Pyrobane"] = {
	fInitFunction = function()
		ReStrat.tEncounterVariables.Pyrobane = true
		if ReStrat.tEncounterVariables.Megalith   then EarthFireInit() end
		if ReStrat.tEncounterVariables.Hydroflux  then WaterFireInit() end
		if ReStrat.tEncounterVariables.Visceralus then LifeFireInit() end
	end,
	strCategory = "Datascape",
	trackHealth = ReStrat.color.red,
	tModules = {}
}