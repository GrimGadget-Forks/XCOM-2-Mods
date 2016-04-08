class RM_UIMissionSummary_ScreenListener extends UIScreenListener dependson(XComGameState_Unit) config (SquadCohesion);

var int enemiesKilled;
var bool objectiveCompleted;
var bool  FlawlessMission;
var int soldiersKilled;
var int soldiersWounded;


var config float KillCohesionMultiplier;
var config int ObjCohesion;
var config int FlawlessCohesion;
var config int DeathCohesion;
var config int InjuryCohesion;
var config bool PostMissionCohesion;
var config bool ShakenAllowed;
var config bool SquadShaken;
var config bool SoldierShaken;

var config int LowShakenChance;
var config int MedShakenChance;
var config int HighShakenChance;

var config int LowSoldierShakenChance;
var config int MedSoldierShakenChance;
var config int HighSoldierShakenChance;

event OnInit(UIScreen Screen)
{
    local UIMissionSummary missionSummary;
    local int enemiesTotal, soldiersDead, soldiersInjured;
    local array<XComGameState_Unit> allUnits;
	local XComGameState_BattleData BattleData;
	local XComGameState_Cohesion CohesionState;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("MOD: Computing Cohesion Change");

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
    CohesionState = XComGameState_Cohesion(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_Cohesion'));


    missionSummary = UIMissionSummary(Screen);
    enemiesKilled = missionSummary.GetNumEnemiesKilled(enemiesTotal);
	soldiersKilled = missionSummary.GetNumSoldiersKilled(soldiersDead);
	soldiersWounded = missionSummary.GetNumSoldiersInjured(soldiersInjured);

	if(BattleData.bLocalPlayerWon)
	{
	`log("OPENING SEASME");
	objectiveCompleted = true;
	}

	if(!PostMissionCohesion)
	{
	return;
	}


	if(soldiersWounded == 0 && soldiersKilled == 0)
	{
		FlawlessMission = true;
	}

    allUnits = GetAllUnits();

	ChangeSquadmateScores(allUnits);

	if(soldiersKilled > 0 && ShakenAllowed && SquadShaken)
	{
	`log("People died, shaken is happening in squad");
	ShakenTesting(allUnits);
	}

	if(soldiersKilled > 0 && ShakenAllowed && SoldierShaken)
	{
	`log("People died, shaken is happening in soldiers");
	SoldierShakenTesting(allUnits, BattleData);
	}

//	if(CohesionState.PreviousSquadCohesion > 0)
	//{
	//CohesionState.PreviousSquadCohesion = 0;
	//NewGameState.AddStateObject(CohesionState);
	// `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
//
	//
	//}
   

}

//-----------------------------------------------------------------

function array<XComGameState_Unit> GetAllUnits()
{
    local int i;
    local XComGameState_Unit unit;
    local array<XComGameState_Unit> unitList;

    for(i = 0; i < `XCOMHQ.Squad.Length; i++)
    {
        Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(`XCOMHQ.Squad[i].ObjectID));

        if(Unit.IsASoldier() && Unit.IsAlive())
        {
            unitList.AddItem(unit);
        }
    }

    return unitList;
}
//-----------------------------------------------------------------------------------------------
function ShakenTesting(array<XComGameState_Unit> Units)
{
	local int i, SquadCohesion;
	local XComGameState NewGameState;
	local RM_SquadSelect_ScreenListener IniValues;
	local XComGameState_Cohesion CohesionState;
	 
	 
	CohesionState = XComGameState_Cohesion(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_Cohesion'));

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("MOD: Getting Shaken Status");
	IniValues = new class'RM_SquadSelect_ScreenListener';

	SquadCohesion = CohesionState.PreviousSquadCohesion;

	if(SquadCohesion < IniValues.LOW_SQUAD_COHESION)
	{
	`log("as it turns out this squad doesn't care for each other");
	return;
	}

	if(SquadCohesion >= IniValues.LOW_SQUAD_COHESION && SquadCohesion < IniValues.MED_SQUAD_COHESION)
	{
	`log("We kinda knew the deceased...");
		for (i = 0; i < Units.Length; ++i)
		{
			if(class'X2StrategyGameRulesetDataStructures'.static.Roll(LowShakenChance))
			{
						Units[i] = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Units[i].ObjectID));
						Units[i].bIsShaken = true;
						Units[i].bSeenShakenPopup = false;

						//Give this unit a random scar if they don't have one already
						if(Units[i].kAppearance.nmScars == '' && Units[i].IsInjured())
						{
							Units[i].GainRandomScar();
						}

						Units[i].SavedWillValue = Units[i].GetBaseStat(eStat_Will);
						Units[i].SetBaseMaxStat(eStat_Will, 0);
						Units[i].MissionsCompletedWhileShaken = -1;
						NewGameState.AddStateObject(Units[i]);
			}
		}
	}

	if(SquadCohesion >= IniValues.MED_SQUAD_COHESION && SquadCohesion < IniValues.HIGH_SQUAD_COHESION)
	{
	`log("They were a good friend...");
		for (i = 0; i < Units.Length; ++i)
		{
			if(class'X2StrategyGameRulesetDataStructures'.static.Roll(MedShakenChance))
			{
						Units[i] = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Units[i].ObjectID));
						Units[i].bIsShaken = true;
						Units[i].bSeenShakenPopup = false;

						//Give this unit a random scar if they don't have one already
						if(Units[i].kAppearance.nmScars == '' && Units[i].IsInjured())
						{
							Units[i].GainRandomScar();
						}

						Units[i].SavedWillValue = Units[i].GetBaseStat(eStat_Will);
						Units[i].SetBaseMaxStat(eStat_Will, 0);
						Units[i].MissionsCompletedWhileShaken = -1;
						NewGameState.AddStateObject(Units[i]);
			}
		
		}
	}

	if(SquadCohesion >= IniValues.HIGH_SQUAD_COHESION)
	{
	`log("DAMN YOU RNGESUS. DAMN YOU STRAIGHT TO HELL.");
		for (i = 0; i < Units.Length; ++i)
		{
			if(class'X2StrategyGameRulesetDataStructures'.static.Roll(HighShakenChance))
			{
						Units[i] = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Units[i].ObjectID));
						Units[i].bIsShaken = true;
						Units[i].bSeenShakenPopup = false;

						//Give this unit a random scar if they don't have one already
						if(Units[i].kAppearance.nmScars == '' && Units[i].IsInjured())
						{
							Units[i].GainRandomScar();
						}

						Units[i].SavedWillValue = Units[i].GetBaseStat(eStat_Will);
						Units[i].SetBaseMaxStat(eStat_Will, 0);
						Units[i].MissionsCompletedWhileShaken = -1;
						NewGameState.AddStateObject(Units[i]);
			}
		
		}
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}
//------------------------------------------------------------------------------------
function SoldierShakenTesting(array<XComGameState_Unit> Units, XComGameState_BattleData BattleData)
{
	local int i, j, cohesionTotal, deadSoldier;
	local XComGameState NewGameState;
	local RM_SquadSelect_ScreenListener IniValues;
	local array<XComGameState_Unit> arrUnits, deadUnits;
	local SquadmateScore SoldierCohesion;

	`BATTLE.GetLocalPlayer().GetOriginalUnits(arrUnits, true);
	

	for(i = 0; i < arrUnits.Length; i++)
	{
		if(arrUnits[i].IsDead() || arrUnits[i].IsBleedingOut()) //Bleeding-out units get cleaned up by SquadTacticalToStrategyTransfer, but that happens later
		{
			deadUnits.additem(arrUnits[i]);
		}
	}


	 
	//CohesionState = XComGameState_Cohesion(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_Cohesion'));

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("MOD: Getting Shaken Status");
	IniValues = new class'RM_SquadSelect_ScreenListener';

	//SquadCohesion = CohesionState.PreviousSquadCohesion;
	
	for(deadsoldier = 0; deadsoldier < deadUnits.Length; deadsoldier++)
	{
		for(j = 0; j < Units.Length; j++)
		{
			if (deadUnits[deadsoldier].GetSquadmateScore(Units[j].ObjectID, soldierCohesion))
			{
				`log("Now tell us how you felt about the dead soldier...");
		 		cohesionTotal = (soldierCohesion.Score * IniValues.REDUCER);
				if(cohesionTotal > 0)
				{
				`log("Well I felt...");
					break;
				}
			}
		}

				if(cohesionTotal < (IniValues.LOW_SQUAD_COHESION / 4) )
				{
				`log("as it turns we didn't care for each other that much");
				return;
				}

				if(cohesionTotal >= (IniValues.LOW_SQUAD_COHESION / 4) && cohesionTotal < (IniValues.MED_SQUAD_COHESION / 4) )
				{
				`log("Comrade no!");
							if(class'X2StrategyGameRulesetDataStructures'.static.Roll(LowSoldierShakenChance))
							{
								Units[j] = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Units[j].ObjectID));
								Units[j].bIsShaken = true;
								Units[j].bSeenShakenPopup = false;

								//Give this unit a random scar if they don't have one already
								if(Units[j].kAppearance.nmScars == '' && Units[i].IsInjured())
								{
									Units[j].GainRandomScar();
								}

								Units[j].SavedWillValue = Units[j].GetBaseStat(eStat_Will);
								Units[j].SetBaseMaxStat(eStat_Will, 0);
								Units[j].MissionsCompletedWhileShaken = -1;
								NewGameState.AddStateObject(Units[j]);
							}
				 }
				if(cohesionTotal >= (IniValues.MED_SQUAD_COHESION / 4) && cohesionTotal < (IniValues.HIGH_SQUAD_COHESION / 4) )
				{
				`log("BUDDY NOOOO!");
							if(class'X2StrategyGameRulesetDataStructures'.static.Roll(MedSoldierShakenChance))
							{
								Units[j] = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Units[j].ObjectID));
								Units[j].bIsShaken = true;
								Units[j].bSeenShakenPopup = false;

								//Give this unit a random scar if they don't have one already
								if(Units[j].kAppearance.nmScars == '' && Units[i].IsInjured())
								{
									Units[j].GainRandomScar();
								}

								Units[j].SavedWillValue = Units[j].GetBaseStat(eStat_Will);
								Units[j].SetBaseMaxStat(eStat_Will, 0);
								Units[j].MissionsCompletedWhileShaken = -1;
								NewGameState.AddStateObject(Units[j]);
							}
				 }
				if(cohesionTotal >= (IniValues.HIGH_SQUAD_COHESION / 4) )
				{
				`log("BEST FRIEND AND/OR LOVER NOOOOOOO!");
							if(class'X2StrategyGameRulesetDataStructures'.static.Roll(HighSoldierShakenChance))
							{
								Units[j] = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Units[j].ObjectID));
								Units[j].bIsShaken = true;
								Units[j].bSeenShakenPopup = false;

								//Give this unit a random scar if they don't have one already
								if(Units[j].kAppearance.nmScars == '' && Units[i].IsInjured())
								{
									Units[j].GainRandomScar();
								}

								Units[j].SavedWillValue = Units[j].GetBaseStat(eStat_Will);
								Units[j].SetBaseMaxStat(eStat_Will, 0);
								Units[j].MissionsCompletedWhileShaken = -1;
								NewGameState.AddStateObject(Units[j]);
							}
				 }
			
		

	}


	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}
//------------------------------------------------------------------------------------
function ChangeSquadmateScores(array<XComGameState_Unit> Units)
{
	local int CohesionChange, i, j, flawlessadder, objadder, deathsadder, injuryadder, killsadder;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("MOD: Changing Squad Cohesion");

	flawlessadder = 0;
	objadder = 0;
	deathsadder = 0;
	injuryadder = 0;

	killsadder = (enemiesKilled * KillCohesionMultiplier);

	if(FlawlessMission)
	{
	`log("Goddamn flawless effort, fucking A squad.");
	flawlessadder = FlawlessCohesion;
	}

	if(objectiveCompleted)
	{
	`log("Mission accomplished.");
	objadder = ObjCohesion;
	}

	if(soldiersKilled > 0)
	{
	`log("IT WAS YOUR FAULT THEY DIED. NO U");
	deathsadder = (soldiersKilled * DeathCohesion);
	}

	if(soldiersWounded > 0)
	{
	`log("Could you not have prevented me from getting shot back there?");
	injuryadder = (soldiersWounded * InjuryCohesion);
	}



	CohesionChange = killsadder + flawlessadder + objadder + deathsadder + injuryadder;

	for (i = 0; i < Units.Length; ++i)
	{

		for (j = i + 1; j < Units.Length; ++j)
		{
			Units[i] = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Units[i].ObjectID));
			Units[j] = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', Units[j].ObjectID));
			Units[i].AddToSquadmateScore(Units[j].ObjectID, CohesionChange);
			Units[j].AddToSquadmateScore(Units[i].ObjectID, CohesionChange);
			NewGameState.AddStateObject(Units[i]);
			NewGameState.AddStateObject(Units[j]);
		}
		
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}



defaultProperties
{
    ScreenClass = UIMissionSummary
}