-----------------------------------------------------------------------------
--Phageborn Convergence, Reglitch's Profile
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Golgox init function
function ReStrat:golgoxInit(unit)
	local golgox = "Golgox the Lifecrusher";
	if unit ~= nil then ReStrat:trackHealth(unit, ReStrat.color.red) end
	
	ReStrat:createAlert("Next Convergence", 85, nil, ReStrat.color.purple, nil)
	
	--Destroy ALL alerts here for ALL middle phases
	local destroyAlerts = function()
		ReStrat:destroyAlert("Scatter Cooldown", false);
		ReStrat:destroyAlert("Demolish Cooldown", false);
		ReStrat:destroyAlert("Essence Rot Cooldown", false);
		ReStrat:destroyAlert("Equalize Cooldown", false);
	end
	
	--Scatter
	local scatterCD = function() ReStrat:createAlert("Scatter Cooldown", 33, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(golgox, "Scatter", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, scatterCD);
	
	--Demolish
	local demoCD = function() ReStrat:createAlert("Demolish Cooldown", 14, nil, ReStrat.color.orange, nil) end
	local demoPop = function() ReStrat:createPop("Demolish!"); ReStrat:Sound("Sound\\demolish.wav"); end
	ReStrat:createCastAlert(golgox, "Demolish", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, demoCD, demoPop);
	
	--Mid phase
	local golgoxPop = function() destroyAlerts(); ReStrat:createPop("Golgox Mid!", 5);  ReStrat:createAlert("Next Convergence", 85, nil, ReStrat.color.purple, nil) end
	ReStrat:createCastTrigger(golgox, "Teleport", golgoxPop);
	
	
	
end

--Terax init function
function ReStrat:teraxInit(unit)
	local terax = "Terax Blightweaver";
	if unit ~= nil then ReStrat:trackHealth(unit, ReStrat.color.red) end
	
	--Destroy ALL alerts here for ALL middle phases
	local destroyAlerts = function()
		ReStrat:destroyAlert("Scatter Cooldown", false);
		ReStrat:destroyAlert("Demolish Cooldown", false);
		ReStrat:destroyAlert("Essence Rot Cooldown", false);
		ReStrat:destroyAlert("Equalize Cooldown", false);
	end
	
	
	--Stitching Strain
	local stitchCD = function() ReStrat:createAlert("Stitching Strain Cooldown", 55, nil, ReStrat.color.yellow, nil) end
	ReStrat:createCastAlert(terax, "Stitching Strain", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, stitchCD);
	if ReStrat:IsActivated("Terax Blightweaver", "Stitching Strain") then
		ReStrat:createAlert("First Stitching Strain", 14.6, nil, ReStrat.color.yellow, nil)
	end
	
	--Teleport
	local teraxPop = function() destroyAlerts(); ReStrat:createPop("Terax Mid!", 5); ReStrat:createAlert("Next Convergence", 85, nil, ReStrat.color.purple, nil) end
	ReStrat:createCastTrigger(terax, "Teleport", teraxPop);
	
	
end

--Vratorg init function
--This guy actually does sod all lol
function ReStrat:vratorgInit(unit)
	local vratorg = "Fleshmonger Vratorg";
	if unit ~= nil then ReStrat:trackHealth(unit, ReStrat.color.red) end
	
	--Destroy ALL alerts here for ALL middle phases
	local destroyAlerts = function()
		ReStrat:destroyAlert("Scatter Cooldown", false);
		ReStrat:destroyAlert("Demolish Cooldown", false);
		ReStrat:destroyAlert("Essence Rot Cooldown", false);
		ReStrat:destroyAlert("Equalize Cooldown", false);
	end
	
	--Teleport
	local vratorgPop = function() destroyAlerts(); ReStrat:createPop("Vratorg Mid!", 5); ReStrat:createAlert("Next Convergence", 85, nil, ReStrat.color.purple, nil) end
	ReStrat:createCastTrigger(vratorg, "Teleport", vratorgPop);
	
end

--Noxmind init function
function ReStrat:noxmindInit(unit)
	local noxmind = "Noxmind the Insidious";
	if unit ~= nil then ReStrat:trackHealth(unit, ReStrat.color.red) end
	
	--Destroy ALL alerts here for ALL middle phases
	local destroyAlerts = function()
		ReStrat:destroyAlert("Scatter Cooldown", false);
		ReStrat:destroyAlert("Demolish Cooldown", false);
		ReStrat:destroyAlert("Essence Rot Cooldown", false);
		ReStrat:destroyAlert("Equalize Cooldown", false);
	end
	
	--Equalize
	local eq = function()
		ReStrat:createAlert("Equalize Cooldown", 35, nil, ReStrat.color.green, nil)
	end
	local eqpop = function()
		ReStrat:createPop("Equalize!", nil)
		ReStrat:Sound("Sound\\equalize.wav")
	end
	ReStrat:createCastAlert(noxmind, "Equalize", nil, "Icon_SkillMisc_UI_Housing_List", ReStrat.color.green, eq)
	ReStrat:createCastTrigger(noxmind, "Equalize", eqpop)
	
	--Essence Rot
	local erCD = function()
		ReStrat:createAlert("Essence Rot Cooldown", 17, nil, ReStrat.color.blue, nil)
	end
	local erpop = function()
		ReStrat:createPop("Waves incoming!", nil)
		ReStrat:Sound("Sound\\wavesinc.wav")
	end
	ReStrat:createCastAlert(noxmind, "Essence Rot", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, erCD);
	ReStrat:createCastTrigger(noxmind, "Essence Rot", erpop)
	
	
	--Teleport
	local noxmindPop = function() destroyAlerts(); ReStrat:createPop("Noxmind Mid!", 5); ReStrat:createAlert("Next Convergence", 85, nil, ReStrat.color.purple, nil) end
	ReStrat:createCastTrigger(noxmind, "Teleport", noxmindPop);
	
end

--Ersoth Curseform init function
function ReStrat:ersothInit(unit)
	local ersoth = "Ersoth Curseform";
	if unit ~= nil then ReStrat:trackHealth(unit, ReStrat.color.red) end
	
	--Destroy ALL alerts here for ALL middle phases
	local destroyAlerts = function()
		ReStrat:destroyAlert("Scatter Cooldown", false);
		ReStrat:destroyAlert("Demolish Cooldown", false);
		ReStrat:destroyAlert("Essence Rot Cooldown", false);
		ReStrat:destroyAlert("Equalize Cooldown", false);
	end
	
	--Teleport
	local ersothInit = function() destroyAlerts(); ReStrat:createPop("Ersoth Mid!", 5); ReStrat:createAlert("Next Convergence", 85, nil, ReStrat.color.purple, nil) end
	ReStrat:createCastTrigger(ersoth, "Teleport", ersothInit);

end

-----------------------------------------------------------------------------
--Encounter Packaging
-----------------------------------------------------------------------------
if not ReStrat.tEncounters then
	ReStrat.tEncounters = {}
end

--Profile Settings
ReStrat.tEncounters["Golgox the Lifecrusher"] = {
	startFunction = golgoxInit,
	strCategory  = "Genetic Archives",
	tModules = {
		["Scatter"] = {
			strLabel = "Scatter",
			bEnabled = false,
		},
		["Demolish"] = {
			strLabel = "Demolish",
			bEnabled = false,
		},
	}
}

ReStrat.tEncounters["Terax Blightweaver"] = {
	startFunction = teraxInit,
	strCategory  = "Genetic Archives",
	tModules = {
		["Stitching Strain"] = {
			strLabel = "Stitching Strain (Heal)",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Fleshmonger Vratorg"] = {
	startFunction = vratorgInit,
	strCategory  = "Genetic Archives",
	tModules = {
	}
}

ReStrat.tEncounters["Noxmind the Insidious"] = {
	startFunction = noxmindInit,
	strCategory  = "Genetic Archives",
	tModules = {
		["Essence Rot"] = {
			strLabel = "Essence Rot (Waves)",
			bEnabled = true,
		},
		["Equalize"] = {
			strLabel = "Equalize",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Ersoth Curseform"] = {
	startFunction = ersothInit,
	strCategory  = "Not Important",
	tModules = {
	}
}


