-----------------------------------------------------------------------------------------------
-- Client Lua Script for ReStrat
-- Copyright (c) NCsoft. All rights reserved
-- Created by Ryan Park, aka Reglitch of Codex
-----------------------------------------------------------------------------------------------
 
require "Window"
require "Sound"
 
local ReStrat = {} 
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ReStrat:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    return o
end

function ReStrat:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- ReStrat OnLoad
-----------------------------------------------------------------------------------------------
function ReStrat:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("ReStrat.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	Apollo.LoadSprites("respr.xml", "SassyMedicSimSprites")
end

-----------------------------------------------------------------------------------------------
-- ReStrat OnDocLoaded
-----------------------------------------------------------------------------------------------
function ReStrat:OnDocLoaded()


	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
		self.wndMain = Apollo.LoadForm(self.xmlDoc, "mainForm", nil, self);
	    self.wndAlerts = Apollo.LoadForm(self.xmlDoc, "alertForm", nil, self);
		self.wndPop = Apollo.LoadForm(self.xmlDoc, "popForm", nil, self);
		self.wndIcon = Apollo.LoadForm(self.xmlDoc, "iconForm", nil, self);

		
	    self.wndMain:Show(false, true)
		self.wndIcon:Show(false, true)
		
		-- Register handlers for events, slash commands and timer, etc.
		Apollo.RegisterSlashCommand("restrat", "OnReStratOn", self)
		Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)
		Apollo.RegisterEventHandler("UnitDestroyed", "OnUnitDestroyed", self)
		Apollo.RegisterEventHandler("UnitEnteredCombat", "OnEnteredCombat", self)
		Apollo.RegisterEventHandler("WindowManagementReady", "OnWindowManagementReady", self)
		
		--Color library, can't be stored in constants
		self.color = {
			red = "ffb8413d",
			orange = "ffdd7649",
			yellow = "fff8fd6b",
			green = "ff58cc5d",
			blue = "ff5196ec",
			purple = "ff915fc2",
			black = "black",
			white = "white",
		}
		
		--This timer drives UI events exclusively, in game checks are fired on a seperate timer
		self.alertTimer = ApolloTimer.Create(0.01, true, "OnAlarmTick", self);
		
		--This timer drives in game logging and event handling
		self.gameTimer = ApolloTimer.Create(0.1, true, "OnGameTick", self);
		
		--This time drives pop appearances
		self.popTimer = ApolloTimer.Create(0.75, true, "OnPopTick", self);
		self.popTimer:Stop();

		--Variables, tables, etc.
		self.tAlerts = {};
		self.tUnits = {};
		self.bInCombat = false;
		self.fPopCallback = nil;
		self.bPopTicked = false;
		self.tWatchedCasts = {};
		self.tWatchedAuras = {};
		self.tZones = {};
		
		
		if not self.tEncounters then
			self.tEncounters = {}
		end
		
		self.bLoaded = false;
	end
end

-----------------------------------------------------------------------------------------------
-- ReStrat Functions
-----------------------------------------------------------------------------------------------
--Add windows to carbines window management
function ReStrat:OnWindowManagementReady()
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndAlerts, strName = "restratAlerts"})
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndPop, strName = "restratPops"})
end

--Save data between sessions
function ReStrat:OnSave(eLevel)
  if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
    return nil
  end

  local tSavedData = { }
  
  tSavedData = {
    encounters = self.tEncounters;
  }

  return tSavedData

end

--Restore data on session
function ReStrat:OnRestore(eType, savedData)
		local encounterCache = nil;
		
		if self.tEncounters then
			encounterCache = self.tEncounters;
			SendVarToRover("Cache", encounterCache, 1);
		end
		
		if savedData.encounters then
			self.tEncounters = savedData.encounters;
			
			if encounterCache then
				for k,v in pairs(encounterCache) do
					local newEntry = true;
					
					for q,t in pairs(self.tEncounters) do
						if k == q then newEntry = false end
					end
					
					if newEntry then
						self.tEncounters[k] = v;
					end
				end
			end
			
			--Functions can't be stored between sessions, retrieve from cache
			for k,v in pairs(self.tEncounters) do
				self.tEncounters[k].fInitFunction = encounterCache[k].fInitFunction;
				self.tEncounters[k].fSpamFunction = encounterCache[k].fSpamFunction;
			end
		else
			self.tEncounters = {}
		end
end


--On Game Tick
function ReStrat:OnGameTick()
	if self.bInCombat then
		self:OnGameTickManageCasts()
		self:OnGameTickManageAuras()
	end
end

--On pop tick
function ReStrat:OnPopTick()
	if self.bPopTicked then
		--We've ticked before
		--Set text
		self.wndPop:SetText("");
		
		--Execute callback if exists
		if self.fPopCallback then
			self.fPopCallback();
			self.fPopCallback = nil;
		end
		
		self.popTimer:Stop();
		self.bPopTicked = false;	
	else
		self.bPopTicked = true;
	end
end

--On alarm tick
function ReStrat:OnAlarmTick()
	if #self.tAlerts > 0 then
		--This counts down all alarms registered to self.tAlerts
		for i,v in ipairs(self.tAlerts) do
			local alertInstance = self.tAlerts[i];
			local timer = alertInstance.alert:FindChild("ProgressBarContainer"):FindChild("timeLeft");
			local pBar = alertInstance.alert:FindChild("ProgressBarContainer"):FindChild("progressBar");
			
			--Manage actual time degradation
			if alertInstance.lastTime then
				alertInstance.currDuration = alertInstance.currDuration-(GameLib.GetGameTime()-alertInstance.lastTime);
			end
			
			alertInstance.lastTime = GameLib.GetGameTime();
			
			--Update time and bar
			if alertInstance.currDuration >= 0 then
					timer:SetText(tostring(round(alertInstance.currDuration, 1)) .. "S");
					pBar:SetProgress(alertInstance.currDuration);
				else
						
				--Close bar
				alertInstance.alert:Close();
					
				--Execute callback
				if alertInstance.callback then
					alertInstance.callback()
				end
						
				--Remove from table
				table.remove(self.tAlerts, i);
					
				--Reshuffle windows
				self:arrangeAlerts();
			end
		end
	end
end

--When units are created by the game
function ReStrat:OnUnitCreated(unit)
	--Check if we have the unit in our library
	for i,v in ipairs(self.tUnits) do
		if self.tUnits[i].unit == unit then
			self.unitExists = true;
			return
		else
			self.unitExists = false;
		end
	end
	
	--If not then we add it
	if not self.unitExists then
		self.tUnits[#self.tUnits+1]  = {
				unit = unit,
				name = unit:GetName(),
				id = unit:GetId(),
				health = unit:GetMaxHealth(),
				shield = unit:GetShieldCapacityMax(),
				baseIA = unit:GetInterruptArmorMax(),
				bActive = true
		}
	end
	
	--Unit has been created in combat
	--If it's a unit in our list
	if self:isWatchedUnit(unit) and unit:IsInCombat() then
		if self.bInCombat then
			self:initUnit(unit);
		end
	end
end

function ReStrat:OnUnitDestroyed(unit)
	--Check if unit exists in our library
	for i,v in ipairs(self.tUnits) do
		if self.tUnits[i].id == unit:GetId() then
			--Since the unit has been destroyed we set it to non active and remove unit reference
			self.tUnits[i].bActive = false;
			self.tUnits[i].unit = nil;
			
			return
		end
	end
end

function ReStrat:OnEnteredCombat(unit, combat)
	--Is it the player?
	if GameLib.GetPlayerUnit() then
		if unit == GameLib.GetPlayerUnit() then
			if combat then
				self.bInCombat = true;
				return
			else
				self.bInCombat = false;
				return
			end
		end
	end
	
	--If it's a unit in our list
	if self:isWatchedUnit(unit) and combat then
		self:initUnit(unit);
	end
end

--Initiate a unit
function ReStrat:initUnit(unit)
	for i,v in ipairs(self.tUnits) do
		if self.tUnits[i].bActive and self.tUnits[i].unit == unit then
			Print(self.tUnits[i].name);
			self.tEncounters[self.tUnits[i].name].fInitFunction(); --Initiate pull function
			return
		end
	end
end

--If the unit is in tEncounters
function ReStrat:isWatchedUnit(unit)
	for k,v in pairs(self.tEncounters) do
		if unit:GetName() == k then
			return true;
		end
	end
end

--[TODO] make this a lot more customizable
function ReStrat:arrangeAlerts()
	for i,v in ipairs(self.tAlerts) do
		local wndHeight = self.tAlerts[i].alert:GetHeight();
		local spacing = 9;
		local vOffset = wndHeight*(i-1) + spacing*(i-1);
		
		self.tAlerts[i].alert:SetAnchorOffsets(0,vOffset,0,vOffset+wndHeight);
	end
end

--Test arrange function
function ReStrat:arrangeChildren(frm)
	local tChildren = frm:GetChildren()
	
	for i,v in ipairs(tChildren) do
		local wndHeight = v:GetHeight();
		local wndWidth = v:GetWidth();
		local spacing = 9;
		local vOffset = wndHeight*(i-1) + spacing+spacing*(i-1);
		
		v:SetAnchorOffsets(-wndWidth/2,vOffset,wndWidth/2,vOffset+wndHeight);
	end
end

--Generate alert
function ReStrat:createAlert(strLabel, duration, strIcon, strColor, fCallback)
	local alertBar = Apollo.LoadForm("ReStrat.xml", "alertInstance", self.wndAlerts, self);
	
	--Set bar label
	alertBar:FindChild("ProgressBarContainer"):FindChild("spellName"):SetText(strLabel);
	
	--Set max for pBar
	alertBar:FindChild("ProgressBarContainer"):FindChild("progressBar"):SetMax(duration);
	
	--Handle optional color
	if not strColor then
		alertBar:FindChild("ProgressBarContainer"):FindChild("progressBar"):SetBarColor(self.color.red);
	else
		alertBar:FindChild("ProgressBarContainer"):FindChild("progressBar"):SetBarColor(strColor);
	end
	
	--Handle optional icon
	if not strIcon then
		alertBar:FindChild("IconContainer"):Close();
	else
		alertBar:FindChild("IconContainer"):FindChild("Icon"):SetSprite(strIcon);
	end
	
	--Handle callback function
	if not fCallback then
		fCallback = nil
	end
	
	--Add to tAlerts
	self.tAlerts[#self.tAlerts+1] = {alert = alertBar, name = strLabel, callback = fCallback, currDuration = duration, maxDuration = duration}
	
	--Arrange vertically
	self:arrangeAlerts();
end

--Create pop
function ReStrat:createPop(strLabel, fCallback)
	--If we're overriding an existing pop
	if self.wndPop:GetText() ~= "" and self.fPopCallback then
		self.fPopCallback();
		self.fPopCallback = nil;
	end
	
	--Set our text
	self.wndPop:SetText(tostring(strLabel));
	
	--Cache our callback
	self.fPopCallback = fCallback;
	
	--Initiate our timer to close
	self.popTimer:Start();
end


--/restrat
function ReStrat:OnReStratOn()
	--Show Window
	self.wndMain:Invoke()
	
	--Fake alerts
	self:createAlert("Big Bad Casterino", 6, nil, self.color.purple, nil)
	self:createAlert("Big Bad Casterino", 1.5, nil, self.color.purple, nil)
	self:createPop("Test Pop", function() Print("Pop Done") end)
	
	--Init UI
	self:OnInitUI()
	
end

--UI Init
function ReStrat:OnInitUI()
	if not self.bLoaded then
		local zoneList = self.wndMain:FindChild("zoneList");
		
		--Go through our encounters and populate zone list
		for k,v in pairs(self.tEncounters) do
			--Create the list
			if not self.tZones[v.strCategory] then
				self.tZones[v.strCategory] = {};
			end
			
			table.insert(self.tZones[v.strCategory], k);
		end
		
		--Create zone buttons
		for k,v in pairs(self.tZones) do
			local btnZone = Apollo.LoadForm(self.xmlDoc, "btnZone", zoneList, self);
			btnZone:SetText(k);
			btnZone:SetData(k);
		end
		
		ReStrat:arrangeChildren(zoneList);
		
		self.bLoaded = true;
	end	
end


function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

---------------------------------------------------------------------------------------------------
-- btnEncounter Functions
---------------------------------------------------------------------------------------------------
--Handles zone selection for main menu
function ReStrat:onZoneSelected(wndHandler, wndControl)
	local zoneName = wndHandler:GetData();
	local encounterList = self.wndMain:FindChild("encounterList");
	
	encounterList:DestroyChildren();
	
	for i,v in ipairs(self.tZones[zoneName]) do
		local encounterButton = Apollo.LoadForm(self.xmlDoc, "btnEncounter", encounterList, self);
		
		encounterButton:SetText(v);
		encounterButton:SetData(v);
	end
	
	self:arrangeChildren(encounterList);
end


--Handles encounter selection for main menu
function ReStrat:onEncounterSelected(wndHandler, wndControl)
	local encounterName = wndHandler:GetData();
	local moduleList = self.wndMain:FindChild("moduleList");
	
	moduleList:DestroyChildren();
	
	for k,v in pairs(self.tEncounters[encounterName].tModules) do
		local moduleButton = Apollo.LoadForm(self.xmlDoc, "btnModule", moduleList, self);
		
		moduleButton:SetText(v.strLabel);
		moduleButton:SetData({encounter = encounterName, module = k});
		
		--Gray out if disabled
		if not self.tEncounters[encounterName].tModules[k].bEnabled then
			moduleButton:SetBGColor("vdarkgray");
		end
		
	end
	
	self:arrangeChildren(moduleList);
end

--Handles module toggling
function ReStrat:onModuleToggled(wndHandler, wndControl)
	local encounterName = wndHandler:GetData().encounter;
	local moduleName = wndHandler:GetData().module;
	local bIsEnabled = self.tEncounters[encounterName].tModules[moduleName].bEnabled;
	
	if bIsEnabled then
		self.tEncounters[encounterName].tModules[moduleName].bEnabled = false;
		wndHandler:SetBGColor("vdarkgray");
	else
		self.tEncounters[encounterName].tModules[moduleName].bEnabled = true;
		wndHandler:SetBGColor(self.color.green);
	end

end

---------------------------------------------------------------------------------------------------
-- mainForm Functions
---------------------------------------------------------------------------------------------------

function ReStrat:onClose()
	self.wndMain:Close();
end

function ReStrat:onShowIcons()
	self.wndIcon:Invoke(); -- open macro window
	
	local iconList = self.wndIcon:FindChild("iconList");
	local icons = MacrosLib.GetMacroIconList();
	
	for i = 0, #icons do
		if icons[i] then
			local icon = Apollo.LoadForm(self.xmlDoc, "iconPreview", iconList, self);
			local iconWindow = icon:FindChild("IconContainer"):FindChild("Icon");
			local iconStringContainer = icon:FindChild("ProgressBarContainer"):FindChild("macroString");
			local iconBtn = icon:FindChild("ProgressBarContainer"):FindChild("btn_copyIconString");
			iconBtn:SetActionData(GameLib.CodeEnumConfirmButtonType.CopyToClipboard, icons[i])
			iconBtn:SetSprite("respr:bartex1");
			
			iconWindow:SetSprite(icons[i]);
			iconStringContainer:SetText(icons[i]);
		end
	end

	iconList:ArrangeChildrenVert();
end

---------------------------------------------------------------------------------------------------
-- iconForm Functions
---------------------------------------------------------------------------------------------------

function ReStrat:onCloseIcons()
	local iconList = self.wndIcon:FindChild("iconList");
	local icons = iconList:GetChildren()
	
	for i = 0, #icons do
		if icons[i] then
			icons[i]:Destroy();
		end
	end
	
	self.wndIcon:Close();
end

---------------------------------------------------------------------------------------------------
-- iconPreview Functions
---------------------------------------------------------------------------------------------------

function ReStrat:onIconStringCopy(wndHandler)
	local iconString = wndHandler:GetData();
end

-----------------------------------------------------------------------------------------------
-- ReStrat Instance
-----------------------------------------------------------------------------------------------
local ReStratInst = ReStrat:new()
ReStratInst:Init()
_G["ReStrat"] = ReStratInst
