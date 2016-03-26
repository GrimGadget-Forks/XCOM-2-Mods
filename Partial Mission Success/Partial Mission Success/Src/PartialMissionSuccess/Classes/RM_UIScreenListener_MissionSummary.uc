class RM_UIScreenListener_MissionSummary extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	//local XComGameStateHistory History;
	//local XComGameState_BattleData BattleData;
	//local XComGameState_HeadquartersXCom XComHQ;
	//local XComGameState_Unit UnitState;
	//local bool bCasualties, bVictory;
	//local int idx;

	//History = `XCOMHISTORY;
	//BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData', true));
	//XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	//bCasualties = false;


	//PlaySoundEvent('StrategyScreen', 'PostMissionFlow_Pass')



}
defaultProperties
{
    ScreenClass = UIMissionSummary
}