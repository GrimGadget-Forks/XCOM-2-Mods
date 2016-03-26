// This is an Unreal Script
class RM_PointOfInterestTemplateManger extends X2DataTemplateManager;

//simulated function RM_PointOfInterestTemplateManager GetRM_PointOfInterestTemplateManager();

function X2PointOfInterestTemplate FindPointOfInterestTemplate(name DataName)
{
	local X2DataTemplate kTemplate;

	kTemplate = FindDataTemplate(DataName);
	if (kTemplate != none)
		return X2PointOfInterestTemplate(kTemplate);
	return none;
}
