-----------------------------------------------------------------------------------------------
-- reStrat - Wildstar Boss Mods
--- © 2014 Ryan Park, aka Reglitch of Codex
--- © 2015-2016 Vim Exe @ Jabbit <narthorn@gmail.com>
--
--- reStrat is free software. All files licensed under the GPLv2 unless otherwise specified.
--- See LICENSE for details.

require "Sound"

ReStrat = {
	name = "ReStrat",
	version = {1,6,0},

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
	tWatchedCasts = {},
	tWatchedAuras = {},
	tConfig = {},
	combatTimer = nil,
	combatStarted = nil,
	combatLog = {},
	tUnitTriggers = {},
	tSpellTriggers = {},
	tAuraTriggers = {},
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
	self.DrawLib = setmetatable({}, {__index = DrawLib or function() return function() end end }) -- fail silently
	
	Event_FireGenericEvent("OneVersion_ReportAddonInfo", self.name, unpack(self.version))
	
	self.wndHealthBars    = Apollo.LoadForm(self.xmlDoc, "healthForm", nil, self)
    self.wndAlerts        = Apollo.LoadForm(self.xmlDoc, "alertForm", nil, self)
	self.wndPop           = Apollo.LoadForm(self.xmlDoc, "popForm", nil, self)
	self.wndActionBarItem = Apollo.LoadForm(self.xmlDoc, "ActionBarShortcutItem", nil, self)
	
	-- Register handlers for events, slash commands and timer, etc.
	Apollo.RegisterSlashCommand("restrat", "OnReStrat", self)

	self:OnWindowManagementReady()
	Apollo.RegisterEventHandler("WindowManagementReady", "OnWindowManagementReady", self)

	Apollo.RegisterEventHandler("UnitCreated",           "OnUnitCreated",       self)
	Apollo.RegisterEventHandler("UnitDestroyed",         "OnUnitDestroyed",     self)
	
	Apollo.RegisterEventHandler("UnitEnteredCombat",     "OnEnteredCombat",     self)
	Apollo.RegisterEventHandler("PlayerResurrected",     "OnPlayerResurrected", self)
	Apollo.RegisterEventHandler("ShowResurrectDialog", 	 "OnShowResurrectDialog",   self)
	Apollo.RegisterEventHandler("UpdateResurrectDialog", "OnUpdateResurrectDialog", self)
	Apollo.RegisterEventHandler("ShowActionBarShortcut", "OnShowActionBarShortcut", self)

	-- Combat log and LCLF only trigger in combat, no need to always unregister/register them
	Apollo.RegisterEventHandler("CombatLogDamage" ,              "OnCombatLogDamage",               self)
	--Apollo.RegisterEventHandler("CombatLogDeflect",              "OnCombatLogDeflect",              self)
	--Apollo.RegisterEventHandler("CombatLogHeal",                 "OnCombatLogHeal",                 self)
	--Apollo.RegisterEventHandler("CombatLogModifyInterruptArmor", "OnCombatLogModifyInterruptArmor", self)
	--Apollo.RegisterEventHandler("CombatLogAbsorption",           "OnCombatLogAbsorption",           self)
	--Apollo.RegisterEventHandler("CombatLogInterrupted",          "OnCombatLogInterrupted",          self)

	Apollo.RegisterEventHandler("_LCLF_SpellAuraApplied",     "OnAuraApplied", self)
	Apollo.RegisterEventHandler("_LCLF_SpellAuraRemoved",     "OnAuraRemoved", self)
	Apollo.RegisterEventHandler("_LCLF_SpellCastStart",       "OnCastStart", self)

	--This timer delays stopping the fight until 7 seconds after the player gets out of combat
    --to allow i.e. spellslingers to voidslip without timers ripping
	self.outofcombatTimer = ApolloTimer.Create(7, false, "OnCombatTimeout", self)
	self.outofcombatTimer:Stop()
end

function ReStrat:OnSave(eLevel)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then return end
	return {version = self.version, tConfig = self.tConfig}
end

function ReStrat:OnRestore(eLevel, tData)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then return end
	if tData.tConfig then
		for strEncounter,tSavedEncounter in pairs(tData.tConfig) do
			local tEncounter = self.tConfig[strEncounter] 
			if tEncounter and tEncounter.version > tSavedEncounter.version then
				if tEncounter.fUpdate then
					self.tConfig[strEncounter] = tEncounter.fUpdate(tSavedEncounter)
				end
			else
				self.tConfig[strEncounter] = tSavedEncounter
			end
		end
	end
end

-----------------------------------------------------------------------------------------------
-- ReStrat Functions
-----------------------------------------------------------------------------------------------
--Add windows to carbines window management
function ReStrat:OnWindowManagementReady()
	Event_FireGenericEvent("WindowManagementRegister", {strName = "reStratHealthBars"})
	Event_FireGenericEvent("WindowManagementRegister", {strName = "reStratAlert"})
	Event_FireGenericEvent("WindowManagementRegister", {strName = "reStratPop"})
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
			
			self.wndAlerts:ArrangeChildrenVert()
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
			self.wndHealthBars:ArrangeChildrenVert()
		end
	end
end
 
function ReStrat:OnUnitCreated(unit)
	local tUnitTrigger = self.tUnitTriggers[unit:GetName()]
	if tUnitTrigger and tUnitTrigger.fOnSpawn then
		tUnitTrigger.fOnSpawn(unit)
	end
end

function ReStrat:OnUnitDestroyed(unit)
	-- This should use ids since the unit already exists...
	local tUnitTrigger = self.tUnitTriggers[unit:GetName()]
	if tUnitTrigger and tUnitTrigger.fOnDespawn then
		tUnitTrigger.fOnDespawn(unit)
	end

	ReStrat:untrackHealth(unit)
	ReStrat:destroyPin(unit)
end

function ReStrat:OnEnteredCombat(unit, combat)
	if     unit:IsInYourGroup() and not self:IsGroupInCombat() then self:Stop()
	elseif unit:IsThePlayer()   and not combat then self.outofcombatTimer:Start() 
	else
		--If combat starts, init unit profile
		if combat then
			local tProfile = self.tEncounters[unit:GetName()] 
			if tProfile then
				self:Start()
				-- FIXME?: need to track health before init 
				if tProfile.trackHealth and not self.tHealth[unit:GetId()] then
					self:trackHealth(unit, tProfile.trackHealth)
				end
				if tProfile.fInitFunction then tProfile.fInitFunction(unit) end
			end

		-- If combat ends, remove unit
		else
			ReStrat:destroyPin(unit)
			ReStrat:untrackHealth(unit)
			if not self:IsGroupInCombat() then self:Stop() end
		end
	end
end

function ReStrat:RegisterCombatEvents()
	Apollo.RegisterEventHandler("ChatMessage", "OnChatMessage", self)
end

function ReStrat:UnregisterCombatEvents()
	Apollo.RemoveEventHandler("ChatMessage", self)
end

function ReStrat:Start()
	if not self.gameTimer then
		self:RegisterCombatEvents()
		self.combatStarted = GameLib.GetGameTime()
		self.gameTimer = ApolloTimer.Create(0.1, true, "OnGameTick", self)
		self.healthTimer = ApolloTimer.Create(0.5, true, "OnHealthTick", self)
		self.outofcombatTimer:Stop()
	end
end

function ReStrat:Stop()
	self.wndHealthBars:DestroyChildren()
	self.wndAlerts:DestroyChildren()
	for k,v in pairs(self.tLandmarks) do v.form:Destroy() end
	for k,v in pairs(self.tPins) do	v:Destroy()	end

	self:UnregisterCombatEvents()
	self.tAlerts = {}
	self.tHealth = {}
	self.tWatchedAuras = {}
	self.tWatchedCasts = {}
	self.tEncounterVariables = {}
	self.tSpellTriggers = {}
	self.tAuraTriggers = {}
	self.tShortcutBars = {}
	self.tDatachron = {}
	self.tPinAuras = {}
	self.tPins = {}
	self.tLandmarks = {}
	
	self.healthTimer = nil
	self.gameTimer = nil
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
		self:ToggleUI()
	end
end

Apollo.RegisterAddon(ReStrat, false, "", {})
