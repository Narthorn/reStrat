-----------------------------------------------------------------------------------------------
-- Interface handlers
--- Created by Ryan Park, aka Reglitch of Codex
---- Maintained by Vim <Codex>
-----------------------------------------------------------------------------------------------

--UI Init
function ReStrat:InitUI()
	if not self.bLoaded then
		--[[local zoneList = self.wndMain:FindChild("zoneList")
		
		--Go through our encounters and populate zone list
		for k,v in pairs(self.tEncounters) do
			--Create the list
			if not self.tZones[v.strCategory] then
				self.tZones[v.strCategory] = {}
			end
			
			table.insert(self.tZones[v.strCategory], k)
		end
		
		--Create zone buttons
		for k,v in pairs(self.tZones) do
			local btnZone = Apollo.LoadForm(self.xmlDoc, "btnZone", zoneList, self)
			btnZone:SetText(k)
			btnZone:SetData(k)
		end
		
		zoneList:ArrangeChildrenVert()--]]
		
		self.bLoaded = true
	end	
end

---------------------------------------------------------------------------------------------------
-- btnEncounter Functions
---------------------------------------------------------------------------------------------------
--Handles zone selection for main menu
function ReStrat:onZoneSelected(wndHandler, wndControl)
	local zoneName = wndHandler:GetData()
	local encounterList = self.wndMain:FindChild("encounterList")
	
	encounterList:DestroyChildren()
	
	for i,v in ipairs(self.tZones[zoneName]) do
		local encounterButton = Apollo.LoadForm(self.xmlDoc, "btnEncounter", encounterList, self)
		
		encounterButton:SetText(v)
		encounterButton:SetData(v)
	end
	
	encounterList:ArrangeChildrenVert()
end


--Handles encounter selection for main menu
function ReStrat:onEncounterSelected(wndHandler, wndControl)
	local encounterName = wndHandler:GetData()
	local moduleList = self.wndMain:FindChild("moduleList")
	
	moduleList:DestroyChildren()
	
	--[[for k,v in pairs(self.tEncounters[encounterName].tModules) do
		local moduleButton = Apollo.LoadForm(self.xmlDoc, "btnModule", moduleList, self)
		
		moduleButton:SetText(v.strLabel)
		moduleButton:SetData({encounter = encounterName, module = k})
		
		--Gray out if disabled
		if not self.tEncounters[encounterName].tModules[k].bEnabled then
			moduleButton:SetBGColor("vdarkgray")
		end
		
	end--]]
	
	moduleList:ArrangeChildrenVert()
end

--Handles module toggling
function ReStrat:onModuleToggled(wndHandler, wndControl)
	local encounterName = wndHandler:GetData().encounter
	local moduleName = wndHandler:GetData().module
	local bIsEnabled = self.tEncounters[encounterName].tModules[moduleName].bEnabled
	
	if bIsEnabled then
		self.tEncounters[encounterName].tModules[moduleName].bEnabled = false
		wndHandler:SetBGColor("vdarkgray")
	else
		self.tEncounters[encounterName].tModules[moduleName].bEnabled = true
		wndHandler:SetBGColor(self.color.green)
	end

end

---------------------------------------------------------------------------------------------------
-- mainForm Functions
---------------------------------------------------------------------------------------------------

function ReStrat:onClose()
	self.wndMain:Close()
end

---------------------------------------------------------------------------------------------------
-- iconForm Functions
---------------------------------------------------------------------------------------------------

function ReStrat:onShowIcons()
	self.wndIcon:Invoke() -- open macro window
	
	local iconList = self.wndIcon:FindChild("iconList")
	local icons = MacrosLib.GetMacroIconList()
	
	for i = 0, #icons do
		if icons[i] then
			local icon = Apollo.LoadForm(self.xmlDoc, "iconPreview", iconList, self)
			local iconWindow = icon:FindChild("IconContainer"):FindChild("Icon")
			local iconStringContainer = icon:FindChild("ProgressBarContainer"):FindChild("macroString")
			local iconBtn = icon:FindChild("ProgressBarContainer"):FindChild("btn_copyIconString")
			iconBtn:SetActionData(GameLib.CodeEnumConfirmButtonType.CopyToClipboard, icons[i])
			iconBtn:SetSprite("respr:bartex1")
			
			iconWindow:SetSprite(icons[i])
			iconStringContainer:SetText(icons[i])
		end
	end

	iconList:ArrangeChildrenVert()
end

function ReStrat:onCloseIcons()
	local iconList = self.wndIcon:FindChild("iconList")
	local icons = iconList:GetChildren()
	
	for i = 0, #icons do
		if icons[i] then
			icons[i]:Destroy()
		end
	end
	
	self.wndIcon:Close()
end

---------------------------------------------------------------------------------------------------
-- settingsForm Functions
---------------------------------------------------------------------------------------------------

function ReStrat:onSettingsShow(wndControl, eMouseButton)
	self.wndSettings:Show(true, true)
end

function ReStrat:onToggleSettings(wndHandler, wndControl)
	if wndControl:GetText() == "Enabled" then
		wndControl:SetText("Disabled")
		wndControl:SetBGColor(self.color.red)
	else
		wndControl:SetText("Enabled")
		wndControl:SetBGColor(self.color.green)
	end
end

function ReStrat:onCloseSettings()
	self.wndSettings:Close()
end

function ReStrat:onToggleMoving(wndHandler, wndControl) --[TODO]: ugh
	local bEnabled = (wndControl:GetText() == "Enabled")
	
	self.wndHealthBars:SetBGColor(bEnabled and "90000000" or "00ffffff")
	self.wndHealthBars:SetText(bEnabled and "Health Bars" or "")
	self.wndAlerts:SetBGColor(bEnabled and "90000000" or "00ffffff")
	self.wndAlerts:SetText(bEnabled and "Alerts" or "")
	self.wndPop:SetBGColor(bEnabled and "90000000" or "00ffffff")
	self.wndPop:SetText(bEnabled and "Pop Frame" or "")
	
	self.wndHealthBars:SetStyle("Moveable", bEnabled)
	self.wndHealthBars:SetStyle("Sizable", bEnabled)
	self.wndAlerts:SetStyle("Moveable", bEnabled)
	self.wndAlerts:SetStyle("Sizable", bEnabled)
	self.wndPop:SetStyle("Moveable", bEnabled)
	self.wndPop:SetStyle("Sizable", bEnabled)
end