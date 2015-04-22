-----------------------------------------------------------------------------
-- Maelstrom - Vim

local function maelstromInit()
	local function WeatherStations()
		ReStrat:createAlert("Next Weather Stations", 25, "Icon_SkillMisc_Scientist_Generator", ReStrat.color.red, WeatherStations)
	end
	ReStrat:createCastAlert("Maelstrom Authority", "Activate Weather Cycle", nil, "Icon_SkillMisc_Scientist_Generator", ReStrat.color.red, WeatherStations)
	
	ReStrat:createCastTrigger("Maelstrom Authority", "Shatter", function()
		ReStrat:destroyAlert("Activate Weather Cycle")
		ReStrat:destroyAlert("Next Weather Stations")
	end)
end

local function stationInit(unit)
	DrawLib:UnitLine(GameLib.GetPlayerUnit(), unit)
end

ReStrat.tEncounters["Maelstrom Authority"] = {
	fInitFunction = maelstromInit,
	strCategory  = "Datascape",
	trackHealth = ReStrat.color.blue,
	tModules = {
		["Activate Weather Cycle"] = {
			strLabel = "Weather Stations",
			bEnabled = true,
		},
	}
}

ReStrat.tEncounters["Weather Station"] = {
	fInitFunction = stationInit,
	strCategory  = "Datascape",
	trackHealth = ReStrat.color.red,
	tModules = {},
}