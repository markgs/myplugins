#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

new Handle:remove_motel_clip;

public Plugin:myinfo = 
{
    name = "Clip Removal",
    author = "Jacob",
    description = "Allows for removal of some pesky clips.",
    version = "0.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
        remove_motel_clip = CreateConVar("remove_motel_clip", "1", "Should we remove the clip above the motel on c2m1?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
}

public OnMapStart()
{
    decl String:mapname[64];
    GetCurrentMap(mapname, sizeof(mapname));
    if(StrEqual(mapname, "c2m1_highway") && GetConVarBool(remove_motel_clip))
	{
	Motel();
	}
}

public Motel()
{
    ModifyEntity("env_player_blocker", "Disable");
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