//----------------------------------------------------------------------------
//  *********   FIRAXIS SOURCE CODE   ******************
//  FILE:    UIFacilityStaffContainer_RM_OTS.uc
//  AUTHOR:  RealityMachina (using Long War Studio's Officer Pack as a base
//  PURPOSE: Staff container override for Veteran Staff Slot. 
//----------------------------------------------------------------------------

class UIFacilityStaffContainer_RM_OTS extends UIFacilityStaffContainer;

simulated function UIStaffContainer InitStaffContainer(optional name InitName, optional string NewTitle = DefaultStaffTitle)
{
	return super.InitStaffContainer(InitName, NewTitle);
}

simulated function Refresh(StateObjectReference LocationRef, delegate<UIStaffSlot.OnStaffUpdated> onStaffUpdatedDelegate)
{
	local int i;
	local XComGameState_FacilityXCom Facility;

	Facility = XComGameState_FacilityXCom(`XCOMHISTORY.GetGameStateForObjectID(LocationRef.ObjectID));

	// Show or create slots for the currently requested facility
	for (i = 0; i < Facility.StaffSlots.Length; i++)
	{
		// If the staff slot is locked and no upgrades are available, do not initialize or show the staff slot
		//if (Facility.GetStaffSlot(i).IsLocked() && !Facility.CanUpgrade())
			//continue;

		if (i < StaffSlots.Length)
			StaffSlots[i].UpdateData();
		else
		{
			switch (Movie.Stack.GetCurrentClass())
			{
			case class'UIFacility_UFODefense':
				if (i == 0)
				{
					StaffSlots.AddItem(Spawn(class'UIFacility_StaffSlot', self).InitStaffSlot(self, LocationRef, i, onStaffUpdatedDelegate));
				} 
				else 
				{
					if (i == 1)
					{
						StaffSlots.AddItem(Spawn(class'UIFacility_RM_VeteranSlot', self).InitStaffSlot(self, LocationRef, i, onStaffUpdatedDelegate));
					}
				}
				break;
			default:
				StaffSlots.AddItem(Spawn(class'UIFacility_StaffSlot', self).InitStaffSlot(self, LocationRef, i, onStaffUpdatedDelegate));
				break;
			}
		}
	}

	//Hide the box for facilities without any staffers, like the Armory, or for any facilities which have them permanently hidden. 
	if (Facility.StaffSlots.Length > 0 && !Facility.GetMyTemplate().bHideStaffSlots)
		Show();
	else
		Hide();
}

defaultproperties
{
}