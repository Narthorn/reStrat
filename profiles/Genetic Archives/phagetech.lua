-----------------------------------------------------------------------------
--Phagetech, Reglitch's Profile
--Holy fuck this one was a bitch to write
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Init for the commander
local function commanderInit()
	local commander = "Phagetech Commander";

	--Forced Production
	local interruptPop = function() ReStrat:createPop("Forced Production!", nil) end
	local prodCD = function() ReStrat:createAlert("Forced Production Cooldown", 30, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(commander, "Forced Production", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, prodCD);
	ReStrat:createCastTrigger(commander, "Forced Production", interruptPop);
	
	--Destruction Protocol
	local dpCD = function() ReStrat:createAlert("Destruction Protocol Cooldown", 12, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(commander, "Destruction Protocol", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, dpCD);
	
	--Powering Up
	local malicious = function() ReStrat:createAlert("Malicious Uplink!", 5, nil, ReStrat.color.red, nil) end
	ReStrat:createCastTrigger(commander, "Powering Up", malicious);
	
	--Destroy Frames Powering Down
	local destroyFrames = function() ReStrat:destroyAlert("Forced Production Cooldown"); ReStrat:destroyAlert("Destruction Protocol Cooldown"); end
	ReStrat:createCastTrigger(commander, "Powering Down", destroyFrames);
	
end

--Init for the augmentor
local function augmentorInit()
	local augmentor = "Phagetech Augmentor";
	
	--Phagetech Borer
	local borerCD = function() ReStrat:createAlert("Phagetech Borer Cooldown", 12, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(augmentor, "Phagetech Borer", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, borerCD);

	--Summon Repairbot
	local rbCD = function() ReStrat:createAlert("Summon Repairbot Cooldown", 12, nil, ReStrat.color.orange, nil); ReStrat:createPop("Repair Bot!", nil) end
	ReStrat:createCastAlert(augmentor, "Summon Repairbot", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, rbCD);
	
	--Destroy Frames Powering Down
	local destroyFrames2 = function() ReStrat:destroyAlert("Phagetech Borer Cooldown"); ReStrat:destroyAlert("Summon Repairbot Cooldown"); end
	ReStrat:createCastTrigger(augmentor, "Powering Down", destroyFrames2);
	
end

--Init for the protector
local function protectorInit()
	local protector = "Phagetech Protector";
	
	--Pulse-A-Tron Wave
	local waves = function() ReStrat:createPop("Waves inc!", nil) end
	local patCD = function() ReStrat:createAlert("Pulse-A-Tron Wave Cooldown", 12, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(protector, "Pulse-A-Tron Wave", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, borerCD);
	ReStrat:createCastTrigger(protector, "Pulse-A-Tron Wave", waves);
	
	--Gravitational Singularity
	local singularity = function() ReStrat:createAlert("Gravitational Singularity!", 4, nil, ReStrat.color.red, nil) end
	ReStrat:createCastTrigger(protector, "Powering Up", singularity);
	
	--Destroy Frames Powering Down
	local destroyFrames3 = function() ReStrat:destroyAlert("Pulse-A-Tron Wave Cooldown") end
	ReStrat:createCastTrigger(protector, "Powering Down", destroyFrames3);
	
end

--Init for the fabricator
local function fabricatorInit()
	local fabricrator = "Phagetech Fabricator";

	--Destructobots
	local dbCD = function() ReStrat:createAlert("Summon Destructobot Cooldown", 12, nil, ReStrat.color.orange, nil); ReStrat:createPop("Destructobot!", nil) end
	ReStrat:createCastAlert(fabricator, "Summon Destructobot", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, dbCD);
	
	--Technophage Catalyst
	local singularity = function() ReStrat:createAlert("Technophage Catalyst!", 10, nil, ReStrat.color.red, nil) end
	ReStrat:createCastTrigger(fabricator, "Powering Up", singularity);
	
	--Destroy Frames Powering Down
	local destroyFrames4 = function() ReStrat:destroyAlert("Summon Destructobot Cooldown") end
	ReStrat:createCastTrigger(fabricator, "Powering Down", destroyFrames4);
	
end

-----------------------------------------------------------------------------
--Encounter Packaging
-----------------------------------------------------------------------------
if not ReStrat.tEncounters then
	ReStrat.tEncounters = {}
end

--Profile Settings
ReStrat.tEncounters["Phagetech Commander"] = {
	fInitFunction = commanderInit,
	strCategory  = "Genetic Archives",
	tModules = {
		["Forced Production"] = {
			strLabel = "Forced Production",
			bEnabled = true,
		},
		["Destruction Protocol"] = {
			strLabel = "Destruction Protocol",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Phagetech Augmentor"] = {
	fInitFunction = augmentorInit,
	strCategory  = "Genetic Archives",
	tModules = {
		["Summon Repairbot"] = {
			strLabel = "Summon Repairbot",
			bEnabled = true,
		},
		["Phagetech Borer"] = {
			strLabel = "Phagetech Borer",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Phagetech Protector"] = {
	fInitFunction = protectorInit,
	strCategory  = "Genetic Archives",
	tModules = {
		["Pulse-A-Tron Wave"] = {
			strLabel = "Pulse-A-Tron Wave",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Phagetech Fabricator"] = {
	fInitFunction = fabricatorInit,
	strCategory  = "Genetic Archives",
	tModules = {
		["Summon Destructobot"] = {
			strLabel = "Summon Destructobot",
			bEnabled = true,
		},
	}
}
