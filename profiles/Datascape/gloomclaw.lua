-----------------------------------------------------------------------------
-- Gloomclaw - Vim, chillmastor
 
local function gloomInit(unit)

	local function enabled(option) return ReStrat.tConfig["Gloomclaw"].tModules[option].bEnabled end
	
	local leftSpawn = {
		{4288.5, -568.48095703125, -16765.66796875 },
		{4288.5, -568.30078125656, -16858.9765625 },
		{4288.5, -568.95300292969, -16949.40234375 },
		{4288.5, -568.95300292969, -17040.22265625 },
		{4288.5, -568.95300292969, -17040.099609375 },
	}
	
	local rightSpawn = {
		{4332.5, -568.48339843750, -16765.66796875 },
		{4332.5, -568.45147705078, -16858.9765625 },
		{4332.5, -568.95300292969, -16949.40234375 },
		{4332.5, -568.95300292969, -17040.22265625 },
		{4332.5, -568.95300292969, -17040.099609375 },
	}
	
	local addTimings = {
		[1] = {25,25,25},
		[2] = {25,26,26},
		[3] = {35,32,35},
		[4] = {25,27,27},
		[6] = {21,21,21},
	}
	
	local phase = 2
	local pull = true
	
	local function Landmarks()
		ReStrat:destroyAllLandmarks()
		if enabled("Landmarks") and phase ~= 0 then
			ReStrat:createLandmark("Left", leftSpawn[phase])
			ReStrat:createLandmark("Right", rightSpawn[phase])
		end
	end
		
	local function NextPhase()
		if phase ~= 5 then
			Landmarks()
			if enabled("Waves") then
				ReStrat:createAlert("Next Wave (#1)", addTimings[phase][1], nil, ReStrat.color.green, function()
					ReStrat:createAlert("Next Wave (#2)", addTimings[phase][2], nil, ReStrat.color.green, function()
						ReStrat:createAlert("Next Wave (#3)", addTimings[phase][3], nil, ReStrat.color.green, nil)
					end)
				end)
			end
		else
			ReStrat:createAlert("Collect", 110, nil, ReStrat.color.green, nil)
			
			if enabled("Landmarks") then
				ReStrat:destroyAllLandmarks()
				ReStrat:createLandmark("Frog1", {4288, -568, -17040})
				ReStrat:createLandmark("Frog2", {4332, -568, -17040})
				ReStrat:createLandmark("Frog3", {4332, -568, -16949})
				ReStrat:createLandmark("Frog4", {4288, -568, -16949})
			end
		end
	end
	
	local function MoO()
		ReStrat:destroyAllAlerts()
		ReStrat:createAlert("MoO", 15, nil, ReStrat.color.purple, nil)
	end
	
	local function Forwards()
		
		ReStrat:destroyAllAlerts()
		phase = phase + 1
		
		Landmarks()
		
		ReStrat:createAlert("Move to Phase "..phase.." !", 9, nil, ReStrat.color.yellow, NextPhase)	
		ReStrat:createAlert("Maybe First Rupture", 32, nil, ReStrat.color.purple, nil)
	end
	
	local function Backwards()
		
		ReStrat:destroyAllAlerts()
		phase = phase - 1
		
		Landmarks()
		
		if pull then
			ReStrat:createAlert("Maybe First Rupture", 32, nil, ReStrat.color.purple, nil)
			ReStrat:createAlert("Gloomclaw Pull!", 5, nil, ReStrat.color.purple, NextPhase)
			pull = false
		else
			ReStrat:createAlert("Move to Phase "..phase.." !", 10, nil, ReStrat.color.red, NextPhase)
		end
	end
	
	--
	
	Landmarks()
	
	-- event tracking not implemented
	--if enabled("Essences") then
	--	ReStrat:trackEvent("Left Essence", self.color.yellow)
	--	ReStrat:trackEvent("Right Essence", self.color.blue)
	--end
	
	ReStrat:createCastTrigger("Gloomclaw", "Rupture", function() ReStrat:createPop("Rupture!", nil, "Sound\\quack.wav") end)
	ReStrat:createCastAlert("Gloomclaw", "Rupture", nil, "Icon_SkillStalker_Razor_Disk", ReStrat.color.red, function()
		ReStrat:createAlert("Rupture Cooldown", 32, nil, ReStrat.color.red, function()
			ReStrat:createPop("Rupture soon", nil)
		end) 
	end)
	
	ReStrat:OnDatachron("Gloomclaw is reduced to a weakened state!",                     MoO)
	ReStrat:OnDatachron("Gloomclaw is pushed back by the purification of the essences!", Forward)
	ReStrat:OnDatachron("Gloomclaw is moving forward to corrupt more essences!",         Backwards)
end

ReStrat.tEncounters["Gloomclaw"] = { fInitFunction = gloomInit, trackHealth = ReStrat.color.red }

ReStrat.tConfig["Gloomclaw"] = {
	version = 2,
	strCategory  = "Datascape",
	tModules = {
		Rupture = {
			strLabel = "Rupture",
			bEnabled = true,
			},
		Waves = {
			strLabel = "Add Waves Timer",
			bEnabled = true,
		},
		Landmarks = {
			strLabel = "Spawn Landmarks",
			bEnabled = true,
		},
		--Essences = {
		--	strLabel = "Essences HP"
		--	bEnabled = true,
		--},
	}
}
