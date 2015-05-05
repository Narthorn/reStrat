------------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------
 
function ReStrat:gloomInit(unit)
	local leftSpawn = {
		{4288.5, -568.48095703125, -16765.66796875 },
		{4288.5, -568.30078125656, -16858.9765625 },
		{4288.5, -568.95300292969, -16949.40234375 },
		{4288.5, -568.95300292969, -17040.22265625 },
		{4288.5, -568.95300292969, -17040.099609375 }
	}

	local rightSpawn = {
		{4332.5, -568.4833984375, -16765.66796875 },
		{4332.5, -568.45147705078, -16858.9765625 },
		{4332.5, -568.95300292969, -16949.40234375 },
		{4332.5, -568.95300292969, -17040.22265625 },
		{4332.5, -568.95300292969, -17040.099609375 }
	}
	
	local phase = 2
	local pull = true
	
	if self:IsActivated("Gloomclaw", "Spawn Landmarks") then
		ReStrat:destroyAllLandmarks()
		ReStrat:createLandmark("Left", leftSpawn[phase])
		ReStrat:createLandmark("Right", rightSpawn[phase])
	end
	
	--Rupture
	
    local ruptureCD = 	function() 
		ReStrat:createAlert("Rupture Cooldown", 32, nil, ReStrat.color.red, function()
			ReStrat:createPop("Rupture soon", nil)
		end) 
	end
	local rupturePop = function()
		ReStrat:createPop("Rupture!", 4)
		ReStrat:Sound("Sound\\spew.wav") --Sound\quack.wav
	end
		
	--ReStrat:createCastAlert("Gloomclaw", "Rupture", nil, "Icon_SkillStalker_Razor_Disk", ReStrat.color.red, ruptureCD)				
	
	if ReStrat.tEncounters["Gloomclaw"].tModules["BossLife"].bEnabled then
		ReStrat:trackHealth(unit, ReStrat.color.red)	
	end
   	
	local NextPhase = function()
					
		if phase == 0 then
			ReStrat:createAlert("Next Wave (#1)", 25, nil, ReStrat.color.green, function()
				ReStrat:createAlert("Next Wave (#2)", 25, nil, ReStrat.color.green, function()
					ReStrat:createAlert("Next Wave (#3)", 25, nil, ReStrat.color.green, nil)end)end)
			ReStrat:createCastAlert("Gloomclaw", "Rupture", nil, "Icon_SkillStalker_Razor_Disk", ReStrat.color.red, ruptureCD, rupturePop)
		elseif phase == 1 then
			ReStrat:createAlert("Next Wave (#1)", 25, nil, ReStrat.color.green, function()
				ReStrat:createAlert("Next Wave (#2)", 26, nil, ReStrat.color.green, function()
					ReStrat:createAlert("Next Wave (#3)", 26, nil, ReStrat.color.green, nil)end)end)
			ReStrat:createCastAlert("Gloomclaw", "Rupture", nil, "Icon_SkillStalker_Razor_Disk", ReStrat.color.red, ruptureCD, rupturePop)
		elseif phase == 2 then
			ReStrat:createAlert("Next Wave (#1)", 35, nil, ReStrat.color.green, function()
				ReStrat:createAlert("Next Wave (#2)", 32, nil, ReStrat.color.green, function()
					ReStrat:createAlert("Next Wave (#3)", 35, nil, ReStrat.color.green, nil)end)end)
			ReStrat:createCastAlert("Gloomclaw", "Rupture", nil, "Icon_SkillStalker_Razor_Disk", ReStrat.color.red, ruptureCD, rupturePop)
		elseif phase == 3 then
			ReStrat:createAlert("Next Wave (#1)", 25, nil, ReStrat.color.green, function()
				ReStrat:createAlert("Next Wave (#2)", 27, nil, ReStrat.color.green, function()
					ReStrat:createAlert("Next Wave (#3)", 27, nil, ReStrat.color.green, nil)end)end)
			ReStrat:createCastAlert("Gloomclaw", "Rupture", nil, "Icon_SkillStalker_Razor_Disk", ReStrat.color.red, ruptureCD, rupturePop)
		elseif phase == 4 then
			ReStrat:createAlert("Collect", 110, nil, ReStrat.color.green, nil)
			
			if self:IsActivated("Gloomclaw", "Spawn Landmarks") then
				ReStrat:destroyAllLandmarks()
				ReStrat:createLandmark("Frog1", {4288, -568, -17040 })
				ReStrat:createLandmark("Frog2", {4332, -568, -17040 })
				ReStrat:createLandmark("Frog3", {4332, -568, -16949 })
				ReStrat:createLandmark("Frog4", {4288, -568, -16949 })
			end
					
			
		elseif phase == 5 then
			ReStrat:createAlert("Next Wave (#1)", 21, nil, ReStrat.color.green, function()
				ReStrat:createAlert("Next Wave (#2)", 21, nil, ReStrat.color.green, function()
					ReStrat:createAlert("Next Wave (#3)", 21, nil, ReStrat.color.green, nil)end)end)
			ReStrat:createCastAlert("Gloomclaw", "Rupture", nil, "Icon_SkillStalker_Razor_Disk", ReStrat.color.red, ruptureCD, rupturePop)
		end                
    end
	
    --Moo
    local MoO = function()
	
		ReStrat:destroyAllAlerts()
		phase = phase + 1
		
		if self:IsActivated("Gloomclaw", "Spawn Landmarks") and phase ~= 0 then
			ReStrat:destroyAllLandmarks()
			ReStrat:createLandmark("Left", leftSpawn[phase])
			ReStrat:createLandmark("Right", rightSpawn[phase])	
		end
		
        ReStrat:createAlert("Gloomclaw MOO!", 15, nil, ReStrat.color.purple, nil)
    end

	local Move = function ()
		ReStrat:createAlert("Move to Phase "..phase.."!", 9, nil, ReStrat.color.yellow, NextPhase)	
		ReStrat:createAlert("Maybe First Rupture", 32, nil, ReStrat.color.purple, nil)
	end
   
    

	local PhaseBack = function()
	
		ReStrat:destroyAllAlerts()

		phase = phase - 1
		
		if self:IsActivated("Gloomclaw", "Spawn Landmarks") and phase ~= 0 then
			ReStrat:destroyAllLandmarks()
			ReStrat:createLandmark("Left", leftSpawn[phase])
			ReStrat:createLandmark("Right", rightSpawn[phase])
		end
		
		if pull then
			ReStrat:createAlert("Maybe First Rupture", 32, nil, ReStrat.color.purple, nil)
			ReStrat:createAlert("Gloomclaw Pull!", 5, nil, ReStrat.color.purple, NextPhase )
			pull = false
		--else
		--	ReStrat:createAlert("Move to Phase "..phase.."!", 10, nil, ReStrat.color.red, NextPhase )				
		end
	end
	
	

    ReStrat:OnDatachron("Gloomclaw is reduced to a weakened state!", MoO );
    ReStrat:OnDatachron("Gloomclaw is pushed back by the purification of the essences!", Move);
	ReStrat:OnDatachron("Gloomclaw is moving forward to corrupt more essences!", PhaseBack );
end

function ReStrat:leftess(tEventObj)
	--tEventObjLeft1 = tEventObj
	if self:IsActivated("Gloomclaw", "Track Essence HP") then
		ReStrat:trackEvent(tEventObj, self.color.yellow, "Left Essence")
	end
end

function ReStrat:rightess(tEventObj)
	--tEventObjRight1 = tEventObj
	if self:IsActivated("Gloomclaw", "Track Essence HP") then
		ReStrat:trackEvent(tEventObj, self.color.blue, "Right Essence")
	end
end
 
-----------------------------------------------------------------------------
--Encounter Packaging
-----------------------------------------------------------------------------
 
if not ReStrat.tEncounters then
        ReStrat.tEncounters = {}
end
 
--Profile Settings
ReStrat.tEncounters["Gloomclaw"] = {
        startFunction = gloomInit,
        --fSpamFunction = profileDebugRepeat,
        strCategory  = "Datascape",
        tModules = {
                ["Rupture"] = {
                        strLabel = "Rupture",
                        bEnabled = true,
                },				
                ["BossLife"] = {
                        strLabel = "Boss Life",
                        bEnabled = true,
                },
				["Spawn Landmarks"] = {
                        strLabel = "Spawn Landmarks",
                        bEnabled = true,
                },
				["Track Essence HP"] = {
                        strLabel = "Spawn Landmarks",
                        bEnabled = true,
                },
        }
}

-----------------------------