class X2Condition_DarkEvac extends X2Condition;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local XComGameState_Unit UnitState, OtherUnit;
	local array<XComGameState_Unit> AllUnits;
	local XComGameState_Effect EffectState;
	local int DeadCount, OriginalCount;
	local float CurrentHP, MaxHP;
	local bool CanEvac;
	local XGBattle_SP Battle;
	local XComGameState_BattleData BattleData;
	local XComGameState_MissionSite MissionSite;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	MissionSite = XComGameState_MissionSite(History.GetGameStateForObjectID(BattleData.m_iMissionID));
	UnitState = XComGameState_Unit(kSource);
	CanEvac = false;

	if(MissionSite.GetMissionSource().DataName == 'MissionSource_MOCXAssault') //no evaccing on story missions
		return 'AA_UnitIsImmune';

	if(MissionSite.GetMissionSource().DataName == 'MissionSource_MOCXTraining') //no evaccing on story missions
		return 'AA_UnitIsImmune';

	if(MissionSite.GetMissionSource().DataName == 'MissionSource_MOCXOffsite') //no evaccing on story missions
		return 'AA_UnitIsImmune';

	if (UnitState == none)
		return 'AA_NotAUnit';

	if (UnitState.IsDead() || UnitState.IsUnconscious() || UnitState.IsBleedingOut())
		return 'AA_UnitIsDead';

	if (UnitState.IsPanicked())
		return 'AA_UnitIsPanicked';


	//  Check to see if we are eligible to evac

	MaxHP = UnitState.GetBaseStat(eStat_HP);
	CurrentHP = UnitState.GetCurrentStat(eStat_HP);


	if(CurrentHP < MaxHP)
	{
	//`log("Dark XCom: Checking HP For Evac");
		if((CurrentHP / MaxHP) <= 0.4) //if at or under 40% of HP, can evac
			CanEvac = true;

	}

	if (!CanEvac) //now we start checking if half the squad is dead or already away
	{
	//`log("Dark XCom: Checking Squad For Evac");
		DeadCount = 0;
		OriginalCount = 1; //well I mean if we can check this...
		Battle = XGBattle_SP(`BATTLE);
		if(Battle != none)
			Battle.GetAIPlayer().GetOriginalUnits(AllUnits, true, true);

		foreach AllUnits(OtherUnit)
		{
			if (OtherUnit != UnitState && OtherUnit.GetMyTemplate().CharacterGroupName == 'DarkXComSoldier')
			{
				OriginalCount++;

				if(OtherUnit.IsDead() || OtherUnit.bRemovedFromPlay)
					DeadCount++;
			}
		}

		if(DeadCount > 0 && (OriginalCount / DeadCount <= 2))
			CanEvac = true;

	}

	if (CanEvac)
	{
		//`log("Dark XCom: we can evacuate now");
		return 'AA_Success';
	}

	return 'AA_UnitIsImmune';
}