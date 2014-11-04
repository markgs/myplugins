#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

public Plugin:myinfo = 
{
    name = "No Death Cam",
    author = "Jacob",
    description = "Skips the deathcam infected get after dying, which also prevents an exploit with spawn timers.",
    version = "1.0",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    HookEvent("player_death", Event_PlayerDeath);
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
    new victim = GetClientOfUserId(GetEventInt(event,"userid"));
    new max_clients = GetMaxClients();

    for (new i = 1; i <= max_clients; i++)
    {
        if (IsValidClient(i) && GetClientTeam(i) == 3)
        {
            SetEntPropEnt(victim, Prop_Send, "m_hObserverTarget", i);
            SetEntPropEnt(victim, Prop_Send, "m_iObserverMode", 4);
            break;
        }
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