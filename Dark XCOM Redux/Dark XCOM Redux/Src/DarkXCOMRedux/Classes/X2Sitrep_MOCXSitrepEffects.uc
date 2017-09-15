//
class X2SitRep_MOCXSitRepEffects extends X2SitRepEffect;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	`log("Dark XCOM: bulding mission sitreps", ,'DarkXCom');

	Templates.AddItem(CreateMOCXRookiesEffectTemplate());
	Templates.AddItem(CreateFullMOCXEffectTemplate()); //this is a dummy effect

	return Templates;
}

static function X2SitRepEffectTemplate CreateMOCXRookiesEffectTemplate()
{
	local X2SitRepEffect_ModifyDefaultEncounterLists Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyDefaultEncounterLists', Template, 'MOCXRookiesEffect');
	Template.DefaultLeaderListOverride = 'MOCXLeaders';
	Template.DefaultFollowerListOverride = 'MOCXFollowers';

	return Template;
}


static function X2SitRepEffectTemplate CreateFullMOCXEffectTemplate()
{
	local X2SitRepEffectTemplate Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffectTemplate', Template, 'FullMOCXEffect');

	return Template;
}