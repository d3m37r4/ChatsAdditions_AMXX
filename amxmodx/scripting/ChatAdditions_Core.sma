#include <amxmodx>
#include <reapi>

#include <ChatAdditions>


#pragma semicolon 1
#pragma ctrlchar '\'

new const LOG_DIR_NAME[] = "CA_Core";
new g_sLogsFile[PLATFORM_MAX_PATH];

new ca_log_type;

new g_pFwd_Client_Say,
	g_pFwd_Client_SayTeam,
	g_pFwd_Client_Voice;

public plugin_precache()
{
	register_plugin(
		.plugin_name	= "Chat Additions Core",
		.version		= "1.0.0-beta",
		.author			= "Sergey Shorokhov"
	);

	bind_pcvar_num(create_cvar("ca_log_type", "1"), ca_log_type);
	GetLogsFilePath(g_sLogsFile, .sDir = LOG_DIR_NAME);

	register_clcmd("say", "ClCmd_Hook_Say");
	register_clcmd("say_team", "ClCmd_Hook_SayTeam");
	RegisterHookChain(RG_CSGameRules_CanPlayerHearPlayer, "CSGameRules_CanPlayerHearPlayer", .post = false);

	g_pFwd_Client_Say = CreateMultiForward("CA_Client_Say", ET_STOP, FP_CELL);
	g_pFwd_Client_SayTeam = CreateMultiForward("CA_Client_SayTeam", ET_STOP, FP_CELL);
	g_pFwd_Client_Voice = CreateMultiForward("CA_Client_Voice", ET_STOP, FP_CELL, FP_CELL);

	CA_Log("Chat Additions Core initialized!")
}

public plugin_natives() {
	register_library("ChatAdditions_Core");
}

public ClCmd_Hook_Say(id) {
	static retVal;
	ExecuteForward(g_pFwd_Client_Say, retVal, id);

	return (retVal == CA_SUPERCEDE) ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}

public ClCmd_Hook_SayTeam(id) {
	static retVal;
	ExecuteForward(g_pFwd_Client_SayTeam, retVal, id);

	return (retVal == CA_SUPERCEDE) ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}

public CSGameRules_CanPlayerHearPlayer(const listener, const sender) {
	if(listener == sender)
		return HC_CONTINUE;

	static retVal;
	ExecuteForward(g_pFwd_Client_Voice, retVal, listener, sender);

	if(retVal == CA_SUPERCEDE) {
		SetHookChainReturn(ATYPE_BOOL, false);

		return HC_BREAK;
	}

	return HC_CONTINUE;
}