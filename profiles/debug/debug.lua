-----------------------------------------------------------------------------
--Debug Profile, only works on easy mobs in Large Training Grounds
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
	
	local nFirestorm = 0
	ReStrat:createCastTrigger("Holographic Moodie", "Firestorm", function()
		Print(ReStrat.tShortcutBars[7][7].spell:GetName())
		ReStrat:createPop("Firestorm Started!")
		nFirestorm = nFirestorm + 1
		Print(nFirestorm)
	end)
	
	ReStrat:createPinFromAura("Melt Armor")
	ReStrat:createPinFromAura("Bleed")
end

--Profile Settings
ReStrat.tEncounters["Holographic Moodie"] = {
	fInitFunction = profileDebug,
	strCategory  = "Large Training Grounds",
	trackHealth = ReStrat.color.green,
	tModules = {},
}

ReStrat.tEncounters["Holographic Shootbot"] = {
	fInitFunction = profileDebug,
	trackHealth = "green",
	strCategory  = "Large Training Grounds",
	tModules = {},
}

ReStrat.tEncounters["Holographic Chompacabra"] = {
	fInitFunction = profileDebug,
	strCategory  = "Large Training Grounds",
	trackHealth = ReStrat.color.green,
	tModules = {},
}