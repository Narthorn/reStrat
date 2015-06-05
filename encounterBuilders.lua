-----------------------------------------------------------------------------------------------
-- Encounter Building Functions
--- Created by Ryan Park, aka Reglitch of Codex
---- Maintained by Vim <Codex>
-----------------------------------------------------------------------------------------------

--Generate alert
function ReStrat:createAlert(strLabel, duration, strIcon, strColor, fCallback)
	local alertBar = Apollo.LoadForm("ReStrat.xml", "alertInstance", self.wndAlerts, self)
	local progressbar = alertBar:FindChild("ProgressBarContainer"):FindChild("progressBar")
	local icon = alertBar:FindChild("IconContainer")
	
	--Set bar label
	alertBar:FindChild("ProgressBarContainer"):FindChild("spellName"):SetText(strLabel)
	
	progressbar:SetMax(duration)
	progressbar:SetProgress(duration)
	progressbar:SetProgress(0, 1)     -- smooth fill down to 0
	progressbar:SetBarColor(strColor or self.color.red)
	
	if strIcon then icon:FindChild("Icon"):SetSprite(strIcon) else icon:Close() end
	
	tAlert = {bar = alertBar, name = strLabel, callback = fCallback, currDuration = duration, maxDuration = duration}		
	
	self.tAlerts[#self.tAlerts+1] = tAlert
	self:arrangeBars(self.tAlerts)
	
	return tAlert
end

--Repeat alert
--TODO: nCount is ambiguous, it's not the amount of repeats to be done but a counter for the callback
function ReStrat:repeatAlert(tParams, nCount)
	nCount = (nCount or 0) + 1
	local function reAlert()
		if tParams.fCallback then tParams.fCallback(nCount) end
		tParams.fDelay = nil
		ReStrat:repeatAlert(tParams, nCount) 
	end
	return ReStrat:createAlert(tParams.strLabel, tParams.fDelay or tParams.fRepeat, tParams.strIcon, tParams.strColor, reAlert)
end

--Destroy alert
function ReStrat:destroyAlert(name, bExecCallback)
	for i=#self.tAlerts,1,-1 do
		local tAlert = self.tAlerts[i]
		if tAlert.name == name then
			if bExecCallback then tAlert.callback()	end
				
			--Destroy and reshuffle bars
			tAlert.bar:Destroy()
			table.remove(self.tAlerts, i)
			self:arrangeBars(self.tAlerts)
		end
	end
end

--Clean up all alerts
function ReStrat:destroyAllAlerts()
	for i=1, #self.tAlerts do
		self.tAlerts[i].bar:Destroy()
	end
	self.tAlerts = {}
end

--Create health bar
function ReStrat:trackHealth(unit, strColor, strName)
	local wndBar = Apollo.LoadForm("ReStrat.xml", "healthInstance", self.wndHealthBars, self)
	local wndBarContainer = wndBar:FindChild("ProgressBarContainer")
	local progressBar = wndBarContainer:FindChild("progressBar")

	progressBar:SetBarColor(strColor or self.color.red)
	wndBarContainer:FindChild("unitName"):SetText(strName or unit:GetName())
	self.tHealth[unit:GetId()] = {bar = wndBar, unit = unit, tCallbacks = {}}
	
	self:OnHealthTick()
	self:arrangeBars(self.tHealth)
end

--Destroy health bar
function ReStrat:untrackHealth(unit)
	local id = unit:GetId()
	if self.tHealth[id] then
		self.tHealth[id].bar:Destroy()
		self.tHealth[id] = nil
		self:arrangeBars(self.tHealth)
	end
end

--Create pop
function ReStrat:createPop(strLabel, fTime, sound)
	self.wndPop:SetText(strLabel)
	self.popTimer = ApolloTimer.Create(fTime or 1.5, false, "destroyPop", self)
	if sound then 
		if     type(sound) == "number" then Sound.Play(sound) 
		elseif type(sound) == "string" then Sound.PlayFile(sound)
		end
	end
end

--Destroy pop
function ReStrat:destroyPop()
	self.wndPop:SetText("")
	self.popTimer = nil
end

--Create Landmark
function ReStrat:createLandmark(strLabel, tLocation, graphic)
	local landmark = Apollo.LoadForm(self.xmlDoc, "landmarkForm", "InWorldHudStratum", self)
	
	--Override graphic if need be
	if graphic then landmark:FindChild("graphic"):SetSprite(graphic) end
	
	landmark:SetWorldLocation(Vector3.New(tLocation))
	landmark:FindChild("label"):SetText(strLabel)
		
	self.tLandmarks[#self.tLandmarks+1] = {label = strLabel, form = landmark}
end

--Destroy Landmark
function ReStrat:destroyLandmark(strLabel)
	for i=#self.tLandmarks,1,-1 do
		if self.tLandmarks[i].label == strLabel then
			self.tLandmarks[i].form:Destroy()
			table.remove(self.tLandmarks, i)
		end
	end
end

--Create pin
function ReStrat:createPin(strLabel, unit, graphic)
	local pin = Apollo.LoadForm(self.xmlDoc, "pinForm", "InWorldHudStratum", self)
	
	--Override graphic if need be
	if graphic then pin:FindChild("graphic"):SetSprite(graphic) end
	
	pin:SetUnit(unit, 0)    --attach to unit
	pin:FindChild("label"):SetText(strLabel)
	
	self:destroyPin(unit) --Overwrite existing pin
	self.tPins[unit:GetName()] = pin
end

--Destroy pin
function ReStrat:destroyPin(unit)
	if self.tPins[unit:GetName()] then
		self.tPins[unit:GetName()]:Destroy()
		self.tPins[unit:GetName()] = nil
	end
end

-----------------------------------------------------------------------------------------------
-- CAST FUNCTIONS
-----------------------------------------------------------------------------------------------
--We add the spell and unit into the tWatchedCasts table then check when the cast event is fired by LCLF
function ReStrat:createCastAlert(strUnit, strCast, duration, strIcon, color, fCallback)
	ReStrat.tWatchedCasts[#ReStrat.tWatchedCasts+1] = {
		name = strUnit,
		cast = strCast,
		tAlertInfo = {
			duration = duration,
			strIcon = strIcon,
			fCallback = fCallback,
			strColor = color
		}
	}
end

--Add trigger to be checked
function ReStrat:createCastTrigger(strUnit, strCast, fCallback)
	self.tSpellTriggers[#self.tSpellTriggers+1] = {
		name = strUnit,
		cast = strCast,
		fCallback = fCallback,
	}
end

--Checks if the specified mob is casting ANYTHING
--strCast is entirely optional, if it isn't there we check for ANYTHING being cast
function ReStrat:isCasting(strUnit, strCast)
	for id,tUnit in pairs(self.tUnits) do
		if tUnit.name == strUnit then
			if (strCast and tUnit.unit.GetCastName() == strCast) -- specific cast
			or (not strCast and tUnit.unit.IsCasting())          -- any cast
			then return true end
		end
	end
	return false
end

function ReStrat:createUnitTrigger(strUnit, fCallback)
	self.tUnitTriggers[strUnit] = { fInitFunction = fCallback }
end

--Adds the requested spell into the checklist
--This is managed in the combat log hooks in combatlog.lua
function ReStrat:onPlayerHit(strSpell, strUnitSource, nCooldown, fCallback)
	if not nCooldown then nCooldown = 1 end -- By default we place a 1 second cooldown on these to avoid spam
	self.tSpellTriggers[#self.tSpellTriggers] = {source = strUnitSource, spell = strSpell, cooldown = nCooldown, callback = fCallback}
end

function ReStrat:onUnitDeath(strUnit, fCallback)
	for id,tUnit in pairs(self.tUnits) do
		if tUnit.name == strUnit then
			tUnit.fOnDeathCallback = fCallback
		end
	end
end

--Add callback on health %
function ReStrat:onHealth(unit, nTreshold, fCallback)
	for id,tHealth in pairs(ReStrat.tHealth) do
		if tHealth.unit == unit then
			tHealth.tCallbacks[nTreshold] = fCallback
		end
	end
end

-----------------------------------------------------------------------------------
-- AURA FUNCTIONS
-----------------------------------------------------------------------------------------------

function ReStrat:createAuraAlert(strUnit, strAuraName, duration, icon, fCallback)
	ReStrat.tWatchedAuras[#ReStrat.tWatchedAuras+1] = {
		name = strUnit,
		aura = strAuraName,
		tAlertInfo = {
			duration = duration,
			strIcon = strIcon,
			fCallback = fCallback,
			strColor = color
		}
	}
end

function ReStrat:createAuraTrigger(strUnit, strAura, fOnApply, fOnRemove)
	ReStrat.tAuraTriggers[#ReStrat.tAuraTriggers+1] = {
		strUnit = strUnit,
		strAura = strAura,
		fOnApply = fOnApply,
		fOnRemove = fOnRemove
	}
end

--Not very accurate, better than nothing
function ReStrat:findAuraDuration(strBuffName, unit)
	local tBuffs = unit:GetBuffs()
	
	for i=1, #tBuffs["arBeneficial"] do
		if tBuffs["arBeneficial"][i].splEffect:GetName() == strBuffName then
			return tBuffs["arBeneficial"][i].fTimeRemaining
		end
	end
	
	for i=1, #tBuffs["arHarmful"] do
		if tBuffs["arHarmful"][i].splEffect:GetName() == strBuffName then
			return tBuffs["arHarmful"][i].fTimeRemaining
		end
	end

end

--Just add into library, look in combatLog.lua for the real functionality
function ReStrat:createPinFromAura(auraName, strSprite)
	if strSprite then
		self.tPinAuras[auraName] = {sprite = strSprite}
	else
		self.tPinAuras[auraName] = {}
	end
end

--This is used in some fights as a phase trigger, quite useful
function ReStrat:OnDatachron(strText, fCallback)
	self.tDatachron[strText] = { fCallback = fCallback }
end