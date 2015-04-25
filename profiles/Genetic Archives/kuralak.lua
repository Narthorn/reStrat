-----------------------------------------------------------------------------
--Kuralak the Defiler, Reglitch's Profile
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Fight initiation function
function ReStrat:kuralakInit()
	local kuralak = "Kuralak the Defiler"

	
	--Initial Generators
	local loldead = function() if GameLib.GetPlayerUnit():IsDead() then Print("Really :D?") end end
	ReStrat:createAlert("Avoid the Red!", 4, "Icon_SkillSbuff_higherjumpbuff", ReStrat.color.orange, loldead);
	
	ReStrat:createLandmark("N", {173.47, -111.66, -503.01}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
	ReStrat:createLandmark("E", {183.34, -111.66, -486}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
	ReStrat:createLandmark("S", {165.32, -111.66, -475.98}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
	ReStrat:createLandmark("W", {155.45, -111.66, -492.99}, "ClientSprites:MiniMapMarkerTiny", "Subtitle")
				
	
	
	--Eggs
	function ReStrat:chromosomepop()
		ReStrat:createPop("Eggs!", nil)
		ReStrat:createAlert("Egg Cooldown", 70, nil, ReStrat.color.orange, nil)
	end
	ReStrat:OnDatachron("The corruption begins to fester!", chromosomepop)
	
	--Destroy Vanish Alerts
	local destroyAlerts = function()
		ReStrat:destroyAllAlerts()
		self:chromosomepop()
	end
	ReStrat:OnDatachron("you will become one of us...", destroyAlerts)
	ReStrat:OnDatachron("Through the Strain you will be transformed", destroyAlerts)
	ReStrat:OnDatachron("Your form is flawed, but I will make you beautiful", destroyAlerts)
	ReStrat:OnDatachron("Let the Strain perfect you", destroyAlerts)  
	ReStrat:OnDatachron("The Experiment has failed", destroyAlerts)  
	ReStrat:OnDatachron("Join us... become one with the Strain", destroyAlerts) 
	ReStrat:OnDatachron("One of us... you will become one of us", destroyAlerts)

	--DNA Siphon
	local siphonpop = function()
		ReStrat:createAlert("DNA Siphon!", 3, nil, ReStrat.color.red, nil)
		ReStrat:createAlert("DNA Siphon Cooldown", 60, nil, ReStrat.color.purple, nil)
	end
	if self:IsActivated(kuralak, "DNA Siphon") then
		ReStrat:OnDatachron("has been anesthetized", siphonpop)
	end
	
	--Outbreak
	local outbreakpop = function()
		ReStrat:createPop("Outbreak!", nil);
		ReStrat:Sound("Sound\\outbreak.wav")
		ReStrat:createAlert("Outbreak", 8, "Icon_SkillSpellslinger_regenerative_pulse", ReStrat.color.red, function()
			ReStrat:createAlert("Outbreak Cooldown", 32, nil, ReStrat.color.yellow, nil);
		end)
	end
	if self:IsActivated(kuralak, "Outbreak") then
		ReStrat:OnDatachron("Kuralak the Defiler causes a violent outbreak of corruption!", outbreakpop)
	end
	
	--Vanish into Darkness
	local vidCD = function() ReStrat:createAlert("Vanish Cooldown", 50, nil, ReStrat.color.orange, nil) end
	if self:IsActivated(kuralak, "Vanish into Darkness") then
		ReStrat:createCastAlert("Kuralak the Defiler", "Vanish into Darkness", nil, "Icon_SkillMind_UI_espr_cnfs", ReStrat.color.red, vidCD);
	end
	
	--Chromosome Corruption Pin
	ReStrat:createPinFromAura("Chromosome Corruption")
	
end

--Spam function, ONLY USE IF NECESSARY
local function profileDebugRepeat()
	
end



-----------------------------------------------------------------------------
--Encounter Packaging
-----------------------------------------------------------------------------
if not ReStrat.tEncounters then
	ReStrat.tEncounters = {}
end

--Profile Settings
ReStrat.tEncounters["Kuralak the Defiler"] = {
	startFunction = kuralakInit,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Genetic Archives",
	tModules = {
		["Chromosome Corruption"] = {
			strLabel = "Chromosome Corruption",
			bEnabled = true,
		},
		["Cultivate Corruption"] = {
			strLabel = "Cultivate Corruption",
			bEnabled = true,
		},
		["DNA Siphon"] = {
			strLabel = "DNA Siphon",
			bEnabled = true,
		},
		["Outbreak"] = {
			strLabel = "Outbreak",
			bEnabled = true,
		},
		["Vanish into Darkness"] = {
			strLabel = "Vanish into Darkness",
			bEnabled = true,
		},
	}
}

