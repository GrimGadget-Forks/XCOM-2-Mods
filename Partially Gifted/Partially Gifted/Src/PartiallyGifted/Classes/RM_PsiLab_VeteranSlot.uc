//---------------------------------------------------------------------------------------
//  FILE:    RM_OTS_Veteran_StaffSlot.uc
//  AUTHOR:  RealityMachina (using Long War Studio's Officer Pack as a base)
//  PURPOSE: This adds templates and updates OTS Facility Template 
//				Adds veteran staffslot to GTS to allow training of soldiers past rookie stage
//---------------------------------------------------------------------------------------

class RM_PsiLab_VeteranSlot extends X2StrategyElement;
//---------------------------------------------------------------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreatePsiVeteranSlotTemplate());  // add StaffSlot
	//Templates.AddItem(CreatePsiVeteranUpgradeTemplate());	//add facility upgrade to unlock slot

	UpdateRMOTSTemplate('PsiChamber');  

	return Templates;
}

static function UpdateRMOTSTemplate(name TemplateName)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2FacilityTemplate Template;
	//local int DifficultyIndex;
	//local string NewTemplateName;

	//get access to strategy element template manager
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	Template = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate(TemplateName));
	if(Template == none) 
	{
		`Redscreen("RM PsiVeteranSlot: Failed to find facility template Psionic Labs");
		return;
	}

	Template.StaffSlots.AddItem('PsiVeteranSlot');
	Template.StaffSlotsLocked = 1;
	//`log("RM Veteran Slot: Added OTS Veteran Slot to facility template OfficerTrainingSchool");

	//for testing purposes of difficulty-variant defect 
	//Template.PointsToComplete = class'X2StrategyElement_DefaultFacilities'.static.GetFacilityBuildDays(1);

	//Template.Upgrades.AddItem('PsiVeteranUpgrade');
	//`log("LW OfficerPack: Added OTS Facility upgrade to facility template OfficerTrainingSchool");

	// need to do this to update any native data caches ?
	TemplateManager.AddStrategyElementTemplate(Template, true);

	//for( DifficultyIndex = `MIN_DIFFICULTY_INDEX; DifficultyIndex <= `MAX_DIFFICULTY_INDEX; ++DifficultyIndex )
	//{
		//NewTemplateName = Template.DataName $ "_Diff_" $ DifficultyIndex;
		//NewTemplate = new(None, NewTemplateName) Template.Class (Template);
		//NewTemplate.SetDifficulty(DifficultyIndex);
		////NewTemplates.AddItem(NewTemplate);
		//TemplateManager.AddStrategyElementTemplate(NewTemplate, true);
	//}

}

/// <summary>
/// Helper function to construct Difficulty variants for each difficulty.
/// </summary>


// -------- Attempted workaround for Difficulty-variant templates not being based on updated template ----- DOES NOT WORK
//static function CreateDifficultyVariantsForTemplate(X2DataTemplate BaseTemplate, out array<X2DataTemplate> NewTemplates)
//{
	//local X2StrategyElementTemplateManager TemplateManager;
	//local X2FacilityTemplate Template;
//
	//if (BaseTemplate.DataName == 'OfficerTrainingSchool') 
	//{
		//TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
		//Template = X2FacilityTemplate(TemplateManager.FindStrategyElementTemplate('OfficerTrainingSchool'));
		//super.CreateDifficultyVariantsForTemplate(Template, NewTemplates);
	//} else {
		//super.CreateDifficultyVariantsForTemplate(BaseTemplate, NewTemplates);
	//}
//}

static function X2DataTemplate CreatePsiVeteranSlotTemplate()
{
	local X2StaffSlotTemplate Template;

	`CREATE_X2TEMPLATE(class'X2StaffSlotTemplate', Template, 'PsiVeteranSlot');
	Template.bSoldierSlot = true;
	Template.bRequireConfirmToEmpty = true;
	Template.FillFn = FillOTSVeteranSlot;
	Template.EmptyFn = class'X2StrategyElement_DefaultStaffSlots'.static.EmptySlotDefault;
	Template.EmptyStopProjectFn = EmptyStopProjectOTSSoldierSlot;
	Template.ShouldDisplayToDoWarningFn = ShouldDisplayOTSVeteranToDoWarning;
	Template.GetContributionFromSkillFn = class'X2StrategyElement_DefaultStaffSlots'.static.GetContributionDefault;
	Template.GetAvengerBonusAmountFn = class'X2StrategyElement_DefaultStaffSlots'.static.GetAvengerBonusDefault;
	Template.GetNameDisplayStringFn = class'X2StrategyElement_DefaultStaffSlots'.static.GetNameDisplayStringDefault;
	Template.GetSkillDisplayStringFn = GetOTSSkillDisplayString;
	Template.GetBonusDisplayStringFn = GetOTSBonusDisplayString;
	//Template.GetLocationDisplayStringFn = GetOTSLocationDisplayString;
	Template.GetLocationDisplayStringFn = class'X2StrategyElement_DefaultStaffSlots'.static.GetLocationDisplayStringDefault;
	Template.IsUnitValidForSlotFn = IsUnitValidForOTSVeteranSlot;
	Template.IsStaffSlotBusyFn = class'X2StrategyElement_DefaultStaffSlots'.static.IsStaffSlotBusyDefault;
	Template.MatineeSlotName = "Soldier";

	return Template;
}


static function bool IsGTSProjectActive(StateObjectReference FacilityRef)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_FacilityXCom FacilityState;
	local XComGameState_StaffSlot StaffSlot;
	local XComGameState_HeadquartersProjectPsiTraining PsiProject;
	local int i;

	History = `XCOMHISTORY;
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	FacilityState = XComGameState_FacilityXCom(History.GetGameStateForObjectID(FacilityRef.ObjectID));

	for (i = 0; i < FacilityState.StaffSlots.Length; i++)
	{
		StaffSlot = FacilityState.GetStaffSlot(i);
		if (StaffSlot.IsSlotFilled())
		{
			PsiProject = XComHQ.GetPsiTrainingProject(StaffSlot.GetAssignedStaffRef());
			if (PsiProject != none)
			{
				return true;
			}
		}
	}
	return false;
}


//---------------------------------------------------------------------------------------
// Second slot helper functions

static function FillOTSVeteranSlot(XComGameState NewGameState, StateObjectReference SlotRef, StaffUnitInfo UnitInfo)
{
	local XComGameState_Unit NewUnitState;
	local XComGameState_StaffSlot NewSlotState;
	local XComGameState_HeadquartersXCom NewXComHQ;
	local XComGameState_HeadquartersProjectPsiTrainRMVeteran ProjectState;
	local StateObjectReference EmptyRef;
	local int SquadIndex;

	class'X2StrategyElement_DefaultStaffSlots'.static.FillSlot(NewGameState, SlotRef, UnitInfo, NewSlotState, NewUnitState);
	NewXComHQ = class'X2StrategyElement_DefaultStaffSlots'.static.GetNewXComHQState(NewGameState);
	//OfficerState = class'LWOfficerUtilities'.static.GetOfficerComponent(NewUnitState);

	ProjectState = XComGameState_HeadquartersProjectPsiTrainRMVeteran(NewGameState.CreateStateObject(class'XComGameState_HeadquartersProjectPsiTrainRMVeteran'));
	NewGameState.AddStateObject(ProjectState);
	ProjectState.SetProjectFocus(UnitInfo.UnitRef, NewGameState, NewSlotState.Facility);

	NewUnitState.SetStatus(eStatus_Training);
	NewXComHQ.Projects.AddItem(ProjectState.GetReference());
	
	// If the unit undergoing training is in the squad, remove them
	SquadIndex = NewXComHQ.Squad.Find('ObjectID', UnitInfo.UnitRef.ObjectID);
	if (SquadIndex != INDEX_NONE)
	{
		// Remove their gear, excepting super soldiers
		if(!NewUnitState.bIsSuperSoldier)
		{
			NewUnitState.MakeItemsAvailable(NewGameState, false);
		}

		// Remove them from the squad
		NewXComHQ.Squad[SquadIndex] = EmptyRef;
	}
}

static function EmptyStopProjectOTSSoldierSlot(StateObjectReference SlotRef)
{
	//local XComGameState_Unit Unit;
	//local XComGameState_Unit_LWOfficer OfficerState;
	local HeadquartersOrderInputContext OrderInput;
	local XComGameState_StaffSlot SlotState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersProjectPsiTrainRMVeteran TrainVeteranProject;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	SlotState = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(SlotRef.ObjectID));

	TrainVeteranProject = XComGameState_HeadquartersProjectPsiTrainRMVeteran(XComHQ.GetPsiTrainingProject(SlotState.GetAssignedStaffRef()));
	if (TrainVeteranProject != none)
	{		
		//TODO add changestate to clear officer data
		OrderInput.OrderType = eHeadquartersOrderType_CancelPsiTraining;
		OrderInput.AcquireObjectReference = TrainVeteranProject.GetReference();

		class'XComGameStateContext_HeadquartersOrder'.static.IssueHeadquartersOrder(OrderInput);
	}
}

static function bool ShouldDisplayOTSVeteranToDoWarning(StateObjectReference SlotRef)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_StaffSlot SlotState;
	local StaffUnitInfo UnitInfo;
	local int i;

	History = `XCOMHISTORY;
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	SlotState = XComGameState_StaffSlot(History.GetGameStateForObjectID(SlotRef.ObjectID));

	for (i = 0; i < XComHQ.Crew.Length; i++)
	{
		UnitInfo.UnitRef = XComHQ.Crew[i];

		if (IsUnitValidForOTSVeteranSlot(SlotState, UnitInfo))
		{
			return true;
		}
	}

	return false;
}

static function bool IsUnitValidForOTSVeteranSlot(XComGameState_StaffSlot SlotState, StaffUnitInfo UnitInfo)

{
	local XComGameState_Unit Unit;
	local XComGameState_Unit_Psi PsiComponent;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitInfo.UnitRef.ObjectID));
	PsiComponent = class'UnitPsiUtilties'.static.GetPsiComponent(Unit);

	if 
		(Unit.IsASoldier() && !Unit.IsInjured() && !Unit.IsTraining() && !Unit.IsPsiTraining() && !Unit.CanRankUpSoldier())
	{
		if (Unit.GetSoldierClassTemplateName() == 'PsiOperative' )
		{
		return false;
		}

		else if (Unit.GetSoldierClassTemplateName() == 'Rookie' )
		{
		return false;
		}
		else if (PsiComponent != none )
		{
					if(PsiComponent.GetFullyPsiTrainedStatus())
					{
					return false;
					}
					else
					{
					return true;
					}
		}
		else if (PsiComponent == none)
		{
		return true;
		}
		return false;
	}

	return false;
}


static function string GetOTSSkillDisplayString(XComGameState_StaffSlot SlotState)
{
	return "";
}

static function string GetOTSBonusDisplayString(XComGameState_StaffSlot SlotState, optional bool bPreview)
{
	local string Contribution;

	if (SlotState.IsSlotFilled())
	{
		Contribution = Caps("TEACHING");
	}

	return class'X2StrategyElement_DefaultStaffSlots'.static.GetBonusDisplayString(SlotState, "%SKILL", Contribution);
}

//static function string GetOTSLocationDisplayString(XComGameState_StaffSlot SlotState)
//{
	////local XComGameState_HeadquartersXCom XComHQ;
	//local XComGameState_Unit UnitState;
	//local XComGameState_HeadquartersProjectTrainLWOfficer TrainProject;
	//local string LocationStr;
	//local XGParamTag LocTag;
//
	//UnitState = SlotState.GetAssignedStaff();
	//TrainProject = GetLWOfficerTrainProject(UnitState.GetReference(), SlotState);
//
	//LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	//LocTag.StrValue0 = TrainProject.GetTrainingAbilityFriendlyName();
	//LocationStr = `XEXPAND.ExpandString(default.strOTSLocationDisplayString);
	//
	//return LocationStr;
//}

static function XComGameState_HeadquartersProjectPsiTrainRMVeteran GetPsiRMVeteranTrainProject(StateObjectReference UnitRef, XComGameState_StaffSlot SlotState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersProjectPsiTrainRMVeteran TrainProject;
	local int idx;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	for (idx = 0; idx < XComHQ.Projects.Length; idx++)
	{
		TrainProject = XComGameState_HeadquartersProjectPsiTrainRMVeteran(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.Projects[idx].ObjectID));

		if (TrainProject != none)
		{
			if (SlotState.GetAssignedStaffRef() == TrainProject.ProjectFocus)
			{
				return TrainProject;
			}
		}
	}
}
