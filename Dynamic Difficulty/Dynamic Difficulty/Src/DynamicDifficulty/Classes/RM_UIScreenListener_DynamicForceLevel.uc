// This is an Unreal Script
class RM_UIScreenListener_DynamicForceLevel extends UIScreenListener dependson(XComGameState_HeadquartersAlien) config (SuccessDifficulty);

var config int FlawlessChange;
var config int ExcellentChange;
var config int GoodChange;
var config int FairChange;
var config int PoorChange;
var config int AbortChange;

event OnInit(UIScreen Screen)
{
    local UIMissionSummary missionSummary;
    local int soldiersKilled, soldiersInjured, soldiersPercentageKilled, soldiersTotal;
    local int forceLevel, newForceLevel;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_BattleData BattleData;
	local XComGameState NewGameState;

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("MOD: Changing Force Level");


	forceLevel = AlienHQ.ForceLevel;

    missionSummary = UIMissionSummary(Screen);
    soldiersKilled = missionSummary.GetNumSoldiersKilled(soldiersTotal);
	soldiersInjured = missionSummary.GetNumSoldiersInjured(soldiersTotal);
	soldiersPercentageKilled = (soldiersKilled * 100) / soldiersTotal;


	if( BattleData.bMissionAborted)
	{
		newForceLevel = (forceLevel + AbortChange);
	}

	else if(soldiersKilled == 0 && soldiersInjured == 0)
	{
		newForceLevel = (forceLevel + FlawlessChange);
	}
	else if(soldiersKilled == 0)
	{
		newForceLevel = (forceLevel + ExcellentChange);
	}
	else if(soldiersPercentageKilled <= 34)
	{
		newForceLevel = (forceLevel + GoodChange);
	}
	else if(soldiersPercentageKilled <= 50)
	{
		newForceLevel = (forceLevel + FairChange);
	}
	else
	{
		newForceLevel = (forceLevel + PoorChange);
	}

	AlienHQ = XComGameState_HeadquartersAlien(NewGameState.CreateStateObject(class'XComGameState_HeadquartersAlien', AlienHQ.ObjectID));
	NewGameState.AddStateObject(AlienHQ);
	newForceLevel = Clamp(newForceLevel, AlienHQ.AlienHeadquarters_StartingForceLevel , AlienHQ.AlienHeadquarters_MaxForceLevel);
	AlienHQ.ForceLevel = newForceLevel;

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}


defaultProperties
{
    ScreenClass = UIMissionSummary
}