-----------------------------------------------------------------------------
--Debug Profile, only works on easy mobs in Large Training Grounds
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

--Fight initiation function
local function phagemawInit()

	--New Bombs
	local bombsCD = function() ReStrat:createAlert("Bomb Cooldown", 20, nil, ReStrat.color.orange, nil) end
	ReStrat:createCastAlert("Phage Maw", "Detonation Bombs", nil, "Icon_SkillMedic_devastatorprobes2", ReStrat.color.red, bombsCD);
	
	--Destroy alerts if Aerial bombardment starts
	local destroyAlerts = function()
		ReStrat:DestroyAlert("Bomb Cooldown", false);	
	end
	
	ReStrat:createCastTrigger("Phage Maw", "Aerial Bombardment", destroyAlerts);
	
	--Crater
	local gettingup = function() ReStrat:createAlert("He's Getting Up!", 5, nil, ReStrat.color.purple, nil) end
	local moo = function() ReStrat:createAlert("Moment of Opportunity!", 15, nil, ReStrat.color.green, gettingup) end
	ReStrat:createCastAlert("Phage Maw", "Crater", nil, "Icon_SkillMind_UI_espr_crush", ReStrat.color.red, moo);
	
	
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
ReStrat.tEncounters["Phage Maw"] = {
	fInitFunction = phagemawInit,
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

