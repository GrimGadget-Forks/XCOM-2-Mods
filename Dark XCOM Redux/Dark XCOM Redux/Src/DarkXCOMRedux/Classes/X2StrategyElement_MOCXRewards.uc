class X2StrategyElement_MOCXRewards extends X2StrategyElement_DefaultRewards
	dependson(X2RewardTemplate);

	
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;

	`log("Dark XCOM: bulding mission rewards", ,'DarkXCom');
	// Mission Rewards
	Rewards.AddItem(CreateOffsiteMissionRewardTemplate()); //this is so we can rescue soldiers just captured by ADVENT
	Rewards.AddItem(CreateAssaultMissionRewardTemplate());
	Rewards.AddItem(CreateTrainingMissionRewardTemplate());

	return Rewards;
}


// #######################################################################################
// -------------------- MISSION REWARDS --------------------------------------------------
// #######################################################################################



static function X2DataTemplate CreateOffsiteMissionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_MOCXOffsite');

	Template.IsRewardAvailableFn = IsOffsiteAvailable;
	Template.GiveRewardFn = GiveOffsiteReward;
	Template.GetRewardStringFn = GetMissionRewardString;
	Template.RewardPopupFn = MissionRewardPopup;

	return Template;
}

static function X2DataTemplate CreateTrainingMissionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_MOCXTraining');

	Template.IsRewardAvailableFn = IsTrainingAvailable;
	Template.GiveRewardFn = GiveTrainingReward;
	Template.GetRewardStringFn = GetMissionRewardString;
	Template.RewardPopupFn = MissionRewardPopup;

	return Template;
}


static function X2DataTemplate CreateAssaultMissionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_MOCXAssault');

	Template.IsRewardAvailableFn = IsAssaultAvailable;
	Template.GiveRewardFn = GiveAssaultReward;
	Template.GetRewardStringFn = GetMissionRewardString;
	Template.RewardPopupFn = MissionRewardPopup;

	return Template;
}

// #######################################################################################
// -------------------- CHECK REWARDS --------------------------------------------------
// #######################################################################################

static function bool IsOffsiteAvailable(optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
	local XComGameState_HeadquartersDarkXcom DarkXComHQ;

	DarkXComHQ = class'UNitDarkXComUtils'.static.GetDarkXComHQ();
	if (DarkXComHQ != none && !DarkXComHQ.bIsDestroyed && DarkXComHQ.bIsActive && !DarkXComHQ.bOffsiteDone)
	{
		return true;
	}

	return false;
}


static function bool IsTrainingAvailable(optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
	local XComGameState_HeadquartersDarkXcom DarkXComHQ;

	DarkXComHQ = class'UNitDarkXComUtils'.static.GetDarkXComHQ();
	if (DarkXComHQ != none && !DarkXComHQ.bIsDestroyed && DarkXComHQ.bIsActive && DarkXComHQ.bOffsiteDone && !DarkXComHQ.bTrainingDone)
	{
		return true;
	}

	return false;
}

static function bool IsAssaultAvailable(optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
	local XComGameState_HeadquartersDarkXcom DarkXComHQ;

	DarkXComHQ = class'UnitDarkXComUtils'.static.GetDarkXComHQ();
	if (DarkXComHQ != none && !DarkXComHQ.bIsDestroyed && DarkXComHQ.bIsActive && DarkXComHQ.bOffsiteDone && DarkXComHQ.bTrainingDone)
	{
		return true;
	}

	return false;
}



// #######################################################################################
// -------------------- give REWARDS --------------------------------------------------
// #######################################################################################

static function GiveOffsiteReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_MissionSite_MOCX  MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward MissionRewardState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local float MissionDuration;
	local XComGameState_CovertAction ActionState;
	local XComGameState_HeadquartersResistance ResHQ;
	local array<XComGameState_WorldRegion> ContactRegions;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(AuxRef.ObjectID));
	RegionState = ActionState.GetWorldRegion();
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();

	if(RegionState == none)
	{
		foreach `XCOMHistory.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
		{
			if(RegionState.HaveMadeContact())
			{
				// Grab all contacted regions regions for fall-through case
				ContactRegions.AddItem(RegionState);

			}
		}
		RegionState = ContactRegions[`SYNC_RAND_STATIC(ContactRegions.Length)];
	}

	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_FacilityLead'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Intel'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	MissionState = XComGameState_MissionSite_MOCX(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite_MOCX'));

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_MOCXOffsite'));
	
	MissionDuration = float((default.MissionMinDuration + `SYNC_RAND_STATIC(default.MissionMaxDuration - default.MissionMinDuration + 1)) * 3600);
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, false, , MissionDuration);
	MissionState.PickPOI(NewGameState);

	// Set this mission as associated with the Faction whose Covert Action spawned it
	MissionState.ResistanceFaction = ActionState.Faction;

	RewardState.RewardObjectReference = MissionState.GetReference();
}


static function GiveTrainingReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_MissionSite_MOCX MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward MissionRewardState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local float MissionDuration;
	local XComGameState_CovertAction ActionState;
	local XComGameState_HeadquartersResistance ResHQ;
	local array<XComGameState_WorldRegion> ContactRegions;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(AuxRef.ObjectID));
	RegionState = ActionState.GetWorldRegion();
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();

	if(RegionState == none)
	{
		foreach `XCOMHistory.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
		{
			if(RegionState.HaveMadeContact())
			{
				// Grab all contacted regions regions for fall-through case
				ContactRegions.AddItem(RegionState);

			}
		}
		RegionState = ContactRegions[`SYNC_RAND_STATIC(ContactRegions.Length)];
	}

	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Elerium'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_AlienLoot'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Alloys'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	MissionState = XComGameState_MissionSite_MOCX(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite_MOCX'));

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_MOCXTraining'));
	
	MissionDuration = float((default.MissionMinDuration + `SYNC_RAND_STATIC(default.MissionMaxDuration - default.MissionMinDuration + 1)) * 3600);
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, false, , MissionDuration);
	MissionState.PickPOI(NewGameState);

	// Set this mission as associated with the Faction whose Covert Action spawned it
	MissionState.ResistanceFaction = ActionState.Faction;

	RewardState.RewardObjectReference = MissionState.GetReference();
}

static function GiveAssaultReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_MissionSite_MOCX MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward MissionRewardState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local float MissionDuration;
	local XComGameState_CovertAction ActionState;
	local XComGameState_HeadquartersResistance ResHQ;
	local array<XComGameState_WorldRegion> ContactRegions;

	if(RegionState == none)
	{
		foreach `XCOMHistory.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
		{
			if(RegionState.HaveMadeContact())
			{
				// Grab all contacted regions regions for fall-through case
				ContactRegions.AddItem(RegionState);

			}
		}
		RegionState = ContactRegions[`SYNC_RAND_STATIC(ContactRegions.Length)];
	}

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(AuxRef.ObjectID));
	RegionState = ActionState.GetWorldRegion();
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();

	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Engineer'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Scientist'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference());
	MissionRewards.AddItem(MissionRewardState);

	MissionState = XComGameState_MissionSite_MOCX(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite_MOCX'));

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_MOCXAssault'));
	
	MissionDuration = float((default.MissionMinDuration + `SYNC_RAND_STATIC(default.MissionMaxDuration - default.MissionMinDuration + 1)) * 3600);
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, false, , MissionDuration);
	MissionState.PickPOI(NewGameState);

	// Set this mission as associated with the Faction whose Covert Action spawned it
	MissionState.ResistanceFaction = ActionState.Faction;

	RewardState.RewardObjectReference = MissionState.GetReference();
}