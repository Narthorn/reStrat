-----------------------------------------------------------------------------
--- Avatus, Vim and Lattice by Chill
-- FUCKING HYPE
-----------------------------------------------------------------------------
function ReStrat:avatusInit(unit) -- also lattice for some reason
	ReStrat:createLandmark("N", {618, -198, -235 }, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
	ReStrat:createLandmark("S", {618, -198, -114 }, "ClientSprites:MiniMapMarkerTiny", "Subtitle")

	self.tKeyRed = {}
	self.tKeyGreen = {}
	self.tKeyBlue = {}

	local function yellowInit(unit)
		if unit:GetDispositionTo(GameLib.GetPlayerUnit()) == 0 then -- portal to yellow room has same name
			ReStrat:trackHealth(unit, ReStrat.color.yellow)
			local function blindyellow()
				ReStrat:createPop("Flare!", nil)
			end
			ReStrat:createCastTrigger("Mobius Physics Constructor", "Data Flare", blindyellow)
		end
	end
	ReStrat:createUnitTrigger("Mobius Physics Constructor", yellowInit)
	local function blueInit(strSpellKey)

			local playerColor = strSpellKey:match("%w+") -- only the first word of "Green/Blue/Red Matrix Key"

			local function Matrix(color)
				ReStrat:createPop(color .. " Disruption Matrix !")
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
	ReStrat:createActionBarTrigger("Red Matrix Key", blueInit)
	ReStrat:createActionBarTrigger("Green Matrix Key", blueInit)
	ReStrat:createActionBarTrigger("Blue Matrix Key", blueInit)
	
	local function portalRoomBlue()
		local function redChat(strSender)
			self.tKeyRed[#self.tKeyRed+1] = strSender
		end
		local function blueChat(strSender)
			self.tKeyBlue[#self.tKeyBlue+1] = strSender
		end
		local function greenChat(strSender)
			self.tKeyGreen[#self.tKeyGreen+1] = strSender
		end
		ReStrat:OnPartychron("red", redChat)
		ReStrat:OnPartychron("green", greenChat)
		ReStrat:OnPartychron("blue", blueChat)
	end
	ReStrat:createUnitTrigger("Infinite Logic Loop", portalRoomBlue)
	ReStrat:trackHealth(unit, ReStrat.color.red)
	if not ReStrat.tEncounterVariables.firstPhase then
		local nHands = 1
		
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
			if ReStrat:trackHealth(unit, ReStrat.color.orange, "Hand #" .. nHands) == true then
				ReStrat:createPin(nHands, unit, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
				nHands = nHands + 1
			end
		end
		ReStrat:createUnitTrigger("Holo Hand", handspawn)


		local function crushblow(unit)
			local dist = ReStrat:dist2unit(GameLib.GetPlayerUnit(), unit)
			if dist < 28 then
				ReStrat:createPop("Crushing Blow!")
				ReStrat:Sound("Sound\\crush.wav")
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

function ReStrat:blueRoom(unit)
	if unit:GetDispositionTo(GameLib.GetPlayerUnit()) == 0 then
		Print("blue fight started")
		local function __genOrderedIndex(t)
		    local orderedIndex = {}
		    for key in pairs(t) do
		        table.insert( orderedIndex, key )
		    end
		    table.sort( orderedIndex )
		    return orderedIndex
		end

		local function orderedNext(t, state)
		    -- Equivalent of the next function, but returns the keys in the alphabetic
		    -- order. We use a temporary ordered key table that is stored in the
		    -- table being iterated.

		    if state == nil then
		        -- the first time, generate the index
		        t.__orderedIndex = __genOrderedIndex( t )
		        key = t.__orderedIndex[1]
		        return key, t[key]
		    end
		    -- fetch the next value
		    key = nil
		    for i = 1,table.getn(t.__orderedIndex) do
		        if t.__orderedIndex[i] == state then
		            key = t.__orderedIndex[i+1]
		        end
		    end

		    if key then
		        return key, t[key]
		    end

		    -- no more value to return, cleanup
		    t.__orderedIndex = nil
		    return
		end

		local function orderedPairs(t)
  		  -- Equivalent of the pairs() function on tables. Allows to iterate
  		  -- in order
  		  return orderedNext, t, nil
		end
--TODO better ordering
		local strRed = "Red Buffs: "
		for key, value in pairs(self.tKeyRed) do
            strRed = strRed .. " - " .. tostring(key) .. ". " .. value
        end
		Print(strRed)

		local strBlue = "Blue Buffs: "
		for key, value in pairs(self.tKeyBlue) do
            strBlue = strBlue .. " - " .. tostring(key) .. ". " .. value
        end
		Print(strBlue)

		local strGreen = "Green Buffs: "
		for key, value in pairs(self.tKeyGreen) do
            strGreen = strGreen .. " - " .. tostring(key) .. ". " .. value
        end
		Print(strGreen)
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

	local function devourerspawn2()
			tdev2 = {}
			tdev2.strLabel = "Next Devourers"
			tdev2.fDelay = 15
			tdev2.fDuration = 5
			tdev2.strColor = ReStrat.color.orange
			tdev2.strIcon = "Icon_SkillEngineer_Anomaly_Launcher"
		
			ReStrat:repeatAlert(tdev2, 999)
		end



	-- jumppphase
	local function jumpphase()
		ReStrat:destroyAllAlerts()
		ReStrat:createAlert("Get Buff and Jump!", 18.53, "Icon_SkillShadow_UI_stlkr_shadowdash", ReStrat.color.green, function()
			ReStrat:createAlert("Jump!", 7.2, "Icon_SkillShadow_UI_stlkr_shadowdash", ReStrat.color.green, function()
				ReStrat:createAlert("Jump!", 6, "Icon_SkillShadow_UI_stlkr_shadowdash", ReStrat.color.green, function()

					ReStrat:createAlert("Obliterate Start", 15, nil, ReStrat.color.red, nil)
					ReStrat:createAlert("Next Laser", 26, "Icon_SkillEngineer_Code_Red", ReStrat.color.red, nil)

					if ReStrat:IsActivated("Avatus", "Devourers Spawn") then
						ReStrat:createAlert("Data Devourers", 36, "Icon_SkillEngineer_Anomaly_Launcher", ReStrat.color.orange, devourerspawn2)
					end

					ReStrat:createAlert("Next Add Wave", 41, nil, ReStrat.color.purple, deletealldata)
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
	ReStrat:OnDatachron("Avatus prepares to delete all data!", deletealldata)


	--add casts
	local function bufferPop(unit) --TODO UI check
		if ReStrat:dist2unit(GameLib.GetPlayerUnit, uni) < 32 then
			ReStrat:createPop("Data Buffer!")
		end
	end
	local function nullPop(unit)
		if ReStrat:dist2unit(GameLib.GetPlayerUnit, uni) < 32 then
			ReStrat:createPop("Nullify!")	
		end
	end
	ReStrat:createCastTrigger("Obstinate Logic Wall", "Data Buffer", bufferPop)
	ReStrat:createCastTrigger("Obstinate Logic Wall", "Nullify", nullPop)
	

	-- spreadphase
	ReStrat:OnDatachron("The Secure Sector Enhancement Ports have been activated!", function()
		ReStrat:destroyAllAlerts()
		ReStrat:createAlert("Get Buff and Spread!", 19, "Icon_SkillMedic_sheildsurge", ReStrat.color.green, function()

			ReStrat:createAlert("Obliterate Start", 13, nil, ReStrat.color.red, nil)
			ReStrat:createAlert("Next Laser", 24, "Icon_SkillEngineer_Code_Red", ReStrat.color.red, nil)

			if ReStrat:IsActivated("Avatus", "Devourers Spawn") then
				ReStrat:createAlert("Data Devourers", 34, "Icon_SkillEngineer_Anomaly_Launcher", ReStrat.color.orange, devourerspawn2)
			end

			ReStrat:createAlert("Next Add Wave", 39, nil, ReStrat.color.purple, deletealldata)
		end)
	end)
	
	local function wallSpawn(unit) --TODO test wall hp tracking
		ReStrat:trackHealth(unit, ReStrat.color.green)
	end
	--ReStrat:createUnitTrigger("Wall", wallSpawn)
	--ReStrat:onPlayerHit("Obliterate", "Avatus", 10, wallSpawn)
	ReStrat:onHeal("Wall", 10, wallSpawn)
	ReStrat:createAuraAlert(nil, "Mark of Enmity", nil, "Icon_SkillEngineer_Code_Red", nil)
end



function ReStrat:devourerInit(unit)
	if self:IsActivated("Avatus", "Lines to Devourers") and ReStrat:dist2unit(GameLib.GetPlayerUnit(), unit) < 60 then
		ReStrat.DrawLib:UnitLine(GameLib.GetPlayerUnit(), unit, ReStrat.color.orange)
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

ReStrat.tEncounters["Infinite Logic Loop"] = {
	strCategory = "Not Important",
	trackHealth = ReStrat.color.blue,
	tModules = {},
}
