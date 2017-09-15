//---------------------------------------------------------------------------------------
//  FILE:    X2EventListener_DLC_3_AbilityPoints.uc
//  AUTHOR:  Russell Aasland
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2EventListener_MOCX_AbilityPoints extends X2EventListener_AbilityPoints;


static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem( CreateMOCXEvacEvent() );
	Templates.AddItem( CreateMOCXKillEvent() );
	return Templates;
}

static function X2AbilityPointTemplate CreateMOCXEvacEvent()
{
	local X2AbilityPointTemplate Template;

	`CREATE_X2TEMPLATE(class'X2AbilityPointTemplate', Template, 'MOCXEvac');
	Template.AddEvent('UnitEvacuated', CheckForEvac);

	return Template;
}

static function X2AbilityPointTemplate CreateMOCXKillEvent()
{
	local X2AbilityPointTemplate Template;

	`CREATE_X2TEMPLATE(class'X2AbilityPointTemplate', Template, 'MOCXKill');
	Template.AddEvent('UnitDied', CheckForMOCXKill);

	return Template;
}


static protected function EventListenerReturn CheckForMOCXKill(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit KilledUnit;
	local XComGameState_BattleData BattleData;
	local X2AbilityPointTemplate APTemplate;
	local int Roll;
	local XComGameStateContext_AbilityPointEvent EventContext;

	KilledUnit = XComGameState_Unit(EventSource);
	BattleData = XComGameState_BattleData( `XCOMHISTORY.GetSingleGameStateObjectForClass( class'XComGameState_BattleData' ) );
	APTemplate = GetAbilityPointTemplate( 'MOCXKill' );

	// bad data somewhere
	if ((APTemplate == none) || (BattleData == none) || (KilledUnit == none))
		return ELR_NoInterrupt;

	// ignore everybody that leaves the field that isn't a MOCX soldier
	if (KilledUnit.GetMyTemplate().CharacterGroupName != 'DarkXComSoldier' || KilledUnit.GetMyTemplateName() == 'DarkRookie' || KilledUnit.GetMyTemplateName() == 'DarkRookie_M2' || KilledUnit.GetMyTemplateName() == 'DarkRookie_M3')
		return ELR_NoInterrupt;


	Roll = class'Engine'.static.GetEngine().SyncRand(100, "RollForAbilityPoint");
	if (Roll < APTemplate.Chance)
	{
		EventContext = XComGameStateContext_AbilityPointEvent( class'XComGameStateContext_AbilityPointEvent'.static.CreateXComGameStateContext() );
		EventContext.AbilityPointTemplateName = APTemplate.DataName;
		EventContext.AssociatedUnitRef = KilledUnit.GetReference( );
		EventContext.TriggerHistoryIndex = GameState.GetContext().GetFirstStateInEventChain().HistoryIndex;

		`TACTICALRULES.SubmitGameStateContext( EventContext );
	}
}


static protected function EventListenerReturn CheckForEvac(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit KilledUnit;
	local XComGameState_BattleData BattleData;
	local X2AbilityPointTemplate APTemplate;
	local int Roll;
	local XComGameStateContext_AbilityPointEvent EventContext;

	KilledUnit = XComGameState_Unit(EventSource);
	BattleData = XComGameState_BattleData( `XCOMHISTORY.GetSingleGameStateObjectForClass( class'XComGameState_BattleData' ) );
	APTemplate = GetAbilityPointTemplate( 'MOCXEvac' );

	// bad data somewhere
	if ((APTemplate == none) || (BattleData == none) || (KilledUnit == none))
		return ELR_NoInterrupt;

	// ignore everybody that leaves the field that isn't a MOCX soldier
	if (KilledUnit.GetMyTemplate().CharacterGroupName != 'DarkXComSoldier')
		return ELR_NoInterrupt;

	Roll = class'Engine'.static.GetEngine().SyncRand(100, "RollForAbilityPoint");
	if (Roll < APTemplate.Chance)
	{
		EventContext = XComGameStateContext_AbilityPointEvent( class'XComGameStateContext_AbilityPointEvent'.static.CreateXComGameStateContext() );
		EventContext.AbilityPointTemplateName = APTemplate.DataName;
		EventContext.AssociatedUnitRef = KilledUnit.GetReference( );
		EventContext.TriggerHistoryIndex = GameState.GetContext().GetFirstStateInEventChain().HistoryIndex;

		`TACTICALRULES.SubmitGameStateContext( EventContext );
	}
}