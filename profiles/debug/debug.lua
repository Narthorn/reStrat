-----------------------------------------------------------------------------
--Debug Profile, only works on Holographic Moodie from Large Training Grounds
-----------------------------------------------------------------------------
self = Apollo.GetAddon("ReStrat");

local function profileDebug()
	

end

local function profileDebugInit()
	Print("Initiating combat with Holographic Moodie");
	local foo = function() Print("Hello") end
	ReStrat:createAlert("Entered Combat", 2.5, nil, nil,foo)
end


--Package encounter
if not self.tEncounters then
	self.tEncounters = {}
end

--Profile Settings
self.tEncounters["Holographic Moodie"] = {
	fMainFunction = profileDebug,
	fInitFunction = profileDebugInit,
	bEnabled = true,
	modules = {
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