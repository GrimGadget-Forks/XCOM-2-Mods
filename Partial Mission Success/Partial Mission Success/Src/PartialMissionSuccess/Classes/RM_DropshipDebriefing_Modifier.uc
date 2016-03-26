// This is an Unreal Script
class RM_DropshipDebriefing_Modifier extends UIDropShipBriefing_MissionEnd;

// Constructor
simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local string MissionResult;
	local XComGameState_BattleData BattleData;
	local GeneratedMissionData GeneratedMission;

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	GeneratedMission = class'UIUtilities_Strategy'.static.GetXComHQ().GetGeneratedMissionData(BattleData.m_iMissionID);
	super.InitScreen(InitController, InitMovie, InitName);

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));	

	if( BattleData.bLocalPlayerWon && !BattleData.bMissionAborted )
	{
		MissionResult = class'UIUtilities_Text'.static.GetColoredText(class'UIMissionSummary'.default.m_strMissionComplete, eUIState_Good);
	}

	else if (BattleData.OneStrategyObjectiveCompleted())
	{
		MissionResult = class'UIUtilities_Text'.static.GetColoredText(class'RM_UIMissionSummary_Modifier'.default.RM_PartialSuccess, eUIState_Warning);
	}
	else if( BattleData.bMissionAborted )
	{
		MissionResult = class'UIUtilities_Text'.static.GetColoredText(class'UIMissionSummary'.default.m_strMissionAbandoned, eUIState_Bad);
	}
	else if( !BattleData.bLocalPlayerWon )
	{
		MissionResult = class'UIUtilities_Text'.static.GetColoredText(class'UIMissionSummary'.default.m_strMissionFailed, eUIState_Bad);
	}

}
