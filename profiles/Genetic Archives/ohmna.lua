-----------------------------------------------------------------------------
--Ohmna, Reglitch's Profile
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Fight initiation function
function ReStrat:ohmnaInit(unit)
	nextgenerator = "highest"
	eruptlistener = false
	local ohmna = "Dreadphage Ohmna";
	if unit ~= nil and ReStrat:IsActivated(ohmna, "Boss Life") then 
		ReStrat:trackHealth(unit, ReStrat.color.red) 
	end
	firsttentacle = true
	lastphasestarted = false
	
	--Boredom
	if self:IsActivated("Dreadphage Ohmna", "Boredom (Tank Switch)") then
		local boredCD = function()
			ReStrat:createPop("Boredom!")
			ReStrat:createAlert("Bored Cooldown!", 42, nil, ReStrat.color.purple, nil)
		end
		ReStrat:OnDatachron("Dreadphage Ohmna is bored with", boredCD)
		ReStrat:createAlert("Bored Cooldown!", 45, nil, ReStrat.color.purple, nil)
	end
	
	--Devour
	if self:IsActivated("Dreadphage Ohmna", "Devour") then
		local devourpop = function()
			if not lastphasestarted then 
				ReStrat:createPop("Devour!", nil)
				ReStrat:Sound("Sound\\devour.wav")
			end
		end
		ReStrat:OnDatachron("Dreadphage Ohmna hungers....", devourpop)
		ReStrat:createCastAlert(ohmna, "Devour", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, nil)
	end	
	
	--Genetic Torrent 
	local spewcount = function()
		if not lastphasestarted then
			if not ReStrat.tEncounterVariables.torrent then ReStrat.tEncounterVariables.torrent = 0 end
			ReStrat.tEncounterVariables.torrent = ReStrat.tEncounterVariables.torrent+1
			if ReStrat.tEncounterVariables.torrent == 2 and unit:GetHealth() > 6000000 then
				ReStrat:createPop("Add phase after Spew!", nil)
				ReStrat.tEncounterVariables.torrent = 0
			else
				ReStrat:createAlert("Next Spew", 80, nil, ReStrat.color.orange, nil)
			end
		end
	end
	ReStrat:createCastAlert(ohmna, "Genetic Torrent", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, spewcount)
	if self:IsActivated("Dreadphage Ohmna", "Genetic Torrent") then
		ReStrat:createAlert("First Spew", 27, nil, ReStrat.color.orange, nil)
	end
	
	--Generator
	local generatorCD = function()
		if unit:GetHealth() > 3000000 then
			if nextgenerator == "lowest" then
				ReStrat:createAlert("Next Generator (lowest HP)", 25, nil, ReStrat.color.yellow, nil)
				nextgenerator = "highest"
			else -- highest
				ReStrat:createAlert("Next Generator (highest HP)", 25, nil, ReStrat.color.yellow, nil)
				nextgenerator = "lowest"
			end
		end
	end
	ReStrat:createAlert("First Generator", 25, nil, ReStrat.color.yellow, nil)
	ReStrat:OnDatachron("A plasma leech begins draining the", generatorCD)
	
	--addphase handler
	local aftererrupt = function()
		if eruptlistener then
			if nextgenerator == "lowest" then -- reversed here :)
				ReStrat:createAlert("Next Generator (highest HP)", 32, nil, ReStrat.color.yellow, nil)
			else -- highest
				ReStrat:createAlert("Next Generator (lowest HP)", 32, nil, ReStrat.color.yellow, nil)
			end
		end
		eruptlistener = false
	end
	
	local addphase = function()
		eruptlistener = true
		ReStrat:destroyAllAlerts()
		ReStrat:createCastTrigger("Dreadphage Ohmna", "Erupt", aftererrupt)
	end
	ReStrat:OnDatachron("Dreadphage Ohmna submerges into the Bi", addphase)
	
	--tentaclespawn handler
	local nextspawnsoon = function()
		firsttentacle = false
	end
	local tentaclespawn = function()
		if firsttentacle == false then
			ReStrat:createAlert("Tentacles", 19, nil, ReStrat.color.blue, nextspawnsoon)
		end	
		firsttentacle = true
	end
	if self:IsActivated("Dreadphage Ohmna", "Tentacle Spawns") then
		ReStrat:createUnitTrigger("Tentacle of Ohmna", tentaclespawn)
	end
	
	
	--3worm mechanics
	local lastphasespew = function()
		ReStrat:createAlert("Spew!", 17, nil, ReStrat.color.red, nil)
		ReStrat:createPop("Spew!", nil)
		ReStrat:Sound("Sound\\spew.wav")
	end
	local smalldevour = function(caster)
		if ReStrat:dist2unit(GameLib.GetPlayerUnit(), caster) < 23 then
			ReStrat:createPop("Devour!", nil)
			ReStrat:Sound("Sound\\devour.wav")
			ReStrat:createAlert("Devour!", 5, nil, ReStrat.color.red, nil)
		end
	end
	local lastphase = function()
		ReStrat:destroyAllAlerts()
		lastphasestarted = true
		if self:IsActivated("Dreadphage Ohmna", "Genetic Torrent") then
			ReStrat:createCastTrigger(ohmna, "Genetic Torrent", lastphasespew)
		end
		ReStrat:createCastTrigger("Ravenous Maw of the Dreadphage", "Devour", smalldevour)
	end
	
	ReStrat:OnDatachron("The Archives quake with the furious might of the Dreadphage", lastphase)
end

function ReStrat:ohmnanorth(tEventObj)
	if self:IsActivated("Dreadphage Ohmna", "Track Generators [Event]") then
		ReStrat:trackEvent(tEventObj, self.color.yellow, "North Generator")
	end	
end
function ReStrat:ohmnaeast(tEventObj)
	if self:IsActivated("Dreadphage Ohmna", "Track Generators [Event]") then
		ReStrat:trackEvent(tEventObj, self.color.yellow, "East Generator")
	end	
end
function ReStrat:ohmnasouth(tEventObj)
	if self:IsActivated("Dreadphage Ohmna", "Track Generators [Event]") then
		ReStrat:trackEvent(tEventObj, self.color.yellow, "South Generator")
	end	
end
function ReStrat:ohmnawest(tEventObj)
	if self:IsActivated("Dreadphage Ohmna", "Track Generators [Event]") then
		ReStrat:trackEvent(tEventObj, self.color.yellow, "West Generator")
	end	
end
-----------------------------------------------------------------------------
--Encounter Packaging
-----------------------------------------------------------------------------
if not ReStrat.tEncounters then
	ReStrat.tEncounters = {}
end

--Profile Settings
ReStrat.tEncounters["Dreadphage Ohmna"] = {
	startFunction = ohmnaInit,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Genetic Archives",
	tModules = {
		["Devour"] = {
			strLabel = "Devour",
			bEnabled = true,
		},
		["Genetic Torrent"] = {
			strLabel = "Genetic Torrent (Spew)",
			bEnabled = true,
		},
		["Track Generators [Event]"] = {
			strLabel = "Track Generators [Event]",
			bEnabled = true,
		},
		["Boredom (Tank Switch)"] = {
			strLabel = "Boredom (Tank Switch)",
			bEnabled = false,
		},
		["Tentacle Spawns"] = {
			strLabel = "Tentacle Spawns",
			bEnabled = true,
		},
		["Boss Life"] = {
			strLabel = "Boss Life",
			bEnabled = true,
		},
	},
}

