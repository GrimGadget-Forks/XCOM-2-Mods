class XGCharacterGenerator_DarkXCom extends XGCharacterGenerator config(DarkXCom);

var config bool SoldiersOnly;
var config bool DarkVIPsOnly;
var config bool UseEntireAppearance;

struct ClassCosmetics
{
	var name DarkClassName;					// class this is used for
	var name ArmorName;				// Armor this is meant for
	var int	 iGender;       //use eGender_Male or eGender_Female
	var name Torso;
	var name Legs;
	var name Arms;
	var name LeftArm;
	var name RightArm;
	var name LeftArmDeco;
	var name RightArmDeco;
	var name Thighs; //XPACK added cosmetics
	var name TorsoDeco;
	var name RightForearm;
	var name LeftForearm;
	var name Shins;
	var name Flag;
	var name Voice;
};

var config array<ClassCosmetics> SoldierAppearances;


function XComGameState_Unit GetSoldier(name CharacterTemplateName, out name ClassName)
{
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;
	local XComGameStateHistory History;
	local XComGameState_Unit_DarkXComInfo InfoState;
	local XComGameState_Unit Unit;
	local int i;
	local bool SameClass;

	History = `XCOMHISTORY;
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));

	if(CharacterTemplateName == '' || CharacterTemplateName == 'DarkSoldier' || CharacterTemplateName == 'DarkRookie')
		return none;

	for(i = 0; i < DarkXComHQ.Squad.Length; i++)
	{
		Unit = XComGameState_Unit(History.GetGameStateForObjectID(DarkXComHQ.Squad[i].ObjectID));

		InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);

		SameClass = MatchNames(CharacterTemplateName, InfoState.GetClassName());

		if(SameClass && !InfoState.bCosmeticDone)
		{
			ClassName = InfoState.GetClassName();
			InfoState.bCosmeticDone = true;
			return Unit;
		}
	}
}


function bool MatchNames(name CharacterTemplateName, name InfoName)
{
	local name ActualName;

	ActualName = CharacterTemplateName;
	if(InfoName == '')
	{
		`log("Dark XCOM: no infostate name for name check.", ,'DarkXCom');
		return false;
	}
	if(ActualName == 'DarkGrenadier_M2' || ActualName == 'DarkGrenadier_M3')
	{
	ActualName = 'DarkGrenadier';

	}

	if(ActualName == 'DarkSpecialist_M2' || ActualName == 'DarkSpecialist_M3')
	{
	ActualName = 'DarkSpecialist';

	}

	if(ActualName == 'DarkRanger_M2' || ActualName == 'DarkRanger_M3')
	{
	ActualName = 'DarkRanger';

	}

	if(ActualName == 'DarkSniper_M2' || ActualName == 'DarkSniper_M3')
	{
	ActualName = 'DarkSniper';

	}


	if(ActualName == 'DarkPsiAgent_M2' || ActualName == 'DarkPsiAgent_M3')
	{
	ActualName = 'DarkPsiAgent';

	}


	if(ActualName == InfoName)
	{
	`log("Dark XCOM: Found right class name.", ,'DarkXCom');
		return true;
	}

	`log("Dark XCOM: did not have right class name", ,'DarkXCom');
	return false;

}

function TSoldier CreateTSoldier( optional name CharacterTemplateName, optional EGender eForceGender, optional name nmCountry = '', optional int iRace = -1, optional name ArmorName )
{
	local TSoldier result;
	local array<XComGameState_Unit> Characters;
	local XComGameState_Unit Unit;
	local bool UsingCharPool;
	local name DarkClassName;
	local ClassCosmetics PossibleAppearance;
	
	UsingCharPool = true; //this is a check so we use a random soldier when necessary.
	// if not character pool, randomly generate
	if(`CHARACTERPOOLMGR.GetSelectionMode(`XPROFILESETTINGS.Data.m_eCharPoolUsage) != eCPSM_PoolOnly)
	{
		UsingCharPool = false;
		result = super.CreateTSoldier('Soldier');
	}

	Characters = GetCharPoolCandidates(class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate(CharacterTemplateName));	

	if(Characters.length == 0 || !UsingCharPool)
	{
		result = super.CreateTSoldier('Soldier');
	}

	if(Characters.Length > 0 && UsingCharPool)
	{
		Unit = GetSoldier(CharacterTemplateName, DarkClassName);

		if(Unit == none)
			Unit = Characters[`SYNC_RAND(Characters.length)];

		result = super.CreateTSoldier('Soldier', EGender(Unit.kAppearance.iGender), Unit.kAppearance.nmFlag, Unit.kAppearance.iRace, ArmorName);
	}
	// copy name

	if(Unit != none && UsingCharPool)
	{
		result.strFirstName = Unit.GetFirstName();
		result.strLastName = Unit.GetLastName();
		result.strNickName = Unit.GetNickName();
	

		result.kAppearance.nmHead = Unit.kAppearance.nmHead;
		result.kAppearance.nmHaircut = Unit.kAppearance.nmHaircut;
		result.kAppearance.iHairColor = Unit.kAppearance.iHairColor;
		result.kAppearance.nmBeard = Unit.kAppearance.nmBeard;
		result.kAppearance.iSkinColor = Unit.kAppearance.iSkinColor;
		result.kAppearance.iEyeColor = Unit.kAppearance.iEyeColor;
		//result.kAppearance.iVoice = Unit.kAppearance.iVoice;
		result.kAppearance.iAttitude = Unit.kAppearance.iAttitude;


		result.kAppearance.iArmorDeco = Unit.kAppearance.iArmorDeco;
	
		result.kAppearance.iArmorTint = Unit.kAppearance.iArmorTint;
		result.kAppearance.iArmorTintSecondary = Unit.kAppearance.iArmorTintSecondary;
	
		result.kAppearance.nmHelmet = Unit.kAppearance.nmHelmet;
		result.kAppearance.nmEye = Unit.kAppearance.nmEye;
		result.kAppearance.nmTeeth = Unit.kAppearance.nmTeeth;
		result.kAppearance.nmFacePropUpper = Unit.kAppearance.nmFacePropUpper;
		result.kAppearance.nmFacePropLower = Unit.kAppearance.nmFacePropLower;
		result.kAppearance.nmPatterns = Unit.kAppearance.nmPatterns;

		result.kAppearance.nmVoice = Unit.kAppearance.nmVoice;

		result.kAppearance.iTattooTint = Unit.kAppearance.iTattooTint;
		result.kAppearance.nmTattoo_LeftArm = Unit.kAppearance.nmTattoo_LeftArm;
		result.kAppearance.nmTattoo_RightArm = Unit.kAppearance.nmTattoo_RightArm;
		result.kAppearance.nmScars = Unit.kAppearance.nmScars;
		result.kAppearance.nmFacepaint = Unit.kAppearance.nmFacepaint;
	}

	if(!`CHARACTERPOOLMGR.FixAppearanceOfInvalidAttributes(result.kAppearance))
	{
		result =  super.CreateTSoldier('Soldier');
	}
	result.nmCountry = 'Country_ADVENT';
	result.kAppearance.nmFlag = 'Country_ADVENT';
	if(result.kAppearance.iGender == eGender_Male)
	{
		foreach SoldierAppearances(PossibleAppearance)
		{
			//class and armor specific appearance first
			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '') && PossibleAppearance.DarkClassName == DarkClassName && PossibleAppearance.iGender == eGender_Male)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}
				break;
			}
			//then armor specific
			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '') && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Male)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				break;
			}
			//then general
			if(PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Male)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				break;
			}

		}
	}

	if(result.kAppearance.iGender == eGender_Female)
	{
		foreach SoldierAppearances(PossibleAppearance)
		{
			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '') && PossibleAppearance.DarkClassName == DarkClassName && PossibleAppearance.iGender == eGender_Female)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				break;
			}

			if((PossibleAppearance.ArmorName == ArmorName || ArmorName == '') && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Female)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				break;
			}

			if(PossibleAppearance.ArmorName == '' && PossibleAppearance.DarkClassName == '' && PossibleAppearance.iGender == eGender_Female)
			{
				result.kAppearance.nmTorso = PossibleAppearance.Torso;
				result.kAppearance.nmLegs = PossibleAppearance.Legs;
				result.kAppearance.nmArms = PossibleAppearance.Arms;
				result.kAppearance.nmLeftArm = PossibleAppearance.LeftArm;
				result.kAppearance.nmRightArm = PossibleAppearance.RightArm;
				result.kAppearance.nmLeftArmDeco = PossibleAppearance.LeftArmDeco;
				result.kAppearance.nmRightArmDeco = PossibleAppearance.RightArmDeco;
				result.kAppearance.nmLeftForearm = PossibleAppearance.LeftForearm;
				result.kAppearance.nmRightForearm = PossibleAppearance.RightForearm;
				result.kAppearance.nmThighs = PossibleAppearance.Thighs;
				result.kAppearance.nmShins = PossibleAppearance.Shins;
				result.kAppearance.nmTorsoDeco = PossibleAppearance.TorsoDeco;

				if(PossibleAppearance.Voice != '')
				{
					result.kAppearance.nmVoice = PossibleAppearance.Voice;
				}
				if(PossibleAppearance.Flag != '')
				{
					result.nmCountry = PossibleAppearance.Flag;
					result.kAppearance.nmFlag = PossibleAppearance.Flag;
				}

				break;
			}

		}
	}


	//result.kAppearance.nmCountry ='';

	//// non-VIPs can have their appearance copied wholesale
	if(UseEntireAppearance && Unit != none && UsingCharPool)
	{
		result.kAppearance = Unit.kAppearance;
	}

	// fix XComGameState_Unit attributes (background, whatever else VIPs have) via UI listener
	// shouldn't be any major incompatibility with Configurable Birthdates

	return result;
}

function array<XComGameState_Unit> GetCharPoolCandidates(X2CharacterTemplate Template)
{
	local int i;
	local XComGameState_Unit Unit;
	local XComGameStateHistory History;
	local array<XComGameState_Unit> CharacterPool, Candidates;

	if(none == Template) return Candidates;

	History = `XCOMHISTORY;
	CharacterPool = `CHARACTERPOOLMGR.CharacterPool;

	for(i = 0; i < CharacterPool.length; ++i)
	{
		if(Filter(CharacterPool[i], Template))
		{
			Candidates.AddItem(CharacterPool[i]);
		}
	}

	// skip history check
	if(Candidates.length == 0) return Candidates;

	// remove characters who have already appeared this campaign
	foreach History.IterateByClassType(class'XComGameState_Unit', Unit)
	{
		if(class'UnitDarkXComUtils'.static.GetFullName(Unit) == "") 
			continue;

		//`log("Dark XCom: Unit being checked for cloning is " $ class'UnitDarkXComUtils'.static.GetFullName(Unit));

		for(i = 0; i < Candidates.length; ++i)
		{
			if(Candidates[i].GetName(eNameType_FullNick) == class'UnitDarkXComUtils'.static.GetFullName(Unit) &&  (Candidates[i].GetMyTemplateName() != 'DarkSoldier' )) //strategic dark soldiers are the exceptions to filtering for combat proxies: they should get the appearances of them
			{
				Candidates.Remove(i, 1);
				--i;
			}
		}
	}

	return Candidates;
}

function bool Filter(XComGameState_Unit Unit, X2CharacterTemplate CharacterTemplate)
{
	local int idx;
	// bugfix for CharacterPoolManager, allow human characters to be anything
	if(Unit.GetMyTemplateName() != 'Soldier' && Unit.GetMyTemplateName() != CharacterTemplate.DataName)
		return false;

	if (CharacterTemplate.bUsePoolSoldiers && Unit.bAllowedTypeSoldier && CharacterTemplate.bUsePoolDarkVIPs && Unit.bAllowedTypeDarkVIP)
		return true;

	if (CharacterTemplate.bUsePoolSoldiers && Unit.bAllowedTypeSoldier && SoldiersOnly)
		return true;

	if (CharacterTemplate.bUsePoolDarkVIPs && Unit.bAllowedTypeDarkVIP && DarkVIPsOnly)
		return true;

	return false;
}