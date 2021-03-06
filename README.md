# KILLSTREAK REMASTERED v1.6
Developed by H3X1C with special thanks to Emosewaj, Killera, xBlizzDevious

# Introduction
The aim of this project was to add some much needed polish to the existing killstreaks in the game by removing unnecessary code, restoring cut content features, reintroducing server configuration options and introducing some new features.
Some popular features include: Nuke MOAB, Killstreak duration configurability, Killstreak rollover and more. 
See the Server Configuration section below for a full break down of the customisable options.

# ChangeLog
v1.6
* Fixed bug in which nuke escort wouldn't get removed (Nuke cancelled during fly by) 
  * Function re-written to complete fly pass without dropping the bomb
* Migrated documentation to Github

v1.5
* Added _helicopters.gsc to the pack

* Buffed attack helicopters to be in line with harriers
  * Health increased
  * Fire rate increased
  * Accuracy increased
  * In some circumstances will fire a missile at a target to finish them off

* Server configuration support added to helicopters
  * Set custom durations on all 3 helicopter types
  * Toggle missile support for attack helicopters

* Removed redundant code from helicopters script

* Cleaned up left over debug code accidently introduced in v1.4

* Fixed some typo's in _killstreaks.gsc

# Installation
Place the iwd inside \userraw
Example: Call of Duty Modern Warfare 2\userraw\z_H3X1Cs-Killstreaks-Remastered-v1.6.iwd

# Server Configuration
Non of these are required and are optional. If you do not include them they will just use their default value. More details for each killstreak can be found in the comments of their given gsc file.

GLOBAL
```
scr_killstreak_mod 0                      - Modifier to the amount of kills required for a given killstreak, (scr_killstreak_mod 5 = Nuke 30 kills) (Default=0 -> Disabled)

scr_killstreak_rollover 0                 - Allows players to restart their streak once completed in a single life (Default=0 -> Disabled)
scr_killstreak_rollover 1
```

NUKE
```
scr_nukeTimer 10                          - Nuke timer in seconds (Default=10)

scr_nuke_is_moab 0                        - Nuke acts normally (ending game after detonation) (Default=0 -> Disabled)
scr_nuke_is_moab 1                        - Nuke acts like MW3 MOAB (Game does not end after detonation)

scr_nuke_aftermath_duration 0             - Aftermath vision duration(s) (Default=0 -> PermanentVision)

scr_nuke_active_vehicles 0                - Doesn't destory vehicles (Air support) on nuke detonation [not an EMP] (Default=0 -> Disabled)
scr_nuke_active_vehicles 1                - Destroys all vehicles (Air support) on nuke detonation [not an EMP]

scr_nuke_emp_duration 0                   - EMP triggered on nuke detonation, specify emp duration in seconds  (Default=0 -> Disabled)

scr_nukeCancelMode 0                      - Disables this feature, nukes will behave as normal (Default=0 -> Disabled)
scr_nukeCancelMode 1                      - If nuke caller is killed nuke cancelled (Cut content)
scr_nukeCancelMode 2                      - If nuke caller is killed nuke cancelled and emp detonated (Cut content)

scr_nuke_earthquake_magnitude 0           - Disbled earthquake
scr_nuke_earthquake_magnitude 0.6         - Standard earthquake magnitude (Default=0.6)

scr_nuke_earthquake_duration 0            - Disabled earthquake 
scr_nuke_earthquake_duration 10	          - Standard earthquake duration (Default=10)

scr_nuke_kills_all 0                      - Disables this feature, nuke only kills other team (Default=0 -> Disabled)
scr_nuke_Kills_all 1                      - Kills every player in the game

scr_nuke_clasic_mode 0                    - Disables this features 
scr_nuke_clasic_mode 1                    - Two harriers escort two stealth bombers, who do a fly by dropping the nuke
```


EMP
```
scr_emp_duration 60                       - EMP duration in seconds (Default=60)
```

AC130
```
scr_ac130_duration 40                     - AC130 duration in seconds (Default=40)
scr_ac130_flares 2                        - Number of flares (Default=2)
```

Predator Missile
```
scr_predator_earthquake_magnitude 0       - Disbled earthquake
scr_predator_earthquake_magnitude 0.6     - Standard earthquake magnitude (Default=0.6)

scr_predator_earthquake_radius 0          - Disbled earthquake
scr_predator_quake_radius 5000            - Standard earthquake radius (Default=5000)

scr_predator_earthquake_duration 0        - Disabled earthquake
scr_predator_earthquake_duration 2        - Standard earthquake duration (Default=2)
```

UAV
```
scr_uav_timeout 30                        - UAV timer in seconds (Default=30)

scr_counter_uav_timeout 30                - Counter UAV in seconds (Default=30)

scr_uav_forceon 0                         - Disables forced UAV (Default=0 -> Disabled)

scr_uav_forceon 1                         - Force permanent radar on 
```

ATTACK HELICOPTER
```
scr_helicopter_cobra_duration 60         - Chopper Gunner duration in seconds (Default=60)

scr_helicopter_cobra_missile 0           - Disable missile support 
scr_helicopter_cobra_missile 1           - Attack helicopters will now shoot missiles at targets (Default=1 -> Enabled)
```

PAVELOW
```
scr_helicopter_pavelow_duration 60       - Pavelow duration in seconds (Default=60)
```

CHOPPER GUNNER
```
scr_helicopter_apache_duration 40        - Chopper Gunner duration in seconds (Default=40)
```

# Example server config
Below is an example of a config setup.
```
set scr_killstreak_rollover 1
set scr_nukeTimer 10
set scr_nukeCancelMode 2
set scr_nuke_is_moab 1
set scr_nuke_aftermath_duration 0
set scr_nuke_active_vehicles 1
set scr_nuke_emp_duration 60
set scr_nuke_kills_all 1
set scr_emp_duration 45
set scr_ac130_duration 25
set scr_ac130_flares 1
```

### Potencial future version content
* Make killstreak duration 0 equate to infinite duration (aka killstreak MUST be shot down in order for them to leave).
* Client side menu files, for easily setting up private games.
* Restore nuke care package code
