-----------------------------------------------------------------------------
--Experiment X-89, Reglitch's Profile
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Fight initiation function
local function experimentInit()

	--Create 10 second timer to run like fuark
	local loldead = function() if GameLib.GetPlayerUnit():IsDead() then Print("Really :D?") end end
	ReStrat:createAlert("Run!", 10, "Icon_SkillSbuff_higherjumpbuff", ReStrat.color.orange, loldead)
	
	--Resounding Shout
	local resoundingCD = function() ReStrat:createAlert("Resounding Shout Cooldown", 25, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert("Experiment X-89", "Resounding Shout", nil, "Icon_SkillShadow_UI_stlkr_onslaught", ReStrat.color.red, resoundingCD)
	
	--Repugnant Spew
	local repugnantCD = function() ReStrat:createAlert("Repugnant Spew Cooldown", 32, nil, ReStrat.color.orange, nil) end
	local repugnantChannel = function() ReStrat:createAlert("Repugnant Spew Active!", 6, "Icon_SkillPhysical_FountainOfBlood", ReStrat.color.red, repugnantCD) end
	ReStrat:createCastAlert("Experiment X-89", "Repugnant Spew", nil, "Icon_SkillShadow_UI_SM_mkrsmrk", ReStrat.color.red, repugnantChannel);
	
	--Corruption Globule (Small bomb)
	local corruptionCD = function() ReStrat:createAlert("Corruption Globule Cooldown", 5, nil, ReStrat.color.orange, nil) end
	ReStrat:createAuraAlert(nil, "Corruption Globule", nil, "Icon_SkillWarrior_Plasma_Pulse_Alt", corruptionCD);
	
	--Strain Bomb (Huge Bomb)
	local strainCD = function() ReStrat:createAlert("Strain Bomb Cooldown", 10, nil, ReStrat.color.orange, nil) end
	ReStrat:createAuraAlert(nil, "Strain Bomb", nil, "Icon_SkillStalker_Amplifide_Spike", strainCD);
	
	--Corruption Globule Pin
	ReStrat:createPinFromAura("Corruption Globule")
end

--Spam function, ONLY USE IF NECESSARY
local function profileDebugRepeat()
	
end



-----------------------------------------------------------------------------
--Encounter Packaging
-----------------------------------------------------------------------------
if not ReStrat.tEncounters then
	ReStrat.tEncounters = {}
end

--Profile Settings
ReStrat.tEncounters["Experiment X-89"] = {
	fInitFunction = experimentInit,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Genetic Archives",
	tModules = {
		["Resounding Shout"] = {
			strLabel = "Resounding Shout",
			bEnabled = true,
		},
		["Repugnant Spew"] = {
			strLabel = "Repugnant Spew",
			bEnabled = true,
		},
		["Corruption Globule"] = {
			strLabel = "Corruption Globule",
			bEnabled = true,
		},
		["Strain Bomb"] = {
			strLabel = "Strain Bomb",
			bEnabled = true,
		},
	}
}

