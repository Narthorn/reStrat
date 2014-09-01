-----------------------------------------------------------------------------
--Debug Profile, only works on easy mobs in Large Training Grounds
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------
local boss = "Aethros";

--Fight initiation function
local function experimentInit()

	--Torrent
	ReStrat:createCastAlert(boss, "Torrent", nil, nil, ReStrat.color.red, nil)
	
	--Tempest
	ReStrat:createCastAlert(boss, "Tempest", nil, nil, ReStrat.color.red, nil)
	
	--Thunderbolt
	ReStrat:createCastAlert(boss, "Thunderbolt", nil, nil, ReStrat.color.red, nil)
	
	--Corruption Globule Pin
	ReStrat:createPinFromAura("Thunderbolt")
	
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
ReStrat.tEncounters[boss] = {
	fInitFunction = experimentInit,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Stormtalon's Lair",
	tModules = {
		["Torrent"] = {
			strLabel = "Torrent",
			bEnabled = true,
		},
		["Tempest"] = {
			strLabel = "Tempest",
			bEnabled = true,
		},
		["Thunderbolt"] = {
			strLabel = "Thunderbolt",
			bEnabled = true,
		},
	}
}

