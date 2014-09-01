--[[

Name: LibCombatLogFixes-1.0
Revision: $Revision: 1 $
Author: msc_
Inspired By: wow's halfdecent combat log event system ...
Dependencies: none

License: LibCombatLogFixes-1.0 is hereby placed in the Public Domain.

Usage: none, just load it in your toc.xml and register for the events enumerated below as you normally would

Description:

THIS LIBRARY IS EXPERIMENTAL. It probably sucks, has bugs, is going to blow up your PC and steal your plat. Use at your own risk.

LibCombatLogFixes-1.0 provides events missing from CRB combatlog:

_LCLF_UnitDied(tUnitKilled)
_LCLF_SpellAuraApplied(intSpellId, intStackCount, tTargetUnit)
_LCLF_SpellAuraAppliedDose(intSpellId, intStackCount, tTargetUnit)
_LCLF_SpellAuraRemoved(intSpellId, intStackCount, tTargetUnit)
_LCLF_SpellAuraRemovedDose(intSpellId, intStackCount, tTargetUnit)
_LCLF_SpellCastStart(strSpellName, tCasterUnit)
_LCLF_SpellCastSuccess(strSpellName, tCasterUnit)

ALL of the above fire only for units currently in combat, if and only if you registered for them BEFORE the unit entered combat.

IMPORTANT! You need to register for the events BEFORE the unit you wish to track enters combat, as we are not using UnitCreated to maintain a shred of efficiency.

CAVEATS:
1) SpellCastStart/Success will not fire for instant cast spells, but those can usually be tracked by other means (auras/damage)
2) There might be a race condition in tracking spell casts and we might be erroneously firing _LCLF_SpellCastSuccess
3) We are processing units every 4th frame, which might mean we are missing some events. If you are testing just increment MINOR revision and change it to every frame. If you don't know how, you have no business reading this anyway.

TO DO: allow filtering by unitId when registering? We hook Apollo.RegisterEventHandler anyways ...

--]]



local MAJOR, MINOR = "LibCombatLogFixes-1.0", 1
-- Get a reference to the package information if any
local APkg = Apollo.GetPackage(MAJOR)
-- If there was an older version loaded we need to see if this is newer
if APkg and (APkg.nVersion or 0) >= MINOR then
	return -- no upgrade needed
end

-- Set a reference to the actual package or create an empty table
local Lib = APkg and APkg.tPackage or {}

local evtHandler = {}

-- not very nice, but we need to know when addons register for our events. Storing original in Lib to support upgrading of revisions.
-- will probably break when someone tries to UNhook those within their own addon/package ...
Lib.origRegisterEventHandler = Lib.origRegisterEventHandler or Apollo.RegisterEventHandler
Apollo.RegisterEventHandler = function(...)
	local evtName = ...
	if evtName and evtHandler[evtName] then
		evtHandler[evtName]:Start()
	end
	return Lib.origRegisterEventHandler(...)
end

Lib.origRemoveEventHandler = Lib.origRemoveEventHandler or Apollo.RemoveEventHandler
Apollo.RemoveEventHandler = function(...)
	local evtName = ...
	if evtName and evtHandler[evtName] then
		evtHandler[evtName]:Stop()
	end
	return Lib.origRemoveEventHandler(...)
end

-- upvalues
local next, Apollo, Event_FireGenericEvent = next, Apollo, Event_FireGenericEvent

-- locals to track feature usage
local iTrackSpells = 0
local iTrackBuffs = 0
local iTrackDeaths = 0
local iUnitEnteredCombat = 0
local iSpellCastFailed = 0

local trackedUnits = {}

-- CUSTOM EVENTS

--- _LCLF_UnitDied(tUnitKilled)

evtHandler['_LCLF_UnitDied'] = {
	isActive = false,
	Start = function(self)
		if self.isActive then return end
		
		self.isActive = true
		-- using UnitEnteredCombat and checking for HP is more efficient than using CombatLogDamage, a lot fewer calls.
		if iUnitEnteredCombat == 0 then
			Apollo.RegisterEventHandler('UnitEnteredCombat', 'OnUnitEnteredCombat', evtHandler)
		end
		iTrackDeaths = iTrackDeaths + 1
		iUnitEnteredCombat = iUnitEnteredCombat + 1
	end,
	Stop = function(self)
		if not self.isActive then return end
		
		self.isActive = false
		iTrackDeaths = iTrackDeaths - 1
		iUnitEnteredCombat = iUnitEnteredCombat - 1
		if iUnitEnteredCombat == 0 then
			Apollo.RemoveEventHandler('UnitEnteredCombat', evtHandler)
		end
	end

}

--- _LCLF_SpellAuraApplied(intSpellId, intStackCount, tTargetUnit)
evtHandler['_LCLF_SpellAuraApplied'] = {
	isActive = false,
	Start = function(self)
		if self.isActive then return end
		
		self.isActive = true
		if iUnitEnteredCombat == 0 then
			Apollo.RegisterEventHandler('UnitEnteredCombat', 'OnUnitEnteredCombat', evtHandler)
		end
		
		if iTrackBuffs == 0 and iTrackSpells == 0 then
			Apollo.RegisterEventHandler('VarChange_FrameCount', 'OnUpdateTrackedUnits', evtHandler)
		end
		
		iTrackBuffs = iTrackBuffs + 1
		iUnitEnteredCombat = iUnitEnteredCombat + 1

	end,
	Stop = function(self)
		if not self.isActive then return end
		
		self.isActive = false
		iTrackBuffs = iTrackBuffs - 1
		iUnitEnteredCombat = iUnitEnteredCombat - 1
		
		if iUnitEnteredCombat == 0 then
			Apollo.RemoveEventHandler('UnitEnteredCombat', evtHandler)
		end
		
		if iTrackBuffs == 0 and iTrackSpells == 0 then
			Apollo.RemoveEventHandler('VarChange_FrameCount', evtHandler)
			trackedUnits = {}
		end
	end
}

--- _LCLF_SpellAuraAppliedDose(intSpellId, intStackCount, tTargetUnit)
evtHandler['_LCLF_SpellAuraAppliedDose'] = {
	isActive = false,
	Start = evtHandler['_LCLF_SpellAuraApplied'].Start,
	Stop = evtHandler['_LCLF_SpellAuraApplied'].Stop
}

--- _LCLF_SpellAuraRemoved(intSpellId, intStackCount, tTargetUnit)
evtHandler['_LCLF_SpellAuraRemoved'] = {
	isActive = false,
	Start = evtHandler['_LCLF_SpellAuraApplied'].Start,
	Stop = evtHandler['_LCLF_SpellAuraApplied'].Stop
}

--- _LCLF_SpellAuraRemovedDose(intSpellId, intStackCount, tTargetUnit)
evtHandler['_LCLF_SpellAuraRemovedDose'] = {
	isActive = false,
	Start = evtHandler['_LCLF_SpellAuraApplied'].Start,
	Stop = evtHandler['_LCLF_SpellAuraApplied'].Stop
}

--- _LCLF_SpellCastStart(strSpellName, tCasterUnit)
evtHandler['_LCLF_SpellCastStart'] = {
	isActive = false,
	Start = function(self)
		if self.isActive then return end
		
		self.isActive = true
		if iUnitEnteredCombat == 0 then
			Apollo.RegisterEventHandler('UnitEnteredCombat', 'OnUnitEnteredCombat', evtHandler)
		end
		
		if iTrackBuffs == 0 and iTrackSpells == 0 then
			Apollo.RegisterEventHandler('VarChange_FrameCount', 'OnUpdateTrackedUnits', evtHandler)
		end
		
		if iTrackSpells == 0 then
			-- not really needed for SpellCastStart, but still ...
			Apollo.RegisterEventHandler('SpellCastFailed', 'OnSpellCastFailed', evtHandler)
		end
		
		iTrackSpells = iTrackSpells + 1
		iUnitEnteredCombat = iUnitEnteredCombat + 1
		iSpellCastFailed = iSpellCastFailed + 1

	end,
	Stop = function(self)
		if not self.isActive then return end
		
		self.isActive = false
		iTrackSpells = iTrackSpells - 1
		iUnitEnteredCombat = iUnitEnteredCombat - 1
		iSpellCastFailed = iSpellCastFailed - 1
		
		if iUnitEnteredCombat == 0 then
			Apollo.RemoveEventHandler('UnitEnteredCombat', evtHandler)
		end

		if iSpellCastFailed == 0 then
			Apollo.RemoveEventHandler('SpellCastFailed', evtHandler)
		end
		
		if iTrackBuffs == 0 and iTrackSpells == 0 then
			Apollo.RemoveEventHandler('VarChange_FrameCount', evtHandler)
			trackedUnits = {}
		end
	end
}

--- _LCLF_SpellCastSuccess(strSpellName, tCasterUnit)
evtHandler['_LCLF_SpellCastSuccess'] = {
	isActive = false,
	Start = evtHandler['_LCLF_SpellCastStart'].Start,
	Stop = evtHandler['_LCLF_SpellCastStart'].Stop
}

local function convertBuffs(tBuffs)
	local tBuffsOut = {}
	
	for _, buffType in next, tBuffs do
		for _, buff in next, buffType do
			tBuffsOut[buff.splEffect:GetId()] = buff.nCount
		end
	end

	return tBuffsOut
end


function evtHandler:OnUnitEnteredCombat(objUnit, bInCombat)
	-- more efficient than subscribing to CombatLogDamage. Surprise! we can't call objUnit:IsDead(), because it's not dead yet according to API...
	-- might break if we actually get units that stop at health == 0 (instead of 1) and refuse to die.
	if iTrackDeaths > 0 and not bInCombat and objUnit:GetHealth() == 0 then
		Event_FireGenericEvent('_LCLF_UnitDied', objUnit)
	end
	-- start/stop tracking units entering/leaving combat if someone subscribed to our events
	if iTrackSpells > 0 or iTrackBuffs > 0 then
		if bInCombat then
			trackedUnits[objUnit:GetId()] = { unit = objUnit, buffs = convertBuffs(objUnit:GetBuffs()), spell = { isCasting = objUnit:IsCasting(), spellName = objUnit:GetCastName() } }
		else
			trackedUnits[objUnit:GetId()] = nil
		end
	end
end

function evtHandler:OnUpdateTrackedUnits()
	-- shouldn't really happen (?)
	if iTrackSpells == 0 and iTrackBuffs == 0 then return end
	
	for unitId, data in next, trackedUnits do
		-- clear units that were destroyed w/o leaving combat i.e. we went out of range
		if not data.unit:IsValid() then
			trackedUnits[unitId] = nil
		else
			-- process aura tracking
			if iTrackBuffs > 0 then
				local oldBuffs = data.buffs
				data.buffs = convertBuffs(data.unit:GetBuffs())
				
				for buffId, stackCount in next, data.buffs do
					local oldStackCount = oldBuffs[buffId]
					if oldStackCount then
						if stackCount == oldStackCount then
							oldBuffs[buffId] = nil
						elseif stackCount > oldStackCount and evtHandler['_LCLF_SpellAuraAppliedDose'].isActive then
							Event_FireGenericEvent('_LCLF_SpellAuraAppliedDose', buffId, stackCount, data.unit)
						elseif evtHandler['_LCLF_SpellAuraRemovedDose'].isActive then
							Event_FireGenericEvent('_LCLF_SpellAuraRemovedDose', buffId, stackCount, data.unit)
						end
					elseif evtHandler['_LCLF_SpellAuraApplied'].isActive then
						Event_FireGenericEvent('_LCLF_SpellAuraApplied', buffId, stackCount, data.unit)
					end
				end
				
				if evtHandler['_LCLF_SpellAuraRemoved'].isActive then
					for buffId, stackCount in next, oldBuffs do
						Event_FireGenericEvent('_LCLF_SpellAuraRemoved', buffId, 0, data.unit)
					end
				end
			end
			-- process spell_cast tracking
			if iTrackSpells > 0 then
				-- all of this assumes we don't get a race condition with OnSpellCastFailed ...
				local isCasting = data.unit:IsCasting()
				local spellName = data.unit:GetCastName()
				if isCasting and data.spell.isCasting and spellName ~= data.spell.spellName then
					Event_FireGenericEvent('_LCLF_SpellCastSuccess', data.spell.spellName, data.unit)
					data.spell = { isCasting = true, spellName = spellName }
					Event_FireGenericEvent('_LCLF_SpellCastStart', data.spell.spellName, data.unit)
				elseif isCasting and not data.spell.isCasting then
					data.spell = { isCasting = isCasting, spellName = spellName }
					Event_FireGenericEvent('_LCLF_SpellCastStart', data.spell.spellName, data.unit)
				elseif not isCasting and data.spell.isCasting then
					Event_FireGenericEvent('_LCLF_SpellCastSuccess', data.spell.spellName, data.unit)
					data.spell = { isCasting = false, spellName = '' }
				else
					-- NOOP
				end
			end
		end
	end
end

function evtHandler:OnSpellCastFailed(eMessageType,eCastResult,unitTarget,unitSource,strMessage,sSpellName)
	local unitId = unitSource:GetId()
	if trackedUnits[unitId] then
		trackedUnits[unitId].spell = {isCasting = false, spellName = '' }
	end
end

Apollo.RegisterPackage(Lib, MAJOR, MINOR, {})
