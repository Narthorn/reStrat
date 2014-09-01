-----------------------------------------------------------------------------
--Debug Profile, only works on easy mobs in Large Training Grounds
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Fight initiation function
local function kuralakInit()

	--Initial Generators
	local loldead = function() if GameLib.GetPlayerUnit():IsDead() then Print("Really :D?") end end
	ReStrat:createAlert("Avoid the Red!", 4, "Icon_SkillSbuff_higherjumpbuff", ReStrat.color.orange, loldead);
	
	--Eggs
	local chromosomeCD = function() ReStrat:createAlert("Egg Cooldown", 60, nil, ReStrat.color.orange, nil) end
	
	ReStrat:createCastAlert("Kuralak the Defiler", "Chromosome Corruption", nil, "Icon_SkillShadow_UI_stlkr_onslaught", ReStrat.color.red, chromosomeCD);
	ReStrat:createCastAlert("Kuralak the Defiler", "Cultivate Corruption", nil, "Icon_SkillShadow_UI_stlkr_onslaught", ReStrat.color.red, chromosomeCD);
	
	--Destroy Vanish Alerts
	local destroyAlerts = function()
		ReStrat:DestroyAlert("Vanish Cooldown", false);
		ReStrat:DestroyAlert("Vanish into Darkness", false);
	end
	
	ReStrat:createCastTrigger("Kuralak the Defiler", "Chromosome Corruption", destroyAlerts);
	
	--DNA Siphon
	local siphonCD = function() ReStrat:createAlert("DNA Siphon Cooldown", 60, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert("Kuralak the Defiler", "DNA Siphon", nil, "Icon_SkillSpellslinger_regenerative_pulse", ReStrat.color.red, siphonCD);
	
	--Outbreak
	local outbreakCD = function() ReStrat:createAlert("Outbreak Cooldown", 30, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert("Kuralak the Defiler", "Outbreak", nil, "Icon_SkillSpellslinger_regenerative_pulse", ReStrat.color.red, outbreakCD);
	
	--Vanish into Darkness
	local vidCD = function() ReStrat:createAlert("Vanish Cooldown", 60, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert("Kuralak the Defiler", "Vanish into Darkness", nil, "Icon_SkillMind_UI_espr_cnfs", ReStrat.color.red, vidCD);

	
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
ReStrat.tEncounters["Kuralak the Defiler"] = {
	fInitFunction = kuralakInit,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Genetic Archives",
	tModules = {
		["Chromosome Corruption"] = {
			strLabel = "Chromosome Corruption",
			bEnabled = true,
		},
		["Cultivate Corruption"] = {
			strLabel = "Cultivate Corruption",
			bEnabled = true,
		},
		["DNA Siphon"] = {
			strLabel = "DNA Siphon",
			bEnabled = true,
		},
		["Outbreak"] = {
			strLabel = "Outbreak",
			bEnabled = true,
		},
	}
}

