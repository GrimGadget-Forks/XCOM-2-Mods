//---------------------------------------------------------------------------------------
//  FILE:    XComGameState_MissionSiteLostTowers.uc
//  AUTHOR:  Joe Weinhoffer
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class XComGameState_MissionSite_MOCX extends XComGameState_MissionSite;

//
//protected function bool DisplaySelectionPrompt()
//{
	//MissionSelected();
//
	//return true; //for now, mission selected shall remain unused since I can't figure out why it doesn't work as it does.
//}
//
function MissionSelected()
{
	local XComHQPresentationLayer Pres;
	local UIMission_MOCXPath kScreen;

	Pres = `HQPRES;

	// Show the lost towers mission
	if (!Pres.ScreenStack.GetCurrentScreen().IsA('UIMission_MOCXPath'))
	{
		kScreen = Pres.Spawn(class'UIMission_MOCXPath');
		kScreen.MissionRef = GetReference();
		Pres.ScreenStack.Push(kScreen);
	}

	if (`GAME.GetGeoscape().IsScanning())
	{
		Pres.StrategyMap2D.ToggleScan();
	}
}


function string GetUIButtonIcon()
{
	if(GetMissionSource().DataName == 'MissionSource_MOCXOffsite')
		return "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Blacksite";

	if(GetMissionSource().DataName == 'MissionSource_MOCXTraining')	
		return "img:///UILibrary_XPACK_Common.MissionIcon_ResOps";

	if(GetMissionSource().DataName == 'MissionSource_MOCXAssault')	
		return "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_FinalMission";
}