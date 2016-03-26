// This is an Unreal Script
class RM_AdditionalDarkEvents extends X2StrategyElement_DefaultDarkEvents; 


var() bool SuperUFOActivated;
//-------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> DarkEvents;

	DarkEvents.AddItem(CreateBerserkersTemplate());
	DarkEvents.AddItem(CreateEarlyAvatarTemplate());
	DarkEvents.AddItem(CreateStunBrigadeTemplate());
	DarkEvents.AddItem(CreateSectopodsTemplate());
	DarkEvents.AddItem(CreateDragonRoundsTemplate());
	DarkEvents.AddItem(CreateAPRoundsTemplate());
	DarkEvents.AddItem(CreateTalonRoundsTemplate());
	DarkEvents.AddItem(CreateTracerRoundsTemplate());
	DarkEvents.AddItem(CreateHazmatArmorTemplate());
	DarkEvents.AddItem(CreatePermanentInfestationTemplate());
	DarkEvents.AddItem(CreatePermanentInfiltratorTemplate());
	DarkEvents.AddItem(CreatePermanentBerserkersTemplate());
	DarkEvents.AddItem(CreatePermanentAvatarTemplate());
	DarkEvents.AddItem(CreateMindshieldingTemplate());
	DarkEvents.AddItem(CreateBlastPaddingTemplate());
	DarkEvents.AddItem(CreateLightningDrugsTemplate());
	DarkEvents.AddItem(CreateHoloRoundsTemplate());
	DarkEvents.AddItem(CreateSpecialForcesTemplate());
	DarkEvents.AddItem(CreateSuperUFOTemplate());
	DarkEvents.AddItem(CreateAvengerWatchTemplate());
	DarkEvents.AddItem(CreateAlienWormTemplate());

	return DarkEvents;
}
//-------------------------
//--------------------------------------------------------------------------
static function X2DataTemplate CreateEarlyAvatarTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_EarlyAvatar');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_RM_StrategyImages.DarkEvent_EarlyAvatar";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.MutuallyExclusiveEvents.AddItem('DarkEvent_PermanentAvatar');
	Template.StartingWeight = 5;
	Template.MinWeight = 1;
	Template.MaxWeight = 5;
	Template.WeightDeltaPerPlay = -2;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateEarlyAvatar;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateEarlyAvatar(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 6);

	}


//--------------------------------------------------------------------------
static function X2DataTemplate CreateBerserkersTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_Berserkers');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_RM_StrategyImages.DarkEvent_Berserkers";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 5;
	Template.MinWeight = 1;
	Template.MaxWeight = 5;
	Template.WeightDeltaPerPlay = -2;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateBerserkers;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateBerserkers(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	return XComHQ.HasSeenCharacterTemplate(class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate('Berserker'));
}


//---------------------------------


static function X2DataTemplate CreateStunBrigadeTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_StunBrigade');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_ShowOfForce";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 5;
	Template.MinWeight = 1;
	Template.MaxWeight = 5;
	Template.WeightDeltaPerPlay = -2;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateStunBrigade;

	return Template;
}

function bool CanActivateStunBrigade(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 4);

	}



//--------------------------------------------------------------------------
static function X2DataTemplate CreateSectopodsTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_Sectopods');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_RM_StrategyImages.DarkEvent_OverwhelmingForce";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 5;
	Template.MinWeight = 1;
	Template.MaxWeight = 5;
	Template.WeightDeltaPerPlay = -2;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateSectopods;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateSectopods(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	return XComHQ.HasSeenCharacterTemplate(class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate('Sectopod'));
}

//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateDragonRoundsTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_DragonRounds');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_RM_StrategyImages.DarkEvent_IncendiaryRounds";
	Template.bRepeatable = false;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 5;
	Template.MinWeight = 1;
	Template.MaxWeight = 5;
	Template.WeightDeltaPerPlay = -2;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateDragonRounds;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateDragonRounds(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 2);
}

//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateAPRoundsTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_APRounds');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_RM_StrategyImages.DarkEvent_APRounds";
	Template.bRepeatable = false;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 5;
	Template.MinWeight = 1;
	Template.MaxWeight = 5;
	Template.WeightDeltaPerPlay = -2;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateAPRounds;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateAPRounds(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 2);
}
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateTalonRoundsTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_TalonRounds');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_RM_StrategyImages.DarkEvent_TalonRounds";
	Template.bRepeatable = false;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 5;
	Template.MinWeight = 1;
	Template.MaxWeight = 5;
	Template.WeightDeltaPerPlay = -2;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateTalonRounds;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateTalonRounds(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 2);
}
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateTracerRoundsTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_TracerRounds');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_RM_StrategyImages.DarkEvent_TracerRounds";
	Template.bRepeatable = false;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 5;
	Template.MinWeight = 1;
	Template.MaxWeight = 5;
	Template.WeightDeltaPerPlay = -2;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateTracerRounds;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateTracerRounds(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 2);
}
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateHazmatArmorTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_HazmatArmor');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_NewArmor";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 9;
	Template.MinWeight = 1;
	Template.MaxWeight = 9;
	Template.WeightDeltaPerPlay = -2;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateHazmatArmor;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateHazmatArmor(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 2);
}

//---------------------------------------------------------------------------------------
static function X2DataTemplate CreatePermanentInfiltratorTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_PermanentInfiltrator');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_Faceless";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 1;
	Template.MaxDurationDays = 1;
	Template.bInfiniteDuration = true;
	Template.StartingWeight = 30;
	Template.MinWeight = 1;
	Template.MaxWeight = 30;
	Template.WeightDeltaPerPlay = -5;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivatePermanentInfiltrator;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivatePermanentInfiltrator(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	return (XComHQ.HasSeenCharacterTemplate(class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate('Faceless')) && AtMaxDoom());
}


//---------------------------------------------------------------------------------------
static function X2DataTemplate CreatePermanentInfestationTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_PermanentInfestation');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_Chryssalid";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 25;
	Template.MinDurationDays = 1;
	Template.MaxDurationDays = 1;
	Template.bInfiniteDuration = true;
	Template.StartingWeight = 30;
	Template.MinWeight = 1;
	Template.MaxWeight = 30;
	Template.WeightDeltaPerPlay = -5;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivatePermanentInfestation;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivatePermanentInfestation(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	//local XComGameState_HeadquartersResistance ResistanceHQ;
	local XComGameState_HeadquartersXCom XComHQ;
	History = `XCOMHISTORY;
	//ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	return (XComHQ.HasSeenCharacterTemplate(class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate('Chryssalid')) && AtMaxDoom());
}



//--------------------------------------------------------------------------
static function X2DataTemplate CreatePermanentBerserkersTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_PermanentBerserkers');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_RM_StrategyImages.DarkEvent_Berserkers";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 25;
	Template.MinDurationDays = 1;
	Template.MaxDurationDays = 1;
	Template.bInfiniteDuration = true;
	Template.StartingWeight = 30;
	Template.MinWeight = 1;
	Template.MaxWeight = 30;
	Template.WeightDeltaPerPlay = -5;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivatePermanentBerserkers;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivatePermanentBerserkers(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	return (XComHQ.HasSeenCharacterTemplate(class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate('Berserker')) && AtMaxDoom());
}


//--------------------------------------------------------------------------
static function X2DataTemplate CreatePermanentAvatarTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_PermanentAvatar');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_Avatar2";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 25;
	Template.MinDurationDays = 1;
	Template.MaxDurationDays = 1;
	Template.bInfiniteDuration = true;
	Template.StartingWeight = 25;
	Template.MinWeight = 1;
	Template.MaxWeight = 75;
	Template.WeightDeltaPerPlay = 10;
	Template.WeightDeltaPerActivate = -5;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivatePermanentAvatar;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivatePermanentAvatar(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 6 && AtMaxDoom());

}

//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateMindshieldingTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_Mindshielding');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_NewArmor";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 8;
	Template.MinWeight = 1;
	Template.MaxWeight = 8;
	Template.WeightDeltaPerPlay = -1;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateMindshielding;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateMindshielding(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 2);
}
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateBlastPaddingTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_BlastPadding');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_NewArmor";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 8;
	Template.MinWeight = 1;
	Template.MaxWeight = 8;
	Template.WeightDeltaPerPlay = -2;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateBlastPadding;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateBlastPadding(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 2);
}
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateLightningDrugsTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_LightningDrugs');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_NewArmor";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 5;
	Template.MinWeight = 1;
	Template.MaxWeight = 5;
	Template.WeightDeltaPerPlay = -2;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateLightningDrugs;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateLightningDrugs(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 4);
}
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateHoloRoundsTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_HoloRounds');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_RM_StrategyImages.DarkEvent_HoloRounds";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 5;
	Template.MinWeight = 1;
	Template.MaxWeight = 5;
	Template.WeightDeltaPerPlay = -2;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateHoloRounds;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateHoloRounds(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 4);
}
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateSpecialForcesTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_SpecialForces');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_ShowOfForce";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 35;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 5;
	Template.MinWeight = 1;
	Template.MaxWeight = 5;
	Template.WeightDeltaPerPlay = -2;
	Template.WeightDeltaPerActivate = 0;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateSpecialForces;

	return Template;
}

//---------------------------------------------------------------------------------------
function bool CanActivateSpecialForces(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 4);
}


//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateSuperUFOTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_SuperUFO');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_UFO";
	Template.bRepeatable = true;
	Template.bTactical = false;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 14;
	Template.MaxActivationDays = 28;
	Template.MinDurationDays = 0;
	Template.MaxDurationDays = 0;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 10;
	Template.MinWeight = 1;
	Template.MaxWeight = 15;
	Template.WeightDeltaPerPlay = 0;
	Template.WeightDeltaPerActivate = 1;

	Template.OnActivatedFn = ActivateSuperUFO;
	Template.CanActivateFn = CanActivateSuperUFO;

	return Template;
}
//---------------------------------------------------------------------------------------
function ActivateSuperUFO(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameStateHistory History;
	local XComGameState_UFO NewUFOState;
	local XComGameState_HeadquartersAlien AlienHQ;

	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	NewGameState.AddStateObject(AlienHQ);
	AlienHQ.bHasPlayerBeenIntercepted = false;

	NewUFOState = XComGameState_UFO(NewGameState.CreateStateObject(class'XComGameState_UFO'));
	NewUFOState.OnCreation(NewGameState, true);
	NewGameState.AddStateObject(NewUFOState);
}

//---------------------------------------------------------------------------------------
function bool CanActivateSuperUFO(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 2);
}

//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateAvengerWatchTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_AvengerWatch');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_StrategyImages.X2StrategyMap.DarkEvent_UFO";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 28;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 10;
	Template.MinWeight = 1;
	Template.MaxWeight = 10;
	Template.WeightDeltaPerPlay = 0;
	Template.WeightDeltaPerActivate = -2;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateAvengerWatch;

	return Template;
}
//---------------------------------------------------------------------------------------
function bool CanActivateAvengerWatch(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 2);
}

//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateAlienWormTemplate()
{
	local X2DarkEventTemplate Template;

	`CREATE_X2TEMPLATE(class'X2DarkEventTemplate', Template, 'DarkEvent_AlienWorm');
	Template.Category = "DarkEvent";
	Template.ImagePath = "img:///UILibrary_RM_StrategyImages.DarkEvent_AlienWorm";
	Template.bRepeatable = true;
	Template.bTactical = true;
	Template.bLastsUntilNextSupplyDrop = false;
	Template.MaxSuccesses = 0;
	Template.MinActivationDays = 21;
	Template.MaxActivationDays = 28;
	Template.MinDurationDays = 28;
	Template.MaxDurationDays = 28;
	Template.bInfiniteDuration = false;
	Template.StartingWeight = 10;
	Template.MinWeight = 1;
	Template.MaxWeight = 10;
	Template.WeightDeltaPerPlay = 0;
	Template.WeightDeltaPerActivate = -2;

	Template.OnActivatedFn = ActivateTacticalDarkEvent;
	Template.OnDeactivatedFn = DeactivateTacticalDarkEvent;
	Template.CanActivateFn = CanActivateAlienWorm;

	return Template;
}
//---------------------------------------------------------------------------------------
function bool CanActivateAlienWorm(XComGameState_DarkEvent DarkEventState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersResistance ResistanceHQ;

	History = `XCOMHISTORY;
	ResistanceHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	return (ResistanceHQ.NumMonths >= 4);
}

//-------------------------------------------------------------------------------------------------------

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




