// This is an Unreal Script
class RM_TacticalMissionHud_ScreenListener extends UIScreenListener config(SquadCohesion);

var bool AlreadyRanCohesion;

//This will loop over all units on tactical UI load and add the appriopate ability to each one that doesn't already have it.
event OnInit(UIScreen Screen)
{
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_HeadquartersXCom XComHQ;
	local RM_SquadSelect_ScreenListener IniValues;
	local int i, SquadCohesion;
	
	IniValues = new class'RM_SquadSelect_ScreenListener';

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	if(!AlreadyRanCohesion)
	{
	SquadCohesion = (GetSquadCohesionValue(XComHQ.Squad) * IniValues.REDUCER);
	}
	AlreadyRanCohesion = true;

	if(SquadCohesion < IniValues.LOW_SQUAD_COHESION)
	{
	return;
	}

	// Locate the proper cohesion ability template
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	if (SquadCohesion >= IniValues.LOW_SQUAD_COHESION && SquadCohesion < IniValues.MED_SQUAD_COHESION)
	{
	AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('Camaraderie');
	}

	if (SquadCohesion >= IniValues.MED_SQUAD_COHESION && SquadCohesion < IniValues.HIGH_SQUAD_COHESION)
	{
	AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('GuerillasInArms');
	}

	if (SquadCohesion >= IniValues.HIGH_SQUAD_COHESION)
	{
	AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('WeAreXCOM');
	}
	// Add the ability to each squad member that doesn't already have it.
	for (i = 0; i < XComHQ.Squad.Length; ++i) 
	{
		EnsureAbilityOnUnit(XComHQ.Squad[i], AbilityTemplate);
	}
}

function int GetSquadCohesionValue(array<StateObjectReference> Units)
{
	local int TotalCohesion, i, j, XComCheck;
	local SquadmateScore Score;
	local XComGameState_Unit UnitState;
	local array<XComGameState_Unit> XComUnits;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Cohesion CohesionState;
	local XComGameState NewGameState;
	local RM_SquadSelect_ScreenListener IniValues;

	IniValues = new class'RM_SquadSelect_ScreenListener';
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating Cohesion State");
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	CohesionState = XComGameState_Cohesion(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_Cohesion'));
	if(CohesionState == none)
	{
	CohesionState = XComGameState_Cohesion(NewGameState.CreateStateObject(class'XComGameState_Cohesion'));
	}
	
	TotalCohesion = 0;
	
	for(XComCheck = 0; XComCheck < XComHQ.Squad.Length; ++XComCheck)
	{
		if(XComHQ.Squad[XComCheck].ObjectID == Units[XComCheck].ObjectID)
		{
			UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.Squad[XComCheck].ObjectID));
			XComUnits.AddItem(UnitState);
		}
	}

	for (i = 0; i < XComHQ.Squad.Length; ++i)
	{

		for (j = i + 1; j < XComHQ.Squad.Length; ++j)
		{
			if (XComUnits[i].GetSquadmateScore(XComHQ.Squad[j].ObjectID, Score))
			{
				TotalCohesion += Score.Score;
			}
		}
	}
	CohesionState.PreviousSquadCohesion = TotalCohesion * IniValues.REDUCER;

	NewGameState.AddStateObject(CohesionState);


	//`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	return TotalCohesion;
}

//
event OnRemoved(UIScreen Screen)
{
	AlreadyRanCohesion = false;

}


// Ensure the unit represented by the given reference has the chosen ability
function EnsureAbilityOnUnit(StateObjectReference UnitStateRef, X2AbilityTemplate AbilityTemplate)
{
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_Ability AbilityState;
	local StateObjectReference StateObjectRef;
	local XComGameState NewGameState;

	// Find the current unit state for this unit
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectId(UnitStateRef.ObjectID));

	// Loop over all the abilities they have
	foreach UnitState.Abilities(StateObjectRef) 
	{
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(StateObjectRef.ObjectID));

		// If the unit already has this ability, don't add a new one.
		if (AbilityState.GetMyTemplateName() == AbilityTemplate.DataName)
		{
		`log("Ability already found");
			return;
		}
	}

	// Construct a new unit game state for this unit, adding an instance of the ability
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Squad Ability");
	NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
	AbilityState = AbilityTemplate.CreateInstanceFromTemplate(NewGameState);
	AbilityState.InitAbilityForUnit(NewUnitState, NewGameState);
	NewGameState.AddStateObject(AbilityState);
	NewUnitState.Abilities.AddItem(AbilityState.GetReference());
	NewGameState.AddStateObject(NewUnitState);
	`log("Applying ability");
	// Submit the new state
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}


defaultProperties
{
	AlreadyRanCohesion = false;
    ScreenClass = UITacticalHUD;
}