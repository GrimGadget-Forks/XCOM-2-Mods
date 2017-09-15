// Additional Behavior Tree conditions for Dark XCOM
class X2AIBT_DarkXCOM_Conditions extends X2AIBTDefaultConditions;


static event bool FindBTConditionDelegate(name strName, optional out delegate<BTConditionDelegate> dOutFn, optional out Name NameParam)
{
	dOutFn = None;

	if(ParseNameForNameAbilitySplit(strName, "UnitTemplateIs-", NameParam))
	{
		dOutFn = IsUnitTemplate;
		return true;
	}


	switch( strName )
	{
		case 'HasRifle':
			dOutFn = HasRifleWeapon;
			return true;
			break;

		case 'HasShotgun':
			dOutFn = HasShotgunWeapon;
			return true;
			break;

		case 'HasCannon':
			dOutFn = HasCannonWeapon;
			return true;
		break;

		case 'HasSniperRifle':
			dOutFn = HasSniperWeapon;
			return true;
		break;

		case 'HasLauncher':
			dOutFn = HasGrenadeWeapon;
			return true;
		break;
		
		case 'HasGremlin':
			dOutFn = HasGremlinWeapon;
			return true;

		case 'HasPistol':
			dOutFn = HasPistolWeapon;
			return true;
		break;

		case 'HasTargeter':
			dOutFn = HasHoloWeapon;
			return true;
		break;

		case 'HasSword':
			dOutFn = HasSwordWeapon;
			return true;
		break;

		case 'HasKnife':
			dOutFn = HasKnifeWeapon;
			return true;
		break;

		case 'HasGauntlet':
			dOutFn = HasGauntletWeapon;
			return true;
		break;

		case 'HasStunner':
			dOutFn = HasStunWeapon;
			return true;
		break;

		default:
		break;
	}

	return super.FindBTConditionDelegate(strName, dOutFn, NameParam);
}

function bt_status IsUnitTemplate()
{
	local XComGameState_Unit UnitState;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	if(UnitState.GetMyTemplateName() == SplitNameParam)
		return BTS_SUCCESS;

	`LogAIBT("IsUnitTemplate FAILED: unit template was not " $ SplitNameParam, ,'DarkXCom');

	return BTS_FAILURE;
}

function bt_status HasRifleWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'rifle')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasShotgunWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'shotgun')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}


function bt_status HasCannonWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'cannon')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasSniperWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'sniper_rifle')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasGrenadeWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'grenade_launcher')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasGremlinWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'gremlin')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}


function bt_status HasPistolWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'pistol')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasHoloWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'holotargeter')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasSwordWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'sword')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasKnifeWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'combatknife')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}

function bt_status HasGauntletWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'gauntlet')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}


function bt_status HasStunWeapon()
{
	local XComGameState_Item RelevantItem;
	local XComGameState_Unit UnitState;
	local X2WeaponTemplate WeaponTemplate;

	UnitState = m_kUnitState;

	if (UnitState == none)
		return BTS_FAILURE;

	RelevantItem = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	if (RelevantItem != none)
		WeaponTemplate = X2WeaponTemplate(RelevantItem.GetMyTemplate());

	if(WeaponTemplate.WeaponCat == 'arcthrower')
		return BTS_SUCCESS;

	return BTS_FAILURE;
}
