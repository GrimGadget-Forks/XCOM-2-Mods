class UIScreenListener_TacticalStart extends UIScreenListener config (DarkXCom) deprecated;
/*
struct AdditionalAbilityNames
{
	var name AbilityName;
	var EInventorySlot InventorySlot; 
};

var config array<name> TemplatesToCheck;
// This event is triggered after a screen is initialized
event OnInit(UIScreen Screen)
{
	// not needed since we aren't going to try and install the AlienCustomization manager when loading into tactical mission
	//class'X2DownloadableContentInfo_LWAlienPack'.static.AddAndRegisterCustomizationManager();
	if(UITacticalHud(Screen) != none)
	{
		StartChanging();
	}
}

function StartChanging()
{
	local XComGameState_Unit EnemyUnit;
	local XGBattle_SP Battle;
	local array<XComGameState_Unit> AllUnits;
	local array<XComGameState_Unit> UnitsToUpdate;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	UnitsToUpdate.Length = 0;

	Battle = XGBattle_SP(`BATTLE);
	if(Battle == none)
	{
	`log("Dark XCOM: Could not find battle data to update squad mid mission. This mod has officialy broke. :(", ,'DarkXCom');
	return;
	}

	Battle.GetAIPlayer().GetOriginalUnits(AllUnits, true, true);

	foreach AllUnits(EnemyUnit)
	{
		if(IsValidDarkTemplate(EnemyUnit.GetMyTemplateName()))
		{
			UnitsToUpdate.AddItem(EnemyUnit);
		}
	}

	TryToUpdateAllAliens(UnitsToUpdate, DarkXComHQ, History);
}

function bool IsValidDarkTemplate(name UnitBeingChecked)
{
	local name NameCheck;

	foreach TemplatesToCheck(NameCheck)
	{
		if(UnitBeingChecked == NameCheck)
		{
		`log("Dark XCom: found valid Dark template", ,'DarkXCom');
			return true;
		}
	}



	return false;
}

function bool MatchNames(XComGameState_Unit Unit, name InfoName)
{
	local name ActualName;

	ActualName = Unit.GetMyTemplateName();
	if(InfoName == '')
	{
		`log("Dark XCOM: no infostate name for name check.", ,'DarkXCom');
		return false;
	}
	if(Unit.GetMyTemplateName() == 'DarkGrenadier_M2' || Unit.GetMyTemplateName() == 'DarkGrenadier_M3')
	{
	ActualName = 'DarkGrenadier';

	}

	if(Unit.GetMyTemplateName() == 'DarkSpecialist_M2' || Unit.GetMyTemplateName() == 'DarkSpecialist_M3')
	{
	ActualName = 'DarkSpecialist';

	}

	if(Unit.GetMyTemplateName() == 'DarkRanger_M2' || Unit.GetMyTemplateName() == 'DarkRanger_M3')
	{
	ActualName = 'DarkRanger';

	}

	if(Unit.GetMyTemplateName() == 'DarkSniper_M2' || Unit.GetMyTemplateName() == 'DarkSniper_M3')
	{
	ActualName = 'DarkSniper';

	}

	if(Unit.GetMyTemplateName() == 'DarkPsiAgent_M2' || Unit.GetMyTemplateName() == 'DarkPsiAgent_M3')
	{
	ActualName = 'DarkPsiAgent';

	}


	if(ActualName == InfoName)
	{
	`log("Dark XCOM: Found right class name.", ,'DarkXCom');
		return true;
	}

	`log("Dark XCOM: did not have right class name", ,'DarkXCom');
	return false;

}

//cycle through remaining aliens and update their materials if their pawns have loaded
function TryToUpdateAllAliens(array<XComGameState_Unit> UnitsToUpdate, XComGameState_HeadquartersDarkXCom DarkXComHQ, XComGameStateHistory History)
{
	local XComGameState_Unit Unit, CombatUnit;
	local XComGameState_Unit_DarkXComInfo InfoState, NewInfoState;
	local XComGameState NewGameState;
	local XComGameStateContext_TacticalGameRule NewGameStateContext;
	local int i;
	local X2TacticalGameRuleset Rules;
	local XGUnit UnitVisualizer;
	local bool SameClass;

	foreach UnitsToUpdate(CombatUnit)
	{

		for(i = 0; i < DarkXComHQ.Squad.Length; i++)
		{
			NewGameStateContext = class'XComGameStateContext_TacticalGameRule'.static.BuildContextFromGameRule(eGameRule_UnitAdded);
			NewGameState = History.CreateNewGameState(true, NewGameStateContext);

			Unit = XComGameState_Unit(History.GetGameStateForObjectID(DarkXComHQ.Squad[i].ObjectID));

			InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

			SameClass = MatchNames(CombatUnit, InfoState.GetClassName());

			if(InfoState != none && InfoState.bInSquad && !InfoState.bAlreadyHandled && SameClass)
			{		
				CombatUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', CombatUnit.ObjectID));
			//	SetAppearance(CombatUnit, Unit);
				//CombatUnit.SetTAppearance(Unit.kAppearance);
				CombatUnit.SetCharacterName(Unit.GetFirstName(), Unit.GetLastName(), Unit.GetNickName());
				CombatUnit.SetCountry('');
				NewGameState.AddStateObject(CombatUnit);

				ApplyAbilities(CombatUnit, InfoState, NewGameState, DarkXComHQ, History);
				NewInfoState = XComGameState_Unit_DarkXComInfo(NewGameState.CreateStateObject(class'XComGameState_Unit_DarkXComInfo', InfoState.ObjectID));
				NewGameState.AddStateObject(NewInfoState);
				NewInfoState.bAlreadyHandled = true;
				NewInfoState.AssignedUnit = CombatUnit.GetReference();
				break;
			}

		}

		if (NewGameState.GetNumGameStateObjects() > 0)
		{
			Rules = `TACTICALRULES;
			//Rules.InitializeUnitAbilities(NewGameState, CombatUnit);
			XComGameStateContext_TacticalGameRule(NewGameState.GetContext()).UnitRef = CombatUnit.GetReference();
			Rules.SubmitGameState(NewGameState);

		//	UnitVisualizer = XGUnit(History.GetVisualizer(CombatUnit.ObjectID));
		//	UnitVisualizer.ApplyLoadoutFromGameState(CombatUnit, NewGameState);

			CombatUnit.FindOrCreateVisualizer(NewGameState);
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Reserve Unit Abilities");
			Rules.InitializeUnitAbilities(NewGameState, Unit);
			Rules.SubmitGameState(NewGameState);

		}
		if(NewGameState != none && NewGameState.GetNumGameStateObjects() <= 0)
		{
			History.CleanupPendingGameState(NewGameState);
		}


	}



}
function SetAppearance(out XComGameState_Unit AlteredUnit, XComGameState_Unit Unit)
{
		AlteredUnit.kAppearance.iGender = Unit.kAppearance.iGender;
		AlteredUnit.kAppearance.nmHead = Unit.kAppearance.nmHead;
		AlteredUnit.kAppearance.nmHaircut = Unit.kAppearance.nmHaircut;
		AlteredUnit.kAppearance.iHairColor = Unit.kAppearance.iHairColor;
		AlteredUnit.kAppearance.nmBeard = Unit.kAppearance.nmBeard;
		AlteredUnit.kAppearance.iSkinColor = Unit.kAppearance.iSkinColor;
		AlteredUnit.kAppearance.iEyeColor = Unit.kAppearance.iEyeColor;
	//result.kAppearance.iVoice = Unit.kAppearance.iVoice;
		AlteredUnit.kAppearance.iAttitude = Unit.kAppearance.iAttitude;

		AlteredUnit.kAppearance.iArmorDeco = Unit.kAppearance.iArmorDeco;
	
		AlteredUnit.kAppearance.iArmorTint = Unit.kAppearance.iArmorTint;
		AlteredUnit.kAppearance.iArmorTintSecondary = Unit.kAppearance.iArmorTintSecondary;
	
		AlteredUnit.kAppearance.nmHelmet = Unit.kAppearance.nmHelmet;
		AlteredUnit.kAppearance.nmEye = Unit.kAppearance.nmEye;
		AlteredUnit.kAppearance.nmTeeth = Unit.kAppearance.nmTeeth;
		AlteredUnit.kAppearance.nmFacePropUpper = Unit.kAppearance.nmFacePropUpper;
		AlteredUnit.kAppearance.nmFacePropLower = Unit.kAppearance.nmFacePropLower;
		AlteredUnit.kAppearance.nmPatterns = Unit.kAppearance.nmPatterns;
		AlteredUnit.kAppearance.nmFlag = '';
		AlteredUnit.kAppearance.nmVoice = Unit.kAppearance.nmVoice;

		AlteredUnit.kAppearance.iTattooTint = Unit.kAppearance.iTattooTint;
		AlteredUnit.kAppearance.nmTattoo_LeftArm = Unit.kAppearance.nmTattoo_LeftArm;
		AlteredUnit.kAppearance.nmTattoo_RightArm = Unit.kAppearance.nmTattoo_RightArm;
		AlteredUnit.kAppearance.nmScars = Unit.kAppearance.nmScars;
		AlteredUnit.kAppearance.nmFacepaint = Unit.kAppearance.nmFacepaint;


}

function ApplyAbilities(out XComGameState_Unit GameUnit, XComGameState_Unit_DarkXComInfo InfoState, out XComGameState NewGameState,  XComGameState_HeadquartersDarkXCom DarkXComHQ, XComGameStateHistory History)
{
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate;
	local name AbilityName;
	local array<AdditionalAbilityNames> AbilityNames;
	local AdditionalAbilityNames		AdditionalAbilityName;
	local bool newState, atLeastOne, DoNotGo;
	local int i, j;
	
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	for(i = 0; i < InfoState.SoldierAbilities.Length; i++)
	{
		AbilityName = InfoState.SoldierAbilities[i].AbilityName;
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityName);
		EnsureAWCAbilityOnUnit(NewGameState, GameUnit, AbilityTemplate, InfoState.SoldierAbilities[i].ApplyToWeaponSlot);
		if(AbilityTemplate.AdditionalAbilities.Length > 0)
		{
			for(j = 0; j < AbilityTemplate.AdditionalAbilities.Length; j++)
			{
				//if( AbilityTemplate.AdditionalAbilities[j] == 'BlademasterMomentum' || 
				if(AbilityTemplate.AdditionalAbilities[j] == 'BlademasterSlice') //we don't want MOCX rangers slicing twice
					continue;

				AdditionalAbilityName.AbilityName = '';
				AdditionalAbilityName.InventorySlot = eInvSlot_Unknown;
				AdditionalAbilityName.AbilityName = AbilityTemplate.AdditionalAbilities[j];
				AdditionalAbilityName.InventorySlot = InfoState.SoldierAbilities[i].ApplyToWeaponSlot;
				AbilityNames.AddItem(AdditionalAbilityName);
			}
		}
	}


	for(i = 0; i < InfoState.AWCAbilities.Length; i++)
	{
		AbilityName = InfoState.AWCAbilities[i].AbilityName;
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityName);
		EnsureAWCAbilityOnUnit(NewGameState, GameUnit, AbilityTemplate, InfoState.AWCAbilities[i].ApplyToWeaponSlot);
		if(AbilityTemplate.AdditionalAbilities.Length > 0)
		{
			for(j = 0; j < AbilityTemplate.AdditionalAbilities.Length; j++)
			{
				//if( AbilityTemplate.AdditionalAbilities[j] == 'BlademasterMomentum' ||  
				if(AbilityTemplate.AdditionalAbilities[j] == 'BlademasterSlice') //we don't want MOCX rangers slicing twice
					continue;

				AdditionalAbilityName.AbilityName = '';
				AdditionalAbilityName.InventorySlot = eInvSlot_Unknown;
				AdditionalAbilityName.AbilityName = AbilityTemplate.AdditionalAbilities[j];
				AdditionalAbilityName.InventorySlot = InfoState.SoldierAbilities[i].ApplyToWeaponSlot;
				AbilityNames.AddItem(AdditionalAbilityName);
			}
		}
	}
			
	for(i = 0; i < AbilityNames.Length; i++)
	{
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityNames[i].AbilityName);
		EnsureAWCAbilityOnUnit(NewGameState, GameUnit, AbilityTemplate, AbilityNames[i].InventorySlot);
	}
			
	ApplyStatsAndPCS(NewGameState, GameUnit, InfoState);

} 

function ApplyStatsandPCS(XComGameState NewGameState, out XComGameState_Unit Unit, XComGameState_Unit_DarkXComInfo InfoState)
{
	local X2EquipmentTemplate SimTemplate;
	local X2ItemTemplateManager ItemTemplateManager;
	local int i;
	local float MaxStat, NewMaxStat;
	local StatBoost Boost;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityTemplateManager;
				
	if(InfoState == none)
	{
		return;
	}

	`log("Dark XCom: applying rank stats.", ,'DarkXCom');
	MaxStat = Unit.GetMaxStat(eStat_Will);
	NewMaxStat = MaxStat + InfoState.RankWill;
	Unit.SetBaseMaxStat(eStat_Will, NewMaxStat);
	Unit.SetCurrentStat(eStat_Will, NewMaxStat);
	
	`log("Dark XCom: added " $ InfoState.RankWill $ " Will.", ,'DarkXCom');

	MaxStat = Unit.GetMaxStat(eStat_Dodge);
	NewMaxStat = MaxStat + InfoState.RankDodge;
	Unit.SetBaseMaxStat(eStat_Dodge, NewMaxStat);
	Unit.SetCurrentStat(eStat_Dodge, NewMaxStat);
	
	`log("Dark XCom: added " $ InfoState.RankDodge $ " Dodge.", ,'DarkXCom');


	MaxStat = Unit.GetMaxStat(eStat_HP);
	NewMaxStat = MaxStat + InfoState.RankHP;
	Unit.SetBaseMaxStat(eStat_HP, NewMaxStat);
	Unit.SetCurrentStat(eStat_HP, NewMaxStat);

	`log("Dark XCom: added " $ InfoState.RankHP $ " HP.", ,'DarkXCom');

	
	MaxStat = Unit.GetMaxStat(eStat_Offense);
	NewMaxStat = MaxStat + InfoState.RankAim;
	Unit.SetBaseMaxStat(eStat_Offense, NewMaxStat);
	Unit.SetCurrentStat(eStat_Offense, NewMaxStat);
	
	`log("Dark XCom: added " $ InfoState.RankAim $ " Aim.", ,'DarkXCom');
												
	MaxStat = Unit.GetMaxStat(eStat_PsiOffense);
	NewMaxStat = MaxStat + InfoState.RankPsi;
	Unit.SetBaseMaxStat(eStat_PsiOffense, NewMaxStat);
	Unit.SetCurrentStat(eStat_PsiOffense, NewMaxStat);
	
	`log("Dark XCom: added " $ InfoState.RankPsi $ " PsiOffense.", ,'DarkXCom');
												
						
				
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	SimTemplate = X2EquipmentTemplate(ItemTemplateManager.FindItemTemplate(InfoState.EquippedPCS));
	if(SimTemplate != none)
	{
		for(i = 0; i < SimTemplate.StatsToBoost.Length; i++)
		{
		`log("Dark XCom: applying PCS stats.", ,'DarkXCom');
		MaxStat = Unit.GetMaxStat(SimTemplate.StatsToBoost[i]);
		ItemTemplateManager.GetItemStatBoost(SimTemplate.StatBoostPowerLevel, SimTemplate.StatsToBoost[i], Boost);
		NewMaxStat = MaxStat + Boost.Boost;
		Unit.SetBaseMaxStat(SimTemplate.StatsToBoost[i], NewMaxStat);
		Unit.SetCurrentStat(SimTemplate.StatsToBoost[i], NewMaxStat);

		}

		for(i = 0; i < SimTemplate.Abilities.Length; i++)
		{
			`log("Dark XCom: applying PCS abilities.", ,'DarkXCom');
			AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(SimTemplate.Abilities[i]);
			EnsureAbilityOnUnit(NewGameState, Unit, AbilityTemplate);
		}
	}

}

// Ensure the unit represented by the given reference has the chosen ability
function bool EnsureAbilityOnUnit(XComGameState NewGameState, XComGameState_Unit UnitState, X2AbilityTemplate AbilityTemplate)
{
	local XComGameState_Ability AbilityState;
	local StateObjectReference StateObjectRef;
	//local XComGameState NewGameState;


	if(UnitState.IsDead())
	{
	`log("Unit be ded.", ,'DarkXCom');
	return false ;

	}


	// Loop over all the abilities they have
	foreach UnitState.Abilities(StateObjectRef) 
	{
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(StateObjectRef.ObjectID));

		// If the unit already has this ability, don't add a new one.
		if (AbilityState.GetMyTemplateName() == AbilityTemplate.DataName)
		{
		`log("Unit " $ UnitState $ " already has this " $ AbilityTemplate.DataName, ,'DarkXCom');
			return false;
		}
	}

	`log("Adding "  $ AbilityTemplate.DataName $ " to unit " $ UnitState, ,'DarkXCom');
	
	AbilityState = AbilityTemplate.CreateInstanceFromTemplate(NewGameState);
	AbilityState.InitAbilityForUnit(UnitState, NewGameState);
	NewGameState.AddStateObject(AbilityState);
	UnitState.Abilities.AddItem(AbilityState.GetReference());
	//`log("Applying ability");
	// Submit the new state (handled in top level now)
	//`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	if(AbilityTemplate.DataName == 'Phantom')
	{
		UnitState.EnterConcealmentNewGameState(NewGameState);
	}

	return true;
}

// Ensure the unit represented by the given reference has the chosen ability
function bool EnsureAWCAbilityOnUnit(XComGameState NewGameState, XComGameState_Unit UnitState, X2AbilityTemplate AbilityTemplate, EInventorySlot SlotToApplyTo)
{
	local XComGameState_Ability AbilityState;
	local StateObjectReference StateObjectRef;
	local array<XComGameState_Item> CurrentInventory;
	local XComGameState_Item InventoryItem;

	if(UnitState.IsDead())
	{
	`log("Dark XCom: Unit be ded.", ,'DarkXCom');
	return false ;

	}

	if(AbilityTemplate.DataName == 'LaunchGrenade')
	{
	`log("Dark XCom: LaunchGrenade can't be added directly to units.", ,'DarkXCom');
	return false;
	}


	// Loop over all the abilities they have
	foreach UnitState.Abilities(StateObjectRef) 
	{
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(StateObjectRef.ObjectID));

		// If the unit already has this ability, don't add a new one.
		if (AbilityState.GetMyTemplateName() == AbilityTemplate.DataName)
		{
		`log("Dark XCom: Unit " $ UnitState $ " already has this " $ AbilityTemplate.DataName, ,'DarkXCom');
			return false;
		}
	}

	`log("Adding "  $ AbilityTemplate.DataName $ " to unit " $ class'UnitDarkXComUtils'.static.GetFullName(UnitState), ,'DarkXCom');
	// Construct a new unit game state for this unit, adding an instance of the ability

	AbilityState = AbilityTemplate.CreateInstanceFromTemplate(NewGameState);

	if(SlotToApplyTo != eInvSlot_Unknown)
	{
		CurrentInventory = UnitState.GetAllInventoryItems(NewGameState);
		foreach CurrentInventory(InventoryItem)
		{
			if (InventoryItem.bMergedOut)
				continue;
			if (InventoryItem.InventorySlot == SlotToApplyTo)
			{
				AbilityState.SourceWeapon = InventoryItem.GetReference();

				break;

			}
		}
	}


	AbilityState.InitAbilityForUnit(UnitState, NewGameState);
	NewGameState.AddStateObject(AbilityState);
	UnitState.Abilities.AddItem(AbilityState.GetReference());

	if(AbilityTemplate.DataName == 'Phantom')
	{
		UnitState.EnterConcealmentNewGameState(NewGameState);
	}
	//`log("Applying ability");
	// Submit the new state (handled in top level now)
	//`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	return true;
}
*/
defaultproperties
{
	// Leave this none so it can be triggered anywhere, gate inside the OnInit
	ScreenClass = UITacticalHUD;
}