// This is an Unreal Script
class RM_HackRewards_AmmoDarkEvents extends X2HackReward config (DarkEvents);


var config int DRAGON_ROUNDS_APPLICATION_CHANCE;
var config int AP_ROUNDS_APPLICATION_CHANCE;
var config int TALON_ROUNDS_APPLICATION_CHANCE;
var config int TRACER_ROUNDS_APPLICATION_CHANCE;
var config int HOLO_ROUNDS_APPLICATION_CHANCE;
var config int HAZMAT_VEST_APPLICATION_CHANCE;
var config int MINDSHIELDING_APPLICATION_CHANCE;
var config int BLASTPADDING_APPLICATION_CHANCE;
var config int LIGHTNINGDRUGS_APPLICATION_CHANCE;
var config int SPECIALFORCES_APPLICATION_CHANCE;

//---------------------------------
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local X2HackRewardTemplate Template;
	local name TemplateName;
	
	foreach default.HackRewardNames(TemplateName)
	{
		`CREATE_X2TEMPLATE(class'X2HackRewardTemplate', Template, TemplateName);
		Templates.AddItem(Template);
	}

	// Dark Events
	Templates.AddItem(DragonRounds('DarkEvent_DragonRounds'));
	Templates.AddItem(APRounds('DarkEvent_APRounds'));
	Templates.AddItem(TalonRounds('DarkEvent_TalonRounds'));
	Templates.AddItem(TracerRounds('DarkEvent_TracerRounds'));
	Templates.AddItem(HazmatArmor('DarkEvent_HazmatArmor'));
	Templates.AddItem(Mindshielding('DarkEvent_Mindshielding'));
	Templates.AddItem(BlastPadding('DarkEvent_BlastPadding'));
	Templates.AddItem(LightningDrugs('DarkEvent_LightningDrugs'));
	Templates.AddItem(HoloRounds('DarkEvent_HoloRounds'));
	Templates.AddItem(SpecialForces('DarkEvent_SpecialForces'));

	return Templates;
}

//-------------------------------------------------------------


static function X2HackRewardTemplate DragonRounds(Name TemplateName)
{
	local X2HackRewardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2HackRewardTemplate', Template, TemplateName);

	Template.ApplyHackRewardFn = ApplyDragonRounds;

	return Template;
}

	function ApplyDragonRounds(XComGameState_Unit Hacker, XComGameState_BaseObject HackTarget, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_Item AmmoState, WeaponState;
	local X2ItemTemplate AmmoTemplate;

	History = `XCOMHISTORY;
	AmmoTemplate = class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate('IncendiaryRounds');

	// viper rounds only apply to advent officers
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if( UnitState.GetMyTemplate().bIsAdvent )
		{
			if( `SYNC_RAND(100) < DRAGON_ROUNDS_APPLICATION_CHANCE )
			{
				WeaponState = UnitState.GetPrimaryWeapon();
				if( WeaponState != None )
				{
					NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
					NewGameState.AddStateObject(NewUnitState);

					// create the ammo
					AmmoState = AmmoTemplate.CreateInstanceFromTemplate(NewGameState);
					NewGameState.AddStateObject(AmmoState);

					NewUnitState.AddItemToInventory(AmmoState, eInvSlot_AmmoPocket, NewGameState);

					// apply it to the unit's weapon
					WeaponState = XComGameState_Item(NewGameState.CreateStateObject(WeaponState.Class, WeaponState.ObjectID));
					NewGameState.AddStateObject(WeaponState);

					WeaponState.LoadedAmmo = AmmoState.GetReference();
				}
			}
		}
	}
}

//----------------------------------------------


static function X2HackRewardTemplate APRounds(Name TemplateName)
{
	local X2HackRewardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2HackRewardTemplate', Template, TemplateName);

	Template.ApplyHackRewardFn = ApplyAPRounds;

	return Template;
}


function ApplyAPRounds(XComGameState_Unit Hacker, XComGameState_BaseObject HackTarget, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_Item AmmoState, WeaponState;
	local X2ItemTemplate AmmoTemplate;

	History = `XCOMHISTORY;
	AmmoTemplate = class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate('APRounds');

	// viper rounds only apply to advent officers
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if( UnitState.GetMyTemplate().bIsAdvent )
		{
			if( `SYNC_RAND(100) < AP_ROUNDS_APPLICATION_CHANCE )
			{
				WeaponState = UnitState.GetPrimaryWeapon();
				if( WeaponState != None )
				{
					NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
					NewGameState.AddStateObject(NewUnitState);

					// create the ammo
					AmmoState = AmmoTemplate.CreateInstanceFromTemplate(NewGameState);
					NewGameState.AddStateObject(AmmoState);

					NewUnitState.AddItemToInventory(AmmoState, eInvSlot_AmmoPocket, NewGameState);

					// apply it to the unit's weapon
					WeaponState = XComGameState_Item(NewGameState.CreateStateObject(WeaponState.Class, WeaponState.ObjectID));
					NewGameState.AddStateObject(WeaponState);

					WeaponState.LoadedAmmo = AmmoState.GetReference();
				}
			}
		}
	}
}

static function X2HackRewardTemplate TalonRounds(Name TemplateName)
{
	local X2HackRewardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2HackRewardTemplate', Template, TemplateName);

	Template.ApplyHackRewardFn = ApplyTalonRounds;

	return Template;
}




function ApplyTalonRounds(XComGameState_Unit Hacker, XComGameState_BaseObject HackTarget, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_Item AmmoState, WeaponState;
	local X2ItemTemplate AmmoTemplate;

	History = `XCOMHISTORY;
	AmmoTemplate = class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate('TalonRounds');

	// viper rounds only apply to advent officers
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if( UnitState.GetMyTemplate().bIsAdvent )
		{
			if( `SYNC_RAND(100) < TALON_ROUNDS_APPLICATION_CHANCE )
			{
				WeaponState = UnitState.GetPrimaryWeapon();
				if( WeaponState != None )
				{
					NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
					NewGameState.AddStateObject(NewUnitState);

					// create the ammo
					AmmoState = AmmoTemplate.CreateInstanceFromTemplate(NewGameState);
					NewGameState.AddStateObject(AmmoState);

					NewUnitState.AddItemToInventory(AmmoState, eInvSlot_AmmoPocket, NewGameState);

					// apply it to the unit's weapon
					WeaponState = XComGameState_Item(NewGameState.CreateStateObject(WeaponState.Class, WeaponState.ObjectID));
					NewGameState.AddStateObject(WeaponState);

					WeaponState.LoadedAmmo = AmmoState.GetReference();
				}
			}
		}
	}
}

static function X2HackRewardTemplate TracerRounds(Name TemplateName)
{
	local X2HackRewardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2HackRewardTemplate', Template, TemplateName);

	Template.ApplyHackRewardFn = ApplyTracerRounds;

	return Template;
}



function ApplyTracerRounds(XComGameState_Unit Hacker, XComGameState_BaseObject HackTarget, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_Item AmmoState, WeaponState;
	local X2ItemTemplate AmmoTemplate;

	History = `XCOMHISTORY;
	AmmoTemplate = class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate('TracerRounds');

	// viper rounds only apply to advent officers
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if( UnitState.GetMyTemplate().bIsAdvent )
		{
			if( `SYNC_RAND(100) < TRACER_ROUNDS_APPLICATION_CHANCE )
			{
				WeaponState = UnitState.GetPrimaryWeapon();
				if( WeaponState != None )
				{
					NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
					NewGameState.AddStateObject(NewUnitState);

					// create the ammo
					AmmoState = AmmoTemplate.CreateInstanceFromTemplate(NewGameState);
					NewGameState.AddStateObject(AmmoState);

					NewUnitState.AddItemToInventory(AmmoState, eInvSlot_AmmoPocket, NewGameState);

					// apply it to the unit's weapon
					WeaponState = XComGameState_Item(NewGameState.CreateStateObject(WeaponState.Class, WeaponState.ObjectID));
					NewGameState.AddStateObject(WeaponState);

					WeaponState.LoadedAmmo = AmmoState.GetReference();
				}
			}
		}
	}
}

//----------------------------------------------


static function X2HackRewardTemplate HazmatArmor(Name TemplateName)
{
	local X2HackRewardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2HackRewardTemplate', Template, TemplateName);

	Template.ApplyHackRewardFn = ApplyHazmatArmor;

	return Template;
}


function ApplyHazmatArmor(XComGameState_Unit Hacker, XComGameState_BaseObject HackTarget, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_Item ArmorState; 
	local XComGameState_Ability AbilityState;
	local X2AbilityTemplate AbilityTemplate;
	local X2ItemTemplate UtilityTemplate;

	History = `XCOMHISTORY;
	UtilityTemplate = class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate('HazmatVest');
	AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('HazmatVestBonus');

	// viper rounds only apply to advent officers
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if( UnitState.GetMyTemplate().bIsAdvent )
		{
			if( `SYNC_RAND(100) < HAZMAT_VEST_APPLICATION_CHANCE  )
			{
					NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
					NewGameState.AddStateObject(NewUnitState);

			

					// create the item and give it to the unit
					ArmorState = UtilityTemplate.CreateInstanceFromTemplate(NewGameState);
					NewGameState.AddStateObject(ArmorState);

					NewUnitState.AddItemToInventory(ArmorState, eInvSlot_Utility, NewGameState);

					// apply it to the unit

					AbilityState = AbilityTemplate.CreateInstanceFromTemplate(NewGameState);
					AbilityState.InitAbilityForUnit(NewUnitState, NewGameState);
					NewGameState.AddStateObject(AbilityState);
					NewUnitState.Abilities.AddItem(AbilityState.GetReference());
					NewGameState.AddStateObject(NewUnitState);

			
			}
		}
	}
}


//----------------------------------------------


static function X2HackRewardTemplate Mindshielding(Name TemplateName)
{	local X2HackRewardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2HackRewardTemplate', Template, TemplateName);

	Template.ApplyHackRewardFn = ApplyMindshielding;

	return Template;
}


function ApplyMindshielding(XComGameState_Unit Hacker, XComGameState_BaseObject HackTarget, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_Item ArmorState; 
	local XComGameState_Ability AbilityState;
	local X2AbilityTemplate AbilityTemplate;
	local X2ItemTemplate UtilityTemplate;

	History = `XCOMHISTORY;
	UtilityTemplate = class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate('MindShield');
	AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('MindShield');

	// viper rounds only apply to advent officers
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if( UnitState.GetMyTemplate().bIsAdvent || UnitState.GetMyTemplate().bIsAlien )
		{
			if( `SYNC_RAND(150) < MINDSHIELDING_APPLICATION_CHANCE  )
			{
					NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
					NewGameState.AddStateObject(NewUnitState);

			

					// create the item and give it to the unit
					ArmorState = UtilityTemplate.CreateInstanceFromTemplate(NewGameState);
					NewGameState.AddStateObject(ArmorState);

					NewUnitState.AddItemToInventory(ArmorState, eInvSlot_Utility, NewGameState);

					// apply it to the unit

					AbilityState = AbilityTemplate.CreateInstanceFromTemplate(NewGameState);
					AbilityState.InitAbilityForUnit(NewUnitState, NewGameState);
					NewGameState.AddStateObject(AbilityState);
					NewUnitState.Abilities.AddItem(AbilityState.GetReference());
					NewGameState.AddStateObject(NewUnitState);

			}
		}
	}
}

//----------------------------------------------


static function X2HackRewardTemplate BlastPadding(Name TemplateName)
{	local X2HackRewardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2HackRewardTemplate', Template, TemplateName);

	Template.ApplyHackRewardFn = ApplyBlastPadding;

	return Template;
}


function ApplyBlastPadding(XComGameState_Unit Hacker, XComGameState_BaseObject HackTarget, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_Ability AbilityState;
	local X2AbilityTemplate AbilityTemplate;

	History = `XCOMHISTORY;
	AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('BlastPadding');

	// viper rounds only apply to advent officers
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if( UnitState.GetMyTemplate().bIsAdvent )
		{
			if( `SYNC_RAND(150) < BLASTPADDING_APPLICATION_CHANCE  )
			{
					NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
					NewGameState.AddStateObject(NewUnitState);

			

					// apply it to the unit

					AbilityState = AbilityTemplate.CreateInstanceFromTemplate(NewGameState);
					AbilityState.InitAbilityForUnit(NewUnitState, NewGameState);
					NewGameState.AddStateObject(AbilityState);
					NewUnitState.Abilities.AddItem(AbilityState.GetReference());
					NewGameState.AddStateObject(NewUnitState);

			}
		}
	}
}


//----------------------------------------------


static function X2HackRewardTemplate LightningDrugs(Name TemplateName)
{	local X2HackRewardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2HackRewardTemplate', Template, TemplateName);

	Template.ApplyHackRewardFn = ApplyLightningDrugs;

	return Template;
}


function ApplyLightningDrugs(XComGameState_Unit Hacker, XComGameState_BaseObject HackTarget, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_Ability AbilityState;
	local X2AbilityTemplate AbilityTemplate;

	History = `XCOMHISTORY;
	AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('LightningReflexes');

	// viper rounds only apply to advent officers
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if( UnitState.GetMyTemplate().bIsAdvent )
		{
			if( `SYNC_RAND(200) < LIGHTNINGDRUGS_APPLICATION_CHANCE  )
			{
					NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
					NewGameState.AddStateObject(NewUnitState);

		

					// apply it to the unit

					AbilityState = AbilityTemplate.CreateInstanceFromTemplate(NewGameState);
					AbilityState.InitAbilityForUnit(NewUnitState, NewGameState);
					NewGameState.AddStateObject(AbilityState);
					NewUnitState.Abilities.AddItem(AbilityState.GetReference());
					NewGameState.AddStateObject(NewUnitState);

			}
		}
	}
}


//----------------------------------------------


static function X2HackRewardTemplate HoloRounds(Name TemplateName)
{	local X2HackRewardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2HackRewardTemplate', Template, TemplateName);

	Template.ApplyHackRewardFn = ApplyHoloRounds;

	return Template;
}


function ApplyHoloRounds(XComGameState_Unit Hacker, XComGameState_BaseObject HackTarget, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_Ability AbilityState;
	local X2AbilityTemplate AbilityTemplate;

	History = `XCOMHISTORY;
	AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('HoloTargeting');

	// viper rounds only apply to advent officers
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if( UnitState.GetMyTemplate().bIsAdvent )
		{
			if( `SYNC_RAND(100) < HOLO_ROUNDS_APPLICATION_CHANCE  )
			{
					NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
					NewGameState.AddStateObject(NewUnitState);

					// apply it to the unit

					AbilityState = AbilityTemplate.CreateInstanceFromTemplate(NewGameState);
					AbilityState.InitAbilityForUnit(NewUnitState, NewGameState);
					NewGameState.AddStateObject(AbilityState);
					NewUnitState.Abilities.AddItem(AbilityState.GetReference());
					NewGameState.AddStateObject(NewUnitState);

			}
		}
	}
}


//----------------------------------------------


static function X2HackRewardTemplate SpecialForces(Name TemplateName)
{	local X2HackRewardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2HackRewardTemplate', Template, TemplateName);

	Template.ApplyHackRewardFn = ApplySpecialForces;

	return Template;
}


function ApplySpecialForces(XComGameState_Unit Hacker, XComGameState_BaseObject HackTarget, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState, NewUnitState;
	local XComGameState_Ability AbilityState1, AbilityState2, AbilityState3, AbilityState4, AbilityState5;
	local X2AbilityTemplate AbilityTemplate1, AbilityTemplate2, AbilityTemplate3, AbilityTemplate4, AbilityTemplate5;

	History = `XCOMHISTORY;
	AbilityTemplate1 = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('CoolUnderPressure');
	AbilityTemplate2 = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('HuntersInstinct');
	AbilityTemplate3 = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('Sentinel');
	AbilityTemplate4 = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('CoveringFire');
	AbilityTemplate5 = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('DeepCover');

	// viper rounds only apply to advent officers
	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if( UnitState.GetMyTemplate().bIsAdvent )
		{
			if( `SYNC_RAND(150) < SPECIALFORCES_APPLICATION_CHANCE  )
			{
					NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
					NewGameState.AddStateObject(NewUnitState);

					// apply it to the unit

					AbilityState1 = AbilityTemplate1.CreateInstanceFromTemplate(NewGameState);
					AbilityState1.InitAbilityForUnit(NewUnitState, NewGameState);
					NewGameState.AddStateObject(AbilityState1);
					NewUnitState.Abilities.AddItem(AbilityState1.GetReference());
					NewGameState.AddStateObject(NewUnitState);

					AbilityState2 = AbilityTemplate2.CreateInstanceFromTemplate(NewGameState);
					AbilityState2.InitAbilityForUnit(NewUnitState, NewGameState);
					NewGameState.AddStateObject(AbilityState2);
					NewUnitState.Abilities.AddItem(AbilityState2.GetReference());
					NewGameState.AddStateObject(NewUnitState);

					AbilityState3 = AbilityTemplate3.CreateInstanceFromTemplate(NewGameState);
					AbilityState3.InitAbilityForUnit(NewUnitState, NewGameState);
					NewGameState.AddStateObject(AbilityState3);
					NewUnitState.Abilities.AddItem(AbilityState3.GetReference());
					NewGameState.AddStateObject(NewUnitState);

					AbilityState4 = AbilityTemplate4.CreateInstanceFromTemplate(NewGameState);
					AbilityState4.InitAbilityForUnit(NewUnitState, NewGameState);
					NewGameState.AddStateObject(AbilityState4);
					NewUnitState.Abilities.AddItem(AbilityState4.GetReference());
					NewGameState.AddStateObject(NewUnitState);

					AbilityState5 = AbilityTemplate5.CreateInstanceFromTemplate(NewGameState);
					AbilityState5.InitAbilityForUnit(NewUnitState, NewGameState);
					NewGameState.AddStateObject(AbilityState5);
					NewUnitState.Abilities.AddItem(AbilityState5.GetReference());
					NewGameState.AddStateObject(NewUnitState);

			}
		}
	}
}
