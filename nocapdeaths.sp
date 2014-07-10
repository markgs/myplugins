#pragma semicolon 1
 
#include <sourcemod>
#include <sdktools>
#include "left4downtown"
 
#define TEAM_INFECTED                   3
#define TAUNT_HIGH_THRESHOLD            0.4
#define TAUNT_MID_THRESHOLD             0.2
#define TAUNT_LOW_THRESHOLD             0.04
#define PLAYERS_CAPPED			0

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
 
new Handle: hCvarDmgThreshold = INVALID_HANDLE;
new Handle: hSpecialInfectedHP[_:SIClasses] = INVALID_HANDLE;


public Plugin:myinfo =
{
        name = "No Cap Deaths",
        author = "Jacob",
        description = "Releases survivors and applies damage when all survivors are capped.",
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
        
        hCvarDmgThreshold = CreateConVar("damage_from_caps", "33", "Amount of damage done (at once) before SI suicides.", FCVAR_PLUGIN, true, 1.0);
        
        hSurvivorCount = FindConVar("survivor_limit");
		
        HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
}
 
public Action:Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
        new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
        new victim = GetClientOfUserId(GetEventInt(event, "userid"));
       
        if (!IsClientAndInGame(attacker))
                return;
       
        new damage = GetEventInt(event, "dmg_health");
        new zombie_class = GetZombieClass(attacker);
       
        if (GetClientTeam(attacker) == TEAM_INFECTED && zombie_class != _:TANK_CLASS && damage >= GetConVarInt(hCvarDmgThreshold))
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
