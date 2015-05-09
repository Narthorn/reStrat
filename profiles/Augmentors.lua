-----------------------------------------------------------------------------
-- Augmentors - Vim

local tUnits = {}
local tUnitIds = {}
local tSafeZones = {
	North = {
		{{vPos = Vector3.New(1293.52,-800.50,823.85)},{vPos = Vector3.New(1279.17,-800.50,823.85)}, {vPos = Vector3.New(1286.34,-800.50,811.31)}},
		{{vPos = Vector3.New(1275.14,-800.50,805.10)},{vPos = Vector3.New(1268.16,-800.50,817.68)}, {vPos = Vector3.New(1260.89,-800.50,805.10)}},
		{{vPos = Vector3.New(1249.67,-800.50,811.67)},{vPos = Vector3.New(1257.10,-800.50,823.85)}, {vPos = Vector3.New(1242.75,-800.50,823.85)}},
		{{vPos = Vector3.New(1293.50,-800.50,836.96)},{vPos = Vector3.New(1242.75,-800.50,836.96)}},
	},
	West = {
		{{vPos = Vector3.New(1220.71,-800.50,925.72)},{vPos = Vector3.New(1227.56,-800.50,913.72)}, {vPos = Vector3.New(1234.45,-800.50,925.84)}},
		{{vPos = Vector3.New(1209.13,-800.50,919.06)},{vPos = Vector3.New(1216.00,-800.50,907.12)}, {vPos = Vector3.New(1202.28,-800.50,907.14)}},
		{{vPos = Vector3.New(1209.17,-800.50,881.84)},{vPos = Vector3.New(1216.00,-800.50,893.77)}, {vPos = Vector3.New(1202.30,-800.50,893.76)}},
		{{vPos = Vector3.New(1220.86,-800.50,875.22)},{vPos = Vector3.New(1246.14,-800.50,919.08)}},
	},
	East = {
		{{vPos = Vector3.New(1301.76,-800.50,925.84)},{vPos = Vector3.New(1308.61,-800.50,914.05)}, {vPos = Vector3.New(1315.38,-800.50,925.85)}},
		{{vPos = Vector3.New(1327.09,-800.50,919.15)},{vPos = Vector3.New(1320.18,-800.50,907.40)}, {vPos = Vector3.New(1333.88,-800.50,907.40)}},
		{{vPos = Vector3.New(1333.91,-800.50,893.93)},{vPos = Vector3.New(1320.12,-800.50,893.86)}, {vPos = Vector3.New(1327.08,-800.50,882.00)}},
		{{vPos = Vector3.New(1315.47,-800.50,875.31)},{vPos = Vector3.New(1290.16,-800.50,919.29)}},
	}
}

local function Corrupted(unit)
	local tUnit = tUnits[type(unit) == "string" and tUnitIds[unit] or unit:GetId()] 
	tUnit.bar:SetBarColor(ReStrat.color.purple)
	for _,path in pairs(tUnit.paths) do
		DrawLib:Destroy(path)
	end
	tUnit.paths = {}
	for _,path in pairs(tSafeZones[tUnit.name]) do
		tUnit.paths[#tUnit.paths+1] = DrawLib:Path(path)
	end
end

local function Uncorrupted(unit)
	local tUnit = tUnits[type(unit) == "string" and tUnitIds[unit] or unit:GetId()] 
	tUnit.bar:SetBarColor(ReStrat.color.orange)
	for _,path in pairs(tUnit.paths) do
		DrawLib:Destroy(path)
	end
	tUnit.paths = {}
end

local function Transmission(unit)
	Uncorrupted(unit)
	nHeading = unit:GetHeading()
	if     nHeading >=  1.5 then Corrupted("West")
	elseif nHeading <= -1.5 then Corrupted("East")
	else                         Corrupted("North")
	end
end

local function encounterInit()
	
	for _,tUnit in pairs(tUnits) do
		for _,path in pairs(tUnit.paths) do
			DrawLib:Destroy(path)
		end
	end
	
	ReStrat:createPinFromAura("Strain Incubation")
	
	ReStrat:OnDatachron("ENGAGING TECHNOPHAGE TRASMISSION", function() -- sic
		ReStrat:createAlert("Transmission", 12, nil, ReStrat.color.red)
	end)
	
	--ReStrat:repeatAlert({strLabel = "Radiation Bath", fDelay = 15, fRepeat = 30, strColor = ReStrat.color.green})

	ReStrat:createAuraTrigger(nil, "Compromised Circuitry", Corrupted)
	ReStrat:createCastTrigger(nil, "Transmission", Transmission)
						
	-- Interrupt timer for hardmode laser
	ReStrat:repeatAlert({strLabel = "Laser Interrupt", fDelay = 8, fRepeat = 13.2, strColor = ReStrat.color.yellow, fCallback = function()
		ReStrat:createPop("Interrupt !", nil, Sound.PlayUIQueuePopsPvP)
	end})
end

local function augmentorInit(unit)
	
	local id = unit:GetId()
	local pos = unit:GetPosition()
	local name = pos.z < 875 and "North" or (pos.x < 1268 and "West" or "East")
	ReStrat:trackHealth(unit, ReStrat.color.orange, name)
	
	-- Cache name and health bars
	tUnits[id] = { name = name, bar = ReStrat.tHealth[unit:GetId()].bar:FindChild("progressBar"), paths = {}}
	tUnitIds[name] = id
	
	if not ReStrat.tEncounterVariables.bStarted then
		encounterInit()
		ReStrat.tEncounterVariables.bStarted = true
	end
	
	if name == "North" then Corrupted(unit) end
	
	-- Pulls below 20 and 60
	local function push() ReStrat:createPop("PUSH SOON !", nil, "Sound\\quack.wav") end
	ReStrat:onHealth(unit, 63, push)
	ReStrat:onHealth(unit, 23, push)
	ReStrat:onHealth(unit, 20, Uncorrupted)
	
end

ReStrat.tEncounters["Prime Phage Distributor"]    = { fInitFunction = augmentorInit }
ReStrat.tEncounters["Prime Evolutionary Operant"] = { fInitFunction = augmentorInit }