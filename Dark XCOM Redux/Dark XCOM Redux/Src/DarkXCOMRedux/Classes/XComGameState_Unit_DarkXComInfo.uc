class XComGameState_Unit_DarkXComInfo extends XComGameState_BaseObject config(DarkXCom);

var protected X2DarkSoldierClassTemplate SoldierClass; //class this soldier has
var protected name ClassName;
var int Rank; //rank of this MOCX soldier
var array<SoldierClassAbilityType> AWCAbilities; //abilities this soldier has from MOCX's AWC
var array<SoldierClassAbilityType> SoldierAbilities; //abilities this soldier has from their class
var name EquippedPCS; //PCS this MOCX soldier has

var StateObjectReference AssignedUnit; //the unit this component is meant to reprsent on the battlefield

var int RankWill;
var int RankHP;
var int RankAim;
var int RankDodge; //used mainly by Shinobi
var int RankPsi; //used by psi agents

var protected int RecoveryPoints; //how much remaining time this soldier has to heal
var protected TDateTime RecoveryComplete;

var bool bIsAlive; //is the soldier actually alive
var bool bInSquad; //is the soldier in the active combat zone
var bool bAlreadyHandled; //did we already add this soldier to the combat zone
var bool bCosmeticDone; //has the soldier's looks already been used?

var int MonthsInService; //how long has this soldier been active?
var int MonthsSinceLastPromotion; //when was the last time this soldier got promoted?

//config variables
var config int PromotionThreshold; //how many months does it take for a soldier to promote?

var config int GlobalWillGrowth; //how much will do soldiers earn per level up?

function XComGameState_Unit_DarkXComInfo InitComponent(name DarkSoldierClass)
{
	local XComGameStateHistory		History;
	local XComGameState_GameTime	TimeState;
	local X2DarkSoldierClassTemplate ClassTemplate;
	local int i, StatVal;
	local array<SoldierClassAbilitySlot> AbilityTree;
	local array<SoldierClassStatType> StatProgression;

	History = `XCOMHISTORY;
	TimeState = XComGameState_GameTime(History.GetSingleGameStateObjectForClass(class'XComGameState_GameTime'));
	RecoveryComplete = TimeState.CurrentTime;
	RecoveryPoints = 0;
	
	bIsAlive = true;
	bInSquad = false;

	ClassTemplate = class'UnitDarkXComUtils'.static.FindDarkClassTemplate(DarkSoldierClass);
	SoldierClass = ClassTemplate;
	ClassName = ClassTemplate.DataName;
	Rank = 1;
	EquippedPCS = class'UnitDarkXComUtils'.static.GetDarkPCS(self);
	AWCAbilities.Length = 0;
	SoldierAbilities.Length = 0;

	AbilityTree = ClassTemplate.GetAbilitySlots(0);

	for(i = 0; i < AbilityTree.Length; i++)
	{
		`log("Dark XCom: Adding squaddie abilitiy - " $ ClassTemplate.GetAbilityName(0, i), ,'DarkXCom');
		SoldierAbilities.AddItem(AbilityTree[i].AbilityType);
	}


	StatProgression = ClassTemplate.GetStatProgression(0);
	for (i = 0; i < StatProgression.Length; ++i)
	{
		StatVal = StatProgression[i].StatAmount + `SYNC_RAND(StatProgression[i].RandStatAmount);

		`log("Dark XCom: current stat value is " $ StatVal, ,'DarkXCom');

		if(StatProgression[i].StatType == eStat_Will)
			RankWill += StatVal;

		if(StatProgression[i].StatType == eStat_HP)
			RankHP += StatVal;

		if(StatProgression[i].StatType == eStat_Offense)
			RankAim += StatVal;

		if(StatProgression[i].StatType == eStat_Dodge)
			RankDodge += StatVal;

		if(StatProgression[i].StatType == eStat_PsiOffense)
			RankPsi += StatVal;
	}



	return self;
}

function array<name> GetBonusAbilities()
{
	local array<name> ArrayToSend;
	local SoldierClassAbilityType Ability;

	foreach AWCAbilities(Ability)
	{
		ArrayToSend.AddItem(Ability.AbilityName);
	}

	return ArrayToSend;
}

function AddBonusAbility(SoldierClassAbilityType AWCAbility)
{
	AWCAbilities.AddItem(AWCAbility);
}

function RankUp(int RanksBy)
{
	local int i, k, StatVal, ForValue, cRank;
	local X2DarkSoldierClassTemplate Template;
	local array<SoldierClassStatType> StatProgression;
	local array<SoldierClassAbilitySlot> AbilityTreeCheck;

	Template =  class'UnitDarkXComUtils'.static.FindDarkClassTemplate(GetClassName());

	if(Template == none)
	{
	`log("Dark XCom: could not find class template.", ,'DarkXCom');
	return;
	}

	if(Template.GetMaxConfiguredRank() <= GetRank())
	{
	`log("Dark XCom: Already at max rank.", ,'DarkXCom');
	return;
	}
	ForValue = (RanksBy + GetRank());
	cRank = GetRank();

	for(i = cRank; i < ForValue; i++)
	{
		AbilityTreeCheck = Template.GetAbilitySlots(i);

		if(Template.GetAbilityName(i, 0) == '')
		{
		`log("Dark Xcom: uh, we somehow have no ability tree for this rank. The fuck?", ,'DarkXCom');
		return;
		}

		k = `SYNC_RAND(AbilityTreeCheck.Length);

		if(Template.GetAbilityName(i, k) == '')
		{
		`log("Dark XCom: Tried to add non-existent ability!", ,'DarkXCom');
		k = 0; //there is always a perk at each rank, so we do this.
		}

		SoldierAbilities.AddItem(AbilityTreeCheck[k].AbilityType); // class ranks are 1 below actual ranks. 
		`log("Dark XCOM: Added the following ability to a MOCX soldier: " $ Template.GetAbilityName(i, k));

		StatProgression = Template.GetStatProgression(i);
		for (k = 0; k < StatProgression.Length; ++k)
		{
			StatVal = StatProgression[k].StatAmount + `SYNC_RAND(StatProgression[k].RandStatAmount);

			if(StatVal <= 0)
			{
			`log("Dark XCOm: no stat value to add", ,'DarkXCom');
			continue;
			}


			//`log("Dark XCom: current stat value is " $ StatVal);
			if(StatProgression[k].StatType == eStat_Will)
				RankWill += StatVal;

			if(StatProgression[k].StatType == eStat_HP)
				RankHP += StatVal;

			if(StatProgression[k].StatType == eStat_Offense)
				RankAim += StatVal;

			if(StatProgression[k].StatType == eStat_Dodge)
				RankDodge += StatVal;

			if(StatProgression[k].StatType == eStat_PsiOffense)
				RankPsi += StatVal;
		}

	}

	RankWill += GlobalWillGrowth;


	Rank += RanksBy; //so we can do multiple level ups, if needed
}

function SetPCS(name PCSName)
{
	EquippedPCS = PCSName;
}


function ApplyRecovery(XComGameState_Unit Unit, XComGameState_HeadquartersDarkXCom DarkXComHQ)
{
	local int Hours;
	
	Hours = class'UnitDarkXComUtils'.static.AssignRecoveryTime(Unit, self, DarkXComHQ);
	
	RecoveryPoints += Hours;
	SetRecoveryCompletionDate();
}


//---------------------------------------------------------------------------------------
function int GetRecoveryPoints()
{
	return RecoveryPoints;
}

function int GetRank()
{
	return Rank;
}

function X2DarkSoldierClassTemplate GetClass()
{

	return SoldierClass;
}

function name GetClassName()
{

	return ClassName;
}
function ResetRecovery()
{
	RecoveryPoints = 0;
}

function SetRecoveryCompletionDate()
{
	local XComGameStateHistory		History;
	local XComGameState_GameTime	TimeState;
	local TDateTime					TempTime;

	History = `XCOMHISTORY;
	TimeState = XComGameState_GameTime(History.GetSingleGameStateObjectForClass(class'XComGameState_GameTime'));

	TempTime = TimeState.CurrentTime;

	class'X2StrategyGameRulesetDataStructures'.static.AddHours(TempTime, RecoveryPoints);
	
	RecoveryComplete = TempTime;
}

function AssessRecovery()
{
	local XComGameStateHistory		History;
	local XComGameState_GameTime	TimeState;
	local TDateTime					TempTime;
	local int						HoursLeft;

	History = `XCOMHISTORY;
	TimeState = XComGameState_GameTime(History.GetSingleGameStateObjectForClass(class'XComGameState_GameTime'));

	TempTime = TimeState.CurrentTime;
	HoursLeft = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInHours(RecoveryComplete, TempTime);

	if(HoursLeft <= 0) //they're done
	{
		ResetRecovery();
	}
	else
	{
		RecoveryPoints = HoursLeft;

	}
}

function HalveRecovery()
{
	local XComGameStateHistory		History;
	local XComGameState_GameTime	TimeState;
	local TDateTime					TempTime;
	local int						HoursLeft;

	History = `XCOMHISTORY;
	TimeState = XComGameState_GameTime(History.GetSingleGameStateObjectForClass(class'XComGameState_GameTime'));

	TempTime = TimeState.CurrentTime;
	HoursLeft = class'X2StrategyGameRulesetDataStructures'.static.DifferenceInHours(RecoveryComplete, TempTime);

	if(HoursLeft <= 0) //they're done
	{
		ResetRecovery();
	}
	else
	{
		RecoveryPoints = (HoursLeft / 2);

	}
}
