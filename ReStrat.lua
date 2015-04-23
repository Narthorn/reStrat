-----------------------------------------------------------------------------------------------
-- reStrat - Wildstar Boss Mods
--- Created by Ryan Park, aka Reglitch of Codex
---- Maintained by Vim <Codex>
--- Overhauled by Chill
-----------------------------------------------------------------------------------------------

require "Sound"
 
ReStrat = {
	name = "ReStrat",
	version = "1.8.6",
	fileversion = 186,
	tVersions = {},
	barSpacing = 6,
	color = {
		red = "ffb8413d",
		orange = "ffdd7649",
		yellow = "fff8fd6b",
		green = "ff58cc5d",
		blue = "ff5196ec",
		purple = "ff915fc2",
		black = "black",
		white = "white",
	},
	
	tAlerts = {},
	tHealth = {},
	tUnits = {},
	tWatchedCasts = {},
	tWatchedAuras = {},
	tZones = {},
	combatTimer = nil,
	combatStarted = nil,
	combatLog = {},
	tSpellTriggers = {},
	tHealTriggers = {},
	tAuraCache = {},
	tPins = {},
	tPinAuras = {},
	tEncounterVariables = {},
	tDatachron = {},
	tLandmarks = {},
	tEncounters = {},
} 
 
-----------------------------------------------------------------------------------------------
-- ReStrat OnLoad
-----------------------------------------------------------------------------------------------
function ReStrat:OnLoad()
	Apollo.LoadSprites("respr.xml", "SassyMedicSimSprites")
	self.xmlDoc = XmlDoc.CreateFromFile("ReStrat.xml")

	self.wndMain       = Apollo.LoadForm(self.xmlDoc, "mainForm", nil, self)
	self.wndHealthBars = Apollo.LoadForm(self.xmlDoc, "healthForm", nil, self)
    self.wndAlerts     = Apollo.LoadForm(self.xmlDoc, "alertForm", nil, self)
	self.wndPop        = Apollo.LoadForm(self.xmlDoc, "popForm", nil, self)
	self.wndIcon       = Apollo.LoadForm(self.xmlDoc, "iconForm", nil, self)
	self.wndLog        = Apollo.LoadForm(self.xmlDoc, "logForm", nil, self)
	self.wndSettings   = Apollo.LoadForm(self.xmlDoc, "settingsForm", nil, self)
	self.wndversion    = Apollo.LoadForm(self.xmlDoc, "versionform", nil, self)
		
	self.wndversion:Show(false, true)
	self.wndMain:Show(false, true)
	self.wndIcon:Show(false, true)
	self.wndLog:Show(false, true)
	self.wndSettings:Show(false, true)
	
	-- Communications channel
	self.channel = ICCommLib.JoinChannel("ATHFReStrat", "OnICCommMessageReceived", self)
	
	-- Register handlers for events, slash commands and timer, etc.
	Apollo.RegisterSlashCommand("restrat", "OnReStrat", self)
	Apollo.RegisterEventHandler("WindowManagementReady", "OnWindowManagementReady", self)
	
	Apollo.RegisterEventHandler("UnitCreated",           "OnUnitCreated",       self)
	Apollo.RegisterEventHandler("UnitDestroyed",         "OnUnitDestroyed",     self)
	Apollo.RegisterEventHandler("UnitEnteredCombat",     "OnEnteredCombat",     self)
	Apollo.RegisterEventHandler("ChatMessage",           "OnChatMessage",       self)
	Apollo.RegisterEventHandler("PlayerResurrected",     "OnPlayerResurrected", self)
	--Apollo.RegisterEventHandler("Group_AcceptInvite",	 "OnGroupAcceptInvite", self)
	Apollo.RegisterEventHandler("Group_Join",            "OnGroup_Join",        self)
	Apollo.RegisterEventHandler("PublicEventObjectiveUpdate", "OnPublicEvent",  self)
	
	Apollo.RegisterEventHandler("CombatLogDamage" ,              "OnCombatLogDamage",               self)
	Apollo.RegisterEventHandler("CombatLogDeflect",              "OnCombatLogDeflect",              self)
	Apollo.RegisterEventHandler("CombatLogHeal",                 "OnCombatLogHeal",                 self)
	Apollo.RegisterEventHandler("CombatLogModifyInterruptArmor", "OnCombatLogModifyInterruptArmor", self)
	Apollo.RegisterEventHandler("CombatLogAbsorption",           "OnCombatLogAbsorption",           self)
	Apollo.RegisterEventHandler("CombatLogInterrupted",          "OnCombatLogInterrupted",          self)
	Apollo.RegisterEventHandler("SubZoneChanged",        		 "OnZone",        				    self)
	
	
	Apollo.RegisterEventHandler("_LCLF_UnitDied",             "OnUnitDied",         self)
	Apollo.RegisterEventHandler("_LCLF_SpellAuraApplied",     "OnAuraApplied",      self)
	Apollo.RegisterEventHandler("_LCLF_SpellAuraAppliedDose", "OnAuraStackAdded",   self)
	Apollo.RegisterEventHandler("_LCLF_SpellAuraRemoved",     "OnAuraRemoved",      self)
	Apollo.RegisterEventHandler("_LCLF_SpellAuraRemovedDose", "OnAuraStackRemoved", self)
	Apollo.RegisterEventHandler("_LCLF_SpellCastStart",       "OnCastStart",        self)
	
	--This timer drives alerts and combat time
	self.gameTimer = ApolloTimer.Create(0.1, true, "OnGameTick", self)
	self.gameTimer:Stop()
	
	--This timer drives health bar updates
	self.healthTimer = ApolloTimer.Create(0.5, true, "OnHealthTick", self)
	self.healthTimer:Stop()
	
	self.loadTimer = ApolloTimer.Create(3.5, false, "OnDelayLoad", self)
	self.loadTimer:Stop()
	
	--Drives pull itmers
	self.pullTimer = ApolloTimer.Create(1, true, "OnPullTimer", self);
	self.pullTimer:Stop();
	
end

-----------------------------------------------------------------------------------------------
-- ReStrat Functions
-----------------------------------------------------------------------------------------------
--Add windows to carbines window management
function ReStrat:OnWindowManagementReady()
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndHealthBars, strName = "reStratHealthBars"})
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndAlerts, strName = "reStratAlert"})
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndPop, strName = "reStratPop"})
end

function ReStrat:OnGameTick()
	self.combatTimer = GameLib.GetGameTime() - self.combatStarted
	
	--Process alerts backwards so we can remove alerts as we go
	for i=#self.tAlerts,1,-1 do
		local alertInstance = self.tAlerts[i]
		
		--Manage actual time degradation, this accounts for lag spikes etc.
		if alertInstance.lastTime then
			alertInstance.currDuration = alertInstance.currDuration-(GameLib.GetGameTime()-alertInstance.lastTime)
		end
		alertInstance.lastTime = GameLib.GetGameTime()
		
		--Update time, callback if expired
		if alertInstance.currDuration >= 0 then	
			local timer = alertInstance.bar:FindChild("ProgressBarContainer"):FindChild("timeLeft")
			timer:SetText(string.format("%.1fS", alertInstance.currDuration))
		else
			--Close bar
			alertInstance.bar:Destroy()
			
			local callback = alertInstance.callback	--Need to remove alert from table prior to executing callback
			table.remove(self.tAlerts, i)           --in case the callback destroys other alerts and fucks up table indices
			if callback then callback()	end
			
			--Reshuffle windows
			self:arrangeBars(self.tAlerts, "timer")	
		end
	end
end

-- Health tracking
-- Adapted from <Hindsight> code: https://github.com/Errc27/ReStrat/
function ReStrat:OnHealthTick() -- also events
	for id,tHealth in pairs(self.tHealth) do
		local wndBar = tHealth.bar:FindChild("ProgressBarContainer")
		local progressBar = wndBar:FindChild("progressBar")
		
		if tHealth.isevent == false or tHealth.isevent == nil then -- health
			local unit = tHealth.unit
			local cur = unit:GetHealth() or 0
			local max = unit:GetMaxHealth() or 0
		
			progressBar:SetMax(max)
			progressBar:SetProgress(cur)
			wndBar:FindChild("healthAmount"):SetText(string.format("%.1fk/%.1fk", cur/1000, max/1000))
			wndBar:FindChild("healthPercent"):SetText(string.format("%.1f%%", cur/max*100))
		else -- event
			local tEventObj = tHealth.tEventObj
			if tEventObj ~= nil then
				local cur = tEventObj:GetCount() or 0 
				local max = tEventObj:GetRequiredCount() or 0
				
				progressBar:SetMax(max)
				progressBar:SetProgress(cur)
				wndBar:FindChild("healthAmount"):SetText(" ")
				wndBar:FindChild("healthPercent"):SetText("0")
				wndBar:FindChild("healthPercent"):SetText(string.format("%.1f%%", cur/max*100))
				
				if cur == max then
					--Print("cur = max......cur: " .. cur)
					--Print("---------------max: " .. max)
					self:untrackEvent(tEventObj)
				end
					
			--	else			
			--		ReStrat:Start()
			--	end
			end
		end
	end
end

function ReStrat:OnZone()
	--Print("ongroupjoin")
	tTimer = ApolloTimer.Create(3, false, "NotifyMaster", self)
end

function ReStrat:NotifyMaster()
	--Print("joined")
	local rules = GroupLib.GetLootRules()
	--Print(rules)
	local parentId = GameLib.GetCurrentZoneMap().parentZoneId -- ds = 98
	local inraid = false
	if parentId == 98 or parentId == 147 then
		inraid = true
	end
	if rules.eThresholdRule ~= 3 and inraid == true then
		ChatSystemLib.Command("/p FYI: Masterloot is not on!")
	end	
end

function ReStrat:IsActivated(bossname, modulename)

	if ReStrat.tEncounters[bossname].tModules[modulename].bEnabled ~= nil then
		modulestate = ReStrat.tEncounters[bossname].tModules[modulename].bEnabled
	else
		return false
	end
	
	if modulestate == true then
		return true
	elseif modulestate == false then
		return false
	else
		return true
	end
end

function ReStrat:OnPublicEvent(tEventObj) --PublicEventObjectiveUpdate
	--tEvent = tEventObj:GetEvent()
	--eventObjDescription = tEventObj:GetDescription()
	--eventName = tEvent:GetName()
	eventId = tEventObj:GetObjectiveId()
	--Print("Desc: " .. eventObjDescription)
	--Print("Name: " .. eventName)
	--Print("EventId: " .. eventId)
	if eventId == 2007 then -- Debug Event From the Breach
		ReStrat:debugEvent(tEventObj)
	elseif eventId == 2006 then -- Debug 2006
		ReStrat:debugEvent2(tEventObj)
	elseif eventId == 1619 then -- mael weather cycle
		ReStrat:maelEvent(tEventObj)
	elseif eventId == 1465 then -- SD firewall
		ReStrat:sdEvent(tEventObj)
	elseif eventId == 1817 then -- lattice
		ReStrat:latticeEvent(tEventObj)
	elseif eventId == 2157 then -- north
		ReStrat:ohmnanorth(tEventObj)
	elseif eventId == 2158 then -- east
		ReStrat:ohmnaeast(tEventObj)
	elseif eventId == 2159 then -- south
		ReStrat:ohmnasouth(tEventObj)
	elseif eventId == 2160 then -- west
		ReStrat:ohmnawest(tEventObj)
	elseif eventId == 1570 then -- left esse
		ReStrat:leftess(tEventObj)
	elseif eventId == 1571 then -- right esse
		ReStrat:rightess(tEventObj)
	end	
	
end

function ReStrat:OnRestore(loadlevel, tload)

	if tload and loadlevel == GameLib.CodeEnumAddonSaveLevel.General then

		if tload["Version"].tfileversion < self.fileversion then -- older load file
			ReStrat.tEncounters["Version"] = nil
			
			ReStrat.tEncounters["Version"] = {
				tfileversion = self.fileversion,
				tcleanversion = self.version,
				strCategory  = self.version,
			}	
		end
		--lfsljk = tload["Version"].tfileversion
		
	
	ReStrat.tEncounters = tload
	
	if ReStrat.tEncounters["Holographic Chompacabra"].tModules["Test Config 1"] == nil then
		ReStrat.tEncounters["Holographic Chompacabra"].tModules["Test Config 1"] = {
			strLabel = "Chomp Test 1",
            bEnabled = true,
		}
	end
	if ReStrat.tEncounters["Maelstrom Authority"].tModules["Lines to Stations"] == nil then
		ReStrat.tEncounters["Maelstrom Authority"].tModules["Lines to Stations"] = {
			strLabel = "Lines to Stations",
			bEnabled = true,
		}
	end
	if ReStrat.tEncounters["Avatus"].tModules["Lines to Devourers"] == nil then
		ReStrat.tEncounters["Avatus"].tModules["Lines to Devourers"] = {
			strLabel = "Lines to Devourers",
			bEnabled = true,
		}
	end
	if ReStrat.tEncounters["Gloomclaw"].tModules["Spawn Landmarks"] == nil then
		ReStrat.tEncounters["Gloomclaw"].tModules["Spawn Landmarks"] = {
			strLabel = "Spawn Landmarks",
			bEnabled = true,
		}
	end
	if ReStrat.tEncounters["Gloomclaw"].tModules["Track Essence HP"] == nil then
		ReStrat.tEncounters["Gloomclaw"].tModules["Track Essence HP"] = {
			strLabel = "Track Essence HP",
			bEnabled = true,
		}
	end
	
	
		if tload["Version"].tfileversion < 183 then -- new feature in 183
			--fgh = true
			ReStrat.tEncounters["General Settings"] = nil
		end
		if tload["Version"].tfileversion < 184 then -- new feature in 163
			ReStrat.tEncounters["Binary System Daemon"] = nil
		end
		
		if tload["Version"].tfileversion < 170 then -- new feature in 170
			ReStrat.tEncounters["Dreadphage Ohmna"] = nil
		end
	
		if tload["Version"].tfileversion < 168 then -- new feature in 166
			ReStrat.tEncounters["Avatus"] = nil
		end
		
		if tload["Version"].tfileversion < 170 then -- new feature in 170
			ReStrat.tEncounters["Maelstrom Authority"] = nil
		end
		
		
		self.loadTimer:Start()
	end
end

function ReStrat:OnDelayLoad()
	--Print(lfsljk)
	--Print("delay")
	--eStrat:Sound("Sound\\spew.wav")
	--ReStrat:Sound("Sound\\spew.wav")
	--ReStrat:Sound("Sound\\quack.wav")
	--if fgh == true then
	--	Print("fsdf0")
	--end
		
	if ReStrat.tEncounters["Version"] == nil then
		ReStrat.tEncounters["Version"] = {
			tfileversion = self.fileversion,
			tcleanversion = self.version,
			strCategory  = self.version,
		}
	end
	if ReStrat.tEncounters["General Settings"] == nil then
		Print("succsess Gen")
		ReStrat.tEncounters["General Settings"] = {
			startFunction = asdfasdfasdfas,
			--fSpamFunction = profileDebugRepeat,
			strCategory  = "General Settings",
			tModules = {
                ["GenPopMessages"] = {
                        strLabel = "Pop Messages",
                        bEnabled = true,
                },				
                ["GenBossLife"] = {
                        strLabel = "Boss Life",
                        bEnabled = true,
                },
				["GenSounds"] = {
                        strLabel = "Play Sounds",
                        bEnabled = false,
                },
				["GenEvents"] = {
                        strLabel = "Track Events",
                        bEnabled = true,
                },
				["GenLandmark"] = {
                        strLabel = "Landmarks",
                        bEnabled = true,
                },
			},
		}
	end
	if ReStrat.tEncounters["Maelstrom Authority"] == nil then
	--Print("mael nil")
		ReStrat.tEncounters["Maelstrom Authority"] = {
			strCategory  = "Datascape",
			trackHealth = ReStrat.color.red,
			tModules = {
				["Typhoon"] = {
						strLabel = "Typhoon",
						bEnabled = true,
                },		
				["Lines to Stations"] = {
						strLabel = "Lines to Stations",
						bEnabled = true,
                },
                ["Crystallize"] = {
                        strLabel = "Crystallize",
                        bEnabled = true,
                },
				["Wind Wall"] = {
                        strLabel = "Wind Wall",
                        bEnabled = true,
                },
				["Ice Breath"] = {
                        strLabel = "Ice Breath",
                        bEnabled = true,
                },					
				["Activate Weather Cycle"] = {
                        strLabel = "Activate Weather Cycle",
                        bEnabled = true,
                },
				["Track Weather Cycle [Event]"] = {
                        strLabel = "Track Weather Cycle [Event]",
                        bEnabled = true,
                },
			},
		}
	end
	if ReStrat.tEncounters["Weather Station"] == nil then
		ReStrat.tEncounters["Weather Station"] = {
			strCategory  = "Not Important",
			trackHealth = ReStrat.color.blue,
			tModules = {},
		}
	end
	if ReStrat.tEncounters["Avatus"] == nil then
		ReStrat.tEncounters["Avatus"] = {
			startFunction = avatusInit,
			strCategory = "Datascape",
			trackHealth = ReStrat.color.red,
			tModules = {
				["Obliterate"] = {
					strLabel = "Obliterate (Lattice)",
					bEnabled = true,
				},
				["Track Exit Power [Event]"] = {
					strLabel = "Track Exit Power [Event]",
					bEnabled = true,
				},
				["Lines to Devourers"] = {
					strLabel = "Lines to Devourers",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Holo Hand"] == nil then
		ReStrat.tEncounters["Holo Hand"] = {
			strCategory  = "Not Important",
			trackHealth = ReStrat.color.blue,
			tModules = {},
		}
	end
	
	if ReStrat.tEncounters["Binary System Daemon"] == nil then
		ReStrat.tEncounters["Binary System Daemon"] = {
			strCategory  = "Datascape",
			trackHealth = ReStrat.color.green,
			tModules = {
				["Binary Power Surge"] = {
					strLabel = "Binary Power Surge",
					bEnabled = false,
				},
				["Binary Purge"] = {
					strLabel = "Binary Purge",
					bEnabled = false,
				},
				["Null Power Surge"] = {
					strLabel = "Null Power Surge",
					bEnabled = false,
				},
				["Null Purge"] = {
					strLabel = "Null Purge",
					bEnabled = false,
				},
				["Tank DC Notification"] = {
					strLabel = "Tank DC Notification",
					bEnabled = false,
				},
				["Track Firewall (Event)"] = {
					strLabel = "Track Firewall (Event)",
					bEnabled = true,
				},
				["North Pillar Landmarks"] = {
					strLabel = "North Pillar Landmarks",
					bEnabled = true,
				},
				["South Pillar Landmarks"] = {
					strLabel = "South Pillar Landmarks",
					bEnabled = true,
				},
			},
		}
	end
	
	if ReStrat.tEncounters["Null System Daemon"] == nil then
		ReStrat.tEncounters["Null System Daemon"] = {
			strCategory  = "Datascape",
			trackHealth = ReStrat.color.blue,
			tModules = {},
		}
	end
	
	if ReStrat.tEncounters["Defragmentation Unit"] == nil then
		ReStrat.tEncounters["Defragmentation Unit"] = {
			strCategory  = "Datascape",
			trackHealth = nil,
			tModules = {
				["Black IC"] = {
					strLabel = "Black IC",
					bEnabled = true,
				},
				["Defrag"] = {
					strLabel = "Defrag",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Gloomclaw"] == nil then
		ReStrat.tEncounters["Gloomclaw"] = {
			strCategory  = "Datascape",
			trackHealth = nil,
			tModules = {
				["Rupture"] = {
                        strLabel = "Rupture",
                        bEnabled = true,
                },				
                ["BossLife"] = {
                        strLabel = "Boss Life",
                        bEnabled = true,
                },
				["Spawn Landmarks"] = {
                        strLabel = "Spawn Landmarks",
                        bEnabled = true,
                },
				["Track Essence HP"] = {
                        strLabel = "Spawn Landmarks",
                        bEnabled = true,
                },
			},
		}
	end
	if ReStrat.tEncounters["Golgox the Lifecrusher"] == nil then
		ReStrat.tEncounters["Golgox the Lifecrusher"] = {
			strCategory  = "Genetic Archives",
			strSubCategory  = "Phageborn Convergence",
			trackHealth = nil,
			tModules = {
				["Scatter"] = {
					strLabel = "Scatter",
					bEnabled = false,
				},
				["Demolish"] = {
					strLabel = "Demolish",
					bEnabled = false,
				},
			},
		}
	end
	if ReStrat.tEncounters["Terax Blightweaver"] == nil then
		ReStrat.tEncounters["Terax Blightweaver"] = {
			strCategory  = "Genetic Archives",
			strSubCategory  = "Phageborn Convergence",
			trackHealth = nil,
			tModules = {
				["Stitching Strain"] = {
					strLabel = "Stitching Strain (Heal)",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Fleshmonger Vratorg"] == nil then
		ReStrat.tEncounters["Fleshmonger Vratorg"] = {
			strCategory  = "Genetic Archives",
			strSubCategory  = "Phageborn Convergence",
			trackHealth = nil,
			tModules = {},
		}
	end
	if ReStrat.tEncounters["Noxmind the Insidious"] == nil then
		ReStrat.tEncounters["Noxmind the Insidious"] = {
			strCategory  = "Genetic Archives",
			strSubCategory  = "Phageborn Convergence",
			trackHealth = nil,
			tModules = {
				["Essence Rot"] = {
					strLabel = "Essence Rot (Waves)",
					bEnabled = true,
				},
				["Equalize"] = {
					strLabel = "Equalize",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Ersoth Curseform"] == nil then
		ReStrat.tEncounters["Ersoth Curseform"] = {
			strCategory  = "Not Important",
			strSubCategory  = "Phageborn Convergence",
			trackHealth = nil,
			tModules = {},
		}
	end
	if ReStrat.tEncounters["Experiment X-89"] == nil then
		ReStrat.tEncounters["Experiment X-89"] = {
			strCategory  = "Genetic Archives",
			trackHealth = nil,
			tModules = {
				["Resounding Shout"] = {
					strLabel = "Resounding Shout",
					bEnabled = true,
				},
				["Repugnant Spew"] = {
					strLabel = "Repugnant Spew",
					bEnabled = true,
				},
				["Corruption Globule"] = {
					strLabel = "Small Bomb",
					bEnabled = true,
				},
				["Strain Bomb"] = {
					strLabel = "Big Bomb",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Kuralak the Defiler"] == nil then
		ReStrat.tEncounters["Kuralak the Defiler"] = {
			strCategory  = "Genetic Archives",
			trackHealth = nil,
			tModules = {
				["Chromosome Corruption"] = {
					strLabel = "Chromosome Corruption",
					bEnabled = true,
				},
				["Cultivate Corruption"] = {
					strLabel = "Cultivate Corruption",
					bEnabled = true,
				},
				["DNA Siphon"] = {
					strLabel = "DNA Siphon",
					bEnabled = true,
				},
				["Outbreak"] = {
					strLabel = "Outbreak",
					bEnabled = true,
				},
				["Vanish into Darkness"] = {
					strLabel = "Vanish into Darkness",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Dreadphage Ohmna"] == nil then
		ReStrat.tEncounters["Dreadphage Ohmna"] = {
			strCategory  = "Genetic Archives",
			trackHealth = nil,
			tModules = {
				["Devour"] = {
					strLabel = "Devour",
					bEnabled = true,
				},
				["Genetic Torrent"] = {
					strLabel = "Genetic Torrent (Spew)",
					bEnabled = true,
				},
				["Track Generators [Event]"] = {
					strLabel = "Track Generators [Event]",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Phage Maw"] == nil then
		ReStrat.tEncounters["Phage Maw"] = {
			strCategory  = "Genetic Archives",
			trackHealth = nil,
			tModules = {
				["Detonation Bombs"] = {
					strLabel = "Detonation Bombs",
					bEnabled = true,
				},
				["Crater"] = {
					strLabel = "Crater",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Detonation Bomb"] == nil then
		ReStrat.tEncounters["Detonation Bomb"] = {
			strCategory  = "Not Important",
			trackHealth = nil,
			tModules = {},
		}
	end
	
	if ReStrat.tEncounters["Data Devourer"] == nil then
		ReStrat.tEncounters["Data Devourer"] = {
			strCategory  = "Not Important",
			trackHealth = nil,
			tModules = {},
		}
	end
	
	if ReStrat.tEncounters["Phagetech Commander"] == nil then
		ReStrat.tEncounters["Phagetech Commander"] = {
			strCategory  = "Genetic Archives",
			trackHealth = nil,
			tModules = {
				["Forced Production"] = {
					strLabel = "Forced Production",
					bEnabled = true,
				},
				["Destruction Protocol"] = {
					strLabel = "Destruction Protocol",
					bEnabled = false,
				},
			},
		}
	end
	if ReStrat.tEncounters["Phagetech Augmentor"] == nil then
		ReStrat.tEncounters["Phagetech Augmentor"] = {
			strCategory  = "Genetic Archives",
			trackHealth = nil,
			tModules = {
				["Summon Repairbot"] = {
					strLabel = "Summon Repairbot",
					bEnabled = true,
				},
				["Phagetech Borer"] = {
					strLabel = "Phagetech Borer",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Phagetech Protector"] == nil then
		ReStrat.tEncounters["Phagetech Protector"] = {
			strCategory  = "Genetic Archives",
			trackHealth = nil,
			tModules = {
				["Pulse-A-Tron Wave"] = {
					strLabel = "Pulse-A-Tron Wave",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Phagetech Fabricator"] == nil then
		ReStrat.tEncounters["Phagetech Fabricator"] = {
			strCategory  = "Genetic Archives",
			trackHealth = nil,
			tModules = {
				["Summon Destructobot"] = {
					strLabel = "Summon Destructobot",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Aethros"] == nil then
		ReStrat.tEncounters["Aethros"] = {
			strCategory  = "Stormtalon's Lair",
			trackHealth = nil,
			tModules = {
				["Torrent"] = {
					strLabel = "Torrent",
					bEnabled = true,
				},
				["Tempest"] = {
					strLabel = "Tempest",
					bEnabled = true,
				},
				["Thunderbolt"] = {
					strLabel = "Thunderbolt",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Blade-Wind the Invoker"] == nil then
		ReStrat.tEncounters["Blade-Wind the Invoker"] = {
			strCategory  = "Stormtalon's Lair",
			trackHealth = nil,
			tModules = {
				["Thunder Cross"] = {
					strLabel = "Thunder Cross",
					bEnabled = true,
				},
				["Lightning Strike"] = {
					strLabel = "Lightning Strike",
					bEnabled = true,
				},
				["Electrostatic Pulse"] = {
					strLabel = "Electrostatic Pulse",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Stormtalon"] == nil then
		ReStrat.tEncounters["Stormtalon"] = {
			strCategory  = "Stormtalon's Lair",
			trackHealth = nil,
			tModules = {
				["Lightning Strike"] = {
					strLabel = "Lightning Strike",
					bEnabled = true,
				},
				["Lightning Storm"] = {
					strLabel = "Lightning Storm",
					bEnabled = true,
				},
				["Thunder Call"] = {
					strLabel = "Thunder Call",
					bEnabled = true,
				},
				["Lightning Rod"] = {
					strLabel = "Lightning Rod",
					bEnabled = true,
				},
				["Static Wave"] = {
					strLabel = "Static Wave",
					bEnabled = true,
				},
			},
		}
	end
	
	if ReStrat.tEncounters["Holographic Moodie"] == nil then
		ReStrat.tEncounters["Holographic Moodie"] = {
			startFunction = profileDebug,
			fSpamFunction = profileDebugRepeat,
			strCategory  = "Large Training Grounds",
			trackHealth = ReStrat.color.green,
			tModules = {
				["Firestorm"] = {
					strLabel = "Firestorm",
					bEnabled = true,
				},
				["Fissure"] = {
					strLabel = "Fissure",
					bEnabled = true,
				},
				["Erupting Fissure"] = {
					strLabel = "Erupting Fissue",
					bEnabled = true,
				},
			},
		}
	end
	
	if ReStrat.tEncounters["Holographic Shootbot"] == nil then
		ReStrat.tEncounters["Holographic Shootbot"] = {
			startFunction = profileDebug,
			fSpamFunction = profileDebugRepeat,
			trackHealth = "green",
			strCategory  = "Large Training Grounds",
			tModules = {
				["Jump Shot"] = {
					strLabel = "Jump Shot",
					bEnabled = true,
				},
				["Slasher Dash"] = {
					strLabel = "Slasher Dash",
					bEnabled = true,
				},
			},
		}
	end
	
	if ReStrat.tEncounters["Holographic Chompacabra"] == nil then
		ReStrat.tEncounters["Holographic Chompacabra"] = {
			startFunction = profileDebug,
			fSpamFunction = profileDebugRepeat,
			strCategory  = "Large Training Grounds",
			trackHealth = ReStrat.color.green,
			tModules = {
				["Snap Trap"] = {
					strLabel = "Snap Trap",
					bEnabled = true,
				},
				["Feeding Frenzy"] = {
					strLabel = "Feeding Frenzy",
					bEnabled = true,
				},
			},
		}
	end
	if ReStrat.tEncounters["Fully-Optimized Canimid"] == nil then
		ReStrat.tEncounters["Fully-Optimized Canimid"] = {
			strCategory  = "Datascape",
			tModules = {
				["Show People with Debuff"] = {
					strLabel = "Show People with Debuff",
					bEnabled = true,
				},
			},
		}
	end
	
end

function ReStrat:OnSave(savelevel)
	if savelevel == GameLib.CodeEnumAddonSaveLevel.General and ReStrat.tEncounters ~= nil then --
	
		ReStrat.tEncounters["Version"] = {
			tfileversion = self.fileversion,
			tcleanversion = self.version,
			strCategory  = self.version,
		}
		
		return ReStrat.tEncounters
	end
end
 
function ReStrat:OnUnitCreated(unit)
	local id = unit:GetId()
	if self.tUnits[id] then 
		self.tUnits[id].unit = newUnit
	end
	if self.tUnits[unit:GetName()] then
		local tUnit = self.tUnits[unit:GetName()]
		if tUnit.fInitFunction then
			tUnit.fInitFunction(unit)
		end
	end
end

function ReStrat:OnUnitDestroyed(unit)
	local id = unit:GetId()
	if self.tUnits[id] then
		if self.tUnits[id].fOnDeathCallback then
			self.tUnits[id].fOnDeathCallback()
		end
		self.tUnits[id].bActive = false
		self.tUnits[id].unit = nil
		ReStrat:untrackHealth(unit)
		ReStrat:destroyPin(unit)
	end
end

function ReStrat:OnEnteredCombat(unit, combat)
	if unit:IsInYourGroup() or unit:IsThePlayer() then
		if combat then
			--Clear combat log
			self.combatLog = {}
			self:Start()
		elseif not self:IsGroupInCombat() then
			self:Stop()
		end
	else
		--If combat starts, init unit profile
		if combat then
			local tProfile = ReStrat.tEncounters[unit:GetName()] 
			if tProfile then 
			
				uName = unit:GetName()
					--debug
				if uName == "Holographic Chompacabra" then
					ReStrat:profileDebug(unit)
				elseif uName == "Holographic Shootbot" then
					ReStrat:profileDebug(unit)
				elseif uName == "Holographic Moodie" then
					ReStrat:profileDebug(unit)
					
					--avatus
				elseif uName == "Avatus" then
					if GameLib.GetCurrentZoneMap().id == 116 then -- lattice
						tProfile.trackHealth = nil
						ReStrat:latticeInit()
					else
						ReStrat:avatusInit(unit)
					end
				elseif uName == "Holo Hand" then
					ReStrat:avatusInit(unit)
				elseif uName == "Data Devourer" then
					ReStrat:devourerInit(unit)
					
					--daemons
				elseif uName == "Binary System Daemon" then
					ReStrat:daemonInit(unit)
				elseif uName == "Null System Daemon" then
					ReStrat:daemonInit(unit)
				elseif uName == "Defragmentation Unit" then
					ReStrat:defragInit(unit)
					
					--gloom
				elseif uName == "Gloomclaw" then
					ReStrat:gloomInit(unit)
					
					--maelstrom
				elseif uName == "Weather Station" then
					ReStrat:stationInit(unit)
				elseif uName == "Maelstrom Authority" then
					ReStrat:maelInit(unit)
					
					--convergence
				elseif uName == "Golgox the Lifecrusher" then
					ReStrat:golgoxInit(unit)
				elseif uName == "Terax Blightweaver" then
					ReStrat:teraxInit(unit)
				elseif uName == "Fleshmonger Vratorg" then
					ReStrat:vratorgInit(unit)
				elseif uName == "Noxmind the Insidious" then
					ReStrat:noxmindInit(unit)
				elseif uName == "Ersoth Curseform" then
					ReStrat:ersothInit(unit)
					
					--experiment
				elseif uName == "Experiment X-89" then
					ReStrat:experimentInit(unit)
					
					--kuralak
				elseif uName == "Kuralak the Defiler" then
					ReStrat:kuralakInit(unit)
					
					--ohmna
				elseif uName == "Dreadphage Ohmna" then
					ReStrat:ohmnaInit(unit)
					
					--phagemaw
				elseif uName == "Phage Maw" then
					ReStrat:phagemawInit(unit)
				elseif uName == "Detonation Bomb" then
					ReStrat:bombinit(unit)
					
					--prototypes
				elseif uName == "Phagetech Commander" then
					ReStrat:commanderInit(unit)
				elseif uName == "Phagetech Augmentor" then
					ReStrat:augmentorInit(unit)
				elseif uName == "Phagetech Protector" then
					ReStrat:protectorInit(unit)
				elseif uName == "Phagetech Fabricator" then
					ReStrat:fabricatorInit(unit)
					
					--stormtalons lair
				elseif uName == "Aethros" then
					ReStrat:aeInit(unit)
				elseif uName == "Blade-Wind the Invoker" then
					ReStrat:bladeInit(unit)
				elseif uName == "Stormtalon" then
					ReStrat:stormInit(unit)
					
				    -- Minis
				elseif uName == "Fully-Optimized Canimid" then
					ReStrat:canimidInit(unit)
	
					--elementals
				elseif uName == "Megalith" then
					ReStrat:earthInit(unit)
				elseif uName == "Aileron" then
					ReStrat:airInit(unit)
				elseif uName == "Mnemesis" then
					ReStrat:logicInit(unit)
				elseif uName == "Pyrobane" then
					ReStrat:fireInit(unit)
				elseif uName == "Visceralus" then
					ReStrat:lifeInit(unit)
				elseif uName == "Hydroflux" then
					ReStrat:waterInit(unit)
				--elseif uName == "Logic Guided Rockslide" then
					--Print("sdf")
					--ReStrat:wingInit(unit)	
				end
				
				
				--tProfile.startFunction(unit) 
				if tProfile.trackHealth then -- System Daemon Special Case
					if uName == "Binary System Daemon" then
						self:trackHealth(unit, tProfile.trackHealth, "[N] Binary System Daemon")
					elseif uName == "Null System Daemon" then
						self:trackHealth(unit, tProfile.trackHealth, "[S] Null System Daemon")
					else
						self:trackHealth(unit, tProfile.trackHealth)
					end
				end
			end
			
			--Add unit in our library if it's not there already
			local id = unit:GetId()
			if not self.tUnits[id] then
				self.tUnits[id] = {
					unit = unit,
					name = unit:GetName(),
					health = unit:GetMaxHealth(),
					shield = unit:GetShieldCapacityMax(),
					absorb = unit:GetAbsorptionMax(),
					baseIA = unit:GetInterruptArmorMax(),
					assault = unit:GetAssaultPower(),
					bActive = true
				}
			end
		end
	end
end

function ReStrat:Start()
	self.combatStarted = GameLib.GetGameTime()
	self.gameTimer:Start()
	self.healthTimer:Start()
end

function ReStrat:Stop()
	self.wndHealthBars:DestroyChildren()
	self.wndAlerts:DestroyChildren()
	for k,v in pairs(self.tPins) do	v:Destroy()	end
	
	self.tAlerts = {}
	self.tHealth = {}
	self.tWatchedAuras = {}
	self.tWatchedCasts = {}
	self.tEncounterVariables = {}
	self.tSpellTriggers = {}
	self.tHealTriggers = {}
	self.tDatachron = {}
	self.tPinAuras = {}
	self.tPins = {}
	ReStrat:destroyAllLandmarks()
	
	self.healthTimer:Stop()
	self.gameTimer:Stop()
end

function ReStrat:IsGroupInCombat()
	for i=1,GroupLib.GetMemberCount() do
		unit = GroupLib.GetUnitForGroupMember(i)
		if unit and unit:IsInCombat() then
			return true
		end
	end
	return false
end

function ReStrat:OnPlayerResurrected()
	ReStrat:Stop()
end

function ReStrat:spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end



--[TODO] make this a lot more customizable
function ReStrat:arrangeBars(tBars, strType)
	local vOffset = 0
	if strType == "health" then
		for _,tBar in pairs(tBars) do
			local wndHeight = tBar.bar:GetHeight()		
			tBar.bar:SetAnchorOffsets(0,vOffset,0,vOffset+wndHeight)
			vOffset = vOffset + (wndHeight + self.barSpacing)
		end
	else -- "timer"
		for _,tBar in self:spairs(tBars, function(t,a,b) return t[b].currDuration < t[a].currDuration end) do
			local wndHeight = tBar.bar:GetHeight()		
			tBar.bar:SetAnchorOffsets(0,vOffset,0,vOffset+wndHeight)
			vOffset = vOffset + (wndHeight + self.barSpacing)
		end
	end
end

--Create our fake timers on request
function ReStrat:onCreateTestAlerts(wndHandler, wndControl)
	wndControl:Enable(false)
	self:Start()
	self:trackHealth(GameLib.GetPlayerUnit())
	self:createAlert("Knockback", 5, "Icon_SkillSbuff_higherjumpbuff", self.color.blue, function() self:createPop("Knockback!", nil) end)
	self:createAlert("Flame Walk", 10, "Icon_SkillMisc_Soldier_March", self.color.red, nil)
	self:createAlert("Energon Cubes", 15.5, "Icon_SkillMedic_repairstation", self.color.purple, function() ReStrat:Stop(); wndControl:Enable(true) end)
end

--Parse chat messages for datachron triggers
function ReStrat:OnChatMessage(channel, tMessage)
	if not tMessage then return end --Shouldn't happen but hey this game
	local strText = tMessage.arMessageSegments[1].strText
	
	
	if channel:GetName() == "Datachron" then --and self.tDatachron[strText]
		for k,v in pairs(self.tDatachron) do
			if string.find(strText, self.tDatachron[k].strText) then
				self.tDatachron[k].fCallback()
				--Print(self.tDatachron[k].strText)
			end	
		end
	end
	
	if channel:GetName() == "NPC Say" then 
		for k,v in pairs(self.tDatachron) do
			if string.find(strText, self.tDatachron[k].strText) then
				self.tDatachron[k].fCallback()
				--Print(self.tDatachron[k].strText)
			end	
		end
	end
	
	
	--Create pull timer
	if string.match(string.lower(strText), "pull in") then
		for i = 1, GroupLib.GetMemberCount() do
			if GroupLib.GetGroupMember(i).strCharacterName == tMessage.strSender then
				if GroupLib.GetGroupMember(i).bIsLeader or GroupLib.GetGroupMember(i).bRaidAssistant or GroupLib.GetGroupMember(i).bMainAssist then
					--Start alert timer
					self:Start();
					
					self:createAlert("Pull!", tonumber(string.match(strText, "%d+")), "Icon_SkillMisc_Explorer_safefail", self.color.green, self.stop)

					return
				end
			end
		end
	end

	
end

--/restrat
function ReStrat:OnReStrat(strCmd, strParam)
	versionall = false
	if strParam == "version" then
		--self.tVersions = {}
		self.tMembers = {}
		for i=1, GroupLib.GetMemberCount() do
			groupmember = GroupLib.GetGroupMember(i)
			if groupmember.strCharacterName ~= GameLib.GetPlayerUnit():GetName() then
				self.tMembers[groupmember.strCharacterName] = "N/A"
			end
		end
		self.channel:SendMessage({ping = true})
		self.tmrVersionCheck = ApolloTimer.Create(5, false, "OnVersionCheckTimer", self)
		versionall = false
		
	elseif strParam == "versionall" then
		--self.tVersions = {}
		self.tMembers = {}
		for i=1, GroupLib.GetMemberCount() do
			groupmember = GroupLib.GetGroupMember(i)
			if groupmember.strCharacterName ~= GameLib.GetPlayerUnit():GetName() then
				self.tMembers[groupmember.strCharacterName] = "N/A"
			end
		end
		self.channel:SendMessage({ping = true})
		self.tmrVersionCheck = ApolloTimer.Create(5, false, "OnVersionCheckTimer", self)
		versionall = true
		
	elseif strParam == "vrf" then
		self.tMembers = {}
		for i=1, GroupLib.GetMemberCount() do
			groupmember = GroupLib.GetGroupMember(i)
			if groupmember.strCharacterName ~= GameLib.GetPlayerUnit():GetName() then
				self.tMembers[groupmember.strCharacterName] = "N/A"
			end
		end
		self.channel:SendMessage({pong = true})
		self.tmrVersionCheck = ApolloTimer.Create(5, false, "OnVersionCheckTimer", self)
		
	elseif strParam == "fs" then
		self.tMembers = {}
		for i=1, GroupLib.GetMemberCount() do
			groupmember = GroupLib.GetGroupMember(i)
			if groupmember.strCharacterName ~= GameLib.GetPlayerUnit():GetName() then
				self.tMembers[groupmember.strCharacterName] = "N/A"
			end
		end
		self.channel:SendMessage({pang = true})
		self.tmrVersionCheck = ApolloTimer.Create(5, false, "OnVersionCheckTimer", self)
		
		
	elseif strParam == "stop" then
		self:Stop()
		
	elseif strParam == "debug" then
		self:Start()
		self:debugfunction()
		
	elseif strParam == "pull" then
		for i = 1, GroupLib.GetMemberCount() do
			if GroupLib.GetGroupMember(i).strCharacterName == GameLib.GetPlayerUnit():GetName() then
				if GroupLib.GetGroupMember(i).bIsLeader or GroupLib.GetGroupMember(i).bRaidAssistant or GroupLib.GetGroupMember(i).bMainAssist then
					--Pull timer
					ChatSystemLib.Command('/p Pull in 5')
					self.pulltime = 5;
					self.pullTimer:Start();
					return
				end
			end
		end
		
		
		
	else
		self.wndMain:Invoke()
		self:InitUI()
	end
end

--debug function
function ReStrat:debugfunction()
	ReStrat:destroyAllLandmarks()
			ReStrat:createLandmark("Frog1", {4288, -568, -17040 })
			ReStrat:createLandmark("Frog2", {4332, -568, -17040 })
			ReStrat:createLandmark("Frog3", {4332, -568, -16949 })
			ReStrat:createLandmark("Frog4", {4288, -568, -16949 })
		
end

--Pull timer
function ReStrat:OnPullTimer()
	if self.pulltime > 1 then
		self.pulltime = self.pulltime-1;
		ChatSystemLib.Command('/p ' .. self.pulltime)
	else
		self.pullTimer:Stop();
		ChatSystemLib.Command("/p Pull!")
	end
end

function ReStrat:OnICCommMessageReceived(channel, tMsg, sender)

	if tMsg.ping == true then
		punit = GameLib.GetPlayerUnit()
		local tt = {}
		tt.playername = punit:GetName()
		tt.reversion = self.version
		tt.answer = true
		self.channel:SendMessage(tt)
		
	elseif tMsg.pang == true then
		punit = GameLib.GetPlayerUnit()
		local tt = {}
		tt.playername = punit:GetName()
		tt.reversion = Foresight.version
		tt.answer = true
		self.channel:SendMessage(tt)
		
	elseif tMsg.pong == true then
		tVRF = Apollo.GetAddonInfo("VinceRaidFrames")
		punit = GameLib.GetPlayerUnit()
		local tt = {}
		tt.playername = punit:GetName()
		
		if tVRF ~= nil then
		
			if tVRF.bRunning == 1 then
				tt.reversion = "Running"
			else
				tt.reversion = "Installed"
			end
			
			
		else
			tt.reversion = "None"
		end
		
		tt.answer = true
		self.channel:SendMessage(tt)
	elseif tMsg.answer == true then
		if self.tMembers ~= nil then
			if versionall == false then
				if self.tMembers[tMsg.playername] ~= nil then -- sender is in raid
					self.tMembers[tMsg.playername] = tMsg.reversion
				end
			else
				self.tMembers[tMsg.playername] = tMsg.reversion
			end	
		end
	end
end

function ReStrat:OnVersionCheckTimer()
	self.wndversion:Invoke()
	versiontable = self.wndversion:FindChild("versiongrid")
	versiontable:DeleteAll()
	
	Print(self.name .. " version: " .. self.version)
	for key,value in pairs(self.tMembers) do Print(key.." "..value) end
	
	
	local x = 0
	for key,value in pairs(self.tMembers) do
		x = x+1
		versiontable:AddRow("asdfsadf")
		versiontable:SetCellText(x,1,key)
		versiontable:SetCellText(x,2,value)
	end
	
	
end

function ReStrat:setContains(set, key)
    return set[key] ~= nil
end



Apollo.RegisterAddon(ReStrat, false, "", {"DrawLib"})
