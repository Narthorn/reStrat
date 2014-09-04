-----------------------------------------------------------------------------
--Ohmna, Reglitch's Profile
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Fight initiation function
local function ohmnaInit()
	local ohmna = "Dreadphage Ohmna";
	
	--Create CD timer for bored
	--local boredCD = function() ReStrat:createAlert("Bored Cooldown!", 45, nil, ReStrat.color.purple, nil) end

	--Devour
	local devourCD = function() ReStrat:createAlert("Devour Cooldown", 20, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(ohmna, "Devour", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, bombsCD);
	
	
	--AND WELCOME TO THE JAM
	local slamTimer = function()
		if not ReStrat.tEncounterVariables.slam then ReStrat.tEncounterVariables.slam = 0 end --Create the slam
		
		ReStrat.tEncounterVariables.slam = ReStrat.tEncounterVariables.slam+1;
		
		if ReStrat.tEncounterVariables.slam == 3 then
			ReStrat.tEncounterVariables.slam = 0; -- Clear our slam
			
			ReStrat:createPop("Spew Incoming!", nil);
		
		end
	end
	
	--COME ON AND SLAM
	ReStrat:onPlayerHit("Body Slam", ohmna, nil, slamTimer)
	
	
	--Torrent notification logic
	local torrentNotification = function()
		if not ReStrat.tEncounterVariables.slam or ReStrat.tEncounterVariables.slam == 1 then
			ReStrat:createAlert("Genetic Torrent Incoming!", 12, nil, ReStrat.color.purple, nil);
		end
	end
	
	--Create torrent notification
	ReStrat:createCastTrigger(ohmna, "Body Slam", torrentNotification)
	
	--Genetic Torrent 
	ReStrat:createCastAlert(ohmna, "Genetic Torrent", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, nil);
	
	--Bored
	--ReStrat:onPlayerHit("Ravage", ohmna, nil, boredCD)
	
	
	
end

-----------------------------------------------------------------------------
--Encounter Packaging
-----------------------------------------------------------------------------
if not ReStrat.tEncounters then
	ReStrat.tEncounters = {}
end

--Profile Settings
ReStrat.tEncounters["Dreadphage Ohmna"] = {
	fInitFunction = ohmnaInit,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Genetic Archives",
	tModules = {
		["Devour"] = {
			strLabel = "Devour",
			bEnabled = true,
		},
		["Genetic Torrent"] = {
			strLabel = "Genetic Torrent",
			bEnabled = true,
		},
	}
}

