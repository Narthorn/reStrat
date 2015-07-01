-----------------------------------------------------------------------------------------------
-- Interface 

function ReStrat:ToggleUI()
	if not self.wndMain then
		self.wndMain = Apollo.LoadForm(self.xmlDoc, "mainForm", nil, self)
		self:InitZoneList()
	else
		self.wndMain:Destroy() 
		self.wndMain = nil
	end
end

---------------------------------------------------------------------------------------------------
-- Profile config

function ReStrat:InitZoneList()
	self.tZones = {}
	local zoneList = self.wndMain:FindChild("zoneList")
	
	--Go through our encounters and populate zone list
	for strEncounter,tEncounter in pairs(self.tConfig) do
		local strCategory = tEncounter.strCategory
		if not self.tZones[strCategory] then self.tZones[strCategory] = {} end
		table.insert(self.tZones[strCategory], strEncounter)
	end
	
	for strZone,_ in pairs(self.tZones) do
		local btnZone = Apollo.LoadForm(self.xmlDoc, "ItemZone", zoneList, self):FindChild("btnZone")
		btnZone:SetText(strZone)
	end
	
	zoneList:ArrangeChildrenVert()
end

--Handles zone selection for main menu
function ReStrat:onZoneSelected(wndHandler, wndControl)
	local zoneName = wndHandler:GetText()
	local encounterList = self.wndMain:FindChild("encounterList")
	
	encounterList:DestroyChildren()
	
	for _,strEncounter in pairs(self.tZones[zoneName]) do
		local encounterButton = Apollo.LoadForm(self.xmlDoc, "ItemEncounter", encounterList, self):FindChild("btnEncounter")
		encounterButton:SetText(strEncounter)
	end
	
	encounterList:ArrangeChildrenVert()
end


--Handles encounter selection for main menu
function ReStrat:onEncounterSelected(wndHandler, wndControl)
	local strEncounter = wndHandler:GetText()
	local moduleList = self.wndMain:FindChild("moduleList")
	
	moduleList:DestroyChildren()
	
	for strModule,tModule in pairs(self.tConfig[strEncounter].tModules) do
		local moduleButton = Apollo.LoadForm(self.xmlDoc, "ItemModule", moduleList, self):FindChild("btnModule")
		moduleButton:SetText(tModule.strLabel)
		moduleButton:SetData({strEncounter = strEncounter, strModule = strModule})
		moduleButton:SetBGColor(tModule.bEnabled and self.color.green or "vdarkgray")
	end
	
	moduleList:ArrangeChildrenVert()
end

--Handles module toggling
function ReStrat:onModuleToggled(wndHandler, wndControl)
	local tData = wndHandler:GetData()
	local tModule = self.tConfig[tData.strEncounter].tModules[tData.strModule]
	
	tModule.bEnabled = not tModule.bEnabled
	wndHandler:SetBGColor(tModule.bEnabled and self.color.green or "vdarkgray")
end

---------------------------------------------------------------------------------------------------
-- Icons

function ReStrat:onIconsToggle()
	if not self.wndIcon then
		self.wndIcon = Apollo.LoadForm(self.xmlDoc, "iconForm", nil, self)
		
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
	else
		self.wndIcon:Destroy()
		self.wndIcon = nil
	end
end

---------------------------------------------------------------------------------------------------
-- Settings

function ReStrat:onSettingsToggle(wndControl, eMouseButton)
	if not self.wndSettings then
		self.wndSettings = Apollo.LoadForm(self.xmlDoc, "settingsForm", nil, self)
	else
		self.wndSettings:Destroy() 
		self.wndSettings = nil
	end
end

function ReStrat:onToggleSettings(wndHandler, wndControl)
	local bEnabled = not (wndControl:GetText() == "Enabled")
	wndControl:SetText(bEnabled and "Enabled" or "Disabled")
	wndControl:SetBGColor(bEnabled and self.color.green or self.color.red)
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