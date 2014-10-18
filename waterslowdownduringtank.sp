#pragma semicolon 1

#include <sourcemod>
#include <colors>

new bool:g_bIsTankAlive;
new Handle:SlowdownFactor;
new Handle:WSDT_Print;

public Plugin:myinfo =
{
	name = "Water Slowdown During Tank",
	author = "Don, Jacob, epilimic",
	description = "Modifies water slowdown while tank is in play.",
	version = "1.7",
	url = "https://github.com/Stabbath/ProMod"
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	decl String:sGame[12];
	GetGameFolderName(sGame, sizeof(sGame));
	if (StrEqual(sGame, "left4dead2"))	// Only load the plugin if the server is running Left 4 Dead 2.
	{
		return APLRes_Success;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports L4D2");
		return APLRes_Failure;
	}
}

public OnPluginStart()
{
	HookEvent("tank_spawn", Event_tank_spawn_Callback);
	HookEvent("player_death", Event_player_death_Callback);
	HookEvent("round_end", Event_round_end_Callback);
	
	WSDT_Print = CreateConVar("print_slowdown_changes", "1", "Whether or not to print when we change water slowdown.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	SlowdownFactor = FindConVar("confogl_slowdown_factor");
}

public Event_tank_spawn_Callback(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!g_bIsTankAlive)
	{
		SetConVarFloat(SlowdownFactor, 0.95);
		g_bIsTankAlive = true;
		if(GetConVarBool(WSDT_Print))
		{
			CPrintToChatAll("{olive}Water Slowdown{default} has been reduced while Tank is in play.");
		}
	}
}

public Event_player_death_Callback(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (g_bIsTankAlive)
	{
		new String:sVictimName[8];
		GetEventString(event, "victimname", sVictimName, sizeof(sVictimName));
		if (StrEqual(sVictimName, "Tank"))
		{
			SetConVarFloat(SlowdownFactor, 0.90);
			g_bIsTankAlive = false;
			if(GetConVarBool(WSDT_Print))
			{
				CPrintToChatAll("{olive}Water Slowdown{default} has been restored to normal.");
			}
		}
	}
}

public Event_round_end_Callback(Handle:event, const String:name[], bool:dontBroadcast)		// Needed for when the round ends without the tank dying.
{
	if (g_bIsTankAlive)
	{
		SetConVarFloat(SlowdownFactor, 0.90);
		g_bIsTankAlive = false;
	}
}

public OnPluginEnd()
{
	if (g_bIsTankAlive)
	{
		SetConVarFloat(SlowdownFactor, 0.90);
	}
}
