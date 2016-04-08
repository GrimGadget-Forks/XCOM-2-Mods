class RM_UIPersonnel_SquadSelect_ScreenListener  extends UIScreenListener config(SquadCohesion);

var public localized String m_strCohesion;
var public localized String m_strNoCohesion;
var public localized String m_strLowCohesion;
var public localized String m_strMedCohesion;
var public localized String m_strHighCohesion;

var protected config int X_POSITION;
var protected config int Y_POSITION;

var XComGameState_HeadquartersXCom XComHQ;
var RM_SquadSelect_ScreenListener IniValues;

var UIPersonnel		Personnel;
var array<UIText>	CohesionText;

var int SquadCohesionInt;
var UIText SquadCohesionLevel;
var UIText SquadCohesionTitle;

//---------------------------------------------------------------------------------------
//The UI Screen has been initialized - Refresh Data
event OnInit(UIScreen Screen)
{
	if(UIPersonnel_SquadSelect(Screen) != none)
	{
		
		IniValues = new class'RM_SquadSelect_ScreenListener';
		XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
		SquadCohesionInt = GetSquadCohesionValue(XComHQ.Squad) * IniValues.REDUCER;
		ShowTotalCohesion(Screen);
		RefreshVisuals(Screen);
	}
}

//The UI Screen has regained focus - Refresh Data
event OnReceiveFocus(UIScreen Screen)
{
	if(UIPersonnel_SquadSelect(Screen) != none)
	{
		
		IniValues = new class'RM_SquadSelect_ScreenListener';
		XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
		SquadCohesionInt = GetSquadCohesionValue(XComHQ.Squad) * IniValues.REDUCER;
		ShowTotalCohesion(Screen);
		RefreshVisuals(Screen);
	}
}

//The UI Screen has lost focus - Hide Data
event OnLoseFocus(UIScreen Screen)
{
	if(UIPersonnel_SquadSelect(Screen) != none)
	{
		DeleteAllVisuals();
		SquadCohesionLevel.Remove();
		SquadCohesionTitle.Hide();
	}
}

//The UI Screen has been removed - Discard Data
event OnRemoved(UIScreen Screen)
{
	if(UIPersonnel_SquadSelect(Screen) != none)
	{
		DeleteAllVisuals();
		SquadCohesionLevel.Remove();
		SquadCohesionTitle.Remove();
	}
}

//---------------------------------------------------------------------------------------
//Refreshes the cohesion text visuals in the personnel screen
function RefreshVisuals(UIScreen Screen)
{
	local UIPersonnel_ListItem	ListItem; 
	local UIText				TextItem;
	local int					i;

	Personnel = UIPersonnel(Screen);

	for(i = 0; i < Personnel.m_kList.ItemCount; i++)
	{
		ListItem = UIPersonnel_ListItem(Personnel.m_kList.GetItem(i));
		TextItem = CreateVisual(ListItem);

		if(TextItem != none)
			CohesionText.AddItem(TextItem);
	}
}

//Creates a UIText item for the cohesion display in the personnel list
function UIText CreateVisual(UIPersonnel_ListItem ListItem)
{
	local XComGameState_Unit			Unit;
	local UIText						NewText;
	local string						SquadCohesion;
	local array<XComGameState_Unit> allUnits;

	IniValues = new class'RM_SquadSelect_ScreenListener';
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ListItem.UnitRef.ObjectID));
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	//If we're looking at a soldier...
	if(!Unit.IsAnEngineer() && !Unit.IsAScientist())
	{
		NewText = ListItem.Spawn(class'UIText', ListItem);
		NewText.InitText(,"TEST");


		SquadCohesion = string(GetListCohesionValue(Unit) * IniValues.REDUCER);
		if (int(SquadCohesion) > 0)
		{
		NewText.SetText(class'UIUtilities_Text'.static.GetSizedText(class'UIUtilities_Text'.static.GetColoredText(m_strCohesion $ m_strLowCohesion, eUIState_Normal),16)); //$ "(" $ SquadCohesion $ ")", eUIState_Normal),16));
		}

		if (int(SquadCohesion) >= (IniValues.MED_SQUAD_COHESION / 4) && int(SquadCohesion) < (IniValues.HIGH_SQUAD_COHESION / 4))
		{
		NewText.SetText(class'UIUtilities_Text'.static.GetSizedText(class'UIUtilities_Text'.static.GetColoredText(m_strCohesion $ m_strMedCohesion, eUIState_Normal),16)); //$ "(" $ SquadCohesion $ ")", eUIState_Normal),16));
		}

		if (int(SquadCohesion) >= (IniValues.HIGH_SQUAD_COHESION / 4))
		{
		NewText.SetText(class'UIUtilities_Text'.static.GetSizedText(class'UIUtilities_Text'.static.GetColoredText(m_strCohesion $ m_strHighCohesion, eUIState_Normal),16)); //$ "(" $ SquadCohesion $ ")", eUIState_Normal),16));
		}
		if (int(SquadCohesion) <= 0)
		{
		NewText.SetText(class'UIUtilities_Text'.static.GetSizedText(class'UIUtilities_Text'.static.GetColoredText(m_strCohesion $ m_strNoCohesion, eUIState_Normal),16)); //$ "(" $ SquadCohesion $ ")", eUIState_Normal),16));
		}

		NewText.SetPosition(default.X_POSITION,default.Y_POSITION);
		return NewText;
	}

	return none;
}


//Clears all UIText visuals from memory
function DeleteAllVisuals()
{
	local int i;

	for(i = 0; i < CohesionText.Length; i++)
	{
		CohesionText[i].Remove();
	}

	CohesionText.Length = 0;
}

function int GetListCohesionValue(XComGameState_Unit ListSoldier)
{
	local int TotalCohesion, i, XComCheck;
	local SquadmateScore Score;
	local XComGameState_Unit UnitState, Unit;
	local array<XComGameState_Unit> XComUnits;
	//local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	TotalCohesion = 0;
	
	//for(XComCheck = 0; XComCheck < XComHQ.Squad.Length; ++XComCheck)
	//{
	//	if(XComHQ.Squad[XComCheck].ObjectID == Units[XComCheck].ObjectID)
	//	{
	//		UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.Squad[XComCheck].ObjectID));
	//		XComUnits.AddItem(UnitState);
	//	}
	//}

	//foreach XComUnits(Unit)
	//{
	for(XComCheck = 0; XComCheck < XComHQ.Squad.Length; ++XComCheck)
	{
		ListSoldier.GetSquadmateScore(XComHQ.Squad[XComCheck].ObjectID, Score);
		TotalCohesion = TotalCohesion + Score.Score;
	
	
	}
	return TotalCohesion;
}


function ShowTotalCohesion(UIScreen Screen)
{
	//local XComGameState_MissionSite MissionState;
	//local XComGameState_HeadquartersXCom XComHQ;
	//local int SquadCohesionInt;
	local string SquadCohesion;

	`Log("+++ Initing Squadload");

	IniValues = new class'RM_SquadSelect_ScreenListener';
	//XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	SquadCohesion = string(SquadCohesionInt);


	//	MissionState = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.MissionRef.ObjectID));
	//	MissionState.GetShadowChamberStrings();
		
		SquadCohesionTitle =  Screen.Spawn(class'UIText',  screen);
		SquadCohesionTitle.InitText('SquadCohesionTitle');
		SquadCohesionTitle.SetText(class'UIUtilities_Text'.static.GetSizedText(class'UIUtilities_Text'.static.GetColoredText(IniValues.m_strSquadCohesion, eUIState_Normal),25));
		SquadCohesionTitle.AnchorTopRight();
		SquadCohesionTitle.SetY(IniValues.Y_POSITION);
		SquadCohesionTitle.SetX(IniValues.X_POSITION);
		
		SquadCohesionLevel =  screen.Spawn(class'UIText',  screen);
		SquadCohesionLevel.InitText('SquadCohesionLevel');
		SquadCohesionLevel.AnchorTopRight();
		if(SquadCohesionInt >= IniValues.LOW_SQUAD_COHESION && SquadCohesionInt < IniValues.MED_SQUAD_COHESION)
		{
		SquadCohesionLevel.SetText(class'UIUtilities_Text'.static.GetColoredText(SquadCohesion $ " " $ IniValues.m_strLowSquadCohesion, eUIState_Warning));
		}
		if(SquadCohesionInt >= IniValues.MED_SQUAD_COHESION && SquadCohesionInt < IniValues.HIGH_SQUAD_COHESION)
		{
		SquadCohesionLevel.SetText(class'UIUtilities_Text'.static.GetColoredText(SquadCohesion $ " " $ IniValues.m_strMedSquadCohesion , eUIState_Normal));
		}
		if(SquadCohesionInt >= IniValues.HIGH_SQUAD_COHESION)
		{
		SquadCohesionLevel.SetText(class'UIUtilities_Text'.static.GetColoredText(SquadCohesion $ " " $ IniValues.m_strHighSquadCohesion , eUIState_Good));
		}
		if (SquadCohesionInt > 0 && SquadCohesionint < IniValues.LOW_SQUAD_COHESION)
		{
		SquadCohesionLevel.SetText(class'UIUtilities_Text'.static.GetColoredText(SquadCohesion $ " " $ IniValues.m_strNegiSquadCohesion  , eUIState_Warning));
		}
		if (SquadCohesionInt <= 0)
		{
		SquadCohesionLevel.SetText(class'UIUtilities_Text'.static.GetColoredText(SquadCohesion $ " " $ IniValues.m_strNoSquadCohesion  , eUIState_Bad));
		}
		SquadCohesionLevel.SetY(IniValues.TITLE_Y_POSITION);
		SquadCohesionLevel.SetX(IniValues.TITLE_X_POSITION);
		//SquadCohesionLevel.SetWidth(320);

		SquadCohesionTitle.Show();
		SquadCohesionLevel.Show();
}

function int GetSquadCohesionValue(array<StateObjectReference> Units)
{
	local int TotalCohesion, i, j, XComCheck;
	local SquadmateScore Score;
	local XComGameState_Unit UnitState;
	local array<XComGameState_Unit> XComUnits;
	//local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	TotalCohesion = 0;
	
	for(XComCheck = 0; XComCheck < XComHQ.Squad.Length; ++XComCheck)
	{
		if(XComHQ.Squad[XComCheck].ObjectID == Units[XComCheck].ObjectID)
		{
			UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.Squad[XComCheck].ObjectID));
			XComUnits.AddItem(UnitState);
		}
	}

	for (i = 0; i < XComHQ.Squad.Length; ++i)
	{

		for (j = i + 1; j < XComHQ.Squad.Length; ++j)
		{
			if (XComUnits[i].GetSquadmateScore(XComHQ.Squad[j].ObjectID, Score))
			{
				TotalCohesion += Score.Score;
			}
		}
	}
	return TotalCohesion;
}



//---------------------------------------------------------------------------------------
defaultproperties
{
	ScreenClass = none
}