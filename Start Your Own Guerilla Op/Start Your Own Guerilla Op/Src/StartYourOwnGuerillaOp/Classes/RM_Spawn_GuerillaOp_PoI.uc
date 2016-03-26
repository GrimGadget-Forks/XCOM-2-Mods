// This is an Unreal Script
class RM_Spawn_GuerillaOp_PoI extends X2StrategyElement config(StartOp);

var config bool GUERILLA_OP_INSTANT;

var config int GUERILLA_OP_COST;

var config int GUERILLA_OP_COST_INCREASE;

var config int GUERILLA_OP_SUPPLIES_COST;

var config int GUERILLA_OP_INTEL_COST;

var int ADDITIONAL_SUPPLIES_COST;

var int ADDITIONAL_INTEL_COST;

var config int DOES_SUPPLIES_INCREASE;

var config int DOES_INTEL_INCREASE;

var config bool SUPPLYRAID_INSTANT;

var config int SUPPLYRAID_COST;

var config int SUPPLYRAID_COST_INCREASE;

var config int SUPPLYRAID_SUPPLIES_COST;

var config int SUPPLYRAID_INTEL_COST;

var config bool CITYCENTEROP_INSTANT;

var config int CITYCENTEROP_COST;

var config int CITYCENTEROP_COST_INCREASE;

var config int CITYCENTEROP_SUPPLIES_COST;

var config int CITYCENTEROP_INTEL_COST;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Techs;
	
	Techs.AddItem(PrepareGuerillaOp());
	Techs.AddItem(PrepareSupplyRaid());
	Techs.AddItem(PrepareCityCenterOP());

	return Techs;
}


static function X2DataTemplate PrepareGuerillaOp()
{
	local X2TechTemplate Template;
	local ArtifactCost Resource1, Resource2;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'Tech_PrepareGuerillaOp');
	Template.PointsToComplete = default.GUERILLA_OP_COST;
	Template.RepeatPointsIncrease = default.GUERILLA_OP_COST_INCREASE;
	Template.bRepeatable = true;
	Template.bCheckForceInstant = default.GUERILLA_OP_INSTANT;
	Template.strImage = "img:///UILibrary_StrategyImages.ResearchTech.TECH_Facility_Lead";
	Template.SortingTier = 4;
	Template.ResearchCompletedFn = SpawnGuerillaOp;

	Template.Requirements.RequiredTechs.AddItem('ResistanceCommunications');
	Template.Requirements.bVisibleIfTechsNotMet = true;

	// Cost
	Resource1.ItemTemplateName = 'Intel';
	Resource1.Quantity = default.GUERILLA_OP_INTEL_COST + default.ADDITIONAL_INTEL_COST;
	Template.Cost.ResourceCosts.AddItem(Resource1);
	Resource2.ItemTemplateName = 'Supplies';
	Resource2.Quantity = default.GUERILLA_OP_SUPPLIES_COST + default.ADDITIONAL_SUPPLIES_COST;
	Template.Cost.ResourceCosts.AddItem(Resource2);

	return Template;
}

static function X2DataTemplate PrepareSupplyRaid()
{
	local X2TechTemplate Template;
	local ArtifactCost Resource1, Resource2;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'Tech_PrepareSupplyRaid');
	Template.PointsToComplete = default.SUPPLYRAID_COST;
	Template.RepeatPointsIncrease = default.SUPPLYRAID_COST_INCREASE;
	Template.bRepeatable = true;
	Template.bCheckForceInstant = default.SUPPLYRAID_INSTANT;
	Template.strImage = "img:///UILibrary_StrategyImages.ResearchTech.TECH_Facility_Lead";
	Template.SortingTier = 4;
	Template.ResearchCompletedFn = SpawnSupplyRaid;

	Template.Requirements.RequiredTechs.AddItem('ResistanceCommunications');
	Template.Requirements.bVisibleIfTechsNotMet = true;

	// Cost
	Resource1.ItemTemplateName = 'Intel';
	Resource1.Quantity = default.SUPPLYRAID_INTEL_COST + default.ADDITIONAL_INTEL_COST;
	Template.Cost.ResourceCosts.AddItem(Resource1);
	Resource2.ItemTemplateName = 'Supplies';
	Resource2.Quantity = default.SUPPLYRAID_SUPPLIES_COST + default.ADDITIONAL_SUPPLIES_COST;
	Template.Cost.ResourceCosts.AddItem(Resource2);

	return Template;
}


static function X2DataTemplate PrepareCityCenterOP()
{
	local X2TechTemplate Template;
	local ArtifactCost Resource1, Resource2;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'Tech_PrepareCityCenterOP');
	Template.PointsToComplete = default.CITYCENTEROP_COST;
	Template.RepeatPointsIncrease = default.CITYCENTEROP_COST_INCREASE;
	Template.bRepeatable = true;
	Template.bCheckForceInstant = default.CITYCENTEROP_INSTANT;
	Template.strImage = "img:///UILibrary_StrategyImages.ResearchTech.TECH_Facility_Lead";
	Template.SortingTier = 4;
	Template.ResearchCompletedFn = SpawnCityCenterOP;

	Template.Requirements.RequiredTechs.AddItem('ResistanceCommunications');
	Template.Requirements.bVisibleIfTechsNotMet = true;

	// Cost
	Resource1.ItemTemplateName = 'Intel';
	Resource1.Quantity = default.CITYCENTEROP_INTEL_COST + default.ADDITIONAL_INTEL_COST;
	Template.Cost.ResourceCosts.AddItem(Resource1);
	Resource2.ItemTemplateName = 'Supplies';
	Resource2.Quantity = default.CITYCENTEROP_SUPPLIES_COST + default.ADDITIONAL_SUPPLIES_COST;
	Template.Cost.ResourceCosts.AddItem(Resource2);

	return Template;
}



function SpawnGuerillaOp(XComGameState NewGameState,  XComGameState_Tech TechState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_MissionSite MissionState;
	local X2MissionSourceTemplate MissionSource;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward RewardState;
	local array<XComGameState_Reward> MissionRewards;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local array<name> ExcludeList;
	local XComGameState_MissionCalendar CalendarState;
	local int newIntelCost, newSuppliesCost;

	newIntelCost = ADDITIONAL_INTEL_COST + DOES_INTEL_INCREASE;

	newSuppliesCost = ADDITIONAL_SUPPLIES_COST + DOES_SUPPLIES_INCREASE;

	ADDITIONAL_INTEL_COST = newIntelCost;

	ADDITIONAL_SUPPLIES_COST = newSuppliesCost;
	
	CalendarState = GetMissionCalendar(NewGameState);
	
	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	RegionState = GetRandomContactedRegion();
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_GuerillaOp'));
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate(SelectGuerillaOpRewardType(ExcludeList, CalendarState)));

	if(MissionSource == none || RewardTemplate == none)
	{
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Spawn Mission");
	RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	NewGameState.AddStateObject(RewardState);
	RewardState.GenerateReward(NewGameState, , RegionState.GetReference());
	MissionRewards.AddItem(RewardState);

	MissionState = XComGameState_MissionSite(NewGameState.CreateStateObject(class'XComGameState_MissionSite'));
	NewGameState.AddStateObject(MissionState);
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards);

	if(NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
}

function SpawnSupplyRaid(XComGameState NewGameState,  XComGameState_Tech TechState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_MissionSite MissionState;
	local X2MissionSourceTemplate MissionSource;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward RewardState;
	local array<XComGameState_Reward> MissionRewards;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local array<name> ExcludeList;
	local XComGameState_MissionCalendar CalendarState;
	local int newIntelCost, newSuppliesCost;

	newIntelCost = ADDITIONAL_INTEL_COST + DOES_INTEL_INCREASE;

	newSuppliesCost = ADDITIONAL_SUPPLIES_COST + DOES_SUPPLIES_INCREASE;

	ADDITIONAL_INTEL_COST = newIntelCost;

	ADDITIONAL_SUPPLIES_COST = newSuppliesCost;
	
	CalendarState = GetMissionCalendar(NewGameState);
	
	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	RegionState = GetRandomContactedRegion();
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_SupplyRaid'));
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_None'));

	if(MissionSource == none || RewardTemplate == none)
	{
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Spawn Mission");
	RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	NewGameState.AddStateObject(RewardState);
	RewardState.GenerateReward(NewGameState, , RegionState.GetReference());
	MissionRewards.AddItem(RewardState);

	MissionState = XComGameState_MissionSite(NewGameState.CreateStateObject(class'XComGameState_MissionSite'));
	NewGameState.AddStateObject(MissionState);
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards);

	if(NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
}

function SpawnCityCenterOP(XComGameState NewGameState,  XComGameState_Tech TechState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_MissionSite MissionState;
	local X2MissionSourceTemplate MissionSource;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward RewardState;
	local array<XComGameState_Reward> MissionRewards;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local array<name> ExcludeList;
	local XComGameState_MissionCalendar CalendarState;
	local int newIntelCost, newSuppliesCost;

	newIntelCost = ADDITIONAL_INTEL_COST + DOES_INTEL_INCREASE;

	newSuppliesCost = ADDITIONAL_SUPPLIES_COST + DOES_SUPPLIES_INCREASE;

	ADDITIONAL_INTEL_COST = newIntelCost;

	ADDITIONAL_SUPPLIES_COST = newSuppliesCost;
	
	CalendarState = GetMissionCalendar(NewGameState);
	
	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	RegionState = GetRandomContactedRegion();
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_Council'));
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Intel'));

	if(MissionSource == none || RewardTemplate == none)
	{
		return;
	}

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Spawn Mission");
	RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	NewGameState.AddStateObject(RewardState);
	RewardState.GenerateReward(NewGameState, , RegionState.GetReference());
	MissionRewards.AddItem(RewardState);

	MissionState = XComGameState_MissionSite(NewGameState.CreateStateObject(class'XComGameState_MissionSite'));
	NewGameState.AddStateObject(MissionState);
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards);

	if(NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
}

function CreateGuerillaOpRewards(XComGameState_MissionCalendar CalendarState)
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<name> Rewards;
	local int idx, SourceIndex;
	local MissionRewardDeck RewardDeck;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_GuerillaOp'));
	Rewards = GetShuffledRewardDeck(MissionSource.RewardDeck);

	SourceIndex = CalendarState.MissionRewardDecks.Find('MissionSource', 'MissionSource_GuerillaOp');

	if(SourceIndex == INDEX_NONE)
	{
		RewardDeck.MissionSource = 'MissionSource_GuerillaOp';
		CalendarState.MissionRewardDecks.AddItem(RewardDeck);
		SourceIndex = CalendarState.MissionRewardDecks.Find('MissionSource', 'MissionSource_GuerillaOp');
	}

	// Append to end of current list
	for(idx = 0; idx < Rewards.Length; idx++)
	{
		CalendarState.MissionRewardDecks[SourceIndex].Rewards.AddItem(Rewards[idx]);
	}
}


function name SelectGuerillaOpRewardType(out array<name> ExcludeList, XComGameState_MissionCalendar CalendarState)
{
	local X2StrategyElementTemplateManager TemplateManager;
	local X2RewardTemplate RewardTemplate;
	local name RewardType;
	local bool bSingleRegion, bFoundNeededReward;
	local int SourceIndex, ExcludeIndex, idx;
	local MissionRewardDeck ExcludeDeck;
	local array<name> SkipList;
	
	SourceIndex = CalendarState.MissionRewardDecks.Find('MissionSource', 'MissionSource_GuerillaOp');
	ExcludeIndex = CalendarState.MissionRewardExcludeDecks.Find('MissionSource', 'MissionSource_GuerillaOp');

	if(ExcludeIndex == INDEX_NONE)
	{
		ExcludeDeck.MissionSource = 'MissionSource_GuerillaOp';
		CalendarState.MissionRewardExcludeDecks.AddItem(ExcludeDeck);
		ExcludeIndex = CalendarState.MissionRewardExcludeDecks.Find('MissionSource', 'MissionSource_GuerillaOp');
	}

	// Refill the deck if empty
	if(SourceIndex == INDEX_NONE || CalendarState.MissionRewardDecks[SourceIndex].Rewards.Length == 0)
	{
		CreateGuerillaOpRewards(CalendarState);
	}

	SourceIndex = CalendarState.MissionRewardDecks.Find('MissionSource', 'MissionSource_GuerillaOp');

	bSingleRegion = (GetNumberOfGuerillaOps(CalendarState) == 1);

	if(bSingleRegion && NeedToResetSingleRegionExcludes(ExcludeList, CalendarState))
	{
		CalendarState.MissionRewardExcludeDecks[ExcludeIndex].Rewards.Length = 0;
	}

	// Guarantee engineer on first guerrilla ops you see
	if(!CalendarState.HasCreatedMissionOfSource('MissionSource_GuerillaOp') && ExcludeList.Length == 0)
	{
		RewardType = 'Reward_Engineer';
		ExcludeList.AddItem(RewardType);
		idx = CalendarState.MissionRewardDecks[SourceIndex].Rewards.Find(RewardType);

		if(idx != INDEX_NONE)
		{
			CalendarState.MissionRewardDecks[SourceIndex].Rewards.Remove(idx, 1);
		}
	}
	else
	{
		while(RewardType == '')
		{
			TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
			
			// Check if there is a valid reward that the player badly needs, if so use it as the reward
			for (idx = 0; idx < CalendarState.MissionRewardDecks[SourceIndex].Rewards.Length; idx++)
			{
				if (ExcludeList.Find(CalendarState.MissionRewardDecks[SourceIndex].Rewards[idx]) == INDEX_NONE)
				{
					if (SkipList.Find(CalendarState.MissionRewardDecks[SourceIndex].Rewards[idx]) == INDEX_NONE)
					{
						if (!bSingleRegion || CalendarState.MissionRewardExcludeDecks[ExcludeIndex].Rewards.Find(CalendarState.MissionRewardDecks[SourceIndex].Rewards[idx]) == INDEX_NONE)
						{
							RewardType = CalendarState.MissionRewardDecks[SourceIndex].Rewards[idx];
							RewardTemplate = X2RewardTemplate(TemplateManager.FindStrategyElementTemplate(RewardType));
							if (RewardTemplate != none)
							{
								if (RewardTemplate.IsRewardNeededFn != none && RewardTemplate.IsRewardNeededFn())
								{
									CalendarState.MissionRewardDecks[SourceIndex].Rewards.Remove(idx, 1);
									ExcludeList.AddItem(RewardType);
									bFoundNeededReward = true;
									break;
								}
								else // If the reward does not have have an IsRewardNeededFn, or it has failed, add it to the skip list so that reward type isn't checked again
								{
									SkipList.AddItem(RewardType);
									RewardType = ''; // Clear the reward type
								}
							}
						}
					}
				}
			}

			if (!bFoundNeededReward)
			{
				for (idx = 0; idx < CalendarState.MissionRewardDecks[SourceIndex].Rewards.Length; idx++)
				{
					if (ExcludeList.Find(CalendarState.MissionRewardDecks[SourceIndex].Rewards[idx]) == INDEX_NONE)
					{
						if (!bSingleRegion || CalendarState.MissionRewardExcludeDecks[ExcludeIndex].Rewards.Find(CalendarState.MissionRewardDecks[SourceIndex].Rewards[idx]) == INDEX_NONE)
						{
							RewardType = CalendarState.MissionRewardDecks[SourceIndex].Rewards[idx];
							RewardTemplate = X2RewardTemplate(TemplateManager.FindStrategyElementTemplate(RewardType));
							if (RewardTemplate != none)
							{
								if (RewardTemplate.IsRewardAvailableFn == none || RewardTemplate.IsRewardAvailableFn())
								{
									CalendarState.MissionRewardDecks[SourceIndex].Rewards.Remove(idx, 1);
									ExcludeList.AddItem(RewardType);
									break;									
								}
								else // If IsRewardAvailableFn fails, add it to the exclude list so that reward type isn't checked again
								{
									ExcludeList.AddItem(RewardType);
									RewardType = ''; // Clear the reward type
								}
							}
						}
					}
				}
			}

			if(RewardType == '')
			{
				// If we're starting over with a new reward deck, wipe the old one to get rid of any excluded stragglers
				CalendarState.MissionRewardDecks[SourceIndex].Rewards.Length = 0;
				CreateGuerillaOpRewards(CalendarState);
			}
		}
	}

	if(bSingleRegion)
	{
		CalendarState.MissionRewardExcludeDecks[ExcludeIndex].Rewards.AddItem(RewardType);
	}
	else
	{
		CalendarState.MissionRewardExcludeDecks[ExcludeIndex].Rewards.Length = 0;
	}

	return RewardType;
}


function array<name> GetShuffledRewardDeck(array<RewardDeckEntry> ConfigRewards)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersAlien AlienHQ;
	local int ForceLevel, idx, i, iTemp, iRand;
	local array<name> UnshuffledRewards, ShuffledRewards;
	local name EntryName;

	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	ForceLevel = AlienHQ.GetForceLevel();

	// Add all applicable rewards to unshuffled deck
	for(idx = 0; idx < ConfigRewards.Length; idx++)
	{
		if(ConfigRewards[idx].ForceLevelGate <= ForceLevel)
		{
			for(i = 0; i < ConfigRewards[idx].Quantity; i++)
			{
				UnshuffledRewards.AddItem(ConfigRewards[idx].RewardName);
			}
		}
	}

	// Shuffle the deck
	iTemp = UnshuffledRewards.Length;
	for(idx = 0; idx < iTemp; idx++)
	{
		iRand = `SYNC_RAND(UnshuffledRewards.Length);
		EntryName = UnshuffledRewards[iRand];
		UnshuffledRewards.Remove(iRand, 1);
		ShuffledRewards.AddItem(EntryName);
	}

	return ShuffledRewards;
}


function int GetNumberOfGuerillaOps(XComGameState_MissionCalendar CalendarState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersAlien AlienHQ;
	local int NumOps;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	NumOps = XComHQ.GetCurrentResContacts(true);

	if(CalendarState.HasCreatedMissionOfSource('MissionSource_GuerillaOp'))
	{
		AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
		NumOps = Clamp(NumOps, 0, AlienHQ.ChosenDarkEvents.Length);
	}

	return Clamp(NumOps, 1, 1);
}

function bool NeedToResetSingleRegionExcludes(array<name> ExcludeList, XComGameState_MissionCalendar CalendarState)
{
	local array<name> DeckRewardTypes;
	local int SourceIndex, ExcludeIndex, idx;

	// Grab Reward types already picked for this round of GOps
	for(idx = 0; idx < ExcludeList.Length; idx++)
	{
		if(DeckRewardTypes.Find(ExcludeList[idx]) == INDEX_NONE)
		{
			DeckRewardTypes.AddItem(ExcludeList[idx]);
		}
	}

	SourceIndex = CalendarState.MissionRewardDecks.Find('MissionSource', 'MissionSource_GuerillaOp');

	// Grab Rewards in the reward deck
	for(idx = 0; idx < CalendarState.MissionRewardDecks[SourceIndex].Rewards.Length; idx++)
	{
		if(DeckRewardTypes.Find(CalendarState.MissionRewardDecks[SourceIndex].Rewards[idx]) == INDEX_NONE)
		{
			DeckRewardTypes.AddItem(CalendarState.MissionRewardDecks[SourceIndex].Rewards[idx]);
		}
	}

	ExcludeIndex = CalendarState.MissionRewardExcludeDecks.Find('MissionSource', 'MissionSource_GuerillaOp');

	for(idx = 0; idx < DeckRewardTypes.Length; idx++)
	{
		if(CalendarState.MissionRewardExcludeDecks[ExcludeIndex].Rewards.Find(DeckRewardTypes[idx]) == INDEX_NONE)
		{
			return false;
		}
	}

	return true;
}


function XComGameState_MissionCalendar GetMissionCalendar(XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_MissionCalendar CalendarState;

	foreach NewGameState.IterateByClassType(class'XComGameState_MissionCalendar', CalendarState)
	{
		break;
	}

	if(CalendarState == none)
	{
		History = `XCOMHISTORY;
		CalendarState = XComGameState_MissionCalendar(History.GetSingleGameStateObjectForClass(class'XComGameState_MissionCalendar'));
		CalendarState = XComGameState_MissionCalendar(NewGameState.CreateStateObject(class'XComGameState_MissionCalendar', CalendarState.ObjectID));
		NewGameState.AddStateObject(CalendarState);
	}

	return CalendarState;
}

function XComGameState_WorldRegion GetRandomContactedRegion()
{
	local XComGameStateHistory History;
	local XComGameState_WorldRegion RegionState;
	local array<XComGameState_WorldRegion> ValidRegions, AllRegions;

	History = `XCOMHISTORY;

		foreach History.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
			AllRegions.AddItem(RegionState);

			if(RegionState.ResistanceLevel >= eResLevel_Contact)
			{
				ValidRegions.AddItem(RegionState);
			}
		}

	if(ValidRegions.Length > 0)
	{
		return ValidRegions[`SYNC_RAND(ValidRegions.Length)];
	}

	return AllRegions[`SYNC_RAND(AllRegions.Length)];
}
