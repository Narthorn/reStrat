-----------------------------------------------------------------------------
--System Daemons, Reglitch's Profile
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Binary Daemon
local function binaryInit()
	local binary = "Binary System Daemon";
	
	-----------------------------
	--Initial Timers
	-----------------------------
	ReStrat.tEncounterVariables.addwaves = function() 
		ReStrat:createAlert("Next Add Wave", 50, nil, ReStrat.color.green, ReStrat.tEncounterVariables.addwaves) 
	end
	
	ReStrat.tEncounterVariables.disconnect = function()
		ReStrat:createAlert("Next Disconnect", 60, nil, ReStrat.color.purple, ReStrat.tEncounterVariables.disconnect) 
	end
	
	ReStrat:createAlert("Portals Opening", 4, nil, ReStrat.color.orange, nil)
	ReStrat:createAlert("Next Add Wave", 15, nil, ReStrat.color.green, ReStrat.tEncounterVariables.addwaves)
	ReStrat:createAlert("Next Disconnect", 45, nil, ReStrat.color.purple, ReStrat.tEncounterVariables.disconnect)
	
	-----------------------------
	--Datachron Hooks
	-----------------------------
	local phaseTwo = function() 
		ReStrat:DestroyAlert("Next Add Wave", false)
		ReStrat:DestroyAlert("Disconnect", false)
		ReStrat:DestroyAlert("Next Add Wave", false)
		ReStrat:createAlert("Next Add Wave", 97, nil, ReStrat.color.green, ReStrat.tEncounterVariables.addwaves)
		ReStrat:createAlert("Next Disconnect", 95, nil, ReStrat.color.green, ReStrat.tEncounterVariables.disconnect)
	end
	
	ReStrat:OnDatachron("COMMENCING ENHANCEMENT SEQUENCE.", phaseTwo);
	
	
	-----------------------------
	--Binary Casts
	-----------------------------
	--Next purge
	local nextpurge = function() ReStrat:createAlert("[BIN] Purge Cooldown", 24, nil, ReStrat.color.purple, nil) end
	
	--Next power surge
	local nextsurge = function() ReStrat:createAlert("[BIN] Power Surge", 13, nil, ReStrat.color.purple, nil) end
	
	ReStrat:createCastAlert(binary, "Power Surge", nil, "Icon_SkillEsper_Awaken_Alt", ReStrat.color.red, nextsurge);
	ReStrat:createCastAlert(binary, "Purge", nil, "Icon_SkillMisc_UI_srcr_frecho", ReStrat.color.red, nextpurge);
	
end

--Null Daemon
local function nullInit()
	local null = "Null System Daemon";
	
	--Next purge
	local nextpurge = function() ReStrat:createAlert("[NULL] Purge Cooldown", 24, nil, ReStrat.color.purple, nil) end
	
	--Next power surge
	local nextsurge = function() ReStrat:createAlert("[NULL] Power Surge", 13, nil, ReStrat.color.purple, nil) end
	
	ReStrat:createCastAlert(null, "Power Surge", nil, "Icon_SkillEsper_Awaken_Alt", ReStrat.color.red, nextsurge);
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


