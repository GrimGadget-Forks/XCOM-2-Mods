class X2Ability_MentorConfidence extends X2Ability config(MentorConfidence);

var config int MC_WILL_BONUS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(MentorConfidence());

	return Templates;
}

static function X2AbilityTemplate MentorConfidence()
{
	local X2AbilityTemplate                 Template;
	local X2Effect_PersistentStatChange		PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'MentorConfidence');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_inspire";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.bIsPassive = true;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	PersistentEffect = new class'X2Effect_PersistentStatChange';
	PersistentEffect.BuildPersistentEffect(1, true, false);
	PersistentEffect.AddPersistentStatChange(eStat_Will, default.MC_WILL_BONUS);
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	Template.AddTargetEffect(PersistentEffect);

	Template.SetUIStatMarkup(class'XLocalizedData'.default.WillLabel, eStat_Will, default.MC_WILL_BONUS);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}