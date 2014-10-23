#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown>

#define ZC_SMOKER               1
#define ZC_BOOMER               2
#define ZC_HUNTER               3
#define ZC_SPITTER              4
#define ZC_JOCKEY               5
#define ZC_CHARGER              6

new Handle:si_restore_ratio;
new MaxHealth;

public Plugin:myinfo = 
{
    name = "Despawn Health",
    author = "Jacob",
    description = "Gives Special Infected health back when they despawn.",
    version = "1.0",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    si_restore_ratio = CreateConVar("si_restore_ratio", "0.5", "How much of the clients missing HP should be restored? 1.0 = Full HP", FCVAR_PLUGIN, true, 0.0, true, 1.0);
}

public L4D_OnEnterGhostState(client)
{
    new CurrentHealth = GetClientHealth(client);
	
    if (GetEntProp(client, Prop_Send, "m_zombieClass") == ZC_CHARGER)
    {
        MaxHealth = 600;
    }
    else if (GetEntProp(client, Prop_Send, "m_zombieClass") == ZC_JOCKEY)
    {
        MaxHealth = 325;
    }
    else if (GetEntProp(client, Prop_Send, "m_zombieClass") == ZC_HUNTER)
    {
        MaxHealth = 250;
    }
    else if (GetEntProp(client, Prop_Send, "m_zombieClass") == ZC_SMOKER)
    {
        MaxHealth = 250;
    }
    else if (GetEntProp(client, Prop_Send, "m_zombieClass") == ZC_SPITTER)
    {
        MaxHealth = 100;
    }
    else if (GetEntProp(client, Prop_Send, "m_zombieClass") == ZC_BOOMER)
    {
        MaxHealth = 50;
    }
	
    new MissingHealth = MaxHealth - CurrentHealth;
    new NewHP = RoundFloat(MissingHealth * GetConVarFloat(si_restore_ratio)) + CurrentHealth;
    SetEntityHealth(client, NewHP);
}