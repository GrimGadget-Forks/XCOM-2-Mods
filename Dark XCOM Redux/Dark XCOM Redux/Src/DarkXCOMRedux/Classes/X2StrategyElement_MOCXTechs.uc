class X2StrategyElement_MOCXTechs extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Techs;
	`log("Dark XCOM: bulding techs", ,'DarkXCom');	
	Techs.AddItem(CreateDecryptChip());
	Techs.AddItem(CreateProduceChip());



	Techs.AddItem(CreateBasicPCSes());
	Techs.AddItem(CreateAdvPCSes());
	Techs.AddItem(CreateSupPCSes());

	return Techs;
}

//---------------------------------------------------------------------------------------
// Helper function for calculating project time
static function int StafferXDays(int iNumScientists, int iNumDays)
{
	return (iNumScientists * 5) * (24 * iNumDays); // Scientists at base skill level
}


function GiveRandomItemReward(XComGameState NewGameState, XComGameState_Tech TechState)
{
	local X2ItemTemplateManager ItemTemplateManager;
	local X2ItemTemplate ItemTemplate;
	local array<name> ItemRewards;
	local int iRandIndex;
	
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	
	ItemRewards = TechState.GetMyTemplate().ItemRewards;
	iRandIndex = `SYNC_RAND(ItemRewards.Length);
	ItemTemplate = ItemTemplateManager.FindItemTemplate(ItemRewards[iRandIndex]);

	GiveItemReward(NewGameState, TechState, ItemTemplate);
}


function GiveItemReward(XComGameState NewGameState, XComGameState_Tech TechState, X2ItemTemplate ItemTemplate)
{	
	class'XComGameState_HeadquartersXCom'.static.GiveItem(NewGameState, ItemTemplate);

	TechState.ItemRewards.Length = 0; // Reset the item rewards array in case the tech is repeatable
	TechState.ItemRewards.AddItem(ItemTemplate); // Needed for UI Alert display info
	TechState.bSeenResearchCompleteScreen = false; // Reset the research report for techs that are repeatable
}

static function X2DataTemplate CreateDecryptChip()
{
	local X2TechTemplate Template;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'RM_DecryptChip');
	Template.PointsToComplete = StafferXDays(4, 10);
	Template.strImage = "img:///UILibrary_StrategyImages.ResearchTech.TECH_Alien_Datapad";
	Template.bAutopsy = true;
	Template.bCheckForceInstant = true;
	Template.SortingTier = 2;

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('AlienBiotech');
	Template.Requirements.RequiredItems.AddItem('RM_ControlChip');
	Template.Requirements.RequiredScienceScore = 20;
	Template.Requirements.bVisibleIfPersonnelGatesNotMet = true;

	// Instant Requirements. Will become the Cost if the tech is forced to Instant.
	Artifacts.ItemTemplateName = 'RM_ControlChip';
	Artifacts.Quantity = 5;
	Template.InstantRequirements.RequiredItemQuantities.AddItem(Artifacts);

	// Cost
	Artifacts.ItemTemplateName = 'RM_ControlChip';
	Artifacts.Quantity = 1;
	Template.Cost.ArtifactCosts.AddItem(Artifacts);

	return Template;
}


static function X2DataTemplate CreateProduceChip()
{
	local X2TechTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'RM_ProduceChip');
	Template.PointsToComplete = StafferXDays(1, 6);
	Template.strImage = "img:///UILibrary_StrategyImages.ResearchTech.TECH_Alien_Datapad";
	Template.bProvingGround = true;
	Template.bRepeatable = true;
	Template.SortingTier = 3;
	Template.ResearchCompletedFn = GiveRandomItemReward;

	Template.Requirements.RequiredTechs.AddItem('RM_DecryptChip');

	Template.Requirements.SpecialRequirementsFn = WasHQMissionCompleted;

	Template.ItemRewards.AddItem('RM_ControlChip');

	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 25;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}

function bool WasHQMissionCompleted()
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersDarkXCom DarkXComHQ;


	History = `XCOMHISTORY;
	DarkXComHQ = XComGameState_HeadquartersDarkXCOM(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCOM'));

	return DarkXComHQ.bIsDestroyed; //if destroyed, mission was completed
}


static function X2DataTemplate CreateBasicPCSes()
{
	local X2TechTemplate Template;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'RM_BasicPCS');
	Template.PointsToComplete = StafferXDays(1, 6);
	Template.strImage = "img:///UILibrary_StrategyImages.ResearchTech.TECH_Alien_Datapad";
	Template.bProvingGround = true;
	Template.bRepeatable = true;
	Template.SortingTier = 3;
	Template.ResearchCompletedFn = GiveRandomItemReward;

	Template.Requirements.RequiredTechs.AddItem('RM_DecryptChip');

	Template.ItemRewards.AddItem('CommonPCSSpeed');
	Template.ItemRewards.AddItem('CommonPCSConditioning');
	Template.ItemRewards.AddItem('CommonPCSPerception');
	Template.ItemRewards.AddItem('CommonPCSAgility');
	Template.ItemRewards.AddItem('CommonPCSFocus');

	Artifacts.ItemTemplateName = 'RM_ControlChip';
	Artifacts.Quantity = 1;
	Template.Cost.ArtifactCosts.AddItem(Artifacts);

	return Template;
}


static function X2DataTemplate CreateAdvPCSes()
{
	local X2TechTemplate Template;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'RM_AdvPCS');
	Template.PointsToComplete = StafferXDays(1, 8);
	Template.strImage = "img:///UILibrary_StrategyImages.ResearchTech.TECH_Alien_Datapad";
	Template.bProvingGround = true;
	Template.bRepeatable = true;
	Template.SortingTier = 3;
	Template.ResearchCompletedFn = GiveRandomItemReward;

	Template.Requirements.RequiredTechs.AddItem('RM_DecryptChip');
	Template.Requirements.RequiredTechs.AddItem('AutopsyMuton');

	Template.ItemRewards.AddItem('RarePCSSpeed');
	Template.ItemRewards.AddItem('RarePCSConditioning');
	Template.ItemRewards.AddItem('RarePCSPerception');
	Template.ItemRewards.AddItem('RarePCSAgility');
	Template.ItemRewards.AddItem('RarePCSFocus');
	Template.ItemRewards.AddItem('LongJumpPCS');

	Artifacts.ItemTemplateName = 'RM_ControlChip';
	Artifacts.Quantity = 2;
	Template.Cost.ArtifactCosts.AddItem(Artifacts);

	return Template;
}


static function X2DataTemplate CreateSupPCSes()
{
	local X2TechTemplate Template;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'RM_SupPCS');
	Template.PointsToComplete = StafferXDays(1, 10);
	Template.strImage = "img:///UILibrary_StrategyImages.ResearchTech.TECH_Alien_Datapad";
	Template.bProvingGround = true;
	Template.bRepeatable = true;
	Template.SortingTier = 3;
	Template.ResearchCompletedFn = GiveRandomItemReward;
	
	Template.Requirements.RequiredTechs.AddItem('RM_DecryptChip');
	Template.Requirements.RequiredTechs.AddItem('AutopsyAndromedon');

	Template.ItemRewards.AddItem('EpicPCSSpeed');
	Template.ItemRewards.AddItem('EpicPCSConditioning');
	Template.ItemRewards.AddItem('EpicPCSPerception');
	Template.ItemRewards.AddItem('EpicPCSAgility');
	Template.ItemRewards.AddItem('EpicPCSFocus');
	Template.ItemRewards.AddItem('MimeticSkinPCS');

	Artifacts.ItemTemplateName = 'RM_ControlChip';
	Artifacts.Quantity = 3;
	Template.Cost.ArtifactCosts.AddItem(Artifacts);

	return Template;
}