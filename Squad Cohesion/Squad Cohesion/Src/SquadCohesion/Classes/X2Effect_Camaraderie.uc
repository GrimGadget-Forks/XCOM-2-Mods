// This is an Unreal Script

class X2Effect_Camaraderie extends X2Effect_ModifyStats config(SquadCohesion);

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

	CalculateCamaraderieStats(SourceUnit, XComGameState_Unit(kNewTargetState), NewEffectState);
	
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

simulated protected function CalculateCamaraderieStats(XComGameState_Unit SourceUnit, XComGameState_Unit TargetUnit, XComGameState_Effect EffectState)
{

	local StatChange Camaraderie;

	//Aim
		Camaraderie.StatType = eStat_Offense;
		Camaraderie.StatAmount = default.AIM_BASE;
		EffectState.StatChanges.AddItem(Camaraderie);
	
	//Crit

		Camaraderie.StatType = eStat_CritChance;
		Camaraderie.StatAmount = default.CRIT_BASE;
		EffectState.StatChanges.AddItem(Camaraderie);

	// Will

		Camaraderie.StatType = eStat_Will;
		Camaraderie.StatAmount = default.WILL_BASE;
		EffectState.StatChanges.AddItem(Camaraderie);
	
	// Mobility

		Camaraderie.StatType = eStat_Mobility;
		Camaraderie.StatAmount = default.MOBILITY_BASE;
		EffectState.StatChanges.AddItem(Camaraderie);

	//Defense
		Camaraderie.StatType = eStat_Defense;
		Camaraderie.StatAmount = default.DEFENSE_BASE;
		EffectState.StatChanges.AddItem(Camaraderie);
	
	//Dodge

		Camaraderie.StatType = eStat_Dodge;
		Camaraderie.StatAmount = default.DODGE_BASE;
		EffectState.StatChanges.AddItem(Camaraderie);

	// Hack

		Camaraderie.StatType = eStat_Hacking;
		Camaraderie.StatAmount = default.HACKING_BASE;
		EffectState.StatChanges.AddItem(Camaraderie);
	
	// Armor

		Camaraderie.StatType = eStat_ArmorMitigation;
		Camaraderie.StatAmount = default.ARMOR_BASE;
		EffectState.StatChanges.AddItem(Camaraderie);
	
}

function bool IsEffectCurrentlyRelevant(XComGameState_Effect EffectGameState, XComGameState_Unit TargetUnit)
{
	//  Only relevant if we successfully rolled any stat changes
	return EffectGameState.StatChanges.Length > 0;
}

DefaultProperties
{
	EffectName = "Camaraderie"
	DuplicateResponse = eDupe_Ignore
}