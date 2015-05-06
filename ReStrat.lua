-----------------------------------------------------------------------------------------------
-- reStrat - Wildstar Boss Mods
--- Created by Ryan Park, aka Reglitch of Codex
---- Maintained by Vim <Codex>
-----------------------------------------------------------------------------------------------

require "Sound"
 
ReStrat = {
	name = "ReStrat",
	version = "1.4.16",
	barSpacing = 9,
	color = {
		red = "ffb8413d",
		orange = "ffdd7649",
		yellow = "fff8fd6b",
		green = "ff58cc5d",
		blue = "ff5196ec",
		purple = "ff915fc2",
		black = "black",
		white = "white",
	},
	
	tAlerts = {},
	tHealth = {},
	tUnits = {},
	tWatchedCasts = {},
	tWatchedAuras = {},
	tZones = {},
	combatTimer = nil,
	combatStarted = nil,
	combatLog = {},
	tSpellTriggers = {},
	tShortcutBars = {},
	tAuraCache = {},
	tPins = {},
	tPinAuras = {},
	tEncounterVariables = {},
	tDatachron = {},
	tLandmarks = {},
	tEncounters = {},
} 
 
-----------------------------------------------------------------------------------------------
-- ReStrat OnLoad
-----------------------------------------------------------------------------------------------
function ReStrat:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ReStrat.xml")

	Apollo.LoadSprites("respr.xml", "SassyMedicSimSprites") 

	self.wndMain          = Apollo.LoadForm(self.xmlDoc, "mainForm", nil, self)
	self.wndHealthBars    = Apollo.LoadForm(self.xmlDoc, "healthForm", nil, self)
    self.wndAlerts        = Apollo.LoadForm(self.xmlDoc, "alertForm", nil, self)
	self.wndPop           = Apollo.LoadForm(self.xmlDoc, "popForm", nil, self)
	self.wndIcon          = Apollo.LoadForm(self.xmlDoc, "iconForm", nil, self)
	self.wndLog           = Apollo.LoadForm(self.xmlDoc, "logForm", nil, self)
	self.wndSettings      = Apollo.LoadForm(self.xmlDoc, "settingsForm", nil, self)
	self.wndActionBarItem = Apollo.LoadForm(self.xmlDoc, "ActionBarShortcutItem", nil, self)
	
	-- Register handlers for events, slash commands and timer, etc.
	Apollo.RegisterSlashCommand("restrat", "OnReStrat", self)
	Apollo.RegisterEventHandler("WindowManagementReady", "OnWindowManagementReady", self)
	
	Apollo.RegisterEventHandler("UnitCreated",           "OnUnitCreated",       self)
	Apollo.RegisterEventHandler("UnitDestroyed",         "OnUnitDestroyed",     self)
	Apollo.RegisterEventHandler("UnitEnteredCombat",     "OnEnteredCombat",     self)
	Apollo.RegisterEventHandler("PlayerResurrected",     "OnPlayerResurrected", self)
	
	Apollo.RegisterEventHandler("ShowResurrectDialog", 	 "OnShowResurrectDialog",   self)
	Apollo.RegisterEventHandler("UpdateResurrectDialog", "OnUpdateResurrectDialog", self)

	Apollo.RegisterEventHandler("ChatMessage",           "OnChatMessage",       self)
	Apollo.RegisterEventHandler("ShowActionBarShortcut", "OnShowActionBarShortcut", self)
	
	Apollo.RegisterEventHandler("CombatLogDamage" ,              "OnCombatLogDamage",               self)
	Apollo.RegisterEventHandler("CombatLogDeflect",              "OnCombatLogDeflect",              self)
	Apollo.RegisterEventHandler("CombatLogHeal",                 "OnCombatLogHeal",                 self)
	Apollo.RegisterEventHandler("CombatLogModifyInterruptArmor", "OnCombatLogModifyInterruptArmor", self)
	Apollo.RegisterEventHandler("CombatLogAbsorption",           "OnCombatLogAbsorption",           self)
	Apollo.RegisterEventHandler("CombatLogInterrupted",          "OnCombatLogInterrupted",          self)
	
	Apollo.RegisterEventHandler("BuffAdded",   "OnAuraApplied", self)
	Apollo.RegisterEventHandler("BuffUpdated", "OnAuraUpdated", self)
	Apollo.RegisterEventHandler("BuffRemoved", "OnAuraRemoved", self)
	
	Apollo.RegisterEventHandler("_LCLF_UnitDied",       "OnUnitDied",  self)
	Apollo.RegisterEventHandler("_LCLF_SpellCastStart", "OnCastStart", self)
	
	--This timer drives alerts and combat time
	self.gameTimer = ApolloTimer.Create(0.1, true, "OnGameTick", self)
	self.gameTimer:Stop()
	
	--This timer drives health bar updates
	self.healthTimer = ApolloTimer.Create(0.5, true, "OnHealthTick", self)
	self.healthTimer:Stop()

	--This timer delays stopping the fight until 7 seconds after the player gets out of combat
    --to allow i.e. spellslingers to voidslip without timers ripping
	self.outofcombatTimer = ApolloTimer.Create(7, false, "OnCombatTimeout", self)
	self.outofcombatTimer:Stop()
end

-----------------------------------------------------------------------------------------------
-- ReStrat Functions
-----------------------------------------------------------------------------------------------
--Add windows to carbines window management
function ReStrat:OnWindowManagementReady()
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndHealthBars, strName = "reStratHealthBars"})
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndAlerts, strName = "reStratAlert"})
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndPop, strName = "reStratPop"})
end

function ReStrat:OnGameTick()
	self.combatTimer = GameLib.GetGameTime() - self.combatStarted
	
	--Process alerts backwards so we can remove alerts as we go
	for i=#self.tAlerts,1,-1 do
		local alertInstance = self.tAlerts[i]
		
		--Manage actual time degradation, this accounts for lag spikes etc.
		if alertInstance.lastTime then
			alertInstance.currDuration = alertInstance.currDuration-(GameLib.GetGameTime()-alertInstance.lastTime)
		end
		alertInstance.lastTime = GameLib.GetGameTime()
		
		--Update time, callback if expired
		if alertInstance.currDuration >= 0 then	
			local timer = alertInstance.bar:FindChild("ProgressBarContainer"):FindChild("timeLeft")
			timer:SetText(string.format("%.1fS", alertInstance.currDuration))
		else
			alertInstance.bar:Destroy()
			
			local callback = alertInstance.callback	--Need to remove alert from table prior to executing callback
			table.remove(self.tAlerts, i)           --in case the callback destroys other alerts and fucks up table indices
			if callback then callback()	end
			
			--Reshuffle windows
			self:arrangeBars(self.tAlerts)	
		end
	end
end

-- Health tracking
-- Adapted from <Hindsight> code: https://github.com/Errc27/ReStrat/
function ReStrat:OnHealthTick()
	for id,tHealth in pairs(self.tHealth) do
		local unit = tHealth.unit
		if unit:IsValid() then
			local wndBar = tHealth.bar:FindChild("ProgressBarContainer")
			local progressBar = wndBar:FindChild("progressBar")
			local cur = unit:GetHealth() or 0
			local max = unit:GetMaxHealth() or 0
			local pct = cur/max*100
		
			for nTreshold, fCallback in pairs(tHealth.tCallbacks) do
				if pct < nTreshold then 
					fCallback(tHealth.unit, cur)
					tHealth.tCallbacks[nTreshold] = nil
				end
			end
			
			progressBar:SetMax(max)
			progressBar:SetProgress(cur)
			wndBar:FindChild("healthAmount"):SetText(string.format("%.1fk/%.1fk", cur/1000, max/1000))
			wndBar:FindChild("healthPercent"):SetText(string.format("%.1f%%", pct))
		else
			self.tHealth[id].bar:Destroy()
			self.tHealth[id] = nil
			self:arrangeBars(self.tHealth)
		end
	end
end
 
function ReStrat:OnUnitCreated(unit)
	local id = unit:GetId()
	if self.tUnits[id] then 
		self.tUnits[id].unit = newUnit
	end
	if self.tUnits[unit:GetName()] then
		local tUnit = self.tUnits[unit:GetName()]
		if tUnit.fInitFunction then
			tUnit.fInitFunction(unit)
		end
	end
end

function ReStrat:OnUnitDestroyed(unit)
	local id = unit:GetId()
	if self.tUnits[id] then
		if self.tUnits[id].fOnDeathCallback then
			self.tUnits[id].fOnDeathCallback()
		end
		self.tUnits[id].bActive = false
		self.tUnits[id].unit = nil
	end
	ReStrat:untrackHealth(unit)
	ReStrat:destroyPin(unit)
end

function ReStrat:OnEnteredCombat(unit, combat)
	if unit:IsInYourGroup() then
		if combat then 
			self:Start()
		elseif not self:IsGroupInCombat() then
			self:Stop()
		end
	elseif unit:IsThePlayer() then
		if combat then
			self:Start()
		else
			self.outofcombatTimer:Start()
		end
	else
		--If combat starts, init unit profile
		if combat then
			local tProfile = self.tEncounters[unit:GetName()] 
			if tProfile then
				-- FIXME?: need to track health before init 
				if tProfile.trackHealth and not self.tHealth[unit:GetId()] then
					self:trackHealth(unit, tProfile.trackHealth)
				end
				if tProfile.fInitFunction then tProfile.fInitFunction(unit) end
			end
			
			--Add unit in our library if it's not there already
			local id = unit:GetId()
			if not self.tUnits[id] then
				self.tUnits[id] = {
					unit = unit,
					name = unit:GetName(),
					health = unit:GetMaxHealth(),
					shield = unit:GetShieldCapacityMax(),
					absorb = unit:GetAbsorptionMax(),
					baseIA = unit:GetInterruptArmorMax(),
					assault = unit:GetAssaultPower(),
					bActive = true
				}
			end
		end
	end
end

function ReStrat:Start()
	self.combatStarted = GameLib.GetGameTime()
	self.gameTimer:Start()
	self.healthTimer:Start()
	self.outofcombatTimer:Stop()
end

function ReStrat:Stop()
	self.wndHealthBars:DestroyChildren()
	self.wndAlerts:DestroyChildren()
	for k,v in pairs(self.tLandmarks) do v.form:Destroy() end
	for k,v in pairs(self.tPins) do	v:Destroy()	end
	
	self.tAlerts = {}
	self.tHealth = {}
	self.tWatchedAuras = {}
	self.tWatchedCasts = {}
	self.tEncounterVariables = {}
	self.tSpellTriggers = {}
	self.tShortcutBars = {}
	self.tDatachron = {}
	self.tPinAuras = {}
	self.tPins = {}
	self.tLandmarks = {}
	
	self.healthTimer:Stop()
	self.gameTimer:Stop()
end

function ReStrat:IsGroupInCombat()
	for i=1,GroupLib.GetMemberCount() do
		unit = GroupLib.GetUnitForGroupMember(i)
		if unit and unit:IsInCombat() then
			return true
		end
	end
	return false
end

function ReStrat:OnPlayerResurrected() ReStrat:Stop() end
function ReStrat:OnCombatTimeout()     ReStrat:Stop() end

function ReStrat:OnShowResurrectDialog(bPlayerIsDead, bEnableRezHere, bEnableRezHoloCrypt, bEnableRezExitInstance, bEnableCasterRez) 
	if bPlayerIsDead and bEnableRezHoloCrypt then
		ReStrat:Stop()
	end
end

function ReStrat:OnUpdateResurrectDialog(bEnableRezHere, bEnableRezHoloCrypt, bEnableRezExitInstance, bEnableCasterRez)
	if bEnableRezHoloCrypt then
		ReStrat:Stop()
	end
end

--[TODO] make this a lot more customizable
function ReStrat:arrangeBars(tBars)
	local vOffset = 0
	for _,tBar in pairs(tBars) do
		local wndHeight = tBar.bar:GetHeight()		
		tBar.bar:SetAnchorOffsets(0,vOffset,0,vOffset+wndHeight)
		vOffset = vOffset + (wndHeight + self.barSpacing)
	end
end

--Create our fake timers on request
function ReStrat:onCreateTestAlerts(wndHandler, wndControl)
	wndControl:Enable(false)
	self:Start()
	self:trackHealth(GameLib.GetPlayerUnit())
	self:createAlert("Knockback", 5, "Icon_SkillSbuff_higherjumpbuff", self.color.blue, function() self:createPop("Knockback!", nil) end)
	self:createAlert("Flame Walk", 10, "Icon_SkillMisc_Soldier_March", self.color.red, nil)
	self:createAlert("Energon Cubes", 15.5, "Icon_SkillMedic_repairstation", self.color.purple, function() ReStrat:Stop(); wndControl:Enable(true) end)
end

--Parse chat messages for datachron triggers
function ReStrat:OnChatMessage(channel, tMessage)
	if not tMessage then return end --Shouldn't happen but hey this game
	local strText = tMessage.arMessageSegments[1].strText
	
	if channel:GetName() == "Datachron" and self.tDatachron[strText] then
		self.tDatachron[strText].fCallback()
	end
end

--Parse secondary action bars for new spells
function ReStrat:OnShowActionBarShortcut(nBar, bIsVisible, nShortcuts)
	self.tShortcutBars[nBar] = {}
	if bIsVisible then
		for iBar=0,7 do
			self.wndActionBarItem:SetContentId(nBar * 12 + iBar)
			self.tShortcutBars[nBar][iBar+1] = self.wndActionBarItem:GetContent()
		end
	end
end

--/restrat
function ReStrat:OnReStrat(strCmd, strParam)
	if strParam == "stop" then
		self:Stop()
	else
		self.wndMain:Invoke()
		self:InitUI()
	end
end

Apollo.RegisterAddon(ReStrat, false, "", {"DrawLib"})
