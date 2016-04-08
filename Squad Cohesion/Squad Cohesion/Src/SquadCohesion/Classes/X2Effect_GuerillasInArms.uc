class X2Effect_GuerillasInArms extends X2Effect_ModifyStats config(SquadCohesion);

var config int AIM_BASE;
var config int CRIT_BASE;
var config int WILL_BASE;
var config int MOBILITY_BASE;
var config int DEFENSE_BASE;
var config int DODGE_BASE;
var config int HACKING_BASE;
var config int ARMOR_BASE;


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit SourceUnit;

	SourceUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	if (SourceUnit == none)
		SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	`assert(SourceUnit != none);

	CalculateGuerillasInArmsStats(SourceUnit, XComGameState_Unit(kNewTargetState), NewEffectState);
	
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

simulated protected function CalculateGuerillasInArmsStats(XComGameState_Unit SourceUnit, XComGameState_Unit TargetUnit, XComGameState_Effect EffectState)
{

	local StatChange GuerillasInArms;

	//Aim
		GuerillasInArms.StatType = eStat_Offense;
		GuerillasInArms.StatAmount = default.AIM_BASE;
		EffectState.StatChanges.AddItem(GuerillasInArms);
	
	//Crit

		GuerillasInArms.StatType = eStat_CritChance;
		GuerillasInArms.StatAmount = default.CRIT_BASE;
		EffectState.StatChanges.AddItem(GuerillasInArms);

	// Will

		GuerillasInArms.StatType = eStat_Will;
		GuerillasInArms.StatAmount = default.WILL_BASE;
		EffectState.StatChanges.AddItem(GuerillasInArms);
	
	// Mobility

		GuerillasInArms.StatType = eStat_Mobility;
		GuerillasInArms.StatAmount = default.MOBILITY_BASE;
		EffectState.StatChanges.AddItem(GuerillasInArms);

	//Defense
		GuerillasInArms.StatType = eStat_Defense;
		GuerillasInArms.StatAmount = default.DEFENSE_BASE;
		EffectState.StatChanges.AddItem(GuerillasInArms);
	
	//Dodge

		GuerillasInArms.StatType = eStat_Dodge;
		GuerillasInArms.StatAmount = default.DODGE_BASE;
		EffectState.StatChanges.AddItem(GuerillasInArms);

	// Hack

		GuerillasInArms.StatType = eStat_Hacking;
		GuerillasInArms.StatAmount = default.HACKING_BASE;
		EffectState.StatChanges.AddItem(GuerillasInArms);
	
	// Armor

		GuerillasInArms.StatType = eStat_ArmorMitigation;
		GuerillasInArms.StatAmount = default.ARMOR_BASE;
		EffectState.StatChanges.AddItem(GuerillasInArms);
	
}

function bool IsEffectCurrentlyRelevant(XComGameState_Effect EffectGameState, XComGameState_Unit TargetUnit)
{
	//  Only relevant if we successfully rolled any stat changes
	return EffectGameState.StatChanges.Length > 0;
}

DefaultProperties
{
	EffectName = "GuerillasInArms"
	DuplicateResponse = eDupe_Ignore
}