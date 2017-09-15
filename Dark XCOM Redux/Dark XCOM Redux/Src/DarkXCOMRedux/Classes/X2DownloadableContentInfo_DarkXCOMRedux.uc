//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_DarkXCOM.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_DarkXCOMRedux extends X2DownloadableContentInfo;

var bool ForceMOCX;


/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
	UpdateResearch();
	InitializeDarkXComHQ();
	//AddTracker();
}

static function bool IsCheatActive()
{
	return default.ForceMOCX;
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local XComGameStateHistory History;


	History = class'XComGameStateHistory'.static.GetGameStateHistory();
	DarkXComHQ = XComGameState_HeadquartersDarkXCom(StartState.CreateStateObject(class'XComGameState_HeadquartersDarkXCom'));
	StartState.AddStateObject(DarkXComHQ);

	DarkXComHQ.SetUpHeadquarters(StartState);


}

static event OnLoadedSavedGameToStrategy()
{
	UpdateResearch();
	InitializeDarkXComHQ();
	//AddTracker();
}

//static function AddTracker()
//{
	//local XComGameStateHistory History;
	//local XComGameState NewGameState;
	//local RM_XComGameState_TriggerObj AchievementObject;
//
	//History = class'XComGameStateHistory'.static.GetGameStateHistory();
	//NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Metal Over Flesh -- Adding Mod Achievement State");
//
	//// Add Achievement Object
	//AchievementObject = RM_XComGameState_TriggerObj(History.GetSingleGameStateObjectForClass(class'RM_XComGameState_TriggerObj', true));
	//if (AchievementObject == none) // Prevent duplicate Achievement Objects
	//{
		//AchievementObject = RM_XComGameState_TriggerObj(NewGameState.CreateStateObject(class'RM_XComGameState_TriggerObj'));
		//NewGameState.AddStateObject(AchievementObject);
	//}
	//
//
	//if (NewGameState.GetNumGameStateObjects() > 0)
	//{
		////AddAchievementTriggers(AchievementObject);
		//History.AddGameStateToHistory(NewGameState);
	//}
	//else
	//{
		//History.CleanupPendingGameState(NewGameState);
	//}
//
//}
//
//
//static function AddAchievementTriggers(Object TriggerObj)
//{
	//local X2EventManager EventManager;
//
	//// Set up triggers for achievements
	//EventManager = class'X2EventManager'.static.GetEventManager();
	//
	////EventManager.RegisterForEvent(TriggerObj, 'KillMail', class'DarkAchievementTracker'.static.OnKillMail, ELD_OnStateSubmitted, 50, , true);
//}
//
//

static function bool IsResearchInHistory(name ResearchName)
{
	// Check if we've already injected the tech templates
	local XComGameState_Tech	TechState;
	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Tech', TechState)
	{
		if ( TechState.GetMyTemplateName() == ResearchName )
		{
			return true;
		}
	}
	return false;
}


static function UpdateResearch()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local X2TechTemplate TechTemplate;
	local XComGameState_Tech TechState;
	local X2StrategyElementTemplateManager	StratMgr;

	//In this method, we demonstrate functionality that will add ExampleWeapon to the player's inventory when loading a saved
	//game. This allows players to enjoy the content of the mod in campaigns that were started without the mod installed.
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	History = `XCOMHISTORY;	

	//Create a pending game state change
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Research Templates");


	//Find tech template


	if ( !IsResearchInHistory('RM_DecryptChip') )
	{
	TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate('RM_DecryptChip'));
	NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
	}

	if ( !IsResearchInHistory('RM_BasicPCS') )
	{
	TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate('RM_BasicPCS'));
	NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
	}

	if ( !IsResearchInHistory('RM_AdvPCS') )
	{
	TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate('RM_AdvPCS'));
	NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
	}
		
	if ( !IsResearchInHistory('RM_SupPCS') )
	{
	TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate('RM_SupPCS'));
	NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
	}

	if ( !IsResearchInHistory('RM_ProduceChip') )
	{
	TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate('M_ProduceChip'));
	NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
	}


	//Commit the state change into the history.
	History.AddGameStateToHistory(NewGameState);
}



/// <summary>
/// Called just before the player launches into a tactical a mission while this DLC / Mod is installed.
/// </summary>
/// 
static event OnPreMission(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local int RandomRoll;
	History = class'XComGameStateHistory'.static.GetGameStateHistory();

	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
	if((DarkXComHQ.bIsActive  && !DarkXComHQ.bIsDestroyed) || default.ForceMOCX || IsPlotMission(MissionState))
	{


	//(DarkXComHQ.bSITREPActive && HasSITREP(MissionState)) || (default.ForceMOCX && HasSITREP(MissionState))
		if( HasSITREP(MissionState) || IsPlotMission(MissionState))
		{
			DarkXComHQ.PreMissionUpdate(NewGameState, MissionState, IsPlotMission(MissionState));
			//DarkXComHQ.NumSinceAppearance = 0;
		}

		else
		{
		DarkXComHQ.NumSinceAppearance += 1;
		}
	}

}


static function bool HasSITREP(XComGameState_MissionSite MissionState)
{
	local name SITREP;
	foreach MissionState.TacticalGameplayTags(SITREP)
	{
		if(SITREP == 'SITREP_MOCX')
		{
		`log("Dark XCom: mission has MOCX SITREP, adding.", ,'DarkXCom');
			return true;
		}
	}

	if(MissionState.GeneratedMission.Sitreps.Find('MOCX') != INDEX_NONE)
	{
		`log("Dark XCom: mission has MOCX SITREP, adding.", ,'DarkXCom');
		return true;
	}

	return false;
}

static function bool IsPlotMission(XComGameState_MissionSite MissionState)
{
	switch (MissionState.GeneratedMission.Mission.sType)
	{
		case "Dark_OffsiteStorage":
		case "Dark_TrainingRaid":
		case "Dark_RooftopsAssault":
			`log("Dark XCom: Plot mission detected.", ,'DarkXCom');
			return true;
		default:
			return false;
	}


	return false;
}

static function InitializeDarkXComHQ()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local XComGameState_HeadquartersResistance ResistanceHQ;
	local bool bDebugMode;

	bDebugMode = false;
	History = class'XComGameStateHistory'.static.GetGameStateHistory();

	DarkXComHQ = XComGameState_HeadquartersDarkXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));

	if (DarkXComHQ == none) //prevent duplicate extraspecies templates
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Dark XCOM State Objects");

		DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.CreateNewStateObject(class'XComGameState_HeadquartersDarkXCOM'));
		DarkXComHQ.SetUpHeadquarters(NewGameState);
		DarkXComHQ.EndOfMonth(NewGameState);
	}
	
	if(DarkXComHQ != none)
	{
		`log("Dark XCOM HQ has been successfully initialized, or is already in the save.", , 'DarkXCom');
		ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

		if(!DarkXComHQ.bIsActive && ResistanceHQ.NumMonths >= class'UIScreenListener_EndOfMonth'.default.ActivationMonth  || bDebugMode && !DarkXComHQ.bIsActive ) //0 - march, 1 - april, 2 - may
		{
			if(NewGameState == none)
				NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Dark XCOM State Objects");

			DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
			DarkXComHQ.bIsActive = true;
			DarkXComHQ.EndOfMonth(NewGameState);
		}

	}
	//if (NewGameState.GetNumGameStateObjects() > 0)
	//{
		//History.AddGameStateToHistory(NewGameState);
	//}
	//else
	//{
		//History.CleanupPendingGameState(NewGameState);
	//}

	if(NewGameState != none)
	{
		if (NewGameState.GetNumGameStateObjects() > 0)
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		else
			History.CleanupPendingGameState(NewGameState);
	}
}

/// <summary>
/// Called when the player completes a mission while this DLC / Mod is installed.
/// </summary>
static event OnPostMission()
{
	local XComGameState NewGameState;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local XComGameState_Unit EnemyUnit, CurrentDarkUnit, UpdatedDarkUnit;
	local XComGameState_Unit_DarkXComInfo InfoState, NewInfoState;
	local array<StateObjectReference> Squad;
	local int i, k;
	local LWTuple AchTuple;
	local LWTValue Value;

	History = `XCOMHISTORY;
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));

	if(DarkXComHQ.Squad.Length == 0 && !DarkXComHQ.bSITREPActive)
		return; //no need to fire if there was no MOCX and no SITREP active.. Since we only generate a squad once the player starts a mission with MOCX in, this also doubles as a "did the player actually do a MOCX mission" check.

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Post Mission");

	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));

	if(DarkXComHQ.ShouldDoFailsafe())
	{
		DarkXComHQ.bSITREPActive = false;
		DarkXComHQ.NumOfMissionsSITREPActive = 0;
	}

	if(DarkXComHQ.Squad.Length > 0 && DarkXComHQ.bSITREPActive)
	{
		DarkXComHQ.bSITREPActive = false;
		DarkXComHQ.NumOfMissionsSITREPActive = 0;
	}

	if(DarkXComHQ.Squad.Length == 0 && DarkXComHQ.bSITREPActive)
	{
		DarkXComHQ.NumOfMissionsSITREPActive += 1; //we add one
	}


	if(DarkXCOMHq.Squad.Length > 0)
	{
		Squad = DarkXComHQ.Squad;

		for(i = 0; i < DarkXComHQ.Squad.Length; i++)
		{
			CurrentDarkUnit = XComGameState_Unit(History.GetGameStateForObjectID(DarkXComHQ.Squad[i].ObjectID));

			`log("Dark XCOM: Checking unit from squad - " $ class'UnitDarkXComUtils'.static.GetFullName(CurrentDarkUnit), ,'DarkXCom');

			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(CurrentDarkUnit);

			if(InfoState != none) //we know that we're going need to update this
			{
				NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.ModifyStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));
				EnemyUnit = XComGameState_Unit(History.GetGameStateForObjectID(NewInfoState.AssignedUnit.ObjectID));

			}

			if(InfoState == none)
			{
			`log("Dark XCom: ERROR! Could not find DarkUnitComponent on a soldier at MOCX HQ!", ,'DarkXCom');
			continue;
			}


			if(EnemyUnit == none)
			{
				`log("Dark XCOM: Found no enemy unit on the battlefield for " $ class'UnitDarkXComUtils'.static.GetFullName(CurrentDarkUnit) $ " , assume they survived with no injuries.", ,'DarkXCom');

				//class'UnitDarkXComUtils'.static.GiveAWCAbility(NewInfoState);
				//class'UnitDarkXComUtils'.static.RemoveFromSquad(DarkXComHQ, DarkXComHQ.Squad[i], NewInfoState);
				continue;
			}

				`log("Dark XCOM: Found enemy unit from battlefield.", ,'DarkXCom');
				if(!EnemyUnit.IsAlive() && EnemyUnit != none)
				{
					class'UnitDarkXComUtils'.static.KillDarkSoldier(NewInfoState);
					`log("Dark XCOM: killed the following unit - " $ class'UnitDarkXComUtils'.static.GetFullName(CurrentDarkUnit), ,'DarkXCom');
				}

				if(EnemyUnit.IsInjured() && EnemyUnit != none)
				{
					`log("Dark XCOM: this unit was considered to only be injured - " $  class'UnitDarkXComUtils'.static.GetFullName(CurrentDarkUnit), ,'DarkXCom');
					NewInfoState.ApplyRecovery(EnemyUnit, DarkXComHQ);
					class'UnitDarkXComUtils'.static.GiveAWCAbility(NewInfoState);

					if(EnemyUnit.IsBleedingOut() || EnemyUnit.GetCurrentStat(eStat_HP) == 1)
						class'UnitDarkXComUtils'.static.GivePromotion(NewInfoState);

					AchTuple = new class'LWTuple'; 
					AchTuple.Id = 'AchievementData'; // Must be this name

					// First entry: Achievement Name.
					Value.kind = LWTVName;
					Value.n = 'RM_DarkSoldierSurvived';
					AchTuple.Data.AddItem(Value);

					// Second Entry: Command
					Value.kind = LWTVName;
					Value.n = 'UnlockAchievement';
					AchTuple.Data.AddItem(Value);

					`XEVENTMGR.TriggerEvent('UnlockAchievement', AchTuple, , );
				}


		



		}

	
		for(i = 0; i < Squad.Length; i++)
		{
		 //do this AFTER we finished processing everything we needed to

	 		CurrentDarkUnit = XComGameState_Unit(History.GetGameStateForObjectID(Squad[i].ObjectID));
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(CurrentDarkUnit);
			NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.ModifyStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));
			`log("Dark XCOM: this unit has now been fully processed - " $  class'UnitDarkXComUtils'.static.GetFullName(CurrentDarkUnit), ,'DarkXCom');
			class'UnitDarkXComUtils'.static.RemoveFromSquad(DarkXComHQ, Squad[i], NewInfoState);
	

		}

		DarkXComHQ.Squad.Length = 0; //just to make sure this gets cleaned out
	}
	if (NewGameState.GetNumGameStateObjects() > 0)
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	else
		History.CleanupPendingGameState(NewGameState);


}


exec function MOCXSpawnFinalMission()
{
	local XComGameState_MissionSite_MOCX MissionState;
	local XComGameStateHistory History;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward MissionRewardState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local float MissionDuration;
	local array<XComGameState_WorldRegion> ContactRegions;
	local XComGameState_ResistanceFaction ResFaction;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: creating mission");
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	//ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(AuxRef.ObjectID));
	foreach History.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
			ContactRegions.AddItem(RegionState);
	}
	RegionState = ContactRegions[`SYNC_RAND_STATIC(ContactRegions.Length)];
	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Engineer'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, 1, RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Scientist'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, 1, RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	MissionState = XComGameState_MissionSite_MOCX(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite_MOCX'));

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_MOCXAssault'));
	
	MissionDuration = float((class'X2StrategyElement_DefaultMissionSources'.default.MissionMinDuration + `SYNC_RAND_STATIC(class'X2StrategyElement_DefaultMissionSources'.default.MissionMaxDuration - class'X2StrategyElement_DefaultMissionSources'.default.MissionMinDuration + 1)) * 3600);
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, false, , MissionDuration);
	MissionState.PickPOI(NewGameState);

	// Set this mission as associated with the Faction whose Covert Action spawned it
	ResFaction = class'X2StrategyElement_XPACKMissionSources'.static.SelectRandomResistanceOpFaction();
	MissionState.ResistanceFaction = ResFaction.GetReference();

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}

}

exec function MOCXSpawnSecondMission()
{
	local XComGameState_MissionSite_MOCX MissionState;
	local XComGameStateHistory History;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward MissionRewardState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local float MissionDuration;
	local array<XComGameState_WorldRegion> ContactRegions;
	local XComGameState_ResistanceFaction ResFaction;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: creating mission");
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	//ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(AuxRef.ObjectID));
	foreach History.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
		if(RegionState.HaveMadeContact())
		{
			// Grab all contacted regions regions for fall-through case
			ContactRegions.AddItem(RegionState);

		}
	}
	RegionState = ContactRegions[`SYNC_RAND_STATIC(ContactRegions.Length)];
	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Elerium'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, 1, RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_AlienLoot'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, 1, RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Alloys'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, 1, RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	MissionState = XComGameState_MissionSite_MOCX(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite_MOCX'));

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_MOCXTraining'));
	
	MissionDuration = float((class'X2StrategyElement_DefaultMissionSources'.default.MissionMinDuration + `SYNC_RAND_STATIC(class'X2StrategyElement_DefaultMissionSources'.default.MissionMaxDuration - class'X2StrategyElement_DefaultMissionSources'.default.MissionMinDuration + 1)) * 3600);
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, false, , MissionDuration);
	MissionState.PickPOI(NewGameState);

	// Set this mission as associated with the Faction whose Covert Action spawned it
	ResFaction = class'X2StrategyElement_XPACKMissionSources'.static.SelectRandomResistanceOpFaction();
	MissionState.ResistanceFaction = ResFaction.GetReference();

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}

}

exec function MOCXSpawnFirstMission()
{
	local XComGameState_MissionSite_MOCX MissionState;
	local XComGameStateHistory History;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward MissionRewardState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local float MissionDuration;
	local array<XComGameState_WorldRegion> ContactRegions;
	local XComGameState_ResistanceFaction ResFaction;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: creating mission");

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	//ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(AuxRef.ObjectID));
	foreach History.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
		if(RegionState.HaveMadeContact())
		{
			// Grab all contacted regions regions for fall-through case
			ContactRegions.AddItem(RegionState);

		}
	}
	RegionState = ContactRegions[`SYNC_RAND_STATIC(ContactRegions.Length)];


	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_FacilityLead'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, 1, RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, 1, RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Intel'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, 1, RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	MissionState = XComGameState_MissionSite_MOCX(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite_MOCX'));

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_MOCXOffsite'));
	
	MissionDuration = float((class'X2StrategyElement_DefaultMissionSources'.default.MissionMinDuration + `SYNC_RAND_STATIC(class'X2StrategyElement_DefaultMissionSources'.default.MissionMaxDuration - class'X2StrategyElement_DefaultMissionSources'.default.MissionMinDuration + 1)) * 3600);
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, false, , MissionDuration);
	MissionState.PickPOI(NewGameState);

	// Set this mission as associated with the Faction whose Covert Action spawned it
	ResFaction = class'X2StrategyElement_XPACKMissionSources'.static.SelectRandomResistanceOpFaction();
	MissionState.ResistanceFaction = ResFaction.GetReference();

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}

}

exec function ForceMOCXOnMissions(bool ForceIt)
{
	ForceMOCX = ForceIt;
}

exec function RankUpMOCXCrew()
{
	local int i;
	local XComGameState_Unit Unit;
	local XComGameState_Unit_DarkXComInfo InfoState, NewInfoState;
	local XComGameState_HeadquartersDarkXCOM DarkXComHQ;
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	History = class'XComGameStateHistory'.static.GetGameStateHistory();


	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Ranking Up MOCX Crew");

	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.CreateStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
	NewGameState.AddStateObject(DarkXComHQ);
	for(i = 0; i < DarkXComHQ.Crew.Length; i++)
	{

		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(DarkXComHQ.Crew[i].ObjectID));
		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

		if(InfoState != none)
		{
			NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));
			NewGameState.AddStateObject(NewInfoState);

			NewInfoState.RankUp(1);
	
		}

	}

	if (NewGameState.GetNumGameStateObjects() > 0)
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	else
		History.CleanupPendingGameState(NewGameState);


}


static event OnPostTemplatesCreated()
{

	EditDarkTemplates();
	EditWeaponTemplates();
	EditSITREPTemplates();
	EditUpgradeTemplates();
	EditRewardTemplates();

}

static function EditRewardTemplates()
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2RewardTemplate RewardTemplate;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_AlienLoot'));

	if(RewardTemplate != none)
	{
		RewardTemplate.GetRewardStringFn = GetNewLootTableRewardString;
	}
}

static function string GetNewLootTableRewardString(XComGameState_Reward RewardState)
{
	if(RewardState.RewardString == "")
	{
		return RewardState.GetMyTemplate().DisplayName;
	}
	return RewardState.RewardString;
}
static function EditUpgradeTemplates()
{
	local X2ItemTemplateManager ItemTemplateManager;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	`log("Dark XCOM: built weapon upgrades.", ,'DarkXCom');

	class'X2Item_DarkXComWeapons'.static.AddCritUpgrade(ItemTemplateManager, 'CritUpgrade_Bsc');
	class'X2Item_DarkXComWeapons'.static.AddCritUpgrade(ItemTemplateManager, 'CritUpgrade_Adv');
	class'X2Item_DarkXComWeapons'.static.AddCritUpgrade(ItemTemplateManager, 'CritUpgrade_Sup');

	class'X2Item_DarkXComWeapons'.static.AddAimBonusUpgrade(ItemTemplateManager, 'AimUpgrade_Bsc');
	class'X2Item_DarkXComWeapons'.static.AddAimBonusUpgrade(ItemTemplateManager, 'AimUpgrade_Adv');
	class'X2Item_DarkXComWeapons'.static.AddAimBonusUpgrade(ItemTemplateManager, 'AimUpgrade_Sup');

	class'X2Item_DarkXComWeapons'.static.AddClipSizeBonusUpgrade(ItemTemplateManager, 'ClipSizeUpgrade_Bsc');
	class'X2Item_DarkXComWeapons'.static.AddClipSizeBonusUpgrade(ItemTemplateManager, 'ClipSizeUpgrade_Adv');
	class'X2Item_DarkXComWeapons'.static.AddClipSizeBonusUpgrade(ItemTemplateManager, 'ClipSizeUpgrade_Sup');

	class'X2Item_DarkXComWeapons'.static.AddFreeFireBonusUpgrade(ItemTemplateManager, 'FreeFireUpgrade_Bsc');
	class'X2Item_DarkXComWeapons'.static.AddFreeFireBonusUpgrade(ItemTemplateManager, 'FreeFireUpgrade_Adv');
	class'X2Item_DarkXComWeapons'.static.AddFreeFireBonusUpgrade(ItemTemplateManager, 'FreeFireUpgrade_Sup');

	class'X2Item_DarkXComWeapons'.static.AddReloadUpgrade(ItemTemplateManager, 'ReloadUpgrade_Bsc');
	class'X2Item_DarkXComWeapons'.static.AddReloadUpgrade(ItemTemplateManager, 'ReloadUpgrade_Adv');
	class'X2Item_DarkXComWeapons'.static.AddReloadUpgrade(ItemTemplateManager, 'ReloadUpgrade_Sup');

	class'X2Item_DarkXComWeapons'.static.AddMissDamageUpgrade(ItemTemplateManager, 'MissDamageUpgrade_Bsc');
	class'X2Item_DarkXComWeapons'.static.AddMissDamageUpgrade(ItemTemplateManager, 'MissDamageUpgrade_Adv');
	class'X2Item_DarkXComWeapons'.static.AddMissDamageUpgrade(ItemTemplateManager, 'MissDamageUpgrade_Sup');

	class'X2Item_DarkXComWeapons'.static.AddFreeKillUpgrade(ItemTemplateManager, 'FreeKillUpgrade_Bsc');
	class'X2Item_DarkXComWeapons'.static.AddFreeKillUpgrade(ItemTemplateManager, 'FreeKillUpgrade_Adv');
	class'X2Item_DarkXComWeapons'.static.AddFreeKillUpgrade(ItemTemplateManager, 'FreeKillUpgrade_Sup');

}

static function EditSITREPTemplates()
{
	local X2SitRepTemplateManager SitRepMgr;
	local X2DataTemplate DataTemplate;
	local X2SitRepTemplate SitRepTemplate;

	SitRepTemplate = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager().FindSitRepTemplate('MOCXRookies');

	SitRepTemplate.StrategyReqs.SpecialRequirementsFn = IsMOCXSitrepAvailable;

	SitRepTemplate = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager().FindSitRepTemplate('MOCX');

	SitRepTemplate.StrategyReqs.SpecialRequirementsFn = NeverUseSitrep;
}

static function bool IsMOCXSitrepAvailable()
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;


	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(`XCOMHistory.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));

	if(DarkXComHQ == none)
		return false;

	return (DarkXComHQ.bIsActive && !DarkXComHQ.bIsDestroyed);
}

static function bool NeverUseSitrep()
{
	return false; //this sitrep should never appear in normal gameplay
}

static function EditWeaponTemplates()
{
	local X2ItemTemplateManager		ItemManager;
	local array<X2WeaponTemplate>	WeaponTemplates;
	local X2WeaponTemplate			WeaponTemplate;
	local name						WeaponName;
	local array<X2DataTemplate>		DifficultyTemplates;
	local X2DataTemplate			DifficultyTemplate;


	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	WeaponTemplates = ItemManager.GetAllWeaponTemplates();

	foreach WeaponTemplates(WeaponTemplate) 
	{
		//MAGNETIC TIER
		if(WeaponTemplate.DataName == 'Dark_AssaultRifle_MG')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
			WeaponTemplate.NumUpgradeSlots = 3;
			WeaponTemplate.TradingPostValue = 20;
			WeaponTemplate.EquipSound = "Magnetic_Weapon_Equip";
		}

		if(WeaponTemplate.DataName == 'Dark_SMG_MG')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
			WeaponTemplate.NumUpgradeSlots = 3;
			WeaponTemplate.TradingPostValue = 20;
			WeaponTemplate.strImage = "img:///UILibrary_Common.AlienWeapons.AdventAssaultRifle";
			WeaponTemplate.EquipSound = "Magnetic_Weapon_Equip";
		}

		if(WeaponTemplate.DataName == 'Dark_Cannon_MG')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Cannon';
			WeaponTemplate.NumUpgradeSlots = 3;
			WeaponTemplate.TradingPostValue = 20;
			WeaponTemplate.strImage = "img:///UILibrary_Common.AlienWeapons.AdventMecGun";
			WeaponTemplate.EquipSound = "Magnetic_Weapon_Equip";
		}
		if(WeaponTemplate.DataName == 'Dark_SniperRifle_MG')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Sniper';
			WeaponTemplate.NumUpgradeSlots = 3;
			WeaponTemplate.TradingPostValue = 20;
			WeaponTemplate.strImage = "img:///UILibrary_Common.AlienWeapons.AdventAssaultRifle";
			WeaponTemplate.EquipSound = "Magnetic_Weapon_Equip";
		}
		if(WeaponTemplate.DataName == 'Dark_Shotgun_MG')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Shotgun';
			WeaponTemplate.NumUpgradeSlots = 3;
			WeaponTemplate.TradingPostValue = 20;
			WeaponTemplate.strImage = "img:///UILibrary_Common.AlienWeapons.AdventAssaultRifle";
			WeaponTemplate.EquipSound = "Magnetic_Weapon_Equip";
		}


		//COIL TIER

		if(WeaponTemplate.DataName == 'Dark_AssaultRifle_CG')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
			WeaponTemplate.NumUpgradeSlots = 4;
			WeaponTemplate.TradingPostValue = 25;
			WeaponTemplate.strImage = "img:///UILibrary_LW_Overhaul.InventoryArt.CoilRifle_Base";
			WeaponTemplate.EquipSound = "Magnetic_Weapon_Equip";
		}

		if(WeaponTemplate.DataName == 'Dark_SMG_CG')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
			WeaponTemplate.NumUpgradeSlots = 4;
			WeaponTemplate.TradingPostValue = 25;
			WeaponTemplate.strImage = "img:///UILibrary_LW_Overhaul.InventoryArt.CoilSMG_Base";
			WeaponTemplate.EquipSound = "Magnetic_Weapon_Equip";
		}

		if(WeaponTemplate.DataName == 'Dark_Cannon_CG')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Cannon';
			WeaponTemplate.NumUpgradeSlots = 4;
			WeaponTemplate.TradingPostValue = 25;
			WeaponTemplate.strImage = "img:///UILibrary_LW_Overhaul.InventoryArt.CoilCannon_Base";
			WeaponTemplate.EquipSound = "Magnetic_Weapon_Equip";
		}
		if(WeaponTemplate.DataName == 'Dark_SniperRifle_CG')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Sniper';
			WeaponTemplate.NumUpgradeSlots = 4;
			WeaponTemplate.TradingPostValue = 25;
			WeaponTemplate.strImage = "img:///UILibrary_LW_Overhaul.InventoryArt.CoilSniperRifle_Base";
			WeaponTemplate.EquipSound = "Magnetic_Weapon_Equip";
		}
		if(WeaponTemplate.DataName == 'Dark_Shotgun_CG')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Shotgun';
			WeaponTemplate.NumUpgradeSlots = 4;
			WeaponTemplate.TradingPostValue = 25;
			WeaponTemplate.strImage = "img:///UILibrary_LW_Overhaul.InventoryArt.CoilShotgun_Base";
			WeaponTemplate.EquipSound = "Magnetic_Weapon_Equip";
		}

		//PLASMA TIER

		if(WeaponTemplate.DataName == 'Dark_AssaultRifle_BM')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
			WeaponTemplate.NumUpgradeSlots = 5;
			WeaponTemplate.TradingPostValue = 35;
			WeaponTemplate.strImage = "img:///UILibrary_Common.UI_BeamAssaultRifle.BeamAssaultRifle_Base";
			WeaponTemplate.EquipSound = "Beam_Weapon_Equip";
		}

		if(WeaponTemplate.DataName == 'Dark_SMG_BM')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_AssaultRifle';
			WeaponTemplate.NumUpgradeSlots = 5;
			WeaponTemplate.TradingPostValue = 35;
			WeaponTemplate.strImage = "img:///UILibrary_SMG.Beam.LWBeamSMG_Base"; 
			WeaponTemplate.EquipSound = "Beam_Weapon_Equip";
		}

		if(WeaponTemplate.DataName == 'Dark_Cannon_BM')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Cannon';
			WeaponTemplate.NumUpgradeSlots = 5;
			WeaponTemplate.TradingPostValue = 35;
			WeaponTemplate.strImage = "img:///UILibrary_Common.UI_BeamCannon.BeamCannon_Base";
			WeaponTemplate.EquipSound = "Beam_Weapon_Equip";
		}
		if(WeaponTemplate.DataName == 'Dark_SniperRifle_BM')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Sniper';
			WeaponTemplate.NumUpgradeSlots = 5;
			WeaponTemplate.TradingPostValue = 35;
			WeaponTemplate.strImage = "img:///UILibrary_Common.UI_BeamSniper.BeamSniper_Base";
			WeaponTemplate.EquipSound = "Beam_Weapon_Equip";
		}
		if(WeaponTemplate.DataName == 'Dark_Shotgun_BM')
		{
			WeaponTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Shotgun';
			WeaponTemplate.NumUpgradeSlots = 5;
			WeaponTemplate.TradingPostValue = 35;
			WeaponTemplate.strImage = "img:///UILibrary_Common.UI_BeamShotgun.BeamShotgun_Base";
			WeaponTemplate.EquipSound = "Beam_Weapon_Equip";
		}
	}

}

static function EditDarkTemplates()
{
	local X2CharacterTemplateManager	CharManager;
	local X2CharacterTemplate			CharTemplate;
	local LootReference Loot;

	local array<X2DataTemplate>		DifficultyTemplates;
	local X2DataTemplate			DifficultyTemplate;

	CharManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	// RANGERS
	//

	CharManager.FindDataTemplateAllDifficulties('DarkRookie',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;

		Loot.ForceLevel=0;
		Loot.LootTableName='MOCX_AR';
		CharTemplate.Loot.LootReferences.AddItem(Loot);
		
	}

	CharManager.FindDataTemplateAllDifficulties('DarkRanger',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_Shotgun';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}

	}

	CharManager.FindDataTemplateAllDifficulties('DarkRanger_M2',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_Shotgun_M2';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}


	}
	
	CharManager.FindDataTemplateAllDifficulties('DarkRanger_M3',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if (CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_Shotgun_M3';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}


	}

	//SPECIALISTS
	//
	CharManager.FindDataTemplateAllDifficulties('DarkSpecialist',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_AR';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}

	}

	CharManager.FindDataTemplateAllDifficulties('DarkSpecialist_M2',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_AR_M2';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}


	}

	CharManager.FindDataTemplateAllDifficulties('DarkSpecialist_M3',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_AR_M3';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}


	}


	//SNIPERS
	//
	CharManager.FindDataTemplateAllDifficulties('DarkSniper',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_Sniper';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}


	}

	CharManager.FindDataTemplateAllDifficulties('DarkSniper_M2',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_Sniper_M2';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}


	}

	CharManager.FindDataTemplateAllDifficulties('DarkSniper_M3',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_Sniper_M3';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}



	}


	// GRENADIERS
	//

	CharManager.FindDataTemplateAllDifficulties('DarkGrenadier',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_Cannon';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}


	}

	CharManager.FindDataTemplateAllDifficulties('DarkGrenadier_M2',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_Cannon_M2';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}



	}

	CharManager.FindDataTemplateAllDifficulties('DarkGrenadier_M3',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_Cannon_M3';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}

	}

	// PSI AGENT
	//

	CharManager.FindDataTemplateAllDifficulties('DarkPsiAgent',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_SMG';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}


	}

	CharManager.FindDataTemplateAllDifficulties('DarkPsiAgent_M2',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_SMG_M2';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}



	}

	CharManager.FindDataTemplateAllDifficulties('DarkPsiAgent_M3',DifficultyTemplates);
	
	foreach DifficultyTemplates(DifficultyTemplate) 
	{

		CharTemplate = X2CharacterTemplate(DifficultyTemplate);
		CharTemplate.Loot.LootReferences.Length = 0;
		if ( CharTemplate != none) 
		{
				Loot.ForceLevel=0;
				Loot.LootTableName='MOCX_SMG_M3';
				CharTemplate.Loot.LootReferences.AddItem(Loot);
		}

	}
}
