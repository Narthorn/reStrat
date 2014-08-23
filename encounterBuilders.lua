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
	if ReStrat.tEncounters[strUnit].tModules[strCast].bEnabled then
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

-----------------------------------------------------------------------------------------------
-- AURA FUNCTIONS
-----------------------------------------------------------------------------------------------
--Again modular, adds to tWatchedAuras
--All processing is handled by OnGameTickManageAuras
function ReStrat:createAuraAlert(strUnit, strAuraName, duration_i, icon_i, fCallback_i)
	if ReStrat.tEncounters[strUnit].tModules[strAuraName].bEnabled then
		ReStrat.tWatchedAuras[#ReStrat.tWatchedAuras+1] = {
			name = strUnit,
			aura = strAuraName,
			tAlertInfo = {
				duration = duration_i,
				strIcon = strIcon_i,
				fCallback = fCallback_i,
				strColor = color_i
			}
		}
	end
end

--Manages creating the timer when a certain buff is found
function ReStrat:OnGameTickManageAuras()
	for i,v in ipairs(ReStrat.tUnits) do
		for q,t in ipairs(ReStrat.tWatchedAuras) do
			--Set aura
			local aura = ReStrat:findAura(ReStrat.tUnits[i].unit, ReStrat.tWatchedAuras[q].aura);
			
			--If we find an aura match
			if aura and aura.duration > 0.5 then
				
				--We attribute each buff to a different player on creation
				local alertString = ReStrat.tUnits[i].name .. " - " .. ReStrat.tWatchedAuras[q].aura;

				--Check if the alert already exists
				if ReStrat.tAlerts then
						for p,r in ipairs(ReStrat.tAlerts) do
							if ReStrat.tAlerts[p].name == alertString then
							return
						end
					end
				end
				
				--It doesn't, time to craft our alert
				--If no duration is specified we set it to the duration property of our local aura
				if not ReStrat.tWatchedAuras[q].tAlertInfo.duration then
					ReStrat.tWatchedAuras[q].tAlertInfo.duration = aura.duration;
				end
				
				--Create our alert
				ReStrat:createAlert(alertString, ReStrat.tWatchedAuras[q].tAlertInfo.duration, ReStrat.tWatchedAuras[q].tAlertInfo.strIcon, ReStrat.tWatchedAuras[q].tAlertInfo.strColor, ReStrat.tWatchedAuras[q].tAlertInfo.fCallback)
				
			end
			
		end
	end
end

--Finds an aura
function ReStrat:findAura(unit, strAura)
	if unit then
		if unit:GetBuffs() then
			local n=0;
			local buffTable = unit:GetBuffs();
			local buffName = strAura;
			for k,v in pairs(buffTable) do
				n=n+1
				if buffTable.arBeneficial[n] then
					if buffTable.arBeneficial[n].splEffect:GetName() == buffName then
						return {
							name = buffTable.arBeneficial[n].splEffect:GetName(),
							duration = buffTable.arBeneficial[n].fTimeRemaining,
							icon = buffTable.arBeneficial[n].splEffect:GetIcon(),
							flavor = buffTable.arBeneficial[n].splEffect:GetFlavor(),
							};
					end
				end
				
				if buffTable.arHarmful[n] then
					if buffTable.arHarmful[n].splEffect:GetName() == buffName then
						return {
							name = buffTable.arHarmful[n].splEffect:GetName(),
							duration = buffTable.arHarmful[n].fTimeRemaining,
							icon = buffTable.arHarmful[n].splEffect:GetIcon(),
							flavor = buffTable.arHarmful[n].splEffect:GetFlavor(),
							};
					end
				end
			end
			
			return false
		end
	end
	
	--I have failed you!
	return false;
end
