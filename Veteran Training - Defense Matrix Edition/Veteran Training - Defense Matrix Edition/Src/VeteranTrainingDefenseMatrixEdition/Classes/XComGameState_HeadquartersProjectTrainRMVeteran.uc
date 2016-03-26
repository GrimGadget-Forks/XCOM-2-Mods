//---------------------------------------------------------------------------------------
//  FILE:    XComGameState_HeadquartersProjectTrainRMVeteran.uc
//  AUTHOR:  RealityMachina (using Long War Studio's Officer Pack as a base, and with code from BlueRaja's All Soldiers Gain XP mod)
//  PURPOSE: This object represents the instance data for an XCom HQ project for a Veteran training junior staff
//  This extends the TrainRookie project so specific hard-coded functions will recognize the training project per Amineri's comments in the LW Officer Pack
//---------------------------------------------------------------------------------------
class XComGameState_HeadquartersProjectTrainRMVeteran extends XComGameState_HeadquartersProjectTrainRookie config (RM_VeteranSlot);

var config float VeteranXPMultipier;
var config bool WoundedAndTrainingUnitsGainXP;
var config bool RookiesGainXP;
var config bool VeteransGainXP;
var config bool UnitsCanLevelUpOutsideOfMission;
var config int MentorTrainingVariable;
var config bool RanksAdjustTime;
var config int MaxTraineeLimit;
var config int StaticTrainingTime;

//---------------------------------------------------------------------------------------
// Call when you start a new project, NewGameState should be none if not coming from tactical
function SetProjectFocus(StateObjectReference FocusRef, optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
	local XComGameStateHistory History;
	local XComGameState_GameTime TimeState;
	local XComGameState_Unit UnitState;

	History = `XCOMHISTORY;
	ProjectFocus = FocusRef; // Unit
	AuxilaryReference = AuxRef; // Facility
	
	ProjectPointsRemaining = CalculatePointsToTrain();
	InitialProjectPoints = ProjectPointsRemaining;

	UnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ProjectFocus.ObjectID));
	//UnitState.PsiTrainingRankReset();
	UnitState.SetStatus(eStatus_Training);

	UpdateWorkPerHour(NewGameState);
	TimeState = XComGameState_GameTime(History.GetSingleGameStateObjectForClass(class'XComGameState_GameTime'));
	StartDateTime = TimeState.CurrentTime;

	if (`STRATEGYRULES != none)
	{
		if (class'X2StrategyGameRulesetDataStructures'.static.LessThan(TimeState.CurrentTime, `STRATEGYRULES.GameTime))
		{
			StartDateTime = `STRATEGYRULES.GameTime;
		}
	}
	
	if (MakingProgress())
	{
		SetProjectedCompletionDateTime(StartDateTime);
	}
	else
	{
		// Set completion time to unreachable future
		CompletionDateTime.m_iYear = 9999;
	}
}

//---------------------------------------------------------------------------------------
function int CalculatePointsToTrain()
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Unit Unit; //the veteran so we can get their arnk
	local int soldierRank; //their rank converted into a number we can use for some maths



	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ProjectFocus.ObjectID));



		if(Unit.GetRank() == 0) //if I decide to remove the check, using a rookie to lead patrols will be its own punishment
		{
			soldierRank = 0;
		}


		if(Unit.GetRank() == 1) //there is probably a more automatic way to do this, but this shouldn't affect the game too much
		{
			soldierRank = 1;
		}


		if(Unit.GetRank() == 2) //there is probably a more automatic way to do this, but this shouldn't affect the game too much
		{
			soldierRank = 2;
		}

		if(Unit.GetRank() == 3) //there is probably a more automatic way to do this, but this shouldn't affect the game too much
		{
			soldierRank = 3;
		}

		if(Unit.GetRank() == 4) 
		{
			soldierRank = 4;
		}

		if(Unit.GetRank() == 5) 
		{
			soldierRank = 5;
		}

		if(Unit.GetRank() == 6) 
		{
			soldierRank = 6;
		}

		if(Unit.GetRank() == 7) 
		{
			soldierRank = 7;
		}

		if(!RanksAdjustTime)
		{
			soldierRank = StaticTrainingTime;
		}

	return (XComHQ.GetTrainRookieDays() * 48 * MentorTrainingVariable ) / soldierRank;
}

//---------------------------------------------------------------------------------------
function int CalculateWorkPerHour(optional XComGameState StartState = none, optional bool bAssumeActive = false)
{
	return 1;
}

//---------------------------------------------------------------------------------------
// Remove the project
function OnProjectCompleted()
{
	local XComGameStateHistory History;
	local XComHeadquartersCheatManager CheatMgr;
	local XComGameState_HeadquartersXCom XComHQ, NewXComHQ;
	local XComGameState_Unit Unit; //the veteran who was teaching everyone
	local XComGameState_Unit UpdatedUnit; //the veteran who is done teaching everyone
	local XComGameState UpdateState;
	local XComGameStateContext_ChangeContainer ChangeContainer;
	local XComGameState_HeadquartersProjectTrainRMVeteran ProjectState;
	local XComGameState_StaffSlot StaffSlotState;
	local int ranksKills; //we want the game to add the veteran's ranks to everybody else's kills for XP purposes
	local int soldierRank; // we want the game to give us said veteran's rank in a number it can use for maths
	local XComGameState_Unit otherUnit; //the everybody else in question
	//local XComGameState_Unit VeteranUnit; //
	local array<XComGameState_Unit> allUnits;
	local X2AbilityTemplate AbilityTemplate;	
	local X2AbilityTemplateManager AbilityTemplateMan;
	//local XComGameState_Ability AbilityState; 
	local SoldierClassAbilityType Ability;
	local ClassAgnosticAbility MentorAbility;

	AbilityTemplateMan = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate('MentorConfidence');

	Ability.AbilityName = AbilityTemplate.DataName;
	Ability.ApplyToWeaponSlot = eInvSlot_Unknown;
	Ability.UtilityCat = '';
	MentorAbility.AbilityType = Ability;
	MentorAbility.iRank = 0;
	MentorAbility.bUnlocked = true;  //Eventually when I figure out how to do abilities, I want to give mentors a will buff for time spent

	History = `XCOMHISTORY;
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ProjectFocus.ObjectID));


	ChangeContainer = class'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("Veteran Training Complete");
	UpdateState = History.CreateNewGameState(true, ChangeContainer);
	UpdatedUnit = XComGameState_Unit(UpdateState.CreateStateObject(class'XComGameState_Unit', Unit.ObjectID));

	
	//AbilityState = AbilityTemplate.CreateInstanceFromTemplate(NewXComHQ);
	//AbilityState.InitAbilityForUnit(UpdatedUnit, NewXComHQ);
	//NewXComHQ.AddStateObject(AbilityState);
	//UpdatedUnit.AWCAbilities.AddItem(AbilityTemplate());
	//NewXComHQ.AddStateObject(UpdatedUnit);

	//OfficerState.SetRankTraining(-1, '');
	UpdatedUnit.AWCAbilities.AddItem(MentorAbility);
	UpdatedUnit.SetStatus(eStatus_Active);

	//ProjectState = XComGameState_HeadquartersProjectTrainLWOfficer(`XCOMHISTORY.GetGameStateForObjectID(ProjectRef.ObjectID));
	ProjectState = XComGameState_HeadquartersProjectTrainRMVeteran(`XCOMHISTORY.GetGameStateForObjectID(GetReference().ObjectID));
	if (ProjectState != none)
	{
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		if (XComHQ != none)
		{
			NewXComHQ = XComGameState_HeadquartersXCom(UpdateState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
			UpdateState.AddStateObject(NewXComHQ);
			NewXComHQ.Projects.RemoveItem(ProjectState.GetReference());
			UpdateState.RemoveStateObject(ProjectState.ObjectID);
		}


		// Remove the soldier from the staff slot
		StaffSlotState = UpdatedUnit.GetStaffSlot();
		if (StaffSlotState != none)
		{
			StaffSlotState.EmptySlot(UpdateState);
		}
	}

	UpdateState.AddStateObject(UpdatedUnit);
	UpdateState.AddStateObject(ProjectState);
	`GAMERULES.SubmitGameState(UpdateState);

	CheatMgr = XComHeadquartersCheatManager(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().CheatManager);
	if (CheatMgr == none || !CheatMgr.bGamesComDemo)
	{
		UITrainingComplete(ProjectFocus);
	}



		if(VeteranXPMultipier <= 0)
		{
			return;
		}

		
		if(Unit.GetRank() == 0) //if I decide to remove the check, using a rookie to lead patrols will be its own punishment
		{
			soldierRank = 0;
		}

		if(Unit.GetRank() == 1) //there is probably a more automatic way to do this, but this shouldn't affect the game too much
		{
			soldierRank = 1;
		}


		if(Unit.GetRank() == 2) //there is probably a more automatic way to do this, but this shouldn't affect the game too much
		{
			soldierRank = 2;
		}

		if(Unit.GetRank() == 3) //there is probably a more automatic way to do this, but this shouldn't affect the game too much
		{
			soldierRank = 3;
		}

		if(Unit.GetRank() == 4) 
		{
			soldierRank = 4;
		}

		if(Unit.GetRank() == 5) 
		{
			soldierRank = 5;
		}

		if(Unit.GetRank() == 6) 
		{
			soldierRank = 6;
		}

		if(Unit.GetRank() == 7) 
		{
			soldierRank = 7;
		}
		//VeteranUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ProjectFocus.ObjectID));

		ranksKills = int(VeteranXPMultipier * soldierRank);


		allUnits = GetAllUnits();
		foreach allUnits(otherUnit)
		{
			if(ShouldGainPassiveXP(otherUnit))
			{
				GainKills(otherUnit, GetNumKills(ranksKills));
			}
		}

}


	function array<XComGameState_Unit> GetAllUnits()
	{
		local int i;
		local XComGameState_Unit otherunit;
		local array<XComGameState_Unit> unitList;

		for(i = 0; i < `XCOMHQ.Crew.Length; i++)
		{
			otherUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(`XCOMHQ.Crew[i].ObjectID));

			if(otherUnit.IsASoldier() && otherUnit.IsAlive())
			{
				unitList.AddItem(otherUnit);
			}
		}

		return unitList;
	}

	function bool IsOnMission(XComGameState_Unit otherUnit) //this tells us if they were on a mission at time of completion
	{
		return otherUnit.GetHQLocation() == eSoldierLoc_Dropship;
	}

	function bool IsIdle(XComGameState_Unit otherUnit) //and this checks for units who aren't busy doing anything if we're disallowing wounded and training soldierrs
	{
		return otherUnit.GetStatus() == eStatus_Active;
	}

	function bool ShouldGainPassiveXP(XComGameState_Unit otherUnit)
	{
		if(!otherUnit.IsSoldier() || otherUnit.IsDead()) //dead people shouldn't be giving XP
			return false;
		if(IsOnMission(otherUnit))
			return false; //weren't around to be taught
		if(otherUnit.GetRank() == 0 && !RookiesGainXP) //disallowing rookies if someone's not using a Commander's Choice mod for example
			return false;
		if(otherUnit.GetRank() >= MaxTraineeLimit && !VeteransGainXP) 
			return false; //Sergeants and beyond need to be on missions by default

		return WoundedAndTrainingUnitsGainXP || IsIdle(otherUnit);
	}

	function int GetNumKills(int ranksKills)
	{
		local int numKillsToAdd, i;

		for(i = 0; i < ranksKills; i++)
		{
			//Can't directly give out XP, need to "fake it" by giving out kills instead. 

				numKillsToAdd = ranksKills;
		}
		return numKillsToAdd;
	}

	function GainKills(XComGameState_Unit otherUnit, int numKills)
	{
		//Mostly adapted from XComGameState_Unit.OnUnitDied()
		local int i;
		local XComGameState NewGameState;
		local XComGameState_Unit killAssistant;

		if(numKills <= 0) //this shouldn't happen in the new context, but I see no harm in leaving this "impossible" case in
		{
			return;
		}

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("End of mission KillAssists");
		KillAssistant = XComGameState_Unit(NewGameState.CreateStateObject(otherUnit.Class, otherUnit.ObjectID));
		KillAssistant.bRankedUp = false; //Hack - for some reason this value is set to true, causing CanRankUpSoldier() to return false

		for(i = 0; i < numKills; i++)
		{
			KillAssistant.SimGetKill(otherUnit.GetReference()); //Parameter here doesn't really matter
		}

		if (ShouldLevelUpSoldier(KillAssistant)) // check whether we can rank them up after training
		{
			LevelUpSoldier(KillAssistant, NewGameState); 
		}

		NewGameState.AddStateObject(KillAssistant);
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}

	function bool ShouldLevelUpSoldier(XComGameState_Unit otherUnit)
	{
		return UnitsCanLevelUpOutsideOfMission && otherUnit.CanRankUpSoldier();
	}

	function LevelUpSoldier(XComGameState_Unit unit, XComGameState newGameState)
	{
		unit.SetUnitFloatValue('RankUpMessage', 1, eCleanup_BeginTactical); //Not sure what this does or if it's necessary :3

		if(unit.GetRank() == 0)
		{
			//Have to apply class and change weapons when soldier is getting [noob]PROMOTED![/noob] from rookie to squaddie
			unit.RankUpSoldier(newGameState, `XCOMHQ.SelectNextSoldierClass());
			unit.ApplySquaddieLoadout(newGameState);
			unit.ApplyBestGearLoadout(newGameState);
		}
		else
		{
			unit.RankUpSoldier(newGameState, unit.GetSoldierClassTemplate().DataName);  //otherwise they can just get a plain' ol PROMOTED! without needing to meddle with stuff
		}
	}




function UITrainingComplete(StateObjectReference UnitRef)
{
	local UIAlert_RMVeteranTrainingComplete Alert;
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPres;

	Alert = HQPres.Spawn(class'UIAlert_RMVeteranTrainingComplete', HQPres);
	Alert.eAlert = eAlert_TrainingComplete;
	Alert.UnitInfo.UnitRef = UnitRef;
	Alert.fnCallback = TrainingCompleteCB;
	Alert.SoundToPlay = "Geoscape_CrewMemberLevelledUp";
	HQPres.ScreenStack.Push(Alert);




}

simulated function TrainingCompleteCB(EUIAction eAction, UIAlert AlertData, optional bool bInstanta = false)
{
	//local XComGameState NewGameState; 
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPres;
	
	//NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Unit Promotion");
	//`XEVENTMGR.TriggerEvent('UnitPromoted', , , NewGameState);
	//`GAMERULES.SubmitGameState(NewGameState);

	if (!HQPres.m_kAvengerHUD.Movie.Stack.HasInstanceOf(class'UIArmory_MainMenu')) // If we are already observing the soldier that was trained, just close the popup
	{
		if (eAction == eUIAction_Accept)
		{
			GoToArmoryRMVeteran(AlertData.UnitInfo.UnitRef, true);
		}
		else
		{
			`GAME.GetGeoscape().Resume();
		}
	}
}

simulated function GoToArmoryRMVeteran(StateObjectReference UnitRef, optional bool bInstantb = false)
{
	//local XComGameState_HeadquartersXCom XComHQ;
	//local XComGameState_FacilityXCom ArmoryState;
	//local UIArmory_MainMenu VeteranScreen;
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPres;
	
	if (`GAME.GetGeoscape().IsScanning())
		HQPres.StrategyMap2D.ToggleScan();

	//call Armory_MainMenu to populate pawn data
	if(HQPres.ScreenStack.IsNotInStack(class'UIArmory_MainMenu'))
		UIArmory_MainMenu(HQPres.ScreenStack.Push(HQPres.Spawn(class'UIArmory_MainMenu', HQPres), HQPres.Get3DMovie())).InitArmory(UnitRef,,,,,, bInstant);


	//VeteranScreen = UIArmory_MainMenu (HQPres.ScreenStack.Push(HQPres.Spawn(class'UIArmory_MainMenu', HQPres), HQPres.Get3DMovie()));
}

//---------------------------------------------------------------------------------------
DefaultProperties
{
}
