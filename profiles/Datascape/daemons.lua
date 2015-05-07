-----------------------------------------------------------------------------
--System Daemons, Reglitch's Profile
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

local function daemonInit(unit)
	name = unit:GetName()
	if name == "Binary System Daemon" then
		ReStrat:trackHealth(unit, ReStrat.color.blue, "North - " .. name)
	else
		ReStrat:trackHealth(unit, ReStrat.color.green, "South - " .. name)
	end

	if not ReStrat.tEncounterVariables.bDaemonInit then
		ReStrat.tEncounterVariables.bDaemonInit = true
		
		ReStrat:createPinFromAura("Purge")
		
		local function AddWaves()
			ReStrat:createAlert("Next Add Wave", 50, nil, ReStrat.color.green, AddWaves) 
			ReStrat:createAlert("Probe 1 Spawn", 10, nil, ReStrat.color.yellow, function()
 				ReStrat:createAlert("Probe 2 Spawn", 10, nil, ReStrat.color.yellow, function()
 					ReStrat:createAlert("Probe 3 Spawn", 10, nil, ReStrat.color.yellow, nil)
				end)
			end)
		end
		
		local function Disconnect()
			ReStrat:createAlert("Next Disconnect", 60, nil, ReStrat.color.purple, Disconnect) 
		end
		
		ReStrat:createAlert("Portals Opening", 4, nil, ReStrat.color.orange, nil)
		ReStrat:createAlert("Next Add Wave", 15, nil, ReStrat.color.green, AddWaves)
		ReStrat:createAlert("Next Disconnect", 40, nil, ReStrat.color.purple, Disconnect)
		
		local function phaseTwo()
			ReStrat:destroyAllAlerts()
			ReStrat:createAlert("Next Add Wave", 95, nil, ReStrat.color.green, AddWaves)
			ReStrat:createAlert("Next Disconnect", 87, nil, ReStrat.color.green, Disconnect)
		end
		
		ReStrat:OnDatachron("COMMENCING ENHANCEMENT SEQUENCE.", phaseTwo)
	end
end

--Defragmentation Unit
local function defragInit()
	defrag = "Defragmentation Unit";
	ReStrat:createCastAlert(defrag, "Black IC", nil, "Icon_SkillMisc_UI_m_enrgypls", ReStrat.color.red, nil)
	ReStrat:createCastAlert(defrag, "Defrag", nil, "Icon_SkillMedic_magneticlockdown", ReStrat.color.red, nil)
end

ReStrat.tEncounters["Binary System Daemon"] = {
	fInitFunction = daemonInit,
	strCategory  = "Datascape",
	tModules = {},
}

ReStrat.tEncounters["Null System Daemon"] = {
	fInitFunction = daemonInit,
	strCategory  = "Datascape",
	tModules = {},
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


