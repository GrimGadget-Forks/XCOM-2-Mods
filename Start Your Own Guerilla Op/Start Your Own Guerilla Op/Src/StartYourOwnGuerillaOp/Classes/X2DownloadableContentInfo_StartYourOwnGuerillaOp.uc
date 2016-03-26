//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_StartYourOwnGuerillaOp.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_StartYourOwnGuerillaOp extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static function ResearchCheck()
{
if ( !IsResearchInHistory() )
	{
		UpdateResearch();
	}
}

static event OnLoadedSavedGame()
{
if ( !IsResearchInHistory() )
	{
		UpdateResearch();
	}
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}

static function bool IsResearchInHistory()
{
	// Check if we've already injected the tech templates
	local XComGameState_Tech	TechState;
	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Tech', TechState)
	{
		if ( TechState.GetMyTemplate().name == 'Tech_PrepareCityCenterOP' )
		{
			return true;
		}
	}
	return false;
}

static function UpdateResearch()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local X2TechTemplate TechTemplate;
	local XComGameState_Tech TechState;
	local X2StrategyElementTemplateManager	StratMgr;
	
	//In this method, we demonstrate functionality that will add ExampleWeapon to the player's inventory when loading a saved
	//game. This allows players to enjoy the content of the mod in campaigns that were started without the mod installed.
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	History = `XCOMHISTORY;	

	//Create a pending game state change
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Research Templates");

	//Find tech template
	TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate('Tech_PrepareGuerillaOp'));
	TechState = XComGameState_Tech(NewGameState.CreateStateObject(class'XComGameState_Tech'));
	TechState.OnCreation(TechTemplate);
	NewGameState.AddStateObject(TechState);
	
	TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate('Tech_PrepareSupplyRaid'));
	TechState = XComGameState_Tech(NewGameState.CreateStateObject(class'XComGameState_Tech'));
	TechState.OnCreation(TechTemplate);
	NewGameState.AddStateObject(TechState);

	TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate('Tech_PrepareCityCenterOP'));
	TechState = XComGameState_Tech(NewGameState.CreateStateObject(class'XComGameState_Tech'));
	TechState.OnCreation(TechTemplate);
	NewGameState.AddStateObject(TechState);

	//Commit the state change into the history.
	History.AddGameStateToHistory(NewGameState);
}