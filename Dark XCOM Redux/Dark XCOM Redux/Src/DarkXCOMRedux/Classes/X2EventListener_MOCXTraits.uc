
class X2EventListener_MOCXTraits extends X2EventListener_DefaultTraits;


static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// alien specific phobias
	Templates.AddItem(CreateFearOfMOCXTemplate());
	

	return Templates;
}

static protected function X2EventListenerTemplate CreateFearOfMOCXTemplate()
{
	local X2TraitTemplate Template;

	`CREATE_X2TEMPLATE(class'X2TraitTemplate', Template, 'FearOfMOCX');
	Template.AddEvent('UnitTakeEffectDamage', OnUnitTookDamage);

	return Template;
}


// common handler to check for acquiring of default traits based on damage criteria 
static protected function EventListenerReturn OnUnitTookDamage(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit DamagedUnit;
	local XComGameState_Unit SourceUnit; // unit that caused the damage
	//local XComGameState_Unit OtherUnit;
	local X2CharacterTemplate SourceUnitTemplate;
	local XComGameStateContext_Ability AbilityContext;
	//local DamageResult LastDamageResult;
	//local XComGameStateHistory History;
	//local XComGameState_HeadquartersXCom XComHQ;
	//local StateObjectReference SquadMemberRef;
	//local X2TraitTemplate Template;
	//local XComGameStateContext_WillRoll WillRollContext;

	DamagedUnit = XComGameState_Unit(EventData);

	// these are only available on xcom units
	if(DamagedUnit == none 
		|| DamagedUnit.GetTeam() != eTeam_XCom 
		|| !DamagedUnit.UsesWillSystem()
		|| DamagedUnit.IsDead())
	{
		return ELR_NoInterrupt;
	}

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if(AbilityContext == none)
	{
		return ELR_NoInterrupt;
	}

	SourceUnit = XComGameState_Unit(GameState.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
	if(SourceUnit == none)
	{
		return ELR_NoInterrupt; 
	}

	//History = `XCOMHISTORY;
	//XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	SourceUnitTemplate = SourceUnit.GetMyTemplate();

	if(SourceUnitTemplate.CharacterGroupName == 'DarkXComSoldier' && !DamagedUnit.HasTrait('FearOfMOCX') )
	{
		class'X2TraitTemplate'.static.RollForTrait(DamagedUnit, 'FearOfMOCX');
	}


	return ELR_NoInterrupt;
}
