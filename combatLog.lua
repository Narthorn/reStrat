-----------------------------------------------------------------------------------------------
-- Combatlog Functions
-- Created by Ryan Park, aka Reglitch of Codex
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Start Casting
-----------------------------------------------------------------------------------------------

function ReStrat:OnCombatLogCast()
	for i = 1, #self.tUnits do
		if self.tUnits[i].unit then
			if self.tUnits[i].unit:IsCasting() then
				if not castCurrentTime or self.combatTimer > castCurrentTime+(self.tUnits[i].unit:GetCastDuration()/1000)+2 then
					if self.tUnits[i].unit:ShouldShowCastBar() then
						castCurrentTime = self.combatTimer;
						if not self.combatlog then self.combatlog = {} end --create combat log if it doesnt exist
						
						--Add event into self.combatlog
						self.combatlog[#self.combatlog+1] = { source = self.tUnits[i].name, type="cast_start", time = self.combatTimer, duration = self.tUnits[i].unit:GetCastDuration()  }
					end
				end
			end
		end
	end
end