class XComGameState_HeadquartersProjectPsiTrainRMVeteran extends  XComGameState_HeadquartersProjectPsiTraining  config (PartiallyGifted);

//var int iAbilityRank;	// the rank of the ability the psi operative will learn upon completing the project
//var int iAbilityBranch; // the branch of the ability the psi operative will learn upon completing the project

var int newAbilityRank;
var int newAbilityBranch;

//var bool bForcePaused;

var config bool OneAbilityOnly;
var config int NumOfTrainingDays;
var config bool WillBasedSuccess;

var config int WillCheck;

//---------------------------------------------------------------------------------------
function SetProjectFocus(StateObjectReference FocusRef, optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
	local XComGameStateHistory History;
	local XComGameState_GameTime TimeState;
	local XComGameState_Unit UnitState;
	local X2SoldierClassTemplate PsiTemplate;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Ability AbilityState;
	local ClassAgnosticAbility ClassAgnosticAbility;
	local name AbilityName;
	local int Rank, i;



	History = `XCOMHISTORY;
	ProjectFocus = FocusRef; // Unit
	AuxilaryReference = AuxRef; // Facility


	// Randomly choose a branch and ability
	//iAbilityRank = `SYNC_RAND(7);
	//iAbilityBranch = `SYNC_RAND(2);

	Rank = `SYNC_RAND(90);

	UnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ProjectFocus.ObjectID));


	if (UnitState.GetSoldierClassTemplateName() != 'PsiOperative')
	{

		if(Rank <= 10)
		{
		iAbilityRank = 0;
		iAbilityBranch = 1;	
		}

		if(Rank <= 20 && Rank > 10)
		{
		iAbilityRank = 1;
		iAbilityBranch = 1;
		}

		if(Rank <= 30 && Rank > 20)
		{
		iAbilityRank = 1;
		iAbilityBranch = 0;
		}

		if(Rank <= 40 && Rank > 30)
		{
		iAbilityRank = 3;
		iAbilityBranch = 1;
		}

		if(Rank <= 50 && Rank > 40)
		{
		iAbilityRank = 3;
		iAbilityBranch = 0;
		}

		if(Rank <= 60 && Rank > 50)
		{
		iAbilityRank = 4;
		iAbilityBranch = 1;
		}

		if(Rank <= 70 && Rank > 60)
		{
		iAbilityRank = 5;
		iAbilityBranch = 0;
		}

		if(Rank <= 80 && Rank > 70 && !OneAbilityOnly)
		{
		iAbilityRank = 2;
		iAbilityBranch = 1;
		}
		if(Rank <= 90 && Rank > 80 && !OneAbilityOnly)
		{
		iAbilityRank = 4;
		iAbilityBranch = 0;
		}
		
	}
	else
	{
	iAbilityRank = 3;
	iAbilityBranch = 1;
	
	}

	PsiTemplate = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager().FindSoldierClassTemplate('PsiOperative');
	AbilityName = PsiTemplate.GetAbilityName(iAbilityRank, iAbilityBranch);
	AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AbilityName);



	for(i = 0; i < UnitState.AWCAbilities.Length; ++i)
	{
		`Log("Checking your stuff...");
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(ProjectFocus.ObjectID));
		if(UnitState.HasSoldierAbility(AbilityName)) //if we find that the soldier already has the initially selected ability...
		{
			`Log("Hey, you already have this one! >:(");
			do
			{
				`Log("Looping around the world");
				Rank = `SYNC_RAND(90); //loop until the ability they're supposed to have isn't a repeat
						if(Rank <= 10)
						{
						iAbilityRank = 0;
						iAbilityBranch = 1;
						}

						if(Rank <= 20 && Rank > 10)
						{
						iAbilityRank = 1;
						iAbilityBranch = 1;
						}

						if(Rank <= 30 && Rank > 20)
						{
						iAbilityRank = 1;
						iAbilityBranch = 1;
						}

						if(Rank <= 40 && Rank > 30)
						{
						iAbilityRank = 3;
						iAbilityBranch = 1;
						}

						if(Rank <= 50 && Rank > 40)
						{
						iAbilityRank = 3;
						iAbilityBranch = 0;
						}

						if(Rank <= 60 && Rank > 50)
						{
						iAbilityRank = 4;
						iAbilityBranch = 1;
						}

						if(Rank <= 70 && Rank > 60)
						{
						iAbilityRank = 5;
						iAbilityBranch = 0;
						}

						if(Rank <= 80 && Rank > 70 && !OneAbilityOnly)
						{
						iAbilityRank = 2;
						iAbilityBranch = 1;
						}
						if(Rank <= 90 && Rank > 80 && !OneAbilityOnly)
						{
						iAbilityRank = 4;
						iAbilityBranch = 0;
						}

					AbilityName = PsiTemplate.GetAbilityName(iAbilityRank, iAbilityBranch);
					AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AbilityName);


			} until (!UnitState.HasSoldierAbility(AbilityName));
		}

	}


	ProjectPointsRemaining = CalculatePointsToTrain();

	InitialProjectPoints = ProjectPointsRemaining;

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

	if(MakingProgress())
	{
		SetProjectedCompletionDateTime(StartDateTime);
	}
	else
	{
		// Set completion time to unreachable future
		CompletionDateTime.m_iYear = 9999;
	}
}
//-------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
function int CalculatePointsToTrain(optional bool bClassTraining = false)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	return NumOfTrainingDays * XComHQ.XComHeadquarters_DefaultPsiTrainingWorkPerHour * 24;
	
}

//---------------------------------------------------------------------------------------
function int CalculateWorkPerHour(optional XComGameState StartState = none, optional bool bAssumeActive = false)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local int iTotalWork;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	iTotalWork = XComHQ.PsiTrainingRate;

	// Can't make progress when paused
	if (bForcePaused && !bAssumeActive)
	{
		return 0;
	}

	return iTotalWork;
}

//---------------------------------------------------------------------------------------
function OnProjectCompleted()
{
	local XComGameState_Unit Unit, UpdatedUnit;
	local X2AbilityTemplate AbilityTemplate;
	local name AbilityName;
	local XComGameState_Unit_Psi	PsiState, 	NewPsiState;	
	local XComGameStateHistory					History;
	local XComGameState							UpdateState;
	local XComGameStateContext_ChangeContainer	ChangeContainer;
	local X2SoldierClassTemplate PsiTemplate;
	local SoldierClassAbilityType Ability;
	local ClassAgnosticAbility PsiAbility;
	local XComGameState_HeadquartersProjectPsiTrainRMVeteran ProjectState;
	local XComGameState_HeadquartersXCom XComHQ, NewXComHQ;
	local XComGameState_StaffSlot StaffSlotState;
	local int WillTest;

	WillTest = `SYNC_RAND(WillCheck);


	PsiTemplate = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager().FindSoldierClassTemplate('PsiOperative');
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ProjectFocus.ObjectID));
	AbilityName = PsiTemplate.GetAbilityName(iAbilityRank, iAbilityBranch);
	AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AbilityName);

	if(WillTest <= Unit.GetBaseStat(eStat_Will) || WillBasedSuccess == false ) //checks will or just lets it go through

	{

	Ability.AbilityName = AbilityTemplate.DataName;
	Ability.ApplyToWeaponSlot = eInvSlot_Unknown;
	Ability.UtilityCat = '';
	PsiAbility.AbilityType = Ability;
	PsiAbility.iRank = 0;
	PsiAbility.bUnlocked = true;  

	`HQPRES.UIPsiTrainingComplete(ProjectFocus, AbilityTemplate);

	History = `XCOMHISTORY;
	ChangeContainer = class'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("Adding psi");
	UpdateState = History.CreateNewGameState(true, ChangeContainer);

	PsiState = class'UnitPsiUtilties'.static.GetPsiComponent(Unit);

	UpdatedUnit = XComGameState_Unit(UpdateState.CreateStateObject(class'XComGameState_Unit', Unit.ObjectID));

	UpdatedUnit.AWCAbilities.AddItem(PsiAbility);
	UpdatedUnit.SetStatus(eStatus_Active);

	ProjectState = XComGameState_HeadquartersProjectPsiTrainRMVeteran(`XCOMHISTORY.GetGameStateForObjectID(GetReference().ObjectID));
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



		if(PsiState != none)
		{

			//Existing psi component detected. Adding training/finalizing trainined
			NewPsiState = XComGameState_Unit_Psi(UpdateState.CreateStateObject(class'XComGameState_Unit_Psi', PsiState.ObjectID));
		
			//Applying psi training...
			if(!OneAbilityOnly)
			{
			NewPsiState.ApplyTraining();
			UpdatedUnit.SetBaseMaxStat(eStat_PsiOffense, UpdatedUnit.GetBaseStat(eStat_PsiOffense) + 7);
			}

			else 
			{
			NewPsiState.FinalizeTraining();
			UpdatedUnit.SetBaseMaxStat(eStat_PsiOffense, 80); //this shouldn't be required since this is where they should get the psi component, but just in case we're making sure they have only 60 psi score
			}

			//Submitting updated gamestate...
			UpdateState.AddStateObject(NewPsiState);
			UpdateState.AddStateObject(UpdatedUnit);
			`GAMERULES.SubmitGameState(UpdateState);

		}

		else if(PsiState == none && !Unit.IsDead())
		{


		//No Psi object present, adding Psicomponent...
		UpdatedUnit = XComGameState_Unit(UpdateState.CreateStateObject(class'XComGameState_Unit', Unit.ObjectID));
		PsiState = XComGameState_Unit_Psi(UpdateState.CreateStateObject(class'XComGameState_Unit_Psi'));
		PsiState.InitComponent();

		//Applying psi training
			if(!OneAbilityOnly)
			{
			PsiState.ApplyTraining();
			UpdatedUnit.SetBaseMaxStat(eStat_PsiOffense, 40);
			}

			else 
			{
			PsiState.FinalizeTraining();
			UpdatedUnit.SetBaseMaxStat(eStat_PsiOffense, 80);
			}
		UpdatedUnit.AddComponentObject(PsiState);

		//Submitting updated gamestate...
		UpdateState.AddStateObject(UpdatedUnit);
		UpdateState.AddStateObject(PsiState);
		`GAMERULES.SubmitGameState(UpdateState);
		}

	}


	else if (WillTest > Unit.GetBaseStat(eStat_Will)) //no psi for you
	{
	History = `XCOMHISTORY;
	ChangeContainer = class'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("soldier failed to get psi");
	UpdateState = History.CreateNewGameState(true, ChangeContainer);

	
	UpdatedUnit = XComGameState_Unit(UpdateState.CreateStateObject(class'XComGameState_Unit', Unit.ObjectID));
	UpdatedUnit.SetStatus(eStatus_Active);


	ProjectState = XComGameState_HeadquartersProjectPsiTrainRMVeteran(`XCOMHISTORY.GetGameStateForObjectID(GetReference().ObjectID));
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
	`GAMERULES.SubmitGameState(UpdateState);

	}
}

//---------------------------------------------------------------------------------------
DefaultProperties
{
}