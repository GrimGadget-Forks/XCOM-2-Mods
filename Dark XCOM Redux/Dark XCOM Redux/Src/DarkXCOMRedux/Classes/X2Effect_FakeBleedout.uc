class X2Effect_FakeBleedout extends X2Effect_Persistent;

var privatewrite name SustainUsed;
var privatewrite name SustainEvent, SustainTriggeredEvent;

function bool PreDeathCheck(XComGameState NewGameState, XComGameState_Unit UnitState, XComGameState_Effect EffectState)
{
	local X2EventManager EventMan;
	local int Chance;
	local int Roll, RollOutOf, RandomOverKill;
	local UnitValue SustainValue;

	if (UnitState.GetUnitValue(default.SustainUsed, SustainValue))
	{
		if (SustainValue.fValue > 0)
			return false;
	}

	RandomOverkill = `SYNC_RAND(10) + `SYNC_RAND(10); //less likely to survive hits

	Chance = class'X2StatusEffects'.static.GetBleedOutChance(UnitState, RandomOverKill);
	RollOutOf = class'X2StatusEffects'.default.BLEEDOUT_ROLL;

	Roll = `SYNC_RAND(RollOutOf);

	if(Roll > Chance) //failed will check, they're ded
		return false;

	UnitState.SetUnitFloatValue(default.SustainUsed, 1, eCleanup_BeginTactical);
	UnitState.SetCurrentStat(eStat_HP, 1);
	EventMan = `XEVENTMGR;
	EventMan.TriggerEvent(default.SustainEvent, UnitState, UnitState, NewGameState);
	return true;
}

function bool PreBleedoutCheck(XComGameState NewGameState, XComGameState_Unit UnitState, XComGameState_Effect EffectState)
{
	return PreDeathCheck(NewGameState, UnitState, EffectState);
}

//function RegisterForEvents(XComGameState_Effect EffectGameState)
//{
	//local XComGameState_Unit UnitState;
	//local X2EventManager EventMan;
	//local Object EffectObj;
//
	//UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	//EventMan = `XEVENTMGR;
	//EffectObj = EffectGameState;
//
	////EventMan.RegisterForEvent(EffectObj, default.SustainTriggeredEvent, class'XComGameState_Effect'.static.SustainActivated, ELD_OnStateSubmitted, , UnitState);
//}

DefaultProperties
{
	SustainUsed = "FakeUsed"
	SustainEvent = "FakeTriggered"
	SustainTriggeredEvent = "FakeSuccess"
}