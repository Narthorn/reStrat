--[[---------------------------------------------------------------------------
--Debug Profile, only works on easy mobs in Large Training Grounds
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Example fight initiate function
local function profileDebug()
	ReStrat:createAlert("Entered Combat", 2.5, nil, nil, nil)
	ReStrat:createCastAlert("Holographic Moodie", "Firestorm", nil, nil, ReStrat.color.white, nil)
	ReStrat:createCastAlert("Holographic Moodie", "Erupting Fissure", nil, nil, ReStrat.color.green, nil)
	ReStrat:createCastAlert("Holographic Shootbot", "Jump Shot", nil, nil, ReStrat.color.purple, function () ReStrat:createAlert("Next Cast", 10, nil, ReStrat.color.purple, nil) end)
	ReStrat:createCastAlert("Holographic Shootbot", "Slasher Dash", nil, nil, ReStrat.color.red, function () ReStrat:createAlert("Next Cast", 10, nil, ReStrat.color.purple, nil) end)
	ReStrat:createCastAlert("Holographic Chompacabra", "Snap Trap", nil, nil, ReStrat.color.yellow, nil)
	ReStrat:createCastAlert("Holographic Chompacabra", "Feeding Frenzy", nil, nil, ReStrat.color.blue, nil)
	ReStrat:onPlayerHit("Firestorm", "Holographic Moodie", 5, function() Print("Stop getting hit!") end)
	
	local fsc = function ()
		Print("Firestorm Started!");
		if not ReStrat.tEncounterVariables.firestorm then ReStrat.tEncounterVariables.firestorm = 0 end
		
		ReStrat.tEncounterVariables.firestorm = ReStrat.tEncounterVariables.firestorm + 1;
		
		Print(ReStrat.tEncounterVariables.firestorm);
	
	end
	
	ReStrat:createCastTrigger("Holographic Moodie", "Firestorm", fsc);
end

--Example spam function, there should be very little if anything in here
local function profileDebugRepeat()
	Print("Spammerino Cappucino");
end



-----------------------------------------------------------------------------
--Encounter Packaging
-----------------------------------------------------------------------------
if not ReStrat.tEncounters then
	ReStrat.tEncounters = {}
end

--Profile Settings
ReStrat.tEncounters["Holographic Moodie"] = {
	fInitFunction = profileDebug,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Large Training Grounds",
	tModules = {
		["Firestorm"] = {
			strLabel = "Firestorm",
			bEnabled = true,
		},
		["Fissure"] = {
			strLabel = "Fissure",
			bEnabled = true,
		},
		["Erupting Fissure"] = {
			strLabel = "Erupting Fissue",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Holographic Shootbot"] = {
	fInitFunction = profileDebug,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Large Training Grounds",
	tModules = {
		["Jump Shot"] = {
			strLabel = "Jump Shot",
			bEnabled = true,
		},
		["Slasher Dash"] = {
			strLabel = "Slasher Dash",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Holographic Chompacabra"] = {
	fInitFunction = profileDebug,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Large Training Grounds",
	tModules = {
		["Snap Trap"] = {
			strLabel = "Snap Trap",
			bEnabled = true,
		},
		["Feeding Frenzy"] = {
			strLabel = "Feeding Frenzy",
			bEnabled = true,
		},
	}
}
]]--
