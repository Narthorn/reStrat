-----------------------------------------------------------------------------
--- Avatus, Vim and Lattice by Chill
-- FUCKING HYPE
-----------------------------------------------------------------------------
function ReStrat:avatusInit(unit) -- also lattice for some reason
	if not ReStrat.tEncounterVariables.firstPhase then
		local disthand1, disthand2
		ReStrat:trackHealth(unit, ReStrat.color.red)
		ReStrat.tEncounterVariables.firstPhase = true

		ReStrat:createAlert("Gun Grid", 20, "Icon_SkillEngineer_Target_Acquistion", ReStrat.color.red)
		
		ReStrat:OnDatachron("SECURITY PROTOCOL: Gun Grid Activated.", function()
			ReStrat:destroyAlert("Gun Grid")
			ReStrat:createAlert("Obliteration Beam", 45, "Icon_SkillEnergy_UI_ss_plsmasht", ReStrat.color.blue, function()
				ReStrat:createAlert("Obliteration Beam", 40, "Icon_SkillEnergy_UI_ss_plsmasht", ReStrat.color.blue)
			end)
			ReStrat:createAlert("Holo Hands/Guns", 22, "Icon_SkillMind_UI_espr_crush", ReStrat.color.orange, nil)
			ReStrat:createAlert("Gun Grid", 112, "Icon_SkillEngineer_Target_Acquistion", ReStrat.color.red, nil)
		end)
		
		ReStrat:OnDatachron("Avatus' power begins to surge! Portals have opened!", function()
			ReStrat:destroyAlert("Obliteration Beam")
			ReStrat:destroyAlert("Gun Grid")
			ReStrat:destroyAlert("Holo Hands/Guns")
		end)
		
		local function handspawn(unit)
			if not ReStrat.tEncounterVariables.firstHand then
				ReStrat:createPin("1", unit, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
				ReStrat:trackHealth(unit, ReStrat.color.orange, "Hand 1")
				ReStrat.tEncounterVariables.firstHand = true
				hand1unit = unit
			else
				ReStrat:createPin("2", unit, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
				ReStrat:trackHealth(unit, ReStrat.color.orange, "Hand 2")
				hand2unit = unit
			end


			--Print("X: " .. tPos.x)
			--Print("Y: " .. tPos.y)
			--Print("Z: " .. tPos.z)
			--1 628, -198, -156
			--2 627, -198, -191
		end
		ReStrat:createUnitTrigger("Holo Hand", handspawn)

		local function crushblow(unit)
			local dist = ReStrat:dist2unit(GameLib.GetPlayerUnit(), unit)
			if dist < 28 then
				ReStrat:createPop("Crushing Blow!")
				ReStrat:createAlert("Crushing Blow", 3, nil, ReStrat.color.red, nil)
			end
		end
		ReStrat:createCastTrigger("Holo Hand", "Crushing Blow", crushblow)

		ReStrat:OnDatachron("The Caretaker has returned!", function()
			ReStrat:destroyAlert("Obliteration Beam")
			ReStrat:destroyAlert("Gun Grid")
			ReStrat:destroyAlert("Holo Hands/Guns")
			ReStrat:createAlert("Cannons", 8, nil, ReStrat.color.yellow, function()
				ReStrat:repeatAlert({strLabel = "Next cannons", fRepeat = 23, strColor = ReStrat.color.yellow})
			end)
		end)
	end
end

function ReStrat:yellowInit()
	ReStrat:createCastTrigger("Mobius Physics Constructor", "Data Flare", function()
		ReStrat:createPop("Flare !", nil)
		ReStrat:Sound("Sound\\quack.wav")
	end)
end

function ReStrat:blueInit(unit)
	if unit:GetDispositionTo(GameLib.GetPlayerUnit()) == 0 then -- portal to blue room has same name
		local playerColor = ReStrat.tShortcutBars[7][1].spell:GetName():match("%w+") -- only the first word of "Green/Blue/Red Matrix Key"
	
		local function Matrix(color)
			if color == playerColor then
				ReStrat:createPop(color .. " Disruption Matrix !")
				ReStrat:Sound("Sound\\quack.wav")
			end
		end

		ReStrat:createAuraAlert("Infinite Logic Loop", "Blue Disruption Matrix", 0, nil, function() Matrix("Blue") end) 
		ReStrat:createAuraAlert("Infinite Logic Loop", "Green Reconstitution Matrix", 0, nil, function() Matrix("Green") end) 
		ReStrat:createAuraAlert("Infinite Logic Loop", "Red Empowerment Matrix", 0, nil, function() Matrix("Red") end) 
	
		ReStrat:createPinFromAura("Disruption Matrix Distortion")
	end
end

function ReStrat:latticeInit()
	oblit = 0
	firstbeam = false

	if ReStrat:IsActivated("Avatus", "Devourers Spawn") then
		-- Devourerer
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
	end


	-- jumppphase
	local function jumpphase()
		ReStrat:destroyAllAlerts()
		ReStrat:createAlert("Get Buff and Jump!", 18.83, "Icon_SkillShadow_UI_stlkr_shadowdash", ReStrat.color.green, function()
			ReStrat:createAlert("Jump!", 7.2, "Icon_SkillShadow_UI_stlkr_shadowdash", ReStrat.color.green, function()
				ReStrat:createAlert("Jump!", 6, "Icon_SkillShadow_UI_stlkr_shadowdash", ReStrat.color.green, function()

					ReStrat:createAlert("Next Laser", 26, "Icon_SkillEngineer_Code_Red", ReStrat.color.red, nil)

					if ReStrat:IsActivated("Avatus", "Devourers Spawn") then
						ReStrat:createAlert("Data Devourers", 41, "Icon_SkillEngineer_Anomaly_Launcher", ReStrat.color.orange, devourerspawn)
					end

					ReStrat:createAlert("Next Add Wave", 46, nil, ReStrat.color.purple, deletealldata)
				end)
			end)
		end)
	end
	ReStrat:OnDatachron("The Vertical Locomotion Enhancement Ports have been activated!", jumpphase)

	-- Addspawns
	local function beam()
		if firstbeam then
			ReStrat:createAlert("Next Add Wave", 45, nil, ReStrat.color.purple, nil)
			firstbeam = false
		end
	end

	local function deletealldata()
		firstbeam = true
	end
	ReStrat:createAlert("Next Add Wave", 45, nil, ReStrat.color.purple, deletealldata)
	ReStrat:OnDatachron("Avatus sets his focus on", beam)


	

	-- spreadphase
	ReStrat:OnDatachron("The Secure Sector Enhancement Ports have been activated!", function()
		ReStrat:destroyAllAlerts()
		ReStrat:createAlert("Get Buff and Spread!", 19, "Icon_SkillMedic_sheildsurge", ReStrat.color.green, function()

			ReStrat:createAlert("Next Laser", 25, "Icon_SkillEngineer_Code_Red", ReStrat.color.red, nil)

			if ReStrat:IsActivated("Avatus", "Devourers Spawn") then
				ReStrat:createAlert("Data Devourers", 40, "Icon_SkillEngineer_Anomaly_Launcher", ReStrat.color.orange, devourerspawn)
			end

			ReStrat:createAlert("Next Add Wave", 45, nil, ReStrat.color.purple, deletealldata)
		end)
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
		["Track Exit Power [Event]"] = {
			strLabel = "Track Exit Power [Event]",
			bEnabled = true,
		},
		["Lines to Devourers"] = {
			strLabel = "Lines to Devourers",
			bEnabled = true,
		},
		["Devourers Spawn"] = {
			strLabel = "Devourers Spawn",
			bEnabled = true,
		},
	},
}
