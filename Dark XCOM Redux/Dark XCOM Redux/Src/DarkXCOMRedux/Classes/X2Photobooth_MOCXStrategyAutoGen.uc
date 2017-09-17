// this is a special auto gen class for MOCX propaganda
// dummy config file for easy default string write
class X2Photobooth_MOCXStrategyAutoGen extends X2Photobooth_AutoGenBase config(DarkXCom);

var localized array<string> SquadDefeatedStrings1;
var localized array<string> SquadDefeatedStrings2;

var localized array<string> SquadVictoriousStrings1;
var localized array<string> SquadVictoriousStrings2;

var localized array<string> UnitWithKillsStrings;

`define RANDENTRY(arrname) `{arrname}[Rand(`{arrname}.Length)]

// we will do everything similar to the normal autogen -- except that we don't actually have a specific type to filter by
// so what we have to do is generate our propaganda ourselves, and then just supply indices to the photobooth

enum EMOCXAutoGenType
{
	eMOCXAGT_VictoriousSquad,
	eMOCXAGT_DefeatedSquad,
	eMOCXAGT_PromotedSoldier
};

// contains extensions neccessary for our custom auto gen
struct ExtendedAutoGenPhotoInfo extends AutoGenPhotoInfo
{
	// supercedes AutoGenPhotoInfo.UnitRef
	var array<StateObjectReference> Units;
	// all our posters will use ePBTLS_PromotedSoldier (victorious, promoted) or ePBTLS_DeadSoldier (defeated)
	// this is here to provide us with a way to find out what we are actually capturing
	var EMOCXAutoGenType AutoGenType;
};

var array<ExtendedAutoGenPhotoInfo> arrAutoGenRequestsExtended;

var ExtendedAutoGenPhotoInfo ExecutingPhotoboothTypeInfo;

var AutoGenCaptureState			NextAutoGenState;
var bool bWatching;

var config string strActorPath;

static function X2Photobooth_MOCXStrategyAutoGen GetMOCXAutoGen()
{
	local X2Photobooth_MOCXStrategyAutoGen Mgr;
	local WorldInfo WI;
	if (`HQPRES != none)
	{
		Mgr = X2Photobooth_MOCXStrategyAutoGen(FindObject(default.strActorPath, class'X2Photobooth_MOCXStrategyAutoGen'));
		if (Mgr != none)
		{
			return Mgr;
		}
		else
		{
			WI = class'WorldInfo'.static.GetWorldInfo();
			if (WI != none)
			{
				Mgr = WI.Spawn(class'X2Photobooth_MOCXStrategyAutoGen');
				Mgr.Init();
				default.strActorPath = PathName(Mgr);
			}
		}
		return Mgr;
	}

}

function Init()
{
	super.Init();
	AutoGenSettings.FormationLocation = GetFormationPlacementActor();
	AutoGenSettings.CameraPOV.FOV = class'UIArmory_Photobooth'.default.m_fCameraFOV;
}

function PointInSpace GetFormationPlacementActor()
{
	local PointInSpace PlacementActor;

	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'PointInSpace', PlacementActor)
	{
		if ('BlueprintLocation' == PlacementActor.Tag)
			return PlacementActor;
	}

	return none;
}

// make sure this unit is equipped with what it would be equipped with in tactical
// we can do it here relatively side-effect free because they only ever use proxies for tactical
function ValidateSoldierLoadout(StateObjectReference SoldierRef)
{
	local string strTechTierSuffix;
	local XComGameStateHistory History;
	local XComGameState_Unit Unit;
	local XComGameState_Unit_DarkXComInfo InfoState;
	local name ProxyName, LoadoutName;
	local XComGameState NewGameState;

	// ApplyInventoryLoadout

	History = `XCOMHISTORY;
	strTechTierSuffix = XComGameState_HeadquartersDarkXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersDarkXCom')).GetTierSuffixFromTech();
	
	Unit = XComGameState_Unit(History.GetGameStateForObjectID(SoldierRef.ObjectID));
	InfoState = class'UnitDarkXComUtils'.static.GetDarkXComComponent(Unit);
	// mocx soldier templates upgrade their equipment via tech
	ProxyName = name(InfoState.GetClassName() $ strTechTierSuffix);
	LoadoutName = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate(ProxyName).DefaultLoadout;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("MOCX: Make Photobooth ready");
	Unit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', Unit.ObjectID));
	Unit.ApplyInventoryLoadout(NewGameState, LoadoutName);
	`GAMERULES.SubmitGameState(NewGameState);
}

function TakePhoto()
{
	local int i;

	// Set things up for the next photo and queue it up to the photobooth.
	if (arrAutoGenRequestsExtended.Length > 0)
	{
		`log("Dark XCOM: Handling Request", ,'DarkXCom');
		ExecutingPhotoboothTypeInfo = arrAutoGenRequestsExtended[0];

		AutoGenSettings.PossibleSoldiers.Length = 0;
		for (i = 0; i < ExecutingPhotoboothTypeInfo.Units.Length; i++)
		{
			ValidateSoldierLoadout(ExecutingPhotoboothTypeInfo.Units[i]);
			AutoGenSettings.PossibleSoldiers.AddItem(ExecutingPhotoboothTypeInfo.Units[i]);
		}
		switch (ExecutingPhotoboothTypeInfo.AutoGenType)
		{
				case eMOCXAGT_VictoriousSquad:
				case eMOCXAGT_PromotedSoldier:
					AutoGenSettings.TextLayoutState = ePBTLS_PromotedSoldier;
					break;
				case eMOCXAGT_DefeatedSquad:
					AutoGenSettings.TextLayoutState = ePBTLS_DeadSoldier;
					break;
		}
		//AutoGenSettings.TextLayoutState = ExecutingPhotoboothTypeInfo.TextLayoutState;
		AutoGenSettings.HeadShotAnimName = '';
		AutoGenSettings.CameraPOV.FOV = class'UIArmory_Photobooth'.default.m_fCameraFOV;
		AutoGenSettings.BackgroundDisplayName = class'X2DownloadableContentInfo_DarkXCOMRedux'.default.m_arrBackgroundOptions[0].BackgroundDisplayName;
//		SetFormation("Line");
		AutoGenSettings.CameraPresetDisplayName = "Full Frontal";

		`PHOTOBOOTH.SetAutoGenSettings(AutoGenSettings, PhotoTaken);
		`log("Dark XCOM: Kicked off", ,'DarkXCom');
		`log("Verify CampaignID:" @ `PHOTOBOOTH.AutoGenSettings.CampaignID, , 'DarkXCom');
		NextAutoGenState = eAGCS_TickPhase1;
		bWatching = true;
	}
	else
	{
		`log("Dark XCOM: Finished Queue, cleaning up", , 'DarkXCom');
		m_bTakePhotoRequested = false;
		Cleanup();
	}
}

function AddRequest(array<StateObjectReference> Units, EMOCXAutoGenType Type)
{
	local ExtendedAutoGenPhotoInfo LocalInfo;
	LocalInfo.Units = Units;
	LocalInfo.AutoGenType = Type;

	arrAutoGenRequestsExtended.AddItem(LocalInfo);
}

function AddRequestSingleUnit(StateObjectReference Unit, EMOCXAutoGenType Type)
{
	local array<StateObjectReference> Units;
	Units.AddItem(Unit);
	AddRequest(Units, Type);
}

function RequestPhotos()
{
	m_bTakePhotoRequested = true;
}

function PhotoTaken(StateObjectReference UnitRef)
{
	local delegate<OnAutoGenPhotoFinished> CallDelegate;
	`log("Dark XCom: Photo finished", ,'DarkXCom');
	foreach arrAutoGenRequestsExtended[0].FinishedDelegates(CallDelegate)
	{
		if (CallDelegate != none)
		{
			CallDelegate(arrAutoGenRequestsExtended[0].Units[0]);
		}
	}
	arrAutoGenRequestsExtended.Remove(0, 1);
	bWatching = false;
}

// our tick group is set to TG_PostAsyncWork, while the Photobooth is set to PreAsyncWork (by default)
// in theory, we should be able to squeeze in our changes after the photobooth has moved states.
event Tick(float fDeltaTime)
{
	super.Tick(fDeltaTime);
	if (bWatching)
	{
		`log("Dark XCom: State" @ GetEnum(Enum'AutoGenCaptureState', `PHOTOBOOTH.m_kAutoGenCaptureState), ,'DarkXCom');
		`log("Dark XCom: watiting for" @ GetEnum(Enum'AutoGenCaptureState', NextAutoGenState), ,'DarkXCom');
		if ((`PHOTOBOOTH.m_kAutoGenCaptureState - 1) == NextAutoGenState)
		{
			switch (NextAutoGenState)
			{
				case eAGCS_TickPhase1:
					if (!`PHOTOBOOTH.DeferPhase1())
					{
						`log("Dark XCom: Handling phase 1", ,'DarkXCom');
						HandlePostPhaseOne();
						NextAutoGenState = eAGCS_TickPhase2;
					}
					break;
				case eAGCS_TickPhase2:
					if (!`PHOTOBOOTH.DeferPhase2())
					{
						`log("Dark XCom: Handling phase 2", ,'DarkXCom');
						HandlePostPhaseTwo();
						NextAutoGenState = 250;
					}
					break;
				// we cannot interfere with those
				case eAGCS_TickPhase3:
				case eAGCS_Capturing:
				case eAGCS_Idle:
					NextAutoGenState = 250;
					break;
			}
		}
	}
}

// Text layout+strings, background
function HandlePostPhaseOne()
{
	local UIImage MOCXIcon;
	local XComGameState_Unit PosterUnit;
	local XComGameState_Unit_DarkXComInfo Info;
	local X2Photobooth Photobooth;
	PosterUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ExecutingPhotoboothTypeInfo.Units[0].ObjectID));
	Info = class'UnitDarkXComUtils'.static.GetDarkXComComponent(PosterUnit);
	// hardcoded "simple" layout
	Photobooth = `PHOTOBOOTH;
	Photobooth.SetLayoutIndex(14);
	switch (ExecutingPhotoboothTypeInfo.AutoGenType)
	{
		case eMOCXAGT_DefeatedSquad:
			Photobooth.SetTextBoxString(0, `RANDENTRY(SquadDefeatedStrings1));
			Photobooth.SetTextBoxString(1, `RANDENTRY(SquadDefeatedStrings2));
			// grayscale
			Photobooth.SetFirstPassFilter(4);
			break;
		case eMOCXAGT_PromotedSoldier:
			Photobooth.SetTextBoxString(0, class'UnitDarkXComUtils'.static.GetFullName(PosterUnit));
			Photobooth.SetTextBoxString(1, Repl(`RANDENTRY(UnitWithKillsStrings), "%KILLS", Info.KilledXComUnits.Length));
			break;
		case eMOCXAGT_VictoriousSquad:
			Photobooth.SetTextBoxString(0, `RANDENTRY(SquadVictoriousStrings1));
			Photobooth.SetTextBoxString(1, `RANDENTRY(SquadVictoriousStrings2));
			break;
	}

	Photobooth.SetBackgroundColorOverride(true);
	Photobooth.SetGradientColor1(Photobooth.CapturedTintColor1);
	Photobooth.SetGradientColor2(Photobooth.CapturedTintColor2);

	// we render a MOCX icon to the photobooth as a replacement for not having access to custom layouts
	// this makes it clear to the user that this is a MOCX poster
	MOCXIcon = Spawn(class'UIImage', Photobooth.m_backgroundPoster);
	MOCXIcon.bAnimateOnInit = false;
	MOCXIcon.bIsNavigable = false;
	MOCXIcon.InitImage('', "img:///MOCX_Photobooth.icon_mocx");
	MOCXIcon.SetSize(256, 256);
	MOCXIcon.AnchorBottomRight();
	MOCXIcon.SetPosition(-270, -270);
}

// soldier anims
function HandlePostPhaseTwo()
{

}

defaultproperties
{
	// X2Photobooth ticks PreAsyncWork -- let's tick after it to make our custom changes
	TickGroup=TG_PostAsyncWork
}