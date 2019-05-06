# KILLSTREAK REMASTERED v1.5
-------------------------------------------
By H3X1C with special thanks to Emosewaj, Killera, xBlizzDevious


# Installation
Place the iwd inside \userraw
Example: Call of Duty Modern Warfare 2\userraw\z_H3X1Cs-Killstreaks-Remastered-v1.5.iwd

# Server config
Non of these are required and are optional. If you do not include them they will just use their default value.

GLOBAL
    `scr_killstreak_mod 0                      - Allows players to restart their streak once completed in a single life (Default=0)
    scr_killstreak_rollover 0
    scr_killstreak_rollover 0`

NUKE
    scr_nukeTimer 10 				        - Nuke timer in seconds (Default=10)

    scr_nuke_is_moab 0			            - Nuke acts normally (ending game after detonation) (Default=0)
    scr_nuke_is_moab 1			            - Nuke acts like MW3 MOAB (Game does not end after detonation)

    scr_nuke_aftermath_duration 0		    - Aftermath vision duration(s) (0=PermanentVision) (Default=0)

    scr_nuke_active_vehicles 0		        - Doesn't destory vehicles (Air support) on nuke detonation [not an EMP] (Default=0)
    scr_nuke_active_vehicles 1		        - Destroys all vehicles (Air support) on nuke detonation [not an EMP]

    scr_nuke_emp_duration 0			        - Doesn't call in a global EMP to all players on nuke detonation (Default=0)
    scr_nuke_emp_duration 1                 - Calls in a global EMP to all players on nuke detonation

    scr_nukeCancelMode 0 		            - Disables this feature, nukes will behave as normal (Default=0)
    scr_nukeCancelMode 1 		            - If nuke caller is killed nuke cancelled (Cut content)
    scr_nukeCancelMode 2 		            - If nuke caller is killed nuke cancelled and emp detonated (Cut content)

    scr_nuke_earthquake_magnitude 0		    - Disbled earthquake
    scr_nuke_earthquake_magnitude 0.6		- Standard earthquake magnitude (Default=0.6)

    scr_nuke_earthquake_duration 0			- Disabled earthquake 
    scr_nuke_earthquake_duration 10		    - Standard earthquake duration (Default=10)

    scr_nuke_kills_all 0			        - Disables this feature, nuke only kills other team (Default=0)
    scr_nuke_Kills_all 1			        - Kills every player in the game

    scr_nuke_clasic_mode 0                  - Disables this features 
    scr_nuke_clasic_mode 0                  - Two harriers escort two stealth bombers, who do a fly by dropping the nuke

EMP
    scr_emp_duration 60			            - EMP duration in seconds (Default=60)

AC130
    scr_ac130_duration 40 		            - AC130 duration in seconds (Default=40)
    scr_ac130_flares 2		                - Number of flares (Default=2)

Predator Missile
    scr_predator_earthquake_magnitude 0	    - Disbled earthquake
    scr_predator_earthquake_magnitude 0.6   - Standard earthquake magnitude (Default=0.6)

    scr_predator_earthquake_radius 0		- Disbled earthquake
    scr_predator_quake_radius 5000			- Standard earthquake radius (Default=5000)

    scr_predator_earthquake_duration 0		- Disabled earthquake
    scr_predator_earthquake_duration 2		- Standard earthquake duration (Default=2)

UAV
    scr_uav_timeout 30 				        - UAV timer in seconds (Default=30)

    scr_counter_uav_timeout 30		        - Counter UAV in seconds (Default=30)

    scr_uav_forceon 0                       - Disables forced UAV (Default=0)

    scr_uav_forceon 1                       - Force permanent radar on 

ATTACK HELICOPTER
    scr_helicopter_cobra_duration 60

    scr_helicopter_cobra_missile 0          - Disable missile support 
    scr_helicopter_cobra_missile 1          - Attack helicopters will now shoot missiles at targets (Default=1)

PAVELOW
    scr_helicopter_pavelow_duration 60

CHOPPER GUNNER
    scr_helicopter_apache_duration 40




# Example server config #
Below is an example of a config setup.

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
