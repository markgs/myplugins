#pragma semicolon 1

#include <sourcemod>

new Float:Timer = 0.0;
new bool:TimerRunning = false;

public Plugin:myinfo = 
{
    name = "Vroom Timer",
    author = "Jacob",
    description = "A timer.",
    version = "0.1",
    url = "github.com/jacob404/myplugins"
}

public OnPluginStart()
{
    RegConsoleCmd("sm_starttimer", Command_Timer);
    RegConsoleCmd("sm_timer", Command_Timer);
    RegConsoleCmd("sm_21g", Command_Timer);
    RegConsoleCmd("sm_vroom", Command_Timer);
}

public Action:Command_Timer(client, args)
{
    if(!TimerRunning)
    {
        RunTimer();
        TimerRunning = true;
    }
    else
    {
        PrintToChatAll("%d seconds have passed.", Timer);
        TimerRunning = false;
        Timer = 0.0;
    }	
}

public RunTimer()
{
    if(TimerRunning)
	{
        CreateTimer(0.5, IncrementNumber);
    }
}

public Action:IncrementNumber(Handle:timer, any:client)
{
    Timer + 0.5;
    RunTimer();
}