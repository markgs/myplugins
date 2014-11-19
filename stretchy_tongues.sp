#pragma semicolon 1

#include <sourcemod>

public Plugin:myinfo = 
{
    name = "Stretchy Tongues",
    author = "Jacob",
    description = "Fixes tongues breaking from bending or stretching too far.",
    version = "1.0",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    HookEvent("tongue_broke_bent", Event_BrokeBent);
}

public Event_BrokeBent(Handle:event, const String:name[], bool:dontBroadcast)
{
    return Plugin_Handled;
}