-----------------------------------------------------------------------------
--Mini Bosses, Chill's Profiles
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------
--("Warmonger Agratha", "Warmonger Talarii", "Grand Warmonger Tar'gresh")
--Frostbringer Warlock
function ReStrat:canimidInit(unit)

	if ReStrat:IsActivated("Fully-Optimized Canimid", "Show People with Debuff") then

		ReStrat:createPinFromAura("Weak in the Knees", nil, false, "CRB_Interface12_BO")
		ReStrat:createAuraAlert(GameLib.GetPlayerUnit():GetName(), "Weak in the Knees", nil, "Icon_SkillMedic_urgency", nil)
		
	end
end

function ReStrat:warlockInit(unit)
	ReStrat:createAlert("Frost Waves", 30, nil, ReStrat.color.orange, nil)
end



-----------------------------------------------------------------------------
--Encounter Packaging
-----------------------------------------------------------------------------


ReStrat.tEncounters["Fully-Optimized Canimid"] = {
	strCategory  = "Datascape",
	tModules = {
		["Show People with Debuff"] = {
			strLabel = "Show People with Debuff",
			bEnabled = true,
		},
	},
}