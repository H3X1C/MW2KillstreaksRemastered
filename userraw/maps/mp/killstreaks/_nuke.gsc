#include common_scripts\utility;
#include maps\mp\_utility;


// ~~ NUKE Remastered ~~
// Cleans up the nuke scripts, finishes the left over code by IW and adds new features
// By H3X1C
//
// -- Nuke Settings --
// *Defines the duration of the nuke timer - (default=10)*
// scr_nukeTimer 				- Nuke timer in seconds
//
// *Stops nuke from ending the game - (default=0)*
// scr_nuke_is_moab = 0			- Nuke acts normally (ending game after detonation)
// scr_nuke_is_moab = 1			- Nuke acts like MW3 MOAB (Game does not end after detonation)
//
// *Defines the duration the nuked vision lasts after nuke detonation - (default=0=PermanentVision)*
// scr_nukeAftermathDuration	- Aftermath vision duration in seconds
//
// *Destroy all Air Support when nuke detonates [Not EMP] - (default=0=Off)*
// scr_nukeActiveVehicles = 0	- Doesn't destory vehicles (Air support) on nuke detonation
// scr_nukeActiveVehicles = 1	- Destroys all vehicles (Air support) on nuke detonation
//
// *Calls in a global EMP to all players with nuke detonation - (default=0=Off)*
// scr_nukeEMPDuration			- Duration of emp detonated by nuke blast (default=0=OFF)
//
// *Cut-content that allows nukes to be aborted if the player who called in the nuke dies - (default=0=Off)*
// scr_nukeCancelMode = 0 		- Disables this feature, nukes will behave as normal 
// scr_nukeCancelMode = 1 		- If nuke caller is killed nuke cancelled
// scr_nukeCancelMode = 2 		- If nuke caller is killed nuke cancelled and emp detonated
//
// *Kills every player on the map on detonation, works well combined with nukeEMP - (default=0=Off)*
// scr_nukeKillsAll = 0			- Disables this feature, nuke only kills other team
// scr_nukeKillsAll = 1			- Kills every player in the game
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

	game["strings"]["nuclear_strike"] = &"MP_TACTICAL_NUKE";
	
	level.killstreakFuncs["nuke"] = ::tryUseNuke;

	setDvarIfUninitialized( "scr_nukeTimer", 10 );
	setDvarIfUninitialized( "scr_nukeCancelMode", 0 );
	setDvarIfUninitialized( "scr_nukeActiveVehicles", 0 );
	setDvarIfUninitialized( "scr_nuke_is_moab", 0 );
	setDvarIfUninitialized( "scr_nukeAftermathDuration", 0 );
	setDvarIfUninitialized( "scr_nukeEMPDuration", 0 );
	setDvarIfUninitialized( "scr_nukeKillsAll", 0 );
	
	level.nukeTimer = getDvarInt( "scr_nukeTimer" );
	level.cancelMode = getDvarInt( "scr_nukeCancelMode" );
	level.nukeActiveVehicles = getDvarInt( "scr_nukeActiveVehicles" );
	level.nukeMoab = getDvarInt( "scr_nuke_is_moab" );
	level.nukeAftermath = getDvarInt( "scr_nukeAftermathDuration" );
	level.nuke = getDvarInt( "scr_nukeAftermathDuration" );
	level.nukeEMPDuration = getDvarInt( "scr_nukeEMPDuration" );
	level.nukeKillsAll = getDvarInt( "scr_nukeKillsAll" );

	level thread onPlayerConnect();
	level thread NukeEMP_PlayerTracker();
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

	self thread teamPlayerCardSplash( "used_nuke", self, self.team ); //called in nuke card
	self thread doNuke( allowCancel );
	self notify( "used_nuke" );
	
	return true;
}

delaythread_nuke( delay, func )
{
    level endon ( "nuke_cancelled" );
	
	wait ( delay );
	
	thread [[ func ]]();
}

doNuke( allowCancel )
{
	level endon ( "nuke_cancelled" );
	
	if ( level.cancelMode )
		self iPrintLnBold("^1Dead mans switch, stay alive or nuke will be aborted");
	
	level.nukeInfo = spawnStruct();
	level.nukeInfo.player = self;
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
	level thread delaythread_nuke( (level.nukeTimer + 1.5), ::nukeDeath );
	level thread delaythread_nuke( (level.nukeTimer + 1.5), ::nukeEarthquake );
	level thread nukeAftermathEffect();

	if ( level.cancelMode && allowCancel )
		level thread cancelNukeOnDeath( self ); 

	// leaks if lots of nukes are called due to endon above.
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

	maps\mp\gametypes\_gamelogic::resumeTimer();
	level.timeLimitOverride = false;

	setDvar( "ui_bomb_timer", 0 ); // Nuke sets '4' to avoid briefcase icon showing
	
	foreach( player in level.players ){
		if ( player != level.nukeInfo.player )
			player iprintlnbold( "^2Tango Down, Nuke Aborted" );
		player.nuked = undefined;
		level.nuked = undefined;
		level.nukeIncoming = undefined;
	}
	
	level notify ( "nuke_cancelled" );
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
	//SetSlowMotion( <startTimescale>, <endTimescale>, <deltaTime> )
	setSlowMotion( 1.0, 0.25, 0.5 );
	level waittill( "nuke_death" );
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
    
	visionSetNaked( "aftermath", 2 ); //Sets nuke aftermath vision file, transition of 5 secs

    // Toggles laptop killstreaks back on 
    wait( 4 );
    foreach( player in level.players )
    {
        player.nuked = undefined;
        level.nuked = undefined;
        level.nukeIncoming = undefined;
    }

	// If nukeAftermath set waits to reset the map vision (default 60 secs), if = 0 then never turns off vision
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
		// don't kill teammates as long as nukeKillsAll is off
		if( level.teambased )
		{
			if( IsDefined( level.nukeInfo.team ) && player.team == level.nukeInfo.team && !level.nukeKillsAll )
				continue;
		}
		// ffa, don't kill the player who called it
		else
		{
			if( IsDefined( level.nukeInfo.player ) && player == level.nukeInfo.player )
				continue;
		}

		player.nuked = true;	
		if ( isAlive( player ) )
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

	// TODO: need to get a different position to call this on
	earthquake( 0.6, 10, level.mapCenter, 100000 ); //Fixed by H3X1C ;)

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

		// make sure the vision set stays on between deaths
		if( IsDefined( level.nukeVisionInProgress ) )
		{
			self VisionSetNakedForPlayer( "aftermath", 0 );
		}
	}
}
