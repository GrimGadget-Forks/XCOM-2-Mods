//---------------------------------------------------------------------------------------
//  FILE:    UIAlert_RMVeteranTrainingComplete.uc
//  AUTHOR:  RealityMachina (using Long War Studio's Officer Pack as a base)
//  PURPOSE: Customized UI Alert for Veteran training 
//           
//---------------------------------------------------------------------------------------
class UIAlert_RMVeteranTrainingComplete extends UIAlert;

//override for UIAlert child to trigger specific Alert built in this class
simulated function BuildAlert()
{
	BindLibraryItem();
	BuildVeteranTrainingCompleteAlert();
}

//New Alert building function
simulated function BuildVeteranTrainingCompleteAlert()
{

	local XComGameState_Unit UnitState;
	local string ClassIcon, ClassName, RankName;
	local X2SoldierClassTemplate ClassTemplate;
	local X2AbilityTemplate TrainedAbilityTemplate;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local string AbilityIcon, AbilityName, AbilityDescription;

	if( LibraryPanel == none )
	{
		`RedScreen("UI Problem with the alerts! Couldn't find LibraryPanel for current eAlertType: " $ eAlert);
		return;
	}

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitInfo.UnitRef.ObjectID));

	ClassTemplate = UnitState.GetSoldierClassTemplate();
	ClassName = Caps(ClassTemplate.DisplayName);
	ClassIcon = ClassTemplate.IconImage;
	RankName = Caps(class'X2ExperienceConfig'.static.GetRankName(1, ClassTemplate.DataName));
	
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	TrainedAbilityTemplate = AbilityTemplateManager.FindAbilityTemplate('MentorConfidence');

	// Ability Name
	AbilityName = TrainedAbilityTemplate.LocFriendlyName != "" ? TrainedAbilityTemplate.LocFriendlyName : ("Missing 'LocFriendlyName' for ability '" $ TrainedAbilityTemplate.DataName $ "'");

	// Ability Description
	AbilityDescription = TrainedAbilityTemplate.HasLongDescription() ? TrainedAbilityTemplate.GetMyLongDescription() : ("Missing 'LocLongDescription' for ability " $ TrainedAbilityTemplate.DataName $ "'");
	AbilityIcon = TrainedAbilityTemplate.IconImage;

	// Send over to flash
	LibraryPanel.MC.BeginFunctionOp("UpdateData");
	LibraryPanel.MC.QueueString(m_strTrainingCompleteLabel);
	LibraryPanel.MC.QueueString(GetOrStartWaitingForVeteranStaffImage()); 
	LibraryPanel.MC.QueueString(ClassIcon);
	LibraryPanel.MC.QueueString(RankName);
	LibraryPanel.MC.QueueString(UnitState.GetName(eNameType_FullNick));
	LibraryPanel.MC.QueueString(ClassName);
	LibraryPanel.MC.QueueString(AbilityIcon);
	LibraryPanel.MC.QueueString(m_strNewAbilityLabel);
	LibraryPanel.MC.QueueString(AbilityName);
	LibraryPanel.MC.QueueString(AbilityDescription);
	LibraryPanel.MC.QueueString(m_strViewSoldier);
	LibraryPanel.MC.QueueString(m_strCarryOn);
	LibraryPanel.MC.EndOp();

	// Hide "View Soldier" button if player is on top of avenger, prevents ui state stack issues
	if(Movie.Pres.ScreenStack.IsInStack(class'UIArmory_MainMenu'))
		Button1.Hide();
}

simulated function string GetOrStartWaitingForVeteranStaffImage()
{
	local XComPhotographer_Strategy Photo;
	local X2ImageCaptureManager CapMan;

	CapMan = X2ImageCaptureManager(`XENGINE.GetImageCaptureManager());
	Photo = `GAME.StrategyPhotographer;

	StaffPicture = CapMan.GetStoredImage(UnitInfo.UnitRef, name("UnitPicture"$UnitInfo.UnitRef.ObjectID));
	if (StaffPicture == none)
	{
		// if we have a photo queued then setup a callback so we can sqap in the image when it is taken
		if (!Photo.HasPendingHeadshot(UnitInfo.UnitRef, UpdateAlertImage))
		{
			Photo.AddHeadshotRequest(UnitInfo.UnitRef, 'UIPawnLocation_ArmoryPhoto', 'SoldierPicture_Head_Armory', 512, 512, UpdateAlertImage, class'X2StrategyElement_DefaultSoldierPersonalities'.static.Personality_ByTheBook());
		}

		return "";
	}

	return "img:///"$PathName(StaffPicture);
}