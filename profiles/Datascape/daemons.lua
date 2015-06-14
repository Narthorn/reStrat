-----------------------------------------------------------------------------
--System Daemons, Chill's Profile
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------


function ReStrat:daemonInit(unit)
	if ReStrat:IsActivated("Binary System Daemon", "Pin on Daemons (N and S)") then
		if unit:GetName() == "Null System Daemon" then
			ReStrat:createPin("S", unit, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
		end
		
		if unit:GetName() == "Binary System Daemon" then
			ReStrat:createPin("N", unit, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
		end
	end
	
	local pillarphase = 0
	
	nulld = "Null System Daemon"
	binaryd = "Binary System Daemon"
	
	if not ReStrat.tEncounterVariables.bDaemonInit then
		ReStrat.tEncounterVariables.bDaemonInit = true
		
		local function AddWaves()
			if not ReStrat.tEncounterVariables.waves then ReStrat.tEncounterVariables.waves = 0 end --Create the counter
			ReStrat.tEncounterVariables.waves = ReStrat.tEncounterVariables.waves+1;
			if not ReStrat.tEncounterVariables.afterphase2 then ReStrat.tEncounterVariables.afterphase2 = false end --create the counter
			if ReStrat.tEncounterVariables.afterphase2 == false then
				if ReStrat.tEncounterVariables.waves == 3 then
					ReStrat.tEncounterVariables.waves = 0; -- Clear our counter
					ReStrat:createPop("Big add!", nil);
					ReStrat:Sound("Sound\\bigadd.wav")
					ReStrat:createAlert("Next Add Wave (Small)", 50, nil, ReStrat.color.green, AddWaves)
				elseif ReStrat.tEncounterVariables.waves == 2 then
					ReStrat:createPop("Small adds!", nil)
					ReStrat:Sound("Sound\\smalladd.wav")
					ReStrat:createAlert("Next Add Wave (Big)", 50, nil, ReStrat.color.green, AddWaves)
				else
					ReStrat:createPop("Small adds!", nil)
					ReStrat:Sound("Sound\\smalladd.wav")
					ReStrat:createAlert("Next Add Wave (Small)", 50, nil, ReStrat.color.green, AddWaves)
				end
			end
			if ReStrat.tEncounterVariables.afterphase2 == true then
				if ReStrat.tEncounterVariables.waves == 2 then
					ReStrat.tEncounterVariables.waves = 0 -- Clear our counter
					ReStrat:createPop("Big add!", nil)
					ReStrat:Sound("Sound\\bigadd.wav")
					ReStrat:createAlert("Next Add Wave (Small)", 50, nil, ReStrat.color.green, AddWaves)
				else
					ReStrat:createPop("Small adds!", nil)
					ReStrat:Sound("Sound\\smalladd.wav")
					ReStrat:createAlert("Next Add Wave (Big)", 50, nil, ReStrat.color.green, AddWaves)
				end
			end
			
				ReStrat:createAlert("Probe 1 Spawn", 10, nil, ReStrat.color.yellow, function()
					ReStrat:createAlert("Probe 2 Spawn", 10, nil, ReStrat.color.yellow, function()
						ReStrat:createAlert("Probe 3 Spawn", 10, nil, ReStrat.color.yellow, nil)
				end)
			end)
		end
		
		local function Disconnect()
			if ReStrat.tEncounters["Binary System Daemon"].tModules["Tank DC Notification"].bEnabled then
				if GameLib.GetCurrentZoneMap().id == 107 then
					ReStrat:Sound("Sound\\dc.wav")
					ReStrat:Sound("Sound\\dc.wav")
					ReStrat:createPop("Disconnect! Disconnect! Disconnect!", nil)
				end
			end
			ReStrat:createAlert("Next Disconnect", 60, nil, ReStrat.color.purple, nil) 
		end
		
		ReStrat:createAuraAlert(GameLib.GetPlayerUnit():GetName(), "Purge", nil, "Icon_SkillFire_UI_srcr_frybrrg")
		ReStrat:createAlert("Portals Opening", 4, nil, ReStrat.color.orange, nil)
		ReStrat:createAlert("Next Add Wave (Small)", 15, nil, ReStrat.color.green, AddWaves)
		ReStrat:createAlert("Next Disconnect", 45, nil, ReStrat.color.purple, nil)
		ReStrat:OnDatachron("INVALID SIGNAL.", Disconnect)


		--pillars
		local function pillarspawn(unit)
			local distN = ReStrat:dist2coords(unit, 124.18, -225.94, -192,69) -- north
			local distS = ReStrat:dist2coords(unit, 140.53, -225.94, -156.73) -- south
			--Print("N: " .. distN .. " S: " .. distS)
			if distN < distS then -- it's a north pillar
				ReStrat:trackHealth(unit, ReStrat.color.purple, "North pillar")
			else -- it's a south pillar
				ReStrat:trackHealth(unit, ReStrat.color.purple, "South pillar")
			end
		end
		ReStrat:createUnitTrigger("Enhancement Module", pillarspawn)
		
		-- Power Surge Casts (PS)
		local function fBinPS()
			ReStrat:createPop("Binary Power Surge!", nil)
			ReStrat:createAlert("[Binary] Power Surge", 3, "Icon_SkillPetCommand_Combat_Pet_Stay", ReStrat.color.red, nil)
		end
		if ReStrat.tEncounters["Binary System Daemon"].tModules["Binary Power Surge"].bEnabled then -- Binary Power Surge
			ReStrat:createCastTrigger(binaryd, "Power Surge", fBinPS)
		end
		
		local function fNullPS()
			ReStrat:createPop("Null Power Surge!", nil)
			ReStrat:createAlert("[Null] Power Surge", 3, "Icon_SkillPetCommand_Combat_Pet_Stay", ReStrat.color.red, nil)
		end
		if ReStrat.tEncounters["Binary System Daemon"].tModules["Null Power Surge"].bEnabled then -- Null Power Surge
			ReStrat:createCastTrigger(nulld, "Power Surge", fNullPS)
		end
	
	
	
		-- Purge Casts
		local function purgeCD()
			ReStrat:createAlert("Next Purge", 26, "Icon_SkillFire_UI_srcr_frybrrg", ReStrat.color.orange, nil)
		end
	
		local function fBinPurge()
			ReStrat:createPop("Binary Purge!", nil)
			ReStrat:createAlert("[Binary] Purge", 2, "Icon_SkillFire_UI_srcr_frybrrg", ReStrat.color.red, purgeCD)
		end
		if ReStrat.tEncounters["Binary System Daemon"].tModules["Binary Purge"].bEnabled then -- Binary Purge
			ReStrat:createCastTrigger(binaryd, "Purge", fBinPurge)
		end
		
		local function fNullPurge()
			ReStrat:createPop("Null Purge!", nil)
			ReStrat:createAlert("[Null] Purge", 2, "Icon_SkillFire_UI_srcr_frybrrg", ReStrat.color.red, purgeCD)
		end
		if ReStrat.tEncounters["Binary System Daemon"].tModules["Null Purge"].bEnabled then -- Null Purge
			ReStrat:createCastTrigger(nulld, "Purge", fNullPurge)
		end
		
	
		
		local function phaseTwo()
			ReStrat:destroyAllLandmarks()
			pillarphase = pillarphase + 1
			
			if pillarphase == 1 then
			
				if ReStrat:IsActivated("Binary System Daemon", "North Pillar Landmarks") then
					ReStrat:createLandmark("N1", {133.217, -225.94, -207.71}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
					ReStrat:createLandmark("N2", {156.22, -225.94, -198.85}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
					ReStrat:createLandmark("N3", {109.23, -225.94, -198.13}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
				end
					
				if ReStrat:IsActivated("Binary System Daemon", "South Pillar Landmarks") then
					ReStrat:createLandmark("S1", {133.217, -225.94, -140.71}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
					ReStrat:createLandmark("S2", {109.22, -225.94, -150.85}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
					ReStrat:createLandmark("S3", {156.23, -225.94, -150.13}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
				end
				
			else -- pillarphase == 2
				if ReStrat:IsActivated("Binary System Daemon", "North Pillar Landmarks") then
					ReStrat:createLandmark("N1", {109.217, -225.94, -198.71}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
					ReStrat:createLandmark("N2", {156.22, -225.94, -198.85}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
					ReStrat:createLandmark("N3", {99.23, -225.94, -174.13}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
					ReStrat:createLandmark("N4", {133.23, -225.94, -207.13}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
				end
					
				if ReStrat:IsActivated("Binary System Daemon", "South Pillar Landmarks") then
					ReStrat:createLandmark("S1", {109.217, -225.94, -150.71}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
					ReStrat:createLandmark("S2", {156.22, -225.94, -150.85}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
					ReStrat:createLandmark("S3", {133.23, -225.94, -140.13}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
					ReStrat:createLandmark("S4", {166.23, -225.94, -174.13}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
				end
				
			end
			
			ReStrat.tEncounterVariables.afterphase2 = true
			ReStrat:createPop("Pillar phase!", nil)
			ReStrat:Sound("Sound\\pillar.wav")
			ReStrat:destroyAllAlerts()
			
			if ReStrat.tEncounterVariables.waves == 0 then
				ReStrat:createAlert("Next Add Wave (Small)", 95, nil, ReStrat.color.green, AddWaves)
			else
				ReStrat:createAlert("Next Add Wave (Big)", 95, nil, ReStrat.color.green, AddWaves)
			end
				
			ReStrat:createAlert("Next Disconnect", 87, nil, ReStrat.color.purple, nil)
		end

		ReStrat:OnDatachron("COMMENCING ENHANCEMENT SEQUENCE.", phaseTwo);
	end
end

function ReStrat:sdEvent(tEventObj)
	if ReStrat:IsActivated("Binary System Daemon", "Track Firewall (Event)") then
		ReStrat:trackEvent(tEventObj, self.color.yellow, "Firewall")
	end	
end


--Defragmentation Unit
function ReStrat:defragInit()
	defrag = "Defragmentation Unit";
	
	local function blackic()
		ReStrat:createPop("Black IC!", nil)
	end
	local function defragm()
		ReStrat:createPop("Defrag!", nil)
	end
	ReStrat:createCastTrigger(defrag, "Black IC", blackic)
	ReStrat:createCastTrigger(defrag, "Defrag", defragm)
	ReStrat:createCastAlert(defrag, "Black IC", nil, "Icon_SkillMisc_UI_m_enrgypls", ReStrat.color.red, nil)
	ReStrat:createCastAlert(defrag, "Defrag", nil, "Icon_SkillMedic_magneticlockdown", ReStrat.color.red, nil)
end

ReStrat.tEncounters["Binary System Daemon"] = {
	startFunction = daemonInit,
	strCategory  = "Datascape",
	trackHealth = ReStrat.color.green,
	tModules = {
		["Binary Power Surge"] = {
			strLabel = "Binary Power Surge",
			bEnabled = false,
		},
		["Binary Purge"] = {
			strLabel = "Binary Purge",
			bEnabled = false,
		},
		["Null Power Surge"] = {
			strLabel = "Null Power Surge",
			bEnabled = false,
		},
		["Null Purge"] = {
			strLabel = "Null Purge",
			bEnabled = false,
		},
		["Tank DC Notification"] = {
			strLabel = "Tank DC Notification",
			bEnabled = false,
		},
		["Track Firewall (Event)"] = {
			strLabel = "Track Firewall (Event)",
			bEnabled = true,
		},
		["North Pillar Landmarks"] = {
			strLabel = "North Pillar Landmarks",
			bEnabled = true,
		},
		["South Pillar Landmarks"] = {
			strLabel = "South Pillar Landmarks",
			bEnabled = true,
		},
		["Pin on Daemons (N and S)"] = {
			strLabel = "Pin on Daemons (N and S)",
			bEnabled = false,
		},
	},
}
--/eval Print(ReStrat.tEncounters["Binary System Daemon"].trackHealth)
ReStrat.tEncounters["Null System Daemon"] = {
	startFunction = daemonInit,
	strCategory  = "Not Important",
	trackHealth = ReStrat.color.blue,
	tModules = {},
}

ReStrat.tEncounters["Defragmentation Unit"] = {
	startFunction = defragInit,
	strCategory  = "Datascape",
	tModules = {
		["Black IC"] = {
			strLabel = "Black IC",
			bEnabled = true,
		},
		["Defrag"] = {
			strLabel = "Defrag",
			bEnabled = true,
		},
	},
}


