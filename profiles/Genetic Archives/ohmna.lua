-----------------------------------------------------------------------------
--Ohmna, Reglitch's Profile
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Fight initiation function
function ReStrat:ohmnaInit(unit)
	
	local ohmna = "Dreadphage Ohmna";
	if unit ~= nil then ReStrat:trackHealth(unit, ReStrat.color.red) end
	--Create CD timer for bored
	--local boredCD = function() ReStrat:createAlert("Bored Cooldown!", 45, nil, ReStrat.color.purple, nil) end

	--Devour
	local devourCD = function()
		ReStrat:createAlert("Devour Cooldown", 20, nil, ReStrat.color.orange, nil)
	end
	
	local devourpop = function()
		ReStrat:createPop("Devour!", nil)
		ReStrat:Sound("Sound\\devour.wav")
	end
	
	ReStrat:createCastAlert(ohmna, "Devour", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, nil);
	
	
	--AND WELCOME TO THE JAM
	local slamTimer = function()
		if not ReStrat.tEncounterVariables.slam then ReStrat.tEncounterVariables.slam = 0 end --Create the slam
		
		ReStrat.tEncounterVariables.slam = ReStrat.tEncounterVariables.slam+1;
		
		if ReStrat.tEncounterVariables.slam == 3 then
			ReStrat.tEncounterVariables.slam = 0; -- Clear our slam
			
			ReStrat:createPop("Spew Incoming!", nil);
			ReStrat:Sound("Sound\\spew.wav")
		
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
	local spewcount = function()
		if not ReStrat.tEncounterVariables.torrent then ReStrat.tEncounterVariables.torrent = 0 end
		ReStrat.tEncounterVariables.torrent = ReStrat.tEncounterVariables.torrent+1
		if ReStrat.tEncounterVariables.torrent == 2 and unit:GetHealth() > 6000000 then
			ReStrat:createPop("Add phase after Spew!", nil)
			ReStrat.tEncounterVariables.torrent = 0
		end
		
	end
	ReStrat:createCastAlert(ohmna, "Genetic Torrent", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, spewcount);
	
	
	ReStrat:OnDatachron("Dreadphage Ohmna hungers....", devourpop)
	--Bored
	--ReStrat:onPlayerHit("Ravage", ohmna, nil, boredCD)
	
	
	
end

function ReStrat:ohmnanorth(tEventObj)
	--if self:IsActivated("Maelstrom Authority", "Track Weather Cycle [Event]") then
		ReStrat:trackEvent(tEventObj, self.color.yellow, "North Generator")
	--end	
end
function ReStrat:ohmnaeast(tEventObj)
	--if self:IsActivated("Maelstrom Authority", "Track Weather Cycle [Event]") then
		ReStrat:trackEvent(tEventObj, self.color.yellow, "East Generator")
	--end	
end
function ReStrat:ohmnasouth(tEventObj)
	--if self:IsActivated("Maelstrom Authority", "Track Weather Cycle [Event]") then
		ReStrat:trackEvent(tEventObj, self.color.yellow, "South Generator")
	--end	
end
function ReStrat:ohmnawest(tEventObj)
	--if self:IsActivated("Maelstrom Authority", "Track Weather Cycle [Event]") then
		ReStrat:trackEvent(tEventObj, self.color.yellow, "West Generator")
	--end	
end
-----------------------------------------------------------------------------
--Encounter Packaging
-----------------------------------------------------------------------------
if not ReStrat.tEncounters then
	ReStrat.tEncounters = {}
end

--Profile Settings
ReStrat.tEncounters["Dreadphage Ohmna"] = {
	startFunction = ohmnaInit,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Genetic Archives",
	tModules = {
		["Devour"] = {
			strLabel = "Devour",
			bEnabled = true,
		},
		["Genetic Torrent"] = {
			strLabel = "Genetic Torrent (Spew)",
			bEnabled = true,
		},
		["Track Generators [Event]"] = {
			strLabel = "Track Generators [Event]",
			bEnabled = true,
		},
	},
}

