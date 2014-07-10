#pragma semicolon 1
 
#include <sourcemod>
#include <sdktools>
#include "left4downtown"
 
#define TEAM_INFECTED					3
#define TAUNT_HIGH_THRESHOLD			0.4
#define TAUNT_MID_THRESHOLD				0.2
#define TAUNT_LOW_THRESHOLD				0.04
#define PLAYERS_CAPPED					0

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
new Handle: hSurvivorCount;
new Handle: hPounceDamage;
new Handle: hRideDamage;
new Handle: hPoundDamage;
//new Handle: hPullDamage;

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
		//hPullDamage = FindConVar("smokersarebroken");
		
		//Hooks
		HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
		
		HookEvent("lunge_pounce", Event_Survivor_Capped);
		HookEvent("tongue_grab", Event_Survivor_Capped);
		HookEvent("jockey_ride", Event_Survivor_Capped);
		HookEvent("charger_pummel_start", Event_Survivor_Capped);

		HookEvent("pounce_stopped", Event_Survivor_Free);
		HookEvent("tongue_release", Event_Survivor_Free);
		HookEvent("jockey_ride_end", Event_Survivor_Free);
		HookEvent("charger_pummel_end", Event_Survivor_Free);

		//HookEvent("player_ledge_grab", survivor_hung);
}

public Action:Event_Survivor_Capped(Handle:event, const String:name[], bool:dontBroadcast)
{
	PLAYERS_CAPPED = (PLAYERS_CAPPED + 1)
		
	if (PLAYERS_CAPPED >= GetConVarInt(hSurvivorCount))
		{
		SetConVarInt(hPounceDamage, hCvarDamageFromCaps);
		SetConVarInt(hRideDamage, hCvarDamageFromCaps);
		SetConVarInt(hPoundDamage, hCvarDamageFromCaps);
		//SetConVarInt(smokersarebroken, hCvarDamageFromCaps);
		}
	else
		{
		ResetConVar(hPounceDamage);
		ResetConVar(hRideDamage);
		ResetConVar(hPoundDamage);
		//ResetConVar(smokersarebroken);
		}
}

public Action:Event_Survivor_Free(Handle:event, const String:name[], bool:dontBroadcast)
{
	PLAYERS_CAPPED = (PLAYERS_CAPPED - 1)
	if (PLAYERS_CAPPED < GetConVarInt(hSurvivorCount))
		{
		ResetConVar(hPounceDamage);
		ResetConVar(hRideDamage);
		ResetConVar(hPoundDamage);
		//ResetConVar(smokersarebroken);
		}
	if (PLAYERS_CAPPED < 0)
		{
		PLAYERS_CAPPED = 0
		}
)

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
                PrintToChatAll("\x01[ProMod 1v1] Infected (\x03%N\x01) health remaining: \x05%d\x01", attacker, remaining_health);
                
                ForcePlayerSuicide(attacker);    
                
                new maxHealth = GetSpecialInfectedHP(zombie_class);
                if (!maxHealth)
                        return;    
                
                if (remaining_health == 1)
                {
                        PrintToChat(victim, "Get owned.");
                }
                else if (remaining_health <= RoundToCeil(maxHealth * TAUNT_LOW_THRESHOLD))
                {
                        PrintToChat(victim, "You seem upset.");
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
