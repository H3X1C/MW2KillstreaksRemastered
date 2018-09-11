# Installation #
Place all files inside \userraw\maps\mp\killstreaks

# Server config #
Non of these are required and are optional. If you do not include them they will just use their default value.

NUKE
 scr_nukeTimer 				- Nuke timer in seconds (default=10)

 scr_nuke_is_moab = 0			- Nuke acts normally (ending game after detonation)
 scr_nuke_is_moab = 1			- Nuke acts like MW3 MOAB (Game does not end after detonation)

 scr_nukeAftermathDuration		- Aftermath vision duration(s) (0=PermanentVision, 0=Default)

 scr_nukeActiveVehicles = 0		- Doesn't destory vehicles (Air support) on nuke detonation [not an EMP]
 scr_nukeActiveVehicles = 1		- Destroys all vehicles (Air support) on nuke detonation [not an EMP]

 scr_nukeEMPDuration			- Calls in a global EMP to all players on nuke detonation (default=0=Off)

 scr_nukeCancelMode = 0 		- Disables this feature, nukes will behave as normal
 scr_nukeCancelMode = 1 		- If nuke caller is killed nuke cancelled (Cut content)
 scr_nukeCancelMode = 2 		- If nuke caller is killed nuke cancelled and emp detonated (Cut content)

 scr_nukeKillsAll = 0			- Disables this feature, nuke only kills other team
 scr_nukeKillsAll = 1			- Kills every player in the game

EMP
 scr_emp_duration 			- EMP duration in seconds (default=60)

AC130
 scr_ac130_duration 			- AC130 duration in seconds (default=20)
 scr_ac130_flares			- Number of flares (default=2)


# Example server config #

set scr_nukeTimer 15
set scr_nuke_is_moab 1
set scr_nukeAftermathDuration 0
set scr_nukeCancelMode 2
set scr_nukeActiveVehicles 0
set scr_nukeEMPDuration 60
set scr_nukeKillsAll 1
set scr_emp_duration 45
set scr_ac130_duration 25
set scr_ac130_flares 1



