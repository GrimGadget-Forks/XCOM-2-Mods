class X2Action_AddAWCAbility extends Object;

struct FindResult
{
	var ClassAgnosticAbility AWCAbility;
	var bool Found;
};

static function FindResult FindAbility(XComGameState_Unit unit, name abilityname)
{
	local ClassAgnosticAbility awcAbility;
	local FindResult result;
	foreach unit.AWCAbilities(awcAbility)
	{
		if (awcAbility.AbilityType.AbilityName == abilityname)
		{
			result.Found = true;
			result.AWCAbility = awcAbility;
			return result;
		}
	}
	return result;
}

static function UpdateAbilityOnUnit(

	StateObjectReference unitRef, 
	X2AbilityTemplate ability, 
	array<name> soldierClasses, 
	optional bool modeExclude = false, 
	optional bool removeIfExcluded = true, 
	optional EInventorySlot invSlot = eInvSlot_Unknown, 
	optional int iRank = 0, 
	optional bool unlock = true,
	optional XComGameState useGameState = none
	)
{
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState NewGameState;
	local FindResult SearchAbility;
	local bool include;
	local bool soldierClassMatched;

	if(unitRef.ObjectID == 0)
	{
		return;
	}

	UnitState = useGameState == none ?  XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectId(unitRef.ObjectID)) :
		XComGameState_Unit(useGameState.GetGameStateForObjectID(unitRef.ObjectID));

	soldierClassMatched = soldierClasses.Find(UnitState.GetSoldierClassTemplateName()) >= 0;
	SearchAbility = FindAbility(UnitState, ability.DataName);

	if (SearchAbility.Found == false)
	{
		include = modeExclude != soldierClassMatched;
		if (include)
		{
			SearchAbility.AWCAbility.AbilityType.AbilityName = ability.DataName;
			SearchAbility.AWCAbility.AbilityType.ApplyToWeaponSlot = invSlot;
			SearchAbility.AWCAbility.AbilityType.UtilityCat = '';
			SearchAbility.AWCAbility.iRank = iRank;
			SearchAbility.AWCAbility.bUnlocked = unlock;
			UnitState.AWCAbilities.AddItem(SearchAbility.AWCAbility);
			if (useGameState == none)
			{
				NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Add Second Wind Ability");
				NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
				NewGameState.AddStateObject(NewUnitState);
				`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
			}
		}
		return;
	}
	else
	{
		if (removeIfExcluded)
		{
			include = modeExclude == soldierClassMatched;
			if (include) 
			{
				// this unit should not have this ability anymore
				UnitState.AWCAbilities.RemoveItem(SearchAbility.AWCAbility);
				if (useGameState == none)
				{						
					NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Add Second Wind Ability");
					NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));						
					NewGameState.AddStateObject(NewUnitState);
					`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
				}
			}
		}
		else
		{
			// update lock state and rank
			SearchAbility.AWCAbility.iRank = iRank;
			SearchAbility.AWCAbility.bUnlocked = SearchAbility.AWCAbility.bUnlocked || unlock;
			if (useGameState == none)
			{
				NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Add Second Wind Ability");
				NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
				NewGameState.AddStateObject(NewUnitState);
				`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
			}
		}		
		return;
	}
}

static function UpdateAbilityOnSquad(
	
	X2AbilityTemplate ability, 
	array<name> soldierClasses, 
	optional bool modeExclude = false, 
	optional bool removeIfExcluded = true, 
	optional EInventorySlot invSlot = eInvSlot_Unknown, 
	optional int iRank = 0, 
	optional bool unlock = true,
	optional XComGameState useGameState = none
	
	)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local int i;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	for (i = 0; i < XComHQ.Squad.Length; ++i) 
	{
		if(XComHQ.Squad[i].ObjectID == 0)
		{
			continue;
		}
		UpdateAbilityOnUnit(XComHQ.Squad[i], ability, soldierClasses, modeExclude, removeIfExcluded, invslot, iRank, unlock, useGameState);
	}
}
