// This is an Unreal Script
class UIScreenListener_StrategyMap extends UIScreenListener config(DarkXCOM);


// This event is triggered after a screen receives focus
simulated function OnInit(UIScreen Screen)
{

}



// This event is triggered after a screen receives focus
simulated function OnReceiveFocus(UIScreen Screen)
{

}



simulated function OnRemoveFocus(UIScreen Screen)
{

}



//we need to make sure notoriety time gets updated once the player has moved time on the geoscape
event OnRemoved(UIScreen Screen)
{
	if(UIStrategyMap(Screen) != none)
	{
		ReassessRecoveryTime();

	}

	//if(UIMission(Screen) != none)
	//{
		//RollForSitreps();
	//}
}

//---------------------------------------------------------------------------------------
static function ReassessRecoveryTime()
{
	local XComGameStateHistory					History;
	local XComGameState_HeadquartersDarkXCom		DarkXComHQ;
	local XComGameState							NewGameState;
	local XComGameState_Unit					UnitState;
	local XComGameState_Unit_DarkXComInfo		InfoState, NewInfoState;
	local int									i;

	History = `XCOMHISTORY;
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Recovery Time Check.");
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.CreateStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
	NewGameState.AddStateObject(DarkXComHQ);

	for(i = 0; i < DarkXComHQ.Crew.Length; i++)
	{
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(DarkXComHQ.Crew[i].ObjectID));
		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(UnitState);

		if(UnitState != none && InfoState != none && InfoState.bIsAlive)
		{
			NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));
			NewGameState.AddStateObject(NewInfoState);

			if(NewInfoState.GetRecoveryPoints() > 0)
			{
				NewInfoState.AssessRecovery(); 
			}
		}
	}

	if( NewGameState.GetNumGameStateObjects() > 0 )
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
}


//---------------------------------------------------------------------------------------
defaultproperties
{
	//Just specifying the UI Screen to listen to...
	ScreenClass = none
}