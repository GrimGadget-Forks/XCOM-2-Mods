
class UIFacility_RM_PsiVeteranSlot extends UIFacility_StaffSlot dependson(UIPersonnel);

var localized string m_strTrainRMPsiVeteranDialogTitle;
var localized string m_strTrainRMPsiVeteranDialogText;
var localized string m_strStopTrainRMPsiVeteranDialogTitle;
var localized string m_strStopTrainRMPsiVeteranDialogText;


//-----------------------------------------------------------------------------
simulated function OnClickStaffSlot(UIPanel kControl, int cmd)
{
	local XComGameState_StaffSlot StaffSlot;
	local XComGameState_Unit UnitState;
	//local XComGameState_HeadquartersXCom XComHQ;
	local string StopTrainingText;

	StaffSlot = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(StaffSlotRef.ObjectID));

	switch (cmd)
	{
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_DOUBLE_UP:
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_UP_DELAYED:

		if (StaffSlot.IsSlotEmpty())
		{
			//StaffContainer.ShowDropDown(self);
			OnVeteranTrainSelected();
		}
		else // Ask the user to confirm that they want to empty the slot and stop training
		{
			//XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
			UnitState = StaffSlot.GetAssignedStaff();

			StopTrainingText = m_strStopTrainRMPsiVeteranDialogText;
			StopTrainingText = Repl(StopTrainingText, "%UNITNAME", UnitState.GetName(eNameType_RankFull));

			ConfirmEmptyProjectSlotPopup(m_strStopTrainRMPsiVeteranDialogTitle, StopTrainingText);
		}
		break;
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT:
	case class'UIUtilities_Input'.const.FXS_L_MOUSE_RELEASE_OUTSIDE:
		if(!StaffSlot.IsLocked())
		{
			StaffContainer.HideDropDown(self);
		}
		break;
	}
}

simulated function QueueDropDownDisplay()
{
	OnClickStaffSlot(none, class'UIUtilities_Input'.const.FXS_L_MOUSE_DOUBLE_UP);
	//m_QueuedDropDown = true;
}

simulated function OnVeteranTrainSelected()
{
	//local XGParamTag LocTag;
	local TDialogueBoxData DialogData;
	//local XComGameState_Unit Unit;
	//local UICallbackData_StateObjectReference CallbackData;

	//Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitInfo.UnitRef.ObjectID));
	//LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	//LocTag.StrValue0 = Unit.GetName(eNameType_RankFull);

	//CallbackData = new class'UICallbackData_StateObjectReference';
	//CallbackData.ObjectRef = Unit.GetReference();
	//DialogData.xUserData = CallbackData;
	DialogData.fnCallbackEx = TrainRMVeteranDialogCallback;

	DialogData.eType = eDialog_Alert;
	DialogData.strTitle = m_strTrainRMPsiVeteranDialogTitle;
	DialogData.strText = m_strTrainRMPsiVeteranDialogText;
	DialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericYes;
	DialogData.strCancel = class'UIUtilities_Text'.default.m_strGenericNo;

	Movie.Pres.UIRaiseDialog(DialogData);
}

simulated function OnPersonnelSelected(StaffUnitInfo UnitInfo)
{
	local XGParamTag LocTag;
	local TDialogueBoxData DialogData;
	local XComGameState_Unit Unit;
	local UICallbackData_StateObjectReference CallbackData;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitInfo.UnitRef.ObjectID));

	LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	LocTag.StrValue0 = Unit.GetName(eNameType_RankFull);

	CallbackData = new class'UICallbackData_StateObjectReference';
	CallbackData.ObjectRef = Unit.GetReference();
	DialogData.xUserData = CallbackData;
	DialogData.fnCallbackEx = TrainRMVeteranDialogCallback;

	DialogData.eType = eDialog_Alert;
	DialogData.strTitle = m_strTrainRMPsiVeteranDialogTitle;
	DialogData.strText = `XEXPAND.ExpandString(m_strTrainRMPsiVeteranDialogText);
	DialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericYes;
	DialogData.strCancel = class'UIUtilities_Text'.default.m_strGenericNo;

	Movie.Pres.UIRaiseDialog(DialogData);
}

simulated function TrainRMVeteranDialogCallback(eUIAction eAction, UICallbackData xUserData)
{
	local UIPersonnel_RMPsiVeteran kPersonnelList;
	local XComHQPresentationLayer HQPres;
	//local UICallbackData_StateObjectReference CallbackData;
	local XComGameState_StaffSlot StaffSlotState;
	
	//CallbackData = UICallbackData_StateObjectReference(xUserData);
	
	if (eAction == eUIAction_Accept)
	{
		HQPres = `HQPRES;
		StaffSlotState = XComGameState_StaffSlot(`XCOMHISTORY.GetGameStateForObjectID(StaffSlotRef.ObjectID));

		//Don't allow clicking of Personnel List is active or if staffslot is filled
		if(HQPres.ScreenStack.IsNotInStack(class'UIPersonnel') && !StaffSlotState.IsSlotFilled())
		{
			kPersonnelList = Spawn( class'UIPersonnel_RMPsiVeteran', HQPres);
			kPersonnelList.m_eListType = eUIPersonnel_Soldiers;
			kPersonnelList.onSelectedDelegate = OnSoldierSelected;
			kPersonnelList.m_bRemoveWhenUnitSelected = true;
			kPersonnelList.SlotRef = StaffSlotRef;
			HQPres.ScreenStack.Push( kPersonnelList );
		}
	}
}

simulated function OnSoldierSelected(StateObjectReference Unit)
{
	local XComGameStateHistory History;
	local XComGameState UpdateState;
	local XComGameState_Unit UpdatedUnit;
	local XComGameState NewGameState;
	//local XComGameState_FacilityXCom FacilityState;
	local XComGameState_StaffSlot StaffSlotState;
	//local XComGameState_HeadquartersProjectTrainRMVeteran TrainVeteranProject;
	local StaffUnitInfo UnitInfo;
	local XComGameStateContext_ChangeContainer ChangeContainer;
	//local XComGameState_Unit Unit;
	
	History = `XCOMHISTORY;
	ChangeContainer = class'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("Staffing Veteran Slot");
	UpdateState = History.CreateNewGameState(true, ChangeContainer);
	UpdatedUnit = XComGameState_Unit(UpdateState.CreateStateObject(class'XComGameState_Unit', Unit.ObjectID));
	StaffSlotState = `XCOMHQ.GetFacilityByName('PsiChamber').GetStaffSlot(3);

	if (StaffSlotState != none)
	{

		//Unit = GetUnit();
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Staffing Veteran Slot");


		UnitInfo.UnitRef = UpdatedUnit.GetReference();

		StaffSlotState.FillSlot(NewGameState, UnitInfo); // The Training project is started when the staff slot is filled
		
		
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

		`XSTRATEGYSOUNDMGR.PlaySoundEvent("StrategyUI_Staff_Assign");
		
	}


}


//==============================================================================



//==============================================================================

defaultproperties
{
	width = 370;
	height = 65;
}
