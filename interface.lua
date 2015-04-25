
--UI Init
function ReStrat:InitUI()
	if not self.bLoaded then
		local zoneList = self.wndMain:FindChild("zoneList")
		
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
		
		ReStrat:arrangeChildren(zoneList)
		
		self.bLoaded = true
	end	
end

--Test arrange function
function ReStrat:arrangeChildren(frm)
	local tChildren = frm:GetChildren()
	
	for i=1,#tChildren do
		local wndHeight = tChildren[i]:GetHeight()
		local wndWidth = tChildren[i]:GetWidth()
		local vOffset = (wndHeight + self.barSpacing)*(i-1) +  self.barSpacing
		
		tChildren[i]:SetAnchorOffsets(-wndWidth/2,vOffset,wndWidth/2,vOffset+wndHeight)
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
	
	self:arrangeChildren(encounterList)
end


--Handles encounter selection for main menu
function ReStrat:onEncounterSelected(wndHandler, wndControl)
	local encounterName = wndHandler:GetData()
	local moduleList = self.wndMain:FindChild("moduleList")
	
	moduleList:DestroyChildren()
	
	for k,v in pairs(self.tEncounters[encounterName].tModules) do
		local moduleButton = Apollo.LoadForm(self.xmlDoc, "btnModule", moduleList, self)
		
		moduleButton:SetText(v.strLabel)
		moduleButton:SetData({encounter = encounterName, module = k})
		
		--Gray out if disabled
		if not self.tEncounters[encounterName].tModules[k].bEnabled then
			moduleButton:SetBGColor("vdarkgray")
		end
		
	end
	
	self:arrangeChildren(moduleList)
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

function ReStrat:onShowLog()
	self.wndLog:Show(true, true)
	
	----------------------------
	--Unit Tab
	----------------------------
	--Grab our labels/forms
	local unitList     = self.wndLog:FindChild("formContainer"):FindChild("unitForm"):FindChild("unitList")
	
	--Create a unit for each unit in tUnits
	for id,tUnit in pairs(self.tUnits) do
		local unitItem = Apollo.LoadForm(self.xmlDoc, "unitItem", unitList, self)
		local unitString = unitItem:FindChild("unitString")
		
		unitString:SetText(tUnit.name)
		unitItem:SetData(id)
	end
	
	unitList:ArrangeChildrenVert()
	
end

--When we switch unit
function ReStrat:onUnitSwitch(wndHandler, wndControl)
	--Grab our labels/forms
	local unitForm     = self.wndLog:FindChild("formContainer"):FindChild("unitForm")
	local portrait     = unitForm:FindChild("CostumeWindow")
	local health       = unitForm:FindChild("strHealth")
	local name         = unitForm:FindChild("strName")
	local power        = unitForm:FindChild("strPower")
	local absorb       = unitForm:FindChild("strAbsorb")
	local shield       = unitForm:FindChild("strShield")
	local assaultpower = unitForm:FindChild("strAssault")
	local count        = unitForm:FindChild("strCount")
	local ia           = unitForm:FindChild("strIA")
	
	local unitCache = self.tUnits[wndHandler:GetParent():GetData()]
	if unitCache.unit then
		portrait:SetCostume(unitCache.unit)
	else 
		portrait:SetCostumeToCreatureId(1)
	end
	if unitCache.health then
		health:SetText("Health: " .. unitCache.health)
	else
		health:SetText("Health: N/A")
	end
	--power:SetText("Health: " .. unitCache.health)
	if unitCache.shield then
		shield:SetText("Shield: " .. unitCache.shield)
	else
		shield:SetText("Shield: N/A")
	end
	if unitCache.absorb then
		absorb:SetText("Absorb: " .. unitCache.absorb)
	else
		absorb:SetText("Absorb: N/A")
	end
	--count:SetText("Health: " .. unitCache.health)
	ia:SetText("Interrupt Armor: " .. unitCache.baseIA)
	if unitCache.assault then
		assaultpower:SetText("Assault Power: " .. round(unitCache.assault,2))
	else
		assaultpower:SetText("Assault Power: N/A")
	end
	name:SetText("Name: " .. unitCache.name)

end

function ReStrat:onSettingsShow(wndControl, eMouseButton)
	self.wndSettings:Show(true, true)
end

---------------------------------------------------------------------------------------------------
-- iconForm Functions
---------------------------------------------------------------------------------------------------

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
-- iconPreview Functions
---------------------------------------------------------------------------------------------------

function ReStrat:onIconStringCopy(wndHandler)
	local iconString = wndHandler:GetData()
end

---------------------------------------------------------------------------------------------------
-- logForm Functions
---------------------------------------------------------------------------------------------------

function ReStrat:onCloseLog(wndHandler, wndControl)
	self.wndLog:Close()
	local unitList     = self.wndLog:FindChild("formContainer"):FindChild("unitForm"):FindChild("unitList")
	unitList:DestroyChildren()

end

---------------------------------------------------------------------------------------------------
-- settingsForm Functions
---------------------------------------------------------------------------------------------------

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
	if wndControl:GetText() == "Enabled" then
		--Display
		self.wndHealthBars:SetBGColor("90000000")
		self.wndHealthBars:SetText("Health Bars")
		self.wndAlerts:SetBGColor("90000000")
		self.wndAlerts:SetText("Alerts")
		self.wndPop:SetBGColor("90000000")
		self.wndPop:SetText("Pop Frame")
		
		--Set properties
		self.wndHealthBars:SetStyle("Moveable", true)
		self.wndHealthBars:SetStyle("Sizable", true)
		self.wndAlerts:SetStyle("Moveable", true)
		self.wndAlerts:SetStyle("Sizable", true)
		self.wndPop:SetStyle("Moveable", true)
		self.wndPop:SetStyle("Sizable", true)		
	else
		--Display
		self.wndHealthBars:SetText("")
		self.wndHealthBars:SetBGColor("00ffffff")
		self.wndAlerts:SetText("")
		self.wndAlerts:SetBGColor("00ffffff")
		self.wndPop:SetText("")
		self.wndPop:SetBGColor("00ffffff")
		
		--Set properties
		self.wndHealthBars:SetStyle("Moveable", false)
		self.wndHealthBars:SetStyle("Sizable", false)
		self.wndAlerts:SetStyle("Moveable", false)
		self.wndAlerts:SetStyle("Sizable", false)
		self.wndPop:SetStyle("Moveable", false)
		self.wndPop:SetStyle("Sizable", false)
	end
end