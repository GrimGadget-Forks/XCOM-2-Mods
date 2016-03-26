// This is an Unreal Script
class X2MissionNarrative_TerrorDefence extends X2MissionNarrative;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2MissionNarrativeTemplate> Templates;

    Templates.AddItem(AddRMTerrorDefenceNarrativeTemplate());
	Templates.AddItem(AddRMGuerillaVIPNeutralizeTemplate());

    return Templates;
}

static function X2MissionNarrativeTemplate AddRMTerrorDefenceNarrativeTemplate()
{
    local X2MissionNarrativeTemplate Template;

    `CREATE_X2MISSIONNARRATIVE_TEMPLATE(Template, 'RM_Terror_Defence');

    Template.MissionType = "RM_Terror_Defence";
    Template.NarrativeMoments[0]="X2NarrativeMoments.TACTICAL.Terror.Terror_AllEnemiesDefeated";
    Template.NarrativeMoments[1]="X2NarrativeMoments.TACTICAL.General.GenTactical_SecureRetreat";
    Template.NarrativeMoments[2]="X2NarrativeMoments.TACTICAL.General.GenTactical_ConsiderRetreat";
    Template.NarrativeMoments[3]="X2NarrativeMoments.TACTICAL.Terror.Terror_AdviseRetreat";
    Template.NarrativeMoments[4]="X2NarrativeMoments.TACTICAL.General.GenTactical_PartialEVAC";
    Template.NarrativeMoments[5]="X2NarrativeMoments.TACTICAL.General.GenTactical_FullEVAC";
    Template.NarrativeMoments[6]="X2NarrativeMoments.TACTICAL.General.GenTactical_SquadWipe";
    Template.NarrativeMoments[7]="X2NarrativeMoments.TACTICAL.Terror.Terror_TacIntro";
	Template.NarrativeMoments[8]="X2NarrativeMoments.TACTICAL.General.GenTactical_SquadWipe";
    Template.NarrativeMoments[9]="X2NarrativeMoments.TACTICAL.General.GenTactical_MissionExtroFailure";
    Template.NarrativeMoments[10]="X2NarrativeMoments.TACTICAL.General.GenTactical_MissionExtroPartialSuccess";
    Template.NarrativeMoments[11]="X2NarrativeMoments.TACTICAL.General.GenTactical_MissionExtroTotalSuccess";
    Template.NarrativeMoments[12]="X2NarrativeMoments.TACTICAL.General.GenTactical_TacWinOnly";
	Template.NarrativeMoments[13]="X2NarrativeMoments.TACTICAL.General.GenTactical_SquadWipe";
    Template.NarrativeMoments[14]="X2NarrativeMoments.T_Retaliation_Reminder_Squad_Not_Concealed_C_Central";
	Template.NarrativeMoments[15]="X2NarrativeMoments.TACTICAL.AvengerDefense.AvengerDefense_RNFFirst";

    return Template;
}




static function X2MissionNarrativeTemplate AddRMGuerillaVIPNeutralizeTemplate()
{
    local X2MissionNarrativeTemplate Template;

    `CREATE_X2MISSIONNARRATIVE_TEMPLATE(Template, 'RM_GuerillaOp_Neutralize');

    Template.MissionType = "RM_GuerillaOp_Neutralize";
    Template.NarrativeMoments[0]="X2NarrativeMoments.TACTICAL.Neutralize.Neutralize_TacIntro";
    Template.NarrativeMoments[1]="X2NarrativeMoments.TACTICAL.Neutralize.Neutralize_VIPSpotted";
    Template.NarrativeMoments[2]="X2NarrativeMoments.TACTICAL.General.SKY_ExtrGEN_STObjSecured";
    Template.NarrativeMoments[3]="X2NarrativeMoments.TACTICAL.Neutralize.Neutralize_VIPKilledAfterCapture";
    Template.NarrativeMoments[4]="X2NarrativeMoments.TACTICAL.Neutralize.Neutralize_VIPExecuted";
    Template.NarrativeMoments[5]="X2NarrativeMoments.TACTICAL.Neutralize.CEN_Neut_TargetInCustody";
	Template.NarrativeMoments[6]="X2NarrativeMoments.TACTICAL.RescueVIP.CEN_RescGEN_ProceedToSweep";
	Template.NarrativeMoments[7]="X2NarrativeMoments.TACTICAL.Forge.Forge_SecureRetreat"; //Commander, we got what we came for, they're going to keep sending reinforcements until we get out of here
    Template.NarrativeMoments[10]="X2NarrativeMoments.TACTICAL.RescueVIP.Central_Rescue_VIP_RNFInbound"; //Menace, Firebrand can't approach the AO evac, regroup and try to buy us time for extraction!
    Template.NarrativeMoments[11]="X2NarrativeMoments.TACTICAL.Neutralize.Neutralize_AdviseRetreat";
    Template.NarrativeMoments[12]="X2NarrativeMoments.TACTICAL.General.GenTactical_ConsiderRetreat";
    Template.NarrativeMoments[13]="X2NarrativeMoments.TACTICAL.Neutralize.Neutralize_SecureRetreat";
    Template.NarrativeMoments[14]="X2NarrativeMoments.TACTICAL.RescueVIP.Central_Rescue_VIP_EvacDestroyed";
    Template.NarrativeMoments[15]="X2NarrativeMoments.TACTICAL.General.GenTactical_SquadWipe";
    Template.NarrativeMoments[16]="X2NarrativeMoments.TACTICAL.General.GenTactical_MissionExtroFailure";
    Template.NarrativeMoments[17]="X2NarrativeMoments.TACTICAL.General.GenTactical_MissionExtroPartialSuccess";
    Template.NarrativeMoments[18]="X2NarrativeMoments.TACTICAL.General.GenTactical_MissionExtroTotalSuccess";
    Template.NarrativeMoments[19]="X2NarrativeMoments.TACTICAL.General.GenTactical_TacWinOnly";
    Template.NarrativeMoments[20]="X2NarrativeMoments.TACTICAL.General.GenTactical_SquadWipe";
	Template.NarrativeMoments[21]="X2NarrativeMoments.TACTICAL.support.T_Support_Reminder_Knock_Out_VIP_Central_01";

    return Template;
}