#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

new Handle:remove_motel_clip;
new Handle:remove_swan_clip;
new Handle:remove_plantation_clip;

public Plugin:myinfo = 
{
    name = "Clip Removal",
    author = "Jacob",
    description = "Allows for removal of some pesky clips.",
    version = "1.0",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
        remove_motel_clip = CreateConVar("remove_motel_clip", "1", "Should we remove the clip above the motel on c2m1?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
        remove_swan_clip = CreateConVar("remove_swan_clip", "1", "Should we remove the clip above the swan room shelf on c2m3?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
        remove_plantation_clip = CreateConVar("remove_plantation_clip", "1", "Should we remove the clip inside the plantation on c3m4?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
        RegAdminCmd("sm_disableallclips", DisableAllClips_Cmd, ADMFLAG_BAN, "Removes all clips from the map. Possibly used for testing purposes.");
        RegAdminCmd("sm_enableallclips", EnableAllClips_Cmd, ADMFLAG_BAN, "Enables all clips on the map. Possibly used for testing purposes.");
}

public OnMapStart()
{
    decl String:mapname[64];
    GetCurrentMap(mapname, sizeof(mapname));
    if(StrEqual(mapname, "c2m1_highway") && GetConVarBool(remove_motel_clip))
    {
        DisableClips();
    }
    else if(StrEqual(mapname, "c2m3_coaster") && GetConVarBool(remove_swan_clip))
    {
        DisableClips();
    }
    else if(StrEqual(mapname, "c3m4_plantation") && GetConVarBool(remove_plantation_clip))
    {
        DisableClips();
    }
}

public DisableClips()
{
    ModifyEntity("env_player_blocker", "Disable");
}

public Action:DisableAllClips_Cmd(client, args)
{
    ModifyEntity("env_player_blocker", "Disable");
    ModifyEntity("env_physics_blocker", "Disable");
    PrintToChatAll("All clips have been disabled.");
}

public Action:EnableAllClips_Cmd(client, args)
{
    ModifyEntity("env_player_blocker", "Enable");
    ModifyEntity("env_physics_blocker", "Enable");
    PrintToChatAll("All clips have been enabled.");
}

ModifyEntity(String:className[], String:inputName[])
{ 
    new iEntity;

    while ( (iEntity = FindEntityByClassname(iEntity, className)) != -1 )
    {
        if ( !IsValidEdict(iEntity) || !IsValidEntity(iEntity) )
        {
            continue;
        }
        AcceptEntityInput(iEntity, inputName);
    }
}