#undef REQUIRE_PLUGIN
#include <sourceirc>

#define PLUGIN_VERSION "1.1.0"

new Handle:kv_translations = INVALID_HANDLE;
new Handle:v_Debug = INVALID_HANDLE;
new Handle:v_Timestamp = INVALID_HANDLE;
new Handle:v_Timeoffset = INVALID_HANDLE;


public Plugin:myinfo = {
	name = "[Any] SourceIRC -> Achievement Relay",
	author = "DarthNinja",
	description = "Relays achievements",
	version = PLUGIN_VERSION,
	url = "DarthNinja.com"
};

public OnPluginStart()
{
	CreateConVar("sm_achievementrelay_version", PLUGIN_VERSION, "Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	v_Debug = CreateConVar("sm_achrelay_debug", "0", "Enable/Disable debug mode", 0, true, 0.0, true, 1.0);
	v_Timestamp = CreateConVar("sm_achrelay_timestamp", "1", "Show/Hide server timestamps of when an achievement is unlocked", 0, true, 0.0, true, 1.0);
	v_Timeoffset = CreateConVar("sm_achrelay_timeoffset", "0", "Seconds to change timestamp by");

	RegAdminCmd("sm_reload_achievement_relay", ReloadCFGs, ADMFLAG_ROOT);

	LoadTranslations("common.phrases");
	LoadTranslations("plugin.basecommands");

	HookEvent("achievement_earned", OnAchievementUnlocked);

	LoadConfigs()

	IRC_MsgFlaggedChannels("achievements", "Achievement relay version %s online!", PLUGIN_VERSION);
}

public Action:ReloadCFGs(client, args)
{
	LoadConfigs()

	ReplyToCommand(client, "Achievement Relay: Reloaded Configs");
	return Plugin_Handled;
}

LoadConfigs()
{
	decl String:path[512];
	BuildPath(Path_SM, path, sizeof(path), "configs/achievements.kv");
	kv_translations = CreateKeyValues("items");
	if (!FileToKeyValues(kv_translations, path))
	{
		SetFailState("Error: achievement data not found or cannot be read (File: configs/achievements.kv)");
	}
	AutoExecConfig(true, "AchievementRelay");
}

public OnAllPluginsLoaded()
{
	if (LibraryExists("sourceirc"))
	{
		IRC_Loaded();
	}
}

public OnLibraryAdded(const String:name[])
{
	if (StrEqual(name, "sourceirc", false))
	{
		IRC_Loaded();
	}
}

IRC_Loaded()
{
	IRC_CleanUp();
}

public Action:OnAchievementUnlocked(Handle:hEvent, const String:strName[], bool:bDontBroadcast)
{
	if (GetEventBool(hEvent, "isfake"))	//achievement is fake
		return;

	new client = GetEventInt(hEvent, "player");

	decl String:ircMessage[IRC_MAXLEN];
	decl String:message[256];
	ircMessage[0] = '\0';

	new iIndex = GetEventInt(hEvent, "achievement");

	new team = -1;
	if (client != 0)
		team = IRC_GetTeamColor(GetClientTeam(client));
	if (team == -1)
		Format(message, sizeof(message), "\x03[\x0300 %N \x03\x03]: ", client);
	else
		Format(message, sizeof(message), "\x03[\x03%02d %N \x03]: ", team, client);
	StrCat(ircMessage, sizeof(ircMessage), message);

	/*
	##############
	# IRC Colors #
	##############

	\x03 = Color Char
	%02d = Color
	0 = White
	1 = Black
	2 = Dark Blue
	3 = Dark Green
	4 = Red
	5 = Dark Red
	6 = Purple
	7 = Orange
	8 = Yellow
	9 = Bright Green
	10 = Gray-Blue
	11 = Sky Blue
	12 = Mid Blue
	13 = Pink
	14 = Gray
	15 = White-Grey

	*/

	// name processing
	decl String:tfEnglishName[256];
	decl String:tfEnglishDesc[256];
	decl String:Index[10];
	
	Format(Index, sizeof(Index), "%i", iIndex);
	if (KvJumpToKey(kv_translations, Index))	// Jump from items to the ach index
	{
		if (KvGotoFirstSubKey(kv_translations, false))
		{
			KvGetString(kv_translations, NULL_STRING, tfEnglishName, sizeof(tfEnglishName), "Unknown Achievement Name");
			if (KvGotoNextKey(kv_translations, false))
				KvGetString(kv_translations, NULL_STRING, tfEnglishDesc, sizeof(tfEnglishDesc), "Unknown Achievement Description");
			else
				Format(tfEnglishDesc, sizeof(tfEnglishDesc), "Unknown Achievement Description");
		}
		else
			Format(tfEnglishName, sizeof(tfEnglishName), "Unknown Achievement Name");
		KvGoBack(kv_translations);
		KvGoBack(kv_translations);
	}
	else	// no key found for that index
		Format(tfEnglishName, sizeof(tfEnglishName), "Unknown Achievement");

	// End name processing

	Format(message, sizeof(message), "\x03has earned the achievement \x03%02d[%s]\x03  (%s)", 3, tfEnglishName, tfEnglishDesc);

	//Add item details
	StrCat(ircMessage, sizeof(ircMessage), message);

	if (GetConVarBool(v_Debug))
	{
		Format(message, sizeof(message), "\x03  Debug index: %s", Index);
		StrCat(ircMessage, sizeof(ircMessage), message);
	}

	if (GetConVarBool(v_Timestamp))
	{
		FormatTime(message, sizeof(message), " %x - %X", GetTime()+GetConVarInt(v_Timeoffset))
		StrCat(ircMessage, sizeof(ircMessage), message);
	}

	//----

	IRC_MsgFlaggedChannels("items", ircMessage);
}

public OnPluginEnd()
{
	IRC_CleanUp();
	CloseHandle(kv_translations);
}
