
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#undef REQUIRE_PLUGIN
#include <readyup>
#define REQUIRE_PLUGIN

new Handle:hGhostHurtState;
new Handle:ghost_hurt_type;
new bool:g_bReadyUpAvailable = false;

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
	ghost_hurt_type = CreateConVar("ghost_hurt_type", "1", "When should trigger_hurt_ghost be enabled? 0 = Never, 1 = On Round Start, 2 = Always", FCVAR_PLUGIN, true, 0.0, true, 2.0);
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
	if(GetConVarInt(ghost_hurt_type) == 1)
	{
		EnableGhostHurt();
	}
}

public Action: L4D_OnFirstSurvivorLeftSafeArea( client )
{   
    if (!g_bReadyUpAvailable && GetConVarInt(ghost_hurt_type) == 1)
	{
        EnableGhostHurt();
    }
}

public OnMapStart()
{
	if(GetConVarInt(ghost_hurt_type) << 2)
	{
		DisableGhostHurt();
	}
	else
	{
		EnableGhostHurt();
	}
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
	if(GetConVarInt(ghost_hurt_type) << 2)
	{
		DisableGhostHurt();
	}
}

public OnPluginEnd()
{
	EnableGhostHurt();
}