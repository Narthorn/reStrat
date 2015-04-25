-----------------------------------------------------------------------------
--Mini Bosses, Chill's Profiles
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--Encounter Logic
-----------------------------------------------------------------------------

function ReStrat:canimidInit(unit)

	if ReStrat:IsActivated("Fully-Optimized Canimid", "Show People with Debuff") then
		ReStrat:createPinFromAura("Weak in the Knees") -- add the undermine debuff 
		ReStrat:createAuraAlert(GameLib.GetPlayerUnit():GetName(), "Weak in the Knees", nil, "Icon_SkillMedic_urgency", nil)
		
	end
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