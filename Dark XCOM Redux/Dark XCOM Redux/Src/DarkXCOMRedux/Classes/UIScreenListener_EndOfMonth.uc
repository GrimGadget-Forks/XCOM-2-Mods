class UIScreenListener_EndOfMonth extends UIScreenListener config(DarkXCom);

var config int ActivationMonth; //when does the MOCX Initative come online?

event OnInit(UIScreen Screen)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ, NewDarkXComHQ;
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersResistance ResistanceHQ;

    if(UIResistanceReport(screen) != none)
	{
		History = class'XComGameStateHistory'.static.GetGameStateHistory();
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Dark XCOM State Objects");
		DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	
		ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

		if(DarkXComHQ != none)
		{
			NewDarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.CreateStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
			NewGameState.AddStateObject(NewDarkXComHQ);
			NewDarkXComHQ.EndOfMonth(NewGameState, ResistanceHQ);
		}

		if(!NewDarkXComHQ.bIsActive && !NewDarkXComHQ.bIsDestroyed)
		{
			if(ResistanceHQ.NumMonths >= default.ActivationMonth) //0 - march, 1 - april, 2 - may
			{
				NewDarkXComHQ.bIsActive = true;
			}
		}


		//if(NewDarkXComHQ.bIsActive && class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('LW_T2_M0_Liberate_Region') && !NewDarkXComHQ.bChainStarted) // we kick off the mission chain
		//{
			//SpawnActivity(NewGameState);
			//NewDarkXComHQ.bChainStarted = true;
//
		//}
		//this is all handled through covert actions now

		if (NewGameState.GetNumGameStateObjects() > 0)
		{
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		}
		else
		{
			History.CleanupPendingGameState(NewGameState);
		}
	}

}



defaultproperties
{
	ScreenClass=none
}