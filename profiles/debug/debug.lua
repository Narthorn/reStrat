-----------------------------------------------------------------------------
--Debug Profile, only works on Holographic Moodie from Large Training Grounds
-----------------------------------------------------------------------------
--Get the main reStrat addon
self = Apollo.GetAddon("ReStrat");

--Example hook initiate function
local function profileDebug()
	

end

--Example fight initiate function
local function profileDebugInit()
	Print("Initiating combat with Holographic Moodie");
	local foo = function() Print("Hello") end
	ReStrat:createAlert("Entered Combat", 2.5, nil, nil,foo)
end

--Example spam function, there should be very little if anything in here
local function profileDebugRepeat()
	Print("Spammerino Cappucino");
end

--Package encounter
if not self.tEncounters then
	self.tEncounters = {}
end

--Profile Settings
self.tEncounters["Holographic Moodie"] = {
	fInitFunction = profileDebugInit,
	fHookFunction = profileDebug,
	fRepeatFunction = profileDebugRepeat,
	bEnabled = true,
	tModules = {
		["Firestorm"] = {
			strLabel = "Firestorm",
			bEnabled = true,
		},
		["Erupting Fissure"] = {
			strLabel = "Erupting Fissue",
			bEnabled = true,
		},
	}
}