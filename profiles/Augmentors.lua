-----------------------------------------------------------------------------
-- Augmentors - Vim

local function augmentorsInit(unit)
	if not ReStrat.tEncounterVariables.bStarted then
		ReStrat:OnDatachron("ENGAGING TECHNOPHAGE TRASMISSION", function() -- sic
			ReStrat:createAlert("Expulsion", 12, nil, ReStrat.color.red)
		end)
		ReStrat.tEncounterVariables.bStarted = true
		--ReStrat:repeatAlert({strLabel = "Radiation Bath", fDelay = 15, fRepeat = 30, strColor = ReStrat.color.green})
		ReStrat:createAuraAlert(nil, "Compromised Circuitry", 0, nil, function(unit) 
			for id,tHealth in pairs(ReStrat.tHealth) do
				tHealth.bar:FindChild("progressBar"):SetBarColor(tHealth.unit == unit and ReStrat.color.purple or ReStrat.color.orange)
			end
		end)
		
		ReStrat:createPinFromAura("Strain Incubation")
	end
	
	local pos = unit:GetPosition()
	local name = pos.z < 875 and "North" or (pos.x < 1268 and "West" or "East")
	ReStrat:trackHealth(unit, ReStrat.color.purple, name)
	
	local function push() 
		ReStrat:createPop("PULL SOON !")
		Sound.PlayFile("Sound\\quack.wav")
	end
	
	-- Pulls below 20 and 60
	ReStrat:onHealth(unit, 62, push)
	ReStrat:onHealth(unit, 22, push)
end

ReStrat.tEncounters["Prime Phage Distributor"] = {
	fInitFunction = augmentorsInit,
}

ReStrat.tEncounters["Prime Evolutionary Operant"] = {
	fInitFunction = augmentorsInit,
}