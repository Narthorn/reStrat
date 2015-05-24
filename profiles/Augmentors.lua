-----------------------------------------------------------------------------
-- Augmentors - Vim

function ReStrat:augmentorsInit(unit)
	if not ReStrat.tEncounterVariables.bStartedAug then
		ReStrat.tEncounterVariables.bStartedAug = true

		--if unit:GetName() == "Prime Phage Distributor" then
		--	ReStrat:trackHealth(unit, ReStrat.color.purple)
		--else
		--	ReStrat:trackHealth(unit, ReStrat.color.orange)
		--end


		local function nextIrradiate(nTime)
			ReStrat:createAlert("Next Radiation Bath", nTime, nil, ReStrat.color.green, nil)
		end

		ReStrat:createAlert("First Radiation Bath", 26, nil, ReStrat.color.green, nil)

		ReStrat:OnDatachron("ENGAGING TECHNOPHAGE TRASMISSION", function() nextIrradiate(40) end)
		ReStrat:OnDatachron("is being irradiated", function() nextIrradiate(26) end)


		ReStrat:createAuraAlert(GameLib.GetPlayerUnit(), "Strain Incubation")
		--ReStrat:repeatAlert({strLabel = "Radiation Bath", fDelay = 15, fRepeat = 30, strColor = ReStrat.color.green})
	end
end

ReStrat.tEncounters["Prime Phage Distributor"] = {
	fInitFunction = augmentorsInit,
	strCategory  = "Augmentors",
	trackHealth = ReStrat.color.purple,
	tModules = {}
}

ReStrat.tEncounters["Prime Evolutionary Operant"] = {
	fInitFunction = augmentorsInit,
	strCategory  = "Augmentors",
	trackHealth = ReStrat.color.orange,
	tModules = {},
}