class X2Effect_WeAreXCOM extends X2Effect_ModifyStats config(SquadCohesion);

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

	CalculateWeAreXCOMStats(SourceUnit, XComGameState_Unit(kNewTargetState), NewEffectState);
	
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

simulated protected function CalculateWeAreXCOMStats(XComGameState_Unit SourceUnit, XComGameState_Unit TargetUnit, XComGameState_Effect EffectState)
{

	local StatChange WeAreXCOM;

	//Aim
		WeAreXCOM.StatType = eStat_Offense;
		WeAreXCOM.StatAmount = default.AIM_BASE;
		EffectState.StatChanges.AddItem(WeAreXCOM);
	
	//Crit

		WeAreXCOM.StatType = eStat_CritChance;
		WeAreXCOM.StatAmount = default.CRIT_BASE;
		EffectState.StatChanges.AddItem(WeAreXCOM);

	// Will

		WeAreXCOM.StatType = eStat_Will;
		WeAreXCOM.StatAmount = default.WILL_BASE;
		EffectState.StatChanges.AddItem(WeAreXCOM);
	
	// Mobility

		WeAreXCOM.StatType = eStat_Mobility;
		WeAreXCOM.StatAmount = default.MOBILITY_BASE;
		EffectState.StatChanges.AddItem(WeAreXCOM);

	//Defense
		WeAreXCOM.StatType = eStat_Defense;
		WeAreXCOM.StatAmount = default.DEFENSE_BASE;
		EffectState.StatChanges.AddItem(WeAreXCOM);
	
	//Dodge

		WeAreXCOM.StatType = eStat_Dodge;
		WeAreXCOM.StatAmount = default.DODGE_BASE;
		EffectState.StatChanges.AddItem(WeAreXCOM);

	// Hack

		WeAreXCOM.StatType = eStat_Hacking;
		WeAreXCOM.StatAmount = default.HACKING_BASE;
		EffectState.StatChanges.AddItem(WeAreXCOM);
	
	// Armor

		WeAreXCOM.StatType = eStat_ArmorMitigation;
		WeAreXCOM.StatAmount = default.ARMOR_BASE;
		EffectState.StatChanges.AddItem(WeAreXCOM);
	
}

function bool IsEffectCurrentlyRelevant(XComGameState_Effect EffectGameState, XComGameState_Unit TargetUnit)
{
	//  Only relevant if we successfully rolled any stat changes
	return EffectGameState.StatChanges.Length > 0;
}

DefaultProperties
{
	EffectName = "WeAreXCOM"
	DuplicateResponse = eDupe_Ignore
}