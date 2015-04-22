-----------------------------------------------------------------------------
--Phageborn Convergence, Reglitch's Profile
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Golgox init function
local function golgoxInit()
	local golgox = "Golgox the Lifecrusher";
	
	ReStrat:createAlert("Next Convergence", 85, nil, ReStrat.color.purple, nil)
	
	--Destroy ALL alerts here for ALL middle phases
	local destroyAlerts = function()
		ReStrat:destroyAlert("Scatter Cooldown", false);
		ReStrat:destroyAlert("Demolish Cooldown", false);
		ReStrat:destroyAlert("Essence Rot Cooldown", false);
	end

	--Scatter
	local scatterCD = function() ReStrat:createAlert("Scatter Cooldown", 33, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(golgox, "Scatter", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, scatterCD);
	
	--Demolish
	local scatterCD = function() ReStrat:createAlert("Demolish Cooldown", 14, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(golgox, "Demolish", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, scatterCD);
	
	--Mid phase
	local golgoxPop = function() destroyAlerts(); ReStrat:createPop("Golgox Mid!", nil);  ReStrat:createAlert("Next Convergence", 85, nil, ReStrat.color.purple, nil) end
	ReStrat:createCastTrigger(golgox, "Teleport", golgoxPop);
	
	
	
end

--Terax init function
local function teraxInit()
	local terax = "Terax Blightweaver";
	
	--Destroy ALL alerts here for ALL middle phases
	local destroyAlerts = function()
		ReStrat:destroyAlert("Scatter Cooldown", false);
		ReStrat:destroyAlert("Demolish Cooldown", false);
		ReStrat:destroyAlert("Essence Rot Cooldown", false);
	end
	
	--Stitching Strain
	local stitchCD = function() ReStrat:createAlert("Stitching Strain Cooldown", 55, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(terax, "Stitching Strain", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, stitchCD);
	
	--Teleport
	local teraxPop = function() destroyAlerts(); ReStrat:createPop("Terax Mid!", nil); ReStrat:createAlert("Next Convergence", 85, nil, ReStrat.color.purple, nil) end
	ReStrat:createCastTrigger(terax, "Teleport", teraxPop);
	
	
end

--Vratorg init function
--This guy actually does sod all lol
local function vratorgInit()
	local vratorg = "Fleshmonger Vratorg";
	
	--Destroy ALL alerts here for ALL middle phases
	local destroyAlerts = function()
		ReStrat:destroyAlert("Scatter Cooldown", false);
		ReStrat:destroyAlert("Demolish Cooldown", false);
		ReStrat:destroyAlert("Essence Rot Cooldown", false);
	end
	
	--Teleport
	local vratorgPop = function() destroyAlerts(); ReStrat:createPop("Vratorg Mid!", nil); ReStrat:createAlert("Next Convergence", 85, nil, ReStrat.color.purple, nil) end
	ReStrat:createCastTrigger(vratorg, "Teleport", vratorgPop);
	
end

--Noxmind init function
local function noxmindInit()
	local noxmind = "Noxmind the Insidious";
	
	--Destroy ALL alerts here for ALL middle phases
	local destroyAlerts = function()
		ReStrat:destroyAlert("Scatter Cooldown", false);
		ReStrat:destroyAlert("Demolish Cooldown", false);
		ReStrat:destroyAlert("Essence Rot Cooldown", false);
	end
	
	--Essence Rot
	local erCD = function() ReStrat:createAlert("Essence Rot Cooldown", 17, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(noxmind, "Essence Rot", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, erCD);
	
	--Teleport
	local noxmindPop = function() destroyAlerts(); ReStrat:createPop("Noxmind Mid!", nil); ReStrat:createAlert("Next Convergence", 85, nil, ReStrat.color.purple, nil) end
	ReStrat:createCastTrigger(noxmind, "Teleport", noxmindPop);
	
end

--Ersoth Curseform init function
local function ersothInit()
	local ersoth = "Ersoth Curseform";
	
	--Destroy ALL alerts here for ALL middle phases
	local destroyAlerts = function()
		ReStrat:destroyAlert("Scatter Cooldown", false);
		ReStrat:destroyAlert("Demolish Cooldown", false);
		ReStrat:destroyAlert("Essence Rot Cooldown", false);
	end
	
	--Teleport
	local ersothInit = function() destroyAlerts(); ReStrat:createPop("Ersoth Mid!", nil); ReStrat:createAlert("Next Convergence", 85, nil, ReStrat.color.purple, nil) end
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
	fInitFunction = golgoxInit,
	strCategory  = "Genetic Archives",
	tModules = {
		["Scatter"] = {
			strLabel = "Scatter",
			bEnabled = true,
		},
		["Demolish"] = {
			strLabel = "Demolish",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Terax Blightweaver"] = {
	fInitFunction = teraxInit,
	strCategory  = "Genetic Archives",
	tModules = {
		["Stitching Strain"] = {
			strLabel = "Stitching Strain",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Fleshmonger Vratorg"] = {
	fInitFunction = vratorgInit,
	strCategory  = "Genetic Archives",
	tModules = {
	}
}

ReStrat.tEncounters["Noxmind the Insidious"] = {
	fInitFunction = noxmindInit,
	strCategory  = "Genetic Archives",
	tModules = {
		["Essence Rot"] = {
			strLabel = "Essence Rot",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Ersoth Curseform"] = {
	fInitFunction = ersothInit,
	strCategory  = "Genetic Archives",
	tModules = {
	}
}


