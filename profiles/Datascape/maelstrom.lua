-----------------------------------------------------------------------------
--- mael, chill
-- fuck
-----------------------------------------------------------------------------
function ReStrat:maelInit(unit)
	local mael = "Maelstrom Authority"
	local maelUnit = unit
	--phase = "jump"
	--stationnum = 1
	
	-- jumps
	local shatter = function()
		ReStrat:destroyAllAlerts()
		ReStrat:createAlert("Jump!", 8, "Icon_SkillEnergy_UI_ss_offblnblst", ReStrat.color.orange, function()
			ReStrat:createAlert("Moo!", 13, nil, ReStrat.color.green, nil)
		end)
		--ReStrat:createPop("Jump!", nil)
	end
	ReStrat:OnDatachron("The platform trembles!", shatter)
	
	local shockphase = function()
		ReStrat:createPop("Lightning phase!!!", nil)
		ReStrat:Sound("Sound\\lightning.wav")
	end
	ReStrat:onPlayerHit("Conduction", mael, 70, shockphase)
	
	-- spew
	local spew = function()
		ReStrat:createPop("Spew!", nil)
		ReStrat:Sound("Sound\\spew.wav")
	end
	ReStrat:createCastAlert(mael, "Ice Breath", nil, "Icon_SkillIce_UI_srcr_avlnch", ReStrat.color.red, nil)
	ReStrat:createCastTrigger(mael, "Ice Breath", spew)
	
	-- grapple mechanics
	local grapple = function()
		ReStrat:createPop("Grapple!", nil)
		ReStrat:Sound("Sound\\grapple.wav")
	end
	ReStrat:createCastTrigger(mael, "Crystallize", grapple)
	ReStrat:createCastTrigger(mael, "Typhoon", grapple)
	ReStrat:createCastAlert(mael, "Crystallize", nil, "Icon_SkillMisc_UI_srcr_coldecho", ReStrat.color.red, nil)
	ReStrat:createCastAlert(mael, "Typhoon", nil, "Icon_SkillNature_UI_srcr_dstdvl", ReStrat.color.red, nil)
	
	--windwall
	local windwall = function()
		ReStrat:createPop("Wind Wall", nil)
	end
	ReStrat:createCastAlert(mael, "Wind Wall", nil, "Icon_SkillEngineer_Disruptive_Mod", ReStrat.color.red, nil)
	ReStrat:createCastTrigger(mael, "Wind Wall", windwall)
	
	-- weather stations
	local function stations()
		tStations = {}
		tStations.strLabel = "Next Station"
		tStations.fDelay = 25
		tStations.fDuration = 5
		tStations.strColor = ReStrat.color.blue
		tStations.strIcon = "Icon_SkillStalker_Destructive_Sweep"
	
		ReStrat:repeatAlert(tStations, 99)
		
	end

	local function stationsPop(unit)
		ReStrat:destroyAllLandmarks()
		local tPos = unit:GetPosition()
		if tPos then
			--ReStrat:createLandmark("M", {tPos.x, tPos.y, tPos.z}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
			ReStrat:createLandmark("O", {tPos.x+30, tPos.y, tPos.z}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
			ReStrat:createLandmark("W", {tPos.x-30, tPos.y, tPos.z}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
			ReStrat:createLandmark("S", {tPos.x, tPos.y, tPos.z+30}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
			ReStrat:createLandmark("N", {tPos.x, tPos.y, tPos.z-30}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
		end
	end
	
	ReStrat:createCastAlert(mael, "Activate Weather Cycle", nil, "Icon_SkillStalker_Destructive_Sweep", ReStrat.color.yellow, stations, stationsPop)
	ReStrat:createPinFromAura("Icicle Chain")
end

function ReStrat:stationInit(unit2)
	--stationnum = stationnum +1
	if ReStrat:IsActivated("Maelstrom Authority", "Lines to Stations") then
		ReStrat.DrawLib:UnitLine(GameLib.GetPlayerUnit(), unit2, ReStrat.color.blue)
	end
	ReStrat:createPop("Stun station!", nil)
	ReStrat:Sound("Sound\\stations.wav")
end

function ReStrat:maelEvent(tEventObj)
	--Print("mael func")
	if self:IsActivated("Maelstrom Authority", "Track Weather Cycle [Event]") then
		ReStrat:trackEvent(tEventObj, self.color.yellow, "Weather Cycle")
	end	
end

ReStrat.tEncounters["Maelstrom Authority"] = {
	strCategory  = "Datascape",
	trackHealth = ReStrat.color.red,
	tModules = {
				["Typhoon"] = {
						strLabel = "Typhoon",
						bEnabled = true,
                },				
                ["Crystallize"] = {
                        strLabel = "Crystallize",
                        bEnabled = true,
                },
				["Wind Wall"] = {
                        strLabel = "Wind Wall",
                        bEnabled = true,
                },
				["Ice Breath"] = {
                        strLabel = "Ice Breath",
                        bEnabled = true,
                },
				["Activate Weather Cycle"] = {
                        strLabel = "Activate Weather Cycle",
                        bEnabled = true,
                },
				["Track Weather Cycle [Event]"] = {
                        strLabel = "Track Weather Cycle [Event]",
                        bEnabled = true,
                },
                ["Lines to Stations"] = {
				strLabel = "Lines to Stations",
				bEnabled = true,
				},
		},
}

ReStrat.tEncounters["Weather Station"] = {
	startFunction = stationInit,
	strCategory  = "Not Important",
	trackHealth = ReStrat.color.blue,
	tModules = {},
}

