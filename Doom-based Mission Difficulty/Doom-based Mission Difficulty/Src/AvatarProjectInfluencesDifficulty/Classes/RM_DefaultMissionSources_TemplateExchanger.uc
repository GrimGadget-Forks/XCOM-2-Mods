class RM_DefaultMissionSources_TemplateExchanger extends X2AmbientNarrativeCriteria config (DoomDifficulty);

var config float DoomDivider;
var config int DoomLimit;
var config bool BlacksitesAffectForceLevel;
var config int MinimumDifficulty;
var config bool CanForceLevelDecrease;
var config int ForceLevelDecreaser;
var config bool bLongWarishMode;


var public localized String m_strStopDoomProduction;
var public localized String m_strDoomLabel;
var public localized String m_strDoomSingular;
var public localized String m_strDoomPlural;
var public localized String m_strDoomRange;
var public localized String m_strFacilityDestroyed;

var XComGameState_CampaignSettings Settings;

static function array<X2DataTemplate> CreateTemplates(){
	local array<X2DataTemplate> EmptyArray;
	local RM_DefaultMissionSources_TemplateExchanger Exchanger;
	
	`log("Make Doom-based Mission Difficulty starts modifiying Mission Source Templates");
	Exchanger = new class'RM_DefaultMissionSources_TemplateExchanger';
	Exchanger.Settings = GameStateMagic();
	Exchanger.ModifyTemplates();

	`XCOMHISTORY.ResetHistory(); // yeah, lets do that, nothing happend anyway...

	`log("Make  Doom-based Mission Difficulty  finished");

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
	HandleTemplate('MissionSource_SupplyRaid');
	HandleTemplate('MissionSource_Council');
	HandleTemplate('MissionSource_LandedUFO');
	HandleTemplate('MissionSource_AlienNetwork');
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
		Template.GetMissionDifficultyFn = GetNewMissionDifficultyFromDoom;
		}

		if (templateName == 'MissionSource_Retaliation')
		{
		Template.GetMissionDifficultyFn = GetNewMissionDifficultyFromDoom;
		}
		
		if (templateName == 'MissionSource_SupplyRaid')
		{
		Template.GetMissionDifficultyFn = GetNewMissionDifficultyFromDoom;
		}

		if (templateName == 'MissionSource_Council')
		{
		Template.GetMissionDifficultyFn = GetCouncilMissionDifficultyFromDoom;
		}

		if (templateName == 'MissionSource_LandedUFO')
		{
		Template.GetMissionDifficultyFn = GetNewMissionDifficultyFromDoom;
		}

		if (templateName == 'MissionSource_AlienNetwork')
		{
		Template.GetMissionDifficultyFn = GetBlacksiteMissionDifficultyFromDoom;
		Template.OnSuccessFn = AlienNetworkOnSuccess;

			if(BlacksitesAffectForceLevel)
			{
			Template.bIncreasesForceLevel = true;
			}

		}
			return Template;

}

function int GetNewMissionDifficultyFromDoom(XComGameState_MissionSite MissionState)
{
	local int Difficulty, Doom;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_HeadquartersXCom XComHQ;
	AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	Doom = AlienHQ.GetCurrentDoom();

	Difficulty = MinimumDifficulty;

	Difficulty += (Doom/DoomDivider);

	

	Difficulty = Clamp(Difficulty, class'X2StrategyGameRulesetDataStructures'.default.MinMissionDifficulty, DoomLimit);

	if(XComHQ.TacticalGameplayTags.Find('DarkEvent_FacilityDestruction') != INDEX_NONE)
	{
	--Difficulty;
	}


	return Difficulty;
}


function int GetBlacksiteMissionDifficultyFromDoom(XComGameState_MissionSite MissionState)
{
	local int Difficulty, Doom;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_HeadquartersXCom XComHQ;
	AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));


	Doom = AlienHQ.GetCurrentDoom();

	Difficulty = 3;

	Difficulty += (Doom/DoomDivider);

	Difficulty = Clamp(Difficulty, class'X2StrategyGameRulesetDataStructures'.default.MinMissionDifficulty, DoomLimit);

	if(XComHQ.TacticalGameplayTags.Find('DarkEvent_FacilityDestruction') != INDEX_NONE)
	{
	--Difficulty;
	}


	return Difficulty;
}

function AlienNetworkOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_WorldRegion RegionState;
	local StateObjectReference EmptyRef;
	local PendingDoom DoomPending;
	local int DoomToRemove;
	local XGParamTag ParamTag;

	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	ResHQ.AttemptSpawnRandomPOI(NewGameState);

	AlienHQ = GetAndAddAlienHQ(NewGameState);
	
	AlienHQ.DelayDoomTimers(AlienHQ.GetFacilityDestructionDoomDelay());
	AlienHQ.DelayFacilityTimer(AlienHQ.GetFacilityDestructionDoomDelay());

	if(CanForceLevelDecrease)
	{
	AlienHQ.ForceLevel = AlienHQ.ForceLevel - ForceLevelDecreaser;
	}

	RegionState = XComGameState_WorldRegion(NewGameState.GetGameStateForObjectID(MissionState.Region.ObjectID));

	if (RegionState == none)
	{
		RegionState = XComGameState_WorldRegion(NewGameState.CreateStateObject(class'XComGameState_WorldRegion', MissionState.Region.ObjectID));
		NewGameState.AddStateObject(RegionState);
	}

	GiveRewards(NewGameState, MissionState);
	RegionState.AlienFacility = EmptyRef;
	  
	if(MissionState.Doom > 0)
	{
		ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
		DoomToRemove = MissionState.Doom;
		DoomPending.Doom = -DoomToRemove;
		ParamTag.StrValue0 = MissionState.GetWorldRegion().GetDisplayName();
		DoomPending.DoomMessage = `XEXPAND.ExpandString(default.m_strFacilityDestroyed);
		AlienHQ.PendingDoomData.AddItem(DoomPending);

		ParamTag.StrValue0 = string(DoomToRemove);

		if(DoomToRemove == 1)
		{
			class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, `XEXPAND.ExpandString(class'UIRewardsRecap'.default.m_strAvatarProgressReducedSingular), false);
		}
		else
		{
			class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, `XEXPAND.ExpandString(class'UIRewardsRecap'.default.m_strAvatarProgressReducedPlural), false);
		}
	}

	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.AddGlobalEffectString(NewGameState, class'UIRewardsRecap'.default.m_strAvatarProjectDelayed, false);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_AlienFacilitiesDestroyed');
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_AvatarProgressReduced', DoomToRemove);


	if (bLongWarishMode)
	{
	RunFauxDarkEvent();
	}
}


function RunFauxDarkEvent()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_DarkEvent DarkEventState;
	local StateObjectReference ActivatedEventRef;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_DarkEvent', DarkEventState)
	{
		if(DarkEventState.GetMyTemplateName() == 'DarkEvent_FacilityDestruction')
		{
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Activate Dark Event");
			AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
			AlienHQ = XComGameState_HeadquartersAlien(NewGameState.CreateStateObject(class'XComGameState_HeadquartersAlien', AlienHQ.ObjectID));
			NewGameState.AddStateObject(AlienHQ);
			DarkEventState = XComGameState_DarkEvent(NewGameState.CreateStateObject(class'XComGameState_DarkEvent', DarkEventState.ObjectID));
			NewGameState.AddStateObject(DarkEventState);
			ActivatedEventRef = DarkEventState.GetReference();
			DarkEventState.TimesSucceeded++;
			DarkEventState.Weight += DarkEventState.GetMyTemplate().WeightDeltaPerActivate;
			DarkEventState.Weight = Clamp(DarkEventState.Weight, DarkEventState.GetMyTemplate().MinWeight, DarkEventState.GetMyTemplate().MaxWeight);
			DarkEventState.OnActivated(NewGameState);

			if(DarkEventState.GetMyTemplate().MaxDurationDays > 0 || DarkEventState.GetMyTemplate().bLastsUntilNextSupplyDrop)
			{
				AlienHQ.ActiveDarkEvents.AddItem(DarkEventState.GetReference());
				DarkEventState.StartDurationTimer();
			}

			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
			break;
		}
	}

	if(ActivatedEventRef.ObjectID != 0)
	{
		`GAME.GetGeoscape().Pause();
		`HQPRES.UIDarkEventActivated(ActivatedEventRef);
	}
}

function int GetCouncilMissionDifficultyFromDoom(XComGameState_MissionSite MissionState)
{
	local int Difficulty, Doom;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_HeadquartersXCom XComHQ;
	AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	Doom = AlienHQ.GetCurrentDoom();

	Difficulty = MinimumDifficulty;

	Difficulty += (Doom/DoomDivider);

	if(MissionState.GeneratedMission.Mission.sType != "Extract")
	{
		Difficulty--;
	}


	Difficulty = Clamp(Difficulty, class'X2StrategyGameRulesetDataStructures'.default.MinMissionDifficulty,	DoomLimit);

	if(XComHQ.TacticalGameplayTags.Find('DarkEvent_FacilityDestruction') != INDEX_NONE)
	{
	--Difficulty;
	}


	return Difficulty;
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



static function X2StrategyElementTemplateManager GetManager()
{
	return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}

defaultproperties
{ 

}