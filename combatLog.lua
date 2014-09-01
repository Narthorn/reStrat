-----------------------------------------------------------------------------------------------
-- Combatlog Functions
-- Created by Ryan Park, aka Reglitch of Codex
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Custom events, casts & auras
-----------------------------------------------------------------------------------------------

--CAST STARTING EVENT
function ReStrat:OnCastStart(strSpellName, tCasterUnit)

	--[[Add into combat log
	self.combatLog[#self.combatLog+1] = { 
		castName = strSpellName, 
		source = tCasterUnit:GetName(),
		type = "cast_start", 
		time = ReStrat.combatTimer, 
		duration = tCasterUnit:GetCastDuration() 
	}]]--
	
	--Do we have to trigger something?
	for i = 1, #ReStrat.tSpellTriggers do
		if strSpellName == ReStrat.tSpellTriggers[i].cast and tCasterUnit:GetName() == ReStrat.tSpellTriggers[i].name then
			ReStrat.tSpellTriggers[i].fCallback();
		end
	
	end
	
	--Do we have to start a timer?
	for i = 1, #ReStrat.tWatchedCasts do
		if ReStrat.tWatchedCasts[i].cast == strSpellName and tCasterUnit:GetName() == ReStrat.tWatchedCasts[i].name then

			--Get cast duration if one isn't given
			if not ReStrat.tWatchedCasts[i].tAlertInfo.duration then
				ReStrat.tWatchedCasts[i].tAlertInfo.duration = (tCasterUnit:GetCastDuration()/1000);
			end
			
			--Create alert
			ReStrat:createAlert(strSpellName, ReStrat.tWatchedCasts[i].tAlertInfo.duration, ReStrat.tWatchedCasts[i].tAlertInfo.strIcon, ReStrat.tWatchedCasts[i].tAlertInfo.strColor, ReStrat.tWatchedCasts[i].tAlertInfo.fCallback)
			
			return
		end
	end
			
end

--AURA APPLIED EVENT
function ReStrat:OnAuraApplied(intSpellId, intStackCount, tTargetUnit)
	local spell = GameLib.GetSpell(intSpellId);
	local duration = ReStrat:findAuraDuration(spell:GetName(), tTargetUnit);
	local spellName = spell:GetName();
	
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
		ReStrat:createPin(spellName .. " - " .. tTargetUnit:GetName(), tTargetUnit, nil);
	end
		
	--Create alert
	for i = 1, #ReStrat.tWatchedAuras do
		
		if ReStrat.tWatchedAuras[i] then
		
			--No specified unit
			if not ReStrat.tWatchedAuras[i].name and ReStrat.tWatchedAuras[i].aura == spell:GetName() then
			
				--Get duration if none specified
				if not ReStrat.tWatchedAuras[i].tAlertInfo.duration then
					ReStrat.tWatchedAuras[i].tAlertInfo.duration = duration;
				end	
				
				--Get icon if none specified
				if not ReStrat.tWatchedAuras[i].tAlertInfo.strIcon then
					ReStrat.tWatchedAuras[i].tAlertInfo.strIcon = spell:GetIcon();
				end
				
				local alertString = tTargetUnit:GetName() .. " - " .. spell:GetName();
				
				--Create alert
				ReStrat:createAlert(alertString, ReStrat.tWatchedAuras[i].tAlertInfo.duration, ReStrat.tWatchedAuras[i].tAlertInfo.strIcon, ReStrat.tWatchedAuras[i].tAlertInfo.strColor, ReStrat.tWatchedAuras[i].tAlertInfo.fCallback)
				
			end
			
			--Specified unit
			if ReStrat.tWatchedAuras[i].name then
				if ReStrat.tWatchedAuras[i].aura == spell:GetName() and ReStrat.tWatchedAuras[i].name == tTargetUnit:GetName() then
					--Get duration if none specified
					if not ReStrat.tWatchedAuras[i].tAlertInfo.duration then
						ReStrat.tWatchedAuras[i].tAlertInfo.duration = duration;
					end	
					
					--Get icon if none specified
					if not ReStrat.tWatchedAuras[i].tAlertInfo.strIcon then
						ReStrat.tWatchedAuras[i].tAlertInfo.strIcon = spell:GetIcon();
					end
					
					local alertString = tTargetUnit:GetName() .. " - " .. spell:GetName();
					
					--Create alert
					ReStrat:createAlert(alertString, ReStrat.tWatchedAuras[i].tAlertInfo.duration, ReStrat.tWatchedAuras[i].tAlertInfo.strIcon, ReStrat.tWatchedAuras[i].tAlertInfo.strColor, ReStrat.tWatchedAuras[i].tAlertInfo.fCallback)
					
				end
			end
		end
	end
	
end

--AURA REMOVED EVENT
function ReStrat:OnAuraRemoved(intSpellId, intStackCount, tTargetUnit)
	local spell = GameLib.GetSpell(intSpellId)
	
	--[[Create combat log event
	self.combatLog[#self.combatLog+1] = { 
		auraName = spell:GetName(), 
		target = tTargetUnit:GetName(), 
		type="aura_faded", 
		time = ReStrat.combatTimer
	}]]--
	
	--Remove pin if needed
	if self.tPinAuras[spell:GetName()] then
		ReStrat:destroyPin(tTargetUnit);
	end
end


-----------------------------------------------------------------------------------------------
-- Combat Log Hooks
-----------------------------------------------------------------------------------------------
local CombatLog = Apollo.GetAddon("CombatLog");

function ReStrat:HookCombatLog()

	---------------------
	--On Damage
	---------------------
	local oldOnDamage = CombatLog.OnCombatLogDamage
	
	CombatLog.OnCombatLogDamage = function(luaCaller, tEventArgs)		
		oldOnDamage(luaCaller, tEventArgs);
		
		if self.bInCombat then
			--[[Combat log event, damage done
			self.combatLog[#self.combatLog+1] = { 
				time = ReStrat.combatTimer,
				spell = tEventArgs.splCallingSpell:GetName(), 
				source = tEventArgs.unitCaster:GetName(),
				target = tEventArgs.unitTarget:GetName(),
				rawDamage = tEventArgs.nRawDamage,
				damage = tEventArgs.nDamageAmount,
				type = "damage_done"
			}]]--
		end
		
		--onPlayerHit check, I am sorry for whoever is reading this
		if #self.tSpellTriggers > 0 then
			if tEventArgs.unitTarget:GetType() == "Player" then
				for i = 0, #self.tSpellTriggers do
					if tEventArgs.splCallingSpell:GetName() == self.tSpellTriggers[i].spell then --If the spell is right
						if not self.tSpellTriggers[i].source then
							if not self.tSpellTriggers[i].lastcast then -- First time cast
								self.tSpellTriggers[i].lastcast = self.combatTimer;
								self.tSpellTriggers[i].callback();
							else --Else we check to see if the cooldown has expired
								if self.tSpellTriggers[i].lastcast+self.tSpellTriggers[i].cooldown < self.combatTimer then
									self.tSpellTriggers[i].callback();
								end
							end	
						else
							if self.tSpellTriggers[i].source == tEventArgs.unitCaster:GetName() then --If we have a unit filter
								if not self.tSpellTriggers[i].lastcast then -- First time cast
									self.tSpellTriggers[i].lastcast = self.combatTimer;
									self.tSpellTriggers[i].callback();
								else --Else we check to see if the cooldown has expired
									if self.tSpellTriggers[i].lastcast+self.tSpellTriggers[i].cooldown < self.combatTimer then
										self.tSpellTriggers[i].callback();
									end
								end
							end
						end
					end
				end
			end
		end
		
	end
	
	---------------------
	--On Deflect
	---------------------
	local oldOnDeflect = CombatLog.OnCombatLogDeflect
	
	CombatLog.OnCombatLogDeflect = function(luaCaller, tEventArgs)		
		oldOnDeflect(luaCaller, tEventArgs);
		
		if self.bInCombat then
			--[[Combat log event, deflect
			self.combatLog[#self.combatLog+1] = { 
				time = ReStrat.combatTimer,
				spell = tEventArgs.splCallingSpell:GetName(), 
				source = tEventArgs.unitCaster:GetName(),
				target = tEventArgs.unitTarget:GetName(),
				type = "deflect"
			}]]--
		end
	end
	
	---------------------
	--On Heal
	---------------------
	local oldOnHeal = CombatLog.OnCombatLogHeal
	
	CombatLog.OnCombatLogHeal = function(luaCaller, tEventArgs)		
		oldOnHeal (luaCaller, tEventArgs);
		
		if self.bInCombat then
			--[[Combat log event, heal
			self.combatLog[#self.combatLog+1] = { 
				time = ReStrat.combatTimer,
				spell = tEventArgs.splCallingSpell:GetName(), 
				source = tEventArgs.unitCaster:GetName(),
				target = tEventArgs.unitTarget:GetName(),
				type = "heal",
				healing = tEventArgs.nHealAmount,
			}]]--
		end
	end
	
	---------------------
	--On IA mod
	---------------------
	local oldOnIa = CombatLog.OnCombatLogModifyInterruptArmor
	
	CombatLog.OnCombatLogModifyInterruptArmor = function(luaCaller, tEventArgs)		
		oldOnIa(luaCaller, tEventArgs);
		
		if self.bInCombat then
			--[[Combat log event, IA change
			self.combatLog[#self.combatLog+1] = { 
				time = ReStrat.combatTimer,
				spell = tEventArgs.splCallingSpell:GetName(), 
				source = tEventArgs.unitCaster:GetName(),
				target = tEventArgs.unitTarget:GetName(),
				type = "IA"
			}]]--
		end
	end
	
	---------------------
	--On Absorb
	---------------------
	local oldOnAbsorb = CombatLog.OnCombatLogAbsorption
	
	CombatLog.OnCombatLogAbsorption = function(luaCaller, tEventArgs)		
		oldOnAbsorb(luaCaller, tEventArgs);

		if self.bInCombat then
			--[[Combat log event, Absorb
			self.combatLog[#self.combatLog+1] = { 
				time = ReStrat.combatTimer,
				spell = tEventArgs.splCallingSpell:GetName(), 
				source = tEventArgs.unitCaster:GetName(),
				target = tEventArgs.unitTarget:GetName(),
				amount = tEventArgs.nAmount,
				type = "absorb"
			}]]--
		end
	end
	
	---------------------
	--On Interrupt
	---------------------
	local oldOnInterrupt = CombatLog.OnCombatLogInterrupted
	
	CombatLog.OnCombatLogInterrupted = function(luaCaller, tEventArgs)		
		oldOnInterrupt(luaCaller, tEventArgs);

		if self.bInCombat then
			--[[Combat log event, in combat
			self.combatLog[#self.combatLog+1] = { 
				time = ReStrat.combatTimer,
				spell = tEventArgs.splInterruptingSpell:GetName(), 
				source = tEventArgs.unitCaster:GetName(),
				target = tEventArgs.unitTarget:GetName(),
				type = "interrupt"
			}]]--
		end
	end
	
	---------------------
	--On Death
	---------------------
	local oldOnDeath = CombatLog.OnCombatLogDeath
	
	CombatLog.OnCombatLogDeath= function(luaCaller, tEventArgs)		
		oldOnDeath(luaCaller, tEventArgs);

		if self.bInCombat then
			--[[Combat log event, in combat
			self.combatLog[#self.combatLog+1] = { 
				time = ReStrat.combatTimer,
				source = tEventArgs.unitCaster:GetName(),
				type = "death"
			}]]--
		end
	end
	
	


end







































