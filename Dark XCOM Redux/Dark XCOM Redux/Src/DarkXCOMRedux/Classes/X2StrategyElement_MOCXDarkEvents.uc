class X2StrategyElement_MOCXDarkEvents extends X2StrategyElement_DefaultDarkEvents;


static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> DarkEvents;

	DarkEvents.AddItem(CreateCoilTierTemplate());
	DarkEvents.AddItem(CreatePlasmaTierTemplate());

	DarkEvents.AddItem(CreateSquadSizeI());
	DarkEvents.AddItem(CreateSquadSizeII());

	DarkEvents.AddItem(CreateICUTemplate());

	DarkEvents.AddItem(CreateAdvancedMECs());
	DarkEvents.AddItem(CreateGeneticPCSes());

	`log("Dark XCOM: bulding dark events", ,'DarkXCom');
	return DarkEvents;

}


static function X2DataTemplate CreateCoilTierTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_CoilTier');
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_ShowOfForce"; 
	GenericSettings(Template);
	Template.StartingWeight = 10;
    Template.MinActivationDays = 21;
    Template.MaxActivationDays = 28;
	Template.CanActivateFn = IsMOCXActive;
	Template.OnActivatedFn = ActivateCoilTier;
	return Template;
}

function ActivateCoilTier(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	
	DarkXComHQ = GetDarkHQ(NewGameState);
	DarkXComHQ.bHasCoil = true;
}

static function X2DataTemplate CreatePlasmaTierTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_PlasmaTier');
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_ShowOfForce"; 
	GenericSettings(Template);
	Template.StartingWeight = 10;
    Template.MinActivationDays = 21;
    Template.MaxActivationDays = 28;
	Template.CanActivateFn = MOCXHasCoil;
	Template.OnActivatedFn = ActivatePlasmaTier;
	return Template;
}


function bool MOCXHasCoil (XComGameState_DarkEvent DarkEventState)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;

    DarkXComHQ = XComGameState_HeadquartersDarkXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));

	if (DarkXComHQ.bIsActive && DarkXComHQ.bHasCoil)
		return true;

	return false;
}

function ActivatePlasmaTier(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	
	DarkXComHQ = GetDarkHQ(NewGameState);
	DarkXComHQ.bHasPlasma = true;
}

static function X2DataTemplate CreateSquadSizeI()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_SquadSizeI');
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_ShowOfForce"; 
	GenericSettings(Template);
	Template.StartingWeight = 10;
    Template.MinActivationDays = 21;
    Template.MaxActivationDays = 28;
	Template.CanActivateFn = MOCXHasCoil;
	Template.OnActivatedFn = ActivateSquadSizeI;
	return Template;
}

function ActivateSquadSizeI(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	
	DarkXComHQ = GetDarkHQ(NewGameState);
	DarkXComHQ.bSquadSizeI = true;
}

static function X2DataTemplate CreateSquadSizeII()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_SquadSizeII');
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_ShowOfForce"; 
	GenericSettings(Template);
	Template.StartingWeight = 10;
    Template.MinActivationDays = 21;
    Template.MaxActivationDays = 28;
	Template.CanActivateFn = MOCXhasSquadSize;
	Template.OnActivatedFn = ActivateSquadSizeII;

	return Template;
}

function bool MOCXHasSquadSize (XComGameState_DarkEvent DarkEventState)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;

    DarkXComHQ = XComGameState_HeadquartersDarkXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));

	if (DarkXComHQ.bIsActive && DarkXComHQ.bSquadSizeI)
		return true;

	return false;
}

function ActivateSquadSizeII(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	
	DarkXComHQ = GetDarkHQ(NewGameState);
	DarkXComHQ.bSquadSizeII = true;
}


static function X2DataTemplate CreateICUTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_ICU');
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_ShowOfForce"; 
	GenericSettings(Template);
	Template.StartingWeight = 10;
    Template.MinActivationDays = 21;
    Template.MaxActivationDays = 28;
	Template.CanActivateFn = IsMOCXActive;
	Template.OnActivatedFn = ActivateICU;
	return Template;
}

function ActivateICU(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	
	DarkXComHQ = GetDarkHQ(NewGameState);
	DarkXComHQ.bAdvancedICUs = true;
}

static function X2DataTemplate CreateAdvancedMECs()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_AdvancedMECs');
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_ShowOfForce"; 
	GenericSettings(Template);
	Template.StartingWeight = 10;
    Template.MinActivationDays = 21;
    Template.MaxActivationDays = 28;
	Template.CanActivateFn = MOCXHasCoil;
	Template.OnActivatedFn = ActivateMECs;

	return Template;
}

function ActivateMECs(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	
	DarkXComHQ = GetDarkHQ(NewGameState);
	DarkXComHQ.bAdvancedMECs = true;
}

static function X2DataTemplate CreateGeneticPCSes()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_GeneticPCS');
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_ShowOfForce"; 
	GenericSettings(Template);
	Template.StartingWeight = 10;
    Template.MinActivationDays = 21;
    Template.MaxActivationDays = 28;
	Template.CanActivateFn = MOCXHasCoil;
	Template.OnActivatedFn = ActivatePCS;

	return Template;
}


function ActivatePCS(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	
	DarkXComHQ = GetDarkHQ(NewGameState);
	DarkXComHQ.bGeneticPCS = true;
	DarkXComHQ.RenewPCSes(NewGameState);
}


//---------------------------------------------------------------------------------------
// HQ is assumed to be in NewGameState already, based on how the events get activated
function XComGameState_HeadquartersDarkXCom GetDarkHQ(XComGameState NewGameState)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local XComGameStateHistory History;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersDarkXCom', DarkXComHQ)
	{
		break;
	}

	if(DarkXComHQ == none)
	{
	History = class'XComGameStateHistory'.static.GetGameStateHistory();
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(NewGameState.CreateStateObject(class'XComGameState_HeadquartersDarkXCOM', DarkXComHQ.ObjectID));
	}


	return DarkXComHQ;
}




function bool IsMOCXActive (XComGameState_DarkEvent DarkEventState)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;

    DarkXComHQ = XComGameState_HeadquartersDarkXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));
	if (DarkXComHQ.bIsActive && !DarkXComHQ.bIsDestroyed)
		return true;

	return false;
}

static function GenericSettings (out X2DarkEventTemplate Template)
{
	Template.Category = "DarkEvent";
	Template.bRepeatable = false;
    Template.bTactical = true;
    Template.bLastsUntilNextSupplyDrop = false;
	Template.StartingWeight = 5;
	Template.MaxWeight = Template.StartingWeight;
    Template.MaxSuccesses = 0;
    Template.MinDurationDays = 21;
    Template.MaxDurationDays = 28;
    Template.bInfiniteDuration = false;
    Template.WeightDeltaPerActivate = 0;
	Template.WeightDeltaPerPlay = 0;
    Template.MinActivationDays = 21;
    Template.MaxActivationDays = 28;
	Template.MinWeight = 1;
	//Template.OnActivatedFn = ActivateTacticalDarkEvent;
   // Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.bNeverShowObjective = true;
}
