-----------------------------------------------------------------------------
--System Daemons, Reglitch's Profile
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Binary Daemon
local function binaryInit()
	local binary = "Binary System Daemon";
	
	--Power Surge/Purge cooldown
	local powersurge = function()
		if not ReStrat.tEncounterVariables.powersurge then ReStrat.tEncounterVariables.powersurge = 0 end
		ReStrat.tEncounterVariables.powersurge = ReStrat.tEncounterVariables.powersurge + 1;
		
		--Power Surge is replaced by Purge every third cast
		if ReStrat.tEncounterVariables.powersurge == 2 then
			ReStrat.tEncounterVariables.powersurge = 0;
			ReStrat:createAlert("[BIN] Purge Incoming", 13, nil, ReStrat.color.orange, nil)
			return
		end
		
		ReStrat:createAlert("[BIN] Power Surge Cooldown", 13, nil, ReStrat.color.orange, nil)
	end
	
	--Next purge
	local nextpurge = function() ReStrat:createAlert("[BIN] Power Surge Incoming", 13, nil, ReStrat.color.orange, nil) end
	
	ReStrat:createCastAlert(binary, "Power Surge", nil, "Icon_SkillEsper_Awaken_Alt", ReStrat.color.red, powersurge);
	ReStrat:createCastAlert(binary, "Purge", nil, "Icon_SkillMisc_UI_srcr_frecho", ReStrat.color.red, nextpurge);
	
end

--Null Daemon
local function nullInit()
	local null = "Null System Daemon";
	
	--Power Surge/Purge cooldown
	local powersurge = function()
		if not ReStrat.tEncounterVariables.powersurge then ReStrat.tEncounterVariables.powersurge = 0 end
		ReStrat.tEncounterVariables.powersurge = ReStrat.tEncounterVariables.powersurge + 1;
		
		--Power Surge is replaced by Purge every third cast
		if ReStrat.tEncounterVariables.powersurge == 2 then
			ReStrat.tEncounterVariables.powersurge = 0;
			ReStrat:createAlert("[NULL] Purge Incoming", 13, nil, ReStrat.color.orange, nil)
			return
		end
		
		ReStrat:createAlert("[NULL] Power Surge Cooldown", 13, nil, ReStrat.color.orange, nil)
	end
	
	--Next purge
	local nextpurge = function() ReStrat:createAlert("[NULL] Power Surge Incoming", 13, nil, ReStrat.color.orange, nil) end
	
	ReStrat:createCastAlert(null, "Power Surge", nil, "Icon_SkillEsper_Awaken_Alt", ReStrat.color.red, powersurge);
	ReStrat:createCastAlert(null, "Purge", nil, "Icon_SkillMisc_UI_srcr_frecho", ReStrat.color.red, nextpurge);
	
end

--Defragmentation Unit
local function defragInit()
	defrag = "Defragmentation Unit";
	
	ReStrat:createCastAlert(defrag, "Black IC", nil, "Icon_SkillMisc_UI_m_enrgypls", ReStrat.color.red, nil);
	ReStrat:createCastAlert(defrag, "Defrag", nil, "Icon_SkillMedic_magneticlockdown", ReStrat.color.red, nil);
end

-----------------------------------------------------------------------------
--Encounter Packaging
-----------------------------------------------------------------------------
if not ReStrat.tEncounters then
	ReStrat.tEncounters = {}
end

--Profile Settings
ReStrat.tEncounters["Binary System Daemon"] = {
	fInitFunction = binaryInit,
	strCategory  = "Datascape",
	tModules = {
		["Power Surge"] = {
			strLabel = "Power Surge",
			bEnabled = true,
		},
		["Purge"] = {
			strLabel = "Purge",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Null System Daemon"] = {
	fInitFunction = nullInit,
	strCategory  = "Datascape",
	tModules = {
		["Power Surge"] = {
			strLabel = "Power Surge",
			bEnabled = true,
		},
		["Purge"] = {
			strLabel = "Purge",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Defragmentation Unit"] = {
	fInitFunction = defragInit,
	strCategory  = "Datascape",
	tModules = {
		["Black IC"] = {
			strLabel = "Black IC",
			bEnabled = true,
		},
		["Defrag"] = {
			strLabel = "Defrag",
			bEnabled = true,
		},
	}
}


