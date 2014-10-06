#pragma semicolon 1
 
#include <sourcemod>
#include <sdktools>
#include "left4downtown"
 
#define TEAM_INFECTED					3
#define TAUNT_HIGH_THRESHOLD			0.4
#define TAUNT_MID_THRESHOLD				0.2
#define TAUNT_LOW_THRESHOLD				0.04

enum SIClasses
{
        SMOKER_CLASS=1,
        BOOMER_CLASS,
        HUNTER_CLASS,
        SPITTER_CLASS,
        JOCKEY_CLASS,
        CHARGER_CLASS,
        WITCH_CLASS,
        TANK_CLASS,
        NOTINFECTED_CLASS
}
 
static String:SINames[_:SIClasses][] =
{
        "",
        "gas",          // smoker
        "exploding",    // boomer
        "hunter",
        "spitter",
        "jockey",
        "charger",
        "witch",
        "tank",
        ""
};
 
new Handle: hCvarDamageFromCaps = INVALID_HANDLE;
new Handle: hSpecialInfectedHP[_:SIClasses] = INVALID_HANDLE;
//new Handle: hPrintTaunts;
//new Handle: hLowTauntPrint;
//new Handle: hMidTauntPrint;
//new Handle: hHighTauntPrint;
new Handle: hSurvivorCount;
new Handle: hPounceDamage;
new Handle: hRideDamage;
new Handle: hPoundDamage;
new Handle: hChokeDamage;
new Handle: hDragDamage;
new playersCapped = 0;

public Plugin:myinfo =
{
        name = "Capper Removal",
        author = "Jacob",
        description = "Better cap removal control. Supports any number of players.",
        version = "1.0",
        url = "https://github.com/jacob404/myplugins"
}


public OnPluginStart()
{      
        decl String:buffer[17];
        for (new i = 1; i < _:SIClasses; i++)
        {
            Format(buffer, sizeof(buffer), "z_%s_health", SINames[i]);
            hSpecialInfectedHP[i] = FindConVar(buffer);
        }
		
	//Cvars and whatnot
        hCvarDamageFromCaps = CreateConVar("damage_from_caps", "33", "Amount of damage done (at once) before SI suicides.", FCVAR_PLUGIN, true, 1.0);
	    //hCvarLedgeHangCounts = CreateConVar("ledge_hang_counts", "0", "Should ledge hangs increase the capped survivor count?", FCVAR_PLUGIN);
        hSurvivorCount = FindConVar("survivor_limit");
        hPounceDamage = FindConVar("z_pounce_damage");
        hRideDamage = FindConVar("z_jockey_ride_damage");
        hPoundDamage = FindConVar("z_charger_pound_damage");
	    hChokeDamage = FindConVar("tongue_choke_damage_amount");
		hDragDamage= FindConVar("tongue_drag_damage_amount");
		
	//Hooks
        HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
        HookEvent("lunge_pounce", Event_Survivor_Pounced);
        HookEvent("tongue_grab", Event_Survivor_Pulled);
        HookEvent("jockey_ride", Event_Survivor_Rode);
        HookEvent("charger_pummel_start", Event_Survivor_Charged);
        HookEvent("pounce_stopped", Event_Pounce_End);
        HookEvent("tongue_release", Event_Pull_End);
        HookEvent("jockey_ride_end", Event_Ride_End);
        HookEvent("charger_pummel_end", Event_Charge_End);
        //HookEvent("player_ledge_grab", survivor_hung);
}

public Event_Survivor_Pounced (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	playersCapped = (playersCapped + 1);
	PrintToChatAll("Pounce Landed");
	if (playersCapped >= GetConVarInt(hSurvivorCount))
	{
		SetConVarInt(hPounceDamage, GetConVarInt(hCvarDamageFromCaps));
	}
}

public Event_Pounce_End (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	PrintToChatAll("Pounce Ended");
	playersCapped = (playersCapped - 1);
	if (playersCapped < GetConVarInt(hSurvivorCount))
	{
		SetConVarInt(hPounceDamage, 5);
	}
	if (playersCapped < 0)
	{
		playersCapped = 0;
	}
}

public Event_Survivor_Rode (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	playersCapped = (playersCapped + 1);
	PrintToChatAll("Jock Landed");
	if (playersCapped >= GetConVarInt(hSurvivorCount))
	{
		SetConVarInt(hRideDamage, GetConVarInt(hCvarDamageFromCaps));
	}
}

public Event_Ride_End (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	PrintToChatAll("Jock Ended");
	playersCapped = (playersCapped - 1);
	if (playersCapped < GetConVarInt(hSurvivorCount))
	{
		SetConVarInt(hRideDamage, 4);
	}
	if (playersCapped < 0)
	{
		playersCapped = 0;
	}
}

public Event_Survivor_Charged (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	playersCapped = (playersCapped + 1);
	PrintToChatAll("Charge Landed");
	if (playersCapped >= GetConVarInt(hSurvivorCount))
	{
		SetConVarInt(hPoundDamage, GetConVarInt(hCvarDamageFromCaps));
	}
}

public Event_Charge_End (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	PrintToChatAll("Charge Ended");
	playersCapped = (playersCapped - 1);
	if (playersCapped < GetConVarInt(hSurvivorCount))
	{
		SetConVarInt(hPoundDamage, 15);
	}
	if (playersCapped < 0)
	{
		playersCapped = 0;
	}
}

public Event_Survivor_Pulled (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	playersCapped = (playersCapped + 1);
	PrintToChatAll("Pull Landed");
	if (playersCapped >= GetConVarInt(hSurvivorCount))
	{
		SetConVarInt(hChokeDamage, GetConVarInt(hCvarDamageFromCaps));
		SetConVarInt(hDragDamage, GetConVarInt(hCvarDamageFromCaps));
	}
}

public Event_Pull_End (Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!victim) return;
	PrintToChatAll("Pull Ended");
	playersCapped = (playersCapped - 1);
	if (playersCapped < GetConVarInt(hSurvivorCount))
	{
		SetConVarInt(hChokeDamage, 5);
		SetConVarInt(hDragDamage, 3);
	}
	if (playersCapped < 0)
	{
		playersCapped = 0;
	}
}

public Action:Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
        new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
        new victim = GetClientOfUserId(GetEventInt(event, "userid"));
       
        if (!IsClientAndInGame(attacker))
                return;
       
        new damage = GetEventInt(event, "dmg_health");
        new zombie_class = GetZombieClass(attacker);
       
        if (GetClientTeam(attacker) == TEAM_INFECTED && zombie_class != _:TANK_CLASS && damage >= GetConVarInt(hCvarDamageFromCaps))
        {
                new remaining_health = GetClientHealth(attacker);
                PrintToChatAll("\x01 Infected (\x03%N\x01) health remaining: \x05%d\x01", attacker, remaining_health);
                
                ForcePlayerSuicide(attacker);    
                
                new maxHealth = GetSpecialInfectedHP(zombie_class);
                if (!maxHealth)
                        return;    
                
                if (remaining_health == 1)
                {
                        PrintToChat(victim, "Ouch.");
                }
                else if (remaining_health <= RoundToCeil(maxHealth * TAUNT_LOW_THRESHOLD))
                {
                        PrintToChat(victim, "Unlucky!");
                }
                else if (remaining_health <= RoundToCeil(maxHealth * TAUNT_MID_THRESHOLD))
                {
                        PrintToChat(victim, "So close!");
                }
                else if (remaining_health <= RoundToCeil(maxHealth * TAUNT_HIGH_THRESHOLD))
                {
                        PrintToChat(victim, "Not bad.");
                }
        }
}


stock GetZombieClass(client) return GetEntProp(client, Prop_Send, "m_zombieClass");

stock GetSpecialInfectedHP(class)
{
    if (hSpecialInfectedHP[class] != INVALID_HANDLE)
            return GetConVarInt(hSpecialInfectedHP[class]);
    
    return 0;
}

stock bool:IsClientAndInGame(index)
{
        if (index > 0 && index < MaxClients)
        {
            return IsClientInGame(index);
        }
        return false;
}
