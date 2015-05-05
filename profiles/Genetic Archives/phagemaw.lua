-----------------------------------------------------------------------------
--Phagemaw, Reglitch's Profile
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Fight initiation function
function ReStrat:phagemawInit()
	bombtot = 0
	bombnum = 0
	--New Bombs
	local bombsCD = function() ReStrat:createAlert("Bomb Cooldown", 20, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert("Phage Maw", "Detonation Bombs", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, bombsCD);
	
	--Destroy alerts if Aerial bombardment starts
	local destroyAlerts = function()
		bombtot = 0
		bombnum = 0
		ReStrat:destroyAllAlerts()
		ReStrat:destroyAllPins()
	end
	
	ReStrat:createCastTrigger("Phage Maw", "Aerial Bombardment", destroyAlerts);
	
	--Crater
	local nextair = function() ReStrat:createAlert("Next Air Phase", 85, nil, ReStrat.color.red, nil) end
	local gettingup = function() ReStrat:createAlert("He's Getting Up!", 5, nil, ReStrat.color.purple, nextair) end
	local moo = function() ReStrat:createAlert("Moment of Opportunity!", 15, nil, ReStrat.color.green, gettingup) end
	ReStrat:createCastAlert("Phage Maw", "Crater", nil, "Icon_SkillMind_UI_espr_crush", ReStrat.color.red, moo);
	
	
end

function ReStrat:bombinit(unit)
	local bombsub = function()
		ReStrat:destroyAlert("Bombs on ground: " .. bombtot, nil)
		bombtot = bombtot - 1
		ReStrat:createAlert("Bombs on ground: " .. bombtot, 600, nil, ReStrat.color.yellow, nil)
	end
	--bombtot = bombtot + 1
	bombnum = bombnum + 1
	ReStrat:createPin(bombnum, unit, nil, "Subtitle")
	ReStrat:trackHealth(unit, ReStrat.color.yellow, "Bomb #" .. bombnum)
	--ReStrat:onPlayerHit("Detonation", nil, 0.5, bombsub)
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
--Print("Phagemaw load")
ReStrat.tEncounters["Phage Maw"] = {
	startFunction = phagemawInit,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Genetic Archives",
	tModules = {
		["Detonation Bombs"] = {
			strLabel = "Detonation Bombs",
			bEnabled = true,
		},
		["Crater"] = {
			strLabel = "Crater",
			bEnabled = true,
		},
	}
}
ReStrat.tEncounters["Detonation Bomb"] = {
	startFunction = bombinit,
	fSpamFunction = profileDebugRepeat,
	strCategory  = "Not Important",
	tModules = {}
}