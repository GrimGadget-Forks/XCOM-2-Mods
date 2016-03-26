// This is an Unreal Script
class RM_AWCScreenListener extends UIScreenListener;

var bool UpdatedTemplates;

// This event is triggered after a screen is initialized
event OnInit(UIScreen Screen)
{
	// But we don't want this to occur more than once, so we check this class variable.
    if(!UpdatedTemplates)
	{
		UpdatedTemplates = class'RM_AWCTemplateUpdater'.static.Update();
	}
}
 
defaultproperties
{
    // Trigger when the main view of the HQ shows
	ScreenClass = UIAvengerHUD;
}
