//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_DarkXCOM.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_DarkXCOMRedux extends X2DownloadableContentInfo config(DarkXCom);

var bool ForceMOCX;

// moved from UISL_TacticalStart
var config array<name> TemplatesToCheck;


var config(Content) array<BackgroundPosterOptions> m_arrBackgroundOptions;

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
//	local XComGameStateHistory History;


//	History = class'XComGameStateHistory'.static.GetGameStateHistory();
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
//	local XComGameState_Tech TechState;
	local X2StrategyElementTemplateManager	StratMgr;
	local array<name> ResearchNames;
	local int i;

	//In this method, we demonstrate functionality that will add ExampleWeapon to the player's inventory when loading a saved
	//game. This allows players to enjoy the content of the mod in campaigns that were started without the mod installed.
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	History = `XCOMHISTORY;	

	//Create a pending game state change
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Research Templates");

	ResearchNames.AddItem('RM_DecryptChip');
	ResearchNames.AddItem('RM_BasicPCS');
	ResearchNames.AddItem('RM_AdvPCS');
	ResearchNames.AddItem('RM_SupPCS');
	ResearchNames.AddItem('RM_ProduceChip');

	//Find tech templates
	for (i = 0; i < ResearchNames.Length; i++)
	{
		if ( !IsResearchInHistory(ResearchNames[i]) )
		{
			TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate(ResearchNames[i]));
			NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
		}
	}

	//Commit the state change into the history.
	History.AddGameStateToHistory(NewGameState);
}

///////// MOCX Mission Squad Setup
// Missions are set up in several steps. When the player goes on mission that has been determined to have a MOCX squad,
// MOCXHQ sets up its squad and creates a "dummy" encounter that makes the AISpawnMgr spawn the MOCX soldiers (OnPreMission)
// When each of the unit sets up its abilities, we do our processing to link them up
// This allows us to keep everything nicely contained in the start state without having to mess around with ScreenListeners
// This also makes reinforcements easier if MOCX decided it wants to send reinforcements to their squads

/// <summary>
/// Called just before the player launches into a tactical a mission while this DLC / Mod is installed.
/// </summary>
/// 
static event OnPreMission(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	History = class'XComGameStateHistory'.static.GetGameStateHistory();

	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
	if((DarkXComHQ.bIsActive  && !DarkXComHQ.bIsDestroyed) || default.ForceMOCX || IsMOCXPlotMission(MissionState))
	{
		//(DarkXComHQ.bSITREPActive && HasSITREP(MissionState)) || (default.ForceMOCX && HasSITREP(MissionState))
		if( HasSITREP(MissionState) || IsMOCXPlotMission(MissionState))
		{
			DarkXComHQ.PreMissionUpdate(NewGameState, MissionState, IsMOCXPlotMission(MissionState));
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

static function bool IsMOCXPlotMission(XComGameState_MissionSite MissionState)
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


/// <summary>
/// Called from XComGameState_Unit:GatherUnitAbilitiesForInit after the game has built what it believes is the full list of
/// abilities for the unit based on character, class, equipment, et cetera. You can add or remove abilities in SetupData.
/// </summary>
// This function is called during the start state setup. It lets us do pretty much anything with the start state for a given unit
static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local XComGameStateHistory History;
	// game state variables
	local XComGameState_Unit SquadUnitState; 
	local XComGameState_Unit_DarkXComInfo SquadUnitInfoState;
	local bool bUnitIsStrategyUnit;

	// only do our handling for MOCX units
	if (!IsValidDarkTemplate(UnitState.GetMyTemplateName()))
		return;

	History = `XCOMHISTORY;
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	bUnitIsStrategyUnit = UnitIsStrategyMOCXUnit(UnitState.GetReference(), DarkXComHQ);
	// this should only ever be valid without a StartState
	`assert(bUnitIsStrategyUnit == (StartState == none));
	if (FindSquadUnitForCombatUnit(UnitState, DarkXComHQ, StartState, SquadUnitState, SquadUnitInfoState))
	{
		// gather their abilities. this function should always be run, and does not touch the game state! It may use an existing one though
		GatherAbilitiesForUnit(SquadUnitState, SquadUnitInfoState, UnitState, StartState, SetupData);
		// we only modify those if UnitState is a proxy unit
		if (StartState != none)
		{
			// copy over the appearance for our units
			UpdateCombatUnitAppearance(UnitState, SquadUnitState);
			// and apply stat bonuses
			ApplyStatBonuses(UnitState, SquadUnitState, SquadUnitInfoState);
		}
	}
	else
	{
		`log("Dark XCOM: Failed to find a squad unit for" @ UnitState.GetMyTemplateName(), ,'DarkXCom');
	}
}


static function ApplyStatBonuses(XComGameState_Unit CombatUnitState, XComGameState_Unit StrategyUnitState, XComGameState_Unit_DarkXComInfo InfoState)
{
	local X2EquipmentTemplate SimTemplate;
	local X2ItemTemplateManager ItemTemplateManager;
	local int i;
	local float MaxStat, NewMaxStat;
	local StatBoost Boost;

	`log("Dark XCom: applying rank stats.", ,'DarkXCom');
	MaxStat = CombatUnitState.GetMaxStat(eStat_Will);
	NewMaxStat = MaxStat + InfoState.RankWill;
	CombatUnitState.SetBaseMaxStat(eStat_Will, NewMaxStat);
	CombatUnitState.SetCurrentStat(eStat_Will, NewMaxStat);
	
	`log("Dark XCom: added " $ InfoState.RankWill $ " Will.", ,'DarkXCom');

	MaxStat = CombatUnitState.GetMaxStat(eStat_Dodge);
	NewMaxStat = MaxStat + InfoState.RankDodge;
	CombatUnitState.SetBaseMaxStat(eStat_Dodge, NewMaxStat);
	CombatUnitState.SetCurrentStat(eStat_Dodge, NewMaxStat);
	
	`log("Dark XCom: added " $ InfoState.RankDodge $ " Dodge.", ,'DarkXCom');


	MaxStat = CombatUnitState.GetMaxStat(eStat_HP);
	NewMaxStat = MaxStat + InfoState.RankHP;
	CombatUnitState.SetBaseMaxStat(eStat_HP, NewMaxStat);
	CombatUnitState.SetCurrentStat(eStat_HP, NewMaxStat);

	`log("Dark XCom: added " $ InfoState.RankHP $ " HP.", ,'DarkXCom');

	
	MaxStat = CombatUnitState.GetMaxStat(eStat_Offense);
	NewMaxStat = MaxStat + InfoState.RankAim;
	CombatUnitState.SetBaseMaxStat(eStat_Offense, NewMaxStat);
	CombatUnitState.SetCurrentStat(eStat_Offense, NewMaxStat);
	
	`log("Dark XCom: added " $ InfoState.RankAim $ " Aim.", ,'DarkXCom');
												
	MaxStat = CombatUnitState.GetMaxStat(eStat_PsiOffense);
	NewMaxStat = MaxStat + InfoState.RankPsi;
	CombatUnitState.SetBaseMaxStat(eStat_PsiOffense, NewMaxStat);
	CombatUnitState.SetCurrentStat(eStat_PsiOffense, NewMaxStat);
	
	`log("Dark XCom: added " $ InfoState.RankPsi $ " PsiOffense.", ,'DarkXCom');


	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	SimTemplate = X2EquipmentTemplate(ItemTemplateManager.FindItemTemplate(InfoState.EquippedPCS));
	if(SimTemplate != none)
	{
		for(i = 0; i < SimTemplate.StatsToBoost.Length; i++)
		{
			`log("Dark XCom: applying PCS stats.", ,'DarkXCom');
			MaxStat = CombatUnitState.GetMaxStat(SimTemplate.StatsToBoost[i]);
			ItemTemplateManager.GetItemStatBoost(SimTemplate.StatBoostPowerLevel, SimTemplate.StatsToBoost[i], Boost);
			NewMaxStat = MaxStat + Boost.Boost;
			CombatUnitState.SetBaseMaxStat(SimTemplate.StatsToBoost[i], NewMaxStat);
			CombatUnitState.SetCurrentStat(SimTemplate.StatsToBoost[i], NewMaxStat);
		}
		// PCS abilities are handled below
	}
}

static function UpdateCombatUnitAppearance(XComGameState_Unit CombatUnitState, XComGameState_Unit StrategyUnitState)
{
	CombatUnitState.SetTAppearance(StrategyUnitState.kAppearance);
	CombatUnitState.SetCharacterName(StrategyUnitState.GetFirstName(), StrategyUnitState.GetLastName(), StrategyUnitState.GetNickName());
}



// return true if the unit is NOT a proxy unit
static function bool UnitIsStrategyMOCXUnit(StateObjectReference UnitRef, XComGameState_HeadquartersDarkXCom DarkXComHQ)
{
	return DarkXComHQ.Crew.Find('ObjectID', UnitRef.ObjectID) != INDEX_NONE || DarkXComHQ.DeadCrew.Find('ObjectID', UnitRef.ObjectID) != INDEX_NONE || DarkXComHQ.Squad.Find('ObjectID', UnitRef.ObjectID) != INDEX_NONE;
}


// given a proxy unit and the MOCX HQ, find an appropriate unit from the squad for it
// and add it (and its component state) to the StartState, and mark the component as already used
// if StartState is none, this unit is assumed to be an actual MOCX strategy unit, and no game state operations are done
static function bool FindSquadUnitForCombatUnit(const XComGameState_Unit CombatUnit, const XComGameState_HeadquartersDarkXCom DarkXComHQ, XComGameState StartState, out XComGameState_Unit SquadUnitState, out XComGameState_Unit_DarkXComInfo SquadUnitInfoState)
{
	local int i;
	local XComGameState_Unit TempUnit;
	local XComGameState_Unit_DarkXComInfo TempInfo;
	local XComGameStateHistory History;
	History = `XCOMHISTORY;
	if (StartState != none)
	{
		for (i = 0; i < DarkXComHQ.Squad.Length; i++)
		{
			TempUnit = XComGameState_Unit(History.GetGameStateForObjectID(DarkXComHQ.Squad[i].ObjectID));
			// pass start state to optionally retrieve any updated state
			TempInfo = class'UnitDarkXComUtils'.static.GetDarkXComComponent(TempUnit, StartState);
			if (TempInfo != none && TempInfo.bInSquad && !TempInfo.bAlreadyHandled && MatchNames(CombatUnit, TempInfo.GetClassName()))
			{
				SquadUnitState = XComGameState_Unit(StartState.ModifyStateObject(class'XComGameState_Unit', TempUnit.ObjectID));
				SquadUnitInfoState = XComGameState_Unit_DarkXComInfo(StartState.ModifyStateObject(class'XComGameState_Unit_DarkXComInfo', TempInfo.ObjectID));
				SquadUnitInfoState.bAlreadyHandled = true;
				SquadUnitInfoState.AssignedUnit = CombatUnit.GetReference();
				return true;
			}
		}
		return false;
	}
	else
	{
		// easy case
		SquadUnitState = CombatUnit;
		SquadUnitInfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(CombatUnit);
		return true;
	}
}


static function bool IsValidDarkTemplate(name UnitBeingChecked)
{
	local name NameCheck;

	foreach default.TemplatesToCheck(NameCheck)
	{
		if(UnitBeingChecked == NameCheck)
		{
			return true;
		}
	}
	return false;
}

// relies on a nomenclature where all unit template names are composed of InfoName and optionally a tier suffix separated with an underscore
// assuming Unit is a valid MOCX unit, and InfoName is the "group" name
static function bool MatchNames(XComGameState_Unit Unit, name InfoName)
{
	local name ActualName;
	local int splitIdx;

	ActualName = Unit.GetMyTemplateName();
	`log("Dark XCOM: comparing" @ ActualName @ "with" @ InfoName, ,'DarkXCom');
	if(InfoName == '')
	{
		`log("Dark XCOM: no infostate name for name check.", ,'DarkXCom');
		return false;
	}

	if (ActualName == InfoName)
		return true;

	// search for an underscore from the right
	splitIdx = InStr(ActualName, "_", true);
	if (splitIdx != INDEX_NONE)
	{
		// when we drop the suffix, do our names match now?
		if (name(Left(ActualName, splitIdx)) == InfoName)
		{
			return true;
		}
	}
	`log("Dark XCOM: FAIL", ,'DarkXCom');
	return false;
}


// this is a modified copy of the XComGameState_Unit function
// This function is kinda big because it has to repeat many steps from the original one, such as overrides, additional abilities, ...
static function GatherAbilitiesForUnit(XComGameState_Unit StrategyUnitState, XComGameState_Unit_DarkXComInfo InfoState, XComGameState_Unit CombatUnitState, XComGameState StartState, out array<AbilitySetupData> arrData)
{
	local X2AbilityTemplateManager AbilityTemplateManager;
	local array<SoldierClassAbilityType> EarnedSoldierAbilities;
	local X2AbilityTemplate AbilityTemplate;
	local name AbilityName;

	local int i, j, OverrideIdx;

	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item InventoryItem;

	local AbilitySetupData Data, EmptyData;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	EarnedSoldierAbilities = InfoState.GetUnitEarnedSoldierAbilities();
	CurrentInventory = CombatUnitState.GetAllInventoryItems(StartState);

	for(i = 0; i < EarnedSoldierAbilities.Length; i++)
	{
		AbilityName = EarnedSoldierAbilities[i].AbilityName;
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityName);
		if( AbilityTemplate != none &&
			(!AbilityTemplate.bUniqueSource || arrData.Find('TemplateName', AbilityTemplate.DataName) == INDEX_NONE))
		{
			Data = EmptyData;
			Data.TemplateName = AbilityName;
			Data.Template = AbilityTemplate;
			if (EarnedSoldierAbilities[i].ApplyToWeaponSlot != eInvSlot_Unknown)
			{
				foreach CurrentInventory(InventoryItem)
				{
					if (InventoryItem.bMergedOut)
						continue;
					if (InventoryItem.InventorySlot == EarnedSoldierAbilities[i].ApplyToWeaponSlot)
					{
						Data.SourceWeaponRef = InventoryItem.GetReference();

						if (EarnedSoldierAbilities[i].ApplyToWeaponSlot != eInvSlot_Utility)
						{
							//  stop searching as this is the only valid item
							break;
						}
						else
						{
							//  add this item if valid and keep looking for other utility items
							if (InventoryItem.GetWeaponCategory() == EarnedSoldierAbilities[i].UtilityCat)							
							{
								arrData.AddItem(Data);
							}
						}
					}
				}
				//  send an error if it wasn't a utility item (primary/secondary weapons should always exist)
				if (Data.SourceWeaponRef.ObjectID == 0 && EarnedSoldierAbilities[i].ApplyToWeaponSlot != eInvSlot_Utility)
				{
					`RedScreen("Soldier ability" @ AbilityName @ "wants to attach to slot" @ EarnedSoldierAbilities[i].ApplyToWeaponSlot @ "but no weapon was found there.");
				}
			}
			//  add data if it wasn't on a utility item
			if (EarnedSoldierAbilities[i].ApplyToWeaponSlot != eInvSlot_Utility)
			{
				if (AbilityTemplate.bUseLaunchedGrenadeEffects)     //  could potentially add another flag but for now this is all we need it for -jbouscher
				{
					//  populate a version of the ability for every grenade in the inventory
					foreach CurrentInventory(InventoryItem)
					{
						if (InventoryItem.bMergedOut) 
							continue;

						if (X2GrenadeTemplate(InventoryItem.GetMyTemplate()) != none)
						{ 
							Data.SourceAmmoRef = InventoryItem.GetReference();
							arrData.AddItem(Data);
						}
					}
				}
				else
				{
					arrData.AddItem(Data);
				}
			}
		}
	}

	//  Check for ability overrides - do it BEFORE adding additional abilities so we don't end up with extra ones we shouldn't have
	for (i = arrData.Length - 1; i >= 0; --i)
	{
		if (arrData[i].Template.OverrideAbilities.Length > 0)
		{
			for (j = 0; j < arrData[i].Template.OverrideAbilities.Length; ++j)
			{
				OverrideIdx = arrData.Find('TemplateName', arrData[i].Template.OverrideAbilities[j]);
				if (OverrideIdx != INDEX_NONE)
				{
					arrData[OverrideIdx].Template = arrData[i].Template;
					arrData[OverrideIdx].TemplateName = arrData[i].TemplateName;
					//  only override the weapon if requested. otherwise, keep the original source weapon for the override ability
					if (arrData[i].Template.bOverrideWeapon)
						arrData[OverrideIdx].SourceWeaponRef = arrData[i].SourceWeaponRef;
				
					arrData.Remove(i, 1);
					break;
				}
			}
		}
	}
	//  Add any additional abilities
	for (i = 0; i < arrData.Length; ++i)
	{
		foreach arrData[i].Template.AdditionalAbilities(AbilityName)
		{
			AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityName);
			if( AbilityTemplate != none &&
				(!AbilityTemplate.bUniqueSource || arrData.Find('TemplateName', AbilityTemplate.DataName) == INDEX_NONE) &&
				// RM Hack
				AbilityTemplate.DataName == 'BlademasterSlice')
			{
				Data = EmptyData;
				Data.TemplateName = AbilityName;
				Data.Template = AbilityTemplate;
				Data.SourceWeaponRef = arrData[i].SourceWeaponRef;
				arrData.AddItem(Data);
			}
		}
	}
	//  Check for ability overrides AGAIN - in case the additional abilities want to override something
	for (i = arrData.Length - 1; i >= 0; --i)
	{
		if (arrData[i].Template.OverrideAbilities.Length > 0)
		{
			for (j = 0; j < arrData[i].Template.OverrideAbilities.Length; ++j)
			{
				OverrideIdx = arrData.Find('TemplateName', arrData[i].Template.OverrideAbilities[j]);
				if (OverrideIdx != INDEX_NONE)
				{
					arrData[OverrideIdx].Template = arrData[i].Template;
					arrData[OverrideIdx].TemplateName = arrData[i].TemplateName;
					//  only override the weapon if requested. otherwise, keep the original source weapon for the override ability
					if (arrData[i].Template.bOverrideWeapon)
						arrData[OverrideIdx].SourceWeaponRef = arrData[i].SourceWeaponRef;
				
					arrData.Remove(i, 1);
					break;
				}
			}
		}
	}
	// for any abilities that specify a default source slot and do not have a source item yet,
	// set that up now
	for( i = 0; i < arrData.Length; ++i )
	{
		if( arrData[i].Template.DefaultSourceItemSlot != eInvSlot_Unknown && arrData[i].SourceWeaponRef.ObjectID <= 0 )
		{
			//	terrible terrible thing to do but it's the easiest at this point.
			//	everyone else has a gun for their primary weapon - templars have it as their secondary.
			if (arrData[i].Template.DefaultSourceItemSlot == eInvSlot_PrimaryWeapon && CombatUnitState.GetMyTemplateName() == 'TemplarSoldier')
				arrData[i].SourceWeaponRef = CombatUnitState.GetItemInSlot(eInvSlot_SecondaryWeapon).GetReference();
			else
				arrData[i].SourceWeaponRef = CombatUnitState.GetItemInSlot(arrData[i].Template.DefaultSourceItemSlot).GetReference();
		}
	}

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
	local XComGameState_Unit EnemyUnit, CurrentDarkUnit, KilledUnit;
	local XComGameState_Unit_DarkXComInfo InfoState, NewInfoState;
	local array<StateObjectReference> Squad, TacticalUnitKills;
	local int i, k;
	local LWTuple AchTuple;
	local LWTValue Value;

	History = `XCOMHISTORY;
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));

	if(DarkXComHQ.Squad.Length == 0 && !DarkXComHQ.bSITREPActive)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Post Mission --  no deployment");

		DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
		DarkXComHQ.LastMission_bWasActive = false;
		DarkXComHQ.LastMission_Squad.Length = 0;
		`GAMERULES.SubmitGameState(NewGameState);
		return; //no need to fire if there was no MOCX and no SITREP active.. Since we only generate a squad once the player starts a mission with MOCX in, this also doubles as a "did the player actually do a MOCX mission" check.
	}

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
				NewInfoState.bAlreadyHandled = false;
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
			// process kills -- all units EnemyUnit killed on the battlefield that spawned in on the XCOM team
			// are added to the Unit Info Kill List
			TacticalUnitKills = EnemyUnit.GetKills();
			for (k = 0; k < TacticalUnitKills.Length; k++)
			{
				KilledUnit = XComGameState_Unit(History.GetGameStateForObjectID(TacticalUnitKills[i].ObjectID));
				// bit of naive code here, but it works in our case. We don't want to count mimic beacons, bonus advent / resistance units, ...
				if (KilledUnit.IsSoldier())
				{
					InfoState.KilledXComUnits.AddItem(TacticalUnitKills[i]);
				}
			}

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
		// record last mission state
		DarkXComHQ.LastMission_bWasActive = true;
		DarkXComHQ.LastMission_Squad = Squad;

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



/// <summary>
/// Called after the player exits the post-mission sequence while this DLC / Mod is installed.
/// </summary>
static event OnExitPostMissionSequence()
{
	CheckForPosterUpdates();
}

static function CheckForPosterUpdates()
{
	local XComGameStateHistory History;
	local XComGameState_Unit_DarkXComInfo InfoState, OriginalInfoState;
	local X2Photobooth_MOCXStrategyAutoGen AutoGen;
	local StateObjectReference OwningUnit;

	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local XComGameState_BattleData BattleData;

	AutoGen = class'X2Photobooth_MOCXStrategyAutoGen'.static.GetMOCXAutoGen();
	History = `XCOMHISTORY;

	// Search for any MOCX soldiers that have more kills now than when this game session started (tactical end game)
	// and request updated posters for units that have a changed number of kills
	// we can do it that way because we handle kills in OnPostMission
	foreach History.IterateByClassType(class'XComGameState_Unit_DarkXComInfo', InfoState)
	{
		OriginalInfoState = XComGameState_Unit_DarkXComInfo(History.GetOriginalGameStateRevision(InfoState.ObjectID));
		if (OriginalInfoState != none && InfoState.KilledXCOMUnits.Length > OriginalInfoState.KilledXCOMUnits.Length)
		{
			OwningUnit.ObjectID = InfoState.OwningObjectID;
			// push a refresh of this unit's kill count poster
			AutoGen.AddRequestSingleUnit(OwningUnit, eMOCXAGT_PromotedSoldier);
		}
	}
	// check whether MOCX was deployed on this mission and the mission was a FAIL
	// This is always worth a poster
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	if (DarkXComHQ.LastMission_bWasActive)
	{
		`log("Dark XCOM: active on the last mission", ,'DarkXCom');
		if (BattleData.bLocalPlayerWon)
		{
			// if we won, only add a poster if we completely annihilated them -- that is, they are all DEAD
			if (AllMOCXUnitsDead(DarkXComHQ.LastMission_Squad))
			{
				`log("Dark XCOM: all ded", ,'DarkXCom');
				// we won and kicked their arse
				AutoGen.AddRequest(DarkXComHQ.LastMission_Squad, eMOCXAGT_DefeatedSquad);
			}
		}
		else
		{
			// we lost :( Hooray for MOCX though
			// this does not mean that the squad survived, it just means that XCOM failed. good enough
			`log("Dark XCOM: MOCX won the battle", ,'DarkXCom');
			AutoGen.AddRequest(DarkXComHQ.LastMission_Squad, eMOCXAGT_VictoriousSquad);
		}
	}
	AutoGen.RequestPhotos();
}

static function bool AllMOCXUnitsDead(array<StateObjectReference> MOCXUnits)
{
	local XComGameStateHistory History;
	local XComGameState_Unit SquadUnitState;
	local int i;

	History = `XCOMHISTORY;

	for (i = 0; i < MOCXUnits.Length; i++)
	{
		SquadUnitState = XComGameState_Unit(History.GetGameStateForObjectID(MOCXUnits[i].ObjectID));
		if (class'UnitDarkXComUtils'.static.IsAlive(SquadUnitState))
		{
			return false;
		}
	}
	return true;
}

///////// Cheats

exec function ForceCheckForPosterUpdates()
{
	CheckForPosterUpdates();
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


exec function MOCXPosterizeOneUnit()
{
	local X2Photobooth_MOCXStrategyAutoGen AutoGen;
	local array<StateObjectReference> Units;
	local XComGameState_HeadquartersDarkXCom MOCXHQ;

	AutoGen = class'X2Photobooth_MOCXStrategyAutoGen'.static.GetMOCXAutoGen();
	MOCXHQ = XComGameState_HeadquartersDarkXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	if (AutoGen != none && MOCXHQ != none)
	{
		Units.AddItem(MOCXHQ.Crew[0]);
		AutoGen.AddRequest(Units, eMOCXAGT_PromotedSoldier);
		`log("Added unit to poster request", ,'DarkXCom');
		AutoGen.RequestPhotos();
	}
}

exec function MOCXSimulateDefeat(optional int iNumSld = 4)
{
	local X2Photobooth_MOCXStrategyAutoGen AutoGen;
	local array<StateObjectReference> Units;
	local int i;
	local XComGameState_HeadquartersDarkXCom MOCXHQ;

	AutoGen = class'X2Photobooth_MOCXStrategyAutoGen'.static.GetMOCXAutoGen();
	MOCXHQ = XComGameState_HeadquartersDarkXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	if (AutoGen != none && MOCXHQ != none)
	{
		Units.Length = 0;
		for (i = 0; i < Min(MOCXHQ.Crew.Length, iNumSld); i++)
		{
			
			Units.AddItem(MOCXHQ.Crew[i]);
		}
		`log("Added squad to poster request", ,'DarkXCom');
		AutoGen.AddRequest(Units, eMOCXAGT_DefeatedSquad);
		AutoGen.RequestPhotos();
	}
}

////// OnPostTemplatesCreated Section

static event OnPostTemplatesCreated()
{

	EditDarkTemplates();
	EditWeaponTemplates();
	EditSITREPTemplates();
	EditUpgradeTemplates();
	EditRewardTemplates();
	EditPhotoboothConfigs();
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
//	local X2SitRepTemplateManager SitRepMgr;
//	local X2DataTemplate DataTemplate;
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
//	local name						WeaponName;
//	local array<X2DataTemplate>		DifficultyTemplates;
//	local X2DataTemplate			DifficultyTemplate;


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

static function EditPhotoboothConfigs()
{
	local X2Photobooth Photobooth;
	local int i;

	Photobooth = X2Photobooth(class'Engine'.static.FindClassDefaultObject("XComGame.X2Photobooth"));
	for (i = 0; i < default.m_arrBackgroundOptions.Length; i++)
	{
		Photobooth.m_arrBackgroundOptions.AddItem(default.m_arrBackgroundOptions[i]);
	}
}