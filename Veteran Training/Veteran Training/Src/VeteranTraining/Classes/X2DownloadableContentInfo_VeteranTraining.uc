//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_VeteranTraining.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
// Author: RealityMachina (using Long War Studio's Officer Pack as a base)
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_VeteranTraining extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
	`Log("RM Veteran Training : Starting OnLoadedSavedGame");
	UpdateRMOTSTemplates(none);
	UpdateRMOTSFacility();
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}

// ******** HANDLE UPDATING FACILITY TEMPLATES ************* //
// This handles updating the OTS facility templates (for all difficulties), for the cases in which the OTS hasn't already been built
// DOES NOT WORK -- does not survive the save/load process, since this isn't invoked during load operations
static function UpdateRMOTSTemplates(XComGameState StartState)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate Template;
	local int DifficultyIndex, OriginalDifficulty, OriginalLowestDifficulty;
	local name TemplateName;
	local XComGameState_CampaignSettings Settings;
	local XComGameStateHistory History;

	`Log("RM Veteran Training : Updating OTS Templates");

	TemplateName = 'OfficerTrainingSchool';
	if (StartState == none)
	{
		History = `XCOMHISTORY;
		Settings = XComGameState_CampaignSettings(History.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings'));
	}
	else
	{
		History = `XCOMHISTORY;
		// The CampaignSettings are initialized in CreateStrategyGameStart, so we can pull it from the history here
		Settings = XComGameState_CampaignSettings(History.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings'));
	}

	OriginalDifficulty = Settings.DifficultySetting;
	OriginalLowestDifficulty = Settings.LowestDifficultySetting;

	//get access to strategy element template manager
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	for( DifficultyIndex = `MIN_DIFFICULTY_INDEX; DifficultyIndex <= `MAX_DIFFICULTY_INDEX; ++DifficultyIndex )
	{
		Settings.SetDifficulty(DifficultyIndex, true);

		Template = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate(TemplateName));
		if(Template == none) 
		{
			`Redscreen("RM Veteran Training: Failed to find facility template OfficerTrainingSchool, difficult=" $ DifficultyIndex);
			continue;
		}

		`log("RM Veteran Training: Number of Pre-existing StaffSlots=" $ Template.StaffSlots.Length);
		//check to see if extra slot is required
		if(Template.StaffSlots.Length == 1) 
		{
			Template.StaffSlots.AddItem('OTSVeteranSlot');
			`log("LW OfficerPack: Added OTSOfficerSlot to facility template OfficerTrainingSchool");

			//for testing purposes of difficulty-variant defect 
			//Template.PointsToComplete = class'X2StrategyElement_DefaultFacilities'.static.GetFacilityBuildDays(1);

			// need to do this to update any native data caches ?
			TemplateManager.AddStrategyElementTemplate(Template, true);
		}
	}

	//restore difficulty settings
	Settings.SetDifficulty(OriginalLowestDifficulty, true);
	Settings.SetDifficulty(OriginalDifficulty, false);
}

// ******** HANDLE UPDATING OTS FACILITY ************* //
// This handles updating the OTS facility, in case facility is already built or is being built
// Upgrades are dynamically pulled from templates even for already-completed facilities, so don't have to be updated
static function UpdateRMOTSFacility()
{
	//local XComGameState NewGameState;
	local XComGameStateHistory History;
	local name TemplateName;
	local XComGameState_FacilityXCom FacilityState, OTSState;

	`Log("RM Veteran Training : Searching for existing OTS Facility");
	TemplateName = 'OfficerTrainingSchool';
	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_FacilityXCom', FacilityState)
	{
		if( FacilityState.GetMyTemplateName() == TemplateName )
		{
			OTSState = FacilityState; 
			break;
		}
	}

	if(OTSState == none) 
	{
		`log("RM Veteran Training: No existing OTS facility, update aborted");
		return;
	}

//	`Log("RM Veteran Training: Found existing OTS, Attempting to update StaffSlots");
//	if(OTSState.StaffSlots.Length == 1)
	//{
	//	`log("Veteran Training: OTS had only single staff slot, attempting to update facility"); 
	//	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating OTS Facility for Veteran Training");
	//	CreateStaffSlots(OTSState, NewGameState);
		//OTSState.StaffSlots.AddItem('OTSVeteranSlot')
	//	NewGameState.AddStateObject(OTSState);
	//	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	//}
}


//---------------------------------------------------------------------------------------
static function CreateStaffSlots(XComGameState_FacilityXCom FacilityState, XComGameState NewGameState)
{
//	local X2FacilityTemplate FacilityTemplate;
	local X2StaffSlotTemplate StaffSlotTemplate1;//, StaffSlotTemplate1;
	local XComGameState_StaffSlot StaffSlotState;
//	local int i;
	
//	FacilityTemplate = FacilityState.GetMyTemplate();


	//for (i = FacilityState.StaffSlots.Length ; i < FacilityTemplate.StaffSlots.Length; i++)
	//{
		//StaffSlotTemplate = X2StaffSlotTemplate(class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate(FacilityTemplate.StaffSlots[i]));
		StaffSlotTemplate1 = X2StaffSlotTemplate(class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate('OTSVeteranSlot'));
		if (StaffSlotTemplate1 != none)
		{
			StaffSlotState = StaffSlotTemplate1.CreateInstanceFromTemplate(NewGameState);
			StaffSlotState.Facility = FacilityState.GetReference(); //make sure the staff slot knows what facility it is in
			
			NewGameState.AddStateObject(StaffSlotState);

			FacilityState.StaffSlots.AddItem(StaffSlotState.GetReference());

			NewGameState.AddStateObject(FacilityState);
		}
	//}
}
