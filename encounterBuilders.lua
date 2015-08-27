-----------------------------------------------------------------------------------------------
-- Encounter Building Functions
--- Created by Ryan Park, aka Reglitch of Codex
---- Maintained by Vim <Codex>
-----------------------------------------------------------------------------------------------

--General Settings
ReStrat.tEncounters["General Settings"] = {
        startFunction = asdfasdfasdfas,
        --fSpamFunction = profileDebugRepeat,
        strCategory  = "General Settings",
        tModules = {
                ["GenPopMessages"] = {
                        strLabel = "Pop Messages",
                        bEnabled = true,
                },				
                ["GenBossLife"] = {
                        strLabel = "Boss Life",
                        bEnabled = true,
                },
				["GenSounds"] = {
                        strLabel = "Play Sounds",
                        bEnabled = false,
                },
				["GenEvents"] = {
                        strLabel = "Track Events",
                        bEnabled = true,
                },
				["GenLandmark"] = {
                        strLabel = "Landmarks",
                        bEnabled = true,
                },
        },
}


ReStrat.tEncounters["Version"] = {
			tfileversion = ReStrat.fileversion,
			tcleanversion = ReStrat.version,
			strCategory  = ReStrat.version,
		}
--Generate alert


function ReStrat:Sound(strfile) --"Sound\\quack.wav"
	if ReStrat.tEncounters["General Settings"].tModules["GenSounds"].bEnabled then
		Sound.PlayFile("Sound\\TimerNew2.wav")
		Sound.PlayFile(strfile)
	end
end

function ReStrat:dist2unit(unitSource, unitTarget)
	if not unitSource or not unitTarget then return 999 end
	local sPos = unitSource:GetPosition()
	local tPos = unitTarget:GetPosition()

	local sVec = Vector3.New(sPos.x, sPos.y, sPos.z)
	local tVec = Vector3.New(tPos.x, tPos.y, tPos.z)

	local dist = (tVec - sVec):Length()

	return tonumber(dist)
end

function ReStrat:dist2coords(unitSource, nX, nY, nZ)
	if not unitSource then return 999 end
	local sPos = unitSource:GetPosition()

	local sVec = Vector3.New(sPos.x, sPos.y, sPos.z)
	local tVec = Vector3.New(nX, nY, nZ)

	local dist = (tVec - sVec):Length()

	return tonumber(dist)
end


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
	
	if strIcon then
		icon:FindChild("Icon"):SetSprite(strIcon)
	else
		icon:Close()
	end
			
	self.tAlerts[#self.tAlerts+1] = {bar = alertBar, name = strLabel, callback = fCallback, currDuration = duration, maxDuration = duration}
	
	self:arrangeBars(self.tAlerts, "timer")
end

--Make a repeating alert
function ReStrat:repeatAlert(tParams, nCount)
	nCount = (nCount or 0) + 1
	local function reAlert()
		if tParams.fCallback then tParams.fCallback(nCount) end
		tParams.fDuration = tParams.fRepeat or tParams.fDuration
		ReStrat:repeatAlert(tParams, nCount)
	end
	ReStrat:createAlert(tParams.strLabel, tParams.fDelay or tParams.fRepeat, tParams.strIcon, tParams.strColor, reAlert)
end



--Destroy alert
function ReStrat:destroyAlert(name, bExecCallback)
	for i=#self.tAlerts,1,-1 do
		local tAlert = self.tAlerts[i]
		if tAlert.name == name then
			if bExecCallback then
				tAlert.callback()
			end
				
			--Destroy and remove
			tAlert.bar:Destroy()
			table.remove(self.tAlerts, i)
			self:arrangeBars(self.tAlerts, "timer")
		end
	end
end

function ReStrat:destroyAllAlerts()
	for i=1, #self.tAlerts do
		self.tAlerts[i].bar:Destroy()
	end
	self.tAlerts = {}
end

function ReStrat:trackHealth(unit, strColor, displayname)
	if ReStrat.tEncounters["General Settings"].tModules["GenBossLife"].bEnabled and self.tHealth[unit:GetId()] == nil then
		local wndBar = Apollo.LoadForm("ReStrat.xml", "healthInstance", self.wndHealthBars, self)
		local wndBarContainer = wndBar:FindChild("ProgressBarContainer")
		local progressBar = wndBarContainer:FindChild("progressBar")
	
		progressBar:SetBarColor(strColor or self.color.red)
		if displayname == nil then
			wndBarContainer:FindChild("unitName"):SetText(unit:GetName())
			barName = unit:GetName()
		else
			wndBarContainer:FindChild("unitName"):SetText(displayname)
			barName = displayname
		end
		self.tHealth[unit:GetId()] = {bar = wndBar, unit = unit, current = 100, orgName = barName}
			
		self:OnHealthTick()
		self:arrangeBars(self.tHealth, "health")

		return true
	end
end

function ReStrat:trackEvent(tEventObj, strColor, displayname)
	if ReStrat.tEncounters["General Settings"].tModules["GenEvents"].bEnabled then	
		if self.tHealth[tEventObj:GetObjectiveId()] == nil then -- track event if not doing that already
			local wndBar = Apollo.LoadForm("ReStrat.xml", "healthInstance", self.wndHealthBars, self)
			local wndBarContainer = wndBar:FindChild("ProgressBarContainer")
			local progressBar = wndBarContainer:FindChild("progressBar")
			
			progressBar:SetBarColor(strColor or self.color.yellow)
			if displayname == nil then
				wndBarContainer:FindChild("unitName"):SetText(tEventObj:GetShortDescription())
			else
				wndBarContainer:FindChild("unitName"):SetText(displayname)
			end
			
			--Print("new event")
			self.tHealth[tEventObj:GetObjectiveId()] = {bar = wndBar, tEventObj = tEventObj, isevent = true, current = 100}
			
			
			self:OnHealthTick()
			self:arrangeBars(self.tHealth, "health")
		end
	end
end


function ReStrat:untrackHealth(unit)
	if self.tHealth[unit:GetId()] then
		self.tHealth[unit:GetId()].bar:Destroy()
		self.tHealth[unit:GetId()] = nil
		self:arrangeBars(self.tHealth, "health")
	end
end

function ReStrat:untrackEvent(eventobj)
	if self.tHealth[eventobj:GetObjectiveId()] then
		self.tHealth[eventobj:GetObjectiveId()].bar:Destroy()
		self.tHealth[eventobj:GetObjectiveId()] = nil
		self:arrangeBars(self.tHealth, "health")
	end
end

--Create pop
function ReStrat:createPop(strLabel, fTime)
	if ReStrat.tEncounters["General Settings"].tModules["GenPopMessages"].bEnabled then
		self.wndPop:SetText(strLabel)
		self.popTimer = ApolloTimer.Create(fTime or 2, false, "destroyPop", self)
	end
end

--Destroy pop
function ReStrat:destroyPop()
	self.wndPop:SetText("")
	self.popTimer = nil
end


--Create Landmark
function ReStrat:createLandmark(strLabel, tLocation, graphic, strFont)
	if ReStrat.tEncounters["General Settings"].tModules["GenLandmark"].bEnabled then
		local landmark = Apollo.LoadForm(self.xmlDoc, "landmarkForm", "InWorldHudStratum", self)
	
		--Set position
		landmark:SetWorldLocation(Vector3.New(tLocation))
		
		--Set label
		landmark:FindChild("label"):SetText(strLabel)
		
		--Set font if need be : -- "Subtitle" "CRB_Interface14_BO" = Standard
		if strFont then landmark:FindChild("label"):SetFont(strFont) end
		
		--Set graphic if need be : -- "ClientSprites:MiniMapMarkerTiny" "respr:landmark" = Standard
		if graphic then landmark:FindChild("graphic"):SetSprite(graphic) end
		
		--Add to tLandmarks
		self.tLandmarks[#self.tLandmarks+1] = {label = strLabel, form = landmark}
	end
end

--Destroy Landmark
function ReStrat:destroyLandmark(strLabel)
	--Print("trying to destroy LM: " .. strLabel)
	for i = 1, #self.tLandmarks do
		if self.tLandmarks[i].label == strLabel then
			self.tLandmarks[i].form:Destroy()
			table.remove(self.tLandmarks, i)
		end
	end
end



--Destroy Landmarks
function ReStrat:destroyAllLandmarks()
	for k,v in pairs(self.tLandmarks) do
		v.form:Destroy()
	end
	self.tLandmarks = {}
end

--Create pin
function ReStrat:createPin(strLabel, unit, graphic, strFont)
	if ReStrat.tEncounters["General Settings"].tModules["GenLandmark"].bEnabled then
		
		local pin = Apollo.LoadForm(self.xmlDoc, "pinForm", "FixedHudStratumHigh", self)
		local label = pin:FindChild("label")
		local graphicform = pin:FindChild("graphic")
		
		--Set font if need be : -- "Subtitle" "CRB_Interface14_BO" "CRB_Pixel_O" = Standard
		if strFont then label:SetFont(strFont) end
			
		--Set graphic if need be : -- "ClientSprites:MiniMapMarkerTiny" "respr:landmark" = Standard
		if graphic then graphicform:SetSprite(graphic) end
			
		label:SetText(strLabel) --set label
		
		pin:SetUnit(unit, 0) --attach to unit
		local unitName = unit:GetName()
		if unitName ~= "Detonation Bomb" and unitName ~= "Holo Hand" then -- special case for bombs at phagemaw
			if self.tPins[unit:GetName()] then self.tPins[unit:GetName()]:Destroy() end --Overwrite existing pin
		end
		
		if unitName ~= "Detonation Bomb" and unitName ~= "Holo Hand" then
			self.tPins[unit:GetName()] = pin --Create the new pin
		else
			self.tPins[unit:GetId()] = pin --Create the new pin using the id for this special case
		end

		
	end
end

--Destroy pin
function ReStrat:destroyPin(unit)
	if unit:GetName() == "Holo Hand" or unit:GetName() == "Detonation Bomb" then --special case, use id
		if self.tPins[unit:GetId()] then self.tPins[unit:GetId()]:Destroy(); self.tPins[unit:GetId()] = nil end
	end

	if self.tPins[unit:GetName()] then self.tPins[unit:GetName()]:Destroy(); self.tPins[unit:GetName()] = nil end
end

function ReStrat:destroyAllPins()
	for k,v in pairs(self.tPins) do
		self.tPins[k]:Destroy()
	end
	self.tPins = {}
end
-----------------------------------------------------------------------------------------------
-- CAST FUNCTIONS
-----------------------------------------------------------------------------------------------
--Modularization is heavy here, we do not reiterate on the same function to continually check
--We add the spell and unit into the tWatchedCasts table then check when the cast event is fired by LCLF
function ReStrat:createCastAlert(strUnit, strCast, duration_i, strIcon_i, color_i, fCallback_i, fCallbackStart, bSkipActivatedCheck) --fCallbackStart will be called when the cast starts and fCallback will be called once it ends
	if bSkipActivatedCheck == true then
		if fCallbackStart ~= nil then
			ReStrat:createCastTrigger(strUnit, strCast, fCallbackStart)
		end
		ReStrat.tWatchedCasts[#ReStrat.tWatchedCasts+1] = {
			name = strUnit,
			cast = strCast,
			tAlertInfo = {
				duration = duration_i,
				strIcon = strIcon_i,
				fCallback = fCallback_i,
				strColor = color_i,
				fCallbackStart = fCallbackStart
			}
		}
	else
		if ReStrat.tEncounters[strUnit] then		
			if ReStrat.tEncounters[strUnit].tModules[strCast].bEnabled then

				if fCallbackStart ~= nil then
					ReStrat:createCastTrigger(strUnit, strCast, fCallbackStart)
				end
				ReStrat.tWatchedCasts[#ReStrat.tWatchedCasts+1] = {
					name = strUnit,
					cast = strCast,
					tAlertInfo = {
						duration = duration_i,
						strIcon = strIcon_i,
						fCallback = fCallback_i,
						strColor = color_i,
						fCallbackStart = fCallbackStart
					}
				}
			end
		end
	end
end

--Add trigger to be checked
--This will call the callback function and returns the caster as first parameter
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
	for id,tUnit in pairs(self.tUnits) do
		if tUnit.name == strUnit then
			if (strCast and tUnit.unit.GetCastName() == strCast) -- specific cast
			or (not strCast and tUnit.unit.IsCasting())          -- any cast
			then return true end
		end
	end
	return false
end

function ReStrat:createActionBarTrigger(strSkillname, fCallback)
	self.tActionBarTrigger[#self.tActionBarTrigger+1] = { strTriggerName = strSkillname, fInitFunction = fCallback }
end

function ReStrat:createUnitTrigger(strUnit, fCallback)
	self.tUnits[strUnit] = { fInitFunction = fCallback }
end

function ReStrat:createHpTrigger(strUnit, nHealth, fCallback)
	self.tHpTriggers[strUnit] = { fInitFunction = fCallback, nTriggerHP = nHealth }
end

--Adds the requested spell into the checklist
--This is managed in the combat log hooks in combatlog.lua
--This will call the callback function and returns the caster as first parameter
function ReStrat:onPlayerHit(strSpell, strUnitSource, nCooldown, fCallback)
	if not nCooldown then nCooldown = 1 end -- By default we place a 1 second cooldown on these to avoid spam
	self.tSpellTriggers[#self.tSpellTriggers] = {source = strUnitSource, spell = strSpell, cooldown = nCooldown, callback = fCallback}
end

--This is managed in the combat log hooks in combatlog.lua
--This will call the callback function and returns the target as first parameter
function ReStrat:onHeal(strUnitTarget, nCooldown, fCallback)
	if not nCooldown then nCooldown = 1 end -- By default we place a 1 second cooldown on these to avoid spam
	self.tHealTriggers[#self.tHealTriggers] = {target = strUnitTarget, cooldown = nCooldown, callback = fCallback}
end

function ReStrat:onUnitDeath(strUnit, fCallback)
	for id,tUnit in pairs(self.tUnits) do
		if tUnit.name == strUnit then
			tUnit.fOnDeathCallback = fCallback
		end
	end
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
	
	--if ReStrat.tEncounters[strUnit].tModules[strAuraName].bEnabled then
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
	--end	
	
end

--Not very accurate, better than nothing
function ReStrat:findAuraDuration(strBuffName, unit)
	local tBuffs = unit:GetBuffs()
	
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

--"Subtitle" "CRB_Interface14_BO" "CRB_Pixel_O" = Standard
function ReStrat:createPinFromAura(auraName, strSprite, bShowAuraName, strFont)
	self.tPinAuras[auraName] = {}
	self.tPinAuras[auraName] = {sprite = strSprite, bShowName = bShowAuraName, font = strFont}
end

--This is used in some fights as a phase trigger, quite useful
function ReStrat:OnDatachron(strText, fCallback)
	if not self.tDatachron then self.tDatachron = {} end
	self.tDatachron[strText] = { fCallback = fCallback, strText = strText}
end

function ReStrat:OnPartychron(strText, fCallback)
	if not self.tPartychron then self.tPartychron = {} end
	self.tPartychron[strText] = { fCallback = fCallback, strText = strText}
end

