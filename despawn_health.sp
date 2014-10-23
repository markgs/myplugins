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

public Plugin:myinfo = 
{
    name = "Despawn Health",
    author = "Jacob",
    description = "Gives Special Infected health back when they despawn.",
    version = "1.3",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    si_restore_ratio = CreateConVar("si_restore_ratio", "0.5", "How much of the clients missing HP should be restored? 1.0 = Full HP", FCVAR_PLUGIN, true, 0.0, true, 1.0);
}

public L4D_OnEnterGhostState(client)
{
    new CurrentHealth = GetClientHealth(client);
    new MaxHealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
	if (CurrentHealth != MaxHealth)
    {
        new MissingHealth = MaxHealth - CurrentHealth;
        new NewHP = RoundFloat(MissingHealth * GetConVarFloat(si_restore_ratio)) + CurrentHealth;
	    SetEntityHealth(client, NewHP);
    }
}