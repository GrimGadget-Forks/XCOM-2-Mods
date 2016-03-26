// This is an Unreal Script
class RM_UIMissionSummary_Modifier extends UIMissionSummary;

var localized string RM_PartialSuccess;

simulated function OnInit()
{
	local int MissionStatus;
	local string MissionResult, MPOPName;
	local X2MissionTemplate MissionTemplate;
	local GeneratedMissionData GeneratedMission;
	local int iKilled, iTotal;

	super.OnInit();

	GeneratedMission = class'UIUtilities_Strategy'.static.GetXComHQ().GetGeneratedMissionData(BattleData.m_iMissionID);
	MissionTemplate = class'X2MissionTemplateManager'.static.GetMissionTemplateManager().FindMissionTemplate(GeneratedMission.Mission.MissionName);

	if( BattleData.bLocalPlayerWon && !BattleData.bMissionAborted )
	{
		MissionResult = class'UIUtilities_Text'.static.GetColoredText(m_strMissionComplete, eUIState_Good);
		MissionStatus = MISSION_SUCCESS;
	}

	else if (BattleData.OneStrategyObjectiveCompleted())
	{
		MissionResult = class'UIUtilities_Text'.static.GetColoredText(RM_PartialSuccess, eUIState_Warning);
		MissionStatus = MISSION_SUCCESS;
	}
	else if( BattleData.bMissionAborted)
	{
		MissionResult = class'UIUtilities_Text'.static.GetColoredText(m_strMissionAbandoned, eUIState_Bad);
		MissionStatus = MISSION_FAILURE;
	}
	else if( !BattleData.bLocalPlayerWon )
	{
		MissionResult = class'UIUtilities_Text'.static.GetColoredText(m_strMissionFailed, eUIState_Bad);
		MissionStatus = MISSION_FAILURE;
	}

	iKilled = GetNumEnemiesKilled(iTotal);

	if(BattleData.IsMultiplayer())
	{
		//OP name was using the hosts language, we need to translate here
		if(BattleData.bRanked )
		{
			MPOPName = class'XComMultiplayerUI'.default.m_aMainMenuOptionStrings[eMPMainMenu_Ranked];
		}
		else if(BattleData.bAutomatch)
		{
			MPOPName = class'XComMultiplayerUI'.default.m_aMainMenuOptionStrings[eMPMainMenu_QuickMatch];
		}
		else
		{
			MPOPName = class'XComMultiplayerUI'.default.m_aMainMenuOptionStrings[eMPMainMenu_CustomMatch];
		}

		SetMissionInfo(
			MissionStatus,
			MissionResult,
			MPOPName,
			GetMaxPointsLabel(),
			GetMaxPointsValue(),
			GetTurnTimeLabel(),
			GetTurnTimeValue(),
			"",
			"",
			"",
			"",
			m_strEnemiesKilledLabel,
			GetEnemiesKilled(),
			m_strSoldiersWoundedLabel,
			GetSoldiersInjured(),
			m_strSoldiersKilledLabel,
			GetSoldiersKilled(),
			m_strRatingLabel,
			GetMissionRating(),
			iKilled,
			iTotal);
	}
	else
	{
		SetMissionInfo(
			MissionStatus,
			MissionResult,
			BattleData.m_strOpName,
			m_strMissionTypeLabel,
			MissionTemplate.PostMissionType,
			GetObjectiveLabel(),
			GetObjectiveValue(),
			GetTurnsLabel(),
			GetTurnsValue(),
			"",
			"",
			m_strEnemiesKilledLabel,
			GetEnemiesKilled(),
			m_strSoldiersWoundedLabel,
			GetSoldiersInjured(),
			m_strSoldiersKilledLabel,
			GetSoldiersKilled(),
			m_strRatingLabel,
			GetMissionRating(),
			iKilled,
			iTotal);
	}
}
