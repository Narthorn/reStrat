-----------------------------------------------------------------------------
--Phagetech, Reglitch's Profile
--Holy fuck this one was a bitch to write
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Init for the commander
function ReStrat:commanderInit()
	local commander = "Phagetech Commander";
	commanderpull = true
	--Forced Production
	local interruptPop = function() ReStrat:createPop("Forced Production!", nil); ReStrat:Sound("Sound\\forcedprod.wav"); end
	local prodCD = function() ReStrat:createAlert("Forced Production Cooldown", 30, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(commander, "Forced Production", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, prodCD);
	ReStrat:createCastTrigger(commander, "Forced Production", interruptPop);
	
	--Destruction Protocol
	local dpCD = function() ReStrat:createAlert("Destruction Protocol Cooldown", 12, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(commander, "Destruction Protocol", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, dpCD);
	
	--Powering Up
	local augmentorphase = function()
		if commanderpull == true then
			ReStrat:createAlert("Power up(Augmentor Next)", 20, nil, ReStrat.color.purple, nil)
		else
			ReStrat:createAlert("Power up(Augmentor Next)", 60, nil, ReStrat.color.purple, nil)
		end
	end
		
	local malicious = function()
		ReStrat:createAlert("Malicious Uplink!", 5, nil, ReStrat.color.red, nil)
	end
	ReStrat:createAuraAlert(GameLib.GetPlayerUnit():GetName(), "Malicious Uplink", nil, "Icon_SkillFire_UI_srcr_frybrrg", nil)
	
	--ReStrat:createCastTrigger(commander, "Powering Up", malicious);
	ReStrat:OnDatachron("Phagetech Commander is now active!", malicious)
	
	--Destroy Frames Powering Down
	local destroyFrames = function() ReStrat:destroyAlert("Forced Production Cooldown"); ReStrat:destroyAlert("Destruction Protocol Cooldown"); end
	ReStrat:createCastTrigger(commander, "Powering Down", destroyFrames);
	
end

--Init for the augmentor
function ReStrat:augmentorInit()
	local augmentor = "Phagetech Augmentor";
	
	--Phagetech Borer
	local borerCD = function() ReStrat:createAlert("Phagetech Borer Cooldown", 12, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(augmentor, "Phagetech Borer", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, borerCD);

	--Summon Repairbot
	local rbCD = function() ReStrat:createAlert("Summon Repairbot Cooldown", 12, nil, ReStrat.color.orange, nil); ReStrat:createPop("Repair Bot!", nil); ReStrat:Sound("Sound\\repairbot.wav"); end
	ReStrat:createCastAlert(augmentor, "Summon Repairbot", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, rbCD);
	
	--Destroy Frames Powering Down
	local destroyFrames2 = function() ReStrat:destroyAlert("Phagetech Borer Cooldown"); ReStrat:destroyAlert("Summon Repairbot Cooldown"); end
	ReStrat:createCastTrigger(augmentor, "Powering Down", destroyFrames2);
	
	local augmentorup = function()
		ReStrat:createAlert("Power up(Protector Next)", 60, nil, ReStrat.color.purple, nil)
	end
	ReStrat:OnDatachron("Phagetech Augmentor is now active!", augmentorup)
end

--Init for the protector
function ReStrat:protectorInit()
	local protector = "Phagetech Protector";
	
	--Pulse-A-Tron Wave
	local waves = function() ReStrat:createPop("Waves inc!", nil); ReStrat:Sound("Sound\\wavesinc.wav") ; end
	local patCD = function() ReStrat:createAlert("Pulse-A-Tron Wave Cooldown", 12, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(protector, "Pulse-A-Tron Wave", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, borerCD);
	ReStrat:createCastTrigger(protector, "Pulse-A-Tron Wave", waves);
	
	--Gravitational Singularity
	local singularity = function() ReStrat:createAlert("Gravitational Singularity!", 4, nil, ReStrat.color.red, nil); ReStrat:createAlert("Power up(Fabricator Next)", 60, nil, ReStrat.color.purple, nil); end
	--ReStrat:createCastTrigger(protector, "Powering Up", singularity);
	ReStrat:OnDatachron("Phagetech Protector is now active!", singularity)
	
	--Destroy Frames Powering Down
	local destroyFrames3 = function() ReStrat:destroyAlert("Pulse-A-Tron Wave Cooldown") end
	ReStrat:createCastTrigger(protector, "Powering Down", destroyFrames3);
	
end

--Init for the fabricator
function ReStrat:fabricatorInit()
	local fabricrator = "Phagetech Fabricator";

	--Destructobots
	local dbCD = function() ReStrat:createAlert("Summon Destructobot Cooldown", 12, nil, ReStrat.color.orange, nil); ReStrat:createPop("Destructobot!", nil) end
	ReStrat:createCastAlert(fabricator, "Summon Destructobot", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, dbCD);
	
	--Technophage Catalyst
	local techno = function()
		ReStrat:createPop("Meteors!")
		ReStrat:createAlert("Technophage Catalyst!", 10, nil, ReStrat.color.red, nil)
		ReStrat:createAlert("Power up(Commander Next)", 60, nil, ReStrat.color.purple, nil)
		commanderpull = false
	end
	--ReStrat:createCastTrigger(fabricator, "Powering Up", techno);
	ReStrat:OnDatachron("Phagetech Fabricator is now active!", techno)
	
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
	startFunction = commanderInit,
	strCategory  = "Genetic Archives",
	tModules = {
		["Forced Production"] = {
			strLabel = "Forced Production",
			bEnabled = true,
		},
		["Destruction Protocol"] = {
			strLabel = "Destruction Protocol",
			bEnabled = false,
		},
	}
}

ReStrat.tEncounters["Phagetech Augmentor"] = {
	startFunction = augmentorInit,
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
	startFunction = protectorInit,
	strCategory  = "Genetic Archives",
	tModules = {
		["Pulse-A-Tron Wave"] = {
			strLabel = "Pulse-A-Tron Wave",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Phagetech Fabricator"] = {
	startFunction = fabricatorInit,
	strCategory  = "Genetic Archives",
	tModules = {
		["Summon Destructobot"] = {
			strLabel = "Summon Destructobot",
			bEnabled = true,
		},
	}
}
