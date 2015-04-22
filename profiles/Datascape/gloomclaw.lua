------------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------
 
function ReStrat:gloomInit(unit)
		
	local phase = 2
	local pull = true
	
	--Rupture
	
    local ruptureCD = 	function() 
		ReStrat:createAlert("Rupture Cooldown", 32, nil, ReStrat.color.red, function()
			ReStrat:createPop("Rupture soon", nil)
		end) 
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
			ReStrat:createCastAlert("Gloomclaw", "Rupture", nil, "Icon_SkillStalker_Razor_Disk", ReStrat.color.red, ruptureCD)
		elseif phase == 1 then
			ReStrat:createAlert("Next Wave (#1)", 25, nil, ReStrat.color.green, function()
				ReStrat:createAlert("Next Wave (#2)", 27, nil, ReStrat.color.green, function()
					ReStrat:createAlert("Next Wave (#3)", 29, nil, ReStrat.color.green, nil)end)end)
			ReStrat:createCastAlert("Gloomclaw", "Rupture", nil, "Icon_SkillStalker_Razor_Disk", ReStrat.color.red, ruptureCD)
		elseif phase == 2 then
			ReStrat:createAlert("Next Wave (#1)", 35, nil, ReStrat.color.green, function()
				ReStrat:createAlert("Next Wave (#2)", 35, nil, ReStrat.color.green, function()
					ReStrat:createAlert("Next Wave (#3)", 35, nil, ReStrat.color.green, nil)end)end)
			ReStrat:createCastAlert("Gloomclaw", "Rupture", nil, "Icon_SkillStalker_Razor_Disk", ReStrat.color.red, ruptureCD)
		elseif phase == 3 then
			ReStrat:createAlert("Next Wave (#1)", 25, nil, ReStrat.color.green, function()
				ReStrat:createAlert("Next Wave (#2)", 27, nil, ReStrat.color.green, function()
					ReStrat:createAlert("Next Wave (#3)", 29, nil, ReStrat.color.green, nil)end)end)
			ReStrat:createCastAlert("Gloomclaw", "Rupture", nil, "Icon_SkillStalker_Razor_Disk", ReStrat.color.red, ruptureCD)
		elseif phase == 4 then
			ReStrat:createAlert("Collect", 110, nil, ReStrat.color.green, nil)
		elseif phase == 5 then
			ReStrat:createAlert("Next Wave (#1)", 21, nil, ReStrat.color.green, function()
				ReStrat:createAlert("Next Wave (#2)", 21, nil, ReStrat.color.green, function()
					ReStrat:createAlert("Next Wave (#3)", 21, nil, ReStrat.color.green, nil)end)end)
			ReStrat:createCastAlert("Gloomclaw", "Rupture", nil, "Icon_SkillStalker_Razor_Disk", ReStrat.color.red, ruptureCD)
		end                
    end
	
    --Moo
    local MoO = function()
	
		ReStrat:destroyAllAlerts()
		phase = phase + 1
           
        ReStrat:createAlert("Gloomclaw MOO!", 15, nil, ReStrat.color.purple, nil)
    end

	local Move = function ()
		ReStrat:createAlert("Move to Phase "..phase.."!", 9, nil, ReStrat.color.yellow, NextPhase)	
		ReStrat:createAlert("Maybe First Rupture", 32, nil, ReStrat.color.purple, nil)
	end
   
    

	local PhaseBack = function()
	
		ReStrat:destroyAllAlerts()

		phase = phase - 1
		
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
	tEventObjLeft1 = tEventObj
	ReStrat:trackEvent(tEventObj, self.color.yellow, "Left Essence")
end

function ReStrat:rightess(tEventObj)
	tEventObjRight1 = tEventObj
	ReStrat:trackEvent(tEventObj, self.color.blue, "Right Essence")
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
        }
}

-----------------------------