-----------------------------------------------------------------------------
--Debug Profile, only works on easy mobs in Large Training Grounds
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------
boss = "Stormtalon"

function ReStrat:stormInit()
	
	--Lightning Strike
	ReStrat:createCastAlert(boss, "Lightning Strike", nil, nil, nil, nil)

	--Lightning Storm
	ReStrat:createCastAlert(boss, "Lightning Storm", nil, nil, nil, nil)
	
	--Thunder Call
	ReStrat:createCastAlert(boss, "Thunder Call", nil, nil, nil, nil)
	
	--Lightning Rod
	ReStrat:createAuraAlert(boss, "Lightning Rod", nil, nil, nil, nil)
	
	--Static Wave
	ReStrat:createCastAlert(boss, "Static Wave", nil, nil, nil, nil)
	
	--Lightning Rod Pin
	ReStrat:createPinFromAura("Lightning Rod")
	
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
ReStrat.tEncounters["Stormtalon"] = {
	startFunction = stormInit,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Stormtalon's Lair",
	tModules = {
		["Lightning Strike"] = {
			strLabel = "Lightning Strike",
			bEnabled = true,
		},
		["Lightning Storm"] = {
			strLabel = "Lightning Storm",
			bEnabled = true,
		},
		["Thunder Call"] = {
			strLabel = "Thunder Call",
			bEnabled = true,
		},
		["Lightning Rod"] = {
			strLabel = "Lightning Rod",
			bEnabled = true,
		},
		["Static Wave"] = {
			strLabel = "Static Wave",
			bEnabled = true,
		},
	}
}

