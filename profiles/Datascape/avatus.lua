-----------------------------------------------------------------------------
--- Avatus, Vim and Lattice by Chill
-- FUCKING HYPE
-----------------------------------------------------------------------------
function ReStrat:avatusInit(unit) -- also lattice for some reason
	if not ReStrat.tEncounterVariables.firstPhase then
		ReStrat.tEncounterVariables.firstPhase = true
		ReStrat:createAlert("Gun Grid", 46, "Icon_SkillEngineer_Target_Acquistion", ReStrat.color.red)
		
		ReStrat:OnDatachron("SECURITY PROTOCOL: Gun Grid Activated.", function()
			ReStrat:destroyAlert("Gun Grid")
			ReStrat:createAlert("Obliteration Beam", 45, nil, ReStrat.color.blue, function()
				ReStrat:createAlert("Obliteration Beam", 45, nil, ReStrat.color.blue)
			end)
			ReStrat:createAlert("Holo Hands", 22, nil, ReStrat.color.green, nil)
			ReStrat:createAlert("Gun Grid", 112, "Icon_SkillEngineer_Target_Acquistion", ReStrat.color.red, nil)
		end)
		
		ReStrat:OnDatachron("Avatus' power begins to surge! Portals have opened!", function()
			ReStrat:destroyAlert("Gun Grid")
			ReStrat:destroyAlert("Holo Hands")
		end)
	end
end

function ReStrat:latticeInit() 
	oblit = 0
	local function devourerspawn()
		tdev = {}
		tdev.strLabel = "Next Devourers"
		tdev.fDelay = 15
		tdev.fDuration = 5
		tdev.strColor = ReStrat.color.orange
		tdev.strIcon = "Icon_SkillEngineer_Anomaly_Launcher"
	
		ReStrat:repeatAlert(tdev, 999)
	end
	
	ReStrat:createAlert("Data Devourers", 10, "Icon_SkillEngineer_Anomaly_Launcher", ReStrat.color.orange, devourerspawn)
	local function jumpphase()
		ReStrat:destroyAllAlerts()
		ReStrat:createAlert("Get Buff and Jump!", 18.83, "Icon_SkillShadow_UI_stlkr_shadowdash", ReStrat.color.green, function()
			ReStrat:createAlert("Jump!", 7.2, "Icon_SkillShadow_UI_stlkr_shadowdash", ReStrat.color.green, function()
				ReStrat:createAlert("Jump!", 6, "Icon_SkillShadow_UI_stlkr_shadowdash", ReStrat.color.green, nil)
			end)
		end)
	end
	
	ReStrat:OnDatachron("The Vertical Locomotion Enhancement Ports have been activated!", jumpphase)
	ReStrat:OnDatachron("The Secure Sector Enhancement Ports have been activated!", function()
		ReStrat:destroyAllAlerts()
		ReStrat:createAlert("Get Buff and Spread!", 19, "Icon_SkillMedic_sheildsurge", ReStrat.color.green, nil)
	end)
	
	ReStrat:createCastAlert("Avatus", "Obliterate", nil, "Icon_SkillEngineer_Energy_Trail", ReStrat.color.purple, function()
		oblit = oblit + 1
		if oblit == 2 then
			ReStrat:createAlert("Data Devourers", 21, "Icon_SkillEngineer_Anomaly_Launcher", ReStrat.color.orange, devourerspawn)
		else
			ReStrat:createAlert("Data Devourers", 11, "Icon_SkillEngineer_Anomaly_Launcher", ReStrat.color.orange, devourerspawn)
		end
	end)
	
	ReStrat:createAuraAlert(nil, "Mark of Enmity", nil, "Icon_SkillEngineer_Code_Red", nil)
end

function ReStrat:devourerInit(unit)
	if self:IsActivated("Avatus", "Lines to Devourers") then
		DrawLib:UnitLine(GameLib.GetPlayerUnit(), unit, ReStrat.color.orange)
	end
end

function ReStrat:latticeEvent(tEventObj)
	if self:IsActivated("Avatus", "Track Exit Power [Event]") then
		ReStrat:trackEvent(tEventObj, self.color.yellow, "Exit Power")
	end	
end


ReStrat.tEncounters["Avatus"] = {
	startFunction = avatusInit,
	strCategory = "Datascape",
	trackHealth = ReStrat.color.red,
	tModules = {
		["Obliterate"] = {
			strLabel = "Obliterate (Lattice)",
			bEnabled = true,
		},
		["Track Exit Power [Event]"] = {
			strLabel = "Track Exit Power [Event]",
			bEnabled = true,
		},
	},
}

ReStrat.tEncounters["Holo Hand"] = {
	startFunction = avatusInit,
	strCategory = "Not Important",
	trackHealth = ReStrat.color.blue,
	tModules = {},
}
