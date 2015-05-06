-----------------------------------------------------------------------------------------------
-- Combatlog Functions
--- Created by Ryan Park, aka Reglitch of Codex
---- Maintained by Vim <Codex>
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- Custom events, casts & auras
-----------------------------------------------------------------------------------------------

--CAST STARTING EVENT
function ReStrat:OnCastStart(strSpellName, tCasterUnit)
	
	--Do we have to trigger something?
	for i = 1, #ReStrat.tSpellTriggers do
		if strSpellName == ReStrat.tSpellTriggers[i].cast and tCasterUnit:GetName() == ReStrat.tSpellTriggers[i].name then
			ReStrat.tSpellTriggers[i].fCallback()
		else if strSpellName == ReStrat.tSpellTriggers[i].cast and ReStrat.tSpellTriggers[i].name == nil then
			ReStrat.tSpellTriggers[i].fCallback()
		end
		end
	end
	
	--Do we have to start a timer?
	for i = 1, #ReStrat.tWatchedCasts do
		if ReStrat.tWatchedCasts[i].cast == strSpellName and tCasterUnit:GetName() == ReStrat.tWatchedCasts[i].name then

			--Get cast duration if one isn't given
			if not ReStrat.tWatchedCasts[i].tAlertInfo.duration then
				ReStrat.tWatchedCasts[i].tAlertInfo.duration = (tCasterUnit:GetCastDuration()/1000)
			end
			
			--Create alert
			ReStrat:createAlert(strSpellName, ReStrat.tWatchedCasts[i].tAlertInfo.duration, ReStrat.tWatchedCasts[i].tAlertInfo.strIcon, ReStrat.tWatchedCasts[i].tAlertInfo.strColor, ReStrat.tWatchedCasts[i].tAlertInfo.fCallback)
			
			return
		end
	end
			
end

--AURA APPLIED EVENT
function ReStrat:OnAuraApplied(tTargetUnit, tBuff)
	if tTargetUnit and tTargetUnit:IsValid() then
		local intStackCount = tBuff.nCount
		local spell = tBuff.splEffect
		local spellName = spell:GetName()
		local targetName = tTargetUnit:GetName()
		local duration = tBuff.fTimeRemaining
		
		--Add the information to our cache
		if not self.tAuraCache[spellName] then
			self.tAuraCache[spellName] = {
				nMaxDuration = math.ceil(duration*10)*0.1,
				strIcon = spell:GetIcon(),
				strFlavor = spell:GetFlavor()
			}
		end
		
		--Create pin if needed
		if self.tPinAuras[spellName] then
			ReStrat:createPin(spellName .. " - " .. targetName, tTargetUnit, self.tPinAuras[spellName].sprite)
		end
		
		--Create alert
		for i = 1, #ReStrat.tWatchedAuras do
			
			if ReStrat.tWatchedAuras[i] and ReStrat.tWatchedAuras[i].aura == spellName then
			
				if not ReStrat.tWatchedAuras[i].name or ReStrat.tWatchedAuras[i].name == targetName then
				
					--Get duration if none specified
					if not ReStrat.tWatchedAuras[i].tAlertInfo.duration then
						ReStrat.tWatchedAuras[i].tAlertInfo.duration = duration
					end	
					
					--Get icon if none specified
					if not ReStrat.tWatchedAuras[i].tAlertInfo.strIcon then
						ReStrat.tWatchedAuras[i].tAlertInfo.strIcon = spell:GetIcon()
					end
					
					local alertString = spellName .. " - " .. targetName
					
					if ReStrat.tWatchedAuras[i].tAlertInfo.duration > 0 then
						--Create alert
						ReStrat:createAlert(alertString, ReStrat.tWatchedAuras[i].tAlertInfo.duration, ReStrat.tWatchedAuras[i].tAlertInfo.strIcon, ReStrat.tWatchedAuras[i].tAlertInfo.strColor, ReStrat.tWatchedAuras[i].tAlertInfo.fCallback)
					else
						ReStrat.tWatchedAuras[i].tAlertInfo.fCallback(tTargetUnit)
					end
					
				end
			end
		end
	end
end
	
--AURA REMOVED EVENT
function ReStrat:OnAuraRemoved(unit, tBuff)
	if unit and unit:IsValid() then
		local spell = tBuff.splEffect
		
		--Remove pin if needed
		if self.tPinAuras[spell:GetName()] then
			ReStrat:destroyPin(unit)
		end
	end
end


-----------------------------------------------------------------------------------------------
-- Combat Log Hooks
-----------------------------------------------------------------------------------------------
function ReStrat:OnCombatLogDamage(tEventArgs)		
		
	--onPlayerHit check, I am sorry for whoever is reading this
	if #self.tSpellTriggers > 0 then
		if tEventArgs.unitTarget then
			if tEventArgs.unitTarget:GetType() == "Player" then
				for i = 0, #self.tSpellTriggers do
					if tEventArgs.splCallingSpell then
						if self.tSpellTriggers[i] then
							if self.tSpellTriggers[i].spell then
								if tEventArgs.splCallingSpell:GetName() == self.tSpellTriggers[i].spell then --If the spell is right
									if not self.tSpellTriggers[i].source then
										if not self.tSpellTriggers[i].lastcast then -- First time cast
											self.tSpellTriggers[i].lastcast = self.combatTimer
											self.tSpellTriggers[i].callback()
										else --Else we check to see if the cooldown has expired
											if self.tSpellTriggers[i].lastcast+self.tSpellTriggers[i].cooldown < self.combatTimer then
												self.tSpellTriggers[i].callback()
											end
										end	
									else
										if self.tSpellTriggers[i].source == tEventArgs.unitCaster:GetName() then --If we have a unit filter
											if not self.tSpellTriggers[i].lastcast then -- First time cast
												self.tSpellTriggers[i].lastcast = self.combatTimer
												self.tSpellTriggers[i].callback()
											else --Else we check to see if the cooldown has expired
												if self.tSpellTriggers[i].lastcast+self.tSpellTriggers[i].cooldown < self.combatTimer then
													self.tSpellTriggers[i].callback()
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
	
function ReStrat:OnCombatLogDeflect(tEventArgs)	end

function ReStrat:OnCombatLogHeal(tEventArgs) end

function ReStrat:OnCombatLogModifyInterruptArmor(tEventArgs) end

function ReStrat:OnCombatLogAbsorption(tEventArgs) end

function ReStrat:OnCombatLogInterrupted(tEventArgs)	end

function ReStrat:OnUnitDied(tUnitKilled)		
	ReStrat:destroyPin(tUnitKilled)
end
