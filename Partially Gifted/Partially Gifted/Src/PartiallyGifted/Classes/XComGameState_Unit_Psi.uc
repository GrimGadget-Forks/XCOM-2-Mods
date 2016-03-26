// This is an Unreal Script
class XComGameState_Unit_Psi extends XComGameState_BaseObject config (PartiallyGifted);

var bool		HasTrained;
var bool		HasFullyTrained;

var int TimesTrained;

var config int MaximumTimes;

function XComGameState_Unit_Psi InitComponent()
{
	HasTrained = false;
	HasFullyTrained = false;
	RegisterSoldierTacticalToStrategy();

	return self;
}

//---------------------------------------------------------------------------------------
function bool GetPsiTrainingStatus()
{
	return HasTrained;
}

function bool GetFullyPsiTrainedStatus()
{
	return HasFullyTrained;
}


//Applys fatigue points, flags unit for fatigue injuries if already fatigued.
function ApplyTraining()
{
	HasTrained = true;
	TimesTrained += 1;

	if(TimesTrained >= MaximumTimes)
	{
	FinalizeTraining();
	}
}

function FinalizeTraining()
{
	HasFullyTrained = true;
}



function RegisterSoldierTacticalToStrategy()
{
	//local Object ThisObj;
	local XComGameState_Unit	Owner;
	local Object				OwnerObject;

	//ThisObj = self;
	Owner = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(OwningObjectId));
	OwnerObject = Owner;

	//this should function for SimCombat as well
	`XEVENTMGR.RegisterForEvent(OwnerObject, 'SoldierTacticalToStrategy', OnSoldierTacticalToStrategy, ELD_OnStateSubmitted, , OwnerObject, true);
}


simulated function EventListenerReturn OnSoldierTacticalToStrategy(Object EventData, Object EventSource, XComGameState GameState, Name InEventID)
{
	local XComGameState_Unit			Unit;
	local XComGameState_Unit_Psi	PsiState;

	Unit = XComGameState_Unit(EventData);
	PsiState = class'UnitPsiUtilties'.static.GetPsiComponent(Unit);

	if (PsiState == none) 
	{
		`Redscreen("Failed to find/add Fatigue State Component : SoldierTacticalToStrategy");
		return ELR_NoInterrupt;
	}

	return ELR_NoInterrupt;
}