-----------------------------------------------------------------------------------------------
-- Encounter Building Functions
-- Created by Ryan Park, aka Reglitch of Codex
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- CAST FUNCTIONS
-----------------------------------------------------------------------------------------------

--OnGameTickManageCasts()
function ReStrat:OnGameTickManageCasts()
	for i,v in ipairs(ReStrat.tUnits) do
		for q,t in ipairs(ReStrat.tWatchedCasts) do
			if ReStrat.tUnits[i].unit then
				if ReStrat.tUnits[i].name == ReStrat.tWatchedCasts[q].name and ReStrat.tUnits[i].unit:GetCastName() == ReStrat.tWatchedCasts[q].cast then
					--Unit is casting, check if alert already exists
					if ReStrat.tAlerts then
						for p,r in ipairs(ReStrat.tAlerts) do
							if ReStrat.tAlerts[p].name == ReStrat.tWatchedCasts[q].cast then
								return
							end
						end
					end
					
					--If no cast time is specified scrape it from unit, divide by 1000 to convert to seconds!
					if not ReStrat.tWatchedCasts[q].tAlertInfo.duration then
						ReStrat.tWatchedCasts[q].tAlertInfo.duration = (ReStrat.tUnits[i].unit:GetCastDuration()/1000);
					end
					
					
					--Some indicated cast timers are actually shorter than the cast
					if ReStrat.tUnits[i].unit:GetCastTotalPercent() > 50 then
						return
					end
					
					--If we haven't found cast then create alert
					ReStrat:createAlert(ReStrat.tWatchedCasts[q].cast, ReStrat.tWatchedCasts[q].tAlertInfo.duration, ReStrat.tWatchedCasts[q].tAlertInfo.strIcon, ReStrat.tWatchedCasts[q].tAlertInfo.strColor, ReStrat.tWatchedCasts[q].tAlertInfo.fCallback)
				end
			end
		end
	end
end


--Modularization is heavy here, we do not reiterate on the same function to continually check
--We add the spell and unit into the tWatchedCasts table then during the game tick we iterate on that instead
--To see the function which manages the processing of that search for ReStrat:OnGameTickManageCasts()
function ReStrat:createCastAlert(strUnit, strCast, duration_i, strIcon_i, color_i, fCallback_i)
	ReStrat.tWatchedCasts[#ReStrat.tWatchedCasts+1] = {
		name = strUnit,
		cast = strCast,
		tAlertInfo = {
			duration = duration_i,
			strIcon = strIcon_i,
			fCallback = fCallback_i,
			strColor = color_i
		}
	}
end


--checks if the specified mob is casting ANYTHING
--strCast is entirely optional, if it isn't there we check for ANYTHING being cast
function ReStrat:isCasting(strUnit, strCast)

	--If we don't have a specified cast to check for
	if not strCast then
		for i,v in ipairs(ReStrat.tUnits) do
			if ReStrat.tUnits[i].name == strUnit then
				if ReStrat.tUnits[i].unit.IsCasting() then return true end
			end
		end
		
		return false
	end
	
	--We need to check for a specified cast
	for i,v in ipairs(ReStrat.tUnits) do
		if ReStrat.tUnits[i].name == strUnit then
			if ReStrat.tUnits[i].unit.GetCastName() == strCast then return true end
		end
	end
	
	return false
	
end
