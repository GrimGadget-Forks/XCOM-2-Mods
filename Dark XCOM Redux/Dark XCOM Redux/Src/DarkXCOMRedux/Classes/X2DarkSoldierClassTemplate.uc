//---------------------------------------------------------------------------------------
//  *********   FIRAXIS SOURCE CODE   ******************
//  FILE:    X2SoldierClassTemplate.uc
//  AUTHOR:  Timothy Talley  --  01/18/2014
//---------------------------------------------------------------------------------------
//  Copyright (c) 2014 Firaxis Games Inc. All rights reserved.
//--------------------------------------------------------------------------------------- 

class X2DarkSoldierClassTemplate extends  X2StrategyElementTemplate 
	dependson(X2TacticalGameRulesetDataStructures)
	config(DarkClassData);

//struct DarkSoldierClassRank
//{
	//var array<SoldierClassAbilitySlot>      aAbilityTree;
	//var array<SoldierClassStatType>         aStatProgression;
//};
var config array<SoldierClassRank> SoldierRanks;
var config name    PrimaryWeapon;
var config name		SecondaryWeapon;
var config array<name>                      ExcludedAbilities;  // AWC abilities this class cannot get
var config name					WeaponLoadout; //armor is handled in the base character template and at mission start
var config string				IconImage;
var config int                 NumInDeck; //how many entries this class should have in the class decks

var localized string			DisplayName;
var localized string			ClassSummary;
var localized array<string>		RankNames;				//  there should be one name for each rank; e.g. Rookie, Squaddie, etc.
var localized array<string>		ShortNames;				//  the abbreviated rank name; e.g. Rk., Sq., etc.
var localized array<string>		RankIcons;				//  strings of image names for specialized rank icons
var localized array<String>     RandomNickNames;        //  Selected randomly when the soldier hits a certain rank, if the player has not set one already.

function name GetAbilityName(int iRank, int iBranch)
{
	if (iRank < 0 && iRank >= SoldierRanks.Length)
		return '';

	if (iBranch < 0 && iBranch >= SoldierRanks[iRank].AbilitySlots.Length)
		return '';

	return SoldierRanks[iRank].AbilitySlots[iBranch].AbilityType.AbilityName;
}

function int GetMaxConfiguredRank()
{
	return SoldierRanks.Length;
}

function array<SoldierClassAbilitySlot> GetAbilitySlots(int Rank)
{
	if(Rank < 0 || Rank >= SoldierRanks.Length)
	{
		`RedScreen(string(GetFuncName()) @ "called with invalid Rank" @ Rank @ "for template" @ DataName @ DisplayName);
		return SoldierRanks[0].AbilitySlots;
	}

	return SoldierRanks[Rank].AbilitySlots;
}


function array<SoldierClassStatType> GetStatProgression(int Rank)
{
	if (Rank < 0 || Rank > SoldierRanks.Length)
	{
		`RedScreen(string(GetFuncName()) @ "called with invalid Rank" @ Rank @ "for template" @ DataName @ DisplayName);
		return SoldierRanks[0].aStatProgression;
	}
	return SoldierRanks[Rank].aStatProgression;
}
//
//function SCATProgression GetSCATProgressionForAbility(name AbilityName)
//{
	//local SCATProgression Progression;
	//local int rankIdx, branchIdx;
//
	//Progression.iBranch = INDEX_NONE;
	//Progression.iRank = INDEX_NONE;
//
	//for (rankIdx = 0; rankIdx < SoldierRanks.Length; ++rankIdx)
	//{
		//for (branchIdx = 0; branchIdx < SoldierRanks[rankIdx].aAbilityTree.Length; ++branchIdx)
		//{
			//if (SoldierRanks[rankIdx].aAbilityTree[branchIdx].AbilityName == AbilityName)
			//{
				//Progression.iRank = rankIdx;
				//Progression.iBranch = branchIdx;
				//return Progression;
			//}
		//}
	//}
//
	//return Progression;
//}

//
//function int GetPointValue()
//{
	//return ClassPoints;
//}
//
//defaultproperties
//{
	//bShouldCreateDifficultyVariants = true
//}