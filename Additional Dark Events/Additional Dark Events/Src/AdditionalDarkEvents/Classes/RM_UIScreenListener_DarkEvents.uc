// This is an Unreal Script
class RM_UIScreenListener_DarkEvents extends UIScreenListener config (DarkEvents);

var config int AlienWormDivider;

var bool IsAlienWormActive;

// This event is triggered after a screen is initialized
event OnReceiveFocus(UIScreen Screen)
{
		local XComGameState_HeadquartersXcom XComHQ;
		local XComGameState NewGameState;
		local XComGameState_Item ItemState;
		local int idx;

		XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		
		if(XComHQ.TacticalGameplayTags.Find('DarkEvent_AlienWorm') != INDEX_NONE && !IsAlienWormActive)
		{
		IsAlienWormActive = true;
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("MOD: Activate Dark Event Effects");
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		NewGameState.AddStateObject(XComHQ);
		XComHQ.HealingRate = (XComHQ.XComHeadquarters_BaseHealRate / AlienWormDivider);
		XComHQ.ProvingGroundRate = (XComHQ.XComHeadquarters_DefaultProvingGroundWorkPerHour / AlienWormDivider);
		XComHQ.PsiTrainingRate = (XComHQ.XComHeadquarters_DefaultPsiTrainingWorkPerHour / AlienWormDivider);


			for(idx = 0; idx < XComHQ.Inventory.Length; idx++)
			{
			ItemState = XComGameState_Item(`XCOMHistory.GetGameStateForObjectID(XComHQ.Inventory[idx].ObjectID));

				if(ItemState != none && ItemState.GetMyTemplateName() == 'Intel')
				{
					ItemState.Quantity = (ItemState.Quantity / AlienWormDivider);
				}
			}

		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		}

		else if (XComHQ.TacticalGameplayTags.Find('DarkEvent_AlienWorm') == INDEX_NONE && IsAlienWormActive)
		{
		IsAlienWormActive = false;
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("MOD: Deactivate Dark Event Effects");
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		NewGameState.AddStateObject(XComHQ);
		XComHQ.HealingRate = XComHQ.XComHeadquarters_BaseHealRate;
		XComHQ.ProvingGroundRate = XComHQ.XComHeadquarters_DefaultProvingGroundWorkPerHour;
		XComHQ.PsiTrainingRate = XComHQ.XComHeadquarters_DefaultPsiTrainingWorkPerHour;

		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);


		}
}
 
defaultproperties
{
	// unfortuanely it seems like the dark event doesn't like working if I try making sure it doesn't check on every screen
	// hopefully it won't cause too much of a performance impact
	// ScreenClass = UIAvengerHUD;
}
