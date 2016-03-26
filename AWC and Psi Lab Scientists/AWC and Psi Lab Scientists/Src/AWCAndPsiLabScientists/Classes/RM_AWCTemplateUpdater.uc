// This is an Unreal Script
class RM_AWCTemplateUpdater extends Object;

static function bool Update()
{	
	local X2StrategyElementTemplateManager StrategyElementTemplateManager;
	local array<X2DataTemplate> Templates; //calls up array to search the class of variables in
	local X2StaffSlotTemplate Template; //calls up the exact class to be altered
	local int i;

	StrategyElementTemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Templates = StrategyElementTemplateManager.GetAllTemplatesOfClass(class'X2StaffSlotTemplate');

	for(i = 0; i < Templates.Length; ++i)
	{
		Template = X2StaffSlotTemplate(Templates[i]); //the template being currently compared

		if(Template.Name == 'AWCScientistStaffSlot')
		{
			Template.bEngineerSlot = false;
			Template.bScientistSlot = true;
			//this should make it use a scientist instead of an engineer
		}
		else
		{

		}

	}
	
	return true;
}
