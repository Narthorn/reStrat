#Todo

Everything in **bold** has been finished, otherwise is still being worked on. 

##Interface
- Mockup
- Assets
    - Graphics
            - [**Alerts & Pops**](http://i.imgur.com/vkqwZBi.jpg)
    - Audio
- Importing to Game

##Code
###Profile Development Functionality
####Unit Casts
These functions will all handle casts, currently we have no event on iniation of a cast so these are intensive. Only operable on target, player, focus, or encounter units.

#####createCastAlert("strUnit", "strCast", [duration], ["strIcon"], [fCallback]);
Automatically creates an alert on cast for the indicated unit. If a callback is indicated it will be executed when the alert ends.  
#####isCasting("strUnit", "strCast")
Return whether or not the indicated cast is active on the indicated unit.

####Buffs or Debuffs
These functions handle auras on the player, their target, their focus, or an encounter unit.

#####createAuraAlert("strUnit", "strAuraName", [duration], [icon], [fCallback])
Automatically creates an alert when the indicated aura is applied to the specified unit. If a callback is indicated it will be executed when the alert ends.

####Alert notifications
These functions handle generic alert creation. Alerts can traditionally be thought of as timers.

#####**createAlert("strAlertLabel", duration, ["strIcon"], [fCallback])**
Creates an alert with the indicated label, duration, and icon. If a callback is indicated it will be executed when the alert ends.
#####broadcastAlert("strAlert")
Broadcasts the alert in the party channel.
#####syncAlert("strAlertLabel", duration, ["strIcon"], [fCallback])
Syncs an alert to everyone in your party using ReStrat, this is helpful for players "out of range."

####Pop notifications
These functions handle "pops", these are brief text notifications accompanied by a sound.

#####**createPop("strPop", [fCallback])**
Creates a pop with the indicated string. If a callback is indicated it will be executed when the alert ends.
#####createCastPop("strPop", "strUnit", "strCast", [fCallback])
Creates a  pop when the specified cast starts from the specified unit. If a callback is indicated it will be executed when the alert ends.
#####createAuraPop("strPop", "strUnit", "strAura", [fCallback])
Creates a pop when the specified unit gains the specified aura. If a callback is indicated it will be executed when the alert ends.

####Unit State Hooks
These functions are generic logic builders used to construct the required functionality to model an encounter. Each hook is added to a library for the encounter, checked at an interval.

#####createHealthHook("strUnit", iPercent, fCallback)
Creates a hook to execute the specified function when the desired unit hits the given health percentage.

#####createDeathHook("strUnit", fCallback)
Creates a hook to execute the specified function when the desired unit dies.

#####createSpawnHook("strUnit", fCallback)
Creates a hook to execute the specified function when the desired unit is created or spawned.



##Inspection Tools
The inspection tools are a set of optional features which are intended to allow filtering, searching, and inspection of fight abilities, mechanics, and so on. These will be resource intensive during the fight, but will log in detail every aspect of the fight. Certain tools will be completely optional, for example if a fight has no important buffs or debuffs there is absolutely no reason to scan them.

###Combat Log
This includes events such as dispels, resource gains, and with optional logging for debuffs and casts which would be resource intensive. It's possible that this could be made fairly efficient by scanning at a set interval and calculating application times from how far the aura is into the total duration. Casts can also have this functionality if we get the max IA instead of the current IA at the time of scanning. 

###Detailed Unit List
A list of all units encountered during the last combat event, any casts will be linked to these units. The unit pane will include information about their health, shield, and other relevant properties. 

###Spell/Aura Inspection
Once combat has concluded every spell and aura cast will be checked for tooltip text, and other useful information. Casts and auras will be linked to their respective units in the unit list.

###Icon List
A simple list of every icon with their path for reference.
