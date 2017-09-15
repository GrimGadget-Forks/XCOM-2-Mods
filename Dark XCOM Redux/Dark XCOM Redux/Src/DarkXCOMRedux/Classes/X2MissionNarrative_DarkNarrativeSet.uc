class X2MissionNarrative_DarkNarrativeSet extends X2MissionNarrative;


static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2MissionNarrativeTemplate> Templates;
	`log("Dark XCOM: bulding mission narratives", ,'DarkXCom');
	//recreation of base-game mission narratives for LW-specific variations
    Templates.AddItem(AddTrainingRaid()); //hack

    Templates.AddItem(AddRooftopsAssault()); //network tower

	Templates.AddItem(AddOffsiteStorage()); //troop maneuvers

    return Templates;
}


static function X2MissionNarrativeTemplate AddTrainingRaid()
{
    local X2MissionNarrativeTemplate Template;

    `CREATE_X2MISSIONNARRATIVE_TEMPLATE(Template, 'Dark_TrainingRaid');

	Template.MissionType = "Dark_TrainingRaid";

    Template.NarrativeMoments[0]="X2NarrativeMoments.TACTICAL.Hack.Hack_TacIntro";
    Template.NarrativeMoments[1]="X2NarrativeMoments.TACTICAL.General.GenTactical_SecureRetreat";
    Template.NarrativeMoments[2]="X2NarrativeMoments.TACTICAL.General.GenTactical_ConsiderRetreat";
    Template.NarrativeMoments[3]="X2NarrativeMoments.TACTICAL.General.GenTactical_AdviseRetreat";
    Template.NarrativeMoments[4]="X2NarrativeMoments.TACTICAL.General.GenTactical_PartialEVAC";
    Template.NarrativeMoments[5]="X2NarrativeMoments.TACTICAL.General.GenTactical_FullEVAC";
    Template.NarrativeMoments[6]="X2NarrativeMoments.TACTICAL.Hack.Hack_TerminalSpotted";
    Template.NarrativeMoments[7]="X2NarrativeMoments.TACTICAL.Hack.Hack_TimerNagThree";
    Template.NarrativeMoments[8]="X2NarrativeMoments.TACTICAL.Hack.Hack_TimerNagLast";
    Template.NarrativeMoments[9]="X2NarrativeMoments.TACTICAL.Hack.Hack_TimerBurnout";
    Template.NarrativeMoments[10]="X2NarrativeMoments.TACTICAL.Hack.Hack_TerminalDestroyedEnemyRemain";
    Template.NarrativeMoments[11]="X2NarrativeMoments.TACTICAL.Hack.Hack_TerminalDestroyedMissionOver";
    Template.NarrativeMoments[12]="X2NarrativeMoments.TACTICAL.General.CEN_Gen_AreaSecured_02";
    Template.NarrativeMoments[13]="X2NarrativeMoments.TACTICAL.Hack.Central_Hack_TerminalHackedWithRNF";
    Template.NarrativeMoments[14]="X2NarrativeMoments.TACTICAL.Hack.CEN_Hack_TerminalHacked";
    Template.NarrativeMoments[15]="X2NarrativeMoments.TACTICAL.General.CEN_Gen_BurnoutSecured_02";
    Template.NarrativeMoments[16]="X2NarrativeMoments.TACTICAL.General.GenTactical_SquadWipe";
    Template.NarrativeMoments[17]="X2NarrativeMoments.TACTICAL.General.GenTactical_MissionExtroFailure";
    Template.NarrativeMoments[18]="X2NarrativeMoments.TACTICAL.General.GenTactical_MissionExtroPartialSuccess";
    Template.NarrativeMoments[19]="X2NarrativeMoments.TACTICAL.General.GenTactical_MissionExtroTotalSuccess";
    Template.NarrativeMoments[20]="X2NarrativeMoments.TACTICAL.General.GenTactical_TacWinOnly";
    Template.NarrativeMoments[21]="X2NarrativeMoments.TACTICAL.General.GenTactical_SquadWipe";
    
    return Template;
}


static function X2MissionNarrativeTemplate AddOffsiteStorage()
{
    local X2MissionNarrativeTemplate Template;

    `CREATE_X2MISSIONNARRATIVE_TEMPLATE(Template, 'Dark_OffsiteStorage');

    Template.MissionType="Dark_OffsiteStorage";
    Template.NarrativeMoments[0]="X2NarrativeMoments.TACTICAL.General.CEN_Gen_AreaSecured_02";
    Template.NarrativeMoments[1]="X2NarrativeMoments.TACTICAL.General.GenTactical_SecureRetreat";
    Template.NarrativeMoments[2]="X2NarrativeMoments.TACTICAL.General.GenTactical_ConsiderRetreat";
    Template.NarrativeMoments[3]="X2NarrativeMoments.TACTICAL.General.GenTactical_PartialEVAC";
    Template.NarrativeMoments[4]="X2NarrativeMoments.TACTICAL.General.GenTactical_FullEVAC";
    Template.NarrativeMoments[5]="X2NarrativeMoments.TACTICAL.General.GenTactical_SquadWipe";
    Template.NarrativeMoments[6]="X2NarrativeMoments.TACTICAL.General.GenTactical_MissionExtroFailure";
    Template.NarrativeMoments[7]="X2NarrativeMoments.TACTICAL.General.GenTactical_MissionExtroTotalSuccess";
    
    return Template;
}


static function X2MissionNarrativeTemplate AddRooftopsAssault()
{
    local X2MissionNarrativeTemplate Template;

    `CREATE_X2MISSIONNARRATIVE_TEMPLATE(Template, 'Dark_RooftopsAssault');

	Template.MissionType = "Dark_RooftopsAssault";
    Template.NarrativeMoments[0]="X2NarrativeMoments.TACTICAL.Sabotage.Sabotage_BombDetonated";
    Template.NarrativeMoments[1]="X2NarrativeMoments.TACTICAL.Sabotage.Sabotage_TacIntro";
    Template.NarrativeMoments[2]="X2NarrativeMoments.TACTICAL.Sabotage.Sabotage_BombSpotted";
    Template.NarrativeMoments[3]="X2NarrativeMoments.TACTICAL.General.GenTactical_SquadWipe";
    Template.NarrativeMoments[4]="X2NarrativeMoments.TACTICAL.General.GenTactical_PartialEVAC";
    Template.NarrativeMoments[5]="X2NarrativeMoments.TACTICAL.General.GenTactical_FullEVAC";
    Template.NarrativeMoments[6]="X2NarrativeMoments.TACTICAL.Sabotage.Sabotage_ConsiderRetreat";
    Template.NarrativeMoments[7]="X2NarrativeMoments.TACTICAL.Sabotage.Sabotage_BombPlantedNoRNF";
    Template.NarrativeMoments[8]="X2NarrativeMoments.TACTICAL.Sabotage.Sabotage_CompletionNag";
    Template.NarrativeMoments[9]="X2NarrativeMoments.TACTICAL.Sabotage.Sabotage_RNFIncoming";
    Template.NarrativeMoments[10]="X2NarrativeMoments.TACTICAL.Sabotage.Sabotage_SignalJammed";
    Template.NarrativeMoments[11]="X2NarrativeMoments.TACTICAL.Sabotage.Sabotage_AllEnemiesDefeatedContinue";
    Template.NarrativeMoments[12]="X2NarrativeMoments.TACTICAL.Sabotage.Sabotage_AllEnemiesDefeatedObjCompleted";
    Template.NarrativeMoments[13]="X2NarrativeMoments.TACTICAL.Sabotage.Sabotage_SecureRetreat";
    Template.NarrativeMoments[14]="X2NarrativeMoments.TACTICAL.General.GenTactical_MissionExtroFailure";

    return Template;
}
