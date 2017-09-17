class X2AbilitySet_DarkXCom extends X2Ability dependson (XComGameStateContext_Ability) config(GameData_WeaponData);

var config int SMG_CONVENTIONAL_MOBILITY_BONUS;
var config float SMG_CONVENTIONAL_DETECTIONRADIUSMODIFER;

var config int PSIAMP_CV_STATBONUS;
var config int PSIAMP_MG_STATBONUS;
var config int PSIAMP_BM_STATBONUS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	`log("Dark XCOM: building abilities", ,'DarkXCom');
	Templates.AddItem(AddLauncherAbility());
	Templates.AddItem(CreateLongJump());
	Templates.AddItem(CreateMimeticSkin());
	Templates.AddItem(CreateIntimidate());
	Templates.AddItem(CreateIntimidateTrigger());
	Templates.AddItem(CreateFakeBleedout());
	Templates.AddItem(CreateFakeBleedoutTrigger());
	Templates.AddItem(AddSMGConventionalBonusAbility());

	Templates.AddItem(CreateAdvKevlarArmorStats());
	Templates.AddItem(CreateAdvPlatedArmorStats());
	Templates.AddItem(CreateAdvPoweredArmorStats());

	Templates.AddItem(CreateDarkEvac());
	Templates.AddItem(CreateDarkEvacTeleport());
	Templates.AddItem(CreateVanish());
	Templates.AddItem(CreateStartVanish());
	Templates.AddItem(CreateVanishReveal());

	Templates.AddItem(AddPsiAmpMG_BonusStats());
	Templates.AddItem(AddPsiAmpCG_BonusStats());
	Templates.AddItem(AddPsiAmpBM_BonusStats());
	Templates.AddItem(PurePassive('FearOfMOCXPassive', "img:///UILibrary_XPACK_Common.PerkIcons.weakx_fearofchosen", , 'eAbilitySource_Debuff'));

	return Templates;
}

// ******************* Psi Amp Bonus ********************************
static function X2AbilityTemplate AddPsiAmpMG_BonusStats()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DarkPsiAmpMG_BonusStats');
	Template.IconImage = "img:///gfxXComIcons.psi_telekineticfield";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
	// Bonus to hacking stat Effect
	//
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_PsiOffense, default.PSIAMP_CV_STATBONUS);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}

static function X2AbilityTemplate AddPsiAmpCG_BonusStats()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DarkPsiAmpCG_BonusStats');
	Template.IconImage = "img:///gfxXComIcons.psi_telekineticfield";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
	// Bonus to hacking stat Effect
	//
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_PsiOffense, default.PSIAMP_MG_STATBONUS);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}
static function X2AbilityTemplate AddPsiAmpBM_BonusStats()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DarkPsiAmpBM_BonusStats');
	Template.IconImage = "img:///gfxXComIcons.psi_telekineticfield";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
	// Bonus to hacking stat Effect
	//
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_PsiOffense, default.PSIAMP_BM_STATBONUS);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}

static function X2DataTemplate CreateVanishReveal()
{
	local X2AbilityTemplate Template;
	local X2Condition_UnitEffects UnitEffectsCondition;
	local X2Effect_RemoveEffects RemoveEffects;
	local X2AbilityTrigger_EventListener Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_VanishReveal');
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_vanishingwind";
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	//Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// This ability fires can when the unit gets hit by a scan
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = class'X2Effect_ScanningProtocol'.default.ScanningProtocolTriggeredEventName;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	// This ability fires when the unit is flanked by an enemy
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_UnitIsFlankedByMovedUnit;
	Trigger.ListenerData.EventID = 'UnitMoveFinished';
	Template.AbilityTriggers.AddItem(Trigger);

	//	This functionality has been deprecated -jbouscher
	// This ability fires when a linked Shadowbound unit dies
	//Trigger = new class'X2AbilityTrigger_EventListener';
	//Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	//Trigger.ListenerData.EventID = 'UnitDied';
	//Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.ShadowboundDeathRevealListener;
	//Template.AbilityTriggers.AddItem(Trigger);

	// This ability fires when the unit is damaged
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'UnitTakeEffectDamage';
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	// This ability fires when the unit takes a hostile action
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'AbilityActivated';
	Trigger.ListenerData.EventFn = WasHostileAction;
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);


	// This ability fires when the unit gets a certain effect added to it
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_VanishedUnitPersistentEffectAdded;
	Trigger.ListenerData.EventID = 'PersistentEffectAdded';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(Trigger);

	// The shooter must have the Vanish Effect
	UnitEffectsCondition = new class'X2Condition_UnitEffects';
	UnitEffectsCondition.AddRequireEffect('RM_Vanish', 'AA_MissingRequiredEffect');
	Template.AbilityShooterConditions.AddItem(UnitEffectsCondition);

	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem('RM_Vanish');
	Template.AddShooterEffect(RemoveEffects);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	//Template.MergeVisualizationFn = class'X2Ability_ChosenAssassin'.static.VanishingWindReveal_MergeVisualization;

	Template.bSkipFireAction = true;
	Template.bShowPostActivation = true;
	Template.bFrameEvenWhenUnitIsHidden = true;

	Template.CinescriptCameraType = "VanishRevealAbility";
	
	return Template;
}


static function EventListenerReturn WasHostileAction(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameStateHistory History;
	//local XComGameStateContext_Ability AbilityContext;
	//local XComGameState NewGameState;
	local XComGameState_Ability AbilityState, VanishState;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Unit SourceUnit;
	local StateObjectReference VanishRef;

	History = `XCOMHISTORY;

	SourceUnit = XComGameState_Unit(EventSource);
	AbilityState = XComGameState_Ability(EventData);
	AbilityTemplate = AbilityState.GetMyTemplate();
	//AbilityContext = XComGameStateContext_Ability(GameState.GetContext().GetFirstStateInEventChain().GetContext());
	if(AbilityTemplate == none || AbilityTemplate.Hostility != eHostility_Offensive)
	{
		//wasn't offensive, ignore
		return ELR_NoInterrupt;
	}

	VanishRef = SourceUnit.FindAbility('RM_VanishReveal');
	if (VanishRef.ObjectID == 0)
		return ELR_NoInterrupt;

	VanishState = XComGameState_Ability(History.GetGameStateForObjectID(VanishRef.ObjectID));
	if (VanishState == None)
		return ELR_NoInterrupt;
	
	
	VanishState.AbilityTriggerAgainstSingleTarget(SourceUnit.GetReference(), false);		
	return ELR_NoInterrupt;
}

static function X2DataTemplate CreateStartVanish()
{
	local X2AbilityTemplate Template;
	//local X2AbilityCost_ActionPoints ActionPointCost;
	//local X2AbilityCooldown_LocalAndGlobal Cooldown;
	local X2Effect_RemoveEffects RemoveEffects;
	local X2Effect_Vanish VanishEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_VanishPhantom');
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_vanishingwind";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;

	Template.AdditionalAbilities.AddItem('RM_VanishReveal');

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(class'X2Effect_Vanish'.static.VanishShooterEffectsCondition());

	// Add remove suppression
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_Suppression'.default.EffectName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_TargetDefinition'.default.EffectName);
	Template.AddTargetEffect(RemoveEffects);

	VanishEffect = new class'X2Effect_Vanish';
	VanishEffect.BuildPersistentEffect(1, true, false, true);
	//VanishEffect.AddPersistentStatChange(eStat_Mobility, default.VANISH_MOBILITY_INCREASE, MODOP_Multiplication);
	//VanishEffect.VanishRevealAnimName = 'HL_Vanish_Stop';
	//VanishEffect.VanishSyncAnimName = 'ADD_Vanish_Restart';
	VanishEffect.EffectName = 'RM_Vanish';
	Template.AddTargetEffect(VanishEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bShowActivation = false;

	Template.CinescriptCameraType = "VanishAbility";
//BEGIN AUTOGENERATED CODE: Template Overrides 'Vanish'
	Template.bSkipExitCoverWhenFiring = true;
	Template.bSKipFireAction = true;
	//Template.CustomFireAnim = 'HL_Vanish_Start';
//END AUTOGENERATED CODE: Template Overrides 'Vanish'
	
	return Template;
}

static function X2DataTemplate CreateVanish()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown_LocalAndGlobal Cooldown;
	local X2Effect_RemoveEffects RemoveEffects;
	local X2Effect_Vanish VanishEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_Vanish');
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_vanishingwind";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;

	Template.AdditionalAbilities.AddItem('RM_VanishReveal');

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown_LocalAndGlobal';
	Cooldown.iNumTurns = class'X2Ability_Spectre'.default.VANISH_COOLDOWN_LOCAL;
	Cooldown.NumGlobalTurns = class'X2Ability_Spectre'.default.VANISH_COOLDOWN_GLOBAL;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(class'X2Effect_Vanish'.static.VanishShooterEffectsCondition());

	// Add remove suppression
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_Suppression'.default.EffectName);
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_TargetDefinition'.default.EffectName);
	Template.AddTargetEffect(RemoveEffects);

	VanishEffect = new class'X2Effect_Vanish';
	VanishEffect.BuildPersistentEffect(1, true, false, true);
	//VanishEffect.AddPersistentStatChange(eStat_Mobility, default.VANISH_MOBILITY_INCREASE, MODOP_Multiplication);
	//VanishEffect.VanishRevealAnimName = 'HL_Vanish_Stop';
	//VanishEffect.VanishSyncAnimName = 'ADD_Vanish_Restart';
	VanishEffect.EffectName = 'RM_Vanish';
	Template.AddTargetEffect(VanishEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bShowActivation = true;

	Template.CinescriptCameraType = "VanishAbility";
//BEGIN AUTOGENERATED CODE: Template Overrides 'Vanish'
	Template.bSkipExitCoverWhenFiring = true;
	Template.bSkipFireAction = true;
	//Template.CustomFireAnim = 'HL_Vanish_Start';
//END AUTOGENERATED CODE: Template Overrides 'Vanish'
	
	return Template;
}

static function X2DataTemplate CreateDarkEvac()
{
	local X2AbilityTemplate Template;
	local X2Effect_Persistent EscapeEffect;
	local X2AbilityTrigger_PlayerInput Trigger;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityCooldown          Cooldown;
	local X2Condition_DarkEvac			DarkEvac;
	Template= new(None, string('RM_DarkEvac')) class'X2AbilityTemplate'; Template.SetTemplateName('RM_DarkEvac');;;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_evac";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;


	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(ActionPointCost);


	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);


	DarkEvac = new class'X2Condition_DarkEvac';
	Template.AbilityTargetConditions.AddItem(DarkEvac);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	//Trigger on movement - interrupt the move
	Trigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(Trigger);

	EscapeEffect = new class'X2Effect_Persistent';
	EscapeEffect.BuildPersistentEffect(2, false, false, false, eGameRule_PlayerTurnEnd);
	EscapeEffect.EffectName = 'RM_Escaping';
	EscapeEffect.EffectRemovedFn = DarkEvacEscapeFn;
	Template.AddShooterEffect(EscapeEffect);	

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 5;
	Template.AbilityCooldown = Cooldown;

	Template.ActivationSpeech = 'EVACrequest';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	//Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	Template.CustomFireAnim = 'HL_SignalPoint';
	Template.CinescriptCameraType = "Mark_Target";
	
	Template.AdditionalAbilities.AddItem('RM_EvacTeleport');

	return Template;
}


static function X2DataTemplate CreateDarkEvacTeleport()
{
	local X2AbilityTemplate Template;
	local X2Effect_Persistent EscapeEffect;
	local X2AbilityTrigger_EventListener EventListener;

	Template= new(None, string('RM_EvacTeleport')) class'X2AbilityTemplate'; Template.SetTemplateName('RM_EvacTeleport');;;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_evac";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'RM_TeleportOut';
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self_VisualizeInGameState;
	EventListener.ListenerData.Priority = 45; //This ability must get triggered after the rest of the on-death listeners (namely, after mind-control effects get removed)
	Template.AbilityTriggers.AddItem(EventListener);

	EscapeEffect = new class'X2Effect_Persistent';
	EscapeEffect.EffectName = 'RM_Escaped';
	EscapeEffect.EffectAddedFn = DarkEscapeFn;
	Template.AddShooterEffect(EscapeEffect);	

	//Template.ActivationSpeech = 'EVACrequest';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = DarkEvac_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	//Template.CustomFireAnim = 'HL_SignalPoint';
	//Template.CinescriptCameraType = "Mark_Target";


	return Template;
}

simulated function DarkEvac_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateContext_Ability Context;
	local XComGameStateHistory History;
	local VisualizationActionMetadata EmptyTrack, DeadUnitTrack;
	local XComGameState_Unit DeadUnit;
	local XComContentManager ContentManager;
	local TTile SpawnedUnitTile;
	local X2Action_PlayEffect PsiWarpInEffectAction;
	local XComWorldData World;
	local X2Action_PlaySoundAndFlyOver  SoundAndFlyover;

	World = `XWORLD;
	ContentManager = `CONTENT;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	History = `XCOMHISTORY;

	DeadUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID));
	`assert(DeadUnit != none);

	// The Spawned unit should appear and play its change animation
	DeadUnitTrack = EmptyTrack;
	DeadUnitTrack.StateObject_OldState = DeadUnit;
	DeadUnitTrack.StateObject_NewState = DeadUnitTrack.StateObject_OldState;
	DeadUnitTrack.VisualizeActor = History.GetVisualizer(DeadUnit.ObjectID);

	DeadUnit.GetKeystoneVisibilityLocation(SpawnedUnitTile);

	SoundAndFlyOver = X2Action_PlaySoundAndFlyover(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(DeadUnitTrack, VisualizeGameState.GetContext()));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", 'EVAC', eColor_Good);

	PsiWarpInEffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(DeadUnitTrack, VisualizeGameState.GetContext()));
	PsiWarpInEffectAction.EffectName = ContentManager.PsiWarpInEffectPathName;
	PsiWarpInEffectAction.EffectLocation = World.GetPositionFromTileCoordinates(SpawnedUnitTile);
	PsiWarpInEffectAction.bStopEffect = false;
	
	//Hide the pawn explicitly now - in case the vis block doesn't complete immediately to trigger an update
	class'X2Action_RemoveUnit'.static.AddToVisualizationTree(DeadUnitTrack, VisualizeGameState.GetContext());


}

static function DarkEscapeFn( X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	local XComGameState_Unit RulerState;
	local X2EventManager EventManager;

	EventManager = class'X2EventManager'.static.GetEventManager();

	RulerState = XComGameState_Unit(kNewTargetState);
	EventManager.TriggerEvent('UnitRemovedFromPlay', RulerState, RulerState, NewGameState);
	EventManager.TriggerEvent('UnitEvacuated', RulerState, RulerState, NewGameState);

}


static function DarkEvacEscapeFn(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed)
{
	local XComGameState_Unit RulerState;
	local X2EventManager EventManager;

	EventManager = class'X2EventManager'.static.GetEventManager();

	RulerState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	EventManager.TriggerEvent('RM_TeleportOut', RulerState, RulerState, NewGameState);

}



static function X2AbilityTemplate CreateAdvKevlarArmorStats()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_AdvKevlarArmorStats');
	// Template.IconImage  -- no icon needed for armor stats

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
	// giving health here; medium plated doesn't have mitigation
	//
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	// PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, default.MediumPlatedHealthBonusName, default.MediumPlatedHealthBonusDesc, Template.IconImage);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_HP, 2);
	//PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, 1);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}


static function X2AbilityTemplate CreateAdvPlatedArmorStats()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_AdvPlatedArmorStats');
	// Template.IconImage  -- no icon needed for armor stats

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
	// giving health here; medium plated doesn't have mitigation
	//
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	// PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, default.MediumPlatedHealthBonusName, default.MediumPlatedHealthBonusDesc, Template.IconImage);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_HP, 4);
	//PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, 1);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}


static function X2AbilityTemplate CreateAdvPoweredArmorStats()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_AdvPoweredArmorStats');
	// Template.IconImage  -- no icon needed for armor stats

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
	// giving health here; medium plated doesn't have mitigation
	//
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	// PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, default.MediumPlatedHealthBonusName, default.MediumPlatedHealthBonusDesc, Template.IconImage);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_HP, 6);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, 1);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}

static function X2AbilityTemplate AddSMGConventionalBonusAbility()
{
	local X2AbilityTemplate                 Template;	
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SMG_Dark_StatBonus');
	Template.IconImage = "img:///gfxXComIcons.NanofiberVest";  

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	// Bonus to Mobility and DetectionRange stat effects
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, "", "", Template.IconImage, false,,Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Mobility, default.SMG_CONVENTIONAL_MOBILITY_BONUS);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_DetectionModifier, default.SMG_CONVENTIONAL_DETECTIONRADIUSMODIFER);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}


static function X2AbilityTemplate CreateFakeBleedout()
{
	local X2AbilityTemplate             Template;
	local X2Effect_FakeBleedout              SustainEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'FakeBleedOut');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_sustain";
	Template.AbilitySourceName = 'eAbilitySource_Psionic';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	SustainEffect = new class'X2Effect_FakeBleedout';
	SustainEffect.BuildPersistentEffect(1, true, true);
	SustainEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(SustainEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Note: no visualization on purpose!

	Template.AdditionalAbilities.AddItem('FakeBleedoutTriggered');

	return Template;
}

static function X2DataTemplate CreateFakeBleedoutTrigger()
{
	local X2AbilityTemplate                 Template;
	local X2Effect_Stunned                  StunEffect;
	local X2AbilityTrigger_EventListener    EventTrigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'FakeBleedoutTriggered');

	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_sustain";
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilitySourceName = 'eAbilitySource_Psionic';

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	StunEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(8, 100, false); //99 turns
	StunEffect.SetDisplayInfo(ePerkBuff_Penalty, class'X2StatusEffects'.default.StunnedFriendlyName, class'X2StatusEffects'.default.StunnedFriendlyDesc, "img:///UILibrary_PerkIcons.UIPerk_stun");
	StunEffect.EffectRemovedFn = BleedoutFn;
	Template.AddTargetEffect(StunEffect);

	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventID = class'X2Effect_FakeBleedout'.default.SustainEvent;
	EventTrigger.ListenerData.Filter = eFilter_Unit;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self_VisualizeInGameState;
	Template.AbilityTriggers.AddItem(EventTrigger);

	Template.PostActivationEvents.AddItem(class'X2Effect_FakeBleedout'.default.SustainTriggeredEvent);
		
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function BleedoutFn(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed)
{
	local XComGameState_Unit TargetUnit;
	//local X2EventManager EventManager;
	local int KillAmount;


	TargetUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	KillAmount = TargetUnit.GetCurrentStat(eStat_HP) + TargetUnit.GetCurrentStat(eStat_ShieldHP);


	TargetUnit.TakeEffectDamage(PersistentEffect, KillAmount, 0, 0, ApplyEffectParameters, NewGameState, false);
}

static function X2AbilityTemplate CreateIntimidate()
{
	local X2AbilityTemplate						Template;
	local X2Effect_CoveringFire                 CoveringEffect;

	Template = PurePassive('RM_Intimidate', "img:///UILibrary_DLC3Images.UIPerk_spark_intimidate", false, 'eAbilitySource_Perk', true);
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer);

	CoveringEffect = new class'X2Effect_CoveringFire';
	CoveringEffect.BuildPersistentEffect(1, true, false, false);
	CoveringEffect.AbilityToActivate = 'RM_IntimidateTrigger';
	CoveringEffect.GrantActionPoint = 'intimidate';
	CoveringEffect.bPreEmptiveFire = false;
	CoveringEffect.bDirectAttackOnly = true;
	CoveringEffect.bOnlyDuringEnemyTurn = true;
	CoveringEffect.bUseMultiTargets = false;
	CoveringEffect.EffectName = 'IntimidateWatchEffect';
	Template.AddTargetEffect(CoveringEffect);

	Template.AdditionalAbilities.AddItem('RM_IntimidateTrigger');

	return Template;
}

static function X2AbilityTemplate CreateIntimidateTrigger()
{
	local X2AbilityTemplate						Template;
	local X2Effect_Panicked						PanicEffect;
	local X2AbilityCost_ReserveActionPoints     ActionPointCost;
	local X2Condition_UnitEffects               UnitEffects;

	Template= new(None, string('RM_IntimidateTrigger')) class'X2AbilityTemplate'; Template.SetTemplateName('RM_IntimidateTrigger');;;
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer);

	Template.IconImage = "img:///UILibrary_DLC3Images.UIPerk_spark_intimidate";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Offensive;

	ActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.AllowedTypes.Length = 0;
	ActionPointCost.AllowedTypes.AddItem('intimidate');
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	UnitEffects = new class'X2Condition_UnitEffects';
	UnitEffects.AddExcludeEffect(class'X2AbilityTemplateManager'.default.StunnedName, 'AA_UnitIsStunned');
	Template.AbilityShooterConditions.AddItem(UnitEffects);

	Template.AbilityToHitCalc = default.DeadEye;                //  the real roll is in the effect apply chance
	Template.AbilityTargetStyle = default.SelfTarget;

	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');

	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);

	PanicEffect = class'X2StatusEffects'.static.CreatePanickedStatusEffect();
	PanicEffect.ApplyChanceFn = IntimidationApplyChance;
	PanicEffect.VisualizationFn = Intimidate_Visualization;
	Template.AddTargetEffect(PanicEffect);

	Template.CustomFireAnim = 'NO_Intimidate';
	Template.bShowActivation = true;
	Template.CinescriptCameraType = "Spark_Intimidate";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

function name IntimidationApplyChance(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	//  this mimics the panic hit roll without actually BEING the panic hit roll
	local XComGameState_Unit TargetUnit, SourceUnit;
	local name ImmuneName;
	local int AttackVal, DefendVal, TargetRoll, RandRoll;
	//local XComGameState_Item ArmorState;

	SourceUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	if (SourceUnit == none)
		SourceUnit = XComGameState_Unit(class'XComGameStateHistory'.static.GetGameStateHistory().GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	TargetUnit = XComGameState_Unit(kNewTargetState);
	if (TargetUnit != none)
	{
		foreach class'X2AbilityToHitCalc_PanicCheck'.default.PanicImmunityAbilities(ImmuneName)
		{
			if (TargetUnit.FindAbility(ImmuneName).ObjectID != 0)
			{
				return 'AA_UnitIsImmune';
			}
		}
		AttackVal = SourceUnit.GetCurrentStat(eStat_Will);
		DefendVal = TargetUnit.GetCurrentStat(eStat_Will);
		TargetRoll = class'X2AbilityToHitCalc_PanicCheck'.default.BaseValue + AttackVal - DefendVal;
		RandRoll = (class'Engine'.static.GetEngine().SyncRand(100,string(Name)@string(GetStateName())@string(GetFuncName())));
		if (RandRoll < TargetRoll)
			return 'AA_Success';
	}

	return 'AA_EffectChanceFailed';
}

static function Intimidate_Visualization(XComGameState VisualizeGameState, out VisualizationActionMetadata BuildTrack, const name EffectApplyResult)
{
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability Context;
	local X2AbilityTemplate	AbilityTemplate;

	if( EffectApplyResult != 'AA_Success' )
	{
		// pan to the panicking unit (but only if it isn't a civilian)
		Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
		UnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);
		if( (UnitState == none) || (Context == none) )
		{
			return;
		}

		AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(Context.InputContext.AbilityTemplateName);

		class'X2StatusEffects'.static.AddEffectCameraPanToAffectedUnitToTrack(BuildTrack, VisualizeGameState.GetContext());
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(BuildTrack, VisualizeGameState.GetContext(), AbilityTemplate.LocMissMessage, '' , eColor_Good, class'UIUtilities_Image'.const.UnitStatus_Panicked);
	}
}
static function X2AbilityTemplate CreateMimeticSkin()
{
	local X2AbilityTemplate						Template;
	local X2Effect_RangerStealth                StealthEffect;
	//local X2AbilityCharges                      Charges;
	local X2AbilityTrigger_EventListener    EventTrigger;
	//local X2Condition_Visibility            CoverCondition;


	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_MimeticSkin');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_stealth";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;

	// loot will also automatically trigger at the end of a move if it is possible
	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventTrigger.ListenerData.EventID = 'UnitMoveFinished';
	EventTrigger.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(EventTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_MimeticSkin');

	StealthEffect = new class'X2Effect_RangerStealth';
	StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	StealthEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true);
	StealthEffect.bRemoveWhenTargetConcealmentBroken = true;
	Template.AddTargetEffect(StealthEffect);

	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	Template.ActivationSpeech = 'ActivateConcealment';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	return Template;
}
static function X2AbilityTemplate CreateLongJump()
{
	local X2AbilityTemplate Template;	
	local X2Effect_PersistentTraversalChange	JumpServosEffect;
	local X2Effect_AdditionalAnimSets			IcarusAnimSet;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_LongJump');

	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	//Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_wraith";
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_jetboot_module";

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityShooterConditions.AddItem( default.LivingShooterProperty );
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	Template.AbilityToHitCalc = default.DeadEye;


	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;
	Template.bSkipPerkActivationActions = true; // we'll trigger related perks as part of the movement action

	// Give the unit the JumpUp traversal type
	JumpServosEffect = new class'X2Effect_PersistentTraversalChange';
	JumpServosEffect.BuildPersistentEffect( 1, true, true, false, eGameRule_PlayerTurnBegin );
	JumpServosEffect.SetDisplayInfo( ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText( ), Template.IconImage, true );
	JumpServosEffect.AddTraversalChange( eTraversal_JumpUp, true );
	JumpServosEffect.EffectName = 'LongJump';
	JumpServosEffect.DuplicateResponse = eDupe_Refresh;

	Template.AddTargetEffect( JumpServosEffect );

	// Because the DLC's animations do not exist in an uncooked state, we cannot add them to the weapon's archetype in the editor
	// Instead, this function will add the anims to the soldier for 1 turn, when the ability is activated.
	IcarusAnimSet = new class'X2Effect_AdditionalAnimSets';
	IcarusAnimSet.BuildPersistentEffect( 1, true, true, false, eGameRule_PlayerTurnBegin );
	//IcarusAnimSet.SetDisplayInfo( ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText( ), Template.IconImage, true );
	IcarusAnimSet.AddAnimSetWithPath( "DLC_60_Soldier_IcarusSuit_ANIM.Anims.AS_IcarusSuit" );
	
	Template.AddTargetEffect( IcarusAnimSet );


	return Template;
}



static function X2AbilityTemplate AddLauncherAbility()
{
	local X2AbilityTemplate					Template;
	local RM_Effect_UseGrenadeLauncher	AdvGLEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_GrenadeLauncher');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_grenade_flash";  // shouldn't ever display
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;

	AdvGLEffect = new class'RM_Effect_UseGrenadeLauncher'; //this is basically DerBk's work anyway
	Template.AddTargetEffect(AdvGLEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}