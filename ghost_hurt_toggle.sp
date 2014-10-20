#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#undef REQUIRE_PLUGIN
#include <readyup>
#define REQUIRE_PLUGIN

new Handle:ghost_hurt_type;
new bool:g_bReadyUpAvailable = false;

public Plugin:myinfo = 
{
    name = "Ghost Hurt Toggle",
    author = "Jacob",
    description = "Enables ghost hurt after the round goes live.",
    version = "1.0",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
	ghost_hurt_type = CreateConVar("ghost_hurt_type", "0", "When should trigger_hurt_ghost be enabled? 0 = Never, 1 = On Round Start", FCVAR_PLUGIN, true, 0.0, true, 1.0);
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

public OnRoundIsLive()
{
	if(GetConVarBool(ghost_hurt_type) == true)
	{
		EnableGhostHurt();
	}
}

public Action: L4D_OnFirstSurvivorLeftSafeArea( client )
{   
    if (!g_bReadyUpAvailable && GetConVarBool(ghost_hurt_type) == true)
	{
        EnableGhostHurt();
    }
}

public OnMapStart()
{
	DisableGhostHurt();
}

public DisableGhostHurt()
{
	ModifyEntity("trigger_hurt_ghost", "Disable");
}

public EnableGhostHurt()
{
	ModifyEntity("trigger_hurt_ghost", "Enable");
}

ModifyEntity(String:className[], String:inputName[])
{ 
    new iEntity;
    
    while ( (iEntity = FindEntityByClassname(iEntity, className)) != -1 )
	{
        if ( !IsValidEdict(iEntity) || !IsValidEntity(iEntity) )
		{
            continue;
        }
        AcceptEntityInput(iEntity, inputName);
    }
}

public Event_Round_End(Handle:event, const String:name[], bool:dontBroadcast)
{
	DisableGhostHurt();
}