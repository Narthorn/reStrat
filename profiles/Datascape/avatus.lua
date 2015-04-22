-----------------------------------------------------------------------------
--- Avatus, Vim
-- TODO: rework this once I split the unit init into onSpawn/onCombat
-----------------------------------------------------------------------------

local function Avatus()
	if not ReStrat.tEncounterVariables.firstPhase then
		ReStrat.tEncounterVariables.firstPhase = true

		ReStrat:createAlert("Gun Grid", 20, "Icon_SkillEngineer_Target_Acquistion", ReStrat.color.red)
		
		ReStrat:OnDatachron("SECURITY PROTOCOL: Gun Grid Activated.", function()
			ReStrat:destroyAlert("Gun Grid")
			ReStrat:createAlert("Obliteration Beam", 45, nil, ReStrat.color.blue, function()
				ReStrat:createAlert("Obliteration Beam", 40, nil, ReStrat.color.blue)
			end)
			ReStrat:createAlert("Holo Hands/Guns", 22, nil, ReStrat.color.green, nil)
			ReStrat:createAlert("Gun Grid", 112, "Icon_SkillEngineer_Target_Acquistion", ReStrat.color.red, nil)
		end)
		
		ReStrat:OnDatachron("Avatus' power begins to surge! Portals have opened!", function()
			ReStrat:destroyAlert("Obliteration Beam")
			ReStrat:destroyAlert("Gun Grid")
			ReStrat:destroyAlert("Holo Hands/Guns")
		end)
		
		ReStrat:OnDatachron("The Caretaker has returned!", function()
			ReStrat:destroyAlert("Obliteration Beam")
			ReStrat:destroyAlert("Gun Grid")
			ReStrat:destroyAlert("Holo Hands/Guns")
			ReStrat:createAlert("Cannons", 8, nil, ReStrat.color.yellow, function()
				ReStrat:repeatAlert({strLabel = "Next cannons", fRepeat = 23, strColor = ReStrat.color.yellow})
			end)
		end)
	end
end

local function yellowRoom()
	ReStrat:createCastTrigger("Mobius Physics Constructor", "Data Flare", function()
		ReStrat:createPop("Flare !", nil)
		Sound.PlayFile("Sound\\quack.wav")
	end)
end

local function blueRoom(unit)
	if unit:GetDispositionTo(GameLib.GetPlayerUnit()) == 0 then -- portal to blue room has same name
		local playerColor = ReStrat.tShortcutBars[7][1].spell:GetName():match("%w+") -- only the first word of "Green/Blue/Red Matrix Key"
	
		local function Matrix(color)
			if color == playerColor then
				ReStrat:createPop(color .. " Disruption Matrix !")
				Sound.PlayFile("Sound\\quack.wav")
			end
		end

		ReStrat:createAuraAlert("Infinite Logic Loop", "Blue Disruption Matrix", 0, nil, function() Matrix("Blue") end) 
		ReStrat:createAuraAlert("Infinite Logic Loop", "Green Reconstitution Matrix", 0, nil, function() Matrix("Green") end) 
		ReStrat:createAuraAlert("Infinite Logic Loop", "Red Empowerment Matrix", 0, nil, function() Matrix("Red") end) 
	
		ReStrat:createPinFromAura("Disruption Matrix Distortion")
	end
end

ReStrat.tEncounters["Avatus"] = {
	fInitFunction = Avatus,
	strCategory = "Datascape",
	trackHealth = ReStrat.color.red,
	tModules = {},
}

ReStrat.tEncounters["Holo Hand"] = {
	strCategory = "Datascape",
	trackHealth = ReStrat.color.blue,
	tModules = {},
}

ReStrat.tEncounters["Mobius Physics Constructor"] = {
	fInitFunction = yellowRoom,
	strCategory = "Datascape",
	trackHealth = ReStrat.color.yellow,
	tModules = {},
}

ReStrat.tEncounters["Infinite Logic Loop"] = {
	fInitFunction = blueRoom,
	strCategory = "Datascape",
	trackHealth = ReStrat.color.blue,
	tModules = {},
}

--ReStrat.tEncounters["Excessive Force Protocol"] = {
--	fInitFunction = redRoom,
--	strCategory = "Datascape",
--	trackHealth = ReStrat.color.red,
--	tModules = {},
--}