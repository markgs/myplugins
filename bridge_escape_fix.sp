#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

new bool:isBridge = false;
new iTankCount = 0;

public Plugin:myinfo = 
{
    name = "Bridge Escape Fix",
    author = "Jacob",
    description = "Kills the unlimited tank spawns on parish finale.",
    version = "1.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    HookEvent("tank_spawn", Event_TankSpawn);
}

public OnMapStart()
{
    decl String:mapname[64];
    GetCurrentMap(mapname, sizeof(mapname));
    if(StrEqual(mapname, "c5m5_bridge"))
    {
        isBridge = true;
    }
    else
    {
        isBridge = false;
    }
    iTankCount = 0;
}

public Event_TankSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    new tank = GetClientOfUserId(GetEventInt(event, "userid"));
    iTankCount++;
    if(isBridge && iTankCount >= 3)
    {
        ForcePlayerSuicide(tank);
        return Plugin_Handled;
    }
}