#ReStrat
##Reglitch [Codex - Hazak]

###What is ReStrat?

ReStrat is a boss mod for Wildstar, currently in early development. The goal of ReStrat is to have a framework which allows rapid development of strategical aids, such as timers, ability alerts, and so on for progress raiding. 

###Goals

ReStrat is an addon which will see primary use in a progress intensive environment, where information on encounters is sparse. As such the main goals of the addon are as follows:

- Provide the ability to create a boss 'profile' with as little interaction with the base game API as possible.
- Provide tools which allow in detail analysis of encounters.
    - This includes the ability to analyze encounter units,  the actions belonging to them, and the auras gained by all      units.
- Minimal aesthetic which makes efficient use of screen space.

### Chill Edit

Ok so what I changed:

- save and load profiles
- slim interface
- better versioncheck (/restrat version and /restrat versionall will show all people that are using ReStrat and their version.)
- many triggers return units now
- event tracking (small bars in quest tracker e.g. Exit Power on Lattice or Logic Essence HP on Gloomclaw)
- many boss profiles updated
- alertbars are sorted by their expiration time

All this sounds good? Well here's the downside:
I am not a programmer. I have no idea what I'm doing. If there's an error all I can do is copy some stuff around until it works.
The entire code is very sloppy. Most People will not understand at all what's going on. All I know is that it works for now.

### DrawLib

You need a modified version of DrawLib for this to work

