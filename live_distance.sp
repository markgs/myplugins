#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <readyup>

new Handle:distance_reset_time;
new Handle:ResetTimer;
new Float:ResetTime = 8.0;

public Plugin:myinfo = 
{
    name = "Live Distance Points",
    author = "Jacob",
    description = "Resets distance points periodically to give more accurate scoring.",
    version = "1.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    HookEvent("door_close", Event_DoorClose);
    HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("finale_vehicle_leaving", Event_RoundEnd, EventHookMode_PostNoCopy);
    HookEvent("player_death", Event_PlayerDeath);
    distance_reset_time = CreateConVar("distance_reset_time", "1.0", "How often should we reset distance points? Min 1, Max 30", FCVAR_PLUGIN, true, 1.0, true, 30.0);
}

public OnRoundIsLive()
{
    ResetTime = GetConVarFloat(distance_reset_time);
    ResetTimer = CreateTimer(ResetTime, ResetDistance, TIMER_REPEAT);
}

public Action:ResetDistance(Handle:timer)
{
    for (new i = 0; i < 4; i++)
    {
        GameRules_SetProp("m_iVersusDistancePerSurvivor", 0, _, i + 4 * GameRules_GetProp("m_bAreTeamsFlipped"));
    }
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event,"userid"));
    if(GetClientTeam(client) == 2)  KillTimer(ResetTimer);
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    KillTimer(ResetTimer);
}

public Action:Event_DoorClose(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(GetEventBool(event, "checkpoint")) KillTimer(ResetTimer);
}