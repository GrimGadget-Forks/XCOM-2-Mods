//---------------------------------------------------------------------------------------
//  FILE:    X2StrategyElement_XpackMissionSources.uc
//  AUTHOR:  Mark Nauta  --  06/23/2016
//  PURPOSE: Define new XPACK mission source templates
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2StrategyElement_MOCXMissionSources extends X2StrategyElement_XPACKMissionSources;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> MissionSources;


	MissionSources.AddItem(CreateMOCXTemplate('MissionSource_MOCXOffsite'));
	MissionSources.AddItem(CreateMOCXTemplate('MissionSource_MOCXAssault'));
	MissionSources.AddItem(CreateMOCXTemplate('MissionSource_MOCXTraining'));
		`log("Dark XCOM: bulding mission sources", ,'DarkXCom');
	return MissionSources;
}



// ALIEN NETWORK
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateMOCXTemplate(name TemplateName)
{
	local X2MissionSourceTemplate Template;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, TemplateName);
	Template.bIncreasesForceLevel = false;
	Template.bDisconnectRegionOnFail = false;
	Template.DifficultyValue = 2;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.ResOps";
	Template.MissionImage = "img://UILibrary_Common.Councilman_small";

	if(TemplateName == 'MissionSource_MOCXOffsite')
	{
		Template.OnSuccessFn = OffsiteOnSuccess;
		Template.DifficultyValue = 3;
	}

	if(TemplateName == 'MissionSource_MOCXTraining')
	{
		Template.OnSuccessFn = TrainingOnSuccess;
		Template.DifficultyValue = 4;
		Template.CustomMusicSet = 'LostAndAbandoned';
	}

	if(TemplateName == 'MissionSource_MOCXAssault')
	{
		Template.OnSuccessFn = AssaultOnSuccess;
		Template.DifficultyValue = 5;
		Template.CustomMusicSet = 'Tutorial'; //avenger def music
	}

	Template.OnFailureFn = MOCXOnFailure;
	Template.OnExpireFn = MOCXOnExpire;
	Template.GetMissionDifficultyFn = GetMissionDifficultyFromMonthAndStart;
	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;
	Template.bIgnoreDifficultyCap = true;
	//Template.MissionPopupFn = OpenMOCXMissionBlades;

	return Template;
}


static function int GetMissionDifficultyFromMonthAndStart(XComGameState_MissionSite MissionState)
{
	local TDateTime StartDate;
	local array<int> MonthlyDifficultyAdd;
	local int Difficulty, MonthDiff;

	class'X2StrategyGameRulesetDataStructures'.static.SetTime(StartDate, 0, 0, 0, class'X2StrategyGameRulesetDataStructures'.default.START_MONTH,
		class'X2StrategyGameRulesetDataStructures'.default.START_DAY, class'X2StrategyGameRulesetDataStructures'.default.START_YEAR);

	Difficulty = 1;
	MonthDiff = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInMonths(class'XComGameState_GeoscapeEntity'.static.GetCurrentTime(), StartDate);
	MonthlyDifficultyAdd = GetMonthlyDifficultyAdd();

	if(MonthDiff >= MonthlyDifficultyAdd.Length)
	{
		MonthDiff = MonthlyDifficultyAdd.Length - 1;
	}

	Difficulty += MonthlyDifficultyAdd[MonthDiff];
	Difficulty += MissionState.GetMissionSource().DifficultyValue;

	Difficulty = Clamp(Difficulty, class'X2StrategyGameRulesetDataStructures'.default.MinMissionDifficulty,
						class'X2StrategyGameRulesetDataStructures'.default.MaxMissionDifficulty);

	return Difficulty;
}

static function OffsiteOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;

	History = `XCOMHISTORY;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ)
	{
		break;
	}

	if(DarkXComHQ == none)
	{
		DarkXComHQ = XComGameState_HeadquartersDarkXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));
		DarkXComHQ = XComGameState_HeadquartersDarkXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ.ObjectID));
	}


	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	ResHQ.AttemptSpawnRandomPOI(NewGameState);

	GiveRewards(NewGameState, MissionState);
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_MOCXMissionCompleted');
	
	DarkXComHQ.bOffSiteDone = true;

}


static function TrainingOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;

	History = `XCOMHISTORY;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ)
	{
		break;
	}

	if(DarkXComHQ == none)
	{
		DarkXComHQ = XComGameState_HeadquartersDarkXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));
		DarkXComHQ = XComGameState_HeadquartersDarkXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ.ObjectID));
	}


	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	ResHQ.AttemptSpawnRandomPOI(NewGameState);

	GiveRewards(NewGameState, MissionState);
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_MOCXMissionCompleted');
	
	DarkXComHQ.bTrainingDone = true;

}


static function AssaultOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;

	History = `XCOMHISTORY;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ)
	{
		break;
	}

	if(DarkXComHQ == none)
	{
		DarkXComHQ = XComGameState_HeadquartersDarkXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));
		DarkXComHQ = XComGameState_HeadquartersDarkXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ.ObjectID));
	}


	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	ResHQ.AttemptSpawnRandomPOI(NewGameState);

	GiveRewards(NewGameState, MissionState);
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_MOCXMissionCompleted');

	DarkXComHQ.bIsActive = false;
	DarkXComHQ.bIsDestroyed = true;

}

static function MOCXOnFailure(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_MOCXMissionFailed');

	//`XEVENTMGR.TriggerEvent('RescueSoldierComplete', , , NewGameState);
}

static function MOCXOnExpire(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_MOCXMissionFailed');
}