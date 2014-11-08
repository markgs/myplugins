#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

public Plugin:myinfo = 
{
    name = "No Death Cam",
    author = "Jacob",
    description = "Skips the deathcam infected get after dying, which also prevents an exploit with spawn timers.",
    version = "1.2",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    HookEvent("player_death", Event_PlayerDeath);
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
    new victim = GetClientOfUserId(GetEventInt(event,"userid"));
	
    if (IsValidClient(victim) && GetClientTeam(victim) == 3)
    {
        SetEntPropEnt(victim, Prop_Send, "m_iObserverMode", 4);
    }
}

stock bool:IsValidClient(client, bool:nobots = true)
{ 
    if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
    {
        return false; 
    }
    return IsClientInGame(client); 
}