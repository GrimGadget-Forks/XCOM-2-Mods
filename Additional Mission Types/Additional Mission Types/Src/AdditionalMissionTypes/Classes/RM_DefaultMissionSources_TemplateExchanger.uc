class RM_DefaultMissionSources_TemplateExchanger extends X2AmbientNarrativeCriteria config (HavenSiege);

var XComGameState_CampaignSettings Settings;

static function array<X2DataTemplate> CreateTemplates(){
	local array<X2DataTemplate> EmptyArray;
	local RM_DefaultMissionSources_TemplateExchanger Exchanger;
	
	`log("Make Doom-based Mission Difficulty starts modifiying Mission Source Templates");
	Exchanger = new class'RM_DefaultMissionSources_TemplateExchanger';
	Exchanger.Settings = GameStateMagic();
	Exchanger.ModifyTemplates();

	`XCOMHISTORY.ResetHistory(); // yeah, lets do that, nothing happend anyway...

	`log("Make  Additional Mission Types finished");

	//We don't create any new templates, only modify existing mission templates
	//AddItem(none) prevents array non initialized warning, although the access of none shows up in the debug log
	EmptyArray.AddItem(none);
	return EmptyArray;
}

//Code from: http://forums.nexusmods.com/index.php?/topic/3839560-template-modification-without-screenlisteners/
//Used to set a difficulty level during start up, because the templates we want to modify have difficulty variants
//These variants can only be accessed when the gamestate is in the corresponding difficulty
static function XComGameState_CampaignSettings GameStateMagic(){
	local XComGameStateHistory History;
	local XComGameStateContext_StrategyGameRule StrategyStartContext;
	local XComGameState StartState;
	local XComGameState_CampaignSettings GameSettings;

	History = `XCOMHISTORY;

	StrategyStartContext = XComGameStateContext_StrategyGameRule(class'XComGameStateContext_StrategyGameRule'.static.CreateXComGameStateContext());
	StrategyStartContext.GameRuleType = eStrategyGameRule_StrategyGameStart;
	StartState = History.CreateNewGameState(false, StrategyStartContext);
	History.AddGameStateToHistory(StartState);

	GameSettings = new class'XComGameState_CampaignSettings'; // Do not use CreateStateObject() here
	StartState.AddStateObject(GameSettings);

	return GameSettings;
}

function ModifyTemplates(){
	
	HandleTemplate('MissionSource_Retaliation');

}

function HandleTemplate(name templateName){
	local X2MissionSourceTemplate Template;

	Template = X2MissionSourceTemplate(GetManager().FindStrategyElementTemplate(templateName));

	if (Template == none)
	{
		`log("Could not find template:"@string(templateName));
		return;
	}

	if (Template.bShouldCreateDifficultyVariants){
		HandleDifficultyVariants(Template, templateName);
	} else {
		`log("Modify single template:"@string(templateName));
		HandleSingleTemplate(Template, templateName);
	}
}

function HandleDifficultyVariants(X2MissionSourceTemplate Base, name templateName) {
	local X2MissionSourceTemplate Template;
	local int difficulty;
	local string diffString;

	HandleSingleTemplate(Base, templateName);
	`log("Modified base template:"@string(templateName));

	for(difficulty = `MIN_DIFFICULTY_INDEX; difficulty <= `MAX_DIFFICULTY_INDEX; ++difficulty)
	{
		Settings.SetDifficulty(difficulty);
		diffString = string(class'XComGameState_CampaignSettings'.static.GetDifficultyFromSettings());

		Template = X2MissionSourceTemplate(GetManager().FindStrategyElementTemplate(templateName));

		if(Template == none) {
			`log("Could not find difficulty variant:" @string(templateName) @"with difficulty:" @diffString);
			return;
		}

		`log("Modify difficulty variant:" @string(templateName) @"with difficulty:" @diffString);
		HandleSingleTemplate(Template, templateName);
		
	}
}

function HandleSingleTemplate(X2MissionSourceTemplate Template, name templateName) {
	Template = ReplaceFunctions(Template, templateName);
	GetManager().AddStrategyElementTemplate(Template, true);
}

 function X2MissionSourceTemplate ReplaceFunctions(X2MissionSourceTemplate Template, name templateName){


		if (templateName == 'MissionSource_Retaliation')
		{
		Template.CreateMissionsFn = CreateRetaliationMission;
		}


			return Template;

}

function CreateRetaliationMission(XComGameState NewGameState, int MissionMonthIndex)
{
	local XComGameState_Reward RewardState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local array<XComGameState_Reward> MissionRewards;
	local StateObjectReference RegionRef;
	local Vector2D v2Loc;
	local XComGameState_MissionSite MissionState;
	local X2MissionSourceTemplate MissionSource;
	local TDateTime SpawnDate;
	local XComGameState_MissionCalendar CalendarState;

	CalendarState = GetMissionCalendar(NewGameState);
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	// Retaliation missions will have a rookie rewards
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Rookie'));

	RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	NewGameState.AddStateObject(RewardState);
	MissionRewards.AddItem(RewardState);

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_Retaliation'));
	MissionState = XComGameState_MissionSite(NewGameState.CreateStateObject(class'XComGameState_MissionSite'));
	NewGameState.AddStateObject(MissionState);

	// Build Mission, region and loc will be determined later so defer computing biome/plot data
	MissionState.BuildMission(MissionSource, v2Loc, RegionRef, MissionRewards, false, false, , , , , false);
	CalendarState.CurrentMissionMonth[MissionMonthIndex].Missions.AddItem(MissionState.GetReference());
	SpawnDate = CalendarState.CurrentMissionMonth[MissionMonthIndex].SpawnDate;
	class'X2StrategyGameRulesetDataStructures'.static.RemoveTime(SpawnDate, CalendarState.RetaliationSpawnTimeDecrease);
	CalendarState.CurrentMissionMonth[MissionMonthIndex].SpawnDate = SpawnDate;
	CalendarState.RetaliationSpawnTimeDecrease = 0;

	CalendarState.CreatedMissionSources.AddItem('MissionSource_Retaliation');
}

//-------------
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

static function X2StrategyElementTemplateManager GetManager()
{
	return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}

defaultproperties
{ 

}