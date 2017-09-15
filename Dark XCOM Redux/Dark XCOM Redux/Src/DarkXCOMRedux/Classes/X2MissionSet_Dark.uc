class X2MissionSet_Dark extends X2Mission config(GameCore);

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2MissionTemplate> Templates;
	`log("Dark XCOM: bulding missions", ,'DarkXCom');
    Templates.AddItem(AddMissionTemplate('Dark_RooftopsAssault'));
    Templates.AddItem(AddMissionTemplate('Dark_TrainingRaid'));
    Templates.AddItem(AddMissionTemplate('Dark_OffsiteStorage'));


    return Templates;
}

static function X2MissionTemplate AddMissionTemplate(name missionName)
{
    local X2MissionTemplate Template;
	`CREATE_X2TEMPLATE(class'X2MissionTemplate', Template, missionName);
    return Template;
}
