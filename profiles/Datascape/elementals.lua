-----------------------------------------------------------------------------
--- Elemental Pairs, Vim & Chill
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

local function EarthLogicInit()
	ReStrat:createPinFromAura("Snake Snack")
	ReStrat:createAuraAlert(nil, "Snake Snack", nil, "Icon_SkillWarrior_Plasma_Pulse_Alt", nil)
	--function ReStrat:createAuraAlert(strUnit, strAuraName, duration_i, icon_i, fCallback_i)
end

local function EarthAirInit()

	local tornados = function()
		tTornado = {}
		tTornado.strLabel = "Next tornado"
		tTornado.fDelay = 17.2
		tTornado.fDuration = 5
		tTornado.strColor = ReStrat.color.green
		tTornado.strIcon = "Icon_SkillSbuff_gasdamovertime"
	
		ReStrat:repeatAlert(tTornado, 999)
	end
	local supercell = function()
		ReStrat:destroyAllAlerts()
		
		tTornado = {}
		tTornado.strLabel = "Next tornado"
		tTornado.fDelay = 17.2
		tTornado.fDuration = 5
		tTornado.strColor = ReStrat.color.green
		tTornado.strIcon = "Icon_SkillSbuff_gasdamovertime"
	
		ReStrat:repeatAlert(tTornado, 999)
	end
	ReStrat:createAlert("First tornado", 12.4, nil, ReStrat.color.green, tornados)
	ReStrat:createCastAlert("Aileron", "Supercell", nil, "Icon_SkillStalker_Maelstrom", ReStrat.color.green, supercell)
end

local function EarthFireInit() 
	ReStrat:createAlert("Enrage", 420, nil, ReStrat.color.red, nil)
end

-----
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
	
	ReStrat:createUnitTrigger("Lifekeeper", function(unit) DrawLib:UnitLine(GameLib.GetPlayerUnit(), unit) end)
	
	ReStrat:createPinFromAura("Lightning Strike", "abilities:sprAbility_CapEnd3")
	
	--ReStrat:createAlert("Enrage", 420, nil, ReStrat.color.red, nil)
end

local function LifeFireInit()

	ReStrat.tEncounterVariables.tWavesParams = {
		strLabel = "Wave 1", fRepeat = 10, strColor = ReStrat.color.red,
		fCallback = function(nWaves) ReStrat.tEncounterVariables.tWavesParams.strLabel = "Wave "..nWaves end}
	local function Midphase() 
		ReStrat:repeatAlert({strLabel = "Circles", fDelay = 5, fRepeat = 10, strColor = ReStrat.color.blue})
		ReStrat:repeatAlert(ReStrat.tEncounterVariables.tWavesParams)
	end
	
	local function MidphaseEndCheck()
		for id, tUnit in ReStrat.tUnits do
			if tUnit.strName == "Essence of Life" and tUnit.bActive == true then
				return -- still one orb up, no midphase end
			end
		end
		-- If we reach this, all orbs are dead, clean up and start another midphase timer
		ReStrat:destroyAlert("Circles")
		ReStrat:destroyAlert(tWavesParams.strName)
		ReStrat:createAlert("Midphase", 90, nil, ReStrat.color.green, Midphase)
	end
	
	ReStrat:createAlert("Midphase", 90, nil, ReStrat.color.green, Midphase)
	ReStrat:onUnitDeath("Essence of Life", MidphaseEndCheck)
	ReStrat:createPinFromAura("Primal Entanglement")
end
-----

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

local function WaterAirInit() 
	ReStrat:createCastAlert("Hydroflux", "Glacial Icestorm", nil, "Icon_SkillStalker_Maelstrom", ReStrat.color.green, function()
		ReStrat:createAlert("Midphase", 65, "Icon_SkillStalker_Maelstrom", ReStrat.color.blue, nil)
	end)
	
	ReStrat:createAlert("Midphase", 60, "Icon_SkillStalker_Maelstrom", ReStrat.color.blue, nil)
	ReStrat:createAlert("Enrage", 420, nil, ReStrat.color.red, nil)
end

local function WaterFireInit() 
	local tDebuffTimeout = true
	local function WaterFireDebuff()
		if tDebuffTimeout then
			tDebuffTimeout = false
			ReStrat:createPop("GTFO GTFO GTFO GTFO GTFO GTFO\nGTFO GTFO GTFO GTFO GTFO GTFO", nil)
			--Sound.PlayFile("Sound\\quack.wav")
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
	ReStrat:createAlert("Enrage", 480, nil, ReStrat.color.red, nil)
end


------
function ReStrat:waterInit()

	ReStrat.tEncounterVariables.Hydroflux = true
	
	if ReStrat.tEncounterVariables.Mnemesis then WaterLogicInit() end
	if ReStrat.tEncounterVariables.Aileron  then WaterAirInit() end
	if ReStrat.tEncounterVariables.Pyrobane then WaterFireInit() end
end

function ReStrat:lifeInit()

	ReStrat.tEncounterVariables.Visceralus = true
	
	if ReStrat.tEncounterVariables.Mnemesis then LifeLogicInit() end
	if ReStrat.tEncounterVariables.Aileron  then LifeAirInit() end
	if ReStrat.tEncounterVariables.Pyrobane then LifeFireInit() end
end

function ReStrat:fireInit()

	ReStrat.tEncounterVariables.Pyrobane = true
	
	if ReStrat.tEncounterVariables.Megalith then EarthFireInit() end
	if ReStrat.tEncounterVariables.Hydroflux  then WaterFireInit() end
	if ReStrat.tEncounterVariables.Visceralus then LifeFireInit() end
end

function ReStrat:logicInit()

	ReStrat.tEncounterVariables.Mnemesis = true
	
	if ReStrat.tEncounterVariables.Megalith then EarthLogicInit() end
	if ReStrat.tEncounterVariables.Hydroflux  then WaterLogicInit() end
	if ReStrat.tEncounterVariables.Visceralus then LifeLogicInit() end
end

function ReStrat:earthInit()
	local jumpquake = function()
		ReStrat:createPop("JUMP JUMP JUMP\nJUMP JUMP JUMP", nil)
		ReStrat:Sound("Sound\\jumpnow.wav")
	end
	ReStrat:OnDatachron("The ground shudders beneath Megalith!", jumpquake)
	ReStrat:createCastAlert("Megalith", "Rockfall", nil, "Icon_SkillPhysical_UI_wr_smsh", ReStrat.color.red, nil)
	ReStrat.tEncounterVariables.Megalith = true
	
	if ReStrat.tEncounterVariables.Mnemesis then EarthLogicInit() end
	if ReStrat.tEncounterVariables.Aileron  then EarthAirInit() end
	if ReStrat.tEncounterVariables.Pyrobane then EarthFireInit() end
end

function ReStrat:airInit()
	local wallofwind = function()
		ReStrat:createPop("Wind Wall!")
		ReStrat:createAlert("[Aileron] Wind Wall", 21, "Icon_SkillNature_UI_srcr_dstdvl", ReStrat.color.red, nil)
	end
	ReStrat:createCastAlert("Aileron", "Walls of Wind", nil, "Icon_SkillNature_UI_srcr_dstdvl", ReStrat.color.red, wallofwind)
	ReStrat:createPinFromAura("Twirl")
	ReStrat.tEncounterVariables.Aileron = true
	
	if ReStrat.tEncounterVariables.Megalith   then EarthAirInit() end
	if ReStrat.tEncounterVariables.Hydroflux  then WaterAirInit() end
	if ReStrat.tEncounterVariables.Visceralus then LifeAirInit() end
end


ReStrat.tEncounters["Megalith"] = {
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
	strCategory = "Datascape",
	trackHealth = ReStrat.color.purple,
	tModules = {
		["Glacial Icestorm"] = {
			strLabel = "Glacial Icestorm",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Visceralus"] = {
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
	},
}

ReStrat.tEncounters["Mnemesis"] = {
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
	strCategory = "Datascape",
	trackHealth = ReStrat.color.blue,
	tModules = {
		["Walls of Wind"] = {
			strLabel = "Walls of Wind",
			bEnabled = true,
		},
		["Supercell"] = {
			strLabel = "Supercell",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Pyrobane"] = {
	strCategory = "Datascape",
	trackHealth = ReStrat.color.red,
	tModules = {}
}	