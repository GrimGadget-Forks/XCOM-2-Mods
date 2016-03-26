// This is an Unreal Script
class X2MissionSet_TerrorDefence extends X2MissionSet config(GameCore);

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2MissionTemplate> Templates;

    Templates.AddItem(AddMissionTemplate('RM_Terror_Defence'));
	//Templates.AddItem(AddMissionTemplate('RM_Sabotage_Raid'));
	Templates.AddItem(AddMissionTemplate('RM_GuerillaOp_Neutralize'));

    return Templates;
}
