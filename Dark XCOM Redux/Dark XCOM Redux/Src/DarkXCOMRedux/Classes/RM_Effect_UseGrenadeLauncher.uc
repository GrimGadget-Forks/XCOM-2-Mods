//---------------------------------------------------------------------------------------
//  FILE:    X2Effect_AdventGrenadeLauncher
//  AUTHOR:  Amineri (Long War Studios)
//  PURPOSE: Links up any carried grenades with a grenade launcher
// Renamed by DerBK to avoid naming conflicts
// Renamed by Reality for the same thing
//--------------------------------------------------------------------------------------- 

class RM_Effect_UseGrenadeLauncher extends X2Effect;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit					UnitState; 
	local XComGameState_Item					InventoryItem;
	local array<XComGameState_Item> CurrentInventory;
	local X2AbilityTemplateManager				AbilityManager;
	local X2AbilityTemplate						AbilityTemplate;
	local XComGameState_Item					SecondaryWeapon;

	UnitState = XComGameState_Unit(kNewTargetState);
	if (UnitState == none)
		return;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	AbilityTemplate = AbilityManager.FindAbilityTemplate('LaunchGrenade');
	if(AbilityTemplate == none)
	{
		`REDSCREEN("ADVENT Grenade Launcher : No Launch Grenade ability template found");
		return;
	}
	SecondaryWeapon = UnitState.GetSecondaryWeapon();
	if(SecondaryWeapon == none)
	{
		`log("ADVENT Grenade Launcher : No item found in secondary slot", ,'DarkXCom');
		return;
	}

	CurrentInventory = UnitState.GetAllInventoryItems();
	//  populate a version of the ability for every grenade in the inventory
	foreach CurrentInventory(InventoryItem)
	{

		if (InventoryItem.bMergedOut) 
			continue;

		if (X2GrenadeTemplate(InventoryItem.GetMyTemplate()) != none)
		{
		//	`APDEBUG("ADVENT Grenade Launcher: Is Grenade. Adding Ability" @ AbilityTemplate.DataName @ "for weapon" @ SecondaryWeapon.GetMyTemplateName() @ "using ammo" @ InventoryItem.GetMyTemplateName());
			`TACTICALRULES.InitAbilityForUnit(AbilityTemplate, UnitState, NewGameState, SecondaryWeapon.GetReference(), InventoryItem.GetReference());
		}

	}

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}