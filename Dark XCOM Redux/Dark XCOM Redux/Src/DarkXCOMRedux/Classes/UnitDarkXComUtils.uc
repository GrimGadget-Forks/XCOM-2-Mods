class UnitDarkXComUtils extends Object config(DarkXCom);

var config int NormalHealingRate;

var config int AdvancedHealingRate;

var config array<name> NormalPCSes;
var config array<name> GenePCSes;

var config array<SoldierClassAbilityType> AWCAbilities;

var config int VigilanceChance; //how much does the chance increase in for a mission in a high vigilance region?
var config int VigilanceThreshold; //how much vigiliance does a region need before the above takes effect?
var config int LowThreshold; //how low of vigiliance does a region need before we start subtracting chances of MOCX appearing?


var config int AWCLimit; //how many AWC abilities can a MOCX soldier have?

static function string GetFullName(XComGameState_Unit Unit)
{
	local bool bFirstNameBlank;

	bFirstNameBlank = (Unit.GetFirstName() == "");

	if(bFirstNameBlank)
		return (SanitizeQuotes(Unit.GetNickName())  @ Unit.GetLastName());

	return (Unit.GetFirstName() @ SanitizeQuotes(Unit.GetNickName())  @  Unit.GetLastName());

}

static function string SanitizeQuotes(string DisplayLabel)
{
	local string SanitizedLabel; 

	SanitizedLabel = DisplayLabel; 

	//If we're in CHT, check to see if we spot single quotes in the name. If so, strip them out. 
	if( GetLanguage() == "CHT" )
	{
		if( Left(SanitizedLabel, 1) == "'" )
		{
			SanitizedLabel = Right(SanitizedLabel, Len(SanitizedLabel) - 1);
		}
		if( Right(SanitizedLabel, 1) == "'" )
		{
			SanitizedLabel = Left(SanitizedLabel, Len(SanitizedLabel) - 1);
		}
	}
	return SanitizedLabel; 
}



static function RemoveFromSquad(XComGameState_HeadquartersDarkXCom DarkXComHQ, StateObjectReference ReferenceToRemove, XComGameState_Unit_DarkXComInfo DarkInfoState)
{
	DarkXComHQ.Squad.RemoveItem(ReferenceToRemove);
	DarkInfoState.bInSquad = false;
	DarkInfoState.bCosmeticDone = false;

	If(!DarkInfoState.bIsAlive)
	{
		`log("Dark XCOM: Soldier has died, removing from HQ's active crew.", ,'DarkXCom');
		DarkXComHq.DeadCrew.AddItem(ReferenceToRemove);
		DarkXComHQ.Crew.RemoveItem(ReferenceToRemove);
	}

}


static function KillDarkSoldier(XComGameState_Unit_DarkXComInfo DarkInfoState)
{
	DarkInfoState.bIsAlive = false;
}

static function bool IsAlive(XComGameState_Unit Unit )
{
	local XComGameState_Unit_DarkXComInfo InfoState;

	if (Unit != none)
	{
		InfoState = XComGameState_Unit_DarkXComInfo(Unit.FindComponentObject(class'XComGameState_Unit_DarkXComInfo'));

		return InfoState.bIsAlive;
	}
	return false;
}
static function GiveAWCAbility(XComGameState_Unit_DarkXComInfo DarkInfoState)
{
	local array<name> ValidAbilities, CurrentAbilities, ExcludedAbilities;
	local name AbilityToSend;
	local int i, k;
	local SoldierClassAbilityType CurrentAbility;
	local X2DarkSoldierClassTemplate Template;


	Template = class'UnitDarkXComUtils'.static.FindDarkClassTemplate(DarkInfoState.GetClassName());
	CurrentAbilities = DarkInfoState.GetBonusAbilities();

	if(CurrentAbilities.Length >= default.AWCLimit)
	{
		`log("Dark XCom: Soldier has already hit maximum number of AWC abilities.", ,'DarkXCom');
		return;
	}
	
	foreach default.AWCAbilities(CurrentAbility)
	{
		ValidAbilities.AddItem(CurrentAbility.AbilityName);
	}
	ExcludedAbilities = Template.ExcludedAbilities;


	for(i = 0; i < ExcludedAbilities.Length; i++)
	{
		for(k = 0; k < ValidAbilities.Length; k++)
		{
			if(ExcludedAbilities[i] == ValidAbilities[k])
			{
				ValidAbilities.RemoveItem( ValidAbilities[k]);
				break;
			}
		}
	}

	for(i = 0; i < CurrentAbilities.Length; i++)
	{
		for(k = 0; k < ValidAbilities.Length; k++)
		{
			if(CurrentAbilities[i] == ValidAbilities[k])
			{
				ValidAbilities.RemoveItem( ValidAbilities[k]);
				break;
			}

		}

	}

	AbilityToSend = ValidAbilities[`SYNC_RAND_STATIC(ValidAbilities.Length)];

	`log("Dark XCom: Soldier has earned the AWC ability: " $ AbilityToSend, ,'DarkXCom');

	foreach default.AWCAbilities(CurrentAbility)
	{
		if(CurrentAbility.AbilityName == AbilityToSend)
		{
			DarkInfoState.AddBonusAbility(CurrentAbility);
		}
	}
}

static function XComGameState_Unit_DarkXComInfo GetDarkXComComponent(XComGameState_Unit Unit, optional XComGameState CheckGameState)
{
	local XComGameState_BaseObject TempObj;
	if (Unit != none)
	{
		if (CheckGameState != none)
		{
			TempObj = CheckGameState.GetGameStateComponentForObjectID(Unit.GetReference().ObjectID, class'XComGameState_Unit_DarkXComInfo');
			if (TempObj != none)
			{
				return XComGameState_Unit_DarkXComInfo(TempObj);
			}
		}
		return XComGameState_Unit_DarkXComInfo(Unit.FindComponentObject(class'XComGameState_Unit_DarkXComInfo'));
	}
	return none;
}

static function XComGameState_HeadquartersDarkXCom GetDarkXComHQ()
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	DarkXComHQ = XComGameState_HeadquartersDarkXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));
	return DarkXComHQ;
}

static function int AssignRecoveryTime(XComGameState_Unit Unit, XComGameState_Unit_DarkXComInfo DarkInfoState, XComGameState_HeadquartersDarkXCom DarkXComHQ)
{
	local int Output, CurrentHP, MaxHP;

	CurrentHP = Unit.GetCurrentStat(eStat_HP);

	MaxHP = Unit.GetMaxStat(eStat_HP);

	Output = (MaxHP - CurrentHP) * default.NormalHealingRate; //one point of HP lost = 6 days

	if(DarkXComHQ.bAdvancedICUs)
		Output = (MaxHP - CurrentHP) * default.AdvancedHealingRate; //one point of HP lost = 3 days

	return Output;
}


static function bool HasContestingTags(XComGameState_MissionSite MissionState) //we need to do this seperately since we have a strategyrequirement to block the MOCX sitrep from being spawned normally
{
	local X2SitRepTemplateManager SitRepManager;
	local X2SitRepTemplate SitRepTemplate;
	local XComGameStateHistory History;
	local XComGameState_HeadquartersAlien AlienHQ; 
	local XComGameState_HeadquartersXCom XComHQ; 
	local MissionDefinition MissionDef;
	local name GameplayTag;
	local int ForceLevel;
	local name Tag;
	SitRepManager = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();
	SitRepTemplate = SitRepManager.FindSitRepTemplate('MOCX');

	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	ForceLevel = AlienHQ.GetForceLevel();
	MissionDef = MissionState.GeneratedMission.Mission;

	if((SitrepTemplate.MinimumForceLevel > 0 && ForceLevel < SitrepTemplate.MinimumForceLevel) || (SitrepTemplate.MaximumForceLevel > 0 && ForceLevel > SitrepTemplate.MaximumForceLevel))
	{
		return true;
	}

	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	foreach SitrepTemplate.TacticalGameplayTags(Tag)
	{
		if(XComHQ.TacticalGameplayTags.Find(Tag) != INDEX_NONE)
		{
			return true;
		}
	}

	if(SitrepTemplate.ValidMissionTypes.Length > 0 && SitrepTemplate.ValidMissionTypes.Find(MissionDef.sType) == INDEX_NONE)
	{
		return true;
	}

	if(SitrepTemplate.ValidMissionFamilies.Length > 0 && SitrepTemplate.ValidMissionFamilies.Find(MissionDef.MissionFamily) == INDEX_NONE)
	{
		return true;
	}

	foreach MissionState.TacticalGameplayTags(GameplayTag)
	{
		if(SitrepTemplate.ExcludeGameplayTags.Find(GameplayTag) != INDEX_NONE)
		{
			return true;
		}
	}

	return false;


}

static function bool IsInvalidMission(X2MissionSourceTemplate MissionTemplate)
{
	if(MissionTemplate.DataName == 'MissionSource_LostAndAbandoned' || MissionTemplate.DataName == 'MissionSource_RescueSoldier' || MissionTemplate.DataName == 'MissionSource_ChosenAmbush') //no limited squad missions
	{
		return true;
	}

	//for my sanity, we shall split checking all invalid mission sources into blocks

	if(MissionTemplate.DataName == 'MissionSource_ChosenStronghold' || MissionTemplate.DataName == 'MissionSource_Broadcast') //|| MissionTemplate.DataName == 'MissionSource_AvengerDefense')
	{
		return true;
	}
	//disabled Strongholds and Sabotage missions because they linger on the geoscape: the SITREP active check will remain active from them.
	  

	if(MissionTemplate.DataName == 'MissionSource_Start' || MissionTemplate.DataName == 'MissionSource_RecoverFlightDevice' || MissionTemplate.DataName == 'MissionSource_AlienNetwork') //no tutorial missions
	{
		return true;
	}

	if(MissionTemplate.DataName == 'MissionSource_AlienNest' || MissionTemplate.DataName == 'MissionSource_LostTowers') // no dlc
	{
		return true;
	}

	return false;

}

static function GivePromotion( XComGameState_Unit_DarkXComInfo DarkInfoState)
{
	DarkInfoState.RankUp(1);
}
static function X2DarkSoldierClassTemplate FindDarkClassTemplate(Name DataName)
{
	local X2DarkSoldierClassTemplate SoldierClassTemplate;
	local X2StrategyElementTemplateManager TemplateManager;
	local array<X2StrategyElementTemplate> Templates;
	local X2StrategyElementTemplate Template;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	Templates = TemplateManager.GetAllTemplatesOfClass(class'X2DarkSoldierClassTemplate');
	foreach Templates(Template)
	{
		`log("Dark XCom: Template being checked is " $ Template.DataName, ,'DarkXCom');
		SoldierClassTemplate = X2DarkSoldierClassTemplate(Template);

		if(SoldierClassTemplate != none && DataName == SoldierClassTemplate.DataName)
		{
			return SoldierClassTemplate;
		}
	}
}

static function name GetDarkPCS(XComGameState_Unit_DarkXComInfo DarkInfo)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local XComGameStateHistory History;
	local array<name> PCSesToPick;
	local name PCStoAdd;

	if(!DarkInfo.bIsAlive)
	{
		`log("Dark XCom: this is a dead unit.", ,'DarkXCom');
		return '';
	}
	History = `XCOMHISTORY;
	DarkXComHQ = XComGameState_HeadquartersDarkXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom'));
	PCSesToPick = default.NormalPCSes;
	if(DarkXComHQ != none)
	{
		if(DarkXComHQ.bGeneticPCS)
		{
			foreach default.GenePCSes(PCStoAdd)
			{
				PCSesToPick.AddItem(PCStoAdd);
			}
		}

		return PCSesToPick[`SYNC_RAND_STATIC(PCSesToPick.Length)];
	}

	`log("Dark XCom: Could not find DarkXCOMHQ", ,'DarkXCom');
	return PCSesToPick[`SYNC_RAND_STATIC(PCSesToPick.Length)];
}


static function name GetAllDarkPCS(XComGameState_Unit_DarkXComInfo DarkInfo)
{
	local array<name> PCSesToPick;
	local name PCStoAdd;

	if(!DarkInfo.bIsAlive)
	{
		`log("Dark XCom: this is a dead unit.", ,'DarkXCom');
		return '';
	}
	PCSesToPick = default.NormalPCSes;

	foreach default.GenePCSes(PCStoAdd)
	{
		PCSesToPick.AddItem(PCStoAdd);
	}
		

	return PCSesToPick[`SYNC_RAND_STATIC(PCSesToPick.Length)];

}