class RM_SquadSelect_ScreenListener extends UIScreenListener config(SquadCohesion);

var public localized String m_strSquadCohesion;
var public localized String m_strNoSquadCohesion;
var public localized String m_strNegiSquadCohesion;
var public localized String m_strLowSquadCohesion;
var public localized String m_strMedSquadCohesion;
var public localized String m_strHighSquadCohesion;

var config int LOW_SQUAD_COHESION;
var config int MED_SQUAD_COHESION;
var config int HIGH_SQUAD_COHESION;
var config int REDUCER;

var config int X_POSITION;
var config int Y_POSITION;
var config int TITLE_X_POSITION;
var config int TITLE_Y_POSITION;


var UIText SquadCohesionLevel;
var UIText SquadCohesionTitle;
var XComGameState_HeadquartersXCom XComHQ;




var int SquadCohesionInt;



event OnInit(UIScreen Screen)
{
    local UISquadSelect squadSelect;
    squadSelect = UISquadSelect(screen);

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	SquadCohesionInt = GetSquadCohesionValue(XComHQ.Squad) * REDUCER;
	`Log("Updating Cohesion");
	RefreshVisuals(squadSelect);
}

event OnReceiveFocus(UIScreen Screen)
{
    local UISquadSelect squadSelect;
    squadSelect = UISquadSelect(screen);

	//`Log("+++ Focusing Squadload");
	//SquadCohesionLevel.Show();
	//SquadCohesionTitle.Show();
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	SquadCohesionInt = GetSquadCohesionValue(XComHQ.Squad) * REDUCER;
	`Log("Updating Cohesion");
	SquadCohesionTitle.Show();
	RefreshVisuals(squadSelect);	
	//SquadCohesionLevel.Show();

}

event OnLoseFocus(UIScreen Screen)
{
	//`Log("+++ Unfocusing Squadload");
	//SquadCohesionLevel.Hide();
	//SquadCohesionTitle.Hide();

	`Log("Hiding Cohesion, Updating");
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	SquadCohesionInt = GetSquadCohesionValue(XComHQ.Squad) * REDUCER;
	SquadCohesionLevel.Remove();
	SquadCohesionTitle.Hide();
}

event OnRemoved(UIScreen Screen)
{
	`Log("Removing Cohesion");
	SquadCohesionLevel.Remove();
	SquadCohesionTitle.Remove();
}

//refresh the value every time the player goes to add a soldier
function RefreshVisuals(UISquadSelect squadSelect)
{
	//local XComGameState_MissionSite MissionState;
	//local XComGameState_HeadquartersXCom XComHQ;
	//local int SquadCohesionInt;
	local string SquadCohesion;

	`Log("+++ Initing Squadload");


	//XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	SquadCohesion = string(SquadCohesionInt);


	//	MissionState = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.MissionRef.ObjectID));
	//	MissionState.GetShadowChamberStrings();
		
		SquadCohesionTitle =  squadSelect.Spawn(class'UIText',  squadSelect);
		SquadCohesionTitle.InitText('SquadCohesionTitle');
		SquadCohesionTitle.SetText(class'UIUtilities_Text'.static.GetSizedText(class'UIUtilities_Text'.static.GetColoredText(m_strSquadCohesion, eUIState_Normal),25));
		SquadCohesionTitle.AnchorTopRight();
		SquadCohesionTitle.SetY(default.Y_POSITION);
		SquadCohesionTitle.SetX(default.X_POSITION);
		
		SquadCohesionLevel =  squadSelect.Spawn(class'UIText',  squadSelect);
		SquadCohesionLevel.InitText('SquadCohesionLevel');
		SquadCohesionLevel.AnchorTopRight();
		if(SquadCohesionInt >= LOW_SQUAD_COHESION && SquadCohesionInt < MED_SQUAD_COHESION)
		{
		SquadCohesionLevel.SetText(class'UIUtilities_Text'.static.GetColoredText(SquadCohesion $ " " $ m_strLowSquadCohesion, eUIState_Warning));
		}
		if(SquadCohesionInt >= MED_SQUAD_COHESION && SquadCohesionInt < HIGH_SQUAD_COHESION)
		{
		SquadCohesionLevel.SetText(class'UIUtilities_Text'.static.GetColoredText(SquadCohesion $ " " $ m_strMedSquadCohesion , eUIState_Normal));
		}
		if(SquadCohesionInt >= HIGH_SQUAD_COHESION)
		{
		SquadCohesionLevel.SetText(class'UIUtilities_Text'.static.GetColoredText(SquadCohesion $ " " $ m_strHighSquadCohesion , eUIState_Good));
		}
		if (SquadCohesionInt > 0 && SquadCohesionint < LOW_SQUAD_COHESION)
		{
		SquadCohesionLevel.SetText(class'UIUtilities_Text'.static.GetColoredText(SquadCohesion $ " " $ m_strNegiSquadCohesion  , eUIState_Warning));
		}
		if (SquadCohesionInt <= 0)
		{
		SquadCohesionLevel.SetText(class'UIUtilities_Text'.static.GetColoredText(SquadCohesion $ " " $ m_strNoSquadCohesion  , eUIState_Bad));
		}
		SquadCohesionLevel.SetY(default.TITLE_Y_POSITION);
		SquadCohesionLevel.SetX(default.TITLE_X_POSITION);
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


defaultproperties
{
	ScreenClass=class'UISquadSelect'
}