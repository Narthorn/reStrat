-----------------------------------------------------------------------------
-- Augmentors - Vim

local tBars = {}

local function augmentorsInit(unit)

	-- Cache health bars for color change
	tBars[unit:GetId()] = ReStrat.tHealth[unit:GetId()].bar:FindChild("progressBar")

	if not ReStrat.tEncounterVariables.bStarted then
		ReStrat:OnDatachron("ENGAGING TECHNOPHAGE TRASMISSION", function() -- sic
			ReStrat:createAlert("Expulsion", 12, nil, ReStrat.color.red)
		end)
		
		--ReStrat:repeatAlert({strLabel = "Radiation Bath", fDelay = 15, fRepeat = 30, strColor = ReStrat.color.green})
		
		local function Corrupted(unit) 
			tBars[unit:GetId()]:SetBarColor(ReStrat.color.purple)
		end
		
		local function Uncorrupted(unit)
			tBars[unit:GetId()]:SetBarColor(ReStrat.color.orange)
		end
		
		ReStrat:createAuraTrigger(nil, "Compromised Circuitry", Corrupted, Uncorrupted)			
		
		ReStrat:createPinFromAura("Strain Incubation")
				
		-- Interrupt timer for hardmode laser
		ReStrat:repeatAlert({strLabel = "Laser Interrupt", fDelay = 8, fRepeat = 14, strColor = ReStrat.color.yellow, fCallback = function()
			ReStrat:createPop("Interrupt !")
			Sound.Play(Sound.PlayUIQueuePopsPvP)
		end})
		 
		ReStrat.tEncounterVariables.bStarted = true
	end
	
	local pos = unit:GetPosition()
	local name = pos.z < 875 and "North" or (pos.x < 1268 and "West" or "East")
	ReStrat:trackHealth(unit, ReStrat.color[name == "North" and "purple" or "orange"], name)
	
	local function push()
		ReStrat:createPop("PUSH SOON !")
		Sound.PlayFile("Sound\\quack.wav")
	end
	
	-- Pulls below 20 and 60
	ReStrat:onHealth(unit, 62, push)
	ReStrat:onHealth(unit, 22, push)
end

ReStrat.tEncounters["Prime Phage Distributor"]    = { fInitFunction = augmentorsInit }
ReStrat.tEncounters["Prime Evolutionary Operant"] = { fInitFunction = augmentorsInit }