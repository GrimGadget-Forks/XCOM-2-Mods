class XComGameState_HeadquartersDarkXCOM extends XComGameState_BaseObject config (DarkXCOM);

var array<StateObjectReference> Crew;	//All MOCX crew members
var array<StateObjectReference> DeadCrew; //the fallen 

var array<StateObjectReference>  Squad; // Which soldiers are selected to go an a mission

// Modifiers
var bool							bSquadSizeI; // Squad Size bonuses
var bool							bSquadSizeII; 
var bool							bGeneticPCS; // gene mod equivalents
var bool							bAdvancedMECs; // SPARK equivalents
var bool							bHasCoil; //is at coil + power armor tech level
var bool							bHasPlasma; //is at plasma tech level
var bool							bAdvancedICUs; //50% faster healing

//HQ status
var bool							bIsDestroyed; //did XCOM set us up the bomb
var bool							bIsActive; //is it May yet

var bool							bChainStarted; //have we started the mission chain?
var bool							bOffSiteDone; //completed offsite storage mission
var bool							bTrainingDone; //completed training raid mission

//sitrep status
var bool							bSITREPActive; //we got a SITREP active, don't roll again. Set this to false every time we do a mission: forced SITREPs on missions should be unaffected.
var int								NumOfMissionsSITREPActive; //this is a failsafe measure: if we pass X amount of missions then we should assume we should stop assuming the SITREP is active.

var int								ChanceToRoll; //current chance for MOCX to appear on a mission
var int								NumSinceAppearance; //how many missions have passed since last appearance?
var int								HighestSoldierRank;
//class stuff
var() array<name>                   SoldierClassDeck;   //classes we can use: be sure to update this when available
var() array<SoldierClassCount>		SoldierClassDistribution;


//config variables

var config int StartingSoldiers; //starting MOCX soldiers
var config int MonthlyReinforcements; //replacements it can get due to losses

var config int MaxSoldiers; //how many soldiers MOCX can have in total
var config int StartingSquadSize; //the initial size of MOCX squads

var config int BaseChance; //what's the minimum that MOCX can roll to appear on a mission?
var config int MissingChance; //how much does the chance increase by per mission MOCX hasn't appeared in?

var config int BaseMonthsForRanks; //how many months does it take for replacement soldiers to start off with better ranks?

var config int AdvancedMECChance; //what's the chance of an advanced MEC deploying on a mission?

function bool ShouldDoFailsafe()
{
	if(bSITREPActive && NumOfMissionsSITREPActive > 3) //after 3 missions, we assume the player has either done the SITREP or skipped it
		return true;

	return false;
}


//--------------------------------------------------------------------------------------
// START AND MONTHLY TRANSITIONS
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
function SetUpHeadquarters(XComGameState StartState)
{
	//local XComGameState_HeadquartersDarkXCom DarkXComHQ;
//
	//DarkXComHQ = XComGameState_HeadquartersDarkXCom(StartState.CreateStateObject(class'XComGameState_HeadquartersDarkXCom'));
	//StartState.AddStateObject(DarkXComHQ);
//
	CreateStartingOrEmergencySoldiers(StartState);
}

function EndOfMonth(XComGameState NewGameState, optional XComGameState_HeadquartersResistance ResHQ)
{

	if(bIsActive)
		CheckForPromotions(NewGameState);


	if(Crew.Length < (StartingSoldiers / 2))
		CreateStartingOrEmergencySoldiers(NewGameState, ResHQ, self);

	if(Crew.Length >= (StartingSoldiers / 2) && bIsActive)
		AddReinforcementSoldiers(NewGameState, ResHQ, self);


}

function CheckForPromotions(XComGameState NewGameState)
{
	local int i;
	local XComGameState_Unit Unit;
	local XComGameState_Unit_DarkXComInfo InfoState, NewInfoState;
	
	for(i = 0; i < Crew.Length; i++)
	{

		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Crew[i].ObjectID));
		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

		if(InfoState != none)
		{
			NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));
			NewGameState.AddStateObject(NewInfoState);

			NewInfoState.MonthsInService += 1;
			if(NewInfoState.MonthsSinceLastPromotion >= NewInfoState.PromotionThreshold)
			{
				class'UnitDarkXComUtils'.static.GivePromotion(NewInfoState);
				NewInfoState.MonthsSinceLastPromotion = 0;
			}

			else
			{
				NewInfoState.MonthsSinceLastPromotion += 1;
			}

		}

	}

}
//--------------------------------------------------------------------------------------
// SOLDIER HANDLING
//---------------------------------------------------------------------------------------
function CreateStartingOrEmergencySoldiers(XComGameState StartState, optional XComGameState_HeadquartersResistance ResHQ, optional XComGameState_HeadquartersDarkXCom DarkXComHQ)
{
	local XComGameState_Unit NewSoldierState;	
	//local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	//local XGCharacterGenerator CharacterGenerator;
	local int Index, AdditionalRanks;
	//local XComGameState_GameTime GameTime;
	local XComOnlineProfileSettings ProfileSettings;
	local XComGameState_Unit_DarkXComInfo InfoState;

	//assert(StartState != none);

	if(DarkXComHQ == none)
	{
		foreach StartState.IterateByClassType(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ)
		{
			break;
		}

	}


	//foreach StartState.IterateByClassType(class'XComGameState_GameTime', GameTime)
	//{
		//break;
	//}
	//`assert( GameTime != none );


	ProfileSettings = `XPROFILESETTINGS;

	// Starting soldiers
	for( Index = 0; Index < StartingSoldiers; ++Index )
	{
		NewSoldierState = `CHARACTERPOOLMGR.CreateCharacter(StartState, ProfileSettings.Data.m_eCharPoolUsage, 'DarkSoldier');
		//CharacterGenerator = `XCOMGRI.Spawn(NewSoldierState.GetMyTemplate().CharacterGeneratorClass);
		//`assert(CharacterGenerator != none);

		NewSoldierState.RandomizeStats();
		NewSoldierState.ApplyInventoryLoadout(StartState);

		InfoState = XComGameState_Unit_DarkXComInfo(StartState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo'));
		InfoState.InitComponent(SelectNextSoldierClass());
		NewSoldierState.AddComponentObject(InfoState);
		StartState.AddStateObject(InfoState);

		if(ResHQ != none && ((ResHQ.NumMonths / BaseMonthsForRanks) > 1))
		{
		AdditionalRanks = (ResHQ.NumMonths / BaseMonthsForRanks);
		AdditionalRanks = Clamp(AdditionalRanks, 1, 3); //clamping because shit gets stupid past a certain rank
		InfoState.RankUp(AdditionalRanks);

		}

		DarkXComHQ.AddToCrew(StartState, NewSoldierState);
		//NewSoldierState.m_RecruitDate = GameTime.CurrentTime; // AddToCrew does this, but during start state creation the StrategyRuleset hasn't been created yet

		StartState.AddStateObject( NewSoldierState );
	}

}


function AddReinforcementSoldiers(XComGameState StartState, optional XComGameState_HeadquartersResistance ResHQ, optional XComGameState_HeadquartersDarkXCom DarkXComHQ)
{
	local XComGameState_Unit NewSoldierState;	
	//local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	//local XGCharacterGenerator CharacterGenerator;
	local int Index, AdditionalRanks;
//	local XComGameState_GameTime GameTime;
	local XComOnlineProfileSettings ProfileSettings;
	local XComGameState_Unit_DarkXComInfo InfoState;

	//assert(StartState != none);

	if(DarkXComHQ == none)
	{
		foreach StartState.IterateByClassType(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ)
		{
			break;
		}

	}

	//foreach StartState.IterateByClassType(class'XComGameState_GameTime', GameTime)
	//{
		//break;
	//}
	//`assert( GameTime != none );


	ProfileSettings = `XPROFILESETTINGS;

	// Starting soldiers
	for( Index = 0; Index < MonthlyReinforcements; ++Index )
	{
		if(Crew.Length >= MaxSoldiers)
		{
		`log("Dark XCOM: Already at max capacity.", ,'DarkXCom');
			break;
		}
		NewSoldierState = `CHARACTERPOOLMGR.CreateCharacter(StartState, ProfileSettings.Data.m_eCharPoolUsage, 'DarkSoldier');
		//CharacterGenerator = `XCOMGRI.Spawn(NewSoldierState.GetMyTemplate().CharacterGeneratorClass);
		//`assert(CharacterGenerator != none);

		NewSoldierState.RandomizeStats();
		NewSoldierState.ApplyInventoryLoadout(StartState);

		InfoState = XComGameState_Unit_DarkXComInfo(StartState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo'));
		InfoState.InitComponent(SelectNextSoldierClass());
		NewSoldierState.AddComponentObject(InfoState);
		StartState.AddStateObject(InfoState);

		if((ResHQ.NumMonths / BaseMonthsForRanks) > 1)
		{
		AdditionalRanks = (ResHQ.NumMonths / BaseMonthsForRanks);
		AdditionalRanks = Clamp(AdditionalRanks, 1, 3); //clamping because shit gets stupid past a certain rank
		InfoState.RankUp(AdditionalRanks);

		}

		DarkXComHQ.AddToCrew(StartState, NewSoldierState);
		//NewSoldierState.m_RecruitDate = GameTime.CurrentTime; // AddToCrew does this, but during start state creation the StrategyRuleset hasn't been created yet

		StartState.AddStateObject( NewSoldierState );
	}

}
//------------------------------------------------------------OTHER CREW FUNCTIONS
function RenewPCSes(XComGameState NewGameState)
{
	local XComGameState_Unit_DarkXComInfo InfoState, NewInfoState;
	local XComGameState_Unit					 Unit;
	local int i;

	for(i = 0; i < Crew.Length; i++)
	{
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Crew[i].ObjectID));
		if(Unit == none)
		{
			`log("Dark XCom: Could not find valid unit.", ,'DarkXCom');
			continue;
		}

		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

		if(InfoState == none)
			`log("Dark XCom: could not find infostate for unit.", ,'DarkXCom');


		if(InfoState != none)
		{
		NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));
		NewGameState.AddStateObject(NewInfoState);

			if(NewInfoState.bIsAlive)
			{
			`log("Dark XCom: re-rolling PCS for Genetic PCS Dark Event", ,'DarkXCom');
			NewInfoState.SetPCS(class'UnitDarkXComUtils'.static.GetAllDarkPCS(NewInfoState));
			}
		}
	}
}
//---------------------------------------------------------------------------------------
function BuildSoldierClassDeck()
{
	local X2DarkSoldierClassTemplate SoldierClassTemplate;
	local X2StrategyElementTemplateManager TemplateManager;
	local X2DataTemplate Template;
	local SoldierClassCount ClassCount;
	local int i;
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	if (SoldierClassDeck.Length != 0)
	{
		SoldierClassDeck.Length = 0;
	}


	foreach TemplateManager.IterateTemplates(Template, none)
	{
		SoldierClassTemplate = X2DarkSoldierClassTemplate(Template);
		if(SoldierClassTemplate != none)
		{
			for(i = 0; i < SoldierClassTemplate.NumInDeck; ++i)
			{
				SoldierClassDeck.AddItem(SoldierClassTemplate.DataName);
				if(SoldierClassDistribution.Find('SoldierClassName', SoldierClassTemplate.DataName) == INDEX_NONE)
				{
					// Add to array to track class distribution
					ClassCount.SoldierClassName = SoldierClassTemplate.DataName;
					ClassCount.Count = 0;
					SoldierClassDistribution.AddItem(ClassCount);
				}
			}
		}

	}

}

//---------------------------------------------------------------------------------------
function name SelectNextSoldierClass(optional name ForcedClass)
{
	local name RetName;
	local array<name> ValidClasses;
	local int Index;

	if(SoldierClassDeck.Length == 0)
	{
		BuildSoldierClassDeck();
	}
	
	if(ForcedClass != '')
	{
		// Must be a valid class in the distribution list
		if(SoldierClassDistribution.Find('SoldierClassName', ForcedClass) != INDEX_NONE)
		{
			// If not in the class deck rebuild the class deck
			if(SoldierClassDeck.Find(ForcedClass) == INDEX_NONE)
			{
				BuildSoldierClassDeck();
			}

			ValidClasses.AddItem(ForcedClass);
		}
	}

	// Only do this if not forced
	if(ValidClasses.Length == 0)
	{
		ValidClasses = GetValidNextSoldierClasses();
	}
	
	// If not forced, and no valid, rebuild
	if(ValidClasses.Length == 0)
	{
		BuildSoldierClassDeck();
		ValidClasses = GetValidNextSoldierClasses();
	}

	if(SoldierClassDeck.Length == 0)
		`RedScreen("No elements found in SoldierClassDeck array. This might break class assignment, please inform realitymachina and provide a save.");

	if(ValidClasses.Length == 0)
		`RedScreen("No elements found in ValidClasses array. This might break class assignment, please inform realitymachina and provide a save.");
	
	RetName = ValidClasses[`SYNC_RAND(ValidClasses.Length)];
	`log("Chosen class is " $ RetName, ,'DarkXCom');
	SoldierClassDeck.Remove(SoldierClassDeck.Find(RetName), 1);
	Index = SoldierClassDistribution.Find('SoldierClassName', RetName);
	SoldierClassDistribution[Index].Count++;

	return RetName;
}

//---------------------------------------------------------------------------------------
private function int GetClassDistributionDifference(name SoldierClassName)
{
	local int LowestCount, ClassCount, idx;

	LowestCount = SoldierClassDistribution[0].Count;

	for(idx = 0; idx < SoldierClassDistribution.Length; idx++)
	{
		if(SoldierClassDistribution[idx].Count < LowestCount)
		{
			LowestCount = SoldierClassDistribution[idx].Count;
		}

		if(SoldierClassDistribution[idx].SoldierClassName == SoldierClassName)
		{
			ClassCount = SoldierClassDistribution[idx].Count;
		}
	}

	return (ClassCount - LowestCount);
}


//---------------------------------------------------------------------------------------
function array<name> GetValidNextSoldierClasses()
{
	local array<name> ValidClasses;
	local int idx;

	for(idx = 0; idx < SoldierClassDeck.Length; idx++)
	{
		if(GetClassDistributionDifference(SoldierClassDeck[idx]) < 1)
		{
			ValidClasses.AddItem(SoldierClassDeck[idx]);
		}
	}

	return ValidClasses;
}


//---------------------------------------------------------------------------------------
function array<name> GetNeededSoldierClasses()
{
	local XComGameStateHistory History;
	local array<SoldierClassCount> ClassCounts, ClassHighestRank;
	local SoldierClassCount SoldierClassStruct, EmptyStruct;
	local XComGameState_Unit UnitState;
	local array<name> NeededClasses;
	local int idx, Index, HighestClassCount;

	History = `XCOMHISTORY;

	// Grab reward classes
	for(idx = 0; idx < SoldierClassDistribution.Length; idx++)
	{
		SoldierClassStruct = EmptyStruct;
		SoldierClassStruct.SoldierClassName = SoldierClassDistribution[idx].SoldierClassName;
		SoldierClassStruct.Count = 0;
		ClassCounts.AddItem(SoldierClassStruct);
		ClassHighestRank.AddItem(SoldierClassStruct);
	}

	HighestClassCount = 0;

	// Grab current crew information
	for(idx = 0; idx < Crew.Length; idx++)
	{
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(Crew[idx].ObjectID));

		if(UnitState != none)
		{
			Index = ClassCounts.Find('SoldierClassName', UnitState.GetSoldierClassTemplate().DataName);

			if(Index != INDEX_NONE)
			{
				// Add to class count
				ClassCounts[Index].Count++;
				if(ClassCounts[Index].Count > HighestClassCount)
				{
					HighestClassCount = ClassCounts[Index].Count;
				}

				// Update Highest class rank if applicable
				if(ClassHighestRank[Index].Count < UnitState.GetRank())
				{
					ClassHighestRank[Index].Count = UnitState.GetRank();
				}
			}
		}
	}

	// Parse the info to grab needed classes
	for(idx = 0; idx < ClassCounts.Length; idx++)
	{
		if((ClassCounts[idx].Count == 0) || ((HighestClassCount - ClassCounts[idx].Count) >= 2) || ((HighestSoldierRank - ClassHighestRank[idx].Count) >= 2))
		{
			NeededClasses.AddItem(ClassCounts[idx].SoldierClassName);
		}
	}

	// If no classes are needed, all classes are needed
	if(NeededClasses.Length == 0)
	{
		for(idx = 0; idx < ClassCounts.Length; idx++)
		{
			NeededClasses.AddItem(ClassCounts[idx].SoldierClassName);
		}
	}

	return NeededClasses;
}

function AddToCrew(XComGameState NewGameState, XComGameState_Unit NewUnit )
{
	Crew.AddItem(NewUnit.GetReference());
}


function RemoveFromCrew( StateObjectReference CrewRef )
{
	Crew.RemoveItem(CrewRef);
}
//--------------------------------------------------------------------------------------
// CHANCE TO ROLL
//---------------------------------------------------------------------------------------
function int HandleChance()
{
	ChanceToRoll = (MissingChance * NumSinceAppearance) + BaseChance;
	
	return ChanceToRoll;
}

//--------------------------------------------------------------------------------------
// PRE MISSION UPDATE
//---------------------------------------------------------------------------------------
static function PreMissionUpdate(XComGameState NewGameState, XComGameState_MissionSite MissionState, bool IsPlotMission)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCOM DarkXComHQ;

	switch (MissionState.GeneratedMission.Mission.sType)
	{
		case "GP_Broadcast":
		case "GP_FortressLeadup":
		case "ChosenStrongholdShort":
		case "ChosenStrongholdLong":
		case "Sabotage":
		case "LostAndAbandonedA":
		case "LostAndAbandonedB":
		case "LostAndAbandonedC":
		case "CompoundRescueOperative":
		case "CovertEscape":
		case "LastGift":
		case "LastGiftB":
		case "LastGiftC":
		case "AlienNest":
			`log("DLC or special mission detected. Aborting.", ,'DarkXCom');
			return;
		default:
			break;
	}

		//



	History = class'XComGameStateHistory'.static.GetGameStateHistory();
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHq.ObjectID));
	//NewGameState.AddStateObject(DarkXComHQ);


	if(!IsPlotMission || (IsPlotMission && MissionState.GeneratedMission.Mission.sType == "Dark_OffsiteStorage")) //off site storage is defended by regular ADVENT augmented by a permanent MOCX attachment
	{
		DarkXComHQ.FillSquad(NewGameState);
		If(DarkXComHQ.GetCurrentSquadSize() > 0)
		{
			DarkXComHQ.UpdateSpawningData(NewGameState, MissionState);
			DarkXComHQ.NumSinceAppearance = 0;
		}
		else
		{
			DarkXComHQ.NumSinceAppearance += 1;
		}
	}

	if(IsPlotMission && MissionState.GeneratedMission.Mission.sType == "Dark_TrainingRaid")
	{
		DarkXComHQ.FillSquad(NewGameState);
		If(DarkXComHQ.GetCurrentSquadSize() > 0)
		{
			DarkXComHQ.UpdateSpawningData(NewGameState, MissionState);
		}
		else
		{
			DarkXComHQ.NumSinceAppearance += 1;
		}

	}

	if(IsPlotMission && MissionState.GeneratedMission.Mission.sType == "Dark_RooftopsAssault")
	{
		DarkXComHQ.SpawnSquad(NewGameState, MissionState); //three squads to patrol HQ alongside ADVENT base security
		DarkXComHQ.SpawnSquad(NewGameState, MissionState);
		DarkXComHQ.SpawnSquad(NewGameState, MissionState);
	}

}

function int GetCurrentSquadSize()
{

	return Squad.Length;
}

function FillSquad(XcomGameState NewGameState)
{
	local XComGameState_Unit_DarkXComInfo InfoState, NewInfoState;
	local XComGameState_Unit					 Unit;
	local int i;

	Squad.Length = 0;
	for(i = 0; i < Crew.Length; i++)
	{
		if(Squad.Length >= GetMaxSquadSize())
		{
			`log("Dark XCom: Finished making squad.", ,'DarkXCom');
			break;
		}

		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Crew[i].ObjectID));
		if(Unit == none)
		{
			`log("Dark XCom: Could not find valid unit.", ,'DarkXCom');
			continue;
		}

		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

		if(InfoState == none)
			`log("Dark XCom: could not find infostate for unit.", ,'DarkXCom');


		if(InfoState != none)
		{
		NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));
		NewGameState.AddStateObject(NewInfoState);

			if(NewInfoState.bIsAlive && NewInfoState.GetRecoveryPoints() <= 0 && !NewInfoState.bInSquad) //is alive and is done healing
			{
			`log("Added following MOCX soldier to squad: " $ class'UnitDarkXComUtils'.static.GetFullName(Unit), ,'DarkXCom');
				Squad.AddItem(Crew[i]);
				NewInfoState.bInSquad = true;
			}
		}

	}
}


function int GetMaxSquadSize()
{
	local int i;

	i = StartingSquadSize;

	if(bSquadSizeI)
	{
		i += 1;
	}

	if(bSquadSizeII)
	{
		i += 1;
	}

	return i;
}

//---------------------------------------------------------------------------------------
function UpdateSpawningData(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local X2SelectedEncounterData NewEncounter, EmptyEncounter;
	local XComTacticalMissionManager TacticalMissionManager;
	local PrePlacedEncounterPair EncounterInfo;
	local array<X2CharacterTemplate> SelectedCharacterTemplates;
	local ConfigurableEncounter Encounter;
	local float AlienLeaderWeight, AlienFollowerWeight;
	local XComAISpawnManager SpawnManager;
	local int LeaderForceLevelMod, i;
	local MissionSchedule SelectedMissionSchedule;
	local XComGameState_Unit Unit;
	local XComGameState_Unit_DarkXComInfo InfoState;
	local array<Name> NamesToAdd;
	local float AlongLOP, FromLOP;
	local XComGameState_BattleData BattleData;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;


	EncounterInfo.EncounterID='MOCX_Teamx4';

	if(Squad.Length <= 2)
		EncounterInfo.EncounterID='MOCX_Teamx2';

	if(Squad.Length == 3)
		EncounterInfo.EncounterID='MOCX_Teamx3';

	if(Squad.Length == 5)
		EncounterInfo.EncounterID='MOCX_Teamx5';

	if(Squad.Length == 6)
		EncounterInfo.EncounterID='MOCX_Teamx6';

	if(Squad.Length == 7)
		EncounterInfo.EncounterID='MOCX_Teamx7';

	if(Squad.Length >= 8)
		EncounterInfo.EncounterID='MOCX_Teamx8';

	if(Squad.Length == 9)
		EncounterInfo.EncounterID='MOCX_Teamx9';

	if(Squad.Length >= 10)
		EncounterInfo.EncounterID='MOCX_Teamx10';


	AlongLOP = `SYNC_RAND(15) - `SYNC_RAND(9);
	FromLOP = `SYNC_RAND(15) - `SYNC_RAND(9);
	EncounterInfo.EncounterZoneOffsetAlongLOP = AlongLOP; //randomized locations
	EncounterInfo.EncounterZoneOffsetFromLOP = FromLOP;
	EncounterInfo.EncounterZoneWidth=9.0;

	TacticalMissionManager = `TACTICALMISSIONMGR;
	SpawnManager = `SPAWNMGR;
	AlienLeaderWeight = 0.0;
	AlienFollowerWeight = 0.0;

	//TacticalMissionManager.GetConfigurableEncounter( EncounterInfo.EncounterID, Encounter, MissionState.SelectedMissionData.ForceLevel, MissionState.SelectedMissionData.AlertLevel );
	Encounter.EncounterID = EncounterInfo.EncounterID;
	Encounter.MaxSpawnCount = GetMaxSquadSize();

	if(bAdvancedMECs)
	{
	i = `SYNC_RAND(100);
		if(i <= AdvancedMECChance)
		{
		NamesToAdd.AddItem('AdvMec_MOCX');
		}

	}

	if(!bHasCoil)
	{
		for(i = 0; i < GetCurrentSquadSize(); i++)
		{
			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Squad[i].ObjectID));
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

			`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
			NamesToAdd.AddItem(InfoState.GetClassName());
		}
	}

	if(bHasCoil && !bHasPlasma)
	{
		for(i = 0; i < GetCurrentSquadSize(); i++)
		{
			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Squad[i].ObjectID));
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

			`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
			NamesToAdd.AddItem(name(InfoState.GetClassName() $ "_M2"));
		}
	}

	if(bHasPlasma)
	{
		for(i = 0; i < GetCurrentSquadSize(); i++)
		{
			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Squad[i].ObjectID));
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

			`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
			NamesToAdd.AddItem(name(InfoState.GetClassName() $ "_M3"));
		}
	}


	if(NamesToAdd.Length < GetMaxSquadSize())
	{
		for(i = NamesToAdd.Length; i < GetMaxSquadSize(); i++)
		{
			if(MissionState.SelectedMissionData.ForceLevel < 9)
				NamesToAdd.AddItem('DarkRookie'); //spawning rookies to fill in gaps

			if(MissionState.SelectedMissionData.ForceLevel < 15 && MissionState.SelectedMissionData.ForceLevel > 9)
				NamesToAdd.AddItem('DarkRookie_M2'); //spawning rookies to fill in gaps

			if(MissionState.SelectedMissionData.ForceLevel >= 15)
				NamesToAdd.AddItem('DarkRookie_M3'); //spawning rookies to fill in gaps

		}

	}

	Encounter.ForceSpawnTemplateNames = NamesToAdd;
	Encounter.TeamToSpawnInto = eTeam_Alien;
	Encounter.ReinforcementCountdown = 1;

	TacticalMissionManager.GetMissionSchedule(MissionState.SelectedMissionData.SelectedMissionScheduleName, SelectedMissionSchedule);

	if( MissionState.SelectedMissionData.SelectedMissionScheduleName == '' )
	{
		`log("Dark XCOM: we were somehow given a missionstate with no schedule: fix it ourselves", , 'DarkXCom');
		MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));
		MissionState.UpdateSelectedMissionData();
		TacticalMissionManager.GetMissionSchedule(MissionState.SelectedMissionData.SelectedMissionScheduleName, SelectedMissionSchedule);
	}

	NewEncounter = EmptyEncounter;

	`log("Dark XCom: Current Encounter ID is " $ Encounter.EncounterID, ,'DarkXCom');

	NewEncounter.SelectedEncounterName = Encounter.EncounterID;
	LeaderForceLevelMod = SpawnManager.GetLeaderForceLevelMod();

	// select the group members who will fill out this encounter group
	AlienLeaderWeight += SelectedMissionSchedule.AlienToAdventLeaderRatio;
	AlienFollowerWeight += SelectedMissionSchedule.AlienToAdventFollowerRatio;
	SpawnManager.SelectSpawnGroup(NewEncounter.EncounterSpawnInfo, MissionState.GeneratedMission.Mission, SelectedMissionSchedule, MissionState.GeneratedMission.Sitreps, Encounter ,MissionState.SelectedMissionData.ForceLevel, MissionState.SelectedMissionData.AlertLevel, SelectedCharacterTemplates, AlienLeaderWeight, AlienFollowerWeight, LeaderForceLevelMod);

	//NewEncounter.EncounterSpawnInfo.SelectedCharacterTemplateNames = NamesToAdd;
	NewEncounter.EncounterSpawnInfo.EncounterZoneWidth = EncounterInfo.EncounterZoneWidth;
	NewEncounter.EncounterSpawnInfo.EncounterZoneDepth = ((EncounterInfo.EncounterZoneDepthOverride >= 0.0) ? EncounterInfo.EncounterZoneDepthOverride : SelectedMissionSchedule.EncounterZonePatrolDepth);
	NewEncounter.EncounterSpawnInfo.EncounterZoneOffsetFromLOP = EncounterInfo.EncounterZoneOffsetFromLOP;
	NewEncounter.EncounterSpawnInfo.EncounterZoneOffsetAlongLOP = EncounterInfo.EncounterZoneOffsetAlongLOP;

	NewEncounter.EncounterSpawnInfo.SpawnLocationActorTag = EncounterInfo.SpawnLocationActorTag;

	MissionState.SelectedMissionData.SelectedEncounters.AddItem(NewEncounter);

}



//---------------------------------------------------------------------------------------
// GRAND FINALE
//-----------------------------------
function SpawnSquad(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local X2SelectedEncounterData NewEncounter, EmptyEncounter;
	local XComTacticalMissionManager TacticalMissionManager;
	local PrePlacedEncounterPair EncounterInfo;
	local array<X2CharacterTemplate> SelectedCharacterTemplates;
	local ConfigurableEncounter Encounter;
	local float AlienLeaderWeight, AlienFollowerWeight;
	local XComAISpawnManager SpawnManager;
	local int LeaderForceLevelMod, i;
	local MissionSchedule SelectedMissionSchedule;
	local XComGameState_Unit Unit;
	local XComGameState_Unit_DarkXComInfo InfoState;
	local array<Name> NamesToAdd;
	local float AlongLOP, FromLOP;
	local array<XComGameState_Unit> CurrentSquad;
	EncounterInfo.EncounterID='MOCX_Teamx4';

	if(GetMaxSquadSize() <= 2)
		EncounterInfo.EncounterID='MOCX_Teamx2';

	if(GetMaxSquadSize() == 3)
		EncounterInfo.EncounterID='MOCX_Teamx3';

	if(GetMaxSquadSize()== 5)
		EncounterInfo.EncounterID='MOCX_Teamx5';

	if(GetMaxSquadSize() == 6)
		EncounterInfo.EncounterID='MOCX_Teamx6';

	if(GetMaxSquadSize() == 7)
		EncounterInfo.EncounterID='MOCX_Teamx7';

	if(GetMaxSquadSize() >= 8)
		EncounterInfo.EncounterID='MOCX_Teamx8';

	if(GetMaxSquadSize() == 9)
		EncounterInfo.EncounterID='MOCX_Teamx9';

	if(GetMaxSquadSize() >= 10)
		EncounterInfo.EncounterID='MOCX_Teamx10';


	AlongLOP = `SYNC_RAND(15) - `SYNC_RAND(9);
	FromLOP = `SYNC_RAND(15) - `SYNC_RAND(9);
	EncounterInfo.EncounterZoneOffsetAlongLOP = AlongLOP; //randomized locations
	EncounterInfo.EncounterZoneOffsetFromLOP = FromLOP;
	EncounterInfo.EncounterZoneWidth=9.0;

	TacticalMissionManager = `TACTICALMISSIONMGR;
	SpawnManager = `SPAWNMGR;
	AlienLeaderWeight = 0.0;
	AlienFollowerWeight = 0.0;

	//TacticalMissionManager.GetConfigurableEncounter( EncounterInfo.EncounterID, Encounter, MissionState.SelectedMissionData.ForceLevel, MissionState.SelectedMissionData.AlertLevel );
	Encounter.EncounterID = EncounterInfo.EncounterID;

	CurrentSquad = GetFirstAvailableCrew(NewGameState);
	Encounter.MaxSpawnCount = CurrentSquad.Length;


	if(bAdvancedMECs)
	{
	i = `SYNC_RAND(100);
		if(i <= AdvancedMECChance)
		{
		NamesToAdd.AddItem('AdvMec_MOCX');
		}

	}

	if(!bHasCoil)
	{
		for(i = 0; i < CurrentSquad.Length; i++)
		{
			Unit = CurrentSquad[i];
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

			`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
			NamesToAdd.AddItem(InfoState.GetClassName());
		}
	}

	if(bHasCoil && !bHasPlasma)
	{
		for(i = 0; i < CurrentSquad.Length; i++)
		{
			Unit = CurrentSquad[i];
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

			`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
			NamesToAdd.AddItem(name(InfoState.GetClassName() $ "_M2"));
		}
	}

	if(bHasPlasma)
	{
		for(i = 0; i < CurrentSquad.Length; i++)
		{
			Unit = CurrentSquad[i];
			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

			`log("Dark XCom: found soldier class - " $ InfoState.GetClassName(), ,'DarkXCom');
			NamesToAdd.AddItem(name(InfoState.GetClassName() $ "_M3"));
		}
	}

	Encounter.ForceSpawnTemplateNames = NamesToAdd;
	Encounter.TeamToSpawnInto = eTeam_Alien;
	Encounter.ReinforcementCountdown = 1;

	TacticalMissionManager.GetMissionSchedule(MissionState.SelectedMissionData.SelectedMissionScheduleName, SelectedMissionSchedule);

	if( MissionState.SelectedMissionData.SelectedMissionScheduleName == '' )
	{
		`log("Dark XCOM: we were somehow given a missionstate with no schedule: fix it ourselves", , 'DarkXCom');
		MissionState = XComGameState_MissionSite(NewGameState.ModifyStateObject(class'XComGameState_MissionSite', MissionState.ObjectID));
		MissionState.UpdateSelectedMissionData();
		TacticalMissionManager.GetMissionSchedule(MissionState.SelectedMissionData.SelectedMissionScheduleName, SelectedMissionSchedule);
	}
	NewEncounter = EmptyEncounter;

	`log("Dark XCom: Current Encounter ID is " $ Encounter.EncounterID, ,'DarkXCom');

	NewEncounter.SelectedEncounterName = Encounter.EncounterID;
	LeaderForceLevelMod = SpawnManager.GetLeaderForceLevelMod();

	// select the group members who will fill out this encounter group
	AlienLeaderWeight += SelectedMissionSchedule.AlienToAdventLeaderRatio;
	AlienFollowerWeight += SelectedMissionSchedule.AlienToAdventFollowerRatio;
	SpawnManager.SelectSpawnGroup(NewEncounter.EncounterSpawnInfo, MissionState.GeneratedMission.Mission, SelectedMissionSchedule, MissionState.GeneratedMission.Sitreps, Encounter ,MissionState.SelectedMissionData.ForceLevel, MissionState.SelectedMissionData.AlertLevel, SelectedCharacterTemplates, AlienLeaderWeight, AlienFollowerWeight, LeaderForceLevelMod);

	//NewEncounter.EncounterSpawnInfo.SelectedCharacterTemplateNames = NamesToAdd;
	NewEncounter.EncounterSpawnInfo.EncounterZoneWidth = EncounterInfo.EncounterZoneWidth;
	NewEncounter.EncounterSpawnInfo.EncounterZoneDepth = ((EncounterInfo.EncounterZoneDepthOverride >= 0.0) ? EncounterInfo.EncounterZoneDepthOverride : SelectedMissionSchedule.EncounterZonePatrolDepth);
	NewEncounter.EncounterSpawnInfo.EncounterZoneOffsetFromLOP = EncounterInfo.EncounterZoneOffsetFromLOP;
	NewEncounter.EncounterSpawnInfo.EncounterZoneOffsetAlongLOP = EncounterInfo.EncounterZoneOffsetAlongLOP;

	NewEncounter.EncounterSpawnInfo.SpawnLocationActorTag = EncounterInfo.SpawnLocationActorTag;

	MissionState.SelectedMissionData.SelectedEncounters.AddItem(NewEncounter);

}


function array<XComGameState_Unit> GetFirstAvailableCrew(XcomGameState NewGameState)
{
	local XComGameState_Unit_DarkXComInfo InfoState, NewInfoState;
	local XComGameState_Unit					Unit;
	local array<XComGameState_Unit> ArrayToSend;
	local int i;

	for(i = 0; i < Crew.Length; i++)
	{
		if(ArrayToSend.Length >= 4)
		{
			`log("Dark XCom: Finished making squad.", ,'DarkXCom');
			break;
		}

		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Crew[i].ObjectID));
		if(Unit == none)
		{
			`log("Dark XCom: Could not find valid unit.", ,'DarkXCom');
			continue;
		}

		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

		if(InfoState == none)
			`log("Dark XCom: could not find infostate for unit.", ,'DarkXCom');


		if(InfoState != none)
		{
			NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));
			NewGameState.AddStateObject(NewInfoState);

			if(NewInfoState.bIsAlive && !NewInfoState.bInSquad) //is alive and is done healing
			{
			`log("Added following MOCX soldier to squad: " $ class'UnitDarkXComUtils'.static.GetFullName(Unit), ,'DarkXCom');
				ArrayToSend.AddItem(Unit);
				NewInfoState.bInSquad = true;
				Squad.AddItem(Crew[i]);
			}
		}

	}

	return ArrayToSend;
}