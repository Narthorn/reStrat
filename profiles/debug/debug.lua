-----------------------------------------------------------------------------
--Debug Profile, only works on easy mobs in Large Training Grounds
-----------------------------------------------------------------------------

function ReStrat:debugEvent(tEventObj)
	ReStrat:trackEvent(tEventObj, self.color.orange, "Infantary escorted")
end
 
function ReStrat:debugEvent2(tEventObj)
	ReStrat:trackEvent(tEventObj, self.color.yellow, "Strain kills")
end


--Example fight initiate function
function ReStrat:profileDebug(unit)
	bombtot = 10
	
	ReStrat:createPin("Enemy", unit, "Crafting_RunecraftingSprites:sprRunecrafting_Fire_Colored")
	DrawLib:UnitLine(GameLib.GetPlayerUnit(), unit, self.color.green)
	
	ReStrat:createLandmark("E", {1423, -709, 1387}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
	ReStrat:createLandmark("N", {1416, -709, 1400}, nil, "Subtitle")
	
	
	ReStrat:createAlert("Entered Combat: " .. bombtot, 600.5, nil, nil, nil)
	ReStrat:createCastAlert("Holographic Moodie", "Firestorm", nil, nil, ReStrat.color.white, fsc)
	ReStrat:createCastAlert("Holographic Moodie", "Erupting Fissure", nil, nil, ReStrat.color.green, fsc)
	ReStrat:createCastAlert("Holographic Shootbot", "Jump Shot", nil, nil, ReStrat.color.purple, function () ReStrat:createAlert("Next Cast", 10, nil, ReStrat.color.purple, nil) end)
	ReStrat:createCastAlert("Holographic Shootbot", "Slasher Dash", nil, nil, ReStrat.color.red, function () ReStrat:createAlert("Next Cast", 10, nil, ReStrat.color.purple, nil) end)
	ReStrat:createCastAlert("Holographic Chompacabra", "Snap Trap", nil, nil, ReStrat.color.yellow, fsc)
	ReStrat:createCastAlert("Holographic Chompacabra", "Feeding Frenzy", nil, nil, ReStrat.color.blue, fsc)
	ReStrat:onPlayerHit("Firestorm", nil, 5, function() Print("Stop getting hit!") end)
	
	ReStrat:createAuraAlert(nil, "Melt Armor", nil, nil, nil)
	ReStrat:createPinFromAura("Interrupt Armor", nil, false, "CRB_Interface12_BO")
	ReStrat:createAuraAlert(nil, "Interrupt Armor", nil, nil, nil)
	
	tStations = {}
	tStations.strLabel = "Next Station"
	tStations.fDelay = 25
	tStations.fDuration = 5
	tStations.strColor = ReStrat.color.blue
	tStations.strIcon = "Icon_SkillStalker_Destructive_Sweep"
	
	ReStrat:repeatAlert(tStations, 99)
	
	local fsc = function (caster)
	
	
		ReStrat:destroyLandmark("N")
		DrawLib:UnitLine(GameLib.GetPlayerUnit(), caster)
		ReStrat:destroyAlert("Entered Combat: " .. bombtot, nil)
		ReStrat:createPop("Firestorm Started!")
		if not ReStrat.tEncounterVariables.firestorm then ReStrat.tEncounterVariables.firestorm = 0 end
		
		ReStrat.tEncounterVariables.firestorm = ReStrat.tEncounterVariables.firestorm + 1
		Print(caster:GetName())
		Print(ReStrat.tEncounterVariables.firestorm)
	
	end
	ReStrat:createCastTrigger("Holographic Moodie", "Firestorm", fsc)
	
	local healinc = function (target)
		ReStrat:destroyLandmark("Number 2")
		local pos = target:GetPosition()
		Print(target:GetName() .. " got healed! Coords: " .. pos.x .. ", ".. pos.y .. ", " .. pos.z)
	end
	
	ReStrat:onHeal(GameLib.GetPlayerUnit():GetName(), 1, healinc)
end

--Example spam function, there should be very little if anything in here
local function profileDebugRepeat()
	Print("Spammerino Cappucino")
end

-----------------------------------------------------------------------------
--Encounter Packaging
-----------------------------------------------------------------------------
if not ReStrat.tEncounters then
	ReStrat.tEncounters = {}
end

--Profile Settings
ReStrat.tEncounters["Holographic Moodie"] = {
	startFunction = profileDebug,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Large Training Grounds",
	trackHealth = ReStrat.color.green,
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
	startFunction = profileDebug,
	fSpamFunction = profileDebugRepeat,
	trackHealth = "green",
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
	startFunction = profileDebug,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Large Training Grounds",
	trackHealth = ReStrat.color.green,
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
--]]--