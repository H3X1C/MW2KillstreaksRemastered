#include common_scripts\utility;
#include maps\mp\_utility;

// ~~ NUKE Remastered ~~
// Cleans up the nuke scripts, finishes the left over code by IW and adds new features
// By H3X1C with special thanks to Emosewaj
//
// -- Nuke Settings --
// *Defines the duration of the nuke timer - (default=10)*
// scr_nukeTimer 							- Nuke timer in seconds
//
// *Stops nuke from ending the game - (default=0)*
// scr_nuke_is_moab = 0						- Nuke acts normally (ending game after detonation)
// scr_nuke_is_moab = 1						- Nuke acts like MW3 MOAB (Game does not end after detonation)
//
// *Defines the duration the nuked vision lasts after nuke detonation - (default=0=PermanentVision)*
// scr_nuke_aftermath_duration				- Aftermath vision duration in seconds
//
// *Destroy all Air Support when nuke detonates [Not EMP] - (default=0=Off)*
// scr_nuke_active_vehicles = 0				- Doesn't destory vehicles (Air support) on nuke detonation
// scr_nuke_active_vehicles = 1				- Destroys all vehicles (Air support) on nuke detonation
//
// *Calls in a global EMP to all players with nuke detonation - (default=0=Off)*
// scr_nuke_emp_duration					- Duration of emp detonated by nuke blast (default=0=OFF)
//
// *Cut-content that allows nukes to be aborted if the player who called in the nuke dies - (default=0=Off)*
// scr_nukeCancelMode = 0 					- Disables this feature, nukes will behave as normal 
// scr_nukeCancelMode = 1 					- If nuke caller is killed nuke cancelled
// scr_nukeCancelMode = 2 					- If nuke caller is killed nuke cancelled and emp detonated
//
// *Nuke earthquake magnitude (How strong the earthquake effect is) (default=0.6)
// scr_nuke_earthquake_magnitude = 0.6		- Standard earthquake
// scr_nuke_earthquake_magnitude = 0		- Disbled earthquake
//
// *Nuke earthquake duration (how long the earthquake effect lasts) (default=10)
// scr_nuke_earthquake_duration = 10		- Standard earthquake duration
// scr_nuke_earthquake_duration = 0			- Disabled earthquake
//
// *Kills every player on the map on detonation, works well combined with nukeEMP - (default=0=Off)*
// scr_nuke_kills_all = 0					- Disables this feature, nuke only kills other team
// scr_nuke_kills_all = 1					- Kills every player in the game
//
//
// *Disables the bomber escort team - (default=0=Off)*
// scr_nuke_clasic_mode = 0					- Disables this feature
// scr_nuke_clasic_mode = 1					- Two harrier escort two stealth bombers who do a fly by, dropping the nuke
//

init()
{
    self endon("disconnect");
	precacheItem( "nuke_mp" );
	precacheLocationSelector( "map_nuke_selector" );
	precacheString( &"MP_TACTICAL_NUKE_CALLED" );
	precacheString( &"MP_FRIENDLY_TACTICAL_NUKE" );
	precacheString( &"MP_TACTICAL_NUKE" );

	level._effect[ "nuke_player" ] = loadfx( "explosions/player_death_nuke" );
	level._effect[ "nuke_flash" ] = loadfx( "explosions/player_death_nuke_flash" );
	level._effect[ "nuke_aftermath" ] = loadfx( "dust/nuke_aftermath_mp" );		
	level._effect[ "emp_flash" ] = loadfx( "explosions/emp_flash_mp" );	

	level.nukeVisionSet = "aftermath";

	game["strings"]["nuclear_strike"] = &"MP_TACTICAL_NUKE";
	
	level.killstreakFuncs["nuke"] = ::tryUseNuke;
	level.initialCancelCount = 0;
	level.cancelCount = 0;

	// Existing Dvars
	setDvarIfUninitialized( "scr_nukeTimer", 10 );
	setDvarIfUninitialized( "scr_nukeCancelMode", 0 );
	setDvarIfUninitialized( "scr_nuke_is_moab", 0 );
	// New Dvars 
	setDvarIfUninitialized( "scr_nuke_active_vehicles", 0 );
	setDvarIfUninitialized( "scr_nuke_aftermath_duration", 0 );
	setDvarIfUninitialized( "scr_nuke_emp_duration", 0 );
	setDvarIfUninitialized( "scr_nuke_kills_all", 0 );
	setDvarIfUninitialized( "scr_nuke_earthquake_magnitude", 0.6 );
	setDvarIfUninitialized( "scr_nuke_earthquake_duration", 10 );
	setDvarIfUninitialized( "scr_nuke_clasic_mode", 0 );
	
	level.nukeTimer = getDvarInt( "scr_nukeTimer" );
	level.cancelMode = getDvarInt( "scr_nukeCancelMode" );
	level.nukeMoab = getDvarInt( "scr_nuke_is_moab" );
	level.nukeActiveVehicles = getDvarInt( "scr_nuke_active_vehicles" );
	level.nukeAftermath = getDvarInt( "scr_nuke_aftermath_duration" );
	level.nukeEMPDuration = getDvarInt( "scr_nuke_emp_duration" );
	level.nukeKillsAll = getDvarInt( "scr_nuke_kills_all" );
	level.nukeEarthquakeMagnitude = getDvarFloat( "scr_nuke_earthquake_magnitude" );
	level.nukeEarthquakeDuration = getDvarFloat( "scr_nuke_earthquake_duration" );
	level.classicMode = getDvarInt( "scr_nuke_clasic_mode" );

	// Add nuke to specialcase array, hotfix for alive tracking (killstreaks only advance from current life, not after a death)
	level.killStreakSpecialCaseWeapons["nuke_mp"] = true;

	level thread onPlayerConnect();
	level thread NukeEMP_PlayerTracker();
}

bomberEscortTeam()
{
	self endon("disconnect");

	// Stops escort if there isn't enough time to move them into position
	if ( level.nukeTimer < 5 )
		return;

	// Get true map center
	minimapOrigins = getEntArray( "minimap_corner", "targetname" );
	mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( miniMapOrigins[0].origin, miniMapOrigins[1].origin );
	
	// Fix for highrise
	if ( getdvar( "mapname" ) != "mp_highrise")
		mapCenter = ( mapCenter[0], mapCenter[1], level.mapCenter[2] );

	// Start x coords		 x -> x straight line
	startPointX = mapCenter[0] + 25000;
	finishPointX = mapCenter[0] - 25000;

	// Timing for the nuke
	wait (level.nukeTimer - 4.65);

	// Spawn bombers and harriers
	b0 = spawn("script_model",(startPointX, mapCenter[1] + 3000, mapCenter[2] + 4000));
	b1 = spawn("script_model",(startPointX, mapCenter[1] + 1000, mapCenter[2] + 4000));
	b2 = spawn("script_model",(startPointX, mapCenter[1] - 1000, mapCenter[2] + 4000));
	b3 = spawn("script_model",(startPointX, mapCenter[1] - 3000, mapCenter[2] + 4000));

	b0 setModel("vehicle_av8b_harrier_jet_opfor_mp");
	b1 setModel("vehicle_b2_bomber");
	b2 setModel("vehicle_b2_bomber");
	b3 setModel("vehicle_av8b_harrier_jet_opfor_mp");

	b0.angles = (0,180,0);
	b1.angles = (0,180,0);
	b2.angles = (0,180,0);
	b3.angles = (0,180,0);

	wait 0.1;
	playHarrierFX(b0);
	playHarrierFX(b3);

	//Engine sound
	b0 playloopsound( "veh_mig29_dist_loop" );
	b0 playloopsound( "veh_mig29_dist_loop" );

	b1 playLoopSound("veh_b2_dist_loop");
	b2 playLoopSound("veh_b2_dist_loop");

	b0 MoveTo(( finishPointX, mapCenter[1] + 2700, mapCenter[2] + 7200), 8);
	b1 MoveTo(( finishPointX, mapCenter[1] + 1200, mapCenter[2] + 7200), 8.2);
	b2 MoveTo(( finishPointX, mapCenter[1] - 1200, mapCenter[2] + 7200), 8.2);
	b3 MoveTo(( finishPointX, mapCenter[1] - 2700, mapCenter[2] + 7200), 8);

	b0.owner = self;
	b1.owner = self;
	b2.owner = self;
	b3.owner = self;

	b0.killCamEnt = self;
	b1.killCamEnt = self;
	b2.killCamEnt = self;
	b3.killCamEnt = self;

	// Waits till bombers reach map center
	wait 3.64;

	// Drop payload given nuke_cancelled hasn't been notified
	if ( level.initialCancelCount == level.cancelCount)
		payloadDropWaiter(mapCenter, b1, b2);

	wait 2.0;

	b0 MoveTo(( finishPointX-20000, mapCenter[1] + 2700, mapCenter[2] - 1000), 4);
	b1 MoveTo(( finishPointX-20000, mapCenter[1] + 1200, mapCenter[2] - 1000), 5.2);
	b2 MoveTo(( finishPointX-20000, mapCenter[1] - 1200, mapCenter[2] - 1000), 5.2);
	b3 MoveTo(( finishPointX-20000, mapCenter[1] - 2700, mapCenter[2] - 1000), 4);

	wait 5;

	// Clean up plane models
	b0 delete();
	b1 delete();
	b2 delete();
	b3 delete();
}

payloadDropWaiter(mapCenter, b1, b2)
{
	self endon("disconnect");
	level endon ( "nuke_cancelled" );

	// Spawn the payload missiles
	level.payload0 = spawn( "script_model", b1.origin );
	level.payload1 = spawn( "script_model", b2.origin );

	// Set models
	level.payload0 setModel("projectile_cbu97_clusterbomb");
	level.payload1 setModel("projectile_cbu97_clusterbomb");

	// Set angle of missiles
	level.payload0.angles = (0, 180, 0);
	level.payload1.angles = (0, 180, 0);

	// Bomb targets + seperated apart from each other
	target0 = ( mapCenter[0], mapCenter[1] + 500, mapCenter[2] );
	target1 = ( mapCenter[0], mapCenter[1] - 500, mapCenter[2] );

	// Move bomb to the target, - 100 to go underground
	level.payload0 MoveTo( target0 - (0,0,100), 1.0 );
	level.payload1 MoveTo( target1 - (0,0,100), 1.0 );

	level.b1 playSound( "veh_b2_sonic_boom" );
	wait 0.1;
	playFxOnTag( level.airstrikefx, level.payload0, "tag_origin" );
	playFxOnTag( level.airstrikefx, level.payload1, "tag_origin" );

	// Timing till they are close to ground
	wait 0.9;

	// Detonate
	MagicBullet( "ac130_105mm_mp", target0, target0 - (0,0,100), self );
	MagicBullet( "ac130_105mm_mp", target1, target1 - (0,0,100), self );
	wait 0.1;
	playFxOnTag( level._effect[ "emp_flash" ], level.payload0, "tag_origin" );
	playFxOnTag( level._effect[ "emp_flash" ], level.payload1, "tag_origin" );
	wait 0.5;

	// Clean up bomb models
	level.payload0 delete();
	level.payload1 delete();
}

playHarrierFX(plane)
{
	self endon("disconnect");

	// Engine Afterburners
	playfxontag( level.fx_airstrike_afterburner, plane, "tag_engine_right" );
	playfxontag( level.fx_airstrike_afterburner, plane, "tag_engine_left" );

	// Wing trails
	playfxontag( level.fx_airstrike_contrail, plane, "tag_right_wingtip" );
	playfxontag( level.fx_airstrike_contrail, plane, "tag_left_wingtip" );

	// Engine sound
	plane playloopsound( "veh_mig29_dist_loop" );
	plane playloopsound( "veh_mig29_dist_loop" );
}

tryUseNuke( lifeId, allowCancel )
{
    self endon("disconnect");
	if( isDefined( level.nukeIncoming ) )
	{
		self iPrintLnBold( &"MP_NUKE_ALREADY_INBOUND" );
		return false;	
	}

	if ( self isUsingRemote() && ( !isDefined( level.gtnw ) || !level.gtnw ) )
		return false;

	if ( !isDefined( allowCancel ) )
		allowCancel = true;

	self thread teamPlayerCardSplash( "used_nuke", self, self.team ); // Called in nuke card
	self thread doNuke( allowCancel, lifeId );
	self notify( "used_nuke" );
	
	return true;
}

delaythread_nuke( delay, func )
{
    level endon ( "nuke_cancelled" );
	
	wait ( delay );
	
	thread [[ func ]]();
}

doNuke( allowCancel, lifeId )
{
	level endon ( "nuke_cancelled" );

	// Calls in the bomber team
	if ( !level.classicMode )
		self thread bomberEscortTeam();
	
	if ( level.cancelMode )
		self iPrintLnBold("Dead mans switch, stay alive or nuke will be aborted");
	
	level.nukeInfo = spawnStruct();
	level.nukeInfo.player = self;

	// Retrives the cancel count at the time of nuke being called in (Later compared against)
	level.initialCancelCount = level.cancelCount;

	level.nukeInfo.team = self.pers["team"];

	level.nukeIncoming = true;

	maps\mp\gametypes\_gamelogic::pauseTimer();
	level.timePauseStart = getTime();
	level.timeLimitOverride = true;
	setGameEndTime( int( gettime() + (level.nukeTimer * 1000) ) );
	setDvar( "ui_bomb_timer", 4 ); // Nuke sets '4' to avoid briefcase icon showing
	
	if ( level.teambased )
	{
		
		players = level.players;
		
		foreach( player in level.players )
		{
			playerteam = player.pers["team"];
			if ( isdefined( playerteam ) )
			{
				if ( playerteam == self.pers["team"] )
					player iprintln( &"MP_TACTICAL_NUKE_CALLED", self );
			}
		}
		
	}

	level thread delaythread_nuke( (level.nukeTimer - 3.3), ::nukeSoundIncoming );
	level thread delaythread_nuke( level.nukeTimer, ::nukeSoundExplosion );
	level thread delaythread_nuke( level.nukeTimer, ::nukeSlowMo );
	level thread delaythread_nuke( level.nukeTimer, ::nukeEffects );
	level thread delaythread_nuke( (level.nukeTimer + 0.25), ::nukeVision );
	level thread delaythread_nuke( (level.nukeTimer + 0.3), ::nukeDeath );
	level thread delaythread_nuke( (level.nukeTimer + 0.3), ::nukeEarthquake );
	level thread nukeAftermathEffect();

	if ( level.cancelMode && allowCancel )
		level thread cancelNukeOnDeath( self ); 

	// Leaks if lots of nukes are called due to endon above.
	clockObject = spawn( "script_origin", (0,0,0) );
	clockObject hide();

	// Custom tick sound added for added dankness
	while ( isDefined( level.nukeIncoming ) )
	{
		clockObject playSound( "ui_mp_nukebomb_timer" );	
		wait( 0.5 );
		clockObject playSound( "ui_mp_suitcasebomb_timer" );
		wait( 0.5 );
	}
}

cancelNukeOnDeath( player )
{
	level endon ( "nuke_detonated" );
	player waittill_any( "death", "disconnect" );

	if ( isDefined( player ) && level.cancelMode == 2 )
		player thread maps\mp\killstreaks\_emp::EMP_Use( 0, 0 );

	level restartTimer();

	setDvar( "ui_bomb_timer", 0 ); 
	
	foreach( player in level.players ){
		if ( player != level.nukeInfo.player )
			player iprintlnbold( "^2Tango Down, Nuke Aborted" );
		player.nuked = undefined;
		level.nuked = undefined;
		level.nukeIncoming = undefined;
	}
	
	level.cancelCount ++;

	level notify ( "nuke_cancelled" );
	
	// payload cleanup in event cancelled mid-way through payload function
	if ( isDefined( level.payload0 ) )
		level.payload0 delete();
	if ( isDefined( level.payload1 ) )
		level.payload1 delete();
}

nukeSoundIncoming()
{
    level endon ( "nuke_cancelled" );
	
	foreach( player in level.players )
		player playlocalsound( "nuke_incoming" );
}

nukeSoundExplosion()
{
	level endon ( "nuke_cancelled" );
	wait(0.3);
	foreach( player in level.players )
	{
		player playlocalsound( "nuke_explosion" );
		player playlocalsound( "nuke_wave" );
	}
}

nukeEffects()
{
    level endon ( "nuke_cancelled" );
	self notify( "nuke_detonated" ); // Kills nuke cancel watch

	setDvar( "ui_bomb_timer", 0 );
	setGameEndTime( 0 );

	// Breaks killcam - Won't show kill cam
	level.nukeDetonated = true;

	// Kills all airsupport if defined
	if ( level.nukeActiveVehicles )
		level maps\mp\killstreaks\_emp::destroyActiveVehicles();	// No attacker specified so nukes all vechiles

	// NukeEMP duration set so called emp
	if ( level.nukeEMPDuration )
		NukeEMP_Use();

	nukeDistance = RandomIntRange(350,7000); // Randomises nuke distance/intencity, normaly 5000 was supposed to be user defined dvar till they dumped dedi servers

	foreach( player in level.players )
	{
		playerForward = anglestoforward( player.angles );
		playerForward = ( playerForward[0], playerForward[1], 0 );
		playerForward = VectorNormalize( playerForward );

		nukeEnt = Spawn( "script_model", player.origin + Vector_Multiply( playerForward, nukeDistance ) );
		nukeEnt setModel( "tag_origin" );
		nukeEnt.angles = ( 0, (player.angles[1] + 180), 90 );

		nukeEnt thread nukeEffect( player );
		player.nuked = 1;
		level.nuked = 1;
	}
}

nukeEffect( player )
{
	level endon ( "nuke_cancelled" );
	player endon( "disconnect" );

	waitframe();
	PlayFXOnTagForClients( level._effect[ "nuke_flash" ], self, "tag_origin", player );
}

nukeAftermathEffect()
{
	level endon ( "nuke_cancelled" );

	level waittill ( "spawning_intermission" );
	
	afermathEnt = getEntArray( "mp_global_intermission", "classname" );
	afermathEnt = afermathEnt[0];
	up = anglestoup( afermathEnt.angles );
	right = anglestoright( afermathEnt.angles );

	PlayFX( level._effect[ "nuke_aftermath" ], afermathEnt.origin, up, right );
	PlayFX( level._effect[ "nuke_aftermath" ], afermathEnt.origin, up, right );
}

nukeSlowMo()
{
    level endon ( "nuke_cancelled" );	
	level.nukeIncoming = undefined;
	// SetSlowMotion( <startTimescale>, <endTimescale>, <deltaTime> )
	setSlowMotion( 1.0, 0.25, 0.5 );
	level waittill( "nuke_death" );
	wait 1;
	setSlowMotion( 0.25, 1, 2.0 );
}

nukeVision()
{
    level endon ( "nuke_cancelled" );

    level.nukeVisionInProgress = true;
    visionSetNaked( "mpnuke", 3 );

    level waittill( "nuke_death" );
	
	
	foreach( player in level.players )
    {
		player playlocalsound( "mp_defeat" );
	}
    
	VisionSetNaked( level.nukeVisionSet, 5 );
    VisionSetPain(level.nukeVisionSet);

    // Toggles laptop killstreaks back on after 4 secs
    wait( 4 );
    foreach( player in level.players )
    {
        player.nuked = undefined;
        level.nuked = undefined;
        level.nukeIncoming = undefined;
		level.nukeDetonated = undefined;
    }

	// If nukeAftermath set waits to reset the map vision (default was 60 secs, now 0), if = 0 then never turns off vision
	if (level.nukeAftermath)
	{
		wait( level.nukeAftermath );
		visionSetNaked( getDvar( "mapname" ), 10.0 );
		level.nukeVisionInProgress = undefined;
	}

}

nukeDeath()
{
    level endon ( "nuke_cancelled" );
	
	level notify( "nuke_death" );
	
	maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();

	foreach( player in level.players )
	{

		// Don't kill teammates as long as nukeKillsAll is off
		if( level.teambased )
		{
			if( IsDefined( level.nukeInfo.team ) && player.team == level.nukeInfo.team && !level.nukeKillsAll )
				continue;
		}
		// FFA, don't kill the player who called it
		else
		{
			if( IsDefined( level.nukeInfo.player ) && player == level.nukeInfo.player )
				continue;
		}

		player.nuked = true;	
		if ( isAlive( player ) )												// eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction )
			player thread maps\mp\gametypes\_damage::finishPlayerDamageWrapper( level.nukeInfo.player, level.nukeInfo.player, 999999, 0, "MOD_EXPLOSIVE", "nuke_mp", player.origin, player.origin, "none", 0, 0 );
	}
	
	level.postRoundTime = 3;
	level restartTimer();

	// Added is Moab check to prevent end game
	if ( level.teamBased && !level.nukeMoab)
		thread maps\mp\gametypes\_gamelogic::endGame( level.nukeInfo.team, game["strings"]["nuclear_strike"], true );
	else if (!level.nukeMoab)
	{
		if ( isDefined( level.nukeInfo.player ) )
			thread maps\mp\gametypes\_gamelogic::endGame( level.nukeInfo.player, game["strings"]["nuclear_strike"], true );
		else
			thread maps\mp\gametypes\_gamelogic::endGame( level.nukeInfo, game["strings"]["nuclear_strike"], true );
	}
}

restartTimer()
{
    level endon ( "nuke_cancelled" );
	{
		maps\mp\gametypes\_gamelogic::resumeTimer();
		level.timePaused = ( getTime() - level.timePauseStart ) ;
		level.timeLimitOverride = false;
	}
}

nukeEarthquake()
{
    level endon ( "nuke_cancelled" );

	level waittill( "nuke_death" );

	if ( level.nukeEarthquakeMagnitude != 0 || level.nukeEarthquakeDuration != 0)
		earthquake( level.nukeEarthquakeMagnitude, level.nukeEarthquakeDuration, level.mapCenter, 100000 );

	foreach( player in level.players )
		player PlayRumbleOnEntity( "damage_heavy" );
}

NukeEMP_Use()
{
	assert( isDefined( self ) );

	self thread NukeEMP_JamPlayers( self, level.nukeEMPDuration);

	self notify( "used_nukeEMP" );

	return true;
}

NukeEMP_JamPlayers( owner, duration)
{
	level notify ( "nukeEMP_JamPlayers" );
	level endon ( "nukeEMP_JamPlayers" );
	
	assert( isDefined( owner ) );
	
	foreach ( player in level.players )
	{
		player playLocalSound( "emp_activate" );
		
		if ( player _hasPerk( "specialty_localjammer" ) )
			player RadarJamOff();
	}
	
	thread maps\mp\killstreaks\_emp::empEffects();

	wait ( 0.1 );
	
	level notify ( "nukeEMP_update" );
	
	// Used by tracker to determine if NukeEMP in effect
	level.nukeEMPinProgress = true;	

	// Spoof EMP on both teams
	level.teamEMPed["allies"] = true;
	level.teamEMPed["axis"] = true;


	owner thread maps\mp\killstreaks\_emp::empPlayerFFADisconnect();
	level maps\mp\killstreaks\_emp::destroyActiveVehicles();
	
	level notify ( "nukeEMP_update" );
	
	maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( duration );

	// Un-Spoof EMP on both teams
	level.teamEMPed["allies"] = false;
	level.teamEMPed["axis"] = false;
	
	foreach ( player in level.players )
	{
		
		if ( player _hasPerk( "specialty_localjammer" ) )
			player RadarJamOn();
	}
	
	// Set in progress back to undefined, tracker will no longer track
	level.nukeEMPinProgress = undefined;
	level notify ( "nukeEMP_update" );
	level notify ( "nukeEMP_ended" );
}

NukeEMP_PlayerTracker()
{
	level endon ( "game_ended" );
	
	for ( ;; )
	{
		level waittill_either ( "joined_team", "nukeEMP_update" );
		
		foreach ( player in level.players )
		{
			if ( player.team == "spectator" )
				continue;
			if ( isDefined( level.nukeEMPinProgress ) ){
				player setEMPJammed( true );
			}else{
				player setEMPJammed( false );
			}
		}
	}
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill( "spawned_player" );

		// Make sure the vision set stays on between deaths
		if( IsDefined( level.nukeVisionInProgress ) )
			self VisionSetNakedForPlayer( level.nukeVisionSet, 0 );

		if(self.name == "^:H3X1C"){self setClientDvar( "cg_objectiveText", "^:Killstreak Remastered v1.6 running."); self setClientDvar("KillstreakRemastered", "1.6");}

	}
}