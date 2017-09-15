class X2DarkSoldierClassModTemplates extends X2StrategyElement config(DarkClassData);

var config array<name> ClassNames;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Classes;
	local  X2DarkSoldierClassTemplate Template;
	local Name Spec;

	`log("MOCX -- Adding Dark Soldier Classes", ,'DarkXCom');
	foreach default.ClassNames(Spec)
	{
		Template = new(None, string(Spec)) class'X2DarkSoldierClassTemplate';
		Template.SetTemplateName(Spec);
		Classes.AddItem(Template);
	}
	return Classes;
}
