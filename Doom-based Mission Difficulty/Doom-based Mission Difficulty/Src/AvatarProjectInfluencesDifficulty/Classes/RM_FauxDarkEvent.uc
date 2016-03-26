// This is an Unreal Script
class RM_FauxDarkEvent extends X2StrategyElement_DefaultDarkEvents;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> DarkEvents;

	DarkEvents.AddItem(CreateFacilityDestructionTemplate());

	return DarkEvents;
}

//we're going add a faux dark event here for Long War(ish) mode

static function X2DataTemplate CreateFacilityDestructionTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_FacilityDestruction');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_ShowOfForce";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 0;
	Template.MaxActivationDays = 0;
	Template.MinDurationDays = 10;
	Template.MaxDurationDays = 20;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 0;
	Template.MinWeight = 0;
	Template.MaxWeight = 0;
	Template.WeightDeltaPerPlay = 0;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateShowOfForce;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateFacilityDestruction(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 99 && `DifficultySetting >= 3); //this should ensure the event can never appear in a deck during a normal campaign
}


function ActivateTacticalDarkEvent(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_DarkEvent DarkEventState;
	local Name DarkEventTemplateName;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	DarkEventState = XComGameState_DarkEvent(History.GetGameStateForObjectID(InRef.ObjectID));
	DarkEventTemplateName = DarkEventState.GetMyTemplateName();

	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	if( XComHQ.TacticalGameplayTags.Find(DarkEventTemplateName) == INDEX_NONE )
	{
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		NewGameState.AddStateObject(XComHQ);

		XComHQ.TacticalGameplayTags.AddItem(DarkEventTemplateName);
	}
}

function DeactivateTacticalDarkEvent(XComGameState NewGameState, StateObjectReference InRef)
{
	local XComGameState_DarkEvent DarkEventState;
	local Name DarkEventTemplateName;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	DarkEventState = XComGameState_DarkEvent(History.GetGameStateForObjectID(InRef.ObjectID));
	DarkEventTemplateName = DarkEventState.GetMyTemplateName();

	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	if( XComHQ.TacticalGameplayTags.Find(DarkEventTemplateName) != INDEX_NONE )
	{
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		NewGameState.AddStateObject(XComHQ);

		XComHQ.TacticalGameplayTags.RemoveItem(DarkEventTemplateName);
	}
}