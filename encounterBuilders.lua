-----------------------------------------------------------------------------------------------
-- Encounter Building Functions
-- Created by Ryan Park, aka Reglitch of Codex
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- CAST FUNCTIONS
-----------------------------------------------------------------------------------------------
--Modularization is heavy here, we do not reiterate on the same function to continually check
--We add the spell and unit into the tWatchedCasts table then check when the cast event is fired by LCLF
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

--Add trigger to be checked
function ReStrat:createCastTrigger(strUnit, strCast, fCallback_i)
	self.tSpellTriggers[#self.tSpellTriggers+1] = {
		name = strUnit,
		cast = strCast,
		fCallback = fCallback_i
	}
end

--Checks if the specified mob is casting ANYTHING
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

--Adds the requested spell into the checklist
--This is managed in the combat log hooks in combatlog.lua
function ReStrat:onPlayerHit(strSpell, strUnitSource, nCooldown, fCallback)
	if not nCooldown then nCooldown = 1 end -- By default we place a 1 second cooldown on these to avoid spam
	self.tSpellTriggers[#self.tSpellTriggers] = {source = strUnitSource, spell = strSpell, cooldown = nCooldown, callback = fCallback};
end


-----------------------------------------------------------------------------------
-- AURA FUNCTIONS
-----------------------------------------------------------------------------------------------
--Again modular, adds to tWatchedAuras
--All processing is handled by OnAuraApplied
function ReStrat:createAuraAlert(strUnit, strAuraName, duration_i, icon_i, fCallback_i)

	if not ReStrat.tEncounters[strUnit] then
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
		
		return
	end
	
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
		
		return
	end	
	
end

--Not very accurate, better than nothing
function ReStrat:findAuraDuration(strBuffName, unit)
	local tBuffs = unit:GetBuffs();
	
	--Benficial
	for i=1, #tBuffs["arBeneficial"] do
		if tBuffs["arBeneficial"][i].splEffect:GetName() == strBuffName then
			return tBuffs["arBeneficial"][i].fTimeRemaining
		end
	end
	
	--Harmful
	for i=1, #tBuffs["arHarmful"] do
		if tBuffs["arHarmful"][i].splEffect:GetName() == strBuffName then
			return tBuffs["arHarmful"][i].fTimeRemaining
		end
	end

end

