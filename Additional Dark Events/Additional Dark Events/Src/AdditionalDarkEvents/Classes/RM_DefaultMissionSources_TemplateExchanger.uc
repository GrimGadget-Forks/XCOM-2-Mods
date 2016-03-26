// This is an Unreal Script
class RM_DefaultMissionSources_TemplateExchanger extends X2AmbientNarrativeCriteria config (DarkEvents);

var config int AvengerWatchChance;

var XComGameState_CampaignSettings Settings;

static function array<X2DataTemplate> CreateTemplates(){
	local array<X2DataTemplate> EmptyArray;
	local RM_DefaultMissionSources_TemplateExchanger Exchanger;
	
	`log("Make Doom-based Mission Difficulty starts modifiying Mission Source Templates");
	Exchanger = new class'RM_DefaultMissionSources_TemplateExchanger';
	Exchanger.Settings = GameStateMagic();
	Exchanger.ModifyTemplates();

	`XCOMHISTORY.ResetHistory(); // yeah, lets do that, nothing happend anyway...

	`log("Additional Dark Events modifications finished");

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
	
	HandleTemplate('MissionSource_GuerillaOp');
	HandleTemplate('MissionSource_Retaliation');
	HandleTemplate('MissionSource_SupplyRaid');
	HandleTemplate('MissionSource_Council');
	HandleTemplate('MissionSource_LandedUFO');
	HandleTemplate('MissionSource_AlienNetwork');
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

		local XComGameState_HeadquartersXcom XComHQ;
		XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

		//Template.WasMissionSuccessfulFn = StrategyObjectivePlusSweepCompleted;

		if (templateName == 'MissionSource_GuerillaOp')
		{
		Template.SpawnUFOChance = 0;
			if(XComHQ.TacticalGameplayTags.Find('DarkEvent_AvengerWatch') != INDEX_NONE)
			{
			Template.SpawnUFOChance = AvengerWatchChance;
			}
		}

		if (templateName == 'MissionSource_Retaliation')
		{
		Template.SpawnUFOChance = 0;
			if(XComHQ.TacticalGameplayTags.Find('DarkEvent_AvengerWatch') != INDEX_NONE)
			{
			Template.SpawnUFOChance = AvengerWatchChance;
			}
		}
		
		if (templateName == 'MissionSource_SupplyRaid')
		{
		Template.SpawnUFOChance = 0;
			
			if(XComHQ.TacticalGameplayTags.Find('DarkEvent_AvengerWatch') != INDEX_NONE)
			{
			Template.SpawnUFOChance = AvengerWatchChance;
			}
		}

		if (templateName == 'MissionSource_Council')
		{
		Template.SpawnUFOChance = 0;

			if(XComHQ.TacticalGameplayTags.Find('DarkEvent_AvengerWatch') != INDEX_NONE)
			{
			Template.SpawnUFOChance = AvengerWatchChance;
			}
		}

		if (templateName == 'MissionSource_LandedUFO')
		{
		Template.SpawnUFOChance = 0;

			if(XComHQ.TacticalGameplayTags.Find('DarkEvent_AvengerWatch') != INDEX_NONE)
			{
			Template.SpawnUFOChance = AvengerWatchChance;
			}
		}

		if (templateName == 'MissionSource_AlienNetwork')
		{
		Template.SpawnUFOChance = 0;
			if(XComHQ.TacticalGameplayTags.Find('DarkEvent_AvengerWatch') != INDEX_NONE)
			{
			Template.SpawnUFOChance = AvengerWatchChance;
			}

		}
			return Template;

}



static function X2StrategyElementTemplateManager GetManager()
{
	return class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
}