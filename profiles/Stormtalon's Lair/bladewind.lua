-----------------------------------------------------------------------------
--Bladewind, Reglitch's Profile
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------
local boss = "Blade-Wind the Invoker"

--Fight initiation function
local function experimentInit()
	
	--Thunder Cross
	local crossCD = function() ReStrat:createAlert("Thunder Cross Cooldown", 10, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert(boss, "Thunder Cross", nil, nil, ReStrat.color.red, crossCD)
	
	--Sonic Barrier [Phase 2]
	local phase2 = function() ReStrat:createPop("Phase 2!", nil) end
	ReStrat:createCastTrigger(boss, "Sonic Barrier", phase2)
	
	--Lightning Strike
	ReStrat:createCastAlert(boss, "Lightning Strike", nil, nil, ReStrat.color.red, nil)
	
	--Electrostatic Pulse
	ReStrat:createCastAlert(boss, "Electrostatic Pulse", nil, nil, ReStrat.color.red, nil)
	
	--Lightning Strike Pin
	ReStrat:createPinFromAura("Lightning Strike")
	
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
		["Thunder Cross"] = {
			strLabel = "Thunder Cross",
			bEnabled = true,
		},
		["Lightning Strike"] = {
			strLabel = "Lightning Strike",
			bEnabled = true,
		},
		["Electrostatic Pulse"] = {
			strLabel = "Electrostatic Pulse",
			bEnabled = true,
		},
	}
}

