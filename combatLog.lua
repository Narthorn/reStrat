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
			ReStrat.tSpellTriggers[i].fCallback(tCasterUnit)
		else if strSpellName == ReStrat.tSpellTriggers[i].cast and ReStrat.tSpellTriggers[i].name == nil then
			ReStrat.tSpellTriggers[i].fCallback(tCasterUnit)
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
function ReStrat:OnAuraApplied(intSpellId, intStackCount, tTargetUnit)
	local spell = GameLib.GetSpell(intSpellId)
	local duration = ReStrat:findAuraDuration(spell:GetName(), tTargetUnit)
	local spellName = spell:GetName()
	
	--[[Create combat log event
	self.combatLog[#self.combatLog+1] = { 
		auraName = spell:GetName(), 
		target = tTargetUnit:GetName(), 
		type="aura_applied", 
		time = ReStrat.combatTimer
	}]]--
	
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
		if self.tPinAuras[spellName].bShowName == false then
			ReStrat:createPin(tTargetUnit:GetName(), tTargetUnit, self.tPinAuras[spellName].sprite, self.tPinAuras[spellName].font)
		else
			ReStrat:createPin(spellName .. " - " .. tTargetUnit:GetName(), tTargetUnit, self.tPinAuras[spellName].sprite, self.tPinAuras[spellName].font)
		end
	end
		
	--Create alert
	for i = 1, #ReStrat.tWatchedAuras do
		
		if ReStrat.tWatchedAuras[i] then
		
			--No specified unit
			if not ReStrat.tWatchedAuras[i].name and ReStrat.tWatchedAuras[i].aura == spell:GetName() then
			
				--Get duration if none specified
				if not ReStrat.tWatchedAuras[i].tAlertInfo.duration then
					ReStrat.tWatchedAuras[i].tAlertInfo.duration = duration
				end	
				
				--Get icon if none specified
				if not ReStrat.tWatchedAuras[i].tAlertInfo.strIcon then
					ReStrat.tWatchedAuras[i].tAlertInfo.strIcon = spell:GetIcon()
				end
				
				local alertString = tTargetUnit:GetName() .. " - " .. spell:GetName()
				
				--Create alert
				ReStrat:createAlert(alertString, ReStrat.tWatchedAuras[i].tAlertInfo.duration, ReStrat.tWatchedAuras[i].tAlertInfo.strIcon, ReStrat.tWatchedAuras[i].tAlertInfo.strColor, ReStrat.tWatchedAuras[i].tAlertInfo.fCallback)
				if tTargetUnit:GetName() == GameLib.GetPlayerUnit():GetName() then -- aura on player
					popstring = spell:GetName() .. " on you!"
					ReStrat:createPop(popstring, nil)
				end
			end
			
			--Specified unit
			if ReStrat.tWatchedAuras[i].name then
				if ReStrat.tWatchedAuras[i].aura == spell:GetName() and ReStrat.tWatchedAuras[i].name == tTargetUnit:GetName() then
					--Get duration if none specified
					if not ReStrat.tWatchedAuras[i].tAlertInfo.duration then
						ReStrat.tWatchedAuras[i].tAlertInfo.duration = duration
					end	
					
					--Get icon if none specified
					if not ReStrat.tWatchedAuras[i].tAlertInfo.strIcon then
						ReStrat.tWatchedAuras[i].tAlertInfo.strIcon = spell:GetIcon()
					end
					
					local alertString = tTargetUnit:GetName() .. " - " .. spell:GetName()
					
					--Create alert
					ReStrat:createAlert(alertString, ReStrat.tWatchedAuras[i].tAlertInfo.duration, ReStrat.tWatchedAuras[i].tAlertInfo.strIcon, ReStrat.tWatchedAuras[i].tAlertInfo.strColor, ReStrat.tWatchedAuras[i].tAlertInfo.fCallback)
					if tTargetUnit:GetName() == GameLib.GetPlayerUnit():GetName() then -- aura on player
						popstring = spell:GetName() .. " on you!"
						ReStrat:createPop(popstring, nil)
					end
					
				end
			end
		end
	end
	
end

--AURA REMOVED EVENT
function ReStrat:OnAuraRemoved(intSpellId, intStackCount, tTargetUnit)
	local spell = GameLib.GetSpell(intSpellId)
		
	--Remove pin if needed
	if self.tPinAuras[spell:GetName()] then
		ReStrat:destroyPin(tTargetUnit)
	end
end


-----------------------------------------------------------------------------------------------
-- Combat Log Hooks
-----------------------------------------------------------------------------------------------
function ReStrat:OnCombatLogDamage(tEventArgs)	
	if #self.tSpellTriggers > 0 then
		if tEventArgs.unitTarget then
			if tEventArgs.unitTarget:GetType() == "Player" then
				for i = 0, #self.tSpellTriggers do
					if tEventArgs.splCallingSpell then
						if self.tSpellTriggers[i] then
							if self.tSpellTriggers[i].spell then
					
								--	Print(tEventArgs.splCallingSpell:GetName())

								if tEventArgs.splCallingSpell:GetName() == self.tSpellTriggers[i].spell then --If the spell is right
									if not self.tSpellTriggers[i].source then
										if not self.tSpellTriggers[i].lastcast then -- First time cast
											self.tSpellTriggers[i].lastcast = self.combatTimer
											self.tSpellTriggers[i].callback(tEventArgs.unitCaster)
										else --Else we check to see if the cooldown has expired
											if self.tSpellTriggers[i].lastcast+self.tSpellTriggers[i].cooldown < self.combatTimer then
												self.tSpellTriggers[i].callback(tEventArgs.unitCaster)
											end
										end	
									else
										if self.tSpellTriggers[i].source == tEventArgs.unitCaster:GetName() then --If we have a unit filter
											if not self.tSpellTriggers[i].lastcast then -- First time cast
												self.tSpellTriggers[i].lastcast = self.combatTimer
												self.tSpellTriggers[i].callback(tEventArgs.unitCaster)
											else --Else we check to see if the cooldown has expired
												if self.tSpellTriggers[i].lastcast+self.tSpellTriggers[i].cooldown < self.combatTimer then
													self.tSpellTriggers[i].callback(tEventArgs.unitCaster)
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
	--...Roaming\NCSOFT\WildStar\Addons\reStrat\combatLog.lua:158: attempt to index field 'unitCaster' (a nil value)
--stack trace:
	--...Roaming\NCSOFT\WildStar\Addons\reStrat\combatLog.lua:158: in function <...Roaming\NCSOFT\WildStar\Addons\reStrat\combatLog.lua:137>
function ReStrat:OnCombatLogDeflect(tEventArgs)	end

function ReStrat:OnCombatLogHeal(tEventArgs)
	if #self.tHealTriggers > 0 then
		if tEventArgs.unitTarget then
			for i = 0, #self.tHealTriggers do
				if tEventArgs.splCallingSpell then
					if self.tHealTriggers[i] then
						if self.tHealTriggers[i].target == tEventArgs.unitTarget:GetName() then --If we have a unit filter
							if not self.tHealTriggers[i].lastcast then -- First time cast
								self.tHealTriggers[i].lastcast = self.combatTimer
								self.tHealTriggers[i].callback(tEventArgs.unitTarget)
							else --Else we check to see if the cooldown has expired
								if self.tHealTriggers[i].lastcast+self.tHealTriggers[i].cooldown < self.combatTimer then
									self.tHealTriggers[i].callback(tEventArgs.unitTarget)
								end
							end
						end
					end
				end
			end
		end
	end					
end

--[[
function mod:OnCombatLogHeal(tArgs)
	if tArgs.unitTarget and tArgs.unitTarget:GetName() == "Essence of Logic" then
		if not essenceUp[tArgs.unitTarget:GetId()] then
			--Print("Found EssLogic : ".. tArgs.unitTarget:GetId())
			essenceUp[tArgs.unitTarget:GetId()] = true
			local essPos = tArgs.unitTarget:GetPosition()
			core:MarkUnit(tArgs.unitTarget, 0, (essPos.x < 4310) and "L" or "R")
			core:AddUnit(tArgs.unitTarget)
			if #essenceUp == 2 then
				--Print("Found 2 essences")
				Apollo.RemoveEventHandler("CombatLogHeal", self)
			end
		end
	end
end
--]]

function ReStrat:OnCombatLogModifyInterruptArmor(tEventArgs) end

function ReStrat:OnCombatLogAbsorption(tEventArgs) end

function ReStrat:OnCombatLogInterrupted(tEventArgs)	end

function ReStrat:OnUnitDied(tUnitKilled)		
	ReStrat:destroyPin(tUnitKilled)
end
