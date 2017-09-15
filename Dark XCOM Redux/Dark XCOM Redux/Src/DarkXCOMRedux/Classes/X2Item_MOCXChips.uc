class X2Item_MOCXChips extends X2Item;

var localized array<string> PCSBlackMarketTexts;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Resources;

	`log("DArk XCOM: building chips and blueprint", ,'DarkXCom');
	Resources.AddItem(CreateControlChip());
	Resources.AddItem(CreateLongJumpPCS());
	Resources.AddItem(CreateMimeticSkinPCS());

	Resources.AddItem(CreateHQBlueprint()); //this is a cheap hack but too lazy to make new class for it

	return Resources;
}

static function X2DataTemplate CreateHQBlueprint()
{
	local X2QuestItemTemplate Template;

	`CREATE_X2TEMPLATE(class'X2QuestItemTemplate', Template, 'RM_HQBlueprint');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Black_Site_Data";
	Template.ItemCat = 'quest';
	Template.CanBeBuilt = false;
	Template.HideInInventory = false;
	Template.HideInLootRecovered = false;
	Template.bOneTimeBuild = false;
	Template.bBlocked = false;
	Template.IsElectronicReward = true;

	Template.MissionType.AddItem("Dark_TrainingRaid");

	Template.RewardType.AddItem('Reward_Elerium');
	Template.RewardType.AddItem('Reward_AlienLoot');
	Template.RewardType.AddItem('Reward_Alloys');

	return Template;
}

static function X2DataTemplate CreateControlChip()
{
	local X2ItemTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ItemTemplate', Template, 'RM_ControlChip');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Sch_Advent_Datapad";
	Template.ItemCat = 'resource';
	Template.TradingPostValue = 3;
	Template.MaxQuantity = 1;
	Template.LeavesExplosiveRemains = true;
	Template.bAlwaysRecovered = true;

	return Template;
}


static function X2DataTemplate CreateLongJumpPCS()
{
	local X2EquipmentTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'LongJumpPCS');

	Template.LootStaticMesh = StaticMesh'UI_3D.Loot.AdventPCS';
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_CombatSim_Speed";
	Template.ItemCat = 'combatsim';
	Template.TradingPostValue = 20;
	Template.bAlwaysUnique = false;
	Template.Tier = 2;

	Template.Abilities.AddItem('RM_LongJump');
	Template.InventorySlot = eInvSlot_CombatSim;

	Template.BlackMarketTexts = default.PCSBlackMarketTexts;

	return Template;
}

static function X2DataTemplate CreateMimeticSkinPCS()
{
	local X2EquipmentTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EquipmentTemplate', Template, 'MimeticSkinPCS');

	Template.LootStaticMesh = StaticMesh'UI_3D.Loot.AdventPCS';
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_CombatSim_Speed";
	Template.ItemCat = 'combatsim';
	Template.TradingPostValue = 20;
	Template.bAlwaysUnique = false;
	Template.Tier = 4;

	Template.Abilities.AddItem('RM_MimeticSkin');
	Template.InventorySlot = eInvSlot_CombatSim;

	Template.BlackMarketTexts = default.PCSBlackMarketTexts;

	return Template;
}