/*
This plugin is irrelevant because the confoglcompmod module used for it doesn't function like I thought it did. 
It removes the triggers on map load meaning that even with the convar being changed it will have no effect.
I am instead updating the module to allow for something similar to this plugin. It will be uploaded to this git.
It's unforunate cuz this plugin works as it's intended to... Oh well I guess this can be framework for another plugin.
*/

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown>
#undef REQUIRE_PLUGIN
#include <readyup>
#define REQUIRE_PLUGIN

new Handle:hGhostHurtState;
new     bool:   g_bReadyUpAvailable     = false;

public Plugin:myinfo = 
{
    name = "Ghost Hurt Toggle",
    author = "Jacob",
    description = "Enables ghost hurt after the round goes live.",
    version = "0.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
	hGhostHurtState = FindConVar("confogl_disable_ghost_hurt");
	HookEvent("round_end", Event_Round_End);
}

// Check for readyup plugin.
public OnAllPluginsLoaded()
{
    g_bReadyUpAvailable = LibraryExists("readyup");
}
public OnLibraryRemoved(const String:name[])
{
    if ( StrEqual(name, "readyup") ) { g_bReadyUpAvailable = false; }
}
public OnLibraryAdded(const String:name[])
{
    if ( StrEqual(name, "readyup") ) { g_bReadyUpAvailable = true; }
}

// Disable ghost hurt on round live, or when survivors leave saferoom if no RUP.
public OnRoundIsLive()
{
    DisableGhostHurt();
}
public Action: L4D_OnFirstSurvivorLeftSafeArea( client )
{   
    if (!g_bReadyUpAvailable) {
        DisableGhostHurt();
    }
}
public DisableGhostHurt()
{
	SetConVarInt(hGhostHurtState, 0);
}

// Reset ghost hurt state on round end and plugin unload.
public Event_Round_End(Handle:event, const String:name[], bool:dontBroadcast)
{
	SetConVarInt(hGhostHurtState, 1);
}
public OnPluginEnd()
{
	SetConVarInt(hGhostHurtState, 1);
}