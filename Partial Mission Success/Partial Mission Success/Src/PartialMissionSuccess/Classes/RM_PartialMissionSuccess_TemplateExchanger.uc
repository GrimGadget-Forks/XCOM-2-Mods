class RM_PartialMissionSuccess_TemplateExchanger extends X2AmbientNarrativeCriteria;

var XComGameState_CampaignSettings Settings;

static function array<X2DataTemplate> CreateTemplates(){
	local array<X2DataTemplate> EmptyArray;
	local RM_PartialMissionSuccess_TemplateExchanger Exchanger;
	
	`log("Make Partial Mission Success Mod starts modifiying Mission Source Templates");
	Exchanger = new class'RM_PartialMissionSuccess_TemplateExchanger';
	Exchanger.Settings = GameStateMagic();
	Exchanger.ModifyTemplates();

	`XCOMHISTORY.ResetHistory(); // yeah, lets do that, nothing happend anyway...

	`log("Make Partial Mission Success Mod  Mod finished");

	//We don't create any new templates, only modify existing mission templates
	//AddItem(none) prevents array non initialized warning, although the access of none shows up in the debug log
	EmptyArray.AddItem(none);
	return EmptyArray;
}

//Code from: http://forums.nexusmods.com/index.php?/topic/3839560-template-modification-without-screenlisteners/
//Used to set a difficulty level during start up, because the templates we want to modify have difficulty variants
//These variants can only be accessed when the gamestate is in the corresponding difficulty
static function XComGameState_CampaignSettings GameStateMagic(){
	local XComGameStateHistory History;
	local XComGameStateContext_StrategyGameRule StrategyStartContext;
	local XComGameState StartState;
	local XComGameState_CampaignSettings GameSettings;

	History = `XCOMHISTORY;

	StrategyStartContext = XComGameStateContext_StrategyGameRule(class'XComGameStateContext_StrategyGameRule'.static.CreateXComGameStateContext());
	StrategyStartContext.GameRuleType = eStrategyGameRule_StrategyGameStart;
	StartState = History.CreateNewGameState(false, StrategyStartContext);
	History.AddGameStateToHistory(StartState);

	GameSettings = new class'XComGameState_CampaignSettings'; // Do not use CreateStateObject() here
	StartState.AddStateObject(GameSettings);

	return GameSettings;
}

function ModifyTemplates(){
	
	HandleTemplate('MissionSource_GuerillaOp');
	HandleTemplate('MissionSource_Retaliation');
}

function HandleTemplate(name templateName){
	local X2MissionSourceTemplate Template;

	Template = X2MissionSourceTemplate(GetManager().FindStrategyElementTemplate(templateName));

	if (Template == none)
	{
		`log("Could not find template:"@string(templateName));
		return;
	}

	if (Template.bShouldCreateDifficultyVariants){
		HandleDifficultyVariants(Template, templateName);
	} else {
		`log("Modify single template:"@string(templateName));
		HandleSingleTemplate(Template, templateName);
	}
}

function HandleDifficultyVariants(X2MissionSourceTemplate Base, name templateName) {
	local X2MissionSourceTemplate Template;
	local int difficulty;
	local string diffString;

	HandleSingleTemplate(Base, templateName);
	`log("Modified base template:"@string(templateName));

	for(difficulty = `MIN_DIFFICULTY_INDEX; difficulty <= `MAX_DIFFICULTY_INDEX; ++difficulty)
	{
		Settings.SetDifficulty(difficulty);
		diffString = string(class'XComGameState_CampaignSettings'.static.GetDifficultyFromSettings());

		Template = X2MissionSourceTemplate(GetManager().FindStrategyElementTemplate(templateName));

		if(Template == none) {
			`log("Could not find difficulty variant:" @string(templateName) @"with difficulty:" @diffString);
			return;
		}

		`log("Modify difficulty variant:" @string(templateName) @"with difficulty:" @diffString);
		HandleSingleTemplate(Template, templateName);
		
	}
}

function HandleSingleTemplate(X2MissionSourceTemplate Template, name templateName) {
	Template = ReplaceFunctions(Template, templateName);
	GetManager().AddStrategyElementTemplate(Template, true);
}

 function X2MissionSourceTemplate ReplaceFunctions(X2MissionSourceTemplate Template, name templateName){

		//Template.WasMissionSuccessfulFn = StrategyObjectivePlusSweepCompleted;

		if (templateName == 'MissionSource_GuerillaOp')
		{
		Template.OnFailureFn = GuerillaOpOnFailure;
		}

		if (templateName == 'MissionSource_Retaliation')
		{
		Template.OnFailureFn = RetaliationOnFailure;
		}
			return Template;
}

//function bool StrategyObjectivePlusSweepCompleted(XComGameState_BattleData BattleDataState)
//{
//	return (BattleDataState.OneStrategyObjectiveCompleted());
//}

function GuerillaOpOnFailure(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local XComGameState_DarkEvent DarkEventState;
	local XComGameState_BattleData BattleData;

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	if(BattleData.OneStrategyObjectiveCompleted())
	{

	if(MissionState.HasDarkEvent())
	{
		StopMissionDarkEvent(NewGameState, MissionState);
	}

	if( `SYNC_RAND(100) >= 50)
	{
	GiveRewards(NewGameState, MissionState);
	CleanUpGuerillaOps(NewGameState, MissionState.ObjectID);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_GuerrillaOpsCompleted');
	}

	else
	SpawnPointOfInterest(NewGameState, MissionState);
	CleanUpGuerillaOps(NewGameState, MissionState.ObjectID);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_GuerrillaOpsCompleted');

	}
	else

	DarkEventState = MissionState.GetDarkEvent();
	if(DarkEventState != none)
	{
		// Completed objective then aborted or wiped still cancels dark event
		if(BattleData.OneStrategyObjectiveCompleted())
		{
			StopMissionDarkEvent(NewGameState, MissionState);

		}
		else
		{
			// Set the Dark Event to activate immediately
			DarkEventState = XComGameState_DarkEvent(NewGameState.CreateStateObject(class'XComGameState_DarkEvent', DarkEventState.ObjectID));
			NewGameState.AddStateObject(DarkEventState);
			DarkEventState.EndDateTime = `STRATEGYRULES.GameTime;
			class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, DarkEventState.GetPostMissionText(false), true);
		}
	}
	
	CleanUpGuerillaOps(NewGameState, MissionState.ObjectID);
	class'XComGameState_HeadquartersResistance'.static.DeactivatePOI(NewGameState, MissionState.POIToSpawn);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_GuerrillaOpsFailed');
}


function RetaliationOnFailure(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{	
	local XComGameState_BattleData BattleData;

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	
	if(BattleData.OneStrategyObjectiveCompleted())
	{

	if( `SYNC_RAND(100) >= 50)
	{
	GiveRewards(NewGameState, MissionState);
	MissionState.RemoveEntity(NewGameState);
	ModifyRegionSupplyYield(NewGameState, MissionState, class'XComGameState_WorldRegion'.static.GetRegionDisconnectSupplyChangePercent(), , true);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_RetaliationsStopped');
	}

	else
	{
	SpawnPointOfInterest(NewGameState, MissionState);
	ModifyRegionSupplyYield(NewGameState, MissionState, class'XComGameState_WorldRegion'.static.GetRegionDisconnectSupplyChangePercent(), , true);
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_RetaliationsStopped');
	}

	}


	else if(!IsInStartingRegion(MissionState))
	{
		LoseContactWithMissionRegion(NewGameState, MissionState, true);
	}
	else
	{
		ModifyRegionSupplyYield(NewGameState, MissionState, class'XComGameState_WorldRegion'.static.GetRegionDisconnectSupplyChangePercent(), , true);
	}

	MissionState.RemoveEntity(NewGameState);	
	class'XComGameState_HeadquartersResistance'.static.DeactivatePOI(NewGameState, MissionState.POIToSpawn);	
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_RetaliationsFailed');
}

function GiveRewards(XComGameState NewGameState, XComGameState_MissionSite MissionState, optional array<int> ExcludeIndices)
{
	local XComGameStateHistory History;
	local XComGameState_Reward RewardState;
	local int idx;

	History = `XCOMHISTORY;

	// First Check if we need to exclude some rewards
	for(idx = 0; idx < MissionState.Rewards.Length; idx++)
	{
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(MissionState.Rewards[idx].ObjectID));
		if(RewardState != none)
		{
			if(ExcludeIndices.Find(idx) != INDEX_NONE)
			{
				RewardState.CleanUpReward(NewGameState);
				NewGameState.RemoveStateObject(RewardState.ObjectID);
				MissionState.Rewards.Remove(idx, 1);
				idx--;
			}
		}
	}

	class'XComGameState_HeadquartersResistance'.static.SetRecapRewardString(NewGameState, MissionState.GetRewardAmountString());

	// @mnauta: set VIP rewards string is deprecated, leaving blank
	class'XComGameState_HeadquartersResistance'.static.SetVIPRewardString(NewGameState, "" /*REWARDS!*/);

	for(idx = 0; idx < MissionState.Rewards.Length; idx++)
	{
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(MissionState.Rewards[idx].ObjectID));

		// Give rewards
		if(RewardState != none)
		{
			RewardState.GiveReward(NewGameState);
		}

		// Remove the reward state objects
		NewGameState.RemoveStateObject(RewardState.ObjectID);
	}

	MissionState.Rewards.Length = 0;
}

function ModifyRegionSupplyYield(XComGameState NewGameState, XComGameState_MissionSite MissionState, float DeltaYieldPercent, optional int DeltaFromLevelChange = 0, optional bool bRecord = true)
{
	local XComGameState_WorldRegion RegionState;
	local XGParamTag ParamTag;
	local int TotalDelta, OldIncome, NewIncome;

	if (DeltaYieldPercent != 1.0)
	{
		// Region gets permanent supply bonus
		RegionState = XComGameState_WorldRegion(NewGameState.GetGameStateForObjectID(MissionState.Region.ObjectID));
		TotalDelta = DeltaFromLevelChange;
		ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));

		if (RegionState == none)
		{
			RegionState = XComGameState_WorldRegion(NewGameState.CreateStateObject(class'XComGameState_WorldRegion', MissionState.Region.ObjectID));
			NewGameState.AddStateObject(RegionState);
		}
		
		OldIncome = RegionState.GetSupplyDropReward();
		RegionState.BaseSupplyDrop *= DeltaYieldPercent;

		if (RegionState.HaveMadeContact())
		{
			NewIncome = RegionState.GetSupplyDropReward();
			TotalDelta += (NewIncome - OldIncome);
		}
		
		if (bRecord)
		{
			if (DeltaYieldPercent < 1.0)
			{
				ParamTag.StrValue0 = RegionState.GetMyTemplate().DisplayName;
				class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, `XEXPAND.ExpandString(class'UIRewardsRecap'.default.m_strDecreasedRegionSupplyOutput), true);
				ParamTag.StrValue0 = string(-TotalDelta);
				class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, `XEXPAND.ExpandString(class'UIRewardsRecap'.default.m_strDecreasedSupplyIncome), true);
			}
			else
			{
				ParamTag.StrValue0 = RegionState.GetMyTemplate().DisplayName;
				class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, `XEXPAND.ExpandString(class'UIRewardsRecap'.default.m_strIncreasedRegionSupplyOutput), false);
				ParamTag.StrValue0 = string(TotalDelta);
				class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, `XEXPAND.ExpandString(class'UIRewardsRecap'.default.m_strIncreasedSupplyIncome), false);
			}
		}
	}
}


function SpawnPointOfInterest(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local XComGameStateHistory History;
	local XComGameState_PointOfInterest POIState;
	local XComGameState_BlackMarket BlackMarketState;

	History = `XCOMHISTORY;
	BlackMarketState = XComGameState_BlackMarket(History.GetSingleGameStateObjectForClass(class'XComGameState_BlackMarket'));

	if (!BlackMarketState.ShowBlackMarket(NewGameState) && MissionState.POIToSpawn.ObjectID != 0)
	{
		POIState = XComGameState_PointOfInterest(History.GetGameStateForObjectID(MissionState.POIToSpawn.ObjectID));
		
		if (POIState != none)
		{
			POIState = XComGameState_PointOfInterest(NewGameState.CreateStateObject(class'XComGameState_PointOfInterest', POIState.ObjectID));
			NewGameState.AddStateObject(POIState);
			POIState.Spawn(NewGameState);
		}
	}
}

function CleanUpGuerillaOps(XComGameState NewGameState, int CurrentMissionID)
{
	local XComGameStateHistory History;
	local XComGameState_MissionSite MissionState;
	local array<int> CleanedUpMissionIDs;


	foreach NewGameState.IterateByClassType(class'XComGameState_MissionSite', MissionState)
	{
		if(MissionState.Source == 'MissionSource_GuerillaOp' && MissionState.Available)
		{
			if(MissionState.ObjectID != CurrentMissionID)
			{
				class'XComGameState_HeadquartersResistance'.static.DeactivatePOI(NewGameState, MissionState.POIToSpawn);
			}

			CleanedUpMissionIDs.AddItem(MissionState.ObjectID);
			MissionState.RemoveEntity(NewGameState);
		}
	}

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_MissionSite', MissionState)
	{
		if(MissionState.Source == 'MissionSource_GuerillaOp' && MissionState.Available && CleanedUpMissionIDs.Find(MissionState.ObjectID) == INDEX_NONE)
		{
			if(MissionState.ObjectID != CurrentMissionID)
			{
				class'XComGameState_HeadquartersResistance'.static.DeactivatePOI(NewGameState, MissionState.POIToSpawn);
			}

			CleanedUpMissionIDs.AddItem(MissionState.ObjectID);
			MissionState.RemoveEntity(NewGameState);
		}
	}

	`XEVENTMGR.TriggerEvent('GuerillaOpComplete', , , NewGameState);
}

function StopMissionDarkEvent(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local XComGameState_HeadquartersAlien AlienHQ;

	AlienHQ = GetAndAddAlienHQ(NewGameState);

	class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, MissionState.GetDarkEvent().GetPostMissionText(true), false);
	AlienHQ.CancelDarkEvent(MissionState.DarkEvent);
}

function bool IsInStartingRegion(XComGameState_MissionSite MissionState)
{
	local XComGameStateHistory History;
	local XComGameState_WorldRegion RegionState;

	History = `XCOMHISTORY;
	RegionState = XComGameState_WorldRegion(History.GetGameStateForObjectID(MissionState.Region.ObjectID));

	return (RegionState != none && RegionState.IsStartingRegion());
}


function LoseContactWithMissionRegion(XComGameState NewGameState, XComGameState_MissionSite MissionState, bool bRecord)
{
	local XComGameState_WorldRegion RegionState;
	local XGParamTag ParamTag;
	local EResistanceLevelType OldResLevel;
	local int OldIncome, NewIncome, IncomeDelta;

	RegionState = XComGameState_WorldRegion(NewGameState.GetGameStateForObjectID(MissionState.Region.ObjectID));

	if (RegionState == none)
	{
		RegionState = XComGameState_WorldRegion(NewGameState.CreateStateObject(class'XComGameState_WorldRegion', MissionState.Region.ObjectID));
		NewGameState.AddStateObject(RegionState);
	}

	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.StrValue0 = RegionState.GetMyTemplate().DisplayName;
	OldResLevel = RegionState.ResistanceLevel;
	OldIncome = RegionState.GetSupplyDropReward();

	RegionState.SetResistanceLevel(NewGameState, eResLevel_Unlocked);
	
	NewIncome = RegionState.GetSupplyDropReward();
	IncomeDelta = NewIncome - OldIncome;

	if (bRecord)
	{
		if(RegionState.ResistanceLevel < OldResLevel)
		{
			class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, `XEXPAND.ExpandString(class'UIRewardsRecap'.default.m_strRegionLostContact), true);
		}

		if(IncomeDelta < 0)
		{
			ParamTag.StrValue0 = string(-IncomeDelta);
			class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, `XEXPAND.ExpandString(class'UIRewardsRecap'.default.m_strDecreasedSupplyIncome), true);
		}
	}
}

function XComGameState_HeadquartersAlien GetAndAddAlienHQ(XComGameState NewGameState)
{
	local XComGameState_HeadquartersAlien AlienHQ;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersAlien', AlienHQ)
	{
		break;
	}

	if(AlienHQ == none)
	{
		AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
		NewGameState.AddStateObject(AlienHQ);
	}

	return AlienHQ;
}

static function X2StrategyElementTemplateManager GetManager(){
	return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}

defaultproperties{ 

}